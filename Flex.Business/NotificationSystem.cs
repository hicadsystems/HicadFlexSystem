using Flex.Data.Model;
using Flex.Utility.Utils;
using log4net;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Text.RegularExpressions;
using Flex.Data.ViewModel;
using System.Web.Script.Serialization;
using Flex.Data.Enum;
using System.Web;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Flex.Business
{
    public class NotificationSystem
    {
        public DbContext _context;
        public NotificationSystem(DbContext context)
        {
            _context = context;
        }
        public ILog Logger { get { return log4net.LogManager.GetLogger("Flex"); } }

        public bool SendMail(PendingEmail pemail, out string error)
        {
            error = string.Empty;
            bool IsSent = false;
            StringBuilder sbEmailPtn = new StringBuilder();
            sbEmailPtn.Append(@"^(?("")("".+?""@)|(([0-9a-zA-Z]((\.(?!\.))|[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)");
            sbEmailPtn.Append(@"(?<=[0-9a-zA-Z])@))(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|");
            sbEmailPtn.Append(@"(([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,6}))$");

            StringBuilder sbDigits = new StringBuilder();
            sbDigits.Append(@"^\d+$");



            if (!Regex.IsMatch(pemail.To, sbEmailPtn.ToString()))
            {
                error = "Wrong Email Address";

                return IsSent;
            }

            MailMessage message = new MailMessage();
            message.From = new MailAddress(ConfigUtils.MailFrom, pemail.From);

            message.To.Add(new MailAddress(pemail.To));
            message.Subject = pemail.Subject;

            message.IsBodyHtml = (bool)pemail.IsBodyHtml;

            message.Body = pemail.Body;

            SmtpClient client = new SmtpClient();

            client.Host = ConfigUtils.SMTPServer;
            client.Port = Convert.ToInt32(ConfigUtils.Port);
            client.EnableSsl = ConfigUtils.EnableSsl;
            client.UseDefaultCredentials = false;

            client.Credentials = new System.Net.NetworkCredential(ConfigUtils.Username, ConfigUtils.Password);

            client.Timeout = 30000000;
            //client.EnableSsl = true;
            System.Net.ServicePointManager.ServerCertificateValidationCallback = delegate(object s,
                   System.Security.Cryptography.X509Certificates.X509Certificate certificate,
                   System.Security.Cryptography.X509Certificates.X509Chain chain,
                   System.Net.Security.SslPolicyErrors sslPolicyErrors)
            {
                return true;
            };

            try
            {
                client.Send(message);
                IsSent = true;
            }
            catch (Exception ex)
            {
                error = ex.Message;
                Logger.ErrorFormat("An Error Occurred. Details [{0}--{1}]",ex.ToString(),ex.StackTrace);
            }
            return IsSent;
        }

        public void SendPolicyCreationNotiification(fl_policyinput polInput,string username, string userpwd,string polType)
        {
            //StringBuilder emailBody = new StringBuilder();
            //emailBody.AppendFormat("<p>Hello {0} {1}</p><br/><<p>Your Policy has been approved.</p>"
            //    , polInput.surname, polInput.othername);
            //emailBody.Append("Please find details of your policy below.</p>");
            //emailBody.AppendFormat("<p>Policy No.: {0}</p><p>Username: {1}</p><p>Password: {2}</p><br/>",
            //    polInput.policyno, polInput.policyno, userpwd);
            //emailBody.Append("<p>Thanks<p/>");
            var msgDetail = GetMessage(MessageType.PolicyCreation, polType);
            if (msgDetail != null && msgDetail.Any())
            {
                var emailMessage = msgDetail.Where(x => x.NotificationType == NotificationType.Email).FirstOrDefault();
                var pEmail = new PendingEmail()
                {
                    Body = emailMessage.Message.Replace("{Surname}", polInput.surname).Replace("{OtherName}", polInput.othername).Replace("{PolicyNo}", polInput.policyno)
                            .Replace("{Username}",username).Replace("{Password}", userpwd),
                    DueDate = DateTime.Now,
                    From = "NLPC",
                    IsBodyHtml = true,
                    Subject = string.Format("Welcome on Board {0} {1}", polInput.surname, polInput.othername),
                    To = polInput.email,
                    IsSent=false,
                    Retries=0,
                    RetryCount=0

                };
                new CoreSystem<PendingEmail>(_context).Save(pEmail);

                var smsMsg = msgDetail.Where(x => x.NotificationType == NotificationType.Sms).FirstOrDefault();

                var pSms = new fl_pendingSMS()
                {
                    Application = "Flex",
                    isSent = false,
                    message = smsMsg.Message.Replace("{Surname}", polInput.surname).Replace("{OtherName}", polInput.othername).Replace("{PolicyNo}", polInput.policyno)
                            .Replace("{Username}", polInput.policyno).Replace("{Password}", userpwd),
                    retrycount = 0,
                    telephone = polInput.telephone
                };

                new CoreSystem<fl_pendingSMS>(_context).Save(pSms);
            }
        }

        public bool validate(string email, string phone)
        {
            bool isValid = true;
            var query = new CoreSystem<fl_policyinput>(_context).FindAll(x => (x.email == email || x.telephone == phone) && string.IsNullOrEmpty(x.exitdate));
            var pol = query.FirstOrDefault();
            if (pol != null)
            {
                isValid = false;
            }

            return isValid;
        }
        //public void SendPolicyCreationNotiification(fl_policyinput polInput)
        //{
        //    StringBuilder emailBody = new StringBuilder();
        //    emailBody.AppendFormat("<p>Hello {0} {1}</p><br/><<p>Your Policy has been approved.</p>"
        //        , polInput.surname, polInput.othername);
        //    emailBody.Append("Please find details of your policy below.</p>");
        //    emailBody.AppendFormat("<p>Policy No.: {0}</p><br/>",
        //        polInput.policyno);
        //    emailBody.Append("<p>Thanks<p/>");
        //    var pEmail = new PendingEmail()
        //    {
        //        Body = emailBody.ToString(),
        //        DueDate = DateTime.Now,
        //        From = "NLPC",
        //        IsBodyHtml = true,
        //        Subject = string.Format("Welcome on Board {0} {1}", polInput.surname, polInput.othername),
        //        To = polInput.email,

        //    };
        //    var err = string.Empty;
        //    new NotificationSystem().SendMail(pEmail, out err);

        //}

        public List<MessageViewModel> GetMessage(MessageType msgType, string polType)
        {
            try
            {
                string file = ConfigUtils.MessagePath;
                Logger.InfoFormat("Path: {0}", file);
                //HttpServerUtilityBase.Server.MapPath(ConfigUtils.MessagePath);;
                string Json = System.IO.File.ReadAllText(file);
                JObject obj = JObject.Parse(Json);
                var jarr = (JArray)obj["Messages"];
                List<MessageViewModel> message = jarr.ToObject<List<MessageViewModel>>();
                //JObject obj = JObject.Parse(jsonString);
                //var jarr = obj["data"].Value<JArray>();
                //List<Person> lst = jarr.ToObject<List<Person>>();
                //var message = JsonConvert.DeserializeObject<List<MessageViewModel>>(token.);
                //ser.Deserialize<List<MessageViewModel>>(Json);
                message = message.Where(x => x.PolicyTypes.Contains(polType) && x.MessageType==msgType).ToList();
                return message;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return null;
            }
        }

    }
}
