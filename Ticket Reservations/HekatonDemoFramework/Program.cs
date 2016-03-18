using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using System.Data;
using System.Data.Sql;
using System.Data.SqlTypes;
using System.Configuration;

namespace DemoWorkload
{
    static class Program
    {

        public static int THREAD_COUNT = int.Parse(ConfigurationManager.AppSettings["ThreadCount"]);
        public static int READS_PER_WRITE = int.Parse(ConfigurationManager.AppSettings["ReadsPerWrite"]);
        public static int REQUEST_COUNT = int.Parse(ConfigurationManager.AppSettings["RequestCount"]);
        public static int ROW_COUNT = int.Parse(ConfigurationManager.AppSettings["RowCount"]);
        public static int TRANSACTION_COUNT = int.Parse(ConfigurationManager.AppSettings["TransactionCount"]);
        public static long MAX_TPS = int.Parse(ConfigurationManager.AppSettings["MaxTps"]);
        public static long MAX_LATCH_WAIT = int.Parse(ConfigurationManager.AppSettings["MaxLatchWaits"]);
        public static string CONN_STR = ConfigurationManager.ConnectionStrings["TicketReservations"].ConnectionString;


        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new Form1());
        }
    }
}
