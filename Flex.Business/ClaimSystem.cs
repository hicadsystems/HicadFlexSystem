using Dapper;
using Flex.Data.Enum;
using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Globalization;
using System.Linq;
using System.Text;

namespace Flex.Business
{
    public class ClaimSystem : CoreSystem<fl_payclaim>
    {
        private DbContext _context;
        public ClaimSystem(DbContext context)
            : base(context)
        {
            _context = context;
        }
        public List<ClaimRequest> RemoveClaimRequest(long id)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");
            var queryParameters = new DynamicParameters();
            queryParameters.Add("@claimid", id);

            try { 
            using (IDbConnection conn = new SqlConnection(_context.Database.Connection.ConnectionString))
            {

                conn.Query<ClaimRequest>("deleteclaim", queryParameters, commandType: CommandType.StoredProcedure, commandTimeout: 2000).FirstOrDefault();
                   
                };
                return null;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        public List<ClaimRequest> RetrieveAllClaimRequest(string sDate, string eDate)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var xDateFrom = SqlDateTime.MinValue.Value;
                var xDateTo = SqlDateTime.MinValue.Value;

                DateTime.TryParse(sDate, out xDateFrom);
                DateTime.TryParse(eDate, out xDateTo);
                xDateTo = Convert.ToDateTime(xDateTo, culInfo).Date.AddDays(1).AddSeconds(-1);

                var allclaimReq = new CoreSystem<ClaimRequest>(_context).FindAll(x => x.DateCreated >= xDateFrom
                                    && x.DateCreated <= xDateTo && (x.Status == (int)(Status)ClaimStatus.Pending
                                    || x.Status ==(int)(Status)ClaimStatus.Processing));
                return allclaimReq.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        public List<ClaimRequest> RetrieveClaimRequest(List<string> policyno, string sDate, string eDate)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var xDateFrom = SqlDateTime.MinValue.Value;
                var xDateTo = SqlDateTime.MinValue.Value;

                DateTime.TryParse(sDate, out xDateFrom);
                DateTime.TryParse(eDate, out xDateTo);
                xDateTo = Convert.ToDateTime(xDateTo, culInfo).Date.AddDays(1).AddSeconds(-1);
                var allclaimReq = new CoreSystem<ClaimRequest>(_context).FindAll(x => x.DateCreated >= xDateFrom && x.DateCreated <= xDateTo 
                                    && policyno.Contains(x.PolicyNo));
                return allclaimReq.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        public List<ClaimRequest> RetrieveAllClaimPendingPayment(string sDate, string eDate, string policyno, string claimno)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var xDateFrom = SqlDateTime.MinValue.Value;
                var xDateTo = SqlDateTime.MinValue.Value;

                DateTime.TryParse(sDate, out xDateFrom);
                DateTime.TryParse(eDate, out xDateTo);
                xDateTo = Convert.ToDateTime(xDateTo, culInfo).Date.AddDays(1).AddSeconds(-1);

                var allclaimReq = new CoreSystem<ClaimRequest>(_context).FindAll(x => x.DateCreated >= xDateFrom
                                    && x.DateCreated <= xDateTo && (x.Status ==(int)(Status)ClaimStatus.Approved));

                if (!string.IsNullOrEmpty(policyno))
                {
                    allclaimReq = allclaimReq.Where(x => x.PolicyNo.ToLower().Contains(policyno.Trim().ToLower()));
                }
                if (!string.IsNullOrEmpty(claimno))
                {
                    allclaimReq = allclaimReq.Where(x => x.ClaimNo.ToLower().Contains(claimno.Trim().ToLower()));
                }
                return allclaimReq.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }


    }
}
