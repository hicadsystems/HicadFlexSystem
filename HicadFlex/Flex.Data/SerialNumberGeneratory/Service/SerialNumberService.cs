using log4net;
using SerialNumberGenerator.DAO;
using SerialNumberGenerator.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace SerialNumberGenerator.Service
{
    public class SerialNumberService : ISerialNumber
    {
        ILog Logger = SerialNumberSystem.Logger;

        public string GetNextNumber(string contextKey)
        {
            var startTime = DateTime.Now;
            try
            {
                Logger.InfoFormat("Request [{0}] From [{1}] To [{2}]", OperationContext.Current.IncomingMessageHeaders.MessageId, OperationContext.Current.IncomingMessageHeaders.From, OperationContext.Current.IncomingMessageHeaders.To);
                return SerialNumberSystem.GetNextNumber(contextKey);
            }
            finally
            {
                Logger.InfoFormat("Request [{0}] Served in {1}ms", OperationContext.Current.IncomingMessageHeaders.MessageId, DateTime.Now.Subtract(startTime).TotalMilliseconds);
            }
        }
    }
}
