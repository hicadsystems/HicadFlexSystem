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
    
    public partial class CustomerPolicy
    {
        public long Id { get; set; }
        public Nullable<long> CustomerUserId { get; set; }
        public string Policyno { get; set; }
    
        public virtual CustomerUser CustomerUser { get; set; }
    }
}
