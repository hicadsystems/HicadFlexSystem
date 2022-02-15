using log4net;
using SerialNumberGenerator.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
[assembly: log4net.Config.XmlConfigurator(Watch = true)]

namespace SerialNumberGenerator.DAO
{
    public class SerialNumberSystem
    {
        public static readonly ILog Logger = LogManager.GetLogger("SerialNumberProvider");
        static Dictionary<String, String> InitializedContexts = new Dictionary<string, string>();

        [MethodImpl(MethodImplOptions.Synchronized)]
        static public String GetNextNumber(String PolicyType)
        {
            //var poltype = (PolicyType)Enum.Parse(typeof(PolicyType), PolicyType);

            var context = DatabaseSystem.dbcontext;
            try
            {
                //var dateKey = DateTime.Now.ToString("yyyyMMdd");
                Logger.InfoFormat("GetNextNumber for ", PolicyType);
                //if (!InitializedContexts.ContainsKey(contextKey))
                //{
                //    Logger.InfoFormat("Initializing...");
                //    InitializedContexts.Add(contextKey, null);
                //}

                fl_recordno serial = context.fl_recordno.Where(x => x.poltype == PolicyType).OrderByDescending(x => x.polno).FirstOrDefault();

                //make sure count has been started 
                if (serial == null)
                {
                    Logger.InfoFormat("Serial object not existing, creating new...");
                    serial = new fl_recordno { poltype = PolicyType, polno = 0};
                    using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                    {
                        context.fl_recordno.Add(serial);
                        context.SaveChanges();
                        transaction.Commit();
                    }
                }
                //else if (serial.DateKey != dateKey)
                //{
                //    //something must be WrongHere
                //    Logger.InfoFormat("Strange! Having a different date key!!! Current DateKey is [{0}] but existing key is [{1}]", dateKey, serial.DateKey);
                //    throw new Exception("Strange! Having a different date key!!!");
                //}

                //increament Serial
                serial.polno++;

                //update serial
                using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                {
                    var original = context.fl_recordno.Find(serial.poltype);
                    context.Entry(original).CurrentValues.SetValues(serial);
                    context.SaveChanges();
                    transaction.Commit();
                }

                //return serial
                Logger.InfoFormat("Yeilding the serial [{0}]", serial.polno);
                return serial.polno.ToString();
            }
            catch (Exception ex)
            {
                Logger.Error(String.Format("An Error occurred: [{0}]", ex.Message), ex);
                throw;
            }
            finally
            {
                //try
                //{
                //    context.Dispose();
                //}
                //catch (Exception exx)
                //{
                //    Logger.Error(exx.Message, exx);
                //}
            }
        }

    }
}
