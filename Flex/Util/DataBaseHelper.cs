using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Configuration;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace Flex.Util
{
    public static class DataBaseHelper
    {
        public class Constants
        {
            public const string SettingsKey = "DataBase.Settings";

        }
        public static string GetConfig(string key)
        {
            var wfSection = ConfigurationManager.GetSection(Constants.SettingsKey) as NameValueCollection;
            return wfSection[key];
        }

        private static FlexEntities _context;
        private static Dictionary<string,FlexEntities> _currentContext= new Dictionary<string, FlexEntities>();
        public static FlexEntities Primarydbcontext
        {
            get
            {
                _context = new FlexEntities();
                //if (HttpContext.Current.Session["PrimaryContext"] == null)
                //{
                //    _context = new FlexEntities();
                //    HttpContext.Current.Session["PrimaryContext"] = _context;
                //}
                //return (FlexEntities)HttpContext.Current.Session["PrimaryContext"];

                return _context;
            }
        }

        public static FlexEntities dbcontext(string AppContext)
        {
            
            try
            {
                FlexEntities _dbContext = new FlexEntities();
                //Dictionary<string, FlexEntities> currentContext = new Dictionary<string, FlexEntities>();
                //if (HttpContext.Current.Session["CurrentContext"] == null 
                //    || !((Dictionary<string, FlexEntities>)HttpContext.Current.Session["CurrentContext"]).ContainsKey(AppContext))
                //{
                //    _currentContext.Add(AppContext,new FlexEntities(GetConfig(AppContext)));
                //    HttpContext.Current.Session["CurrentContext"] = _currentContext;
                //}

                //return ((Dictionary<string, FlexEntities>)HttpContext.Current.Session["CurrentContext"])[AppContext];

                _dbContext = new FlexEntities(GetConfig(AppContext));

                return _dbContext;
            }
            catch (Exception)
            {

                throw;
            }
        }

    }


}