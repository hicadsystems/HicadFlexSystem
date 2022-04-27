using CustomerPortal.Util;
using Flex.Business;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using Flex.Utility.Utils;
using SerialNumber;
using System;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CustomerPortal.Controllers
{
    public class PolicyController : BaseController
    {
        // GET: Policy
        public ActionResult Create()
        {
           GetPolicyType();
            GetLocation();
            return PartialView("_createPolicy");
        }

        [HttpPost]
        public ActionResult Create(PolicyBindingModel model)
        {
            try
            {
                var newpolicy = new fl_policyinput();

                var user = WebSecurity.GetCurrentUser(Request);

                var pol = user.CustomerUser.CustomerPolicies.Select(x => x.Policyno).ToList()[0];
                using (var _context = context)
                {
                    var policy = new CoreSystem<fl_policyinput>(context).FindAll(x => x.policyno == pol).FirstOrDefault();

                    //var polType = _context.fl_poltype.Where(x => x.poltype == policy.poltype).FirstOrDefault();
                    //var xpolType = polType != null && !string.IsNullOrEmpty(polType.code) ? polType.code : policy.poltype;

                    newpolicy.accdate = DateTime.Now;
                    newpolicy.datecreated = DateTime.Now;
                    newpolicy.dob = policy.dob;
                    newpolicy.email = policy.email;
                    newpolicy.location = model.Location;
                    newpolicy.othername = policy.othername;
                    newpolicy.poltype = new CoreSystem<fl_poltype>(context).Get(model.PolicyType).poltype;
                    newpolicy.premium = model.Amount;
                    newpolicy.status = (int)Flex.Data.Enum.Status.Active;
                    newpolicy.surname = policy.surname;
                    newpolicy.telephone = policy.telephone;

                    var polType = _context.fl_poltype.Where(x => x.Id == model.PolicyType).FirstOrDefault();
                    var xpolType = polType != null && !string.IsNullOrEmpty(polType.code) ? polType.code : polType.poltype;

                    var policynoSno = new SerialNumberSource().GetNextNumber(polType.poltype);


                    Logger.InfoFormat("Serial Number {0} gotten", policynoSno);
                    var policyno = ConfigUtils.PolicyNoFormat;
                    var xlocation = new CoreSystem<fl_location>(_context).Get((int)model.Location);
                    if (xlocation == null)
                    {
                        throw new Exception("Invalid Location");
                    }

                    var pcn = policynoSno.ToString().PadLeft(ConfigUtils.policynoLenght, '0');
                    policyno = policyno.Replace("{PolicyType}", xpolType).Replace("{Location}", xlocation.loccode)
                                  .Replace("{Year}", DateTime.Today.ToString("yy"))
                                  .Replace("{SerialNo}", pcn);

                    newpolicy.policyno = policyno;

                    using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                    {
                        try
                        {
                            new PolicySystem(context).savePolicy(newpolicy);
                            var userpwd = string.Empty;


                            userpwd = WebUtils.UserPwd;
                            var defaultDate = (DateTime)SqlDateTime.Null;
                            var custPolicy = new CustomerPolicy()
                            {
                                CustomerUserId = user.CustomerUserID,
                                Policyno = newpolicy.policyno
                            };
                            new CoreSystem<CustomerPolicy>(context).Save(custPolicy);

                            new NotificationSystem(context).SendPolicyCreationNotiification(newpolicy, user.CustomerUser.username, string.Empty, xpolType);

                            transaction.Commit();

                        }
                        catch
                        {
                            transaction.Rollback();
                            throw;
                        }
                    }
                }
               
                return new JsonResult()
                {
                    Data = string.Format("Policy with policy Number {0} created successfully", newpolicy.policyno)
                };
            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Error Occurred. Details  [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }


        }

    }
}