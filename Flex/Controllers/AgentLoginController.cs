using Flex.Business;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using Flex.Util;
using Flex.Utility.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Flex.Controllers
{
    [AllowAnonymous]
    public class AgentLoginController : BaseController
    {
        // GET: Login
        public ActionResult Index()
        {
            try
            {

                var modules = new ModuleSystem(context).GetAll().ToList();
                ViewBag.Modules = new SelectList(modules, "Code", "Name");
            }
            catch (Exception ex)
            {

                Logger.ErrorFormat("Error Occurred. Details [error: {0}, StackTrace: {1}]", ex.ToString(), ex.StackTrace);
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.ToString()); 
            }
            return View();
        }

        [HttpPost]
        [AllowAnonymous]
        //[ValidateAntiForgeryToken]
        public ActionResult Login(string username, string password)
        {
            AuthResult res = null;
            try
            {
                JsonResult resp = null;
                UserAuthResponseViewModel model = null;

                using(var _context= context)
                {
                    res = new UserAuthSystem(_context).AuthenticateUser(username, password);
                }
                
                if (new AuthStatus[] { AuthStatus.Normal, AuthStatus.FirstTime, AuthStatus.PasswordExpired, AuthStatus.AlreadyLoggedOn }.Any(x => x == res.Status))
                {
                    model = new UserAuthResponseViewModel
                    {
                        User = new UserAuthViewModel
                        {
                            Name = res.Session.fl_password.Name,
                            Username = res.Session.fl_password.userid,
                            //Branch = (int)res.Session.fl_password.branch,
                            Dept = res.Session.fl_password.userdept
                        },
                        IsFirst = res.Status == AuthStatus.FirstTime,
                        IsExpired = res.Status == AuthStatus.PasswordExpired,
                        SessionTimeout = ConfigUtils.SessionTimeout,
                        Status=res.Status
                    };
                    model.Token = res.Session.Token;
                    model.Expires = res.Session.ExpiryDate.Value;

                    resp = new JsonResult()
                    {
                        Data = model,
                        
                    };

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
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.ToString());
            }
        }
        [HttpPost]
        [AllowAnonymous]
        //[ValidateAntiForgeryToken]
        public ActionResult AgentLogin(string username, string password)
        {
            AuthResult res = null;
            try
            {
                JsonResult resp = null;
                UserAuthResponseViewModel model = null;

                using (var _context = context)
                {
                    res = new AgentUserAuth(_context).AgentAuthenticateUser(username, password);
                }

                if (new AuthStatus[] { AuthStatus.Normal, AuthStatus.FirstTime, AuthStatus.PasswordExpired, AuthStatus.AlreadyLoggedOn }.Any(x => x == res.Status))
                {
                    model = new UserAuthResponseViewModel
                    {
                        User = new UserAuthViewModel
                        {
                            Name = res.Session.fl_agents.agentname,
                            Username = res.Session.fl_agents.agentphone,
                            Dept = res.Session.fl_agents.agenttype
                        },
                        IsFirst = res.Status == AuthStatus.FirstTime,
                        IsExpired = res.Status == AuthStatus.PasswordExpired,
                        SessionTimeout = ConfigUtils.SessionTimeout,
                        Status = res.Status
                    };
                    model.Token = res.Session.Token;
                    model.Expires = res.Session.ExpiryDate.Value;

                    resp = new JsonResult()
                    {
                        Data = model,

                    };

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
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.ToString());
            }
        }
        public ActionResult ChangePassword()
        {
            return View();
        }
            public ActionResult ChangePassword(ChangePasswordBindingModel xpass)
        {
            try
            {
                var usrSession = WebSecurity.GetCurrentUser(Request);

                JsonResult resp = null;
                var result = new ProcessResult();
                using (var _context = context)
                {
                    result = new UserAuthSystem(context).ChangePassword((Int64)usrSession.UserId, xpass.NewPassword, xpass.OldPassword);
                }
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