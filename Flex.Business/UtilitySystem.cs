using Flex.Data.Enum;
using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Linq.Expressions;
using System.Text;

namespace Flex.Business
{
    public class UtilitySystem
    {
        private int rctno=0;

        static Dictionary<string, int> m_TransactionCounts = new Dictionary<string, int>();

        public static string TransactionCountKey = string.Empty;

        static int m_TransactionCount
        {
            get
            {
                if (!m_TransactionCounts.ContainsKey(TransactionCountKey))
                {
                    m_TransactionCounts.Add(TransactionCountKey, 0);
                }
                return m_TransactionCounts[TransactionCountKey];
            }
            set
            {
                if (!m_TransactionCounts.ContainsKey(TransactionCountKey))
                {
                    m_TransactionCounts.Add(TransactionCountKey, 0);
                }
                m_TransactionCounts[TransactionCountKey] = value;
            }
        }

        static readonly Object SerialNoLock = new Object();

        public static int GetNextSerialNumber(DbContext context,SerialNoCountKey sKey)
        {
            lock (SerialNoLock)
            {
                TransactionCountKey = sKey.ToString();
                IQueryable<Object> query = null;
                if (m_TransactionCount == 0)
                {
                    var xDateFrom = DateTime.Today;
                    var xDateTo = DateTime.Today.AddDays(1).AddSeconds(-1);

                    switch (sKey)
                    {
                        case SerialNoCountKey.RT:
                        case SerialNoCountKey.PV:
                            query=new CoreSystem<fl_translog>(context).FindAll(x=> x.trandate >= xDateFrom 
                                && x.trandate <= xDateTo);
                            break;
                        case SerialNoCountKey.QT:
                            query = new CoreSystem<PersonalDetailsStaging>(context).FindAll(x => x.DateCreated >= xDateFrom
                                && x.DateCreated <= xDateTo && x.Type == (int)Flex.Data.Enum.Type.New);
                            break;
                        case SerialNoCountKey.PY:
                            query = new CoreSystem<fl_policyinput>(context).FindAll(x => x.datecreated >= xDateFrom
                                && x.datecreated <= xDateTo);
                            break;
                        case SerialNoCountKey.CM:
                             query = new CoreSystem<ClaimRequest>(context).FindAll(x => x.DateCreated >= xDateFrom
                                && x.DateCreated <= xDateTo);
                            break;
                    }
                    m_TransactionCount = query != null?query.Count():0;
                }
                return ++m_TransactionCount;
            }
        }

        public string GenerateRef(string perfix, int serialno)
        {
            var receiptno = string.Format("{0}{1}{2}", perfix, DateTime.Today.ToString("yyMMdd"), serialno.ToString().PadLeft(5, '0'));

            return receiptno;
        }

        public string GenerateAgentCode(FlexEntities context)
        {
            try
            {
                var agcount = new CoreSystem<fl_agents>(context).Count();

                var agCode = (agcount + 1).ToString().PadLeft(5, '0');

                return agCode;
            }
            catch (Exception)
            {

                throw;
            }
        }
    }
}
