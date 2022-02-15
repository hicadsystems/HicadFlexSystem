using Dapper;
using Flex.Business;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.Utility;
using Flex.Data.ViewModel;
using Flex.Models.ReportModel;
using Flex.Util;
using Flex.Utility.Utils;
using Newtonsoft.Json;
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace Flex.Controllers
{
    public class PaymentController : ContainerController
    {
        public ActionResult PaymentListing()
        {
            //ViewBag.paymentMethods = GetPaymentMethods();
            //ViewBag.instruments = getPaymentInstruments();
            var datefrom = DateTime.Today.AddDays(-30).ToString();
            var dateto = DateTime.Today.ToString();

            var payments = new PagedResult<fl_payinput>();
            using (var _context = context)
            {
                payments = new PaymentSystem(_context).searchTransaction("", "", "", datefrom, dateto, "");
            }
            return PartialView("_payments", payments);
        }
        // GET: Payment
        public ActionResult Listing()
        {
            return PartialView("_paymentListLayout");
        }

        /*public ActionResult PaymentListingPdf(QueryModel query = null)
        {
            Logger.Info("Inside payment listing");
            try
            {
                using (var _context = context)
                {
                    List<rptPaymentList> paymentLists = new List<rptPaymentList>();

                    paymentLists = new CoreSystem<fl_payinput>(_context).FindAll(x => x.reverseind == false).Select(x => new rptPaymentList()
                    {
                        RecieptNo = x.receiptno,
                        PolicyNo = x.policyno,
                        TransDate = x.trandate.Value,
                        ChequeNo = x.chequeno,
                        Amount = x.amount.Value
                    }).ToList();

                    if (query == null)
                    {
                        return RedirectToAction("Agents");
                    }
                    else
                    {
                        var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.PaymentListing);
                        var rpt = new CrystalReportEngine();
                        rpt.reportFormat = ReportFormat.pdf;

                        rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                        var savedir = Server.MapPath(ConfigUtils.ReportPath);
                        var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                        rpt.ReportName = Path.Combine(savedir, reportName);
                        rpt.GenerateReport(paymentLists);

                        return ExportReport(reportName);


                    }
                }
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }*/
        public ActionResult GPaymentListing()
        {
            var datefrom = DateTime.Today.AddDays(-30).ToString();
            var dateto = DateTime.Today.ToString();

            getGroup();
            var payments = new PagedResult<fl_translog>();
            using (var _context = context)
            {
                payments = new PaymentSystem(_context).searchGTransaction("", "", "", datefrom, dateto, "", WebSecurity.ModulePolicyTypes);
            }
            return PartialView("_gratuityPayments", payments);
        }


        private SelectList getPaymentInstruments()
        {
            var instruments = UtilEnumHelper.GetEnumList(typeof(Instrument));
            return new SelectList(instruments, "ID", "Name");
        }

        public ActionResult SearchTransaction(string queryjson)
        {
            Logger.Info("Transaction Search");
            try
            {
                if (!string.IsNullOrEmpty(queryjson))
                {
                    var query = JsonConvert.DeserializeObject<paymentQueryModel>(queryjson);
                    string page = string.Empty;
                    string size = string.Empty;
                    if (query.Page!=null)
                    {
                        page = query.Page.Page;
                        size = query.Page.Size;
                    }
                    var trans = new PagedResult<fl_payinput>();
                    using (var _context = context)
                    {
                        trans = new PaymentSystem(_context).searchTransaction(page, size, query.ReceiptNo, query.DateFrom,query.DateTo, query.policyno);
                    }
                    return PartialView("_tbPayments", trans);
                    //return PartialView("_payments", trans);
                }
                throw new Exception();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult PaymentListingPdf(string queryjson)
        {
            Logger.Info("Inside payment listing");
            try
            {
                List<rptPaymentList> paymentLists = new List<rptPaymentList>();
                using (var _context = context)
                {
                    if (!string.IsNullOrEmpty(queryjson))
                    {
                        var query = JsonConvert.DeserializeObject<paymentQueryModel>(queryjson);

                        paymentLists = new PaymentSystem(_context).getTransaction(query.ReceiptNo,query.DateFrom,query.DateTo,query.ReceiptNo).Select(x => new rptPaymentList()
                        {
                            RecieptNo = x.receiptno,
                            PolicyNo = x.policyno,
                            TransDate = x.trandate.Value,
                            ChequeNo = x.chequeno,
                            Amount = x.amount.Value
                        }).ToList();

                        var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.PaymentListing);
                        var rpt = new CrystalReportEngine();
                        rpt.reportFormat = ReportFormat.pdf;

                        rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                        var savedir = Server.MapPath(ConfigUtils.ReportPath);
                        var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                        rpt.ReportName = Path.Combine(savedir, reportName);
                        rpt.GenerateReport(paymentLists);

                        return ExportReport(reportName);
                    }
                    return RedirectToAction("Agents");
                   
                }
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult SearchGTransaction(string queryjson)
        {
            Logger.Info("Gratuity Transaction Search");
            try
            {
                if (!string.IsNullOrEmpty(queryjson))
                {
                    var query = JsonConvert.DeserializeObject<paymentQueryModel>(queryjson);
                    string page = string.Empty;
                    string size = string.Empty;
                    if (query.Page != null)
                    {
                        page = query.Page.Page;
                        size = query.Page.Size;
                    }
                    var trans = new PagedResult<fl_translog>();
                    using (var _context = context)
                    {
                        trans = new PaymentSystem(_context).searchGTransaction(page, size, query.ReceiptNo, query.DateFrom, query.DateTo,query.GroupCode,WebSecurity.ModulePolicyTypes);
                    }
                    return PartialView("_tbGPayments", trans);
                }
                throw new Exception();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult Accounts()
        {
            try
            {
                ViewBag.paymentMethods = GetPaymentMethods();
                var polTypes = new List<fl_poltype>();
                var rctCtrl = new PagedResult<fl_receiptcontrol>();

                using(var _context = context)
                {
                    polTypes = new CoreSystem<fl_poltype>(_context).FindAll(x => x.IsDeleted == false).ToList();
                    ViewBag.polTypes = new SelectList(polTypes, "Id", "poldesc");
                    Func<fl_receiptcontrol, dynamic> orderFunc = u => u.Id;
                    var query = new CoreSystem<fl_receiptcontrol>(_context).FindAll(x => x.IsDeleted == false && x.fl_poltype.IsDeleted == false);
                    rctCtrl = new CoreSystem<fl_receiptcontrol>(_context).PagedQuery(orderFunc, query);
                }
               
                return PartialView("_paymentAccounts",rctCtrl);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SearchPaymentAccounts(paymentQueryModel querymodel)
        {
            try
            {
                var rctCtrl = new PagedResult<fl_receiptcontrol>();
                Func <fl_receiptcontrol, dynamic> orderFunc = u => u.Id;

                using(var _context= context)
                {
                    var query = new CoreSystem<fl_receiptcontrol>(_context).GetAll().IncludeMultiple(p => p.fl_poltype);
                    PaymentMethod paymethod;
                    int poltype = 0;
                    if (!string.IsNullOrEmpty(querymodel.PaymentMethod))
                    {
                        paymethod = (PaymentMethod)Enum.Parse(typeof(PaymentMethod), querymodel.PaymentMethod);
                        query = query.Where(x => x.PaymentMethod == paymethod);
                    }
                    if (!string.IsNullOrEmpty(querymodel.PolicyType))
                    {
                        int.TryParse(querymodel.PolicyType, out poltype);
                        query = query.Where(x => x.PolTypeId == poltype);
                    }
                    rctCtrl = new CoreSystem<fl_receiptcontrol>(_context).PagedQuery(orderFunc, query);
                }
                
                return PartialView("_tbPaymentAccount", rctCtrl);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult AddEditPaymentAccount(long Id = 0)
        {
            try
            {
                Logger.Info("AddEditPaymentAccount");
                var payAcct = new fl_receiptcontrol();
                using (var _context = context)
                {
                    if (Id > 0)
                    {
                        payAcct = new CoreSystem<fl_receiptcontrol>(_context).Get(Id);
                    }
                    ViewBag.PaymentMethods = payAcct.Id > 0 ? GetPaymentMethods((int)payAcct.PaymentMethod) : GetPaymentMethods();

                    var incomeSelected = payAcct.Id > 0 ? payAcct.Income_ledger : "";
                    var bankSelected = payAcct.Id > 0 ? payAcct.Bank_ledger : "";

                    ViewBag.IncomeAcct = getAccounts(incomeSelected);
                    ViewBag.BankAcct = getAccounts(bankSelected);

                    if (payAcct.Id > 0)
                    {
                        var poltypes = new List<fl_poltype>();
                        var poltype = new fl_poltype();

                        poltype = new CoreSystem<fl_poltype>(_context).Get((int)payAcct.PolTypeId);

                        poltypes.Add(poltype);
                        ViewBag.PolicyType = new SelectList(poltypes, "Id", "poldesc", payAcct.PolTypeId);
                    }
                }

                return PartialView("_addEditPaymentAccount", payAcct);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SaveUpdatePaymentAccount(FormCollection formdata)
        {
            Logger.Info("About to save PaymentAccount");
            try
            {
                int Id = 0;
                int polType = 0;
                var payAcct = new fl_receiptcontrol();

                if (formdata != null)
                {
                    int.TryParse(formdata["Id"].ToString(), out Id);
                    var paymethod = formdata["PayMethod"].ToString();
                    var paymentMethod = (PaymentMethod)Enum.Parse(typeof(PaymentMethod), paymethod);
                    payAcct.PaymentMethod = paymentMethod;
                    var pType = formdata["PolType"].ToString();
                    int.TryParse(pType, out polType);
                    payAcct.PolTypeId = polType;
                    payAcct.Income_ledger = formdata["Income"].ToString();
                    payAcct.DateCreated = DateTime.Today;
                    payAcct.Bank_ledger = formdata["Bank"].ToString();
                    payAcct.Bankname = formdata["BankName"].ToString();
                    payAcct.BankAccount = formdata["Account"].ToString();
                    payAcct.IsDeleted = false;

                    using (var _context = context)
                    {
                        if (Id == 0)
                        {
                            new CoreSystem<fl_receiptcontrol>(_context).Save(payAcct);
                        }
                        else
                        {
                            payAcct.Id = Id;
                            new CoreSystem<fl_receiptcontrol>(_context).Update(payAcct, payAcct.Id);
                        }
                    }
                }
                return RedirectToAction("Accounts");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult DeletePaymentAccount(long Id)
        {
            var rctCtrl = new fl_receiptcontrol();
            using (var _context = context)
            {
                rctCtrl = _context.Set<fl_receiptcontrol>().Include("fl_poltype").Where(x=>x.Id==Id).FirstOrDefault();
            }

            var mModel = new ModalModel()
            {
                Id = rctCtrl.Id,
                Desc = string.Format("Are you sure you want to delete [{0}] Account for [{1}]", rctCtrl.fl_poltype.poldesc,rctCtrl.PaymentMethod)
            };

            return PartialView("_deleteConfirmation", mModel);
        }

        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult cDeletePaymentAccount(long Id)
        {
            using(var _context= context)
            {
                var loc = new CoreSystem<fl_receiptcontrol>(_context).Get(Id);

                loc.IsDeleted = true;

                new CoreSystem<fl_receiptcontrol>(_context).Update(loc, Id);
            }

            return RedirectToAction("Accounts");
        }

        public JsonResult GetPolicyTypeNotSetUp(string paymentMethod)
        {
            try
            {
                if (!string.IsNullOrEmpty(paymentMethod))
	            {
                    Logger.InfoFormat("About to get policy types not setup for payment method {0}", paymentMethod);
                    var polTypes = GetPolicyTypeNotSetUpAcct(paymentMethod);
                    var sPolTypes = polTypes.Select(x => new SelectListItem()
                    {
                        Text = x.poldesc,
                        Value = x.Id.ToString()
                    }).ToList();
                    return Json(sPolTypes, JsonRequestBehavior.AllowGet);
	            }
                else
                {
                    throw new Exception();
                }

            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return Json(new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message));
            }
        }

        private List<fl_poltype> GetPolicyTypeNotSetUpAcct(string paymethod)
        {
            var xpaymenthod = (PaymentMethod)Enum.Parse(typeof(PaymentMethod), paymethod);
            var polTypes = new List<fl_poltype>();

            using(var _context= context)
            {
                polTypes = new CoreSystem<fl_poltype>(_context).FindAll(x => x.IsDeleted == false && !x.fl_receiptcontrol.Any(y => y.PaymentMethod == xpaymenthod)).ToList();
            }

            return polTypes;
        }
        [HttpGet]
        public ActionResult TransactionPost()
        {
            ViewBag.instruments = getPaymentInstruments();
            ViewBag.paymentMethods = GetPaymentMethods();
            getGroup();
            return PartialView("_paymentLayout");
        }

        [HttpGet]
        public ActionResult GUpdateTransaction()
        {
            getReceipt();
            getPolicyType();
            return PartialView("_gpaymentupdate");
        }

        [HttpPost]
        public ActionResult GUpdateTransactions(string queryj)
        {
            try
            {
                var query = JsonConvert.DeserializeObject<dynamic>(queryj);
                string receiptno = query.ReceiptNo;
                string policytype = query.PolicyType;
                string remark = query.Remark;
                string sms = query.SMS;
                //string status;
                //var policytype = formdata["PolicyType"].ToString();
                //var remark = formdata["Remark"].ToString();
                //bool.TryParse(formdata["SMS"].ToString(), out smschk);
                //var sms = formdata["SMS"].ToString();

                var userid = GetUserSesiion().fl_password.userid;
                var queryparameter = new DynamicParameters();


                if (string.IsNullOrEmpty(sms))
                {

                    queryparameter.Add("@poltype", policytype);
                    queryparameter.Add("@guser", userid);
                    queryparameter.Add("@receipt", receiptno);
                    queryparameter.Add("@msg", remark);
                    if (!string.IsNullOrEmpty(policytype))
                    {
                        using (var conn = new SqlConnection(context.Database.Connection.ConnectionString))
                        {
                            conn.Execute("fl_updgrat_receipt", queryparameter, commandType: System.Data.CommandType.StoredProcedure, commandTimeout: 2000);
                        }
                    }
                    else
                    {
                        throw new Exception("Please fill all fields");
                    }
                }
                else
                {
                    queryparameter.Add("@poltype", policytype);
                    queryparameter.Add("@guser", userid);
                    queryparameter.Add("@receipt", receiptno);
                    queryparameter.Add("@msg", remark);
                    using (var conn = new SqlConnection(context.Database.Connection.ConnectionString))
                    {
                        conn.Execute("fl_updgrat_receipt_smsonly", queryparameter, commandType: System.Data.CommandType.StoredProcedure, commandTimeout: 2000);
                    }

                }
                //return RedirectToAction("GPaymentListing");
                return new JsonResult()
                {
                    Data = "Payment Update Successful"
                };
            }
            catch (Exception ex)
            {

                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }

        }

        public ActionResult GReverseReceipt()
        {
            getReceipt();
            getPolicyType();
            return PartialView("_greceiptreversal");
        }

        [HttpPost]
        public ActionResult GReverseTransactions(string queryj)
        {
            try
            {
                var query = JsonConvert.DeserializeObject<dynamic>(queryj);
                string receiptno = query.ReceiptNo;
                string policytype = query.PolicyType;
                //string remark = query.Remark;
                string sms = query.SMS;
                //string status;
                //var policytype = formdata["PolicyType"].ToString();
                //var remark = formdata["Remark"].ToString();
                //bool.TryParse(formdata["SMS"].ToString(), out smschk);
                //var sms = formdata["SMS"].ToString();

                var userid = GetUserSesiion().fl_password.userid;
                var queryparameter = new DynamicParameters();


                using (var _context = context)
                {

                    var payinput = new CoreSystem<fl_payinput2>(_context).FindAll(x => x.receiptno == receiptno).FirstOrDefault();
                    if (payinput == null)
                    {
                        throw new Exception("Invalid Transaction");
                    }
                    using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                    {
                        try
                        {
                            //var queryparameter = new DynamicParameters();
                            queryparameter.Add("@poltype", payinput.poltype);
                            queryparameter.Add("@receipt", payinput.receiptno);
                            if (!string.IsNullOrEmpty(payinput.poltype))
                            {
                                using (var conn = new SqlConnection(context.Database.Connection.ConnectionString))
                                {
                                    if (!string.IsNullOrEmpty(sms))
                                    {
                                        conn.Execute("fl_receipt_reversal", queryparameter, commandType: System.Data.CommandType.StoredProcedure, commandTimeout: 2000);
                                    }
                                    conn.Execute("fl_receipt_reversal_delete", queryparameter, commandType: System.Data.CommandType.StoredProcedure, commandTimeout: 2000);
                                }
                            }
                            return RedirectToAction("Listing");
                        }
                        catch (Exception)
                        {
                            throw;
                        }
                    }
                }
               
            }
            catch (Exception ex)
            {

                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }


        }


        [HttpPost]
        public ActionResult PostTransaction(FormCollection formdata)
        {
            try
            {
                var amt = 0.0M;
                string chqno = string.Empty;
                var recieptno=string.Empty;
                if (formdata !=null)
                {
                    var policyno = formdata["PolicyNo"].ToString();
                    var instr = formdata["Type"].ToString();
                    var xInstr = (Instrument)Enum.Parse(typeof(Instrument), instr);
                    var amount = formdata["Amount"].ToString();
                    decimal.TryParse(amount, out amt);
                    var paymethod = formdata["PaymentMethod"].ToString();
                    var xPaymethod = (PaymentMethod)Enum.Parse(typeof(PaymentMethod), paymethod);
                    var narr = formdata["Narration"].ToString();
                    var transDate = formdata["TransactionDate"].ToString();
                    if (formdata["ChequeNo"] != null)
	                {
                        chqno = formdata["ChequeNo"].ToString();
	                }

                    /*DateTime _transDate = DateTime.Now;

                    DateTime.TryParseExact(transDate, "yyyyMMdd", CultureInfo.InvariantCulture, DateTimeStyles.None, out _transDate);*/
                    DateTime _transDate = DateTime.Parse(transDate);

                    using (var _context = context)
                    {
                        var pol = new PolicySystem(_context).FindAll(x => x.policyno == policyno).FirstOrDefault();
                        if (pol == null)
                        {
                            throw new Exception("Invalid policy number");
                        }
                        var pyctrl = new CoreSystem<fl_receiptcontrol>(_context).FindAll(x => x.fl_poltype.poltype == pol.poltype
                            && x.PaymentMethod == xPaymethod).FirstOrDefault();
                        if (pyctrl == null)
                        {
                            throw new Exception(string.Format("Account has not been set up for policytype {0} with payment method {1} "
                                , pol.poltype, xPaymethod));
                        }
                        SerialNoCountKey serialnoKey = SerialNoCountKey.RT;
                        if (xInstr == Instrument.RECEIPT)
                        {
                            serialnoKey = SerialNoCountKey.RT;
                        }
                        else if (xInstr == Instrument.JournalVoucher)
                        {
                            serialnoKey = SerialNoCountKey.JV;
                        }
                        else if (xInstr == Instrument.PaymentVoucher)
                        {
                            serialnoKey = SerialNoCountKey.PV;
                        }
                        using (var transaction = _context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                        {
                            try
                            {
                                var translog = new fl_translog();
                                translog.amount = amt;
                                translog.bank_ledger = pyctrl.Bank_ledger;
                                translog.income_ledger = pyctrl.Income_ledger;
                                translog.Instrument = xInstr;
                                translog.paymentmethod = xPaymethod;
                                translog.policyno = policyno;
                                translog.remark = narr;
                                translog.trandate = DateTime.Now;
                                int sn = UtilitySystem.GetNextSerialNumber(context, serialnoKey);
                                recieptno = new UtilitySystem().GenerateRef(pol.poltype, sn);
                                translog.receiptno = recieptno;
                                translog.poltype = pol.poltype;
                                new CoreSystem<fl_translog>(_context).Save(translog);

                                var payinput = new fl_payinput();

                                payinput.amount = amt;
                                payinput.chequeno = chqno;
                                payinput.datecreated = DateTime.Now;
                                payinput.grpcode = pol.grpcode;
                                payinput.policyno = policyno;
                                payinput.poltype = pol.poltype;
                                payinput.receiptno = recieptno;
                                payinput.totamt = amt;
                                payinput.type = xInstr.ToString();
                                payinput.trandate = _transDate;

                                new CoreSystem<fl_payinput>(_context).Save(payinput);

                                var payhis = new fl_payhistory();
                                payhis.amount = amt;
                                payhis.grpcode = pol.grpcode;
                                payhis.orig_date = DateTime.Now;
                                payhis.policyno = policyno;
                                payhis.receiptno = recieptno;
                                payhis.trandate = DateTime.Now;
                                payhis.doctype = xInstr.ToString();
                                payhis.period = DateTime.Today.ToString("yyyy") + "00";
                                payhis.poltype = pol.poltype;
                                payhis.trandate = _transDate;

                                new CoreSystem<fl_payhistory>(_context).Save(payhis);

                                transaction.Commit();
                                if (xInstr == Instrument.RECEIPT)
                                {
                                    var polName = string.Format("{0} {1}", pol.surname, pol.othername);
                                    var rctList = new List<rptReceipt>();
                                    rctList.Add(new rptReceipt()
                                    {
                                        Payer = polName,
                                        ReceiptNo = recieptno,
                                        RefNo = chqno,
                                        Remarks = translog.remark,
                                        TransDate = translog.trandate.GetValueOrDefault().ToShortDateString(),
                                        AmountinWord = "",
                                        BranchCode = ""
                                    });
                                    try
                                    {
                                        var rpt = new CrystalReportEngine();
                                        rpt.reportFormat = ReportFormat.pdf;
                                        var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.Receipt);

                                        var rparams = new List<KeyValuePair<string, string>>();
                                        rparams.Add(RptHeaderCompanyName);
                                        rparams.Add(RptHeaderCompanyAddress);
                                        var amtinwordsparam = new KeyValuePair<string, string>("input1", rctList[0].AmountinWord);
                                        rparams.Add(amtinwordsparam);
                                        var remarksparam = new KeyValuePair<string, string>("input2", rctList[0].Remarks);
                                        rparams.Add(remarksparam);
                                        rpt.Parameter = rparams;

                                        rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                                        var savedir = Server.MapPath(ConfigUtils.ReportPath);
                                        var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                                        rpt.ReportName = Path.Combine(savedir, reportName);
                                        rpt.GenerateReport(rctList);
                                        //var contentType = "application/pdf";

                                        return ExportReport(reportName);
                                        //return new ReportFileActionResult(rpt.streamProduct, rpt.ReportName, contentType);
                                    }
                                    catch (Exception ex)
                                    {
                                        Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                                        return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
                                        //throw;
                                    }

                                }
                                else
                                {
                                    return RedirectToAction("Listing");
                                }
                            }
                            catch (Exception ex)
                            {
                                transaction.Rollback();
                                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                                //throw;
                            }
                        }

                    }

                }
                else
                {
                    throw new Exception("Invalid Data");
                }
                return View();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
                //throw;
            }
        }

        public ActionResult ConfirmReverse(long Id)
        {
            var trans = new fl_payinput();
            using(var _context= context)
            {
                trans = new CoreSystem<fl_payinput>(_context).Get(Id);
            }

            var mModel = new ModalModel()
            {
                Id = trans.Id,
                Desc = string.Format("Are you sure you want to Reverse [{0}]", trans.receiptno)
            };

            return PartialView("_deleteConfirmation", mModel);

        }

        public ActionResult ReverseTransaction(long Id)
        {

            try
            {
                var amt = 0.0M;
                string chqno = string.Empty;
                var recieptno = string.Empty;
                using (var _context = context)
                {
                    //var trans = new CoreSystem<fl_payinput>(_context).Get(Id);
                    //if (trans==null)
                    //{
                    //    throw new Exception("Invalid Transaction");
                    //}
                    var payinput = new CoreSystem<fl_payinput>(_context).FindAll(x => x.Id == Id).FirstOrDefault();
                    if (payinput == null)
                    {
                        throw new Exception("Invalid Transaction");
                    }
                    var pol = new PolicySystem(_context).FindAll(x => x.policyno == payinput.policyno).FirstOrDefault();
                    if (pol == null)
                    {
                        throw new Exception("Invalid policy number");
                    }
                    using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                    {
                        try
                        {
                            //trans.reverseind = true;
                            //new CoreSystem<fl_payinput>(_context).Update(trans, trans.Id);

                            //var revTrans = new fl_translog();
                            //revTrans.amount = trans.amount * -1;
                            //revTrans.bank_ledger = trans.bank_ledger;
                            //revTrans.income_ledger = trans.income_ledger;
                            //revTrans.Instrument = Instrument.JournalVoucher;
                            //revTrans.Isreversed = true;
                            //revTrans.paymentmethod = trans.paymentmethod;
                            //revTrans.policyno = trans.policyno;
                            //revTrans.receiptno = trans.receiptno + "R";
                            //revTrans.remark = string.Format("Reversal on {0}", trans.receiptno);
                            //revTrans.trandate = DateTime.Now;
                            //new CoreSystem<fl_translog>(_context).Save(revTrans);


                            payinput.reverseind = true;
                            new CoreSystem<fl_payinput>(_context).Update(payinput, payinput.Id);
                            var revPayinput = new fl_payinput();

                            revPayinput.amount = payinput.amount * -1;
                            revPayinput.chequeno = chqno;
                            revPayinput.datecreated = DateTime.Now;
                            revPayinput.grpcode = payinput.grpcode;
                            revPayinput.policyno = payinput.policyno;
                            revPayinput.poltype = payinput.poltype;
                            revPayinput.receiptno = payinput.receiptno + "R";
                            revPayinput.totamt = payinput.amount * -1;
                            revPayinput.type = Instrument.JournalVoucher.ToString();

                            new CoreSystem<fl_payinput>(_context).Save(revPayinput);

                            var payhis = new CoreSystem<fl_payhistory>(_context).FindAll(x => x.receiptno == payinput.receiptno)
                                .OrderByDescending(x => x.trandate).FirstOrDefault();
                            var revPayhis = new fl_payhistory();
                            revPayhis.amount = payhis.amount * -1;
                            revPayhis.grpcode = payhis.grpcode;
                            revPayhis.orig_date = DateTime.Now;
                            revPayhis.policyno = payhis.policyno;
                            revPayhis.receiptno = payhis.receiptno + "R";
                            revPayhis.trandate = DateTime.Now;
                            revPayhis.doctype = Instrument.JournalVoucher.ToString();
                            revPayhis.period = payhis.period;
                            revPayhis.loanamt = payhis.loanamt * -1;
                            revPayhis.openbalance = payhis.openbalance * -1;
                            revPayhis.opendeposit = payhis.opendeposit * -1;
                            revPayhis.cumul_intr = payhis.cumul_intr * -1;
                            revPayhis.cumuldep_intr = payhis.cumuldep_intr * -1;
                            revPayhis.cur_intr = payhis.cur_intr * -1;
                            revPayhis.curdep_intr = payhis.curdep_intr * -1;
                            revPayhis.deposit = payhis.deposit * -1;

                            new CoreSystem<fl_payhistory>(_context).Save(revPayhis);

                            transaction.Commit();
                            return RedirectToAction("Listing");
                        }
                        catch (Exception)
                        {
                            transaction.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }

        }

        //public ActionResult GConfirmReverse(long Id)
        //{
        //    var trans = new fl_translog();
        //    //var input = new fl_translog();
        //    using (var _context = context)
        //    {
        //        trans = new CoreSystem<fl_translog>(_context).Get(Id);
        //    }

        //    var mModel = new ModalModel()
        //    {
        //        Id = trans.Id,
        //        Desc = string.Format("Are you sure you want to Reverse [{0}]", trans.receiptno)
        //    };

        //    return PartialView("_deleteConfirmation", mModel);

        //}


        //public ActionResult GReverseTransaction(long Id, string sms)
        //{

        //    try
        //    {
        //        var amt = 0.0M;
        //        string chqno = string.Empty;
        //        var recieptno = string.Empty;
        //        using(var _context = context)
        //        {
                    
        //            var payinput = new CoreSystem<fl_translog>(_context).FindAll(x => x.Id == Id).FirstOrDefault();
        //            if (payinput == null)
        //            {
        //                throw new Exception("Invalid Transaction");
        //            }
        //            var pol = new CoreSystem<fl_payinput2>(_context).FindAll(x => x.receiptno == payinput.receiptno).FirstOrDefault();
        //            if (pol == null)
        //            {
        //                throw new Exception("Invalid policy number");
        //            }
        //            using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
        //            {
        //                try
        //                {
        //                    var queryparameter = new DynamicParameters();
        //                    queryparameter.Add("@poltype", pol.poltype );
        //                    queryparameter.Add("@receipt", pol.receiptno);
        //                    if (!string.IsNullOrEmpty(pol.poltype))
        //                    {
        //                        using (var conn = new SqlConnection(context.Database.Connection.ConnectionString))
        //                        {
        //                            conn.Execute("fl_receipt_reversal", queryparameter, commandType: System.Data.CommandType.StoredProcedure, commandTimeout: 2000);
        //                            conn.Execute("fl_receipt_reversal_delete", queryparameter, commandType: System.Data.CommandType.StoredProcedure, commandTimeout: 2000);
        //                        }
        //                    }
        //                    return RedirectToAction("Listing");
        //                }
        //                catch (Exception)
        //                {
        //                    throw;
        //                }
        //            }
        //        }
        //    }
        //    catch (Exception ex)
        //    {                   
        //        Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
        //        return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
        //    }

        //}

        public JsonResult PolicynoAutoComplete(string query)
        {
            var products = new PolicySystem(currentContext).FindAll(x => (x.policyno.ToLower().Contains(query.ToLower())
            || x.surname.ToLower().Contains(query.ToLower()) || x.othername.ToLower().Contains(query.ToLower()))
            && WebSecurity.ModulePolicyTypes.Contains(x.poltype)).OrderBy(x => x.surname).OrderBy(x => x.othername).Take(15).ToList()
                .Select(x => new
                {
                    value = x.policyno,
                    label = string.Format("{0} {1}../{2}", x.surname, x.othername, x.policyno)
                }).ToList();

            //var prodJson= new JavaScriptSerializer().Serialize(products);
            return Json(products, JsonRequestBehavior.AllowGet);
        }

        public JsonResult ValidateReceipt(string ReceiptNo)
        {
            try
            {
                bool isValid = false;
                using(var _context= context)
                {
                    isValid = _context.fl_translog.Where(x => x.receiptno == ReceiptNo).Any();
                    if (isValid)
                    {
                        var resp = new
                        {
                            success = !isValid,
                            message = string.Format("Receipt {0} already exists", ReceiptNo)
                        };
                        return Json(resp, JsonRequestBehavior.AllowGet);
                    }
                    isValid = _context.ac_rctheader.Any(x => x.rcth_number == ReceiptNo);
                }
                var resp2 = new
                {
                    success = isValid,
                    message = string.Format("Receipt {0} does not exists in accounts", ReceiptNo)
                };
                return Json(resp2, JsonRequestBehavior.AllowGet);
            }
            catch (Exception)
            {

                throw;
            }
        }

        public ActionResult UploadPayment(long GroupCode, string ReceiptNo, string TransactionDate)
        {
            try
            {
                var file = Request.Files[0];
                var payInputs = new List<fl_payinput2>();
                var uploadErrors = new List<string>();
                DateTime xDate = DateTime.Now;
                DateTime.TryParseExact(TransactionDate, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out xDate);

                if ( !xDate.ToString().Contains("1/1/0001"))
                {
                    using (var _context = context)
                    {
                        var _rct = _context.ac_rctheader.Where(x => x.rcth_number == ReceiptNo).FirstOrDefault();
                        var _grpCode = _context.fl_grouptype.Where(x => x.Id == GroupCode).FirstOrDefault();
                        if ((file != null) && (file.ContentLength > 0) && !string.IsNullOrEmpty(file.FileName))
                        {
                            string fileName = file.FileName;
                            string fileContentType = file.ContentType;
                            byte[] fileBytes = new byte[file.ContentLength];
                            var data = file.InputStream.Read(fileBytes, 0, Convert.ToInt32(file.ContentLength));
                            ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
                            using (var package = new ExcelPackage(file.InputStream))
                            {
                                var currentSheet = package.Workbook.Worksheets;
                                var workSheet = currentSheet.First();
                                var noOfCol = workSheet.Dimension.End.Column;
                                var noOfRow = workSheet.Dimension.End.Row;
                                for (int rowIterator = 2; rowIterator <= noOfRow; rowIterator++)
                                {
                                    var payinput2 = new fl_payinput2();
                                    payinput2.policyno = workSheet.Cells[rowIterator, 2].Value.ToString();

                                    var _pol = _context.fl_policyinput.Where(x => x.policyno == payinput2.policyno).FirstOrDefault();
                                    if (_pol == null)
                                    {
                                        uploadErrors.Add(string.Format("Invalid PolicyNo {0}", payinput2.policyno));
                                        continue;
                                    }
                                    payinput2.pcn = workSheet.Cells[rowIterator, 1].Value?.ToString();

                                    payinput2.grpcode = _grpCode.grpcode;
                                    var _er = 0.00M;
                                    decimal.TryParse(workSheet.Cells[rowIterator, 4].Value?.ToString(), out _er);
                                    payinput2.er = _er;
                                    var _ee = 0.00M;
                                    decimal.TryParse(workSheet.Cells[rowIterator, 5].Value?.ToString(), out _ee);
                                    payinput2.ee = _ee;
                                    var _avc = 0.00M;
                                    decimal.TryParse(workSheet.Cells[rowIterator, 6].Value?.ToString(), out _avc);
                                    payinput2.av = _avc;
                                    var _cc = 0.00M;
                                    decimal.TryParse(workSheet.Cells[rowIterator, 7].Value?.ToString(), out _cc);
                                    payinput2.cc = _cc;
                                    var _psc = 0.00M;
                                    decimal.TryParse(workSheet.Cells[rowIterator, 8].Value?.ToString(), out _psc);
                                    payinput2.psc = _psc;
                                    var _ps = 0.00M;
                                    decimal.TryParse(workSheet.Cells[rowIterator, 3].Value?.ToString(), out _ps);
                                    payinput2.ps = _ps;
                                    payinput2.status = Status.Active;
                                    payinput2.poltype = _pol.poltype;
                                    payinput2.createdby = User.Identity.Name;
                                    payinput2.datecreated = DateTime.Now;
                                    payinput2.effdate = xDate;
                                    payinput2.receiptno = ReceiptNo;
                                    payinput2.totamt = payinput2.ps.GetValueOrDefault() + payinput2.av.GetValueOrDefault() + payinput2.cc.GetValueOrDefault() + payinput2.ee.GetValueOrDefault()
                                        + payinput2.er.GetValueOrDefault() + payinput2.psc.GetValueOrDefault();
                                    payinput2.reverseind = false;
                                    payinput2.trandate = xDate;
                                    payinput2.type = Instrument.RECEIPT.ToString();
                                    payInputs.Add(payinput2);
                                }
                            }
                        }

                        var totalAmt = payInputs.Sum(x => x.totamt);
                        if (_rct.rcth_total < totalAmt)
                        {
                            var resp = new
                            {
                                success = false,
                                message = "Receipt Amount less than total Amount"
                            };

                            return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, resp.message);
                            //return new JsonResult()
                            //{
                            //    Data = resp
                            //};
                        }
                        var _module = _context.Modules.Where(x => x.Code == WebSecurity.Module).FirstOrDefault();
                        fl_poltype _polType = null;
                        if (_module != null)
                        {
                            _polType = _context.fl_poltype.Where(x => x.poltype == _module.PolicyType).FirstOrDefault();
                        }
                        var transLog = new fl_translog()
                        {
                            amount = totalAmt,
                            Instrument = Instrument.RECEIPT,
                            Isreversed = false,
                            receiptno = ReceiptNo,
                            bank_ledger = _rct.rcth_bank,
                            chequeno = _rct.rcth_cheque,
                            income_ledger = _polType != null ? _polType.income_account : "",
                            trandate = xDate,
                            poltype = _polType.poltype,
                            grpcode = _grpCode.grpcode
                        };

                        _context.fl_translog.Add(transLog);
                        _context.fl_payinput2.AddRange(payInputs);
                        _context.SaveChanges();
                    }

                }
                else
                {
                    throw new Exception("Please select a valid date");
                }
                var resp2 = new
                {
                    success = true,
                    message = "Policy Created Successfully"
                };

                return new JsonResult()
                {
                    Data = resp2
                };
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Uploading Policy. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult ViewPaymentDetails(string ReceiptNo)
        {
            try
            {
                var payItems = new List<fl_payinput2>();
                using (var _context=context)
                {
                    payItems = _context.fl_payinput2.Where(x => x.receiptno == ReceiptNo).ToList();
                }
                return PartialView("_gpaymentDetails", payItems);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        [HttpGet]
        public ActionResult Update()
        {
            return PartialView("_paymentUpdateLayout");
        }

        [HttpPost]
        public ActionResult UpdateTransactions(FormCollection formdata)
        {
            try
            {
                var amt = 0.0M;
                string chqno = string.Empty;
                var recieptno = string.Empty;
                if (formdata != null)
                {
                    var dateFrom = formdata["DateFrom"].ToString();
                    var dateTo = formdata["DateTo"].ToString();

                    DateTime _dateFrom = DateTime.Today;
                    DateTime _dateto = DateTime.Today;

                    DateTime.TryParseExact(dateFrom, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out _dateFrom);
                    DateTime.TryParseExact(dateTo, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out _dateto);

                    _dateto = _dateto.AddDays(1).AddSeconds(-1);

                    using (var _context = currentContext)
                    {
                        var trans = _context.ac_rctheader.Where(x => x.rcth_unitcode == WebSecurity.Module && x.datecreated >= _dateFrom && x.datecreated <= _dateto).ToList();
                        
                        using (var transaction = _context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                        {
                            try
                            {
                                foreach (var item in trans)
                                {
                                    var payDetails = _context.ac_rctdetails.Where(x => x.rct_number == item.rcth_number).ToList();
                                    foreach (var payDetail in payDetails)
                                    {
                                        var pol = new PolicySystem(_context).FindAll(x => x.policyno == payDetail.rct_code).FirstOrDefault();
                                        if (pol != null)
                                        {
                                            var translog = new fl_translog();
                                            translog.amount = payDetail.rct_credit;
                                            translog.bank_ledger = payDetail.rct_bank;
                                            translog.income_ledger = payDetail.rct_account;
                                            //translog.Instrument = xInstr;
                                            //translog.paymentmethod = xPaymethod;
                                            translog.policyno = payDetail.rct_code;
                                            translog.remark = payDetail.rct_remark;
                                            translog.trandate = payDetail.datecreated;
                                            recieptno = payDetail.rct_number;
                                            translog.receiptno = recieptno;
                                            translog.poltype = item.rcth_unitcode;
                                            new CoreSystem<fl_translog>(_context).Save(translog);

                                            var payinput = new fl_payinput();

                                            payinput.amount = payDetail.rct_credit;
                                            payinput.chequeno = item.rcth_cheque;
                                            payinput.datecreated = DateTime.Now;
                                            payinput.grpcode = pol.grpcode;
                                            payinput.policyno = payDetail.rct_code;
                                            payinput.poltype = pol.poltype;
                                            payinput.receiptno = recieptno;
                                            payinput.totamt = payDetail.rct_credit;
                                            payinput.type = item.rcth_type.ToString();
                                            payinput.trandate = payDetail.datecreated;

                                            new CoreSystem<fl_payinput>(_context).Save(payinput);

                                            var payhis = new fl_payhistory();
                                            payhis.amount = amt;
                                            payhis.grpcode = pol.grpcode;
                                            payhis.orig_date = DateTime.Now;
                                            payhis.policyno = payDetail.rct_code;
                                            payhis.receiptno = recieptno;
                                            payhis.trandate = DateTime.Now;
                                            //payhis.doctype = xInstr.ToString();
                                            payhis.period = payDetail.datecreated.GetValueOrDefault().ToString("yyyy") + "00";
                                            payhis.poltype = pol.poltype;
                                            payhis.trandate = payDetail.datecreated;

                                            new CoreSystem<fl_payhistory>(_context).Save(payhis);
                                        }
                                    }
                                }

                                transaction.Commit();

                                return new JsonResult()
                                {
                                    Data = "Payment Update Successful"
                                };
                                //return RedirectToAction("Listing");

                            }
                            catch (Exception ex)
                            {
                                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                                transaction.Rollback();
                                throw;
                            }
                        }

                    }

                }
                else
                {
                    throw new Exception("Invalid Data");
                }
                return View();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult DownloadExcel(QueryModel query = null)
        {
            //var drp = db.draftingReports.Where(d => d.batchnumber == batchno).ToList();
            using (var _context = context)
            {
                var paylist = new List<rptPaymentList>();
                var paymentLists = new CoreSystem<fl_payinput>(_context).FindAll(x => x.reverseind == false)
               .ToList();
                if (query == null)
                {
                    return RedirectToAction("Agents");
                }
                ExcelPackage.LicenseContext = LicenseContext.NonCommercial;
                ExcelPackage pck = new ExcelPackage();
                ExcelWorksheet wk = pck.Workbook.Worksheets.Add("Report");


                wk.Cells["A3"].Value = "Date";
                wk.Cells["B3"].Value = string.Format("{0:dd mm yyyy} at {0:H: mm tt}", DateTimeOffset.Now);

                wk.Cells["A4"].Value = "Receipt No";
                wk.Cells["B4"].Value = "Policy";
                wk.Cells["C4"].Value = "Trans Date";
                wk.Cells["D4"].Value = "Cheque No";
                wk.Cells["E4"].Value = "Amount";
                //wk.Cells["F4"].Value = "DOJ";
                //wk.Cells["G4"].Value = "Authority";
                //wk.Cells["H4"].Value = "Drafted To";
                //wk.Cells["I4"].Value = "WEF";
                //wk.Cells["J4"].Value = "Deployment/Vice";
                //wk.Cells["K4"].Value = "remark";

                int rowstart = 5;
                foreach (var item in paymentLists)
                {
                    //if (item.reverseind != null)
                    //{
                        wk.Row(rowstart).Style.Fill.PatternType = OfficeOpenXml.Style.ExcelFillStyle.None;
                        // wk.Row(rowstart).Style.Fill.BackgroundColor.SetColor(ColorTranslator.FromHtml(string.Format("white")));
                    //}
                    wk.Cells[(string.Format("A{0}", rowstart))].Value = item.receiptno;
                    wk.Cells[(string.Format("B{0}", rowstart))].Value = item.policyno;
                    wk.Cells[(string.Format("C{0}", rowstart))].Value = item.trandate;
                    wk.Cells[(string.Format("D{0}", rowstart))].Value = item.chequeno;
                    wk.Cells[(string.Format("E{0}", rowstart))].Value = item.amount;
                    //wk.Cells[(string.Format("F{0}", rowstart))].Value = string.Format("{0:dd/MM/yyyy}", item.DOJ);
                    //wk.Cells[(string.Format("G{0}", rowstart))].Value = item.signalCode;
                    //wk.Cells[(string.Format("H{0}", rowstart))].Value = item.newdepartmentName;
                    //wk.Cells[(string.Format("I{0}", rowstart))].Value = item.reportdate;
                    //wk.Cells[(string.Format("J{0}", rowstart))].Value = "COMPLEMENT";
                    //wk.Cells[(string.Format("I{0}", rowstart))].Value = item.request;
                    rowstart++;

                }
                wk.Cells["A:AZ"].AutoFitColumns();
                Response.Clear();
                Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                Response.AddHeader("content-disposition", "attachment: filename=" + "ExcelReport.xlsx");
                Response.BinaryWrite(pck.GetAsByteArray());
                Response.End();
                //return View();
                return ExportReport(Response.ContentType);
            }
            return View();
            //return PartialView("_paymentListLayout");
        }
    }
}