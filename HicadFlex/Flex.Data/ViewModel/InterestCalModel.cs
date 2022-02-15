using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Flex.Data.ViewModel
{
    public class InterestCalModel
    {
        public string PolicyNo { get; set; }

        public string ReceiptNo { get; set; }

        public Decimal Amount { get; set; }

        public Decimal Interest { get; set; }

        public string TransDate { get; set; }
    }
}
