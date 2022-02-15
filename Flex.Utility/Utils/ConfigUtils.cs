using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Configuration;
using System.Linq;
using System.Text;

namespace Flex.Utility.Utils
{
    public class ConfigUtils
    {
        class Constants
        {
            public const String SessionTimeout = "SessionTimeout";
            public const string UserName = "SMTPUserName";
            public const string Port = "SMTPPort";
            public const string Password = "SMTPPassword";
            public const string SMTPServer = "SMTPServer";
            public const string EnableSsl = "EnableSsl";
            public const string MailFrom = "MailFrom";
            public const string Sender = "Sender";
            public const string ReportPath = "ReportPath";
            public const string ReportPath2 = "ReportPath2";
            public const string PolicyNoFormat = "PolicyNoFormat";
            public const string NotificationMessage = "NotificationMessage";

        }

        public static Int32 SessionTimeout
        {
            get { return Convert.ToInt32(ConfigurationManager.AppSettings[Constants.SessionTimeout] ?? "5"); }
        }

        public static string ReportPath
        {
            get { return ConfigurationManager.AppSettings[Constants.ReportPath] ?? string.Empty; }
        }

        public static string ReportPath2
        {
            get { return ConfigurationManager.AppSettings[Constants.ReportPath2] ?? string.Empty; }
        }
        private static NameValueCollection Email
        {
            get
            {
                NameValueCollection emailDetails = null;
                try
                {
                    emailDetails = ConfigurationManager.GetSection("Mail") as NameValueCollection;
                    return emailDetails;
                }
                catch (Exception)
                {
                    return emailDetails;
                }
                
            }
        }

        public static string Username
        {
            get
            {
                try
                {
                    return Email[Constants.UserName];
                }
                catch
                {
                    return string.Empty;
                }
            }
            
        }

        public static string Port
        {
            get
            {
                try
                {
                    return Email[Constants.Port];
                }
                catch
                {
                    return string.Empty;
                }
            }

        }

        public static string Password
        {
            get
            {
                try
                {
                    return Email[Constants.Password];
                }
                catch
                {
                    return string.Empty;
                }
            }

        }

        public static string SMTPServer
        {
            get
            {
                try
                {
                    return Email[Constants.SMTPServer];
                }
                catch
                {
                    return string.Empty;
                }
            }

        }

        public static bool EnableSsl
        {
            get
            {
                try
                {
                    return Convert.ToBoolean(Email[Constants.EnableSsl]);
                }
                catch
                {
                    return false;
                }
            }

        }

        public static string MailFrom
        {
            get
            {
                try
                {
                    return Email[Constants.MailFrom];
                }
                catch
                {
                    return string.Empty;
                }
            }

        }

        public static string Sender
        {
            get
            {
                try
                {
                    return Email[Constants.Sender];
                }
                catch
                {
                    return string.Empty;
                }
            }

        }

        public static string PolicyNoFormat
        {
            get
            {
                try
                {
                    return ConfigurationManager.AppSettings["PolicyNoFormat"] ?? string.Empty;
                }
                catch (Exception)
                {

                    return string.Empty;
                }
            }
        }

        public static int policynoLenght
        {
            get
            {
                try
                {
                    return Convert.ToInt32(ConfigurationManager.AppSettings["PolicynoLenght"]);
                }
                catch (Exception)
                {
                    return 5;
                }

            }
        }

        public static string MessagePath
        {
            get
            {
                try
                {
                    return ConfigurationManager.AppSettings[Constants.NotificationMessage];
                }
                catch (Exception ex)
                {
                    
                    throw;
                }
            }
        }
    }
}
