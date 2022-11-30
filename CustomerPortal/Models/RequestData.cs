using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CustomerPortal.Models
{
    public class RequestData
    {
        public string policyno { get; set; }
        public int PolicyType { get; set; }
        public string Name { get; set; }
        public string telephone { get; set; }
        public string email { get; set; }
        public string amount { get; set; }
        public string transactionId { get; set; }
        public string currency { get; set; }
        public string publicKey { get; set; }
        public string mode { get; set; }
        public string callbackUrl { get; set; }
        public string productId { get; set; }
        public bool applyConviniencyCharge { get; set; }
        public string productDescription { get; set; }
        public string bodyColor { get; set; }
        public string buttonColor { get; set; }
        public string footerText { get; set; }
        public string footerLink { get; set; }
        public string footerLogo { get; set; }
        public string xpressurl { get; set; }
        public List<Metadata> metadata { get; set; }


    }

    public class Metadata
    {
        public string name { get; set; } = "Sample";
        public string value { get; set; } = "Test";
    }

    public class Root
    {
        public string amount { get; set; }
        public string transactionId { get; set; }
        public string email { get; set; }
        public string publicKey { get; set; }
        public string currency { get; set; }
        public string mode { get; set; }
        public string callbackUrl { get; set; }
        public string productId { get; set; }
        public bool applyConviniencyCharge { get; set; }
        public string productDescription { get; set; }
        public string bodyColor { get; set; }
        public string buttonColor { get; set; }
        public string footerText { get; set; }
        public string footerLink { get; set; }
        public string footerLogo { get; set; }
        public List<Metadata> metadata { get; set; }
    }

    public class DataResponse
    {
        public string Id { get; set; }
        public string paymentUrl { get; set; }
        public string accessCode { get; set; }
    }

    public class RootResponse
    {
        public string Id { get; set; }
        public string responseCode { get; set; }
        public string responseMessage { get; set; }
        public DataResponse data { get; set; }
    }

  

}