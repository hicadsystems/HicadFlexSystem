using CustomerPortal.Models;
using CustomerPortal.Util;
using Flex.Business;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using Flex.Utility.Utils;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using static CustomerPortal.Models.PaystackModel;

namespace CustomerPortal.Controllers
{
    public class XpressPayController : BaseController
    {
        private int resetcode;
        Random rnd = new Random();
        // GET: XpressPay
        public ActionResult Index()
        {
            try
            {
                GetPolicyType();

                var user = WebSecurity.GetCurrentUser(Request);

                var pols = user.CustomerUser.CustomerPolicies.Select(x => x.Policyno);

                var details = new CoreSystem<vwPolicy>(context).FindAll(x => pols.Contains(x.policyno)).ToList();

                return PartialView("_xpressPay", details);

            }
            catch (Exception ex)
            {

                return RedirectToAction("Index", "Login");
            }
        }
        [AllowAnonymous]
        [HttpPost]
        public async Task<ActionResult> InitializePayment(RequestData model)
        {
            var user = WebSecurity.GetCurrentUser(Request);
            //string po=user.CustomerUser.username;
            try
            {
                string updatetype = "initiate";
                string Url = ConfigurationManager.AppSettings["xpressUrl"];

                string AppKey = ConfigurationManager.AppSettings["xpressKey"];

                model.callbackUrl = ConfigurationManager.AppSettings["xCallbackUrl"];
                model.footerText = ConfigurationManager.AppSettings["xfooterText"];
                model.footerLink = ConfigurationManager.AppSettings["xfooterLink"];
                model.footerLogo = ConfigurationManager.AppSettings["xfooterlogo"];


                resetcode = rnd.Next(100000, 200000);
                model.transactionId=resetcode.ToString();
                model.publicKey = AppKey;
                model.currency="NGN";
                model.mode="Debug";
                model.productId=model.PolicyType.ToString();
                model.applyConviniencyCharge=true;
                model.productDescription = model.policyno;
                model.bodyColor="#0000";
                model.buttonColor="#0000";
                model.callbackUrl = model.callbackUrl + "?transactionId=" + model.transactionId;
               

                var Response = new RootResponse();
                HttpClient httpClient = new HttpClient();


                var httpRequestMessage = new HttpRequestMessage(HttpMethod.Post, Url);
                string serializedRequest = JsonConvert.SerializeObject(model);

                httpRequestMessage.Content = new StringContent(serializedRequest, Encoding.UTF8, "application/json");


                httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {AppKey}");

                //log your request going to xpress payment
                //Logger.ErrorFormat("Payment Request. Details [error: {0}, StackTrace: {1}]", model);

                JsonResult resp = null;
                var response = await httpClient.SendAsync(httpRequestMessage);
                if (response.IsSuccessStatusCode)
                {
                    var responseStream = await response.Content.ReadAsStringAsync();
                    Response = JsonConvert.DeserializeObject<RootResponse>(responseStream);


                    var result = new XpayUpdateModel
                    {
                        paymentDate = DateTime.Now,
                        transactionId = model.transactionId,
                        amount = model.amount,
                        paymentReference = model.transactionId,
                        paymentType = "",
                        gatewayResponse = responseStream,
                        status = Response.responseCode,
                        isSuccessful = true,
                        policyno = model.policyno,
                        poltype = model.PolicyType.ToString(),
                        initiate = updatetype,
                    };
                    new PaymentSystem(context).XpaymentUpdate(result);

                    resp = new JsonResult()
                    {
                        Data = Response
                    };

                    //return resp;
                    //log success response from xpress payment
                   // ViewBag.xurl = Response.data.paymentUrl;
                    return Json(Response.data.paymentUrl, JsonRequestBehavior.AllowGet);
                    //return Response.data.paymentUrl;
                }
                else
                {
                    var failedResponseStream = await response.Content.ReadAsStringAsync();
                    var errorResponse = JsonConvert.DeserializeObject<RootResponse>(failedResponseStream);
                    //log the failed response stream
                   // Logger.ErrorFormat("Payment Error Occurred. Details [error: {0}, StackTrace: {1}]", failedResponseStream);
                    //  return errorResponse;
                    resp = new JsonResult()
                    {
                        Data = errorResponse,

                    };
                    return resp;
                }
            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Payment Error Occurred. Details [error: {0}, StackTrace: {1}]", ex.ToString(), ex.StackTrace);

            }
            return View();
        }
        public async Task<ActionResult> verifyAndPostTran(string transactionId)
        {
            try { 
            var user = WebSecurity.GetCurrentUser(Request);
                string policynos = user.CustomerUser.username;
               // string poltypes = user.CustomerUser.CustomerPolicies;
                string updatetype = "final";
                string ApiKey = ConfigurationManager.AppSettings["xpressKey"];
            string Url = ConfigurationManager.AppSettings["xpressVerifyUrl"];

            var verifyreq = new VerifyPaymentModel();
            verifyreq.transactionId = transactionId;
            verifyreq.publicKey= ApiKey;
            verifyreq.publicKey = "Debug";
           

                var Response = new VerifyPaymentResponse();
                var HistResponse = new List<Histories>();
                HttpClient httpClient = new HttpClient();


            var httpRequestMessage = new HttpRequestMessage(HttpMethod.Post, Url);
            string serializedRequest = JsonConvert.SerializeObject(verifyreq);

            httpRequestMessage.Content = new StringContent(serializedRequest, Encoding.UTF8, "application/json");


            httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {ApiKey}");

            //log your request going to xpress payment

            JsonResult resp = null;
            var response = await httpClient.SendAsync(httpRequestMessage);
            if (response.IsSuccessStatusCode)
            {
                var responseStream = await response.Content.ReadAsStringAsync();
                Response = JsonConvert.DeserializeObject<VerifyPaymentResponse>(responseStream);

                    //var objResponse1 = JsonConvert.DeserializeObject<List<Histories>>(responseStream);
                    var result = new XpayUpdateModel
                    {
                        paymentDate =Convert.ToDateTime(Response.data.paymentDate),
                        transactionId = Response.data.transactionId,
                        amount = Response.data.amount,
                        paymentReference = Response.data.paymentReference,
                        paymentType = Response.data.paymentType,
                        gatewayResponse = Response.data.gatewayResponse,
                        status = Response.data.status,
                        isSuccessful = Response.data.isSuccessful,
                        policyno = policynos,
                        poltype = "",
                        initiate = updatetype,
                    };
                    new PaymentSystem(context).XpaymentUpdate(result);
                    return RedirectToAction("Index", "DashBoard");
                    //return new JsonResult()
                    //{
                    //    Data = "Payment Successfully"
                    //};
                }
            else
            {
                var failedResponseStream = await response.Content.ReadAsStringAsync();
                Logger.ErrorFormat("Payment Error Occurred. Details [error: {0}, StackTrace: {1}]", failedResponseStream);
                //  return errorResponse;
                resp = new JsonResult()
                {
                    Data = "Fail",

                };
                return RedirectToAction("Index","DashBoard");
            }
        }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Payment Error Occurred. Details [error: {0}, StackTrace: {1}]", ex.ToString(), ex.StackTrace);

            }
            return RedirectToAction("Index", "DashBoard");
        }

