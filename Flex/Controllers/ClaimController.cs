using Flex.Business;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using Flex.Models.ReportModel;
using Flex.Util;
using Flex.Utility.Utils;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Flex.Controllers
{
    public class ClaimController : ContainerController
    {
        // GET: Claim

        public ActionResult ClaimRequest()
        {
            try
            {
                var claims = new ClaimSystem(context).RetrieveAllClaimRequest(DateTime.Today.AddDays(-30).ToShortDateString()
                    , DateTime.Today.ToShortDateString());
                return PartialView("_claimRequest", claims);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SearchClaim(string sdate, string edate)
        {
            var clms = new ClaimSystem(context).RetrieveAllClaimRequest(sdate, edate);
            return PartialView("_tbclmReq", clms);
        }

        public ActionResult ClaimProcess(string id, string processingType)
        {
            try
            {
                var Id = 0L;
                Int64.TryParse(id, out Id);
                var clm = new CoreSystem<ClaimRequest>(context).FindAll(x => x.Id == Id).FirstOrDefault();
                if (clm != null)
                {
                    if (processingType.Equals("disapprove", StringComparison.InvariantCultureIgnoreCase))
                    {
                        clm.Status = (Status)ClaimStatus.Disapproved;
                        new CoreSystem<ClaimRequest>(context).Update(clm, Id);
                    }
                    else 
                    {
                        if (processingType.Equals("approve", StringComparison.InvariantCultureIgnoreCase) && clm.Status != (Status)ClaimStatus.Processing)
                        {
                            throw new Exception("Claim must be processed before approval");
                        }
                        var pol = new PolicySystem(context).FindAll(x => x.policyno == clm.PolicyNo).FirstOrDefault();
                        string policyName = string.Format("{0} {1}../{2}", pol.surname, pol.othername, pol.policyno);

                        ViewBag.PolicyName = policyName;
                        if (processingType.Equals("pay",StringComparison.InvariantCultureIgnoreCase))
                        {
                            ViewBag.paymentMethods = GetPaymentMethods();
                        }
                        if (processingType.Equals("process", StringComparison.InvariantCultureIgnoreCase))
                            return PartialView("_claimProcess", clm);
                        else if (processingType.Equals("approve", StringComparison.InvariantCultureIgnoreCase))
                            return PartialView("_claimApproval", clm);
                        else
                            return PartialView("_claimPayInput", clm);
                    }
                }

                return RedirectToAction("ClaimRequest");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult ProcessClaim(string query)
        {
            try
            {
                var model = JsonConvert.DeserializeObject<dynamic>(query);
                string cType = model.clmType;
                var clmType = (ClaimType)Enum.Parse(typeof(ClaimType), cType);
                var intrest = 0.0M;
                var amt = 0.0M;
                var Id = 0L;
                string eDate = model.effDate;
                string amount = model.amount;
                string intr = model.intr;
                string id = model.Id;
                DateTime effDate = SqlDateTime.MinValue.Value;
                DateTime.TryParse(eDate, out effDate);
                Int64.TryParse(id, out Id);

                decimal.TryParse(amount, out amt);
                decimal.TryParse(intr, out intrest);
                string policyno = model.policyno;
                var clmReq = new ClaimRequest();
                

                var clm = new List<rptClaim>();
                var pol = new CoreSystem<vwPolicy>(context).FindAll(x => x.policyno == policyno).FirstOrDefault();
                var availFunds = new InterestSystem(context).CalculateInterest(policyno, intrest, effDate);
                clm= availFunds.Select(x => new rptClaim()
                    {
                        Agent = pol.agentname,
                        Amount = x.Amount,
                        Interest = x.Interest,
                        Location = pol.locdesc,
                        OtherNames = pol.othername,
                        PolicyNo = policyno,
                        ReceiptNo = x.ReceiptNo,
                        Surname = pol.surname,
                        TransDate = DateTime.Parse(x.TransDate)
                    }).ToList();

                if (!string.IsNullOrEmpty(id))
                {
                    clmReq = new CoreSystem<ClaimRequest>(context).Get(Id);
                    clmReq.Interest = intrest;
                    clmReq.FundAmount = clm.Sum(x => x.Total);
                    clmReq.Status = (Status)ClaimStatus.Processing;

                    new CoreSystem<ClaimRequest>(context).Update(clmReq, Id);
                }
                else
                {
                    clmReq.Amount = amt;
                    clmReq.ClaimType = clmType;
                    clmReq.DateCreated = DateTime.Now;
                    clmReq.EffectiveDate = effDate;
                    clmReq.PolicyNo = policyno;
                    clmReq.Interest = intrest;
                    clmReq.FundAmount = clm.Sum(x => x.Total);
                    clmReq.Status = (Status)ClaimStatus.Processing;

                    new CoreSystem<ClaimRequest>(context).Save(clmReq);
                }

                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;
                var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.ClaimStatement);
              
                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                var datefromparams = new KeyValuePair<string, string>("input1", effDate.ToString("yyyy-MM-dd"));
                rparams.Add(datefromparams);

                rpt.Parameter = rparams;

                rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                var savedir = Server.MapPath(ConfigUtils.ReportPath);
                var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                rpt.ReportName = Path.Combine(savedir, reportName);
                rpt.GenerateReport(clm);
                //var contentType =  "application/pdf";
                return ExportReport(reportName);

            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult ApproveClaim(string query)
        {
            try
            {
                var model = JsonConvert.DeserializeObject<dynamic>(query);
                string cType = model.clmType;
                var clmType = (ClaimType)Enum.Parse(typeof(ClaimType), cType);
                var intrest = 0.0M;
                var amt = 0.0M;
                var approvedAmt = 0.0M;
                var Id = 0L;
                string eDate = model.effDate;
                string amount = model.amount;
                string intr = model.intr;
                string id = model.Id;
                string apprvamt = model.apprvAmt;
                DateTime effDate = SqlDateTime.MinValue.Value;
                DateTime.TryParse(eDate, out effDate);
                Int64.TryParse(id, out Id);

                decimal.TryParse(amount, out amt);
                decimal.TryParse(intr, out intrest);
                decimal.TryParse(apprvamt, out approvedAmt);

                string policyno = model.policyno;

                var clmReq = new CoreSystem<ClaimRequest>(context).Get(Id);

                var clm = new List<rptClaim>();
                //var pol = new CoreSystem<vwPolicy>(context).FindAll(x => x.policyno == policyno).FirstOrDefault();
                var pol = new CoreSystem<fl_policyinput>(context).FindAll(x => x.policyno == policyno).FirstOrDefault();

                int sn = UtilitySystem.GetNextSerialNumber(context, SerialNoCountKey.CM);
                var ClaimNo = new UtilitySystem().GenerateRef(pol.poltype, sn);

                clm.Add(new rptClaim()
                {
                    Agent = pol.agentcode,
                    Amount = approvedAmt,
                    //Location = pol.location,
                    OtherNames = pol.othername,
                    PolicyNo = pol.policyno,
                    ReceiptNo = ClaimNo,
                    Surname = pol.surname,
                    TransDate = (DateTime)clmReq.EffectiveDate
                });


                clmReq.Status = (Status)ClaimStatus.Approved;
                clmReq.ApprovedAmount = approvedAmt;
                clmReq.ClaimNo = ClaimNo;

                new CoreSystem<ClaimRequest>(context).Update(clmReq, Id);

                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;
                var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.ClaimApproval);

                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                rpt.Parameter = rparams;

                rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                var savedir = Server.MapPath(ConfigUtils.ReportPath);
                var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                rpt.ReportName = Path.Combine(savedir, reportName);
                rpt.GenerateReport(clm);
                //var contentType =  "application/pdf";
                return ExportReport(reportName);

            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult Calculation()
        {
            GetClaimType();
            var user = WebSecurity.GetCurrentUser(Request);
            //var pols = user.CustomerUser.CustomerPolicies.ToList();
            //ViewBag.Policy = new SelectList(pols, "Policyno", "Policyno");

            return PartialView("_addClaim");

        }
        public ActionResult Payment()
        {
            var approvedClaims = new CoreSystem<ClaimRequest>(context).FindAll(x => x.Status == (Status)ClaimStatus.Approved).ToList();
            return PartialView("_claimPayment",approvedClaims);
        }

        public ActionResult SearchClaimPay(string sdate, string edate, string policyno, string claimno)
        {
            try
            {
                var clms = new ClaimSystem(context).RetrieveAllClaimPendingPayment(sdate, edate,policyno,claimno);
                return PartialView("_tbclmPayments", clms);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult PayClaim(string query)
        {
            try
            {
                var model = JsonConvert.DeserializeObject<dynamic>(query);
                var amt = 0.0M;
                var Id = 0L;
                string eDate = model.effDate;
                string amount = model.amount;
                string intr = model.intr;
                string id = model.Id;
                DateTime effDate = SqlDateTime.MinValue.Value;
                DateTime.TryParse(eDate, out effDate);
                Int64.TryParse(id, out Id);

                decimal.TryParse(amount, out amt);
                string policyno = model.policyno;
                string claimno = model.claimno;
                string paymethod = model.PaymentMethod;
                string refno = model.refno;

                var paymentMethod = (PaymentMethod)Enum.Parse(typeof(PaymentMethod), paymethod);
                var clmReq = new CoreSystem<ClaimRequest>(context).Get(Id);

                var pol = new PolicySystem(context).FindAll(x => x.policyno == policyno).FirstOrDefault();
                if (pol==null)
                {
                    throw new Exception("Invalid policy number");
                }
                var pyctrl = new CoreSystem<fl_receiptcontrol>(context).FindAll(x => x.fl_poltype.poltype == pol.poltype
                        && x.PaymentMethod == paymentMethod).FirstOrDefault();
                if (pyctrl == null)
                {
                    throw new Exception(string.Format("Account has not been set up for policytype {0} with payment method {1} "
                        , pol.poltype, paymentMethod));
                }
                using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                {
                    try
                    {
                        var recieptno = string.Empty;
                        int sn = UtilitySystem.GetNextSerialNumber(context, SerialNoCountKey.PV);
                        recieptno = new UtilitySystem().GenerateRef(pol.poltype, sn);

                        var translog = new fl_translog();

                        var rem = clmReq.ClaimType == ClaimType.FullWithdrawal ? "Full Withdral" : "Partial Withdrwal";

                        var remark = string.Format("{0} on Policy {1}", rem, policyno);
                        translog.amount = -1 * amt;
                        translog.bank_ledger = pyctrl.Bank_ledger;
                        translog.chequeno = refno;
                        translog.income_ledger = pyctrl.Income_ledger;
                        translog.Instrument = Instrument.PaymentVoucher;
                        translog.paymentmethod = paymentMethod;
                        translog.policyno = policyno;
                        translog.receiptno = recieptno;
                        translog.remark = remark;
                        translog.trandate = DateTime.Now;

                        new CoreSystem<fl_translog>(context).Save(translog);

                        var payinput = new fl_payinput();

                        payinput.totamt=payinput.amount = -1 * amt;
                        payinput.chequeno = refno;
                        payinput.trandate=payinput.datecreated = DateTime.Now;
                        payinput.grpcode = pol.grpcode;
                        payinput.policyno = policyno;
                        payinput.poltype = pol.poltype;
                        payinput.receiptno = recieptno;
                        payinput.type = Instrument.PaymentVoucher.ToString();
                        payinput.createdby = WebSecurity.CurrentUser(Request);

                        new CoreSystem<fl_payinput>(context).Save(payinput);

                        var payhis = new fl_payhistory();
                        payhis.amount = -1 * amt;
                        payhis.grpcode = pol.grpcode;
                        payhis.orig_date = DateTime.Now;
                        payhis.policyno = policyno;
                        payhis.receiptno = recieptno;
                        payhis.trandate = DateTime.Now;
                        payhis.doctype = Instrument.PaymentVoucher.ToString();
                        payhis.period = DateTime.Today.ToString("yyyyMM");
                        payhis.poltype = pol.poltype;

                        new CoreSystem<fl_payhistory>(context).Save(payhis);

                        if (clmReq.ClaimType == ClaimType.FullWithdrawal)
                        {
                            var pClaim = new CoreSystem<fl_payhistory>(context).FindAll(x => x.policyno == policyno).ToList();
                            foreach (var pc in pClaim)
                            {
                                var flPclaim = new fl_payclaim();
                                flPclaim.amount = pc.amount;
                                flPclaim.cumuldep_intr = pc.cumuldep_intr;
                                flPclaim.cumul_intr = pc.cumul_intr;
                                flPclaim.curdep_intr = pc.curdep_intr;
                                flPclaim.cur_intr = pc.cur_intr;
                                flPclaim.deposit = pc.deposit;
                                flPclaim.doctype = pc.doctype.ToString();
                                flPclaim.gir = pc.gir;
                                flPclaim.grpcode = pc.grpcode;
                                flPclaim.loanamt = pc.loanamt;
                                flPclaim.openbalance = pc.openbalance;
                                flPclaim.opendeposit = pc.opendeposit;
                                flPclaim.orig_date = pc.orig_date;
                                flPclaim.period = pc.period;
                                flPclaim.policyno = pc.policyno;
                                flPclaim.poltype = pc.poltype;
                                flPclaim.receiptno = pc.receiptno;
                                flPclaim.trandate = pc.trandate;
                                new CoreSystem<fl_payclaim>(context).Save(flPclaim);
                            }

                            pol.exitdate = DateTime.Today.ToString("yyyyMMdd");
                            pol.status = (int)Status.Exited;

                            new CoreSystem<fl_policyinput>(context).Update(pol, pol.srn);
                        }

                        clmReq.Status = (Status)ClaimStatus.Paid;
                        new CoreSystem<ClaimRequest>(context).Update(clmReq, clmReq.Id);
                        transaction.Commit();
                    }
                    catch (Exception)
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
                return new JsonResult()
                {
                    Data = string.Format("Claim Payment for Policy No. {0} with Claim No. {1} completed successfully", policyno,claimno)
                };
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }

        }

        public ActionResult Report()
        {
            var exitedpolicies = new CoreSystem<fl_policyinput>(context).FindAll(x => x.status == (int)Status.Exited)
                .Select(x=> new PolBindingModel() {
                    OtherName=x.othername,
                    PolicyNo=x.policyno,
                    Surname=x.surname
                }).ToList();

            ViewBag.PolicyNo = new SelectList(exitedpolicies, "PolicyNo", "PolicyName");
            return PartialView("_clmReport");
        }

        [HttpPost]
        public ActionResult ClaimReport(string query)
        {
            try
            {
                var model = JsonConvert.DeserializeObject<dynamic>(query);

                var rptType = model.rptType;
                var intrest = 0.0M;
                var amt = 0.0M;
                var Id = 0L;
                string eDate = model.eDate;
                string sDate = model.sDate;
                string summary = model.rptSummary;
                string policyno = model.policyno;
                DateTime datefrom = SqlDateTime.MinValue.Value;
                DateTime dateto = SqlDateTime.MinValue.Value;

                if (!string.IsNullOrEmpty(sDate))
                {
                    DateTime.TryParse(sDate, out datefrom);
                }
                if (!string.IsNullOrEmpty(eDate))
                {
                    DateTime.TryParse(eDate, out dateto);
                }
                IList<rptClaim> clmStmt = null;
                if (rptType=="Single")
                {
                    var pol = new CoreSystem<vwPolicy>(context).FindAll(x => x.policyno == policyno).FirstOrDefault();
                    var clms = new CoreSystem<fl_payclaim>(context).FindAll(x => x.policyno == policyno).ToList();
                    clmStmt=clms
                        .Select(x=> new rptClaim() {
                            Agent=pol.agentname,
                            Amount=x.amount.GetValueOrDefault(),
                            Interest= x.cumul_intr.GetValueOrDefault(),
                            Location=pol.locdesc,
                            OtherNames=pol.othername,
                            PolicyNo=x.policyno,
                            ReceiptNo=x.receiptno,
                            Surname=pol.surname,
                            Title=pol.title,
                            TransDate= (DateTime)x.orig_date
                        }).ToList();
                }
                else
                {
                    var xdateto = dateto.ToString("yyyyMMdd");
                    var xdatefrom = datefrom.ToString("yyyyMMdd");

                    var exitedpols = new CoreSystem<vwPolicy>(context).FindAll(x=> !string.IsNullOrEmpty(x.exitdate)).ToList();
                    if (!string.IsNullOrEmpty(sDate) && !string.IsNullOrEmpty(eDate))
                    {
                        exitedpols=exitedpols.Where(x =>  DateTime.ParseExact(x.exitdate, "yyyyMMdd", CultureInfo.InvariantCulture) >= datefrom
                     && DateTime.ParseExact(x.exitdate ?? string.Empty, "yyyyMMdd", CultureInfo.InvariantCulture) <= dateto).ToList();
                    }
                    
                    var exitedpolicynos = exitedpols.Select(x => x.policyno).ToList();

                    if (string.IsNullOrEmpty(summary))
                    {
                        var clm = new CoreSystem<fl_payclaim>(context).FindAll(x => exitedpolicynos.Contains(x.policyno)).ToList();
                        clmStmt=clm
                        .Select(x => new rptClaim()
                        {
                            Agent = exitedpols.Where(y=>y.policyno==x.policyno).FirstOrDefault().agentname,
                            Amount = (decimal)x.amount.GetValueOrDefault(),
                            Interest = (decimal)x.cumul_intr.GetValueOrDefault(),
                            Location = exitedpols.Where(y => y.policyno == x.policyno).FirstOrDefault().locdesc,
                            OtherNames = exitedpols.Where(y => y.policyno == x.policyno).FirstOrDefault().othername,
                            PolicyNo = x.policyno,
                            ReceiptNo = x.receiptno,
                            Surname = exitedpols.Where(y => y.policyno == x.policyno).FirstOrDefault().surname,
                            Title = exitedpols.Where(y => y.policyno == x.policyno).FirstOrDefault().title,
                            TransDate = (DateTime)x.orig_date.GetValueOrDefault()
                        }).ToList();
                    }
                    else
                    {
                        var clm = new CoreSystem<ClaimRequest>(context).FindAll(x => exitedpolicynos.Contains(x.PolicyNo) &&
                                  x.EffectiveDate >= datefrom && x.EffectiveDate <= dateto && x.ClaimType==ClaimType.FullWithdrawal).ToList();
                        clmStmt=clm.Select(x => new rptClaim()
                                {
                                    PolicyNo = x.PolicyNo,
                                    Amount = (decimal)x.ApprovedAmount,
                                    ExitDate = DateTime.ParseExact(exitedpols.Where(y => y.policyno == x.PolicyNo).FirstOrDefault().exitdate
                                    , "yyyyMMdd", CultureInfo.InvariantCulture),
                                    OtherNames = exitedpols.Where(y => y.policyno == x.PolicyNo).FirstOrDefault().othername,
                                    Surname = exitedpols.Where(y => y.policyno == x.PolicyNo).FirstOrDefault().surname,

                                }).ToList();
                    }

                }



                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;
                var rptdir = string.Empty;
                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                KeyValuePair<string, string> datefromparams;
                KeyValuePair<string, string> datetoparams;

                if (string.IsNullOrEmpty(summary))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.ClaimStatement);
                    datefromparams = new KeyValuePair<string, string>("input1", DateTime.Now.ToString("yyyy-MM-dd"));
                    rparams.Add(datefromparams);

                    rpt.Parameter = rparams;
                }
                else
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.ClaimSummary);
                    datefromparams = new KeyValuePair<string, string>("input1", datefrom.ToString("yyyy-MM-dd"));
                    rparams.Add(datefromparams);
                    datetoparams = new KeyValuePair<string, string>("input2", dateto.ToString("yyyy-MM-dd"));
                    rparams.Add(datetoparams);

                }

                rpt.Parameter = rparams;

                rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                var savedir = Server.MapPath(ConfigUtils.ReportPath);
                var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                rpt.ReportName = Path.Combine(savedir, reportName);
                rpt.GenerateReport(clmStmt);
                //var contentType =  "application/pdf";
                return ExportReport(reportName);

            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult ClaimDate()
        {
            GetClaimStatus((int)ClaimStatus.Paid);
            return PartialView("_claimwithDateRange");
        }

        [HttpPost]
        public ActionResult ClaimDate(string query)
        {
            try
            {
                var model = JsonConvert.DeserializeObject<dynamic>(query);

                string withdrawal = model.withdrawal;
                string eDate = model.eDate;
                string sDate = model.sDate;
                string claimStatus = model.claimStatus;
                DateTime datefrom = SqlDateTime.MinValue.Value;
                DateTime dateto = SqlDateTime.MinValue.Value;
                CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

                ClaimType xwithdrawal = ClaimType.PartialWithdrawal;
                ClaimStatus xclaimStatus = ClaimStatus.Paid;
                if (!string.IsNullOrEmpty(sDate))
                {
                    DateTime.TryParse(sDate, out datefrom);
                }
                if (!string.IsNullOrEmpty(eDate))
                {
                    DateTime.TryParse(eDate, out dateto);
                    dateto = Convert.ToDateTime(dateto, culInfo).Date.AddDays(1).AddSeconds(-1);
                }
                if (!string.IsNullOrEmpty(withdrawal))
                {
                    xwithdrawal = (ClaimType)Enum.Parse(typeof(ClaimType), withdrawal);
                }
                if (!string.IsNullOrEmpty(claimStatus))
                {
                    xclaimStatus = (ClaimStatus)Enum.Parse(typeof(ClaimStatus), claimStatus);
                }
                IList<rptClaim> clmrpt = new List<rptClaim>();

                var clm = new CoreSystem<ClaimRequest>(context).FindAll(x => x.EffectiveDate >= datefrom && x.EffectiveDate <= dateto
                             && x.ClaimType == xwithdrawal && x.Status==(Status)xclaimStatus).ToList();
                if (clm !=null && clm.Any())
                {
                    foreach (var item in clm)
                    {
                        var crpt = new rptClaim();
                        var pol = new CoreSystem<vwPolicy>(context).FindAll(x=>x.policyno==item.PolicyNo).FirstOrDefault();
                        crpt.Agent = pol.agentname;
                        crpt.Amount = item.ApprovedAmount.GetValueOrDefault();
                        if (!string.IsNullOrEmpty(pol.exitdate))
                        {
                            crpt.ExitDate = DateTime.ParseExact(pol.exitdate, "yyyyMMdd", CultureInfo.InvariantCulture);
                        }

                        crpt.OtherNames = pol.othername;
                        crpt.PolicyNo = pol.policyno;
                        crpt.Surname = pol.surname;
                        crpt.Title = pol.title;

                        clmrpt.Add(crpt);
                    }
                }
                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;
                var rptdir = string.Empty;
                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                KeyValuePair<string, string> datefromparams;
                KeyValuePair<string, string> datetoparams; KeyValuePair<string, string> statusparams;

                rptdir = ReportUtil.GetConfig(ReportUtil.Constants.ClaimDateRange);
                datefromparams = new KeyValuePair<string, string>("input1", datefrom.ToString("yyyy-MM-dd"));
                rparams.Add(datefromparams);
                datetoparams = new KeyValuePair<string, string>("input2", dateto.ToString("yyyy-MM-dd"));
                rparams.Add(datetoparams);
                statusparams = new KeyValuePair<string, string>("input3", xclaimStatus.ToString());
                rparams.Add(statusparams);

                rpt.Parameter = rparams;

                rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                var savedir = Server.MapPath(ConfigUtils.ReportPath);
                var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                rpt.ReportName = Path.Combine(savedir, reportName);
                rpt.GenerateReport(clmrpt);
                //var contentType =  "application/pdf";
                return ExportReport(reportName);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult PolicyReactivation() 
        {
            var exitpols = new PolicySystem(context).FindAll(x => x.status == (int)Status.Exited).ToList();
            List<PolBindingModel> exPols = new List<PolBindingModel>();
            if (exitpols != null && exitpols.Any())
            {
                exPols = exitpols.Select(x => new PolBindingModel()
                {
                    PolicyNo = x.policyno,
                    OtherName = x.othername,
                    Surname = x.surname
                }).ToList();
            }
            ViewBag.Policy = new SelectList(exPols, "PolicyNo", "PolicyName");

            return PartialView("_policyReactivation");
        }

        [HttpPost]
        public ActionResult PolicyReactivation(string policyno)
        {
            try
            {
                var pol = new PolicySystem(context).FindAll(x => x.policyno == policyno).FirstOrDefault();
                if (pol == null)
                {
                    throw new Exception("Invalid Policy Number");
                }
                using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                {
                    pol.status = (int)Status.Active;
                    pol.exitdate = string.Empty;

                    new PolicySystem(context).Update(pol, pol.srn);

                    var clmreq = new CoreSystem<ClaimRequest>(context).FindAll(x => x.PolicyNo == policyno && x.ClaimType == ClaimType.FullWithdrawal).FirstOrDefault();

                    if (clmreq != null)
                    {
                        clmreq.Status = (Status)ClaimStatus.Canceled;

                        new CoreSystem<ClaimRequest>(context).Update(clmreq, clmreq.Id);
                    }
                    transaction.Commit();
                }

                return new JsonResult()
                {
                    Data = string.Format("Policy [{0}] Reactivated Successfully", policyno)
                };
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
    }
}