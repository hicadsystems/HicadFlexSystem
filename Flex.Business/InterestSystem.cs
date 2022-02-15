using Flex.Data.Model;
using Flex.Data.ViewModel;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Globalization;
using System.Linq;
using System.Text;

namespace Flex.Business
{
    public class InterestSystem : CoreSystem<vwPolicyHistory>
    {
        private DbContext _context;
        public InterestSystem(DbContext context)
            : base(context)
        {
            _context = context;
        }
        public List<InterestCalModel> CalculateInterest(string policyno, decimal interest, DateTime effDate)
        {
            try
            {
                var lastintCal = string.Concat((effDate.Year - 1).ToString(), "1231");
                var lastIntDate = DateTime.ParseExact(lastintCal,
                                 "yyyyMMdd",
                                  CultureInfo.InvariantCulture);
                var pastTrans = FindAll(x => x.policyno == policyno && x.trandate <= lastIntDate)
                    .GroupBy(x=>x.policyno)
                    .Select(x=> new InterestCalModel() {
                    Amount=(decimal)x.Sum(c=>c.amount + c.cumul_intr),
                    //Interest=(decimal)x.Sum(c => c.cumul_intr)
                    }).FirstOrDefault();

                var currTrans = FindAll(x => x.policyno == policyno && x.trandate > lastIntDate && x.trandate <= effDate).ToList();

                //var totPrincipal = 0.0M;
                //var totInterest = 0.0M;
                var polInts = new List<InterestCalModel>();

                if (pastTrans != null)
                {
                    pastTrans.Interest = CalInterest(pastTrans.Amount, interest, lastIntDate, effDate);
                    pastTrans.PolicyNo = policyno;
                    pastTrans.ReceiptNo = "Open Bal";
                    pastTrans.TransDate = new DateTime(effDate.Year, 1, 1).ToString("yyyy-MM-dd");
                    polInts.Add(pastTrans);
                }

                foreach (var trans in currTrans)
                {
                    var intModel = new InterestCalModel();
                    intModel.Amount = (decimal)(trans.amount + trans.cumul_intr);
                    intModel.Interest = CalInterest(intModel.Amount, interest, (DateTime)trans.trandate, effDate);
                    intModel.PolicyNo = trans.policyno;
                    intModel.ReceiptNo = trans.receiptno;
                    intModel.TransDate = ((DateTime)trans.trandate).ToString("yyyy-MM-dd");
                    polInts.Add(intModel);
                }

                return polInts;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                throw;
            }
        }

        private decimal CalInterest(decimal amount,decimal intr, DateTime sdate, DateTime eDate)
        {
            var days = (eDate - sdate).TotalDays;
            if (days > 356)
            {
                days = 365;
            }
            var interest = (amount * (intr/100) * (Convert.ToDecimal(days / 365)));

            return interest;

        }
    }
}
