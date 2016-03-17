using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Windows.Forms;
using System.Data.SqlClient;
using System.Threading;
using System.Diagnostics;
using System.Windows.Forms.DataVisualization.Charting;
using System.Windows.Forms.Integration;


namespace DemoWorkload
{
    public partial class Form1 : Form
    {
        public Object ErrorLock = new Object();

        public Object StopLock = new Object();
        Boolean Stopped = true;

        Int64 BaselineTPS = 1;
        delegate void SetTextCallback(string text);

        List<Thread> RunningThreads = new List<Thread>();
        Thread MonitorThread;


        int Height_2Panels = 0;
        int Height_1Panel = 0;
        int TPSChartTime = 0;

        private UIControls uiControls = new UIControls();

        public Form1()
        {
            InitializeComponent();

        }

        
        delegate void SetInt64Callback(Int64 value);
        delegate void SetIntCallback(int value);

        //Adds a line of text into the message box
        private void AddText(string text)
        {
            // InvokeRequired required compares the thread ID of the
            // calling thread to the thread ID of the creating thread.
            // If these threads are different, it returns true.
            if (this.ErrorMessages.InvokeRequired)
            {
                SetTextCallback d = new SetTextCallback(AddText);
                this.Invoke(d, new object[] { text });
            }
            else
            {
                this.ErrorMessages.AppendText("\r\n" + text);
            }

        }

        //Updates the thread count display
        private void UpdateCount(string TC)
        {
            this.lblThreads.Text = TC.ToString();
        }

        //Updates the elapsed time display
        private void UpdateElapsed(string Elapsed)
        {
            this.lblTime.Text = Elapsed.ToString();
        }

        // Updates the CPU% bar in the chart 
        // Note that this proc does NOT cause the chart to refresh.
        // that is done in UpdateTPS(), which should be called after this proc.
        private void UpdateCPUChart(int CPU)
        {
            if (this.statusStrip1.InvokeRequired)
            {
                SetIntCallback d = new SetIntCallback(UpdateCPUChart);
                this.Invoke(d, new object[] { CPU });
            }
            else
            {
                CPU = (CPU == 0) ? 1 : CPU;
                this.chtCPU.Series["CPUUsage"].Points.Clear();
                this.chtCPU.Series["CPUUsage"].Points.Add(new DataPoint(0, CPU));
                this.chtCPU.Update();
            }
        }

        private void UpdateLatchChart(Int64 Latches)
        {
            if (this.statusStrip1.InvokeRequired)
            {
                SetInt64Callback d = new SetInt64Callback(UpdateLatchChart);
                this.Invoke(d, new object[] { Latches });
            }
            else
            {
                Latches = (Latches == 0) ? 1 : Latches;
                this.chtLatches.Series["Latches"].Points.Clear();
                this.chtLatches.Series["Latches"].Points.Add(new DataPoint(0, Latches));
                this.chtLatches.Update();
            }
        }

        // Updates the TPS bar in the chart, and causes the whole chart to be re-drawn with the new data.
        private void UpdateTPSChart(Int64 TPS)
        {
            if (this.statusStrip1.InvokeRequired)
            {
                SetInt64Callback d = new SetInt64Callback(UpdateTPSChart);
                this.Invoke(d, new object[] { TPS });
            }
            else
            {
                // Updating Speedometer

                if (TPS >= 0)
                {
                    double normalizedTPS = TPS / 100;
                    normalizedTPS = (normalizedTPS == 0) ? 1 : normalizedTPS;
                    normalizedTPS = (normalizedTPS > 100) ? 100 : normalizedTPS;
                  
                    uiControls.speedDial.CurrentValue = normalizedTPS;
                    uiControls.speedDial.DialText = normalizedTPS.ToString();                    

                    // Updating TPS chart
                    TPSChartTime++;

                    // X Axis Overflow
                    if (TPSChartTime > this.chtTPS.ChartAreas[0].AxisX.Maximum)
                    {
                        this.chtTPS.ChartAreas[0].AxisX.Maximum += 100;
                    }

                    // Y Axis Overflow
                    //if (TPS > this.chtTPS.ChartAreas[0].AxisY.Maximum)
                    //{
                    //    this.chtTPS.ChartAreas[0].AxisY.Maximum *= 2;
                    //}

                    this.chtTPS.Series[0].Points.Add(new System.Windows.Forms.DataVisualization.Charting.DataPoint(TPSChartTime, TPS));
                }
                else
                {
                    this.chtTPS.Series[0].Points.Clear();
                    TPSChartTime = 0;
                }
                this.chtTPS.Update();
            }

        }

