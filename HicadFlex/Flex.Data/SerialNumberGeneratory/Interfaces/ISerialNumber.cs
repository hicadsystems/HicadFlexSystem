using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Text;
using System.Threading.Tasks;

namespace SerialNumberGenerator.Interfaces
{
    [ServiceContract]
    public interface ISerialNumber
    {
        [OperationContract]
        String GetNextNumber(String contextKey);
    }
}
