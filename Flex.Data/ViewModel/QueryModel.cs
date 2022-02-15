using Flex.Data.Enum;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Flex.Data.ViewModel
{
    public class QueryModel
    {
        public bool IsReport { get; set; }

        public string ReportFormat { get; set; }
    }

    public class paymentQueryModel : QueryModel
    {
        public string DateFrom { get; set; }

        public string DateTo { get; set; }

        public string policyno { get; set; }

        public string Location { get; set; }

        public string ReceiptNo { get; set; }

        public string PaymentMethod { get; set; }

        public string Instrument { get; set; }

        public string PolicyType { get; set; }

        public string GroupCode { get; set; }
        public PageQueryModel  Page { get; set; }
    }

    public class PageQueryModel
    {
        public string Page { get; set; }

        public string Size { get; set; }
    }

    public class AgentQueryModel : QueryModel
    {
        public string Name { get; set; }

        public string Type { get; set; }

        public string Location { get; set; }

        public PageQueryModel Page { get; set; }
    }

    public class RateQueryModel : QueryModel
    {
        public string Period { get; set; }

        public string PolicyType { get; set; }

        public string Group { get; set; }
    }

    public class PolicyQueryModel : QueryModel
    {
        public string PolicyNo { get; set; }

        public string Name { get; set; }

        public string Phone { get; set; }

        public string Agent { get; set; }

        public string Location { get; set; }

        public PageQueryModel Page { get; set; }

    }

    public class SearchModel : QueryModel
    {
        public string SearchTerm { get; set; }

        public PageQueryModel Page { get; set; }
    }

    public class StatementModel : QueryModel
    {
        public string PolicyNo { get; set; }

        public string Month { get; set; }

        public string Year { get; set; }

        public string DateFrom { get; set; }

        public string DateTo { get; set; }

        public PageQueryModel Page { get; set; }

    }

    public class ProposalQueryModel : QueryModel
    {
        public string DateFrom { get; set; }

        public string DateTo { get; set; }
    }
}
