using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CustomerPortal.Models
{
    public class VerifyPaymentModel
    {
        public string publicKey { get; set; }
        public string transactionId { get; set; }
        public string mode { get; set; }
    }

    //public class VerifyDataResponse
    //{
    //    public string amount { get; set; }
    //    public string currency { get; set; }
    //    public string status { get; set; }
    //    public string paymentType { get; set; }
    //    public string gatewayResponse { get; set; }
    //    public string transactionId { get; set; }
    //}
    //public class HistoriesResponse
    //{
    //    public string type { get; set; }
    //    public string message { get; set; }
    //    public string status { get; set; }
    //    public string date { get; set; }
    //    public string time { get; set; }
    //}
    //public class VerifyPaymentResponse
    //{
    //    public bool success { get; set; }
    //    public string message { get; set; }
    //    public VerifyDataResponse data { get; set; }
    //    public HistoriesResponse histories { get; set; }
    //}
    // Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(myJsonResponse);
    // Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(myJsonResponse);
    public class Data
    {
        public string amount { get; set; }
        public string paymentType { get; set; }
        public string currency { get; set; }
        public string status { get; set; }
        public bool isSuccessful { get; set; }
        public string gatewayResponse { get; set; }
        public string transactionId { get; set; }
        public string paymentDate { get; set; }
        public string paymentReference { get; set; }
        public int merchantId { get; set; }
    }

    public class Histories
    {
        public string type { get; set; }
        public string message { get; set; }
       // public List<Value> values { get; set; }
    }

    public class VerifyPaymentResponse
    {
        public string responseCode { get; set; }
        public string responseMessage { get; set; }
        public Data data { get; set; }
        public List<Histories> histories { get; set; }
    }

    public class Value
    {
        public string id { get; set; }
        public string type { get; set; }
        public string message { get; set; }
    }




}