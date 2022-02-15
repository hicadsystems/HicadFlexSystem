using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Flex.Data.ViewModel
{
    public class PendingPolicy
    {
        public string Regno { get; set; }

        public string Surname { get; set; }

        public string Othernames { get; set; }

        public string Address { get; set; }

        public string Email { get; set; }

        public string Phone { get; set; }

        public string PolicyType { get; set; }

        public string ContribFreq { get; set; }

        public decimal Amount { get; set; }

        public DateTime ApprovedDate { get; set; }
    }
}
