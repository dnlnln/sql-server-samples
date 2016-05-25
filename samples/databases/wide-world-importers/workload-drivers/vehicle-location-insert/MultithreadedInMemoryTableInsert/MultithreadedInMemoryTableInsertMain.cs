using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace MultithreadedInMemoryTableInsert
{
    public partial class MultithreadedInMemoryTableInsertMain : Form
    {
        public bool errorHasOccurred;
        public string errorDetails;

        public MultithreadedInMemoryTableInsertMain()
        {
            InitializeComponent();
        }

        private void MultithreadedInMemoryTableInsertMain_Load(object sender, EventArgs e)
        {
            ConnectionStringTextBox.Text = Properties.Settings.Default.WWI_ConnectionString;
            if (ConnectionStringTextBox.Text.Length == 0)
            {
                ConnectionStringTextBox.Text = "Server=.;Database=WideWorldImporters;Integrated Security=true;Column Encryption Setting=disabled;Max Pool Size=250;";
            }
        }

        private void MultithreadedInMemoryTableInsertMain_FormClosing(object sender, FormClosingEventArgs e)
        {
            Properties.Settings.Default.WWI_ConnectionString = ConnectionStringTextBox.Text;
            Properties.Settings.Default.Save();
        }

        private void InsertButton_Click(object sender, EventArgs e)
        {
            InsertButton.Text = "Running";
            InsertButton.Refresh();

            this.errorHasOccurred = false;
            this.errorDetails = "";

            if (ConnectionStringTextBox.Text.Length == 0)
            {
                ConnectionStringTextBox.Text = "Server=.;Database=WideWorldImporters;Integrated Security=true;Column Encryption Setting=disabled;Max Pool Size=250;";
            }

            if (!ConnectionStringTextBox.Text.ToUpper().Contains("MAX POOL SIZE"))
            {
                ConnectionStringTextBox.Text = (ConnectionStringTextBox.Text + ";Max Pool Size=250;").Replace(";;", ";");
            }

            var startingTime = DateTime.Now;

            try
            {
                int numberOfThreads = (int)NumberOfThreadsNumericUpDown.Value;

                var sqlTasks = new Thread[numberOfThreads];

                for (int threadCounter = 0; threadCounter < numberOfThreads; threadCounter++)
                {
                    sqlTasks[threadCounter] = new System.Threading.Thread(() => PerformSqlTask(threadCounter, this));
                    sqlTasks[threadCounter].Start();
                }

                if (sqlTasks != null)
                {
                    foreach (Thread thread in sqlTasks)
                    {
                        thread.Join();
                    }
                }
            }
            catch (Exception ex)
            {
                this.errorHasOccurred = true;
                this.errorDetails = ex.ToString();
            }

            InsertButton.Text = "&Insert";
            LastExecutionTimeTextBox.Text = ((int)DateTime.Now.Subtract(startingTime).TotalMilliseconds).ToString();

            if (this.errorHasOccurred)
            {
                var errorForm = new ErrorDetailsForm();
                errorForm.ErrorMessage = this.errorDetails;
                errorForm.ShowDialog();
            }
        }

        public void PerformSqlTask(int TaskNumber, MultithreadedInMemoryTableInsertMain ParentForm)
        {
            try
            {
                using (var con = new SqlConnection(ConnectionStringTextBox.Text))
                {
                    con.Open();

                    using (var cmd = con.CreateCommand())
                    {
                        if (OnDiskRadioButton.Checked)
                        {
                            cmd.CommandText = "EXEC OnDisk.InsertVehicleLocation @RegistrationNumber, @TrackedWhen, @Longitude, @Latitude;";
                        }
                        else
                        {
                            cmd.CommandText = "EXEC InMemory.InsertVehicleLocation @RegistrationNumber, @TrackedWhen, @Longitude, @Latitude;";
                        }
                        cmd.Parameters.Add(new SqlParameter("@RegistrationNumber", SqlDbType.NVarChar, 20));
                        cmd.Parameters.Add(new SqlParameter("@TrackedWhen", SqlDbType.DateTime2));
                        var p = new SqlParameter("@Longitude", SqlDbType.Decimal);
                        p.Precision = 18;
                        p.Scale = 4;
                        cmd.Parameters.Add(p);
                        p = new SqlParameter("@Latitude", SqlDbType.Decimal);
                        p.Precision = 18;
                        p.Scale = 4;
                        cmd.Parameters.Add(p);

                        var rnd = new Random();

                        var tran = con.BeginTransaction();
                        cmd.Transaction = tran;

                        for (int counter = 0; counter < NumberOfRowsPerThreadNumericUpDown.Value; counter++)
                        {
                            cmd.Parameters["@RegistrationNumber"].Value = "EA24-GL";
                            cmd.Parameters["@TrackedWhen"].Value = DateTime.Now;
                            cmd.Parameters["@Longitude"].Value = rnd.Next(100);
                            cmd.Parameters["@Latitude"].Value = rnd.Next(100);
                            cmd.ExecuteNonQuery();
                        }

                        tran.Commit();
                    }
                    con.Close();
                }
            }
            catch (Exception ex)
            {
                ParentForm.errorHasOccurred = true;
                ParentForm.errorDetails = ex.ToString();
            }
        }

    }
}

