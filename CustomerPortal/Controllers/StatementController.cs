using CustomerPortal.Util;
using Flex.Business;
using Flex.Data.ViewModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CustomerPortal.Controllers
{
    public class StatementController : BaseController
    {
        // GET: Statement
        public ActionResult Index(string Policyno=null)
        {
            try
            {
                if (string.IsNullOrEmpty(Policyno))
                {
                    var user = WebSecurity.GetCurrentUser(Request);
                    var pols = user.CustomerUser.CustomerPolicies.Select(x => x.Policyno).ToList();
                    Policyno = pols[0];
                    ViewBag.Policyno = new SelectList(user.CustomerUser.CustomerPolicies.ToList(), "Policyno", "Policyno", Policyno);
                }
                var stmt = new PaymentSystem(context).searchPaymentHistory(Policyno);
                return PartialView("_statement",stmt);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SearchStatement(StatementModel stmtquery)
        {
            try
            {
                var dt = string.Empty;
                var dtfrom = string.Empty;
                var dtto = string.Empty;
                string page = string.Empty;
                string size = string.Empty;

                if (stmtquery.Page != null)
                {
                    page = stmtquery.Page.Page;
                    size = stmtquery.Page.Size;
                }
                if (!string.IsNullOrEmpty(stmtquery.Month) && !string.IsNullOrEmpty(stmtquery.Year))
                {
                    var lday = DateTime.DaysInMonth(int.Parse(stmtquery.Year), int.Parse(stmtquery.Month)).ToString();
                    dtfrom = string.Concat(stmtquery.Year, "/", stmtquery.Month, "/01");
                    dtto = string.Concat(stmtquery.Year, "/", stmtquery.Month, "/", lday);
                }
                if (!string.IsNullOrEmpty(stmtquery.DateFrom))
                {
                    dtfrom = stmtquery.DateFrom;
                }
                if (!string.IsNullOrEmpty(stmtquery.DateTo))
                {
                    dtto = stmtquery.DateTo;
                }
                var stmt = new PaymentSystem(context).searchPaymentHistory(stmtquery.PolicyNo, dtfrom, dtto,page,size);

                return PartialView("_tbStmt", stmt);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
    }
}