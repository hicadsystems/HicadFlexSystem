using CustomerPortal.Util;
using Flex.Business;
using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CustomerPortal.Controllers
{
    public class PolicySummaryController : BaseController
    {
        // GET: PolicySummary
        public ActionResult Index()
        {
            var user = WebSecurity.GetCurrentUser(Request);

            var pols = user.CustomerUser.CustomerPolicies.Select(x=> x.Policyno);

            var details = new CoreSystem<vwPolicy>(context).FindAll(x => pols.Contains(x.policyno)).ToList();

            return PartialView("_policySummary",details);
        }
    }
}