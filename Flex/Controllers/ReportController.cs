using Flex.Business;
using Flex.Controllers.Util;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Models.ReportModel;
using Flex.Util;
using Flex.Utility.Utils;
using Microsoft.Ajax.Utilities;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlTypes;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

namespace Flex.Controllers
{
    public class ReportController : ContainerController
    {
        // GET: Report
        public ActionResult MemberRegister()
        {
            ViewBag.Agents = GetAgents();
            ViewBag.Location = GetLocations();
            return PartialView("_memberRegister");
        }

        [HttpPost]
        public ActionResult MemberResgister(string queryj)
        {
            try
            {
                var query = JsonConvert.DeserializeObject<dynamic>(queryj);
                string sdate = query.sDate;
                string edate = query.eDate;
                string type = query.type;
                string agent = query.Agent;
                string branch = query.Location;
                var status = string.Empty;

                if (new string[] { "All", "Active", "Withdrawn" }.Contains(type))
                {
                    status = type;
                }

                var _location = 0;
                int.TryParse(branch, out _location);
                var members = new PolicySystem(context).GetMembers(sdate, edate, status,agent,_location);
                var memRepList= members.Select(x => new rptMembers() {
                    AcceptDate = ((DateTime)x.accdate).ToShortDateString(),
                    ExitDate = !string.IsNullOrEmpty(x.exitdate)? (DateTime.ParseExact(x.exitdate, "yyyyMMdd", CultureInfo.InvariantCulture)).ToString("dd/MM/yyyy"): string.Empty,
                    Name = string.Concat(x.surname, " ", x.othername),
                    PolicyNo = x.policyno,
                    Title = x.title,
                    AgentCode = x.agentcode,
                    AgentName = !string.IsNullOrEmpty(x.agentcode) ? new CoreSystem<fl_agents>(context).FindAll(y => y.agentcode == x.agentcode).FirstOrDefault().agentname : string.Empty,
                    //Location=x.fl_location.loccode
                }).ToList();
                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;
                var rptdir = string.Empty;
                if (type.Equals("agent", StringComparison.InvariantCultureIgnoreCase))
                {
                   rptdir = ReportUtil.GetConfig(ReportUtil.Constants.MemberListByAgent);
                }
                else if(type.Equals("branch", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.MemberListByLocation);
                }
                else
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.MemberList);
                }
                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                rpt.Parameter = rparams;
                rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                var savedir = Server.MapPath(ConfigUtils.ReportPath);
                var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                rpt.ReportName = Path.Combine(savedir, reportName);
                rpt.GenerateReport(memRepList);
                //var contentType =  "application/pdf";
                return ExportReport(reportName);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult Statment()
        {
            return PartialView("_stmtAcct");
        }

        [HttpPost]
        public ActionResult PrintStatment(string queryj)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var query = JsonConvert.DeserializeObject<dynamic>(queryj);
                string date = query.Date;
                string policy = query.Policy;
                var _interest = query.Interest.ToString();

                decimal interest = 0.00M;
                decimal.TryParse(_interest, out interest);

                var stmt = new PaymentSystem(context).Statement(date, policy);

                rptStatement rptstmtOpenBal = null;
                var xDate = SqlDateTime.MinValue.Value;
                DateTime.TryParse(date, out xDate);
                xDate = Convert.ToDateTime(xDate, culInfo).Date;

                var lastyr = string.Concat((xDate.Year - 1).ToString(), "1231");
                var thisyr= string.Concat(xDate.Year.ToString(), "0101");

                var closeDate = DateTime.ParseExact(lastyr, "yyyyMMdd", CultureInfo.InvariantCulture);
                var opendate = DateTime.ParseExact(thisyr, "yyyyMMdd", CultureInfo.InvariantCulture);
                var openBaltrans = stmt.Where(x => x.trandate <= closeDate);

