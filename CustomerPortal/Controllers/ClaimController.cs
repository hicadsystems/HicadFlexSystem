using CustomerPortal.Util;
using Flex.Business;
using Flex.Data.Enum;
using Flex.Data.Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CustomerPortal.Controllers
{
    public class ClaimController : BaseController
    {
        // GET: Claim
        public ActionResult Index()
        {
            var user = WebSecurity.GetCurrentUser(Request);
            var pols = user.CustomerUser.CustomerPolicies.Select(x => x.Policyno).ToList();

            var clms = new ClaimSystem(context).RetrieveClaimRequest(pols,DateTime.Today.ToShortDateString(), DateTime.Today.ToShortDateString());
            return PartialView("_claimRequest", clms);
        }

        public ActionResult SearchClaim(string sdate, string edate)
        {
            var user = WebSecurity.GetCurrentUser(Request);
            var pols = user.CustomerUser.CustomerPolicies.Select(x => x.Policyno).ToList();

            var clms = new ClaimSystem(context).RetrieveClaimRequest(pols, sdate, edate);
            return PartialView("_tbclmReq", clms);
        }
        public ActionResult AddClaim()
        {
            GetClaimType();
            var user = WebSecurity.GetCurrentUser(Request);
            var pols = user.CustomerUser.CustomerPolicies.ToList();
            ViewBag.Policy= new SelectList(pols, "Policyno", "Policyno");

            return PartialView("_addClaim");

        }

        public ActionResult Save(string queryj)
        {
            try
            {
                var query = JsonConvert.DeserializeObject<dynamic>(queryj);
                string policyno = query.Policyno;
                string claimType = query.clmType;
                string amount = query.amount;
                string effDate = query.effDate;
                var clmreq = new ClaimRequest();
                clmreq.PolicyNo = policyno;
                clmreq.DateCreated = DateTime.Now;
                clmreq.ClaimType = (int)(ClaimType)Enum.Parse(typeof(ClaimType), claimType);
                clmreq.Status = (int)(Status)ClaimStatus.Pending;
                clmreq.EffectiveDate = Convert.ToDateTime(effDate);
                decimal xamount = 0.0M;
                if (clmreq.ClaimType == (int)ClaimType.PartialWithdrawal && !decimal.TryParse(amount, out xamount))
                {
                    throw new Exception("Invalid Amount");
                }
                if (!string.IsNullOrEmpty(amount))
                {
                    clmreq.Amount = Convert.ToDecimal(amount);
                }

                new CoreSystem<ClaimRequest>(context).Save(clmreq);

                //return new JsonResult()
                //{
                //    Data = "Claim Registered Successfully"
                //};

                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult CancelClaim(string Id)
        {
            try
            {
                var id = 0L;
                Int64.TryParse(Id, out id);
                var claim = new CoreSystem<ClaimRequest>(context).FindAll(x => x.Id == id).FirstOrDefault();
                if (claim != null)
                {
                    claim.Status = (int)(Status)ClaimStatus.Canceled;

                    new CoreSystem<ClaimRequest>(context).Update(claim, id);
                }
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
    }
}