        private void UpdateResults(string Results)
        {
            lock (StopLock)
            {
                if (Stopped)
                {
                    return;
                }
            }
            if (this.statusStrip1.InvokeRequired)
            {
                SetTextCallback d = new SetTextCallback(UpdateResults);
                this.Invoke(d, new object[] { Results });
            }
            else
            {
                this.lbResults.Text = Results;
                this.lbResults.Refresh();
            }
        }

        void OnRunClick(object sender, EventArgs e)
        {
            string ReadCommand;
            string WriteCommand;
            lock (StopLock)
            {
                Stopped = false;
            }

            WriteCommand = "EXEC BatchInsertReservations @ServerTransactions, @RowsPerTransaction, @ThreadID";
            ReadCommand = "EXEC ReadMultipleReservations @ServerTransactions, @RowsPerTransaction, @ThreadID";
            this.ErrorMessages.Clear();

            ThreadParams tp = new ThreadParams(Program.REQUEST_COUNT, Program.TRANSACTION_COUNT, Program.ROW_COUNT,
                Program.READS_PER_WRITE, ReadCommand, WriteCommand);
            for (int j = 0; j < Program.THREAD_COUNT; j++)
            {
                int Threads = RunningThreads.Count();
                // Create a thread with parameters.
                ParameterizedThreadStart pts = new ParameterizedThreadStart(ThreadWorker);
                RunningThreads.Add(new Thread(pts));
                RunningThreads.ElementAt(Threads).Start(tp);
            }
            ThreadStart ts1 = new ThreadStart(ThreadMonitor);
            this.MonitorThread = new Thread(ts1);
            this.MonitorThread.Start();
        }

