using Flex.API.Models;
using Flex.API.Utils;
using Flex.Business;
using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace Flex.API.Controllers
{
    public class AgentController : BaseController
    {
        public IHttpActionResult Validate(AgentValidationModel model)
        {
            Logger.Info("Inside Agent Validation");
            try
            {

                AgentValidationResponse agDetails = null;

                if (model==null)
                {
                    Logger.Info("Data not received from client");
                    return BadRequest();
                }

                var reqHash = new WebSecurityUtils().getHash(string.Concat(model.AgentCode,model.Phone));
                Logger.InfoFormat("Expected Hash : {0}", reqHash);
                Logger.InfoFormat("Hash Received : {0}", model.Hash);
                if (model.Hash != reqHash)
                {
                    agDetails = new AgentValidationResponse()
                    {
                        ResponseCode = "40"
                    };
                    return Ok(agDetails);
                }
                Logger.InfoFormat("About to validate Agent with code {0} and phone number {1}", model.AgentCode,model.Phone);
                //var code = model.PolicyNo.Trim().Substring(0, 3);
                var context = getContext("PPP");
                Logger.InfoFormat("Database Context {0} Gotten", context.Database.Connection.ConnectionString);
                agDetails = new CoreSystem<fl_agents>(context).FindAll(x => x.agentcode == model.AgentCode && x.agentphone==model.Phone)
                    .Select(x => new AgentValidationResponse()
                {
                   AgentCode=x.agentcode,
                   Name=x.agentname,
                   Phone=x.agentphone
                }).FirstOrDefault();
                if (agDetails == null)
                {
                    agDetails = new AgentValidationResponse()
                    {
                        ResponseCode = "10"
                    };

                    return Ok(agDetails);
                }
                var clearstring = string.Concat(agDetails.AgentCode, agDetails.Phone, agDetails.Name);
                agDetails.Hash = new WebSecurityUtils().getHash(clearstring);
                agDetails.ResponseCode = "00";
                return Ok(agDetails);
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
