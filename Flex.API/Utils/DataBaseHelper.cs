using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Configuration;
using System.Linq;
using System.Web;

namespace Flex.API.Utils
{
    public class DataBaseHelper
    {
        public static FlexEntities GetContext(string name)
        {
            try
            {
                var _context = new FlexEntities();
                if (!string.IsNullOrEmpty(name))
                {
                    _context = new FlexEntities(name);
                }
                return _context;
            }
            catch (Exception)
            {
                return new FlexEntities();
            }
           
        }

        public class Constants
        {
            public const string SettingsKey = "DataBase.Settings";

        }

        public static string Getconfig(string key)
        {
            var wfSection = ConfigurationManager.GetSection(Constants.SettingsKey) as NameValueCollection;
            return wfSection[key];
        }

    }
}