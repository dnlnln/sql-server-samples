# SQL Server Code Samples
This GitHub repository contains code samples that demonstrate how to use SQL Server features. Each sample includes a README file that explains how to run and use the sample.


## Sample Categories
**In-memory**
  - Ticket Reservations: Windows Forms sample application built on .NET Framework 4.6 that demonstrates the performance benefits of using SQL Server memory optimized tables and native compiled stored procedures. You can compare the performance before and after enabling In-Memory OLTP by observing the transactions/sec as well as the current CPU Usage and latches/sec.

**Master Data Services**
  - Samples coming soon

**R Services**
  - Samples coming soon


## Adding Samples
To add a sample create a subdirectory under ./samples. Start the sample name with the SQL Server feature you are showcasing. Use all lower case and separate the words with hyphens (e.g., in-memory-ticket-reservations).

Include a README.txt file at the root of the sample that explains how to run the sample. Use the README_samples_template.txt as your template.


## Working in GitHub
To work in GitHub, go to https://github.com/microsoft/sql-server-samples and fork the repository. Work in your own fork and when you are ready to submit to make a change or publish your sample for the first time, submit a pull request into the master branch of sql-server-samples. One of the approvers will review your request and accept or reject the pull request. 


## License
These samples and templates are all licensed under the MIT license. See the license.txt file in the root.


## Questions
Email questions to: sqlserversamples@micrososft.com.
