
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
    
public partial class fl_location
{

    public fl_location()
    {

        this.fl_policyinput = new HashSet<fl_policyinput>();

    }


    public int Id { get; set; }

    public string locdesc { get; set; }

    public string locstate { get; set; }

    public string loccode { get; set; }

    public Nullable<System.DateTime> datecreated { get; set; }

    public string createdby { get; set; }

    public Nullable<System.DateTime> datemodified { get; set; }

    public string modifiedby { get; set; }

    public Nullable<bool> Isdeleted { get; set; }



    public virtual ICollection<fl_policyinput> fl_policyinput { get; set; }

}

}
