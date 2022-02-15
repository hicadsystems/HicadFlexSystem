using Flex.Business;
using Flex.Data.Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace CustomerPortal.Util
{
    public class WebSecurity
    {
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
            HttpCookie myCookie = HttpContext.Current.Request.Cookies["auth"];
            if (myCookie != null)
            {
                var authjson = HttpUtility.UrlDecode(myCookie.Value);

                var authobj= JsonConvert.DeserializeObject<dynamic>(authjson);
                return authobj.Token;
            }
            return null;
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
                return new UserSessionSystem(DataBaseHelper.dbcontext).GetActiveSession(_token);
            }
        }
    }
}