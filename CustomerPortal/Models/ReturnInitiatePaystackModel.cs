using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CustomerPortal.Models
{
    public class ReturnInitiatePaystackModel
    {
            public bool status { get; set; }
            public string message { get; set; }
            public PaystackReturnData data { get; set; }
    }
    public class PaystackReturnData
    {
        public string authorization_url { get; set; }
        public string access_code { get; set; }
        public string reference { get; set; }
    }
    public class Paymentrequest
    {
        public string lastname { get; set; }
        public string firstname { get; set; }
        public string PolicyType { get; set; }
        public string amount { get; set; }
        public string email { get; set; }
    }

}