using CustomerPortal.Util;
using Flex.Business;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using Flex.Utility.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web;
using System.Web.Mvc;

namespace CustomerPortal.Controllers
{
    public class LoginController : BaseController
    {
        //private FlexEntities context = new FlexEntities();

        // GET: Login
        [AllowAnonymous]
        public ActionResult Index()
        {
            return View();
        }


        [HttpPost]
        [AllowAnonymous]
        public ActionResult login(string username, string password)
        {
            AuthResult res = null;
            try
            {
                JsonResult resp = null;
                UserAuthResponseViewModel model = null;
                Session["xpassme"] = password;
                Session["xme"] = username;

                res = new CustomerAuthSystem(context).AuthenticateUser(username, password);
                if (new AuthStatus[] { AuthStatus.Normal, AuthStatus.FirstTime, AuthStatus.PasswordExpired, AuthStatus.AlreadyLoggedOn }.Any(x => x == res.Status))
                {
                    model = new UserAuthResponseViewModel
                    {
                        User = new UserAuthViewModel
                        {
                            Name = res.Session.CustomerUser.Name,
                            Email = res.Session.CustomerUser.email,
                            Username = res.Session.CustomerUser.username,
                            Mobile = res.Session.CustomerUser.phone
                        },
                        IsFirst = res.Status == AuthStatus.FirstTime,
                        IsExpired = res.Status == AuthStatus.PasswordExpired,
                        SessionTimeout = ConfigUtils.SessionTimeout
                    };
                    model.Token = res.Session.Token;
                    model.Expires = res.Session.ExpiryDate.Value;
                    model.Status = res.Status;
                    resp = new JsonResult()
                    {
                        Data = model
                    };
                    //resp.StatusCode=OK;
                }
                else
                {
                    resp = new JsonResult()
                    {
                        Data = res,

                    };
                }
                return resp;
            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Error Occurred. Details [error: {0}, StackTrace: {1}]", ex.ToString(), ex.StackTrace);
                throw;
            }
        }

        public ActionResult ChangePassword(ChangePasswordBindingModel xpass)
        {
            try
            {
                var usrSession = WebSecurity.GetCurrentUser(Request);

                JsonResult resp = null;
                var result = new CustomerAuthSystem(context).ChangePassword((Int64)usrSession.CustomerUserID, xpass.NewPassword, xpass.OldPassword);
                resp = new JsonResult()
                {
                    Data = result

                };

                return resp;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.ToString());
            }
        }
       
    }
}