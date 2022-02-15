using Flex.API.Utils;
using Flex.Data.Model;
using log4net;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace Flex.API.Controllers
{
    public class BaseController : ApiController
    {
        public ILog Logger { get { return log4net.LogManager.GetLogger("FlexAPI"); } }

        public FlexEntities getContext(string code)
        {
            //var code =policyno.Trim().Substring(0, 3);
            var context = DataBaseHelper.GetContext(DataBaseHelper.Getconfig(code));

            return context;
        }
    }

}
