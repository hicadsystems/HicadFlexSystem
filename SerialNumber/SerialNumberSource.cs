using SerialNumberGenerator.Interfaces;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace SerialNumber
{
    public class SerialNumberSource : ISerialNumber
    {
        ISerialNumber m_NumberServiceProxy = null;
        public ISerialNumber NumberServiceProxy
        {
            get
             {
                if (m_NumberServiceProxy == null || (m_NumberServiceProxy as IClientChannel).State == CommunicationState.Faulted)
                {
                    m_NumberServiceProxy = ChannelFactory<ISerialNumber>.CreateChannel(new NetNamedPipeBinding(), new EndpointAddress(ConfigurationManager.AppSettings["SerialNumberServiceUrl"]));
                 }

                return m_NumberServiceProxy;
            }
        }

        public string GetNextNumber(string contextKey)
        {
            try
            {
                return NumberServiceProxy.GetNextNumber(contextKey);
            }
            finally
            {
                ((IClientChannel)NumberServiceProxy).Close();
            }
        }
    }
}
