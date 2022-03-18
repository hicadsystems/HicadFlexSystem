using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flex.Data.ViewModel
{
    public class StatementViewModel
    {
        public string workstation { get; set; }

        public string policyno { get; set; }

        public string receiptno { get; set; }

        public string period { get; set; }

        public string grpcode { get; set; }

        public string pcn { get; set; }

        public string poltype { get; set; }

        public Nullable<System.DateTime> orig_date { get; set; }

        public Nullable<System.DateTime> trandate { get; set; }

        public Nullable<decimal> amount { get; set; }

        public Nullable<float> gir { get; set; }

        public Nullable<decimal> cur_intr { get; set; }

        public Nullable<decimal> cumul_intr { get; set; }

        public Nullable<decimal> loanamt { get; set; }

        public string doctype { get; set; }

        public Nullable<decimal> openbalance { get; set; }

        public Nullable<decimal> opendeposit { get; set; }

        public Nullable<decimal> deposit { get; set; }

        public Nullable<decimal> curdep_intr { get; set; }

        public Nullable<decimal> cumuldep_intr { get; set; }

    }
}
