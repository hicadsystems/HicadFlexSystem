
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
    
public partial class LinkRole
{

    public int Id { get; set; }

    public Nullable<int> LinkId { get; set; }

    public Nullable<int> RoleID { get; set; }

    public Flex.Data.Enum.LinkType Type { get; set; }

    public Nullable<int> Parent { get; set; }



    public virtual Role Role { get; set; }

}

}
