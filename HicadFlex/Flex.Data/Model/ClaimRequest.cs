
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
    
public partial class ClaimRequest
{

    public long Id { get; set; }

    public string ClaimNo { get; set; }

    public string PolicyNo { get; set; }

    public Nullable<decimal> Amount { get; set; }

    public Nullable<Flex.Data.Enum.ClaimType> ClaimType { get; set; }

    public Nullable<Flex.Data.Enum.ClaimStatus> Status { get; set; }

    public Nullable<System.DateTime> DateCreated { get; set; }

    public Nullable<System.DateTime> EffectiveDate { get; set; }

    public Nullable<decimal> Interest { get; set; }

    public Nullable<decimal> ApprovedAmount { get; set; }

    public Nullable<decimal> FundAmount { get; set; }

}

}
