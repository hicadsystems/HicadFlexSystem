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
    
    public partial class fl_translog
    {
        public long Id { get; set; }
        public string receiptno { get; set; }
        public Nullable<System.DateTime> trandate { get; set; }
        public string bank_ledger { get; set; }
        public string income_ledger { get; set; }
        public string payee { get; set; }
        public Nullable<int> paymentmethod { get; set; }
        public Nullable<decimal> amount { get; set; }
        public string policyno { get; set; }
        public string remark { get; set; }
        public Nullable<int> Instrument { get; set; }
        public Nullable<bool> Isreversed { get; set; }
        public string chequeno { get; set; }
        public string poltype { get; set; }
        public string grpcode { get; set; }
    }
}
