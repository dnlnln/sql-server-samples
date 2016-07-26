This folder "Optional Migrations" contains a number of additional migrations and/or programmable objects that provide additional features for this database:

1. Data Population (Runtime 5-10 minutes): Contains a migration that seeds transactional tables with data

2. Data Simulation (Runtime 15-20 minutes): Contains a migration that simulates changes to the data within transactional tables over a period
   NOTE: In order to run this script, the Data Population script must first be executed.

3. Enterprise Features (Runtime < 1 minute): Contains a migration plus a set of programmable objects that make use of a number of Enterprise-edition
   only features, such as full-text indexing and in-memory tables.

In order to use the above scripts, you can simply execute them manually (e.g. within the Visual Studio query editor) or move the contents of the desired 
feature folder to the root of the project. For example, if you would like to deploy the Enterprise features, move the "Migrations" and "Programmable Objects"
folders within "Enterprise Features" to the root of the project.