                List<rptStatement> stmts = new List<rptStatement>();
                if (openBaltrans.Any())
                {
                    rptstmtOpenBal = new rptStatement()
                    {
                        Amount = (Decimal)openBaltrans.Sum(x => x.amount).GetValueOrDefault(),
                        Date = opendate.ToString("dd/MM/yyyy"),
                        Interest = (Decimal)openBaltrans.Sum(x => x.cumul_intr).GetValueOrDefault(),
                        Location = openBaltrans.FirstOrDefault().locdesc,
                        Name = openBaltrans.FirstOrDefault().Name,
                        PolicyNo = openBaltrans.FirstOrDefault().policyno,
                        ReceiptNo = "OpenBal",
                        RefNo = !string.IsNullOrEmpty(openBaltrans.FirstOrDefault().doctype.ToString()) ? ((Instrument)Enum.Parse(typeof(Instrument), openBaltrans.FirstOrDefault().doctype.ToString())).ToString()  : "",
                    };
                }

                if (rptstmtOpenBal != null)
                {
                    stmts.Add(rptstmtOpenBal);
                }

                var currentTrans = stmt.Where(x => x.trandate >= opendate).Select(x=> new rptStatement() {
                    Amount = (Decimal)x.amount.GetValueOrDefault(),
                    Date = ((DateTime)x.trandate).ToString("dd/MM/yyyy"),
                    Interest = x.gir != 0 ? x.cumul_intr.GetValueOrDefault() : CalculateInterest(x.amount.GetValueOrDefault(),x.orig_date.GetValueOrDefault(),interest, xDate),
                    Location = x.locdesc,
                    Name = x.Name,
                    PolicyNo = x.policyno,
                    ReceiptNo = x.receiptno,
                    RefNo = !string.IsNullOrEmpty(x.doctype) ? ((Instrument)Enum.Parse(typeof(Instrument), x.doctype)).ToString() : "",
                }).ToList();
                stmts.AddRange(currentTrans);
                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;
                var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.Statement);

                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                rparams.Add(new KeyValuePair<string, string>("Date", date));
                rpt.Parameter = rparams;
                rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                var savedir = Server.MapPath(ConfigUtils.ReportPath);
                var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                rpt.ReportName = Path.Combine(savedir, reportName);
                rpt.GenerateReport(stmts);
                //var contentType = "application/pdf";

                return ExportReport(reportName);
                //return new ReportFileActionResult(rpt.streamProduct, rpt.ReportName, contentType);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        private decimal CalculateInterest(decimal Amount, DateTime TransDate, decimal Rate, DateTime StatementDate)
        {
            var interest = 0.00M;

            var days = StatementDate.Subtract(TransDate).Days;
            var totalDays = DateTime.IsLeapYear(StatementDate.Year) ? 366 : 365;

            interest = (Amount * Rate * days) / (totalDays * 100);

            return interest;
        }
        public ActionResult Investment()
        {
            return PartialView("_invHis");
        }

        [HttpPost]
        public ActionResult Investment(string queryj)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var query = JsonConvert.DeserializeObject<dynamic>(queryj);
                string sdate = query.sDate;
                string eDate = query.eDate;
                string policyno = query.Policy;
                string option = query.option;
                var rptdir = "";


