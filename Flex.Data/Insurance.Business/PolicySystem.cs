using Insurance.Data.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Insurance.Business
{
    public class PolicySystem : CoreSystem<gb_Policymaster>
    {
        private DbContext _context;
        public PolicySystem(DbContext context)
            : base(context)
        {
            _context = context;
        }
        public gb_Policymaster RetrievePolicyDetails(string policyNo)
        {
            try
            {
                var pol = FindAll(x => x.policy_code == policyNo).FirstOrDefault();

                return pol;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }
    }
}
