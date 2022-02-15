using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text;

namespace Flex.Data.Model
{
    public partial class UserSession:  IPrincipal, IIdentity
    {
        public virtual IIdentity Identity
        {
            get { return this; }
        }

        public virtual bool IsInRole(string role)
        {
            try
            {
                return true;
                //return this.fl_password.UserRoles.ToList()[0].RoleId == int.Parse(role);
            }
            catch { return false; }
        }

        public virtual string AuthenticationType
        {
            get { return "Basic authentication"; }
        }

        public virtual bool IsAuthenticated
        {
            get { return true; }
        }

        public virtual string Name
        {
            //get { return CorporateUser.UserName; }
            get { return fl_password.Name; }
        }


    }
}
