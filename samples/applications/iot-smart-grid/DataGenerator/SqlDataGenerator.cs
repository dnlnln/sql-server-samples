//----------------------------------------------------------------------------------  
// Copyright (c) Microsoft Corporation. All rights reserved.  
//  
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,   
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES   
// OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
//----------------------------------------------------------------------------------  
// The example companies, organizations, products, domain names,  
// e-mail addresses, logos, people, places, and events depicted  
// herein are fictitious.  No association with any real company,  
// organization, product, domain name, email address, logo, person,  
// places, or events is intended or should be inferred.  

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Data.SqlClient;
using System.Data.Sql;
using System.Data;
using System.Diagnostics;
using System.Collections.Concurrent;
using Microsoft.SqlServer.Server;

namespace DataGenerator
{
    /// <summary>SqlDataGenerator is a class used for creating SQL Server sample data by using multiple Asychronous Tasks.</summary>
    public class SqlDataGenerator
    {
        private string[] postalCodes = {"98001","98002","98003","98004","98005","98006","98007","98008","98009","98010","98011","98012","98013","98014","98015","98019","98020","98021","98022","98023",
                                        "98024","98025","98026","98027","98028","98029","98030","98031","98032","98033","98034","98035","98036","98037","98038","98039","98040","98041","98042","98043",
                                        "98050","98051","98052","98053","98054","98055","98056","98057","98058","98059","98061","98062","98063","98064","98065","98068","98070","98071","98072","98073",
                                        "98074","98075","98077","98082","98083","98087","98089","98092","98093","98101","98102","98103","98104","98105","98106","98107","98108","98109","98110","98111"};

        private Action<int, Exception> onException;
        private ConcurrentDictionary<int, CancellableTask> tasks;

        private string sqlConnectionString;
        private string sqlInsertMeterMeasurementSPName;
        private int sqlCommandTimeout;
        private int batchSize;
        private int initialNumberOfTasks;
        private int numberOfMetersPerTask;
        private int numberOfBatchesPerTask;
        private int delay;
        private int numberOfMeters;

        private Stopwatch timer;
        private int numberOfRowsInserted = 0;

        protected ThreadLocal<Random> randomValue;
        private bool running = false;

        /// <summary>Wait Time in milliseconds between executing SqlCommands.</summary>
        /// <returns>Integer</returns>
        public int Delay
        {
            get { return delay; }
            set
            {
                Validate(this.batchSize, this.initialNumberOfTasks, value, this.numberOfMeters);
                delay = value;
            }
        }

        /// <summary>The row count of the sample data batch that every task generates.</summary>
        /// <returns>Integer</returns>
        public int BatchSize
        {
            get { return batchSize; }
            set
            {
                Validate(value, this.initialNumberOfTasks, this.delay, this.numberOfMeters);
                batchSize = value;
            }
        }

        /// <summary>Rows (inserted or updated) per second.</summary>
        /// <returns>Double</returns>
        public double Rps => (double)this.numberOfRowsInserted / this.timer.Elapsed.TotalSeconds;

        /// <summary>The number of current active tasks.</summary>
        /// <returns>Integer</returns>
        public int RunningTasks => this.tasks.Count();

        /// <summary>Running Status</summary>
        /// <returns>Bool</returns>
        public bool IsRunning => this.running;

        /// <summary>Creates a new instance of the SqlDataGenerator Class.</summary>
        /// <param name="sqlConnectionString">The sqlserver connectionString. Example: "Data Source=.;Initial Catalog=DbName;Integrated Security=True"</param>
        /// <param name="sqlInsertSPName">The Insert Meter Measurement sqlserver stored procedure. Example: "InsertMeterMeasurement". Note that the sql stored procedure needs to accept exactly two parameters: @Batch AS (Your User Defined Table Type) and @BatchSize INT</param>        
        /// <param name="sqlCommandTimeout">The sqlserver command timeout. Example: 600</param>
        /// <param name="numberOfMeters">The total number of Meters. Example: 1000</param>
        /// <param name="initialNumberOfTasks">The number of concurrent tasks. Example: 5. Note that every task 1.Creates and opens a new sql connection 2.Creates a batch of BatchSize sample data and 3.Executes the sql stored procedure passed in sqlStoredProcedureName endless times until stopped by the user.</param>
        /// <param name="delayInMilliseconds">Delay in Millisecods betweeen Sql Commands. Example. 100</param>
        /// <param name="batchSize">The row count of the batch size to be used by every task. Example: 200</param>
        /// <param name="batchDataTypes">The pipe seperated column types of the batch table. Example. identity:1:1|string|datetime|double|int|guid</param>
        /// <param name="onException">Exception call back method with TaskId(int) and exception(Exception). Example: ExceptionCallback</param>
        public SqlDataGenerator(
            string sqlConnectionString, 
            string sqlInsertSPName,
            int sqlCommandTimeout, 
            int numberOfMeters,
            int initialNumberOfTasks, 
            int delayInMilliseconds, 
            int batchSize, 
            Action<int, Exception> onException)
        {

            this.sqlConnectionString = sqlConnectionString;
            this.sqlInsertMeterMeasurementSPName = sqlInsertSPName;
            this.sqlCommandTimeout = sqlCommandTimeout;
            this.numberOfMeters = numberOfMeters;
            this.onException = onException;
            this.tasks = new ConcurrentDictionary<int, CancellableTask>();
            this.randomValue = new ThreadLocal<Random>(() => new Random(Guid.NewGuid().GetHashCode()));
            this.initialNumberOfTasks = initialNumberOfTasks;
            this.delay = delayInMilliseconds;
            this.batchSize = batchSize;
            
            Validate(this.batchSize, this.initialNumberOfTasks, this.delay, this.numberOfMeters);

        }

