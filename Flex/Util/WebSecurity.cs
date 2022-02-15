using Flex.Business;
using Flex.Data.Model;
using log4net;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace Flex.Util
{
    public class WebSecurity
    {
        public ILog Logger { get { return log4net.LogManager.GetLogger("Flex"); } }

        private DbContext _context;

        public WebSecurity() { }

        public WebSecurity(DbContext context)
        {
            this._context = context;
        }
        public static UserSession GetCurrentUser(HttpRequestBase request)
        {
            String token = "";
            try
            {
                token = HttpUtility.UrlDecode(request.Headers.GetValues("authtoken").FirstOrDefault());
                if (string.IsNullOrEmpty(token))
                {
                    throw new Exception();
                }
            }
            catch {
                token = GetTokenFromCookie();
            }
            return token == null ? null : GetCurrentUser(token);
        }

        private static string GetTokenFromCookie()
        {
            try
            {
                HttpCookie myCookie = HttpContext.Current.Request.Cookies["auth"];
                if (myCookie != null)
                {
                    var authjson = HttpUtility.UrlDecode(myCookie.Value);

                    var authobj = JsonConvert.DeserializeObject<dynamic>(authjson);
                    return authobj.Token;
                }
                return null;
            }
            catch (Exception ex)
            {
                new WebSecurity().Logger.ErrorFormat("Error Occurred. Details {0}", ex.ToString());
                throw;
            }
            
        }

        public static string Module
        {
            get
            {
                try
                {
                    HttpCookie myCookie = HttpContext.Current.Request.Cookies["Module"];
                    if (myCookie != null)
                    {
                        var module = HttpUtility.UrlDecode(myCookie.Value);

                        return module;
                    }
                    return string.Empty;
                }
                catch (Exception)
                {
                    return string.Empty;
                }
            }
        }
        public static UserSession GetCurrentUser(String token)
        {
            return new UserDAOProxy(token).GetUserSession();
        }
        class UserDAOProxy
        {
            string _token = null;
            public UserDAOProxy(string token)
            {
                _token = token;
            }

            public UserSession GetUserSession()
            {
                UserSession session;
                using(var _context= DataBaseHelper.Primarydbcontext)
                {
                    session= new UserSessionSystem(_context).GetActiveSession(_token);
                }
                return session;
            }
        }

        public static string CurrentUser(HttpRequestBase request)
        {
            try
            {
                var user = GetCurrentUser(request).fl_password.Name;
                return user;
            }
            catch (Exception)
            {
                return string.Empty;
            }
        }

        public static List<string> ModulePolicyTypes
        {
            get
            {
                try
                {
                    if (!string.IsNullOrEmpty(Module))
                    {
                        var polytpes = new ModuleSystem(DataBaseHelper.Primarydbcontext).GetModulesPolicyTypes(Module);

                        return polytpes;
                    }
                    return null;
                }
                catch (Exception ex)
                {
                    throw;
                }
            }
        }
    }
}