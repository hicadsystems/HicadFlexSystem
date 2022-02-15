using Flex.API.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Insurance.Business;
using Flex.API.Utils;

namespace Flex.API.Controllers
{
    public class InsuranceController : BaseController
    {
        public IHttpActionResult GetDetails(string PolicyNo)
        {
            Logger.Info("Inside Insurance Get Details");
            try
            {
                InsurancePolicyDetails polDetails = null;

                if (string.IsNullOrEmpty(PolicyNo))
                {
                    Logger.Info("Data not received from client");
                    return BadRequest();
                }
                Logger.InfoFormat("About to get details for policy no : {0}", PolicyNo);
                //var code = model.PolicyNo.Trim().Substring(0, 3);
                var context = getContext("INS");
                Logger.InfoFormat("Database Context {0} Gotten", context.Database.Connection.ConnectionString);
                polDetails = new PolicySystem(context).FindAll(x => x.policy_code == PolicyNo).Select(x => new InsurancePolicyDetails()
                {
                    ExpiryDate=(DateTime)x.policy_expdate,
                    Name=x.Policy_Name,
                    PolicyNo=x.policy_code,
                    Premium=Convert.ToDecimal(x.policy_totprem),
                    RenewalDate=(DateTime)x.policy_rendate,
                    Scheme=x.policy_desc
                }).FirstOrDefault();
                if (polDetails == null)
                {
                    polDetails = new InsurancePolicyDetails()
                    {
                        ResponseCode = "10"
                    };

                    return Ok(polDetails);
                }
                var clearstring = string.Concat(polDetails.PolicyNo, polDetails.Name
                    , polDetails.Scheme, polDetails.Premium, polDetails.ExpiryDate,polDetails.RenewalDate);
                polDetails.Hash = new WebSecurityUtils().getHash(clearstring);
                polDetails.ResponseCode = "00";
                return Ok(polDetails);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return Ok(new PolicyDetails()
                {
                    ResponseCode = "20"
                });
            }

        }
    }
}
