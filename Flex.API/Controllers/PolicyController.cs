using Flex.API.Models;
using Flex.API.Utils;
using Flex.Business;
using Flex.Data.Enum;
using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace Flex.API.Controllers
{
    public class PolicyController : BaseController
    {
        public IHttpActionResult GetDetails(string PolicyNo)
        {
            Logger.Info("Inside Get Details");
            try
            {
                PolicyDetails polDetails = null;

                if (string.IsNullOrEmpty(PolicyNo))
                {
                    Logger.Info("Data not received from client");
                    return BadRequest();
                }

                //var reqHash = new WebSecurityUtils().getHash(PolicyNo);
                //Logger.InfoFormat("Expected Hash : {0}", reqHash);
                //Logger.InfoFormat("Hash Received : {0}", model.Hash);
                //if (model.Hash != reqHash)
                //{
                //    polDetails = new PolicyDetails()
                //    {
                //        ResponseCode = "40"
                //    };
                //    return Ok(polDetails);
                //}
                Logger.InfoFormat("About to get details for policy no : {0}", PolicyNo);
                //var code = model.PolicyNo.Trim().Substring(0, 3);
                var context =getContext(PolicyNo);
                Logger.InfoFormat("Database Context {0} Gotten", context.Database.Connection.ConnectionString);
                polDetails = new CoreSystem<vwPolicy>(context).FindAll(x => x.policyno == PolicyNo).Select(x => new PolicyDetails()
                {
                    Balance = (decimal)x.balance.GetValueOrDefault(),
                    OtherName = x.othername,
                    PolicyNo = x.policyno,
                    PolicyType = x.poltype,
                    Status = x.status.ToString(),
                    Surname = x.surname
                }).FirstOrDefault();
                if (polDetails==null)
                {
                    polDetails = new PolicyDetails()
                    {
                        ResponseCode = "10"
                    };

                    return Ok(polDetails);
                }
                var clearstring = string.Concat(polDetails.PolicyNo, polDetails.Surname, polDetails.OtherName
                    , polDetails.PolicyType, polDetails.Status, polDetails.Balance);
                polDetails.Hash = new WebSecurityUtils().getHash(clearstring);
                polDetails.ResponseCode = "00";
                return Ok(polDetails);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return Ok(new PolicyDetails()
                {
                    ResponseCode = "20"
                });
            }
        }

        public IHttpActionResult GetPaymentHistory(PaymentHistoryQuery model) 
        {
            Logger.Info("Inside GetPayment History");
            PaymentHistoryResponse payhis = null;
            try
            {
                if (model==null)
                {
                    Logger.Info("No Data was received from client");

                    return BadRequest();
                }

                var reqHash = new WebSecurityUtils().getHash(model.PolicyNo);
                Logger.InfoFormat("Expected Hash : {0}", reqHash);
                Logger.InfoFormat("Hash Received : {0}", model.Hash);
                if (model.Hash != reqHash)
                {
                    payhis = new PaymentHistoryResponse()
                    {
                        ResponseCode = "40"
                    };
                    return Ok(payhis);
                }
                Logger.InfoFormat("About to get Payment History for policy no : {0}", model.PolicyNo);
                //var code = model.PolicyNo.Trim().Substring(0, 3);
                var context = getContext(model.PolicyNo);
                Logger.InfoFormat("Database Context {0} Gotten", context.Database.Connection.ConnectionString);

                if (model.IsPaged)
                {
                    var payhistory = new PaymentSystem(context).searchPaymentHistory(model.PolicyNo, model.DateFrom
                         , model.DateTo, model.PageSize.ToString(), model.Page.ToString());

                    if (payhistory != null)
                    {
                        var trans = payhistory.Items.Select(x => new PaymentDetails()
                        {
                            Amount = (decimal)x.amount.GetValueOrDefault(),
                            interest = (decimal)x.cur_intr.GetValueOrDefault(),
                            TransDate = (DateTime)x.trandate.GetValueOrDefault(),
                            TransReference = x.receiptno
                        }).ToList();

                        payhis = new PaymentHistoryResponse()
                        {
                            History = trans,
                            Name = payhistory.Items.ToList()[0].Name,
                            PolicyNo = payhistory.Items.ToList()[0].policyno,
                            ResponseCode = "00",
                            Hash = new WebSecurityUtils().getHash(string.Concat(payhis.PolicyNo, payhis.Name))
                        };

                        //return Ok(payhis);
                    }
                }
                else
                {
                    var upayhistory = new PaymentSystem(context).searchPaymentHistory(model.PolicyNo, model.DateFrom, model.DateTo);

                    if (upayhistory != null)
                    {
                        var trans = upayhistory.Select(x => new PaymentDetails()
                        {
                            Amount = (decimal)x.amount.GetValueOrDefault(),
                            interest = (decimal)x.cur_intr.GetValueOrDefault(),
                            TransDate = (DateTime)x.trandate.GetValueOrDefault(),
                            TransReference = x.receiptno
                        }).ToList();

                        payhis = new PaymentHistoryResponse()
                        {
                            History = trans,
                            Name = upayhistory.ToList()[0].Name,
                            PolicyNo = upayhistory.ToList()[0].policyno,
                            ResponseCode = "00",
                            Hash = new WebSecurityUtils().getHash(string.Concat(payhis.PolicyNo, payhis.Name))
                        };

                        //return Ok(payhis);
                    }
                }
                return Ok(payhis);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error ocurred. Details {0}", ex.ToString());
                return Ok(new PaymentHistoryResponse()
                {
                    ResponseCode = "20"
                });
            }
        }

        public IHttpActionResult SavePayment(PaymentRequestModel model)
        {
            Logger.Info("Inside GetPayment History");
            PaymentResponseModel pay = null;
            try
            {
                if (model == null)
                {
                    Logger.Info("No Data was received from client");

                    return BadRequest();
                }
                var hashstring = string.Concat(model.PolicyNo, model.TransactionRef, model.Amount, model.PaymentMethod);
                var reqHash = new WebSecurityUtils().getHash(hashstring);
                Logger.InfoFormat("Expected Hash : {0}", reqHash);
                Logger.InfoFormat("Hash Received : {0}", model.Hash);
                if (model.Hash != reqHash)
                {
                    pay = new PaymentResponseModel()
                    {
                        ResponseCode = "40"
                    };
                    return Ok(pay);
                }
                Logger.InfoFormat("About to Update Payment Details for policy no : {0}", model.PolicyNo);
                var code = model.PolicyNo.Trim().Substring(0, 3);
                var context = getContext(model.PolicyNo);
                Logger.InfoFormat("Database Context {0} Gotten", context.Database.Connection.ConnectionString);

                var onlineRect = new OnlineReciept();
                //onlineRect.Email = pol.email;
                onlineRect.InitialAmount = onlineRect.FinalAmount = Convert.ToDecimal(model.Amount);
                onlineRect.InitialPaymentDate = onlineRect.FinalPaymentDate = DateTime.Now;
                onlineRect.InitialResponseCode = onlineRect.FinalResponseCode = "00";
                //onlineRect.IntialResponseDecription = onlineRect.FinalResponseDecription = paymentUpdateRequest.ResponseDesc;
                onlineRect.IsSynched = false;
                onlineRect.PaymentChannel = model.PaymentMethod;
                onlineRect.PaymentDate = DateTime.Now;
                onlineRect.Policyno = model.PolicyNo;
                onlineRect.Product = code;
                onlineRect.ReceiptNo = model.TransactionRef;
                onlineRect.TransactionStatus = (int)TransactionStatus.Successful;

                pay = new PaymentResponseModel()
                {
                    Amount = model.Amount,
                    PolicyNo = model.PolicyNo,
                    TransactionRef = model.TransactionRef,
                    ResponseCode = "00",
                    Hash = new WebSecurityUtils().getHash(string.Concat(model.PolicyNo, model.TransactionRef, model.Amount))
                };
                return Ok(pay);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return Ok(new PaymentHistoryResponse()
                {
                    ResponseCode = "20"
                });
            }
        }
    }
}
