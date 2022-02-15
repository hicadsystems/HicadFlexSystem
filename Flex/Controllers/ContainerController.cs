using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Flex.Controllers
{
    public class ContainerController : BaseController
    {
        // GET: Container
        public ActionResult Index()
        {
            List<Tab> tabs=new List<Tab>();
            string defaultController;
            string defaultAction;
            if (TempData["Tabs"] == null)
            {
                return RedirectToAction("Index", "DashBoard");
            }
            //if (TempData["DefaultView"] == null)
            //{
            //    return RedirectToAction("Index", "DashBoard");
            //}
             ViewBag.Tab=tabs= TempData["Tabs"] as List<Tab>;
             defaultController = tabs[0].Controller;
             defaultAction = tabs[0].Action;
            Logger.InfoFormat("{0} tabs available", tabs.Count());
            ViewBag.DefaultView = TempData["DefaultView"];
            return View();
        }

    }
}