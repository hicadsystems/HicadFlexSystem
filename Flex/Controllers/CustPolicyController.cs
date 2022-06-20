using Dapper;
using Flex.Business;
using Flex.Controllers.Util;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using Flex.Models.ReportModel;
using Flex.Util;
using Flex.Utility.Security;
using Flex.Utility.Utils;
using Newtonsoft.Json;
using OfficeOpenXml;
using SerialNumber;
using SerialNumberGenerator.Model;
using SerialNumberGenerator.Service;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;
using System.Web;
using System.Web.Mvc;

namespace Flex.Controllers
{
    public class CustPolicyController : ContainerController
    {
        // GET: CustPolicy
        public ActionResult Proposal()
        {
            return PartialView("_proposalLayout");
        }

        [HttpPost]
        public ActionResult UnApprovedPolicy(string datefrom, string dateTo)
        {
            try
            {
                var signUpData = new SignUpSystem(context).GetUnApprovedSignUp(Convert.ToDateTime(datefrom), Convert.ToDateTime(dateTo));

                var unapprovedPolicies = signUpData.Select(x => new PendingPolicy()
                            {
                                Address=x.ResAddress,
                                Amount=(decimal)x.ContribAmount,
                                ContribFreq = ((Frequency)Enum.Parse(typeof(Frequency), x.ContribFreq)).ToString(),
                                Email=x.Email,
                                Othernames=x.OtherNames,
                                Phone=x.Phone,
                                PolicyType = x.fl_poltype.poldesc,
                                Regno=x.RegNo,
                                Surname=x.Surname
                            }
                    ).ToList();


                return PartialView("_tbppolicies",unapprovedPolicies);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult ApprovedPolicy(ProposalQueryModel query)
        {

            var rptdir = string.Empty;

            try
            {
                var signUpData = new SignUpSystem(context).GetApprovedSignUp(Convert.ToDateTime(query.DateFrom), Convert.ToDateTime(query.DateTo));

                var unapprovedPolicies = signUpData.Select(x => new PendingPolicy()
                {
                    Address = x.ResAddress,
                    Amount = (decimal)x.ContribAmount,
                    ContribFreq = ((Frequency)Enum.Parse(typeof(Frequency), x.ContribFreq)).ToString(),
                    Email = x.Email,
                    Othernames = x.OtherNames,
                    Phone = x.Phone,
                    PolicyType = x.fl_poltype.poldesc,//((PolicyType)Enum.Parse(typeof(PolicyType), x.PolicyType.ToString())).ToString(),
                    Regno = x.RegNo,
                    Surname = x.Surname,
                    ApprovedDate=(DateTime)x.DateCreated
                }
                    ).ToList();
                if (!query.IsReport)
                {
                    return PartialView("_tbappolicies", unapprovedPolicies);
                }else
                {
                    var approvedProps = signUpData.Select(x => new rptApprovedProp()
                    {
                        Address = x.ResAddress,
                        DOB = (DateTime)x.dob,
                        Location = new CoreSystem<fl_location>(context).Get((int)x.Location).locdesc,
                        NOK = x.NextofKin_BeneficiaryStaging.Where(y => y.Category == (int)Category.NextofKin).FirstOrDefault().Name,
                        Othernames = x.OtherNames,
                        PolicyNo = new PolicySystem(context).FindAll(y => y.quoteno == y.quoteno).FirstOrDefault().policyno,
                        QuoteNo = x.RegNo,
                        Surname = x.Surname
                    }).ToList();

                    /*var rptFormat = !string.IsNullOrEmpty(query.ReportFormat) ? (ReportFormat)Enum.Parse(typeof(ReportFormat), query.ReportFormat) : ReportFormat.pdf;
                    var rpt = new CrystalReportEngine();
                    rpt.reportFormat = rptFormat != null ? rptFormat : ReportFormat.pdf;
                    rpt.ReportPath = System.IO.Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), ReportUtil.GetConfig(ReportUtil.Constants.ApprovedProposal));
                    rpt.ReportName = ReportUtil.Constants.ApprovedProposal;*/
                    //rpt.streamProduct = "";

                    var rpt = new CrystalReportEngine();
                    rpt.reportFormat = ReportFormat.pdf;

                    rptdir = ReportUtil.GetConfig(ReportUtil.Constants.ApprovedPolicy);

                    rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                    var savedir = Server.MapPath(ConfigUtils.ReportPath);
                    var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                    rpt.ReportName = Path.Combine(savedir, reportName);
                   

                    rpt.GenerateReport(approvedProps);
                    /*rpt.GenerateReport(signUpData.Select(x => new rptApprovedProp()
                    {
                        Address = x.ResAddress,
                        DOB =(DateTime) x.dob,
                        Location = new CoreSystem<fl_location>(context).Get((int)x.Location).locdesc,
                        NOK=x.NextofKin_BeneficiaryStaging.Where(y=>y.Category==Category.NextofKin).FirstOrDefault().Name,
                        Othernames=x.OtherNames,
                        PolicyNo=new PolicySystem(context).FindAll(y=>y.quoteno==y.quoteno).FirstOrDefault().policyno,
                        QuoteNo=x.RegNo,
                        Surname=x.Surname
                    }).ToList());*/
                    /*var contentType = rptFormat == ReportFormat.pdf ? "application/pdf" : "application/xls";
                    byte[] byteArray = Encoding.UTF8.GetBytes(contentType);
                    MemoryStream stream = new MemoryStream(byteArray);
                    //rpt.streamProduct = stream;
                    return new ReportFileActionResult(stream, rpt.ReportName, contentType);*/

                    return ExportReport(reportName);
                }
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult ApprovePolicy(string QuoteNos)
        {
            JsonResult resp = null;
            try
            {
                int i=0;
                var Qunos = JsonConvert.DeserializeObject<List<string>>(QuoteNos);
                using (var _context = context)
                {
                    foreach (var quoteno in Qunos)
                    {
                        var signup = new SignUpSystem(context).RetriveSignUpDataByQuoteNo(quoteno);

                        var polInput = new fl_policyinput()
                        {
                            datecreated = DateTime.Now,
                            dob = ((DateTime)signup.dob).ToString("yyyyMMdd"),
                            email = signup.Email,
                            othername = signup.OtherNames,
                            peradd = signup.ResAddress,
                            poltype = new CoreSystem<fl_poltype>(context).Get((int)signup.PolicyType).poltype,
                            premium = signup.ContribAmount,
                            quoteno = signup.RegNo,
                            surname = signup.Surname,
                            telephone = signup.Phone,
                            accdate = DateTime.Now,
                            locationid = signup.Location,
                            agentcode=signup.agentcode,
                            IdentityNumber=signup.IdentityNumber,
                            IdentityType=signup.IdentityType,
                            PictureFile=signup.PictureFile,
                            signature=signup.signature,
                            TermsAndConditions=signup.TermsAndConditions,
                            
                            
                        };
                        i++;

                        using (var transaction = _context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                        {
                            try
                            {
                                Logger.Info("About to get Policy Serial Number");


                                //var policynoSno = new SerialNumberService().GetNextNumber(polInput.poltype);

                                var polType = _context.fl_poltype.Where(x => x.poltype == polInput.poltype).FirstOrDefault();
                                var xpolType = polType != null && !string.IsNullOrEmpty(polType.code) ? polType.code : polType.code;
                                

                                var policyno = ConfigUtils.PolicyNoFormat;
                                var xlocation = new fl_location();
                                try
                                {
                                    xlocation = new CoreSystem<fl_location>(_context).Get((int)polInput.locationid);
                                    if (xlocation == null)
                                    {
                                        throw new Exception("Invalid Location");

                                    }
                                }
                                catch (Exception)
                                {

                                    throw new Exception("Invalid Location");
                                }

                                var policynoSno = GetNextNumber(polInput.poltype);
                                Logger.InfoFormat("Serial Number {0} gotten", policynoSno);

                                var pcn = policynoSno.ToString().PadLeft(ConfigUtils.policynoLenght, '0');
                                policyno = policyno.Replace("{PolicyType}", xpolType).Replace("{Location}", xlocation.loccode)
                                              .Replace("{Year}", DateTime.Today.ToString("yy"))
                                              .Replace("{SerialNo}", pcn);

                                if (string.IsNullOrEmpty(polInput.grpcode))
                                {
                                    polInput.grpcode = string.Empty;
                                }
                                polInput.policyno = policyno;
                                polInput.pcn = pcn;
                                
                                new PolicySystem(context).savePolicy(polInput);

                                new SignUpSystem(context).ApproveSignUp(polInput.quoteno, polInput.srn);
                                var userpwd = WebUtils.UserPwd;
                                var defaultDate = (DateTime)SqlDateTime.Null;
                                var user = new CustomerUser()
                                {
                                    username = polInput.policyno,
                                    datecreated = DateTime.Now,
                                    email = polInput.email,
                                    Name = string.Format("{0} {1}", polInput.surname, polInput.othername),
                                    password = new MD5Password().CreateSecurePassword(userpwd),
                                    phone = polInput.telephone,
                                    status = (int)UserStatus.New,
                                    passworddate = defaultDate,
                                    modifydate = defaultDate,
                                    firstLoginDate = defaultDate,
                                    lastLoginDate = defaultDate,
                                    IsDeleted = false
                                };

                                new CustomerAuthSystem(context).Save(user);

                                var custPolicy = new CustomerPolicy()
                                {
                                    CustomerUser = user,
                                    CustomerUserId = user.Id,
                                    Policyno = polInput.policyno
                                };

                                new CoreSystem<CustomerPolicy>(context).Save(custPolicy);

                                //StringBuilder emailBody = new StringBuilder();
                                //emailBody.AppendFormat("<p>Hello {0} {1}</p><br/><<p>Your Policy has been approved.</p>"
                                //    , polInput.surname, polInput.othername);
                                //emailBody.Append("Please find details of your policy below.</p>");
                                //emailBody.AppendFormat("<p>Policy No.: {0}</p><p>Username: {1}</p><p>Password: {2}</p><br/>",
                                //    polInput.policyno, polInput.policyno, userpwd);
                                //emailBody.Append("<p>Thanks<p/>");
                                //var pEmail = new PendingEmail()
                                //{
                                //    Body = emailBody.ToString(),
                                //    DueDate = DateTime.Now,
                                //    From = "NLPC",
                                //    IsBodyHtml = true,
                                //    Subject = string.Format("Welcome on Board {0} {1}", polInput.surname, polInput.othername),
                                //    To = polInput.email,

                                //};
                                //var err = string.Empty;
                                new NotificationSystem(context).SendPolicyCreationNotiification(polInput, polInput.policyno, userpwd, xpolType);

                                //if (!string.IsNullOrEmpty(polInput.email))
                                //{
                                //    SendEmailNotification(polInput, userpwd, polInput.email);
                                //}

                                transaction.Commit();

                            }
                            catch (Exception ex)
                            {
                                Logger.ErrorFormat("Error Occurred. Details {0}", ex.ToString());
                                transaction.Rollback();
                                throw;
                            }
                        }


                    }
                    resp = new JsonResult()
                    {
                        Data = string.Format("{0} quotation(s) approved successfully", i)
                    };
                }
                

            }
            catch (Exception ex)
            {
                Logger.InfoFormat("An Error Occurred. Details [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
            return resp;
        }
        /// <summary>
        /// HELPER METHODS
        /// </summary>
        /// <param name="PolicyType"></param>
        /// <returns></returns>
        private String GetNextNumber(String PolicyType)
        {
            RecordNo gratuity = null;
            var queryParameters = new DynamicParameters();

            try
            {

                if (!string.IsNullOrEmpty(PolicyType))
                {
                    queryParameters.Add("@poltype", PolicyType);
                }

                using (IDbConnection conn = new SqlConnection(context.Database.Connection.ConnectionString))
                {

                    gratuity = conn.Query<RecordNo>("fl_generate_serialno", queryParameters, commandType: CommandType.StoredProcedure, commandTimeout: 2000).FirstOrDefault();
                };


            }
            catch (Exception)
            {

                throw new Exception("Unable to generate serial no");
            }
            return gratuity.polno.ToString();

        }

        public void SendEmailNotification(fl_policyinput polInput, string userpwd, string email)
        {
            try
            {
                string messageToSend = "Policy Confirmation";
                string receipient = email;
                string emailFrom = "NLPC";
                string sender = ConfigurationManager.AppSettings["emailaddress"];
                string UserName = ConfigurationManager.AppSettings["emailaddress"];
                string Password = ConfigurationManager.AppSettings["emailpass"];
                
                StringBuilder emailBody = new StringBuilder();
                emailBody.AppendFormat("<p>Hello {0} {1}</p><br/><<p>Your Policy has been approved.</p>"
                    , polInput.surname, polInput.othername);
                emailBody.Append("Please find details of your policy below.</p>");
                emailBody.AppendFormat("<p>Policy No.: {0}</p><p>Username: {1}</p><p>Password: {2}</p><br/>",
                    polInput.policyno, polInput.policyno, userpwd);
                emailBody.Append("<p>Thanks<p/>");
                
                //var body = "<p>Email From: {0} ({1})</p><p>Message:</p><p>{2}</p>";
                var message = new MailMessage();
                //if (report != null)
                //{
                //    message.Attachments.Add(new Attachment(report));
                //}
                message.To.Add(new MailAddress(receipient));
                message.From = new MailAddress(sender, emailFrom);
                message.Subject = "Password Verification Code";
                message.Body = string.Format(emailBody.ToString(), emailFrom, sender, messageToSend);
                message.IsBodyHtml = true;



                string host = ConfigurationManager.AppSettings["emailhost"];
                int port = 587;
                var enableSSL = true;

                SmtpClient SmtpServer = new SmtpClient(host);
                //SmtpClient SmtpServer = new SmtpClient("smtp.gmail.com", port);

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

                Response.Write("Message sent successfully");
            }
            catch (Exception ex)
            {
                throw;
                //string message = ex.Message;
                //Response.Write("Message Failed");
            }


        }

        public ActionResult DisapprovePolicy(string QuoteNos)
        {
            JsonResult resp = null;
            int i = 0;
            var Qunos = JsonConvert.DeserializeObject<List<string>>(QuoteNos);
            using (var _context = context)
            {
                try
                {
                    foreach (var quoteno in Qunos)
                    {
                        var signup = new SignUpSystem(context).RetriveSignUpDataByQuoteNo(quoteno);

                        var polInput = new fl_policyinput()
                        {
                            datecreated = DateTime.Now,
                            dob = ((DateTime)signup.dob).ToString("yyyyMMdd"),
                            email = signup.Email,
                            othername = signup.OtherNames,
                            peradd = signup.ResAddress,
                            poltype = new CoreSystem<fl_poltype>(context).Get((int)signup.PolicyType).poltype,
                            premium = signup.ContribAmount,
                            quoteno = signup.RegNo,
                            surname = signup.Surname,
                            telephone = signup.Phone,
                            accdate = DateTime.Now,
                            locationid = signup.Location,

                        };
                        i++;

                        using (var transaction = _context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                        {
                            try
                            {

                                new SignUpSystem(context).DisapproveSignUp(polInput.quoteno, polInput.srn);
                                transaction.Commit();
                            }
                            catch (Exception ex)
                            {
                                Logger.ErrorFormat("Error Occurred. Details {0}", ex.ToString());
                                transaction.Rollback();
                                throw;
                            }
                        }

                    }
                }
                catch (Exception ex)
                {
                    Logger.InfoFormat("An Error Occurred. Details [{0}]", ex.ToString());
                    return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
                }
                resp = new JsonResult()
                {
                    Data = string.Format("{0} quotation(s) approved successfully", i)
                };
                return resp;
            }
        }

        public ActionResult Customers()
        {
            try
            {
                var cust = new CustomerAuthSystem(context).SearchUser();

                return PartialView("_customers", cust);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SearchCustomer(string searchterm, string page, string pagesize)
        {
            int pg = 0;
            int psize = 0;
            try
            {
                int.TryParse(page, out pg);
                int.TryParse(pagesize, out psize);
                var cust = new CustomerAuthSystem(context).SearchUser(searchterm, pg, psize);

                return PartialView("_tbCustomers", cust);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }


        public ActionResult ResetPassword(long Id)
        {
            try
            {
                var custUser = new CoreSystem<CustomerUser>(context).Get(Id);
                return PartialView("_resetPwd", custUser);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        [HttpPost]
        public ActionResult PasswordReset(string Id)
        {
            try
            {
                long id;
                Int64.TryParse(Id, out id);
                var cust = new CustomerAuthSystem(context).Get(id);

                var nPwd = WebUtils.UserPwd;
                var pwd = new MD5Password().CreateSecurePassword(nPwd);

                cust.password = pwd;
                cust.status = (int)UserStatus.New;
                cust.modifydate = DateTime.Now;
                cust.passworddate = DateTime.Now;
                using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                {
                    try
                    {
                        new CustomerAuthSystem(context).Update(cust, cust.Id);

                        var pemail = new PendingEmail();
                        StringBuilder body = new StringBuilder();
                        body.AppendFormat("<p>Hello {0}</p><br/>", cust.Name);
                        body.AppendFormat("Your Password has been reset to {0}", nPwd);
                        body.Append("Thanks");
                        pemail.Body = body.ToString();
                        pemail.DueDate = DateTime.Now;
                        pemail.From = "NLPC";
                        pemail.IsBodyHtml = true;
                        pemail.Subject = "Password Reset";
                        pemail.To = cust.email;
                        var err = string.Empty;
                        //new NotificationSystem().SendMail(pemail, out err);
                        new CoreSystem<PendingEmail>(context).Save(pemail);

                        transaction.Commit();
                    }
                    catch (Exception)
                    {
                        transaction.Rollback();
                        throw;
                    }
                }

                //return new HttpStatusCodeResult(System.Net.HttpStatusCode.OK,  );
                return new JsonResult()
                {
                    Data = string.Format("Password Reset Successful for {0} with password {1}", cust.username, nPwd)
                };
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult AddPolicy(string Id)
        {
            try
            {
                int custid = Convert.ToInt32(Id);

                ////var pol = _context.CustomerPolicies.Where(x => x.Id == Convert.ToInt64(Id)).FirstOrDefault();
                //using (var _context = context)
                //{
                //    var _custPols = _context.CustomerUsers.Where(x => x.Id == custid).FirstOrDefault();
                //    ViewBag.policyno = _custPols.username;
                //}
                GetPolicyNo(custid);
                GetPolicyType();
                GetLocation();
                ViewBag.Id = Id;

                return PartialView("_addPolicy");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult ViewCustPolicies(long CustomerId)
        {
            try
            {
                ViewBag.Id = CustomerId;

                var custPolicies = new List<vwPolicy>();
                using(var _context = context)
                {
                    var _custPols = _context.CustomerPolicies.Where(x => x.CustomerUserId == CustomerId).Select(y => y.Policyno);
                    custPolicies = new CoreSystem<vwPolicy>(context).FindAll(x => _custPols.Contains(x.policyno)).ToList();
                }
                return PartialView("_policySummary", custPolicies);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }


        [HttpPost]
        public ActionResult UpdatePolicy(string Id, string policyno)
        {
            try
            {
                JsonResult resp = null;
                var id=0L;
                Int64.TryParse(Id, out id);
                var oldCust = new CustomerAuthSystem(context).FindAll(x => x.username == policyno).FirstOrDefault();
                if (oldCust==null || oldCust.IsDeleted==true)
                {
                    throw new Exception(string.Format("Policy Number {0} does not exits or has been added to another User", policyno));
                }
                //if (true)
                //{
                    
                //}
                var OldCustPol = new CoreSystem<CustomerPolicy>(context).FindAll(x => x.Policyno == policyno).FirstOrDefault();

                using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                {
                    try
                    {
                        new CustomerAuthSystem(context).Update(oldCust, oldCust.Id);

                        if (OldCustPol != null)
                        {
                            oldCust.IsDeleted = true;
                            OldCustPol.CustomerUserId = id;

                            new CoreSystem<CustomerPolicy>(context).Update(OldCustPol, OldCustPol.Id);
                        }

                        transaction.Commit();
                    }
                    catch (Exception)
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
                resp = new JsonResult()
                {
                    Data = string.Format("Policy Number {0} has been added to user {1} successfully", policyno, Id)
                };

                return resp;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult Policy()
        {
            try
            {
                return PartialView("_policyLayout");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult Policies()
        {
            try
            {
                ViewBag.Agent = GetAgents();
                ViewBag.Location = GetLocations();

                var pols = new PagedResult<vwPolicy>();
                using (var _context = currentContext)
                {
                    pols = new PolicySystem(_context).searchPolicies(WebSecurity.ModulePolicyTypes);
                }
                
                return PartialView("_policy", pols);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult AgentPolicy()
        {
            try
            {
                return PartialView("_agentPolicyLayout");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult AgentPolicies()
        {
            try
            {
                ViewBag.Agent = GetAgents();
                ViewBag.Location = GetLocations();
                var uSession = GetUserSesiion();
                
                var pols = new PagedResult<vwPolicy>();
                using (var _context = currentContext)
                {
                  var agent= _context.fl_agents.FirstOrDefault(x => x.Id == uSession.AgentId).agentcode;
                    pols = new PolicySystem(_context).agentSearchPolicies(agent);
                }

               return PartialView("_agentPolicy", pols);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult Payhistbyagent()
        {
            try
            {
                ViewBag.month = GetMonths();
                var uSession = GetUserSesiion();

                var pols = new PagedResult<VPayhistorybyAgent>();
                using (var _context = currentContext)
                {

                    var agent = _context.fl_agents.FirstOrDefault(x => x.Id == uSession.AgentId).agentcode;
                    pols = new PolicySystem(_context).agentSearchPayhist(agent);
                }

                return PartialView("_agentPayhist", pols);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult SearchPolicy(PolicyQueryModel query)
        {
            try
            {
                var page = "";
                var size = "";
                if (query.Page != null)
                {
                    if (!string.IsNullOrEmpty(query.Page.Page))
                    {
                        page=query.Page.Page;
                    }
                    if (!string.IsNullOrEmpty(query.Page.Size))
                    {
                        size = query.Page.Size;
                    }
                }

                var pols = new PagedResult<vwPolicy>();
                using (currentContext)
                {
                    pols = new PolicySystem(currentContext).searchPolicies(WebSecurity.ModulePolicyTypes, query.PolicyNo, query.Name, query.Phone, query.Agent, query.Location, size, page);
                }
                
                return PartialView("_tbPolicies", pols);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult SearchAgentPolicy(PolicyQueryModel query)
        {
            try
            {
                var page = "";
                var size = "";
                if (query.Page != null)
                {
                    if (!string.IsNullOrEmpty(query.Page.Page))
                    {
                        page = query.Page.Page;
                    }
                    if (!string.IsNullOrEmpty(query.Page.Size))
                    {
                        size = query.Page.Size;
                    }
                }

                var pols = new PagedResult<vwPolicy>();
                using (currentContext)
                {
                    var uSession = GetUserSesiion();
                    var agent = currentContext.fl_agents.FirstOrDefault(x => x.Id == uSession.AgentId).agentcode;
                    pols = new PolicySystem(currentContext).agentSearchPolicies(agent,query.PolicyNo, query.Name, query.Phone, size, page);
                }
                ViewBag.Agent = GetAgents();
                ViewBag.Location = GetLocations();

                return PartialView("_agentPolicy2", pols);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }


        }
        public ActionResult SearchPayhist(PolicyQueryModel query)
        {
            try
            {
                var uSession = GetUserSesiion();
                var page = "";
                var size = "";
                if (query.Page != null)
                {
                    if (!string.IsNullOrEmpty(query.Page.Page))
                    {
                        page = query.Page.Page;
                    }
                    if (!string.IsNullOrEmpty(query.Page.Size))
                    {
                        size = query.Page.Size;
                    }
                }
                ViewBag.month = GetMonths();
                var pols = new PagedResult<VPayhistorybyAgent>();
                using (currentContext)
                {
                    var agent = currentContext.fl_agents.FirstOrDefault(x => x.Id == uSession.AgentId).agentcode;
                    pols = new PolicySystem(currentContext).agentSearchPayhist(agent,query.PolicyNo, query.Month,query.year, size, page);
                }

                return PartialView("_agentPayhist2", pols);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }


        }
        private SignUpBindingModel _polDetails;

        public SignUpBindingModel poldetails
        {
            get
            {
                _polDetails=  new SignUpBindingModel()
                {
                    PersonalInfo = new PesonalInfoBindingModel()
                    {
                        NextofKin = new NextofKinBeneficiaryBindingModel(),
                        Beneficiary = new List<NextofKinBeneficiaryBindingModel>()
                    }
                };

                return _polDetails;
            }

            set
            {
                _polDetails = value;
            }
        }
        public ActionResult Step1()
        {
           
            ViewBag.Location = GetLocations();
            getPolicyTypeForDirectPolicyInput();
            ViewBag.Agent = GetAgents();
            getGroup();
            GetReligion();
            GetGender();
            return PartialView("_step1", poldetails);
        }
        public ActionResult Step2()
        {

            return PartialView("_step2", poldetails);
        }
        public ActionResult Step3()
        {
            GetReationShip();
            return PartialView("_step3", poldetails);
        }

        public ActionResult PolicyUpload()
        {
            getGroup();
            getPolicyType();
            return PartialView("_policyUpload");
        }

        public ActionResult DirectPolicyCreation(SignUpBindingModel signUpmodel)
        {
            Logger.Info("Inside direct policy");
            try
            {
                if (signUpmodel == null)
                {
                    throw new Exception("Error Occurred.");
                }
                if (signUpmodel.PersonalInfo == null)
                {
                    throw new Exception("Error occurred. Please try again");
                }
                if (signUpmodel.PersonalInfo.NextofKin == null)
                {
                    throw new Exception("Please Provide Next of kin Details");
                }
                if (signUpmodel.PersonalInfo.Beneficiary == null || !signUpmodel.PersonalInfo.Beneficiary.Any())
                {
                    throw new Exception("Please Provide atleast one Beneficiary");
                }
                var pInfo = signUpmodel.PersonalInfo;
                var isValid = new PolicySystem(context).validate(pInfo.Phone);
                //var existingPolicy = new CoreSystem<fl_policyinput>(context).Get(pInfo.Phone.ToString());
                if (isValid ==false)
                {
                    throw new Exception("A Policy Holder Already Use This Phone Number");
                }
                HttpPostedFileBase file = Request.Files["PictureFile"];
                var xpoltype = new fl_poltype();
                //var id = new CoreSystem<fl_poltype>(context).FindAll(x => x.poltype == pInfo.PolicyType.ToString()).Select(x => x.Id).FirstOrDefault();
                xpoltype = new CoreSystem<fl_poltype>(context).Get((int)pInfo.PolicyType);
                if (xpoltype==null)
                {
                    string pol = "";
                    if (pInfo.PolicyType==2 || pInfo.PolicyType==3)
                    {
                         pol = "0"+pInfo.PolicyType.ToString();
                        var id = new CoreSystem<fl_poltype>(context).FindAll(x => x.poltype == pol).Select(x => x.Id).FirstOrDefault();
                        xpoltype = new CoreSystem<fl_poltype>(context).Get(id);
                    }
                    
                }
                //xpoltype = new CoreSystem<fl_poltype>(context).Get(id);

                var polInput = new fl_policyinput()
                {
                    datecreated = DateTime.Now,
                    dob = ((DateTime)pInfo.Dob).ToString("yyyyMMdd"),
                    email = pInfo.Email,
                    othername = pInfo.Othernames,
                    peradd = pInfo.ResAddress,
                    poltype = xpoltype.poltype,
                    premium = pInfo.Amount,
                    surname = pInfo.Surname,
                    telephone = pInfo.Phone,
                    accdate = DateTime.Now,
                    locationid = pInfo.Locationid,
                    agentcode = pInfo.AgentCode,
                    status = (int)Status.Active,
                    //PictureFile=pInfo.PictureFile,
                    PictureFile=pInfo.PictureFile,
                    grpcode=pInfo.GroupCode,
                    IdentityType=pInfo.IdentityType,
                    IdentityNumber=pInfo.IdentityNumber
                };
               
                var nok = signUpmodel.PersonalInfo.NextofKin;
               
                var nextofkinBen = new NextofKin_BeneficiaryStaging();
                nextofkinBen.Address = nok.Address;
                nextofkinBen.ApprovalStatus = (int)ApprovalStatus.Approved;
                nextofkinBen.Category = (int)Category.NextofKin;
                nextofkinBen.Dob = Convert.ToDateTime(nok.Dob);
                nextofkinBen.Email = nok.Email;
                nextofkinBen.Name = nok.Name;
                nextofkinBen.Phone = nok.Phone;
                nextofkinBen.IsSynched = true;
                nextofkinBen.Type = (int)Data.Enum.Type.New;
                /*if (nextofkinBen.Dob.ToString().Contains("01/01/0001"))
                {
                   // throw new Exception();
                    nextofkinBen.Dob = null;
                }*/
                var bens = signUpmodel.PersonalInfo.Beneficiary;

                var benefs = bens.Select(x => new NextofKin_BeneficiaryStaging()
                {
                    Address = x.Address,
                    ApprovalStatus = (int)ApprovalStatus.Approved,
                    Category = (int)Category.Beneficiary,
                    Dob = Convert.ToDateTime(x.Dob),
                    Email = x.Email,
                    Name = x.Name,
                    Phone = x.Phone,
                    Proportion = x.Proportion,
                    RelationShip = x.Relationship,
                    IsSynched = true,
                    Type = (int)Data.Enum.Type.New
                });

                using (var _context = context)
                {
                    using (var transaction = _context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                    {
                        try
                        {
                            var userId = signUpmodel.PersonalInfo.CustomerId;

                            Logger.Info("About to get Policy Serial Number");
                            //var policynoSno = new SerialNumberSource().GetNextNumber(xpoltype.poltype);
                            var policyno = ConfigUtils.PolicyNoFormat;
                            var xlocation = new CoreSystem<fl_location>(_context).Get((int)polInput.locationid);
                            if (xlocation == null)
                            {
                                throw new Exception("Invalid Location or Location is missing.");
                            }

                            var policynoSno = GetNextNumber(xpoltype.poltype);
                            Logger.InfoFormat("Serial Number {0} gotten", policynoSno);

                            var xpolType = xpoltype != null && !string.IsNullOrEmpty(xpoltype.code) ? xpoltype.code : polInput.poltype;

                            var pcn = policynoSno.ToString().PadLeft(ConfigUtils.policynoLenght, '0');
                            policyno = policyno.Replace("{PolicyType}", xpolType).Replace("{Location}", xlocation.loccode)
                                          .Replace("{Year}", DateTime.Today.ToString("yy"))
                                          .Replace("{SerialNo}", pcn);

                            polInput.policyno = policyno;
                            polInput.pcn = pcn;
                            new PolicySystem(currentContext).savePolicy(polInput);
                            bool IsNewCustomer = false;
                            var userpwd = string.Empty;
                            nextofkinBen.PolicyId = polInput.srn;
                            nextofkinBen.RegNo = polInput.policyno;

                            new CoreSystem<NextofKin_BeneficiaryStaging>(_context).Save(nextofkinBen);

                            foreach (var b in benefs)
                            {
                                /*if (b.Dob.ToString().Contains("01/01/0001"))
                                {
                                    b.Dob = null;
                                }*/
                                b.PolicyId = polInput.srn;
                                b.RegNo = polInput.policyno;
                                new CoreSystem<NextofKin_BeneficiaryStaging>(context).Save(b);
                            }

                            if (userId == 0)
                            {
                                IsNewCustomer = true;
                                userpwd = WebUtils.UserPwd;
                                var defaultDate = (DateTime)SqlDateTime.Null;
                                var user = new CustomerUser()
                                {
                                    username = polInput.policyno,
                                    datecreated = DateTime.Now,
                                    email = polInput.email,
                                    Name = string.Format("{0} {1}", polInput.surname, polInput.othername),
                                    password = new MD5Password().CreateSecurePassword(userpwd),
                                    phone = polInput.telephone,
                                    status = (int)UserStatus.New,
                                    passworddate = defaultDate,
                                    modifydate = defaultDate,
                                    firstLoginDate = defaultDate,
                                    lastLoginDate = defaultDate,
                                    IsDeleted = false
                                };
                                new CustomerAuthSystem(_context).Save(user);

                                userId = user.Id;
                            }

                            var custPolicy = new CustomerPolicy()
                            {
                                CustomerUserId = userId,
                                Policyno = polInput.policyno
                            };
                            new CoreSystem<CustomerPolicy>(_context).Save(custPolicy);
                            if (IsNewCustomer)
                            {
                                new NotificationSystem(_context).SendPolicyCreationNotiification(polInput, polInput.policyno, userpwd, xpolType);
                                //if (!string.IsNullOrEmpty(polInput.email))
                                //{
                                //    SendEmailNotification(polInput, userpwd, polInput.email);
                                //}
                            }
                            else
                            {
                                var userDetails = new CustomerAuthSystem(context).Get(userId);
                                new NotificationSystem(_context).SendPolicyCreationNotiification(polInput, userDetails.username, string.Empty, xpolType);
                                //if (!string.IsNullOrEmpty(polInput.email))
                                //{
                                //    SendEmailNotification(polInput,string.Empty, polInput.email);
                                //}
                            }

                            transaction.Commit();

                        }
                        catch
                        {
                            transaction.Rollback();
                            throw;
                        }
                    }

                }
                return new JsonResult()
                {
                    Data = string.Format("Policy with policy Number {0} created successfully", polInput.policyno)
                };

            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Error Occurred. Details  [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult DirectPolicyUpdate(SignUpBindingModel signUpmodel)
        {
            Logger.Info("Inside direct policy");
            try
            {
                if (signUpmodel == null)
                {
                    throw new Exception("Error Occurred.");
                }
                var pInfo = signUpmodel.PersonalInfo;
                fl_policyinput existingPolicy = null;
                
                var xpoltype = new fl_poltype();
                xpoltype = new CoreSystem<fl_poltype>(context).Get((int)pInfo.PolicyType);
                if (pInfo != null)
                     existingPolicy = new CoreSystem<fl_policyinput>(context).Get((int)pInfo.CustomerId);
                
                //if (xpoltype == null)
                //    throw new Exception("Invalid Policy type");


                if (existingPolicy != null)
                {
                    existingPolicy.dob = ((DateTime)pInfo.Dob).ToString("yyyyMMdd");
                    existingPolicy.email = pInfo.Email;
                    existingPolicy.othername = pInfo.Othernames;
                    existingPolicy.peradd = pInfo.ResAddress;
                    existingPolicy.premium = pInfo.Amount;
                    existingPolicy.locationid = pInfo.Locationid;
                    existingPolicy.agentcode = pInfo.AgentCode;
                    //existingPolicy.grpcode = pInfo.GroupCode;
                    existingPolicy.sex = pInfo.Gender;
                    existingPolicy.poltype = xpoltype.poltype;
                    existingPolicy.surname = pInfo.Surname;
                    existingPolicy.telephone = pInfo.Phone;
                    existingPolicy.religion = pInfo.Religion;
                }
                    
                
               

                var nok = signUpmodel.PersonalInfo.NextofKin;
                NextofKin_BeneficiaryStaging existingNok = null;
                if (nok != null)
                     existingNok = new CoreSystem<NextofKin_BeneficiaryStaging>(context).Get(nok.Id);
                


                if (existingNok != null)
                {
                    existingNok.Address = nok.Address;
                    existingNok.Dob = Convert.ToDateTime(nok.Dob);
                    existingNok.Email = nok.Email;
                    existingNok.Name = nok.Name;
                    existingNok.Phone = nok.Phone;
                    existingNok.Proportion = nok.Proportion;
                }
                    


                var beneficiary = signUpmodel.PersonalInfo.Benefitiary;
                NextofKin_BeneficiaryStaging existingBeneficiary = null;

                if (beneficiary != null)
                    existingBeneficiary = new CoreSystem<NextofKin_BeneficiaryStaging>(context).Get(beneficiary.Id);

                if (existingBeneficiary != null)
                {
                    existingBeneficiary.Address = beneficiary.Address;
                    existingBeneficiary.Dob = Convert.ToDateTime(beneficiary.Dob);
                    existingBeneficiary.Email = beneficiary.Email;
                    existingBeneficiary.Name = beneficiary.Name;
                    existingBeneficiary.Phone = beneficiary.Phone;
                    existingBeneficiary.Proportion = beneficiary.Proportion;
                    existingBeneficiary.RelationShip = beneficiary.Relationship;
                }

                var bens = signUpmodel.PersonalInfo.Beneficiary;
                var benefs = new List<NextofKin_BeneficiaryStaging>();
                fl_policyinput policy = new fl_policyinput();
               
                if (bens.Count > 0)
                {
                    policy = new CoreSystem<fl_policyinput>(context).Get(bens.FirstOrDefault().PolicyId);
                    benefs = bens.Select(x => new NextofKin_BeneficiaryStaging()
                    {
                        Address = x.Address,
                        ApprovalStatus = (int)ApprovalStatus.Approved,
                        Category = (int)Category.Beneficiary,
                        Dob = Convert.ToDateTime(x.Dob),
                        Email = x.Email,
                        Name = x.Name,
                        Phone = x.Phone,
                        Proportion = x.Proportion,
                        RelationShip = x.Relationship,
                        IsSynched = true,
                        Type = (int)Data.Enum.Type.New,
                        RegNo = x.RegNo,
                        PolicyId = x.PolicyId
                    }).ToList(); 
                }


                using (var _context = context)
                {
                    using (var transaction = _context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                    {
                        try
                        {
                            var userId = signUpmodel.PersonalInfo.CustomerId;

                            
                            if (existingPolicy != null)
                                new PolicySystem(currentContext).UpdatePolicy(existingPolicy, pInfo.CustomerId);
                            
                            if (existingNok != null)
                                new CoreSystem<NextofKin_BeneficiaryStaging>(_context).Update(existingNok, nok.Id);

                            if (existingBeneficiary != null)
                                new CoreSystem<NextofKin_BeneficiaryStaging>(_context).Update(existingBeneficiary, beneficiary.Id);

                            if (benefs.Count > 0)
                            {
                                foreach (var b in benefs)
                                {
                                    /*if (b.Dob.ToString().Contains("01/01/0001"))
                                    {
                                        b.Dob = null;
                                    }*/
                                    b.PolicyId = policy.srn;
                                    b.RegNo = policy.policyno;
                                    new CoreSystem<NextofKin_BeneficiaryStaging>(context).Save(b);
                                } 
                            }

                            transaction.Commit();

                        }
                        catch
                        {
                            transaction.Rollback();
                            throw;
                        }
                    }

                }
                return new JsonResult()
                {
                    Data = string.Format("Policy updated successfully")
                };

            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Error Occurred. Details  [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult UploadPolicy(string GroupCode, int PolicyType)
        {
            try
            {
                var file = Request.Files[0];
                var pols = new List<fl_policyinput>();
                //var poltype = new CoreSystem<fl_poltype>(context).Get(PolicyType);
                //string polType = poltype.poltype;
                var xpoltype = new fl_poltype();

                //xpoltype = new CoreSystem<fl_poltype>(context).Get(PolicyType);
                xpoltype = new CoreSystem<fl_poltype>(context).FindAll(x=>x.poltype==PolicyType.ToString()).FirstOrDefault();

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
                            var policy = new fl_policyinput();
                            policy.policyno = workSheet.Cells[rowIterator, 1].Value?.ToString();
                            var policynoSno = string.Empty;
                            if (string.IsNullOrEmpty(policy.policyno))
                            {
                                policynoSno = GetNextNumber(xpoltype.poltype);
                                policy.policyno = GroupCode + "/" + policynoSno;
                                //policy.pcn = policynoSno;
                            }
                            policy.pcn = workSheet.Cells[rowIterator, 2].Value?.ToString();
                            if (string.IsNullOrEmpty(policy.pcn))
                            {
                                policy.pcn = policynoSno;
                            }
                            policy.sex = workSheet.Cells[rowIterator, 3].Value?.ToString();
                            policy.title = workSheet.Cells[rowIterator, 4].Value?.ToString();
                            policy.surname = workSheet.Cells[rowIterator, 5].Value?.ToString();
                            policy.othername = workSheet.Cells[rowIterator, 6].Value?.ToString();
                            policy.dob = workSheet.Cells[rowIterator, 7].Value?.ToString();
                            policy.grpcode = workSheet.Cells[rowIterator, 8].Value?.ToString();
                            if (string.IsNullOrEmpty(policy.grpcode))
                            {
                                policy.grpcode = GroupCode;
                            }
                            policy.telephone = workSheet.Cells[rowIterator, 9].Value?.ToString();
                            policy.email = workSheet.Cells[rowIterator, 10].Value?.ToString();
                            policy.status = (int)Status.Active;
                            policy.datecreated = DateTime.Now;
                            policy.poltype = xpoltype.poltype;
                            try
                            {
                               
                                if (!string.IsNullOrEmpty(policy.email) || string.IsNullOrEmpty(policy.telephone))
                                {
                                    var isValid = new NotificationSystem(context).validate(policy.email, policy.telephone);

                                    if (isValid)
                                    {
                                        pols.Add(policy);
                                    }
                                    else
                                    {
                                        throw new Exception("One or More email/phone number already exist");
                                    }
                                }
                                else
                                {
                                    pols.Add(policy);
                                }

                            }
                            catch (Exception ex)
                            {
                                Logger.InfoFormat("Error occurred. Detail {0}", ex.ToString());
                                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
                            }
                            //pols.Add(policy);
                        }
                    }
                }

                using(var _context= context)
                {
                    _context.fl_policyinput.AddRange(pols);
                    _context.SaveChanges();

                    bool IsNewCustomer = false;
                    var userpwd = string.Empty;
                    long userId;

                    foreach (var polInput in pols)
                    {
                        IsNewCustomer = true;
                        userpwd = WebUtils.UserPwd;
                        var defaultDate = (DateTime)SqlDateTime.Null;
                        var user = new CustomerUser()
                        {
                            username = polInput.policyno,
                            datecreated = DateTime.Now,
                            email = polInput.email,
                            Name = string.Format("{0} {1}", polInput.surname, polInput.othername),
                            password = new MD5Password().CreateSecurePassword(userpwd),
                            phone = polInput.telephone,
                            status = (int)UserStatus.New,
                            passworddate = defaultDate,
                            modifydate = defaultDate,
                            firstLoginDate = defaultDate,
                            lastLoginDate = defaultDate,
                            IsDeleted = false
                        };
                        new CustomerAuthSystem(_context).Save(user);

                        userId = user.Id;

                        var custPolicy = new CustomerPolicy()
                        {
                            CustomerUserId = userId,
                            Policyno = polInput.policyno
                        };
                        new CoreSystem<CustomerPolicy>(_context).Save(custPolicy);
                        var xpolType = xpoltype != null && !string.IsNullOrEmpty(xpoltype.code) ? xpoltype.code : polInput.poltype;
                        if (IsNewCustomer)
                        {
                            new NotificationSystem(_context).SendPolicyCreationNotiification(polInput, polInput.policyno, userpwd, xpolType);
                            if (!string.IsNullOrEmpty(polInput.email))
                            {
                                SendEmailNotification(polInput, userpwd, polInput.email);
                            }
                        } 
                    }
                }

                return new JsonResult()
                {
                    Data = $"{pols.Count} Policies Created Successfully"
                };
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Uploading Policy. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult ViewPolicy(long Id)
        {
            try
            {
                var poldetails = new fl_policyinput();
                var nokBen = new List<NextofKin_BeneficiaryStaging>();
                using (context)
                {
                    poldetails = new PolicySystem(context).Get(Id);
                    nokBen = new CoreSystem<NextofKin_BeneficiaryStaging>(context).FindAll(x => x.PolicyId == Id).ToList();

                    var state = new CoreSystem<fl_state>(context).FindAll(x => x.Id == poldetails.locationid).Select(x=>x.Name).FirstOrDefault();
                    var group = new CoreSystem<fl_grouptype>(context).FindAll(x => x.grpcode == poldetails.grpcode).Select(x=>x.grpname).FirstOrDefault();
                    var policyType = new CoreSystem<fl_poltype>(context).FindAll(x => x.poltype == poldetails.poltype).Select(x=>x.poldesc).FirstOrDefault();
                    var agent = new CoreSystem<fl_agents>(context).FindAll(x => x.agentcode == poldetails.agentcode).Select(x=>x.agentname).FirstOrDefault();
                    var sex = poldetails.sex;
                    var religion = poldetails.religion;
                    ViewBag.Id = Id;
                    GetReationShip();
                    ViewBag.Location = GetStates2(state);
                    getPolicyTypeForDirectPolicyInput(policyType);
                    ViewBag.Agent = GetAgents(agent);
                    getGroup(group);
                    GetReligion(religion);
                    GetGender(sex);
                    ViewBag.picture = "Passport_" + poldetails.IdentityNumber + ".png";
                    var polModel = new SignUpBindingModel();
                    CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

                    polModel.PersonalInfo = new PesonalInfoBindingModel()
                    {
                        AgentCode = poldetails.agentcode,
                        Amount = (decimal)poldetails.premium,
                        CommencementDate = (DateTime)poldetails.accdate,
                        Dob = !string.IsNullOrEmpty(poldetails.dob)? DateTime.ParseExact(poldetails.dob,
                                        "yyyyMMdd",CultureInfo.InvariantCulture) : (DateTime?)null, 
                        Email = poldetails.email,
                        Locationid = (int)poldetails.locationid,
                        Othernames = poldetails.othername,
                        Phone = poldetails.telephone,
                        PolicyType = new CoreSystem<fl_poltype>(context).FindAll(x => x.poltype == poldetails.poltype).FirstOrDefault().Id,
                        ResAddress = poldetails.peradd,
                        Surname = poldetails.surname,
                        RegNo=poldetails.policyno,
                        IdentityNumber=poldetails.IdentityNumber,
                        IdentityType=poldetails.IdentityType,
                        Beneficiary = nokBen.Where(x => x.Category == (int)Category.Beneficiary)
                                        .Select(x => new NextofKinBeneficiaryBindingModel()
                                        {
                                            Id = x.Id,
                                            Address = x.Address,
                                            //Dob = x.Dob.ToShortDateString(),
                                            Dob = x.Dob.GetValueOrDefault().ToShortDateString(),
                                            Email = x.Email,
                                            Name = x.Name,
                                            Phone = x.Phone,
                                            Proportion = (decimal)x.Proportion,
                                            Relationship = ((RelationShip)Enum.Parse(typeof(RelationShip), x.RelationShip)).ToString()
                                        }).ToList(),
                        NextofKin = nokBen.Where(x => x.Category == (int)Category.NextofKin)
                                .Select(x => new NextofKinBeneficiaryBindingModel()
                                {
                                    Id = x.Id,
                                    Address = x.Address,
                                    //Dob = x.Dob.ToShortDateString(),
                                    //Dob = x.Dob.GetValueOrDefault().ToShortDateString(),
                                    Email = x.Email,
                                    Name = x.Name,
                                    Phone = x.Phone,

                                }).FirstOrDefault(),
                    };
                    return PartialView("_managepolicy", polModel);
                }
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public JsonResult PolicynoAutoComplete(string term)
        {
            var products = new PolicySystem(currentContext).FindAll(x=> (x.policyno.ToLower().Contains(term.ToLower()) 
            || x.surname.ToLower().Contains(term.ToLower()) || x.othername.ToLower().Contains(term.ToLower()))
            && WebSecurity.ModulePolicyTypes.Contains(x.poltype)).OrderBy(x=>x.surname).OrderBy(x=>x.othername).Take(15).ToList()
                .Select(x => new
                {
                    value = x.policyno,
                    label = string.Format("{0} {1}../{2}", x.surname, x.othername,x.policyno)
                }).ToList();

            //var prodJson= new JavaScriptSerializer().Serialize(products);
            return Json(products, JsonRequestBehavior.AllowGet);
        }

        public JsonResult GetBeneficiary(long customerId, long benId)
        //public ActionResult GetBeneficiary(long Id)
        {
            var beneficiary = new CoreSystem<NextofKin_BeneficiaryStaging>(context).FindAll(x=>x.PolicyId==customerId).ToList();
            var rel = beneficiary.Where(x => x.Id == benId).Select(x => x.RelationShip).FirstOrDefault();
            GetReationShip(rel);
            var polModel = new SignUpBindingModel();
            polModel.PersonalInfo = new PesonalInfoBindingModel()
            {
                Beneficiary = beneficiary.Where(x => x.Id == benId).Select(x => new NextofKinBeneficiaryBindingModel
                {
                    Id = x.Id,
                    Address = x.Address,
                    //Dob = x.Dob.ToShortDateString(),
                    Dob = x.Dob.GetValueOrDefault().ToShortDateString(),
                    Email = x.Email,
                    Name = x.Name,
                    Phone = x.Phone,
                    Proportion = (decimal)x.Proportion,
                    Relationship = x.RelationShip
                }).ToList()
            };

            //JsonSerializerSettings jss = new JsonSerializerSettings { ReferenceLoopHandling = ReferenceLoopHandling.Ignore };
            //var result = JsonConvert.SerializeObject(polModel, Formatting.Indented, jss);
            return Json(polModel, JsonRequestBehavior.AllowGet);
            //return PartialView("_updateBeneficiary", beneficiary);
            //return new JsonResult()
            //{
            //    Data = beneficiary
            //};

            
        }

        [AllowAnonymous]
        public JsonResult UploadPicture(string term)
        {
            try
            {
                var pictureUrl = "";
                var fileName = "";
                var fileContent = Request.Files[0];
                //if (fileContent != null && fileContent.ContentLength > 0)
                //{
                //    // get a stream
                //    var stream = fileContent.InputStream;
                //    // and optionally write the file to disk
                //    fileName = Path.GetFileName(fileContent.FileName);
                //    var path = Path.Combine(ConfigurationManager.AppSettings["PicturePath"], fileName);
                //    using (var fileStream = System.IO.File.Create(path))
                //    {
                //        stream.CopyTo(fileStream);
                //    }
                //}

                var binarypic = convertTobyte(fileContent);
                var binarystringpic = Convert.ToBase64String(binarypic);

                pictureUrl = ConfigurationManager.AppSettings["BasePicUrl"] + fileName;

                var data = new
                {
                    //Url = pictureUrl,
                    Url = Convert.ToBase64String(binarypic),
                    //FileName = fileName
                    FileName = binarystringpic
                };
                return Json(data, JsonRequestBehavior.AllowGet);

            }
            catch (Exception)
            {

                throw;
            }
        }

        public byte[] convertTobyte(HttpPostedFileBase c)
        {
            byte[] imageBytes = null;
            BinaryReader reader = new BinaryReader(c.InputStream);
            imageBytes = reader.ReadBytes((int)c.ContentLength);
            return imageBytes;
        }
        [HttpPost]
        public ActionResult CreateAddPolicy(PolicyBindingModel model)
        {
            try
            {
                var newpolicy = new fl_policyinput();

                var user = WebSecurity.GetCurrentUser(Request);

                var pol = user.CustomerUser.CustomerPolicies.Select(x => x.Policyno).ToList()[0];
                using (var _context = context)
                {
                    var policy = new CoreSystem<fl_policyinput>(context).FindAll(x => x.policyno == pol).FirstOrDefault();

                    //var polType = _context.fl_poltype.Where(x => x.poltype == policy.poltype).FirstOrDefault();
                    //var xpolType = polType != null && !string.IsNullOrEmpty(polType.code) ? polType.code : policy.poltype;

                    newpolicy.accdate = DateTime.Now;
                    newpolicy.datecreated = DateTime.Now;
                    newpolicy.dob = policy.dob;
                    newpolicy.email = policy.email;
                    newpolicy.locationid = model.Locationid;
                    newpolicy.othername = policy.othername;
                    newpolicy.poltype = new CoreSystem<fl_poltype>(context).Get(model.PolicyType).poltype;
                    newpolicy.premium = model.Amount;
                    newpolicy.status = (int)Flex.Data.Enum.Status.Active;
                    newpolicy.surname = policy.surname;
                    newpolicy.telephone = policy.telephone;
                    newpolicy.IdentityNumber = policy.IdentityNumber;
                    newpolicy.IdentityType = policy.IdentityType;

                    var polType = _context.fl_poltype.Where(x => x.Id == model.PolicyType).FirstOrDefault();
                    var xpolType = polType != null && !string.IsNullOrEmpty(polType.code) ? polType.code : polType.poltype;

                    var policynoSno = new SerialNumberSource().GetNextNumber(polType.poltype);


                    Logger.InfoFormat("Serial Number {0} gotten", policynoSno);
                    var policyno = ConfigUtils.PolicyNoFormat;
                    var xlocation = new CoreSystem<fl_location>(_context).Get((int)model.Locationid);
                    if (xlocation == null)
                    {
                        throw new Exception("Invalid Location");
                    }

                    var pcn = policynoSno.ToString().PadLeft(ConfigUtils.policynoLenght, '0');
                    policyno = policyno.Replace("{PolicyType}", xpolType).Replace("{Location}", xlocation.loccode)
                                  .Replace("{Year}", DateTime.Today.ToString("yy"))
                                  .Replace("{SerialNo}", pcn);

                    newpolicy.policyno = policyno;

                    using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                    {
                        try
                        {
                            new PolicySystem(context).savePolicy(newpolicy);
                            var userpwd = string.Empty;


                            userpwd = WebUtils.UserPwd;
                            var defaultDate = (DateTime)SqlDateTime.Null;
                            var custPolicy = new CustomerPolicy()
                            {
                                CustomerUserId = user.CustomerUserID,
                                Policyno = newpolicy.policyno
                            };
                            new CoreSystem<CustomerPolicy>(context).Save(custPolicy);

                            new NotificationSystem(context).SendPolicyCreationNotiification(newpolicy, user.CustomerUser.username, string.Empty, xpolType);

                            transaction.Commit();

                        }
                        catch
                        {
                            transaction.Rollback();
                            throw;
                        }
                    }
                }

                return new JsonResult()
                {
                    Data = string.Format("Policy with policy Number {0} created successfully", newpolicy.policyno)
                };
            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Error Occurred. Details  [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }


        }
      
    }
}