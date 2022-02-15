using Flex.Data.Enum;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Flex.Data.ViewModel
{
    public class CustomerPolicySummary
    {
        public string PolicyNo { get; set; }

        public decimal Balance { get; set; }

        public Status Status { get; set; }

        public string policyType { get; set; }
    }

    public class CustomerViewModel
    {
        public long Id { get; set; }

        public string Name { get; set; }

        public string Phone { get; set; }

        public string Email { get; set; }

        public int Policies { get; set; }

        public string Username { get; set; }
    }
}