        [HttpPost]
        public async Task<ActionResult> initiatepaystack(Paymentrequest model)
        {
            try
            {
                string updatetype = "initiate";
                string Url = ConfigurationManager.AppSettings["paystackUrl"];

                string AppKey = ConfigurationManager.AppSettings["paystackKey"];

                var Response = new ReturnInitiatePaystackModel();
                HttpClient httpClient = new HttpClient();

                model.amount = model.amount + "00";
                var httpRequestMessage = new HttpRequestMessage(HttpMethod.Post, Url);
                string serializedRequest = JsonConvert.SerializeObject(model);

                httpRequestMessage.Content = new StringContent(serializedRequest, Encoding.UTF8, "application/json");


                httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {AppKey}");

                ServicePointManager.Expect100Continue = true;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls
                       | SecurityProtocolType.Tls11
                       | SecurityProtocolType.Tls12
                       | SecurityProtocolType.Ssl3;

                JsonResult resp = null;
                var response = await httpClient.SendAsync(httpRequestMessage);
                if (response.IsSuccessStatusCode)
                {
                    var responseStream = await response.Content.ReadAsStringAsync();
                    Response = JsonConvert.DeserializeObject<ReturnInitiatePaystackModel>(responseStream);


                    var result = new XpayUpdateModel
                    {
                        paymentDate = DateTime.Now,
                        transactionId = "",
                        amount = model.amount,
                        paymentReference = "",
                        paymentType = "",
                        gatewayResponse = responseStream,
                        status = "",
                        isSuccessful = true,
                        policyno = "",
                        poltype = "",
                        initiate = updatetype,
                    };
                    new PaymentSystem(context).XpaymentUpdate(result);

                    resp = new JsonResult()
                    {
                        Data = Response
                    };
                    Session["refno"] = Response.data.reference;
                    //return resp;
                    //log success response from xpress payment
                    // ViewBag.xurl = Response.data.paymentUrl;
                    return Json(Response.data.authorization_url, JsonRequestBehavior.AllowGet);
                    //return Response.data.paymentUrl;
                }
                else
                {
                    var failedResponseStream = await response.Content.ReadAsStringAsync();
                    var errorResponse = JsonConvert.DeserializeObject<ReturnInitiatePaystackModel>(failedResponseStream);
                    resp = new JsonResult()
                    {
                        Data = errorResponse,

                    };
                    return resp;
                }
            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Payment Error Occurred. Details [error: {0}, StackTrace: {1}]", ex.ToString(), ex.StackTrace);

            }
            return View();

        }
        public async Task<ActionResult> verifyPaystackAndPostTran()
        {
            string transactionId = Session["refno"].ToString();
            try
            {
                var user = WebSecurity.GetCurrentUser(Request);
                string policynos = user.CustomerUser.username;
                // string poltypes = user.CustomerUser.CustomerPolicies;
                string updatetype = "final";
                string Url = ConfigurationManager.AppSettings["paystackVerifyurl"] +transactionId;

                string ApiKey = ConfigurationManager.AppSettings["paystackKey"];

                var Response = new paydatapaystack();
                var HistResponse = new List<Histories>();
                HttpClient httpClient = new HttpClient();


                var httpRequestMessage = new HttpRequestMessage(HttpMethod.Get, Url);
               // string serializedRequest = JsonConvert.SerializeObject(verifyreq);

               // httpRequestMessage.Content = new StringContent(serializedRequest, Encoding.UTF8, "application/json");


                httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {ApiKey}");

                //log your request going to xpress payment
                ServicePointManager.Expect100Continue = true;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls
                       | SecurityProtocolType.Tls11
                       | SecurityProtocolType.Tls12
                       | SecurityProtocolType.Ssl3;

                JsonResult resp = null;
                var response = await httpClient.SendAsync(httpRequestMessage);
                if (response.IsSuccessStatusCode)
                {
                    var responseStream = await response.Content.ReadAsStringAsync();
                    Response = JsonConvert.DeserializeObject<paydatapaystack>(responseStream);

                    //var objResponse1 = JsonConvert.DeserializeObject<List<Histories>>(responseStream);
                    var result = new XpayUpdateModel
                    {
                        paymentDate = Convert.ToDateTime(Response.data.transaction_date),
                        transactionId = Response.data.reference,
                        amount = Response.data.amount.ToString(),
                        paymentReference = Response.data.reference,
                        paymentType = Response.data.reference,
                        gatewayResponse = Response.data.status,
                        status = Response.data.status,
                        isSuccessful = true,
                        policyno = policynos,
                        poltype = "",
                        initiate = updatetype,
                    };
                    new PaymentSystem(context).XpaymentUpdate(result);
                    return RedirectToAction("Index", "DashBoard");
                    //return new JsonResult()
                    //{
                    //    Data = "Payment Successfully"
                    //};
                }
                else
                {
                    var failedResponseStream = await response.Content.ReadAsStringAsync();
                    Logger.ErrorFormat("Payment Error Occurred. Details [error: {0}, StackTrace: {1}]", failedResponseStream);
                    //  return errorResponse;
                    resp = new JsonResult()
                    {
                        Data = "Fail",

                    };
                    return RedirectToAction("Index", "DashBoard");
                }
            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Payment Error Occurred. Details [error: {0}, StackTrace: {1}]", ex.ToString(), ex.StackTrace);

            }
            return RedirectToAction("Index", "DashBoard");
        }


        public ActionResult Xpressspay()
        {

            var user = WebSecurity.GetCurrentUser(Request);
            var pols = user.CustomerUser.CustomerPolicies.ToList();
            ViewBag.Policy = new SelectList(pols, "Policyno", "Policyno");

            return PartialView("_xpresssPay");

        }
    }
}