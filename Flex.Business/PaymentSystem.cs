using Dapper;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using log4net;
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
    public class PaymentSystem //: CoreSystem<fl_payinput>
    {
        private DbContext _context;
        public ILog Logger { get { return log4net.LogManager.GetLogger("Flex"); } }

        public PaymentSystem(DbContext context) //: base(context)
        {
            _context = context;
        }
        public PagedResult<fl_payinput> searchTransaction(string pagesize, string page, string receiptno, string datefrom, string dateto, string policyno)
        {
            Logger.Info("Inside Transaction Search");
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");
            try
            {
                int xPagesize = 0;
                int xPage = 0;
                int.TryParse(pagesize, out xPagesize);
                int.TryParse(page, out xPage);
                var xDateFrom=SqlDateTime.MinValue.Value;
                var xDateTo=SqlDateTime.MinValue.Value;
                xPagesize = xPagesize > 0 ? xPagesize : 10;
                xPage = xPage > 0 ? xPage : 1;
                var trans = new CoreSystem<fl_payinput>(_context).GetAll();
                if (!string.IsNullOrEmpty(datefrom) && !string.IsNullOrEmpty(dateto))
                {
                    DateTime.TryParse(datefrom, out xDateFrom);
                    xDateFrom = Convert.ToDateTime(xDateFrom, culInfo).Date;
                    DateTime.TryParse(dateto,out xDateTo);
                    xDateTo = Convert.ToDateTime(xDateTo, culInfo).Date.AddDays(1).AddSeconds(-1);
                    trans = trans.Where(x => x.trandate >= xDateFrom && x.trandate <= xDateTo);
                }
                if (!string.IsNullOrEmpty(receiptno))
                {
                    trans = trans.Where(x => x.receiptno == receiptno);
                }
                if (!string.IsNullOrEmpty(policyno))
                {
                    trans = trans.Where(x => x.policyno == policyno);
                }

                var TotalCount=trans.Count();
                var skip = (xPage - 1) * xPagesize;
                var PagedTrans = new PagedResult<fl_payinput>();
                PagedTrans.LongRowCount = TotalCount;
                PagedTrans.Items = trans.OrderBy(x=>x.trandate).Skip(skip).Take(xPagesize).ToList();
                PagedTrans.PageSize = xPagesize;
                PagedTrans.PageCount = TotalCount > 0 ? (int)Math.Ceiling(Convert.ToDouble(Convert.ToDouble(TotalCount) / Convert.ToDouble(xPagesize))) : 1;

                PagedTrans.CurrentPage = xPage;

                return PagedTrans;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Detail {0}", ex.ToString());
                throw;
            }
        }


        public IQueryable<fl_payinput> getTransaction(string receiptno, string datefrom, string dateto, string policyno)
        {
            Logger.Info("Inside Transaction Search");
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");
            try
            {
                var xDateFrom = SqlDateTime.MinValue.Value;
                var xDateTo = SqlDateTime.MinValue.Value;

                var trans = new CoreSystem<fl_payinput>(_context).GetAll();

                if (!string.IsNullOrEmpty(datefrom) && !string.IsNullOrEmpty(dateto))
                {
                    DateTime.TryParse(datefrom, out xDateFrom);
                    xDateFrom = Convert.ToDateTime(xDateFrom, culInfo).Date;
                    DateTime.TryParse(dateto, out xDateTo);
                    xDateTo = Convert.ToDateTime(xDateTo, culInfo).Date.AddDays(1).AddSeconds(-1);
                    trans = trans.Where(x => x.trandate >= xDateFrom && x.trandate <= xDateTo);
                }
                if (!string.IsNullOrEmpty(receiptno))
                {
                    trans = trans.Where(x => x.receiptno == receiptno);
                }
                if (!string.IsNullOrEmpty(policyno))
                {
                    trans = trans.Where(x => x.policyno == policyno);
                }

                return trans;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Detail {0}", ex.ToString());
                throw;
            }
        }
        public PagedResult<fl_translog> searchGTransaction(string pagesize, string page, string receiptno, string datefrom, string dateto,  string groupCode, List<string> poltypes)
        {
            Logger.Info("Inside Transaction Search");
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");
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
                var trans = new CoreSystem<fl_translog>(_context).GetAll().Where(x=>x.Isreversed == false);
                if (!string.IsNullOrEmpty(datefrom) && !string.IsNullOrEmpty(dateto))
                {
                    DateTime.TryParse(datefrom, out xDateFrom);
                    xDateFrom = Convert.ToDateTime(xDateFrom, culInfo).Date;
                    DateTime.TryParse(dateto, out xDateTo);
                    xDateTo = Convert.ToDateTime(xDateTo, culInfo).Date.AddDays(1).AddSeconds(-1);
                    trans = trans.Where(x => x.trandate >= xDateFrom && x.trandate <= xDateTo);
                }
                if (poltypes.Any())
                {
                    trans = trans.Where(x => poltypes.Contains(x.poltype));
                }
                if (!string.IsNullOrEmpty(receiptno))
                {
                    trans = trans.Where(x => x.receiptno == receiptno);
                }
                if (!string.IsNullOrEmpty(groupCode))
                {
                    trans = trans.Where(x => x.grpcode == groupCode);
                }

                var TotalCount = trans.Count();
                var skip = (xPage - 1) * xPagesize;
                var PagedTrans = new PagedResult<fl_translog>();
                PagedTrans.LongRowCount = TotalCount;
                PagedTrans.Items = trans.OrderBy(x => x.trandate).Skip(skip).Take(xPagesize).ToList();
                PagedTrans.PageSize = xPagesize;
                PagedTrans.PageCount = TotalCount > 0 ? (int)Math.Ceiling(Convert.ToDouble(Convert.ToDouble(TotalCount) / Convert.ToDouble(xPagesize))) : 1;

                PagedTrans.CurrentPage = xPage;

                return PagedTrans;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Detail {0}", ex.ToString());
                throw;
            }
        }

        public PagedResult<vwPolicyHistory> searchPaymentHistory(string policyno, string datefrom=null, string dateto=null,string pagesize=null, string page=null)
        {
            Logger.Info("Inside Payment History");
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");
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
                var query = new CoreSystem<vwPolicyHistory>(_context).FindAll(x => x.policyno == policyno);
                if (!string.IsNullOrEmpty(datefrom) && !string.IsNullOrEmpty(dateto))
                {
                    DateTime.TryParse(datefrom, out xDateFrom);
                    xDateFrom = Convert.ToDateTime(xDateFrom, culInfo).Date;
                    DateTime.TryParse(dateto, out xDateTo);
                    xDateTo = Convert.ToDateTime(xDateTo, culInfo).Date.AddDays(1).AddSeconds(-1);
                    query = query.Where(x => x.trandate >= xDateFrom && x.trandate <= xDateTo);
                }
                var TotalCount = query.Count();
                var skip = (xPage - 1) * xPagesize;
                var PagedStmt = new PagedResult<vwPolicyHistory>();
                PagedStmt.LongRowCount = TotalCount;
                PagedStmt.Items = query.OrderByDescending(x => x.trandate).Skip(skip).Take(xPagesize).ToList();
                PagedStmt.PageSize = xPagesize;
                PagedStmt.PageCount = TotalCount > 0 ? (int)Math.Ceiling(Convert.ToDouble(Convert.ToDouble(TotalCount) / Convert.ToDouble(xPagesize))) : 1;

                PagedStmt.CurrentPage = xPage;

                return PagedStmt;

            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        public List<vwPolicyHistory> searchPaymentHistory(string policyno, string datefrom, string dateto)
        {
            Logger.Info("Inside Payment History");
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");
            try
            {
                var xDateFrom = SqlDateTime.MinValue.Value;
                var xDateTo = SqlDateTime.MinValue.Value;
                var query = new CoreSystem<vwPolicyHistory>(_context).FindAll(x => x.policyno == policyno);
                if (!string.IsNullOrEmpty(datefrom) && !string.IsNullOrEmpty(dateto))
                {
                    DateTime.TryParse(datefrom, out xDateFrom);
                    xDateFrom = Convert.ToDateTime(xDateFrom, culInfo).Date;
                    DateTime.TryParse(dateto, out xDateTo);
                    xDateTo = Convert.ToDateTime(xDateTo, culInfo).Date.AddDays(1).AddSeconds(-1);
                    query = query.Where(x => x.trandate >= xDateFrom && x.trandate <= xDateTo);
                }
                return query.ToList();

            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }

        }
        public List<vwPolicyHistory> Statement(string date, string policyno)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var xDate = SqlDateTime.MinValue.Value;
                DateTime.TryParse(date, out xDate);
                xDate = Convert.ToDateTime(xDate, culInfo).Date;

                var stmt = new CoreSystem<vwPolicyHistory>(_context).FindAll(x => x.trandate <= xDate);

                if (!string.IsNullOrEmpty(policyno))
                {
                    stmt = stmt.Where(x => x.policyno == policyno);
                }

                return stmt.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        public List<fl_payhistory> ReceiptHistory(string policyno, string datefrom, string dateto, string option)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var xDatefrom = SqlDateTime.MinValue.Value;
                DateTime.TryParse(datefrom, out xDatefrom);
                xDatefrom = Convert.ToDateTime(xDatefrom, culInfo).Date;

                var xDateto = SqlDateTime.MinValue.Value;
                DateTime.TryParse(dateto, out xDateto);
                xDateto = Convert.ToDateTime(xDateto, culInfo).Date;

                var query = new CoreSystem<fl_payhistory>(_context).FindAll(x => x.trandate >= xDatefrom && x.trandate <= xDateto);

                if (!string.IsNullOrEmpty(policyno))
                {
                    query = query.Where(x => x.policyno == policyno);
                }

                return query.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        public List<vwPolicyHistory> ReceiptCurrentValue(string policyno, string datefrom, string dateto, string option)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var rcts = new List<vwPolicyHistory>();
                var xDatefrom = SqlDateTime.MinValue.Value;
                DateTime.TryParse(datefrom, out xDatefrom);
                xDatefrom = Convert.ToDateTime(xDatefrom, culInfo).Date;

                var xDateto = SqlDateTime.MinValue.Value;
                DateTime.TryParse(dateto, out xDateto);
                xDateto = Convert.ToDateTime(xDateto, culInfo).Date;

                using (var context=_context)
                {
                    var query = new CoreSystem<vwPolicyHistory>(context).FindAll(x => x.trandate >= xDatefrom && x.trandate <= xDateto);

                    if (!string.IsNullOrEmpty(policyno))
                    {
                        query = query.Where(x => x.policyno == policyno);
                    }
                    rcts = query.ToList();
                }
                

                return rcts;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }


        public List<vProduction> RetrieveProduction(string agentcode, string datefrom, string dateto, string policyno, string location, string custLocation)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var xDatefrom = SqlDateTime.MinValue.Value;
                DateTime.TryParse(datefrom, out xDatefrom);
                xDatefrom = Convert.ToDateTime(xDatefrom, culInfo).Date;

                var xDateto = SqlDateTime.MinValue.Value;
                DateTime.TryParse(dateto, out xDateto);
                xDateto = Convert.ToDateTime(xDateto, culInfo).Date;

                var xlocation = 0;
                var xCustLoc = 0;
                var query = new CoreSystem<vProduction>(_context).FindAll(x => x.trandate >= xDatefrom && x.trandate <= xDateto);

                if (!string.IsNullOrEmpty(agentcode))
                {
                    query = query.Where(x => x.agentcode == agentcode);
                }
                if (!string.IsNullOrEmpty(location))
                {
                    int.TryParse(location, out xlocation);
                    query = query.Where(x => (int)x.agentLocation == xlocation);
                }
                if (!string.IsNullOrEmpty(location))
                {
                    int.TryParse(custLocation, out xCustLoc);
                    query = query.Where(x => (int)x.location == xCustLoc);
                }

                return query.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        public List<vProduction> RecieptList(string policyno, string datefrom, string dateto)
        {
            CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

            try
            {
                var xDatefrom = SqlDateTime.MinValue.Value;
                DateTime.TryParse(datefrom, out xDatefrom);
                xDatefrom = Convert.ToDateTime(xDatefrom, culInfo).Date;

                var xDateto = SqlDateTime.MinValue.Value;
                DateTime.TryParse(dateto, out xDateto);
                xDateto = Convert.ToDateTime(xDateto, culInfo).Date;

                var query = new CoreSystem<vProduction>(_context).FindAll(x => x.trandate >= xDatefrom && x.trandate <= xDateto);

                if (!string.IsNullOrEmpty(policyno))
                {
                    query = query.Where(x => x.policyno == policyno);
                }

                return query.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        public void SavePaymetIntegration(OnlineReciept onlineRct)
        {
            try
            {
                new CoreSystem<OnlineReciept>(_context).Save(onlineRct);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        public List<vwPolicy> RetrieveFundGroup(decimal LowerAmt, decimal UpperAmt)
        {
            try
            {
                var funds = new CoreSystem<vwPolicy>(_context).FindAll(x => x.balance >= LowerAmt && x.balance <= UpperAmt);

                return funds.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        public List<Production> CommissionReport(string StartDate, string Enddate, string PolicyType)
        {
            try
            {
                CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");

                var xDatefrom = SqlDateTime.MinValue.Value;
                DateTime.TryParse(StartDate, out xDatefrom);
                xDatefrom = Convert.ToDateTime(xDatefrom, culInfo).Date;

                var xDateto = SqlDateTime.MinValue.Value;
                DateTime.TryParse(Enddate, out xDateto);
                xDateto = Convert.ToDateTime(xDateto, culInfo).Date;

                IEnumerable<Production> comms = null;
                var queryParameters = new DynamicParameters();
                queryParameters.Add("@sdate", xDatefrom.ToString("yyyyMMdd"));
                queryParameters.Add("@edate", xDateto.ToString("yyyyMMdd"));
                queryParameters.Add("@module", PolicyType);

                using (IDbConnection conn = new SqlConnection(_context.Database.Connection.ConnectionString))
                {
                    comms = conn.Query<Production>("sp_CommissionReport", queryParameters, commandType: CommandType.StoredProcedure,commandTimeout:0);
                };

                return comms.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        public List<Maturity> MaturityReport()
        {
            try
            {

                IEnumerable<Maturity> data = null;

                using (IDbConnection conn = new SqlConnection(_context.Database.Connection.ConnectionString))
                {
                    data = conn.Query<Maturity>("sp_MaturityReport", commandType: CommandType.StoredProcedure);
                };

                return data.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }
        public List<Gratuity> GratuityStatementReport(string Date, string polno, string grpcode, string Users)
        {
            try
            {
                CultureInfo culInfo = CultureInfo.CreateSpecificCulture("en-GB");
                string yy = Date.Substring(0, 4);
                string mm = Date.Substring(5, 2);
                string dd = Date.Substring(8, 2);
                string maindate = yy + mm + dd;

                IEnumerable<Gratuity> gratuity = null;
                var queryParameters = new DynamicParameters();
                if (!string.IsNullOrEmpty(polno))
                {
                    queryParameters.Add("@globalpol", "10");
                    queryParameters.Add("@polno", polno);
                    queryParameters.Add("@grpcode", grpcode);
                    queryParameters.Add("@globalstation", "Systems");
                    queryParameters.Add("@txtdate1", maindate);

                   
                }
                else
                {
                    queryParameters.Add("@globalpol", "10");
                    queryParameters.Add("@polno", "1000");
                    queryParameters.Add("@grpcode", grpcode);
                    queryParameters.Add("@globalstation", "Systems");
                    queryParameters.Add("@txtdate1", maindate);
                    
                }

                using (IDbConnection conn = new SqlConnection(_context.Database.Connection.ConnectionString))
                {

                    gratuity = conn.Query<Gratuity>("fl_grat_statement", queryParameters, commandType: CommandType.StoredProcedure, commandTimeout: 2000);
                };
                //var query = new CoreSystem<fl_policyinput>(_context).GetAll();

                //if (!string.IsNullOrEmpty(polno))
                //{
                //    query = gratuity.Where(x => x.policyno == polno);
                //}

                // return query.ToList();

                return gratuity.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }
    }
}
