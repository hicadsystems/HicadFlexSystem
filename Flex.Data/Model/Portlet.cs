
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
    
public partial class Portlet
{

    public Portlet()
    {

        this.Tabs = new HashSet<Tab>();

    }


    public int Id { get; set; }

    public string Name { get; set; }

    public string ImageUrl { get; set; }

    public string Background { get; set; }

    public Nullable<int> Order { get; set; }



    public virtual ICollection<Tab> Tabs { get; set; }

}

}
