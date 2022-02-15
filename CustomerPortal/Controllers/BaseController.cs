using Flex.Business;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.Utility;
using log4net;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace CustomerPortal.Controllers
{
    public class BaseController : Controller
    {
        public FlexEntities context = new FlexEntities();
        // GET: Base
        public ILog Logger { get { return log4net.LogManager.GetLogger("CustomerPortal"); } }

        public void GetPolicyType()
        {
            var polType = new CoreSystem<fl_poltype>(context).FindAll(x=>x.IsDeleted==false);
            ViewBag.polType = new SelectList(polType, "Id", "poldesc");
        }

        public void GetLocation()
        {
            var loc = new CoreSystem<fl_location>(context).FindAll(x=>x.Isdeleted==false);
            ViewBag.location = new SelectList(loc, "Id", "locdesc");

        }
        public void GetClaimType()
        {
            var clmTypes = UtilEnumHelper.GetEnumList(typeof(ClaimType));
            ViewBag.clmTypes = new SelectList(clmTypes, "ID", "Name");

        }
    }
}