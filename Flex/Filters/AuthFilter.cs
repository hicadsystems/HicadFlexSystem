using Flex.Data.Model;
using Flex.Util;
using System;
using System.Collections.Generic;
using System.Diagnostics.Contracts;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace Flex.Filters
{
    public class AuthFilter : ActionFilterAttribute
    {
       public override void OnActionExecuting(ActionExecutingContext actionContext)
        {
            if (!SkipAuthorization(actionContext))
            {
               
                UserSession session = null;
                try
                {
                    session = WebSecurity.GetCurrentUser(actionContext.HttpContext.Request);
                    //var principal= new CustomUserPrincipal()
                    //.RequestContext.HttpContext. = session;
                    Thread.CurrentPrincipal = session;
                    base.OnActionExecuting(actionContext);
                }
                catch (Exception ex) { }
                if (session == null || string.IsNullOrEmpty(WebSecurity.Module))
                {
                    if (actionContext.HttpContext.Request.IsAjaxRequest())
                    {
                        // For an Ajax request, just end the request 
                        actionContext.HttpContext.Response.StatusCode = 401;
                        actionContext.HttpContext.Response.End();
                    }else
                    {
                        actionContext.Result = new RedirectToRouteResult(new RouteValueDictionary { { "controller", "Login" }, { "action", "Index" } });
                    }
                }
            }
        }

        private bool SkipAuthorization(ActionExecutingContext actionContext)
        {
            Contract.Assert(actionContext != null);

            return actionContext.ActionDescriptor.IsDefined(typeof(AllowAnonymousAttribute),inherit: true)
                   || actionContext.ActionDescriptor.ControllerDescriptor.IsDefined(typeof(AllowAnonymousAttribute), inherit: true);
        }
    }
}