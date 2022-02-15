using Flex.Business;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.Utility;
using Flex.Data.ViewModel;
using Flex.Util;
using Flex.Utility.Utils;
using log4net;
using MoreLinq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Mvc;

namespace Flex.Controllers
{
    public class BaseController : Controller
    {
        public ILog Logger { get { return log4net.LogManager.GetLogger("Flex"); } }

        protected FlexEntities context = DataBaseHelper.Primarydbcontext;

        public FlexEntities currentContext
        {
            get
            {
                try
                {
                    Logger.InfoFormat("Module : {0}", WebSecurity.Module.Trim());
                    return DataBaseHelper.dbcontext(WebSecurity.Module.Trim());
                }
                catch (Exception ex)
                {
                    Logger.InfoFormat("Error getting Context. Details {0}", ex.ToString());
                    throw new Exception("Invalid Context");
                }
            }
        }
        public KeyValuePair<string, string> RptHeaderCompanyName
        {
            get
            {
                return new KeyValuePair<string, string>("coyname", ReportUtil.GetConfig(ReportUtil.Constants.CoyName));
            }
        }

        
        public KeyValuePair<string, string> RptHeaderCompanyAddress
        {
            get
            {
                return new KeyValuePair<string, string>("coyaddr", ReportUtil.GetConfig(ReportUtil.Constants.CoyAddress));
            }
        }

        //public JsonResult GetPaymentMethods()
        //{
        //    try
        //    {
        //        var paymethods=UtilEnumHelper.GetEnumList(typeof(PaymentMethod));
        //        var payMethodList = paymethods.Select(x => new SelectListItem()
        //        {
        //            Text = x.Name,
        //            Value = x.ID.ToString()
        //        }).ToList();
        //        return Json(payMethodList, JsonRequestBehavior.AllowGet);
        //    }
        //    catch (Exception ex)
        //    {
        //        Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
        //        throw;
        //    }
        //}

        public SelectList GetPaymentMethods(int paymethod = -1)
        {
            var paymentMethods = UtilEnumHelper.GetEnumList(typeof(PaymentMethod));
            return new SelectList(paymentMethods, "ID", "Name", paymethod);
        }
        public SelectList getAccounts(string selectvalue="")
        {
            var Accounts = new List<AccountBindingModel>();
            //using (var _context= context)
            //{
                Accounts = context.acccharts.Select(x => new AccountBindingModel()
                {
                    AccountNumber = x.acctnumber,
                    Description = x.description
                }).OrderBy(x=>x.AccountNumber).ToList();
            //}
            return new SelectList(Accounts, "AccountNumber", "DescAccount", selectvalue);
        }

        public SelectList GetUserStatus(int status = 0)
        {
            var userstatus = UtilEnumHelper.GetEnumList(typeof(UserStatus));
            if (status > 0)
            {
                new SelectList(userstatus, "ID", "Name", status);
            }
            return new SelectList(userstatus, "ID", "Name");
        }
        public SelectList Getgropcodes()
        {
            var grp = new List<fl_grouptype>();
            grp = new CoreSystem<fl_grouptype>(context).FindAll(x => x.IsDeleted == false).ToList();

            return new SelectList(grp, "grpcode", "grpname");
        }
        public SelectList GetCustomer()
        {
            var pol = new List<fl_policyinput>();
            pol = new CoreSystem<fl_policyinput>(context).GetAll().ToList();

            return new SelectList(pol, "grpcode", "surname");
        }
        public SelectList GetLocations()
        {
            var locs = new List<fl_location>();
            locs = new CoreSystem<fl_location>(context).FindAll(x => x.Isdeleted == false).ToList();

            return new SelectList(locs, "Id", "locdesc");
        }
        public void getAgentType(int selectedvalue)
        {
            var agentType = UtilEnumHelper.GetEnumList(typeof(AgentType));
            ViewBag.agentType = new SelectList(agentType, "ID", "Name", selectedvalue);
        }

        public void getGroupClass()
        {
            var grpClass = UtilEnumHelper.GetEnumList(typeof(GroupClass));
            ViewBag.grpClass = new SelectList(grpClass, "ID", "Name");
        }

        public void getCostCentre(int selectedvalue)
        {
            var CostCentre = new List<ac_costCenter>();
            //using (var _context = context)
            //{
                CostCentre = new CoreSystem<ac_costCenter>(context).GetAll().ToList();
            //}
            ViewBag.CostCentre = new SelectList(CostCentre, "Id", "Desc",selectedvalue);
        }

