//==============================================================================
//
//    Copyright (c) Microsoft. All rights reserved.
//    This code is licensed under the Microsoft Public License.
//    THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
//    ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
//    IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
//    PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
//
//==============================================================================

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ModelDUtil
{
    /// <summary>
    /// The various "modes" of the utility console app. The app will run in
    /// exactly one of these modes each execution.
    /// </summary>
    public enum Modes
    {
        /// <summary>
        /// Used to export a model to a package file.
        /// </summary>
        CreatePackage,

        /// <summary>
        /// Used to deploy a clone of a model in a package.
        /// </summary>
        DeployClone,

        /// <summary>
        /// Used to deploy a copy of a model in a package, under a new name.
        /// </summary>
        DeployNew,

        /// <summary>
        /// Used to update an existing model from a package.
        /// </summary>
        DeployUpdate,

        /// <summary>
        /// Used to list all the models in the system.
        /// </summary>
        ListModels,

        /// <summary>
        /// Used to list all the versions for a selected model.
        /// </summary>
        ListVersions,

        /// <summary>
        /// Used to display the usage instructions.
        /// </summary>
        Help
    }
}
