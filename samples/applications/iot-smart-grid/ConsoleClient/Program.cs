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

using System;
using System.IO;
using DataGenerator;
using System.Configuration;
using System.Timers;
using System.Diagnostics;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
namespace ConsoleClient
{
    class Program
    {
        static SqlDataGenerator dataGenerator;
        static string connection;
        static string spName;
        static string logFileName;
        static string powerBIDesktopPath;
        static int tasks;
        static int meters;
        static int batchSize;
        static int delay;
        static int commandTimeout;
        static int shockFrequency;
        static int shockDuration;
        static int rpsFrequency;
        static int enableShock;
        static Timer mainTimer = new Timer();
        static Timer rpsTimer = new Timer();
        static Timer shockTimer = new Timer();

        static void Main(string[] args)
        {
            Init();
            dataGenerator = new SqlDataGenerator(connection, spName, commandTimeout, meters, tasks, delay, batchSize, ExceptionCallback);

            mainTimer.Elapsed += mainTimer_Tick;
            rpsTimer.Elapsed += rpsTimer_Tick;
            shockTimer.Elapsed += shockTimer_Tick;

            string commandString = string.Empty;
            Console.ForegroundColor = ConsoleColor.White;
            Console.WriteLine("***********************************************************");
            Console.WriteLine("*                   Data Generator                        *");
            Console.WriteLine("*                                                         *");
            Console.WriteLine("*             Type commands to get started                *");
            Console.WriteLine("*                                                         *");
            Console.WriteLine("***********************************************************");
            Console.WriteLine("");

            // main command cycle
            while (!commandString.Equals("Exit"))
            {
                Console.ResetColor();
                Console.WriteLine("Enter command (start | stop | help | report | exit) >");
                commandString = Console.ReadLine();

                switch (commandString.ToUpper())
                {
                    case "START":
                        Start();
                        break;
                    case "STOP":
                        Stop();
                        break;
                    case "HELP":
                        Help();
                        break;
                    case "REPORT":
                        Report();
                        break;
                    case "EXIT":
                        Console.WriteLine("Bye!");
                        return;
                    default:
                        Console.ForegroundColor = ConsoleColor.Red;
                        Console.WriteLine("Invalid command.");
                        break;
                }
            }
        }
        static void ExceptionCallback(int taskId, Exception exception)
        {
            HandleException(exception, taskId);
        }
        static void HandleException(Exception exception, int? taskId = null)
        {
            string ex = taskId?.ToString() + " - " + exception.Message + (exception.InnerException != null ? "\n\nInner Exception\n" + exception.InnerException : "");

            Console.WriteLine(ex);
            using (StreamWriter w = File.AppendText(logFileName)) { w.WriteLine("\r\n{0}: {1}", DateTime.Now, ex); }
        }
        static async void Start()
        {
            try
            {
                if (!dataGenerator.IsRunning)
                {
                    if(enableShock == 1) mainTimer.Start();
                    rpsTimer.Start();

                    await dataGenerator.RunAsync();
                }
            }
            catch (Exception exception) { HandleException(exception); }
        }

        static async void Stop()
        {
            try
            {
                if (dataGenerator.IsRunning)
                {
                    if (enableShock == 1) mainTimer.Stop();
                    rpsTimer.Stop();
                    if (enableShock == 1) shockTimer.Stop();

                    await dataGenerator.StopAsync();
                    dataGenerator.RpsReset();
                }
            }
            catch (Exception exception) { HandleException(exception); }
        }

        static void Report()
        {
            ProcessStartInfo psi = new ProcessStartInfo();
            psi.FileName = powerBIDesktopPath;
            psi.Arguments = @"Reports\PowerDashboard.pbix";
            Process.Start(psi);
        }
        static void Help()
        {
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("");
            Console.WriteLine("START    - Starts the DataGenerator");
            Console.WriteLine("STOP     - Stops the DataGenerator");
            Console.WriteLine("HELP     - Displays this page");
            Console.WriteLine("REPORT   - Launches the Power BI Report");
            Console.WriteLine("EXIT     - Closes this program");
            Console.WriteLine("");
        }
        static void Init()
        {
            try
            {
                // Read Config Settings
                connection = ConfigurationManager.ConnectionStrings["Db"].ConnectionString;
                spName = ConfigurationManager.AppSettings["insertSPName"];
                logFileName = ConfigurationManager.AppSettings["logFileName"];
                powerBIDesktopPath = ConfigurationManager.AppSettings["powerBIDesktopPath"];
                tasks = int.Parse(ConfigurationManager.AppSettings["numberOfTasks"]);
                meters = int.Parse(ConfigurationManager.AppSettings["numberOfMeters"]);
                batchSize = int.Parse(ConfigurationManager.AppSettings["batchSize"]);
                delay = int.Parse(ConfigurationManager.AppSettings["commandDelay"]);
                commandTimeout = int.Parse(ConfigurationManager.AppSettings["commandTimeout"]);
                shockFrequency = int.Parse(ConfigurationManager.AppSettings["shockFrequency"]);
                shockDuration = int.Parse(ConfigurationManager.AppSettings["shockDuration"]);
                enableShock = int.Parse(ConfigurationManager.AppSettings["enableShock"]);

                rpsFrequency = int.Parse(ConfigurationManager.AppSettings["rpsFrequency"]);

                // Initialize Timers
                mainTimer.Interval = shockFrequency;
                shockTimer.Interval = shockDuration;
                rpsTimer.Interval = rpsFrequency;
                
                if (batchSize <= 0) throw new SqlDataGeneratorException("The Batch Size cannot be less or equal to zero.");

                if (tasks <= 0) throw new SqlDataGeneratorException("Number Of Tasks cannot be less or equal to zero.");

                if (delay < 0) throw new SqlDataGeneratorException("Delay cannot be less than zero");

                if (meters <= 0) throw new SqlDataGeneratorException("Number Of Meters cannot be less than zero");

                if (meters < batchSize * tasks) throw new SqlDataGeneratorException("Number Of Meters cannot be less than (Tasks * BatchSize).");
            }
            catch (Exception exception) { HandleException(exception); }
        }
        static void mainTimer_Tick(object sender, ElapsedEventArgs e)
        {
            if (dataGenerator.IsRunning)
            {
                dataGenerator.Delay = 0;
                shockTimer.Start();
            }
        }
        static void rpsTimer_Tick(object sender, ElapsedEventArgs e)
        {
            try
            {                
                double rps = dataGenerator.Rps;
                if (dataGenerator.IsRunning)
                {
                    if (dataGenerator.RunningTasks == 0) return;

                    if (rps > 0)
                    {
                        Console.SetCursorPosition(0, Console.CursorTop);
                        Console.Write(string.Format("Rows Per Second (RPS):{0:#,#}   ", rps).ToString());
                    }
                }
            }
            catch (Exception exception) { HandleException(exception); }
        }
        static void shockTimer_Tick(object sender, ElapsedEventArgs e)
        {
            Random rand = new Random();
            dataGenerator.Delay = rand.Next(1500, 3000);
            shockTimer.Stop();
        }
    }
}