        public void getPolicyType()
        {
            var polType = new List<fl_poltype>();
            //using (var _context = context)
            //{
                polType = new CoreSystem<fl_poltype>(context).FindAll(x => x.IsDeleted == false).ToList();
            //}
            ViewBag.polType = new SelectList(polType, "poltype", "poldesc");
        }

        public void getGroup()
        {
            var grp = new List<fl_grouptype>();
            //using (var _context = context)
            //{
                grp = new CoreSystem<fl_grouptype>(context).FindAll(x => x.IsDeleted == false).ToList();
            //}
            ViewBag.grp = new SelectList(grp, "grpcode", "grpname");
        }
        
        public void getReceipt()
        {
            var receipt = new List<fl_payinput2>();
            var status = Status.Active;
            receipt = new CoreSystem<fl_payinput2>(context).FindAll(x => x.status == status).DistinctBy(x=>x.receiptno).ToList();
            //receipt = query.DistinctBy(x=>x.receiptno).ToList();
            //receipt = new CoreSystem<fl_payinput2>(context).GetAll().DistinctBy(x=>x.receiptno).ToList();


            ViewBag.rt = new SelectList(receipt, "receiptno", "receiptno");
        }

        public UserSession GetUserSesiion()
        {
            try
            {
                var usrSession = WebSecurity.GetCurrentUser(Request);
                return usrSession;
            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Error Occurred. Details {0}", ex.ToString());
                throw;
            }
            
        }

        public SelectList GetAgents()
        {
            var agents = new List<fl_agents>();
            agents = new CoreSystem<fl_agents>(context).FindAll(x => x.IsDeleted == false).ToList();

            return new SelectList(agents, "agentcode", "agentname");
        }

        

        public SelectList GetStates(string state="")
        {
            var states = new List<fl_state>();
            states = new CoreSystem<fl_state>(context).GetAll().ToList();

            return new SelectList(states, "Name", "Name",state);
        }

        public SelectList GetStates2(string state = "")
        {
            var states = new List<fl_state>();
            states = new CoreSystem<fl_state>(context).GetAll().ToList();

            return new SelectList(states, "Id", "Name", state);
        }

        public void GetReationShip()
        {
            var relationships = UtilEnumHelper.GetEnumList(typeof(RelationShip));
            ViewBag.relationships = new SelectList(relationships, "ID", "Name");

        }

        public SelectList GetCustomers()
        {
            var cust = new List<CustomerUser>();
            cust = new CoreSystem<CustomerUser>(context).FindAll(x => x.status == UserStatus.Active).Distinct().ToList();
            return new SelectList(cust, "Id", "Name");
        }
        public ActionResult ExportReport(string reportName)
        {
            return new JsonResult()
            {
                Data = string.Format("{0}{1}", ConfigUtils.ReportPath2, reportName),
                JsonRequestBehavior=JsonRequestBehavior.AllowGet
            };
        }

        public void GetClaimType()
        {
            var clmTypes = UtilEnumHelper.GetEnumList(typeof(ClaimType));
            ViewBag.clmTypes = new SelectList(clmTypes, "ID", "Name");

        }

        public void GetClaimStatus(int selectedvalue=0)
        {
            var clmTypes = UtilEnumHelper.GetEnumList(typeof(ClaimStatus));
            ViewBag.claimStatus = new SelectList(clmTypes, "ID", "Name",selectedvalue);

        }

        public void GetStatus(int selectedvalue = 0)
        {
            var statuses = UtilEnumHelper.GetEnumList(typeof(Status));
            ViewBag.statuses = new SelectList(statuses, "ID", "Name", selectedvalue);

        }

        public void GetReligion(string selectedvalue = "")
        {
            var religions = new Dictionary<string,string>();
            religions.Add("Christianity", "Christianity");
            religions.Add("Islam", "Islam");
            religions.Add("Others", "Others");

            ViewBag.Religion = new SelectList(religions, "Key", "Value", selectedvalue);
        }

        public void GetGender(string selectedvalue = "")
        {
            var gender = new Dictionary<string, string>();
            gender.Add("Male", "Male");
            gender.Add("Female", "Female");

            ViewBag.Gender = new SelectList(gender, "Key", "Value",selectedvalue);
        }

    }


}