        /// <summary>Creates and Starts all the tasks asynchronously. Note that every task 1.Creates and opens a new sql connection 2.Creates a batch of BatchSize sample data and 3.Executes the sql stored procedure passed in sqlStoredProcedureName endless times until stopped by the user.</summary>
        /// <returns>Task</returns>        
        public async Task RunAsync()
        {
            if (this.running)
            {
                return;
            }
            timer = Stopwatch.StartNew();
            await this.RunAsync(this.initialNumberOfTasks);
        }

        /// <summary>Stops all tasks asynchronously.</summary>
        /// <returns>Task</returns>
        public async Task StopAsync()
        {
            await this.StopAsync(this.RunningTasks);
        }

        /// <summary>Restarts the Rows/Second Counter. This is called internally every time the input is changed.</summary>
        /// <returns>void</returns>
        public void RpsReset()
        {
            if (running)
            {
                this.timer.Restart();
                this.numberOfRowsInserted = 0;
            }
        }

        /// <summary>Updates the number of tasks that the DataGenerator is using.</summary>
        /// <returns>Task</returns>
        /// <remarks></remarks>
        /// <param name="numberOfTasks">The number of Tasks to start/stop depending of the number of tasks currently running.</param>
        public async Task UpdateTasksAsync(int numberOfTasks)
        {
            int diff = numberOfTasks - this.RunningTasks;

            if (!running || diff == 0)
            {
                this.initialNumberOfTasks = numberOfTasks;
                return;
            }

            if (diff < 0)
            {
                await this.StopAsync(-diff);
            }
            else
            {
                await this.RunAsync(diff);
            }
        }

        /// <summary>InsertMeterMeasurementAsync(int taskId, CancellationToken token)</summary>
        /// <returns>Task</returns>
        /// <remarks>Every Task creates a new sql connection, creates a new sqlcommand, create a batch of random numbers, and executes indefinetely until stopped by the user.</remarks>
        /// <param name="taskId">The taskId</param>
        /// <param name="token">The task's CancellationToken</param>
        private async Task InsertMeterMeasurementAsync(int taskId, CancellationToken token)
        {
            int batchId = 0;
            int size = this.BatchSize;
            
            using (SqlConnection connection = new SqlConnection(this.sqlConnectionString))
            {
                await connection.OpenAsync(token);

                using (SqlCommand command = new SqlCommand())
                {                    
                    command.Connection = connection;
                    command.CommandType = CommandType.StoredProcedure;
                    command.CommandTimeout = this.sqlCommandTimeout;
                    command.CommandText = this.sqlInsertMeterMeasurementSPName;
                    command.Parameters.Add("@Batch", SqlDbType.Structured);
                    command.Parameters.Add("@BatchSize", SqlDbType.Int).Value = this.BatchSize;

                    while (!token.IsCancellationRequested)
                    {
                        DataTable dataTable = CreateBatch(taskId, batchId++);                        
                        command.Parameters[0].Value = dataTable;

                        await command.ExecuteNonQueryAsync(token);
                        Interlocked.Add(ref this.numberOfRowsInserted, size);
                        await Task.Delay(this.Delay, token);
                    }
                }
            }
        }

