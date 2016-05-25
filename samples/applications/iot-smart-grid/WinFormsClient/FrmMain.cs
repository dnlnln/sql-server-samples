/*----------------------------------------------------------------------------------  
Copyright (c) Microsoft Corporation. All rights reserved.  
  
THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,   
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES   
OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
----------------------------------------------------------------------------------  
The example companies, organizations, products, domain names,  
e-mail addresses, logos, people, places, and events depicted  
herein are fictitious.  No association with any real company,  
organization, product, domain name, email address, logo, person,  
places, or events is intended or should be inferred.  

*/

using DataGenerator;
using System;
using System.Configuration;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;
using System.Windows.Forms.DataVisualization.Charting;

/*----------------------------------------------------------------------------------  
High Level Scenario:
This code sample demonstrates how a SQL Server 2016 (or higher) memory optimized database could be used to ingest a very high input data rate 
and ultimately help improve the performance of applications with this scenario. The code simulates an IoT Smart Grid scenario where multiple 
IoT power meters are constantly sending electricity usage measurements to the database.

Details:
This code sample simulates an IoT Smart Grid scenario where multiple IoT power meters are sending electricity usage measurements to a SQL Server memory optimized database. 
The Data Generator, that can be started either from the Console or the Windows Form client, produces a data generated spike to simulate a 
shock absorber scenario: https://blogs.technet.microsoft.com/dataplatforminsider/2013/09/19/in-memory-oltp-common-design-pattern-high-data-input-rateshock-absorber/. 
Every async task in the Data Generator produces a batch of records with random values in order to simulate the data of an IoT power meter. 
It then calls a natively compiled stored procedure, that accepts an memory optimized table valued parameter (TVP), to insert the data into an memory optimized SQL Server table. 
In addition to the in-memory features, the sample is leveraging System-Versioned Temporal Tables: https://msdn.microsoft.com/en-us/library/dn935015.aspx for building version history, 
Clustered Columnstore Index: https://msdn.microsoft.com/en-us/library/dn817827.aspx) for enabling real time operational analytics, and 
Power BI: https://powerbi.microsoft.com/en-us/desktop/ for data visualization. 
*/
namespace Client
{
    public partial class FrmMain : Form
    {
        private SqlDataGenerator dataGenerator;
        private string connection;
        private string spName;
        private string logFileName;
        private string powerBIDesktopPath;
        private int tasks;
        private int meters;
        private int batchSize;
        private int delay;
        private int commandTimeout;
        private int shockFrequency;
        private int shockDuration;
        private int rpsFrequency;
        private int rpsChartTime = 0;
        private int enableShock;

        public FrmMain()
        {
            InitializeComponent();            
            Init();

            this.dataGenerator = new SqlDataGenerator(this.connection, this.spName, this.commandTimeout, this.meters, this.tasks, this.delay, this.batchSize, this.ExceptionCallback);
        }

        private void ExceptionCallback(int taskId, Exception exception)
        {
            HandleException(exception, taskId);
        }

