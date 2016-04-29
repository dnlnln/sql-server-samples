# Master Data Services Security Model Deployment API Sample

This is a simple console application that demonstrates usage of a few of the common methods in the Model Deployment API.

Building the Visual Studio 2013 Solution

This sample has the following external dependencies:

Microsoft.MasterDataServices.Deployment.dll

Microsoft.MasterDataServices.Services.contracts.dll

In order to build the solution, adjust the project references to point to these binaries in your Microsoft SQL Server Master Data Services deployment.

Configuring the sample project

Update the ConnectionString in ModelDUtil.config to point to your deployed database. Do not to change the name of the connection -- that should be left as "defaultMdsConnection".

ModelDUtil.config must be co-located with ModelDUtil.exe.

Using the sample executable

The following is the built-in help output, which describes the capabilities:

Usage:

    ModelDUtil [mode] [params]

where [mode] is one of the following:

ListModels -- returns a list of all the user models in the target system

    ModelDUtil ListModels

ListVersions -- returns a list of the versions for a given model

    ModelDUtil ListVersions [model name]

CreatePackage -- create a package file for a given model

    ModelDUtil CreatePackage [output package file name] [model name] [version name]

DeployClone -- deploys a clone of a model from a given package

    ModelDUtil DeployClone [input package file name]

DeployNew -- deploys a model from a given package with the new given name

    ModelDUtil DeployNew [input package file name] [new model name]

DeployUpdate -- deploys an update to a given version of a model from a given package

    ModelDUtil DeployUpdate [input package file name] [version name to update]

Help -- displays this help

    ModelDUtil Help

Note: names that contain spaces should be wrapped with double quotation marks. For Example: ModelDUtil DeployUpdate mypackage.pkg "Version 1"