using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CustomerPortal.Models
{
    public class PaystackModel
    {
        // Root myDeserializedClass = JsonConvert.DeserializeObject<Root>(myJsonResponse);
        public class Authorization
        {
            public string authorization_code { get; set; }
            public string bin { get; set; }
            public string last4 { get; set; }
            public string exp_month { get; set; }
            public string exp_year { get; set; }
            public string channel { get; set; }
            public string card_type { get; set; }
            public string bank { get; set; }
            public string country_code { get; set; }
            public string brand { get; set; }
            public bool reusable { get; set; }
            public string signature { get; set; }
            public string account_name { get; set; }
        }
        public class Customer
        {
            public int id { get; set; }
            public object first_name { get; set; }
            public object last_name { get; set; }
            public string email { get; set; }
            public string customer_code { get; set; }
            public object phone { get; set; }
            public object metadata { get; set; }
            public string risk_action { get; set; }
            public object international_format_phone { get; set; }
        }

        public class paystackData
        {
            public long id { get; set; }
            public string domain { get; set; }
            public string status { get; set; }
            public string reference { get; set; }
            public int amount { get; set; }
            public object message { get; set; }
            public string gateway_response { get; set; }
            public object paid_at { get; set; }
            public DateTime created_at { get; set; }
            public string channel { get; set; }
            public string currency { get; set; }
            public string ip_address { get; set; }
            public string metadata { get; set; }
            public object log { get; set; }
            public object fees { get; set; }
            public object fees_split { get; set; }
            public Authorization authorization { get; set; }
            public Customer customer { get; set; }
            public object plan { get; set; }
            public Split split { get; set; }
            public object order_id { get; set; }
            public object paidAt { get; set; }
            public DateTime createdAt { get; set; }
            public int requested_amount { get; set; }
            public object pos_transaction_data { get; set; }
            public object source { get; set; }
            public object fees_breakdown { get; set; }
            public DateTime transaction_date { get; set; }
            public PlanObject plan_object { get; set; }
            public Subaccount subaccount { get; set; }
        }

        public class PlanObject
        {
        }

        public class paydatapaystack
        {
            public bool status { get; set; }
            public string message { get; set; }
            public paystackData data { get; set; }
        }
        public class Split
        {
        }

        public class Subaccount
        {
        }

    }
}