        void ThreadWorker(object tp)
        {
            ////////////////////////////////////////////////////////////////////////////////
            // Connect to the data source.
            ////////////////////////////////////////////////////////////////////////////////

            System.Data.SqlClient.SqlConnection conn = new SqlConnection(Program.CONN_STR);

            ThreadParams MyTP = (ThreadParams)tp;
            SqlCommand WriteCmd = new SqlCommand();
            WriteCmd.Connection = conn;
            WriteCmd.CommandTimeout = 600;
            WriteCmd.CommandText = MyTP.WriteCommandText;
            WriteCmd.Parameters.Add("@ServerTransactions", SqlDbType.Int, 4).Value = (int)MyTP.serverTransactions;
            WriteCmd.Parameters.Add("@RowsPerTransaction", SqlDbType.Int, 4).Value = (int)MyTP.rowsPerTransaction;
            WriteCmd.Parameters.Add("@ThreadID", SqlDbType.Int, 4).Value = (int)Thread.CurrentThread.ManagedThreadId;

            SqlCommand ReadCmd = new SqlCommand();
            ReadCmd.Connection = conn;
            ReadCmd.CommandTimeout = 600;
            ReadCmd.CommandText = MyTP.ReadCommandText;
            ReadCmd.Parameters.Add("@ServerTransactions", SqlDbType.Int, 4).Value = (int)MyTP.serverTransactions;
            ReadCmd.Parameters.Add("@RowsPerTransaction", SqlDbType.Int, 4).Value = (int)MyTP.rowsPerTransaction;
            ReadCmd.Parameters.Add("@ThreadID", SqlDbType.Int, 4).Value = (int)Thread.CurrentThread.ManagedThreadId;

            // Executing transactions on the target server
            try
            {
                conn.Open();
                for (int i = 0; i < MyTP.requestsPerThread; i++)
                {
                    lock (StopLock)
                    {
                        if (Stopped)
                        {
                            break;
                        }
                    }
                    WriteCmd.ExecuteNonQuery();
                    for (int j = 0; j < MyTP.readsPerWrite && !Stopped; j++)
                    {
                        ReadCmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                lock (this.ErrorLock)
                {
                    this.AddText(ex.Message + " " + Thread.CurrentThread.ManagedThreadId.ToString());
                }
            }
            finally
            {
                conn.Close();
            }
        }

        void ThreadMonitor()
        {
            //Set-up & initialization
            DateTime Start = DateTime.Now;
            DateTime PerfCounterStart = DateTime.Now, PerfCounterEnd;
            Int64 LastPerfCounterValue = 0, ThisPerfCounterValue = 0, TPS = 0;
            Int64 LatchCounterValue = 0, LastLatchCounter = 0, ThisLatchCounter = 0;
            int CPU_Usage = 0;
            int mo_tables = 0;
            PerformanceCounter CPUCounter = new PerformanceCounter("Processor", "% Processor Time", "_Total");
            Int64 TotalTPS = 0, TotalIterations = 0;

            // Open the connection
            System.Data.SqlClient.SqlConnection conn = new SqlConnection(Program.CONN_STR);

            string cmdStr = string.Format("select max(cntr_value) FROM sys.dm_os_performance_counters WHERE counter_name = 'Transactions/sec'");

            string LatchcmdStr = string.Format("select max(cntr_value) FROM sys.dm_os_performance_counters WHERE counter_name = 'Latch Waits/sec'");
            SqlCommand Perfcmd = new SqlCommand();
            Perfcmd.Connection = conn;
            Perfcmd.CommandTimeout = 600;
            Perfcmd.CommandText = cmdStr;

            //query to determine which stage we're in
            SqlCommand Latchcmd = new SqlCommand();
            Latchcmd.Connection = conn;
            Latchcmd.CommandTimeout = 600;
            Latchcmd.CommandText = LatchcmdStr;
            string ConfigSelect = string.Format("select count(*) from sys.tables where is_memory_optimized = 1 and object_id=object_id('dbo.TicketReservationDetail')");

            SqlCommand ConfigQuery = new SqlCommand();
            ConfigQuery.Connection = conn;
            ConfigQuery.CommandTimeout = 600;
            ConfigQuery.CommandText = ConfigSelect;

            try
            {
                conn.Open();
            }
            catch (Exception ex)
            {
                lock (this.ErrorLock)
                {
                    this.AddText(ex.Message + " " + Thread.CurrentThread.ManagedThreadId.ToString());
                }
            }

            if (conn.State != ConnectionState.Open)
            {
                MessageBox.Show("Monitor failed to connect to server.", "Error", MessageBoxButtons.OK);
                return;
            }

            mo_tables = (int)ConfigQuery.ExecuteScalar();
            if (mo_tables == 0)
            {
                //This is the case where there are no Memory Optimized tables, so we're running in pure SQL mode.
                UpdateResults("Baseline");
                //Calling UpdateTPSChart with a negative value causes it to clear the current chart and reset.
                UpdateTPSChart(-1);
            }
            else
            {
                UpdateResults("");
            }

            while (RunningThreads.Count > 0)
            {
                List<Thread> DeadThreads = new List<Thread>();
                foreach (Thread MyThread in RunningThreads)
                {
                    if (!MyThread.IsAlive)
                    {
                        DeadThreads.Add(MyThread);
                    }
                }
                foreach (Thread DThread in DeadThreads)
                {
                    RunningThreads.Remove(DThread);
                }
                DeadThreads.Clear();
                PerfCounterEnd = DateTime.Now;

                try
                {
                    ThisPerfCounterValue = (Int64)Perfcmd.ExecuteScalar();
                    ThisLatchCounter = (Int64)Latchcmd.ExecuteScalar();
                }
                catch (Exception ex)
                {
                    lock (this.ErrorLock)
                    {
                        this.AddText(ex.Message + " " + Thread.CurrentThread.ManagedThreadId.ToString());
                    }
                }

                if (LastLatchCounter == 0)
                {
                    LastLatchCounter = ThisLatchCounter;
                }

                if (LastPerfCounterValue != 0)
                {
                    CPU_Usage = (int)CPUCounter.NextValue();
                    //TmpTPS = (Int64)TPSCounter.NextValue();
                    //LatchCounterValue = (Int64)LatchCounter.NextValue();

                    TimeSpan PerfCounterInterval = PerfCounterEnd - PerfCounterStart;
                    if (PerfCounterInterval.Milliseconds > 0)
                    {
                        TPS = (Int64)((ThisPerfCounterValue - LastPerfCounterValue) / (float)(PerfCounterInterval.Seconds + (PerfCounterInterval.Milliseconds / 1000)));
                        LatchCounterValue = (Int64)((ThisLatchCounter - LastLatchCounter) / (float)(PerfCounterInterval.Seconds + (PerfCounterInterval.Milliseconds / 1000)));
                        UpdateCPUChart(CPU_Usage);
                        UpdateLatchChart(LatchCounterValue);
                        UpdateTPSChart(TPS);
                    }
                    if (mo_tables == 0)
                    {
                        TotalTPS += TPS;
                        TotalIterations += 1;
                        BaselineTPS = TotalTPS / TotalIterations;
                    }
                    else
                    {
                        string UpdateString = string.Format("{0}X", TPS / BaselineTPS);
                        UpdateResults(UpdateString);
                    }
                }

                PerfCounterStart = PerfCounterEnd;
                LastPerfCounterValue = ThisPerfCounterValue;
                LastLatchCounter = ThisLatchCounter;
                PerfCounterStart = PerfCounterEnd;
                this.UpdateCount(RunningThreads.Count.ToString());
                Thread.Sleep(1000);
                TimeSpan Elapsed = DateTime.Now - Start;
                UpdateElapsed(Elapsed.ToString(@"hh\:mm\:ss"));
            }

            TPS = 0;
            CPU_Usage = 0;
            LatchCounterValue = 0;
            UpdateLatchChart(LatchCounterValue);
            UpdateCPUChart(CPU_Usage);
            UpdateTPSChart(TPS);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            lock (StopLock)
            {
                Stopped = true;
            }
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void configurationToolStripMenuItem_Click(object sender, EventArgs e)
        {
            ConfigForm cf = new ConfigForm();
            cf.ShowDialog();
            uiControls.speedDial.MaxValue = Program.MAX_TPS;
        }

        private void button1_Click_1(object sender, EventArgs e)
        {
            splitContainer1.Panel2Collapsed = !splitContainer1.Panel2Collapsed;
            if (splitContainer1.Panel2Collapsed)
            {
                this.Height = this.Height_1Panel;
                btnToggle.Text = "Show diagnostics";
            }
            else
            {
                this.Height = this.Height_2Panels;
                btnToggle.Text = "Hide diagnostics";
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            
            ElementHost host = new ElementHost();

            host.Dock = DockStyle.Fill;
            host.Child = uiControls.speedDial;
            speedDialPanel.Controls.Add(host);

            this.Height_1Panel = splitContainer1.Panel1.Height + 100;
            this.Height_2Panels = this.Height;
            splitContainer1.Panel2Collapsed = true;
            this.Height = Height_1Panel;
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            lock (StopLock)
            {
                Stopped = true;
            }
            Thread.Sleep(1000);
            if (MonitorThread != null && MonitorThread.ThreadState == System.Threading.ThreadState.Running)
            {
                MonitorThread.Abort();
            }
        }

    }

    class ThreadParams
    {
        public int requestsPerThread;  // how many many separate client requests per thread
        public int serverTransactions; // how many separate transactions to run on the server per request
        public int rowsPerTransaction; // how many rows to inserts/read per transaction
        public int readsPerWrite;      // number of read requests per write request
        public string ReadCommandText; // command text for read request
        public string WriteCommandText; // command text for insert request

        public ThreadParams(int requestsPerThread, int serverTransactions, int rowsPerTransaction, int readsPerWrite,
            string ReadCommandText, string WriteCommandText)
        {
            this.requestsPerThread = requestsPerThread;
            this.serverTransactions = serverTransactions;
            this.rowsPerTransaction = rowsPerTransaction;
            this.readsPerWrite = readsPerWrite;
            this.ReadCommandText = ReadCommandText;
            this.WriteCommandText = WriteCommandText;
        }

    }

}
