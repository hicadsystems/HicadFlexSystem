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
    public class PaymentChannelController : BaseController
    {
        public ActionResult Index()
        {
            var user = WebSecurity.GetCurrentUser(Request);
            return PartialView("_paymentchannel");
        }
        public ActionResult ussd()
        {
            return PartialView("_paymentchannel2");
        }
        public ActionResult Paymentchannel2()
        {
            var user = WebSecurity.GetCurrentUser(Request);
            return View();
        }

        public ActionResult Xpressspay()
        {
            GetPolicyType();

            var user = WebSecurity.GetCurrentUser(Request);

            var pols = user.CustomerUser.CustomerPolicies.Select(x => x.Policyno);

            var details = new CoreSystem<vwPolicy>(context).FindAll(x => pols.Contains(x.policyno)).ToList();

            return PartialView("_xpresssPay", details);
            //return PartialView("_xpresssPay");

        }
        public ActionResult paystack()
        {
            GetPolicyType();

            var user = WebSecurity.GetCurrentUser(Request);

            var pols = user.CustomerUser.CustomerPolicies.Select(x => x.Policyno);

            var details = new CoreSystem<vwPolicy>(context).FindAll(x => pols.Contains(x.policyno)).ToList();

            return PartialView("_paystackPay", details);
            //return PartialView("_xpresssPay");

        }
    }
}