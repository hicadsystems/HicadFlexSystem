using CustomerPortal.Util;
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

    }
}