using Flex.Data.Model;
using Flex.Data.ViewModel;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.SqlTypes;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flex.Business
{
    public class GPaymentSystem : CoreSystem<fl_payinput2>
    {
        private DbContext _context;
        public GPaymentSystem(DbContext context)
            : base(context)
        {
            _context = context;
        }

        public PagedResult<fl_payinput2> searchTransaction(string pagesize, string page, string datefrom, string dateto, string receiptno, string groupCode)
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
                var trans = GetAll();
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
                if (!string.IsNullOrEmpty(groupCode))
                {
                    trans = trans.Where(x => x.grpcode == groupCode);
                }
               
                var TotalCount = trans.Count();
                var skip = (xPage - 1) * xPagesize;
                var PagedTrans = new PagedResult<fl_payinput2>();
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

    }
}
