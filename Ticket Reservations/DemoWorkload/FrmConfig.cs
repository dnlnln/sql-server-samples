using System;
using System.Configuration;
using System.Windows.Forms;

namespace DemoWorkload
{
    public partial class FrmConfig : Form
    {

        public FrmConfig()
        {
            InitializeComponent();
        }

        private void ConfigForm_Load(object sender, EventArgs e)
        {
            tbConnectionString.Text = Program.CONN_STR;
            TransactionCount.Value = Program.TRANSACTION_COUNT;
            ThreadCount.Value = Program.THREAD_COUNT;
            ReadsPerWrite.Value = Program.READS_PER_WRITE;
            RequestCount.Value = Program.REQUEST_COUNT;
            RowCount.Value = Program.ROW_COUNT;
            txtMaxLatch.Text = Program.MAX_LATCH_WAIT.ToString();
            txtMaxTPS.Text = Program.MAX_TPS.ToString();
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            Program.THREAD_COUNT = (int)this.ThreadCount.Value;
            Program.READS_PER_WRITE = (int)this.ReadsPerWrite.Value;
            Program.REQUEST_COUNT = (int)this.RequestCount.Value;
            Program.ROW_COUNT = (int)this.RowCount.Value;
            Program.TRANSACTION_COUNT = (int)this.TransactionCount.Value;
            Program.CONN_STR = this.tbConnectionString.Text;
            Program.MAX_TPS = Convert.ToInt32(this.txtMaxTPS.Text);
            Program.MAX_LATCH_WAIT = Convert.ToInt32(this.txtMaxLatch.Text);

            // also persist changes in app config
            Configuration config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            KeyValueConfigurationCollection settings = config.AppSettings.Settings;
            ConnectionStringSettingsCollection connStrs = config.ConnectionStrings.ConnectionStrings;

            // update SaveBeforeExit
            settings["ThreadCount"].Value = Program.THREAD_COUNT.ToString();
            settings["ReadsPerWrite"].Value = Program.READS_PER_WRITE.ToString();
            settings["RequestCount"].Value = Program.REQUEST_COUNT.ToString();
            settings["RowCount"].Value = Program.ROW_COUNT.ToString();
            settings["TransactionCount"].Value = Program.TRANSACTION_COUNT.ToString();
            settings["MaxTps"].Value = Program.MAX_TPS.ToString();
            settings["MaxLatchWaits"].Value = Program.MAX_LATCH_WAIT.ToString();
            connStrs["TicketReservations"].ConnectionString = Program.CONN_STR;

            //save the file
            config.Save(ConfigurationSaveMode.Modified);

        }

        private void tbInstance_TextChanged(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {

        }
    }
}
