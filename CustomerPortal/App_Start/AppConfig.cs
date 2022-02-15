using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;

namespace CustomerPortal.App_Start
{
    public class AppConfig
    {
        public static string CurrentVersion
        {
            get
            {
                return ConfigurationManager.AppSettings["appVersion"];
            }
        }
    }
}