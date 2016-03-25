# SQL Server Code Samples
This GitHub repository contains code samples that demonstrate how to use SQL Server features. Each sample includes a README file that explains how to run and use the sample.


## Sample Categories
**In-memory**

In-Memory OLTP can significantly improve OLTP database application performance. It is a memory-optimized database engine integrated into the SQL Server engine, optimized for OLTP. With In-Memory OLTP you can increase the transaction throughput by up to 30 times, depending on the specifics of the workload. The performance gains come from:
  - For memory-optimized tables, the design of their structure is free of the physical limitations of hard drives that force design compromises.
  - Core transaction processing is completely free of locks.
  - Natively compiled modules execute Transact-SQL statements more efficiently.

Read the following resources for mroe information.
- [In-Memory OLTP (In-Memory Optimization)] (https://msdn.microsoft.com/en-us/library/dn133186.aspx)
- [Quick Start 1: In-Memory OLTP Technologies for Faster Transact-SQL Performance] (https://msdn.microsoft.com/en-us/library/mt694156.aspx)
- [Get started with Columnstore for real time operational analytics] (https://msdn.microsoft.com/en-us/library/dn817827.aspx)
- [Columnstore Indexes Guide] (https://msdn.microsoft.com/en-us/library/gg492088.aspx)

**Master Data Services**
  - Samples coming soon

**R Services**
  - Samples coming soon


## Adding Samples
To add a sample create a subdirectory under ./samples. Start the sample name with the SQL Server feature you are showcasing. Use all lower case and separate the words with hyphens (e.g., in-memory-ticket-reservations).

Include a README.md file at the root of the sample that explains how to run the sample. Use the README_samples_template.md as your template.


## Working in GitHub
To work in GitHub, go to https://github.com/microsoft/sql-server-samples and fork the repository. Work in your own fork and when you are ready to submit to make a change or publish your sample for the first time, submit a pull request into the master branch of sql-server-samples. One of the approvers will review your request and accept or reject the pull request. 


## License
These samples and templates are all licensed under the MIT license. See the license.txt file in the root.


## Questions
Email questions to: sqlserversamples@micrososft.com.
