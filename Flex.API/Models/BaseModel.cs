using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Flex.API.Models
{
    public class BaseModel
    {
        public string PolicyNo { get; set; }

        public string Hash { get; set; }
    }

    public class BaseResponse : BaseModel
    {
        public string ResponseCode { get; set; }
    }

    public class PolicyDetails: BaseResponse
    {
        public string Surname { get; set; }

        public string OtherName { get; set; }

        public string PolicyType { get; set; }

        public string Status { get; set; }

        public decimal Balance { get; set; }

    }


    public class PaymentHistoryQuery: BaseModel
    {
        public string DateFrom { get; set; }

        public string DateTo { get; set; }

        public int Page { get; set; }

        public int PageSize { get; set; }

        public bool IsPaged { get; set; }
    }

    public class PaymentHistoryResponse: BaseResponse
    {
        public string Name { get; set; }

        public List<PaymentDetails> History { get; set; }
    }

    public class PaymentDetails
    {
        public string TransReference { get; set; }

        public DateTime TransDate { get; set; }

        public Decimal Amount { get; set; }

        public Decimal interest { get; set; }
    }

    public class PaymentRequestModel : BaseModel
    {
        public string TransactionRef { get; set; }

        public decimal Amount { get; set; }

        public int PaymentMethod { get; set; }
    }

    public class PaymentResponseModel : BaseResponse
    {
        public string TransactionRef { get; set; }

        public decimal Amount { get; set; }
    }

    public class InsurancePolicyDetails : BaseResponse
    {
        public string Name { get; set; }

        public string Scheme { get; set; }

        public decimal Premium { get; set; }

        public DateTime ExpiryDate { get; set; }

        public DateTime RenewalDate { get; set; }
    }

    public class AgentValidationModel
    {
        public string AgentCode { get; set; }

        public string Phone { get; set; }

        public string Hash { get; set; }
    }

    public class AgentValidationResponse : AgentValidationModel
    {
        public string Name { get; set; }

        public string ResponseCode { get; set; }
    }
}