        /// <summary>CreateMeterMeasurementBatch(int taskId)</summary>
        /// <returns>DataTable</returns>
        /// <param name="taskId">Task Id</param>
        private DataTable CreateBatch(int taskId, int batchId)
        {            
            DataTable table = new DataTable();
            table.Columns.Add("RowID", typeof(int));
            table.Columns.Add("MeterID", typeof(int));
            table.Columns.Add("MeasurementInkWh", typeof(double));
            table.Columns.Add("PostalCode", typeof(string));
            table.Columns.Add("MeasurementDate", typeof(DateTime));
            
            batchId = (batchId % this.numberOfBatchesPerTask);
            for (int i = 1; i <= this.batchSize; i++)
            {
                int randomPostalCode = randomValue.Value.Next(0, this.postalCodes.Length);   
                int meterId = taskId * this.numberOfMetersPerTask + batchId * this.BatchSize + i;
                double value = randomValue.Value.NextDouble();
                DateTime date = DateTime.Now;
                string postalCode = this.postalCodes[randomPostalCode].ToString();

                // Data Shock - Produces 10X values
                value = this.Delay == 0 ? value * 10 : value; 

                table.Rows.Add(i, meterId, value, postalCode, date);                
            }
            return table;
        }

        /// <summary>StopAsync(int numberOfTasksToStop)</summary>
        /// <returns>Task</returns>
        /// <param name="numberOfTasksToStop">The number of Tasks to stop.</param>
        private async Task StopAsync(int numberOfTasksToStop)
        {
            // TODO: Lock
            if (numberOfTasksToStop >= this.RunningTasks) { this.running = false; }
            
            numberOfTasksToStop = Math.Min(numberOfTasksToStop, this.RunningTasks);
            List<CancellableTask> cancellableTasksToKill = this.tasks.Take(numberOfTasksToStop).Select(kv => kv.Value).ToList();

            foreach (CancellableTask cancellableTask in cancellableTasksToKill)
            {
                cancellableTask.CancellationTokenSource.Cancel();
            }

            await Task.WhenAll(cancellableTasksToKill.Select(c => c.Task));
        }

        /// <summary>RunAsync(int numberOfTasks)</summary>
        /// <returns>Task</returns>
        /// <param name="numberOfTasks">The number of Tasks to start/stop depending of the number of tasks currently running.</param>
        private async Task RunAsync(int numberOfTasks)
        {            
            for (int i = 0; i < numberOfTasks; i++)
            {
                CancellationTokenSource tokenSource = new CancellationTokenSource();
                int taskId = i;
                Task task = Task.Factory.StartNew(
                    async () => await this.InsertMeterMeasurementAsync(taskId, tokenSource.Token).ContinueWith(t => CleanupTask(taskId, t)),
                    tokenSource.Token,
                    TaskCreationOptions.LongRunning,
                    TaskScheduler.Default).Unwrap();

                tasks.TryAdd(taskId, new CancellableTask(taskId, task, tokenSource));
            }
 
            this.running = true;

            await Task.WhenAll(this.tasks.Values.Select(t => t.Task));
        }

        /// <summary>CleanupTask(int taskId, Task task)</summary>
        /// <returns>void</returns>
        /// <remarks></remarks>
        /// <param name="taskId">The taskId</param>
        /// <param name="task">The actual Task</param>
        private void CleanupTask(int taskId, Task task)
        {
            CancellableTask cancellableTask;
            bool succeeded = this.tasks.TryRemove(taskId, out cancellableTask);

            if (task.IsFaulted && !cancellableTask.CancellationTokenSource.IsCancellationRequested)
            {
                this.onException(taskId, task.Exception?.InnerException);
            }
        }

        /// <summary>Validate(int batchSize, int tasks, int delay)</summary>
        /// <param name="batchSize">The Batch Size</param>
        /// <param name="tasks">The number Of Tasks</param>
        /// <param name="delay">Teh Delay</param>
        private void Validate(int batchSize, int tasks, int delay, int numberOfMeters)
        {
            // Validate
            if (batchSize <= 0)
            {
                throw new SqlDataGeneratorException("The Batch Size cannot be less or equal to zero.");
            }
            if (tasks <= 0)
            {
                throw new SqlDataGeneratorException("Number Of Tasks cannot be less or equal to zero.");
            }
            if (delay < 0)
            {
                throw new SqlDataGeneratorException("Delay cannot be less than zero");
            }
            if (numberOfMeters <= 0)
            {
                throw new SqlDataGeneratorException("Number Of Meters cannot be less than zero");
            }
            if (numberOfMeters < batchSize * tasks)
            {
                throw new SqlDataGeneratorException("Number Of Meters cannot be less than (Tasks * BatchSize).");
            }
            // Reset Rps
            RpsReset();

            // Set Number Of Meters Per Tasks
            this.numberOfMetersPerTask = this.numberOfMeters / this.initialNumberOfTasks;
            this.numberOfBatchesPerTask = this.numberOfMetersPerTask / this.BatchSize;
        }
    }
}
