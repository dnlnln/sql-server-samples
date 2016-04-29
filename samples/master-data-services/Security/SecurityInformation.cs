//==============================================================================
//
//    © Microsoft corp. All rights reserved.
//    This code is licensed under the Microsoft Public License.
//    THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
//    ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
//    IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
//    PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
//
//==============================================================================
using Security.MDSTestService; // For the created service reference.

namespace Security
{
    // This is the class to store the security information
    public class SecurityInformation
    {
        System.Collections.ObjectModel.Collection<User> users;
        System.Collections.ObjectModel.Collection<Group> groups;

        public System.Collections.ObjectModel.Collection<User> Users
        {
            get
            {
                return users;
            }
            set
            {
                users = value;
            }
        }

        public System.Collections.ObjectModel.Collection<Group> Groups
        {
            get
            {
                return groups;
            }
            set
            {
                groups = value;
            }
        }
    }
}
