using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flex.Business
{
    public class AgentUserAuth : CoreSystem<fl_agents>
    {
        private DbContext _context;
        public AgentUserAuth(DbContext context)
            : base(context)
        {
            _context = context;
        }

        public AuthResult AgentAuthenticateUser(String userName, string password, Boolean getUsable = true)
        {
            AuthResult res = new AuthResult() { };
            //  var user = FindAll(x => x.agentphone == userName).FirstOrDefault();
            var user2 = new CoreSystem<fl_agents>(_context).FindAll(x=>x.IsDeleted == false);
  
            var user = new CoreSystem<fl_agents>(_context).FindAll(x => x.agentphone == userName && x.agentcode == password && x.IsDeleted == false).FirstOrDefault();
            if (user != null)
            {
                
               res.Session = new UserSessionSystem(_context).ProvisionSessionFor(user, getUsable);

            }
            else
            {
                res.Description = "Invalid username or password";// "User does not exist";
                res.Status = AuthStatus.DoesNotExist;
            }
            return res;
        }

      
    }
}
