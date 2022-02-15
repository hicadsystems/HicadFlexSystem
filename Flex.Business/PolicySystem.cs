using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlTypes;
using System.Globalization;
using System.Linq;
using System.Text;

namespace Flex.Business
{
    public class PolicySystem : CoreSystem<fl_policyinput>
    {
        public DbContext _context;
        public PolicySystem(DbContext context)
            : base(context)
        {
            _context = context;
        }

        public void savePolicy(fl_policyinput policy)
        {
            try
            {
                //var locCode = new CoreSystem<fl_location>(_context).Get((int)policy.location).loccode;
                //var poltypeCode = new CoreSystem<fl_poltype>(_context).FindAll(x => x.poltype == policy.poltype).FirstOrDefault().code;
                //policy.policyno = GeneratePolicyNo(poltypeCode, locCode);
                Save(policy);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("An Error Occurred. [Details: {0}]", ex.ToString());
                throw;
            }
        }

        public PagedResult<vwPolicy> searchPolicies(List<string> poltypes,string policyno=null, string name=null, string phone=null, string agent=null, string location=null, string pagesize=null, string page=null)
        {
            Logger.Info("Inside Search Policy No");
            Logger.InfoFormat("Using Context: {0}", _context.Database.Connection.ConnectionString);

            try
            {
                int xPagesize = 0;
                int xPage = 0;
                int.TryParse(pagesize, out xPagesize);
                int.TryParse(page, out xPage);
                var xDateFrom = SqlDateTime.MinValue.Value;
                var xDateTo = SqlDateTime.MinValue.Value;
                xPagesize = xPagesize > 0 ? xPagesize : 10;
                xPage = xPage > 0 ? xPage : 1;
                var query = new CoreSystem<vwPolicy>(_context).FindAll(x=>x.status==Status.Active);
                if (poltypes != null && poltypes.Any())
                {
                    query = query.Where(x => poltypes.Contains(x.poltype));
                }
                if (!string.IsNullOrEmpty(policyno))
                {
                    query = query.Where(x => x.policyno.ToLower().Contains(policyno.ToLower()));
                }
                if (!string.IsNullOrEmpty(name))
                {
                    query = query.Where(x => x.surname.ToLower().Contains(name.ToLower()) || x.othername.ToLower().Contains(name.ToLower()));
                }
                if (!string.IsNullOrEmpty(phone))
                {
                    query = query.Where(x => x.telephone == phone);
                }
                if (!string.IsNullOrEmpty(agent))
                {
                    query = query.Where(x => x.agentcode == agent);
                }
                if (!string.IsNullOrEmpty(location))
                {
                    var loc = int.Parse(location);
                    query = query.Where(x => x.location == loc);
                }

                var TotalCount = query.Count();
                var skip = (xPage - 1) * xPagesize;
                var PagedPols = new PagedResult<vwPolicy>();
                PagedPols.LongRowCount = TotalCount;
                PagedPols.Items = query.OrderByDescending(x=>x.accdate).Skip(skip).Take(xPagesize).ToList();
                PagedPols.PageSize = xPagesize;
                PagedPols.PageCount = TotalCount > 0 ? (int)Math.Ceiling(Convert.ToDouble(Convert.ToDouble(TotalCount) / Convert.ToDouble(xPagesize))) : 1;

                PagedPols.CurrentPage = xPage;

                return PagedPols;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        private string GeneratePolicyNo(string policytype, string location)
        {
            var sn = Count() + 1;
            return string.Format("{0}/{1}/{2}/{3}", policytype, location, DateTime.Today.ToString("yy"), sn.ToString().PadLeft(5,'0'));
        }

        public bool validate(string email, string phone)
        {
            bool isValid = true;
            var query = FindAll(x=> (x.email == email || x.telephone==phone) && string.IsNullOrEmpty(x.exitdate));
            var pol = query.FirstOrDefault();
            if (pol != null)
            {
                isValid = false;
            }

            return isValid;
        }

        public IList<fl_policyinput> GetMembers(string datefrom, string dateto, string status, string agent, int location)
        {
            Logger.Info("Inside get Members");
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var xDateFrom = SqlDateTime.MinValue.Value;
                var xDateTo = SqlDateTime.MinValue.Value;
                DateTime.TryParse(datefrom, out xDateFrom);
                xDateFrom = Convert.ToDateTime(xDateFrom, culInfo).Date;
                DateTime.TryParse(dateto, out xDateTo);
                xDateTo = Convert.ToDateTime(xDateTo, culInfo).Date.AddDays(1).AddSeconds(-1);

                var membs = FindAll(x => x.accdate >= xDateFrom && x.accdate <= xDateTo);

                if (status.Equals("active",StringComparison.InvariantCultureIgnoreCase))
                {
                    membs = membs.Where(x => x.status == Status.Active);

                }
                if (status.Equals("withdrawn", StringComparison.InvariantCultureIgnoreCase))
                {
                    membs = membs.Where(x => x.status == Status.Exited);
                }
                if (!string.IsNullOrEmpty(agent))
                {
                    membs = membs.Where(x => x.agentcode == agent);
                }
                if (location > 0)
                {
                    membs = membs.Where(x => x.location == location);
                }
                return membs.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }
    }
}
