
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------


namespace Flex.Data.Model
{

using System;
    using System.Collections.Generic;
    
public partial class CustomerUser
{

    public CustomerUser()
    {

        this.CustomerPolicies = new HashSet<CustomerPolicy>();

        this.UserSessions = new HashSet<UserSession>();

    }


    public long Id { get; set; }

    public string username { get; set; }

    public string password { get; set; }

    public string Name { get; set; }

    public Nullable<long> createdby { get; set; }

    public Nullable<System.DateTime> datecreated { get; set; }

    public Nullable<System.DateTime> passworddate { get; set; }

    public Nullable<System.DateTime> modifydate { get; set; }

    public Nullable<long> modifyby { get; set; }

    public Nullable<System.DateTime> lastLoginDate { get; set; }

    public Nullable<System.DateTime> firstLoginDate { get; set; }

    public Nullable<Flex.Data.Enum.UserStatus> status { get; set; }

    public string email { get; set; }

    public string phone { get; set; }

    public Nullable<bool> IsDeleted { get; set; }



    public virtual ICollection<CustomerPolicy> CustomerPolicies { get; set; }

    public virtual ICollection<UserSession> UserSessions { get; set; }

}

}