                List<rptInvestmentHistory> invHis = new List<rptInvestmentHistory>();
                if (option== "RctHistory")
                {
                    invHis = new PaymentSystem(context).ReceiptHistory(policyno, sdate, eDate, option).Select(x=> new rptInvestmentHistory() {
                        Amount=(decimal)x.amount.GetValueOrDefault(),
                        Cumul_Intr=(decimal)x.cumul_intr.GetValueOrDefault(),
                        Cur_Intr=(decimal)x.cur_intr.GetValueOrDefault(),
                        Date=(DateTime)x.trandate.GetValueOrDefault(),
                        Gir=Convert.ToDecimal(x.gir.GetValueOrDefault()),
                        PolicyNo=x.policyno,
                        ReceiptNo=x.receiptno
                    }).ToList();

                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.InvHistory);
                }
                else if (option == "RctValue")
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.RctValue_Rct);

                    invHis = new PaymentSystem(context).ReceiptCurrentValue(policyno, sdate, eDate, option).Select(x => new rptInvestmentHistory()
                    {
                        Amount = (decimal)x.amount.GetValueOrDefault(),
                        Cumul_Intr = (decimal)x.cumul_intr.GetValueOrDefault(),
                        Cur_Intr = (decimal)x.cur_intr.GetValueOrDefault(),
                        Date = (DateTime)x.trandate.GetValueOrDefault(),
                        Gir = Convert.ToDecimal(x.gir),
                        PolicyNo = x.policyno,
                        ReceiptNo = x.receiptno,
                        Name=x.Name,
                        OrigDate=x.orig_date.GetValueOrDefault().ToString("dd/MM/yyyy"),
                        Remark="",
                        Title=x.title
                    }).ToList();
                }
                else if (option == "PolicyValue")
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.PolCurrentValue);

                    invHis = new PaymentSystem(context).ReceiptCurrentValue(policyno, sdate, eDate, option).Select(x => new rptInvestmentHistory()
                    {
                        Amount = (decimal)x.amount.GetValueOrDefault(),
                        Cumul_Intr = (decimal)x.cumul_intr.GetValueOrDefault(),
                        Cur_Intr = (decimal)x.cur_intr.GetValueOrDefault(),
                        Date = (DateTime)x.trandate.GetValueOrDefault(),
                        Gir = Convert.ToDecimal(x.gir),
                        PolicyNo = x.policyno,
                        ReceiptNo = x.receiptno,
                        Name = x.Name,
                        OrigDate = x.orig_date.GetValueOrDefault().ToString("dd/MM/yyyy"),
                        Remark = "",
                        Title = x.title
                    }).ToList();
                }
                else if (option == "RctValuePolicy")
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.RctValue_Pol);

                    invHis = new PaymentSystem(context).ReceiptCurrentValue(policyno, sdate, eDate, option).Select(x => new rptInvestmentHistory()
                    {
                        Amount = (decimal)x.amount.GetValueOrDefault(),
                        Cumul_Intr = (decimal)x.cumul_intr.GetValueOrDefault(),
                        Cur_Intr = (decimal)x.cur_intr.GetValueOrDefault(),
                        Date = (DateTime)x.trandate.GetValueOrDefault(),
                        Gir = Convert.ToDecimal(x.gir),
                        PolicyNo = x.policyno,
                        ReceiptNo = x.receiptno,
                        Name = x.Name,
                        OrigDate = x.orig_date.GetValueOrDefault().ToString("dd/MM/yyyy"),
                        Remark = "",
                        Title = x.title
                    }).ToList();
                }
                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;

                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                rpt.Parameter = rparams;
                rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                var savedir = Server.MapPath(ConfigUtils.ReportPath);
                var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                rpt.ReportName = Path.Combine(savedir, reportName);
                rpt.GenerateReport(invHis);
                //var contentType = "application/pdf";

                return ExportReport(reportName);
                //return new ReportFileActionResult(rpt.streamProduct, rpt.ReportName, contentType);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult Production()
        {
            ViewBag.Agents = GetAgents();
            ViewBag.Location = GetLocations();
            ViewBag.CustLocation = GetStates();
            return PartialView("_production");
        }
        [HttpPost]
        public ActionResult Production(string queryj)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var query = JsonConvert.DeserializeObject<dynamic>(queryj);
                string sdate = query.sDate;
                string eDate = query.eDate;
                string agentcode = query.Agent;
                string rptOption = query.rptOption;
                string sortOrder = query.sortOrder;
                string prodAnalysis = query.prodAnalysis;
                string policyno = query.Policy;
                string location = query.Location;
                string custLoc = query.CustLocation;

                List<rptProduction> prod = new List<rptProduction>();

                prod = new PaymentSystem(context).RetrieveProduction(agentcode, sdate, eDate,policyno,location,custLoc).Select(x => new rptProduction()
                {
                    AgentName = x.agentname,
                    Amount = (decimal)x.amount.GetValueOrDefault(),
                    Date=x.trandate.GetValueOrDefault().ToString("dd/MM/yyyy"),
                    Name=string.Format("{0} {1}",x.surname,x.othername),
                    //PremiumLoan=(decimal)x.loanamt.GetValueOrDefault(),
                    PolicyNo=x.policyno,
                    ReceiptNo=x.receiptno,
                    AcceptanceDate=((DateTime)x.accdate).ToString("dd/MM/yyyy")
                }).ToList();

                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;
                var rptdir = string.Empty;

                if (rptOption== "detail")
                {
                    if (sortOrder== "agent")
                    {
                        rptdir= ReportUtil.GetConfig(ReportUtil.Constants.ProductionByAgent);
                    }
                    else
                    {
                        rptdir = ReportUtil.GetConfig(ReportUtil.Constants.Production);
                    }
                }
                else if (rptOption == "summary")
                {
                    if (sortOrder == "agent")
                    {
                        rptdir = ReportUtil.GetConfig(ReportUtil.Constants.ProductionSummaryByAgent);
                    }
                    else
                    {
                        rptdir = ReportUtil.GetConfig(ReportUtil.Constants.ProductionSummary);
                    }
                }

                if (!string.IsNullOrEmpty(prodAnalysis))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.ProductAnalysis);
                }


                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                rparams.Add(RptHeaderCompanyAddress);
                var datefromparams= new KeyValuePair<string, string>("input1", sdate);
                rparams.Add(datefromparams);
                var datetoparams= new KeyValuePair<string, string>("input2", eDate);
                rparams.Add(datetoparams);
                rpt.Parameter = rparams;

                rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                var savedir = Server.MapPath(ConfigUtils.ReportPath);
                var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                rpt.ReportName = Path.Combine(savedir, reportName);
                rpt.GenerateReport(prod);
                //var contentType = "application/pdf";

                return ExportReport(reportName);
                //return new ReportFileActionResult(rpt.streamProduct, rpt.ReportName, contentType);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult Reciept()
        {
            return PartialView("_receiptList");
        }
        [HttpPost]
        public ActionResult Reciept(string queryj)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var query = JsonConvert.DeserializeObject<dynamic>(queryj);
                string sdate = query.sDate;
                string eDate = query.eDate;
                string policyno = query.Policy;

                var rctList = new PaymentSystem(context).RecieptList(policyno, sdate, eDate).Select(x => new rptRecieptList()
                {
                    Amount = (decimal)x.amount.GetValueOrDefault(),
                    ChequeNo = x.chequeno,
                    OtherName =x.othername,
                    RecieptNo = x.receiptno,
                    Date = (DateTime)x.trandate,
                    Surname =x.surname,
                    PolicyNo = x.policyno,
                    Title=x.title,
                    Remark=""
                }).ToList();


                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;
                var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.RecieptListing);

                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                rparams.Add(RptHeaderCompanyAddress);
                var datefromparams = new KeyValuePair<string, string>("input1", sdate);
                rparams.Add(datefromparams);
                var datetoparams = new KeyValuePair<string, string>("input2", eDate);
                rparams.Add(datetoparams);
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
            }

        }

        public ActionResult Commission()
        {
            return PartialView("_commission");
        }
        [HttpPost]
        public ActionResult Commission(string queryj)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var query = JsonConvert.DeserializeObject<dynamic>(queryj);
                string sdate = query.sDate;
                string eDate = query.eDate;

                string agentcode = query.Agent;
                string rptOption = query.option;
                string sortOrder = query.sortOrder;
                string prodAnalysis = query.prodAnalysis;

                List<rptProduction> prod = new List<rptProduction>();

                prod = new PaymentSystem(context).CommissionReport(sdate, eDate, WebSecurity.Module).Select(x => new rptProduction()
                {
                    AgentName = x.AgentName,
                    Amount = x.Amount,
                    Date = x.Date.ToString("dd/MM/yyyy"),
                    Name = x.Name,
                    PremiumLoan=x.PremiumLoan,
                    PolicyNo = x.PolicyNo,
                    ReceiptNo = x.ReceiptNo,
                    AcceptanceDate = x.AcceptanceDate.ToString("dd/MM/yyyy"),
                    Others=x.Others,
                    PolicyLoan=x.PolicyLoan,
                    Premium=x.Premium
                }).ToList();

                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;
                var rptdir = string.Empty;

                if (rptOption == "Details")
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.Commisssion);
                }
                else if (rptOption == "Summary")
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.CommisssionSummary);
                }

                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                rparams.Add(RptHeaderCompanyAddress);
                var datefromparams = new KeyValuePair<string, string>("input1", sdate);
                rparams.Add(datefromparams);
                var datetoparams = new KeyValuePair<string, string>("input2", eDate);
                rparams.Add(datetoparams);
                rpt.Parameter = rparams;

                rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                var savedir = Server.MapPath(ConfigUtils.ReportPath);
                var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                rpt.ReportName = Path.Combine(savedir, reportName);
                rpt.GenerateReport(prod);
                //var contentType = "application/pdf";

                return ExportReport(reportName);
                //return new ReportFileActionResult(rpt.streamProduct, rpt.ReportName, contentType);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult FundGroup()
        {
            return PartialView("_fundGroup");
        }

        [HttpPost]
        public ActionResult FundGroup(string lamt, string uamt)
        {
            try
            {
                decimal lowerAmt = 0.0M;
                decimal upperAmt = 0.0M;

                decimal.TryParse(lamt, out lowerAmt);
                decimal.TryParse(uamt, out upperAmt);

                var rctList = new PaymentSystem(context).RetrieveFundGroup(lowerAmt,upperAmt).Select(x => new rptFundGroup()
                {
                    Amount = (decimal)x.balance.GetValueOrDefault(),
                    AcceptanceDate = (DateTime)x.accdate.GetValueOrDefault(),
                    OtherNames = x.othername,
                    PolicyNo=x.policyno,
                    Surname=x.surname
                }).ToList();


                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;
                var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.FundGroup);

                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                rparams.Add(RptHeaderCompanyAddress);
                var datefromparams = new KeyValuePair<string, string>("input1", lamt);
                rparams.Add(datefromparams);
                var datetoparams = new KeyValuePair<string, string>("input2", uamt);
                rparams.Add(datetoparams);
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
            }


        }

        [HttpPost]
        public ActionResult PrintReceipt(List<rptReceipt> receipt)
        {
            try
            {
                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;
                var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.Receipt);

                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                rparams.Add(RptHeaderCompanyAddress);
                var amtinwordsparam = new KeyValuePair<string, string>("input1", receipt[0].AmountinWord);
                rparams.Add(amtinwordsparam);
                var remarksparam = new KeyValuePair<string, string>("input2", receipt[0].Remarks);
                rparams.Add(remarksparam);
                rpt.Parameter = rparams;

                rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                var savedir = Server.MapPath(ConfigUtils.ReportPath);
                var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                rpt.ReportName = Path.Combine(savedir, reportName);
                rpt.GenerateReport(receipt);
                //var contentType = "application/pdf";

                return ExportReport(reportName);
                //return new ReportFileActionResult(rpt.streamProduct, rpt.ReportName, contentType);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }


        }

        public ActionResult MaturityList()
        {
            return PartialView("_maturitylist");
        }
        [HttpPost]
        public ActionResult Maturity()
        {
            try
            {
                
                List<rptMembers> prod = new List<rptMembers>();

                prod = new PaymentSystem(context).MaturityReport().Select(x => new rptMembers()
                {
                    AgentName = x.AgentName,
                    Amount = x.Amount,
                    Name = x.Name,
                    PolicyNo = x.PolicyNo,
                    AcceptDate = x.AcceptDate,
                    Duedate=x.Duedate,
                    
                }).ToList();

                var rpt = new CrystalReportEngine();
                rpt.reportFormat = ReportFormat.pdf;
                var rptdir = string.Empty;

                rptdir = ReportUtil.GetConfig(ReportUtil.Constants.Maturity);

                var rparams = new List<KeyValuePair<string, string>>();
                rparams.Add(RptHeaderCompanyName);
                rparams.Add(RptHeaderCompanyAddress);
                var datefromparams = new KeyValuePair<string, string>("input1", DateTime.Today.ToString("dd/MM/yyyy"));
                rparams.Add(datefromparams);
                var datetoparams = new KeyValuePair<string, string>("input2", "Maturity List");
                rparams.Add(datetoparams);
                rpt.Parameter = rparams;

                rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                var savedir = Server.MapPath(ConfigUtils.ReportPath);
                var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                rpt.ReportName = Path.Combine(savedir, reportName);
                rpt.GenerateReport(prod);
                //var contentType = "application/pdf";

                return ExportReport(reportName);
                //return new ReportFileActionResult(rpt.streamProduct, rpt.ReportName, contentType);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult GratuityReport()
        {
            ViewBag.customer = GetCustomer();
            ViewBag.GroupCode = Getgropcodes();
            return PartialView("_gratuityAccountStatement");
        }
        [HttpPost]
        public ActionResult Gratuity(string queryj)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var query = JsonConvert.DeserializeObject<dynamic>(queryj);
                string sdate = query.sDate;
                string policyName = query.policyName;
                string policycomp = query.policycomp;
                string Header = query.Header;
                string Naration = query.Naration;
                string showsummary = query.showsummary;
                string Users = User.Identity.Name;
                var getgroup = context.fl_grouptype.Where(x => x.grpcode == policycomp).FirstOrDefault();

                List<rptGratuity> gratuityList = new List<rptGratuity>();
                List<rptGratuity> gratuityList2 = new List<rptGratuity>();

                //gratuityList = new PaymentSystem(context).GratuityStatementReport(sdate, policyName, policycomp, Users).Select(x => new rptGratuity());

                gratuityList = GetStatement(sdate, policyName, policycomp, Users, Header, Naration);


                if (string.IsNullOrEmpty(policyName))
                {
                    var grtsubset = gratuityList.OrderBy(x => x.Policyno).Take(2);
                    foreach (var item in grtsubset)
                    {
                        gratuityList2 = GetStatement(sdate, item.Policyno, item.Grpcode, Users, Header, Naration);

                        //string email2 = gratuityList2.Count > 0 ? gratuityList2.FirstOrDefault().email : "";
                        string email2 = "fregzythomas@gmail.com";
                        if (string.IsNullOrEmpty(email2))
                        {
                            email2 = "fregzythomas@gmail.com";
                        }
                        //string email = !string.IsNullOrEmpty(gratuity.email) ? "" : gratuity.email;
                        GetReport(policycomp, showsummary, gratuityList2, getgroup, email2, sdate);
                        //rpt.GenerateReport(newgratuity);
                        //var contentType =  "application/pdf";


                        //SendEmailNotification(savedir + reportName, email);

                        /*return*/
                        //return ExportReport(reportName);
                    }

                    var report2 = GetReport(policycomp, showsummary, gratuityList, getgroup,"", sdate);
                    return report2;
                }

                string email = gratuityList.Count > 0 ? gratuityList.FirstOrDefault().email : "";
                //string email = "fregzythomas@gmail.com";

                var report = GetReport(policycomp, showsummary, gratuityList, getgroup, email, sdate);

                return report;

            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
            //return new HttpStatusCodeResult(HttpStatusCode.OK, "Report Generated Successfully");
        }

        /// <summary>
        /// HELPER METHODS
        /// </summary>
        /// <param name="report"></param>
        /// <param name="email"></param>
        private void SendEmailNotification(string report,string email)
        {
            try
            {
                string messageToSend = "Statement";
                string receipient =email;
                string emailFrom = "NLPC";
                string sender = ConfigurationManager.AppSettings["emailaddress"];
                string UserName = ConfigurationManager.AppSettings["emailaddress"];
                string Password = ConfigurationManager.AppSettings["emailpass"];
                var body = "<p>Email From: {0} ({1})</p><p>Message:</p><p>{2}</p>";
                var message = new MailMessage();
                if (report != null)
                {
                    message.Attachments.Add(new Attachment(report));
                }
                message.To.Add(new MailAddress(receipient));
                message.From = new MailAddress(sender, emailFrom);
                message.Subject = "Password Verification Code";
                message.Body = string.Format(body, emailFrom, sender, messageToSend);
                message.IsBodyHtml = true;



                string host = ConfigurationManager.AppSettings["emailhost"];
                int port = 587;
                var enableSSL = true;

                SmtpClient SmtpServer = new SmtpClient(host);

                var smtp = new SmtpClient
                {
                    Host = host,
                    Port = port,
                    EnableSsl = enableSSL,
                    DeliveryMethod = SmtpDeliveryMethod.Network,
                    UseDefaultCredentials = false,
                    Credentials = new NetworkCredential(UserName, Password)
                };
                SmtpServer.Port = port; // Also Add the port number to send it, its default for Gmail
                SmtpServer.Credentials = new NetworkCredential(UserName, Password);
                SmtpServer.EnableSsl = enableSSL;
                SmtpServer.Timeout = 200000; // Add Timeout property
                SmtpServer.Send(message);


            }
            catch (Exception ex)
            {

                string message =ex.Message;
            }
            
          
        }

        private List<rptGratuity> GetStatement(string sdate, string policyName, string policycomp, string Users, string Header, string Naration)
        {
            List<rptGratuity> gratuityList2 = new List<rptGratuity>();
            gratuityList2 = new PaymentSystem(context).GratuityStatementReport(sdate, policyName, policycomp, Users).Select(x => new rptGratuity()
            {

                Title = x.title,
                Surname = x.surname,
                Othername = x.othername,
                Location = x.location,
                Policyno = x.policyno,
                Receiptno = x.receiptno,
                Pcn = x.pcn,
                Grpcode = x.grpcode,
                Gir = x.gir,
                Period = x.period,
                Doctype = x.doctype,
                Poltype = x.poltype,
                Orig_date = x.orig_date,
                Trandate = x.trandate,
                Psamount = x.psamount,
                Psopen = x.psopen,
                Pscur_intr = x.pscur_intr,
                Pscumul_intr = x.pscumul_intr,
                Eramount = x.eramount,
                Eropen = x.eropen,
                Ercur_intr = x.ercur_intr,
                Ercumul_intr = x.ercumul_intr,
                Eeamount = x.eeamount,
                ps = x.ps,
                er = x.er,
                ee = x.ee,
                cc = x.cc,
                av = x.av,
                psc = x.psc,
                psintr = x.psintr,
                erintr = x.erintr,
                eeintr = x.eeintr,
                ccintr = x.ccintr,
                avintr = x.avintr,
                pscintr = x.pscintr,
                Eeopen = x.eeopen,
                Eecur_intr = x.eecumul_intr,
                Eecumul_intr = x.eecumul_intr,
                Avamount = x.avamount,
                Avopen = x.avopen,
                Avcur_intr = x.avcur_intr,
                Avcumul_intr = x.avcumul_intr,
                Ccamount = x.ccamount,
                Ccopen = x.ccopen,
                Cccur_intr = x.cccur_intr,
                Cccumul_intr = x.cccumul_intr,
                Pscamount = x.pscamount,
                Pscopen = x.pscopen,
                Psccur_intr = x.psccur_intr,
                Psccumul_intr = x.psccumul_intr,
                Loanamt = x.loanamt,
                grpname = x.grpname,
                header = Header,
                naration = Naration,
                email = x.email,
            }).ToList();

            return gratuityList2;
        }

        private ActionResult GetReport(string policycomp, string showsummary, List<rptGratuity> gratuityList, fl_grouptype grptype, string email, string sdate)
        {
            var getgroup = grptype;
            var rpt = new CrystalReportEngine();
            rpt.reportFormat = ReportFormat.pdf;
            var rptdir = string.Empty;
            if (showsummary == "1")
            {
                if (getgroup.grpclass.Equals("TRV, ER, EE, AVC, CC, PSC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement1A);
                }
                else if (getgroup.grpclass.Equals("ER, EE, AVC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement2A);
                }
                else if (getgroup.grpclass.Equals("ER, EE", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement3A);
                }
                else if (getgroup.grpclass.Equals("TRV, ER, EE", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement4A);
                }
                else if (getgroup.grpclass.Equals("CC, PSC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement5A);
                }
                else if (getgroup.grpclass.Equals("TRV", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement6A);
                }
                else if (getgroup.grpclass.Equals("AVC, CC, PSC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement7A);
                }
                else if (getgroup.grpclass.Equals("TRV, ER, EE, PSC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement8A);
                }
                else if (getgroup.grpclass.Equals("TRV, CC, PSC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement9A);
                }
                else if (getgroup.grpclass.Equals("TRV, CC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement10A);
                }
                else if (getgroup.grpclass.Equals("CC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement11A);
                }
                else
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement12A);
                }
                
            }
            else
            {
                if (getgroup.grpclass.Equals("TRV, ER, EE, AVC, CC, PSC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement1);
                }
                else if (getgroup.grpclass.Equals("ER, EE, AVC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement2);
                }
                else if (getgroup.grpclass.Equals("ER, EE", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement3);
                }
                else if (getgroup.grpclass.Equals("TRV, ER, EE", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement4);
                }
                else if (getgroup.grpclass.Equals("CC, PSC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement5);
                }
                else if (getgroup.grpclass.Equals("TRV", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement6);
                }
                else if (getgroup.grpclass.Equals("AVC, CC, PSC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement7);
                }
                else if (getgroup.grpclass.Equals("TRV, ER, EE, PSC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement8);
                }
                else if (getgroup.grpclass.Equals("TRV, CC, PSC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement9);
                }
                else if (getgroup.grpclass.Equals("TRV, CC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement10);
                }
                else if (getgroup.grpclass.Equals("CC", StringComparison.InvariantCultureIgnoreCase))
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement11);
                }
                else
                {
                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.statement12);
                }
            }
            var rptSdate = new KeyValuePair<string, string>("input1", sdate); 
           
            var rparams = new List<KeyValuePair<string, string>>();
            rparams.Add(RptHeaderCompanyName);
            rparams.Add(rptSdate);
            rpt.Parameter = rparams;
            rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
            var savedir = Server.MapPath(ConfigUtils.ReportPath);
            var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
            rpt.ReportName = Path.Combine(savedir, reportName);

            rpt.GenerateReport(gratuityList);

            if (!string.IsNullOrEmpty(email))
            {
                SendEmailNotification(savedir + reportName, email); 
            }

            return ExportReport(reportName);
        }

        public static string GetSdate(string sdate)
        {
            return sdate;
        }
       
    }
} 