        private void HandleException(Exception exception, int? taskId = null)
        {
            string ex = taskId?.ToString() + " - " + exception.Message + (exception.InnerException != null ? "\n\nInner Exception\n" + exception.InnerException : "");

            MessageBox.Show(ex, "Invalid Input Parameter", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            using (StreamWriter w = File.AppendText(logFileName)) { w.WriteLine("\r\n{0}: {1}", DateTime.Now, ex); }               
        }

        private async void Start_Click(object sender, EventArgs e)
        {
            try
            {
                if (enableShock == 1) this.mainTimer.Start();
                this.rpsTimer.Start();
                this.Stop.Enabled = true;
                this.Stop.Update();
                this.Start.Enabled = false;
                this.Start.Update();

                await this.dataGenerator.RunAsync();
            }
            catch (Exception exception) { HandleException(exception); }
        }

        private async void Stop_Click(object sender, EventArgs e)
        {
            try
            {                               
                this.UpdateChart(-1);
                if (enableShock == 1) this.mainTimer.Stop();
                this.rpsTimer.Stop();
                if (enableShock == 1) this.shockTimer.Stop();
                this.lblRpsValue.Text = "0";
                this.lblTasksValue.Text = "0";
                this.Stop.Enabled = false;
                this.Stop.Update();
                this.Start.Enabled = true;
                this.Start.Update();
                
                await this.dataGenerator.StopAsync();
                this.dataGenerator.RpsReset();
            }
            catch (Exception exception) { HandleException(exception); }
        }

        private void UpdateChart(double rps)
        {
            if (rps >= 0)
            {
                rpsChartTime++;

                if (rpsChartTime > this.RpsChart.ChartAreas[0].AxisX.Maximum)
                {
                    this.RpsChart.ChartAreas[0].AxisX.Maximum += 100;
                }
                this.RpsChart.Series[0].Points.Add(new DataPoint(rpsChartTime, rps));
            }
            else
            {
                this.RpsChart.Series[0].Points.Clear();
                rpsChartTime = 0;
            }
            this.RpsChart.Update();
        }

        private void Init()
        {
            try
            {
                // Read Config Settings
                this.connection = ConfigurationManager.ConnectionStrings["Db"].ConnectionString;
                this.spName = ConfigurationManager.AppSettings["insertSPName"];
                this.logFileName = ConfigurationManager.AppSettings["logFileName"];
                this.powerBIDesktopPath = ConfigurationManager.AppSettings["powerBIDesktopPath"];
                this.tasks = int.Parse(ConfigurationManager.AppSettings["numberOfTasks"]);
                this.meters = int.Parse(ConfigurationManager.AppSettings["numberOfMeters"]);
                this.batchSize = int.Parse(ConfigurationManager.AppSettings["batchSize"]);
                this.delay = int.Parse(ConfigurationManager.AppSettings["commandDelay"]);
                this.commandTimeout = int.Parse(ConfigurationManager.AppSettings["commandTimeout"]);
                this.shockFrequency = int.Parse(ConfigurationManager.AppSettings["shockFrequency"]);
                this.shockDuration = int.Parse(ConfigurationManager.AppSettings["shockDuration"]);
                this.enableShock = int.Parse(ConfigurationManager.AppSettings["enableShock"]);

                this.rpsFrequency = int.Parse(ConfigurationManager.AppSettings["rpsFrequency"]);

                // Initialize Timers
                this.mainTimer.Interval = shockFrequency;
                this.shockTimer.Interval = shockDuration;         
                this.rpsTimer.Interval = this.rpsFrequency;

                // Initialize Labels
                this.lblTasksValue.Text = string.Format("{0:#,#}", this.tasks).ToString();
                this.lblFrequencyValue.Text = (this.shockFrequency/1000).ToString() + "/" + (this.shockDuration / 1000).ToString();
                this.lblBatchSizeValue.Text = string.Format("{0:#,#}", this.batchSize).ToString();
                this.lblMetersValue.Text = string.Format("{0:#,#}", this.meters).ToString();

                if (batchSize <= 0) throw new SqlDataGeneratorException("The Batch Size cannot be less or equal to zero.");

                if (tasks <= 0) throw new SqlDataGeneratorException("Number Of Tasks cannot be less or equal to zero.");

                if (delay < 0) throw new SqlDataGeneratorException("Delay cannot be less than zero");

                if (meters <= 0) throw new SqlDataGeneratorException("Number Of Meters cannot be less than zero");

                if (meters < batchSize * tasks) throw new SqlDataGeneratorException("Number Of Meters cannot be less than (Tasks * BatchSize).");
            }
            catch (Exception exception) { HandleException(exception); }
        }

        private void rpsTimer_Tick(object sender, EventArgs e)
        {
            try
            {
                this.lblTasksValue.Text = this.dataGenerator.RunningTasks.ToString();

                double rps = this.dataGenerator.Rps;
                if (dataGenerator.IsRunning)
                {
                    if (this.dataGenerator.RunningTasks == 0) return;
                
                    if (rps > 0)
                    {
                        this.lblRpsValue.Text = string.Format("{0:#,#}", rps).ToString();
                        UpdateChart(rps);
                    }

                }
            }
            catch (Exception exception) { HandleException(exception); }
        }

        private void mainTimer_Tick(object sender, EventArgs e)
        {
            if (this.dataGenerator.IsRunning)
            {
                this.dataGenerator.Delay = 0;
                this.shockTimer.Start();
            }
        }

        private void shockTimer_Tick(object sender, EventArgs e)
        {
            Random rand = new Random();
            this.dataGenerator.Delay = rand.Next(1500,3000);
            this.shockTimer.Stop();
        }

        private void powerBIReport_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {            
            ProcessStartInfo psi = new ProcessStartInfo();
            psi.FileName = this.powerBIDesktopPath;
            psi.Arguments = @"Reports\PowerDashboard.pbix";
            Process.Start(psi);
        }
    }
}
