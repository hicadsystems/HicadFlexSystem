using Flex.Business;
using Flex.Data.Model;
using Flex.Util;
using Flex.Utility.Utils;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Flex.Controllers
{
    public class AgentDashBoardController : BaseController
    {
        // GET: DashBoard
        public ActionResult Index()
        {
            try
            {
                var uSession = GetUserSesiion();
                var roleId = uSession.fl_password.UserRoles.ToList()[0].RoleId;
                //var roleId = 1012;
                var Role = new CoreSystem<Role>(context).FindAll(x => x.Id == roleId).FirstOrDefault();
                var portlets = new List<Portlet>();
                using (var _context = context)
                {
                    portlets = new PortletSystem(context).RetrivePortlets(Convert.ToInt64(roleId));
                }
                return View(portlets);
            }
            catch (Exception ex)
            {
                Logger.ErrorFormat("Error Occurred. details {0}", ex.ToString());
                //throw;
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }

        }

        public ActionResult PortletDefaultPage(int id)
        {
            Logger.InfoFormat("PortletId : {0}", id);
            string defaultController;
            var USession = GetUserSesiion();
            var RoleId = USession.fl_password.UserRoles.ToList()[0].RoleId;

            var allowedTabs = new List<int?>();
            var tabs = new List<Tab>();

            using(var _context= context)
            {
                allowedTabs = new CoreSystem<LinkRole>(context).FindAll(x => x.Parent == id && x.RoleID == RoleId).ToList().Select(x => x.LinkId).ToList();
                tabs = new TabSystem(context).RetrieveTabs(allowedTabs.Cast<int>().ToList()) as List<Tab>;
            }
            if (tabs.Any())
            {
                defaultController = tabs[0].Controller;
                //defaultAction = tabs[0].Action;
                //Logger.InfoFormat("DefaultController: {0}", defaultController);
                //Logger.InfoFormat("defaultAction: {0}", defaultAction);
                TempData["Tabs"]=tabs;
                //TempData["DefaultView"] = tabs[0].View;
                //Logger.InfoFormat("DefaultView : {0}", tabs[0].View);
                return RedirectToAction("Index",defaultController);
            }
            return View();
        }
    }
}