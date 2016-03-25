# SQL Server In-memory

In-Memory OLTP can significantly improve OLTP database application performance. It is a memory-optimized database engine integrated into the SQL Server engine, optimized for OLTP. With In-Memory OLTP you can increase the transaction throughput by up to 30 times, depending on the specifics of the workload. The performance gains come from:
  - For memory-optimized tables, the design of their structure is free of the physical limitations of hard drives that force design compromises.
  - Core transaction processing is completely free of locks.
  - Natively compiled modules execute Transact-SQL statements more efficiently.

Read the following resources for mroe information.
- [In-Memory OLTP (In-Memory Optimization)] (https://msdn.microsoft.com/en-us/library/dn133186.aspx)
- [Quick Start 1: In-Memory OLTP Technologies for Faster Transact-SQL Performance] (https://msdn.microsoft.com/en-us/library/mt694156.aspx)
- [Get started with Columnstore for real time operational analytics] (https://msdn.microsoft.com/en-us/library/dn817827.aspx)
- [Columnstore Indexes Guide] (https://msdn.microsoft.com/en-us/library/gg492088.aspx)
