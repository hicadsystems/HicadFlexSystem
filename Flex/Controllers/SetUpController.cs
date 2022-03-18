using Flex.Business;
using Flex.Controllers.Util;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using Flex.Models.ReportModel;
using Flex.Util;
using Flex.Utility.Utils;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Flex.Controllers
{
    public class SetUpController : ContainerController
    {
        // GET: SetUp

        public ActionResult CompanyProfile() 
        {
            try
            {
                
                var coyProfile = new fl_system();
                using (var _context= context)
                {
                    coyProfile = new CoreSystem<fl_system>(_context).FindAll(x => x.IsDeleted == false).FirstOrDefault();
                }
                return PartialView("_CoyProfileView",coyProfile);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        [HttpGet]
        public ActionResult AddEditCoyProfile(string mode, string coyCode=null)
        {
            try
            {
                var coy = new fl_system();
                if (!mode.ToLower().Equals("new"))
                {
                    using(var _context = context)
                    {
                        coy = new CoreSystem<fl_system>(_context).FindAll(x => x.coycode == coyCode).FirstOrDefault();
                    }
                }
                return PartialView("_CoyProfileInput",coy);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SaveUpdate(FormCollection formdata)
        {
            try
            {
                int Id = 0;
                string mode=string.Empty;
                var coy = new fl_system();

                if (formdata != null)
                {
                    coy.box = formdata["box"].ToString();
                    coy.coyaddress = formdata["Address"].ToString();
                    coy.coycode = formdata["Code"].ToString();
                    coy.coyname = formdata["Name"].ToString();
                    coy.datecreated = DateTime.Today;
                    coy.email = formdata["Email"].ToString();
                    coy.installdate = formdata["InstallDate"].ToString();
                    coy.lg = formdata["LGA"].ToString();
                    coy.processmonth = formdata["ProcessMonth"].ToString();
                    coy.processyear = formdata["ProcessYear"].ToString();
                    coy.state = formdata["State"].ToString();
                    coy.telephone = formdata["Phone"].ToString();
                    coy.town = formdata["Town"].ToString();
                    coy.IsDeleted = false;

                    mode = formdata["mode"].ToString();

                    using (var _context= context)
                    {
                        if (mode.ToLower().Equals("new"))
                        {
                            new CoreSystem<fl_system>(_context).Save(coy);
                        }
                        else
                        {
                            int.TryParse(formdata["Id"].ToString(), out Id);
                            coy.Id = Id;
                            new CoreSystem<fl_system>(_context).Update(coy, coy.Id);
                        }
                    }
                }
                return RedirectToAction("CompanyProfile");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult Groups()
        {
            try
            {
                var grps = new PagedResult<fl_grouptype>();
                Func <fl_grouptype, dynamic> orderFunc = u => u.Id;
                using (var _context= context)
                {
                    var query = new CoreSystem<fl_grouptype>(_context).FindAll(x => x.IsDeleted == false);
                    grps = new CoreSystem<fl_grouptype>(_context).PagedQuery(orderFunc, query);
                }
                return PartialView("_groups",grps);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SearchGroupList(string searchterm, string page, string size)
        {
            int xpage = 0; int xsize = 0;
            var grps = new PagedResult<fl_grouptype>();

            try
            {
                using (var _context = context)
                {
                    Func<fl_grouptype, dynamic> orderFunc = u => u.Id;
                    var query = new CoreSystem<fl_grouptype>(_context).FindAll(x => x.IsDeleted == false);
                    if (!string.IsNullOrEmpty(searchterm))
                    {
                        query = query.Where(x => x.grpcode.ToLower().Contains(searchterm.ToLower()) || x.grpname.ToLower().Contains(searchterm.ToLower()));
                    }
                    int.TryParse(page, out xpage);
                    int.TryParse(size, out xsize);
                    grps = new CoreSystem<fl_grouptype>(_context).PagedQuery(orderFunc, query, xpage, xsize);
                }

                return PartialView("_tbGroups", grps);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        //V2
        public ActionResult SearchGroup(SearchModel searchmodel)
        {
            int xpage = 0; int xsize = 0;
            var grps = new PagedResult<fl_grouptype>();

            try
            {
                using (var _context = context)
                {
                    //Func<fl_grouptype, dynamic> orderFunc = u => u.Id;
                    var query = new CoreSystem<fl_grouptype>(_context).FindAll(x => x.IsDeleted == false);
                    if (!string.IsNullOrEmpty(searchmodel.SearchTerm))
                    {
                        query = query.Where(x => x.grpcode.ToLower()
                        .Contains(searchmodel.SearchTerm.ToLower()) || x.grpname.ToLower()
                        .Contains(searchmodel.SearchTerm.ToLower()));
                    }

                    Func<fl_grouptype, dynamic> orderFunc = u => u.Id;
                    if (searchmodel.Page != null)
                    {
                        if (!string.IsNullOrEmpty(searchmodel.Page.Page))
                        {
                            int.TryParse(searchmodel.Page.Page, out xpage);
                        }

                        if (!string.IsNullOrEmpty(searchmodel.Page.Size))
                        {
                            int.TryParse(searchmodel.Page.Size, out xsize);
                        }
                    }

                    grps = new CoreSystem<fl_grouptype>(_context).PagedQuery(orderFunc, query, xpage, xsize);
                }

                return PartialView("_tbGroups", grps);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult AddEditGroup(long GroupId=0)
        {
            try
            {
                Logger.Info("PolicyGroup");
                fl_grouptype grp = new fl_grouptype();

                using (var _context = context)
                {
                    getGroupClass();
                    if (GroupId>0)
                    {
                        grp = new CoreSystem<fl_grouptype>(_context).Get(GroupId);
                    }

                    ViewBag.Accounts = GroupId > 0 ? getAccounts(grp.accountcode) : getAccounts();
                }
                return PartialView("_addEditGroup", grp);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SaveUpdateGroup(FormCollection formdata)
        {
            Logger.Info("About to save group");
            try
            {
                int Id = 0;
                int month = 0;
                var grp = new fl_grouptype();

                if (formdata != null)
                {
                    int.TryParse(formdata["Id"].ToString(), out Id);
                    grp.Address = formdata["Address"].ToString();
                    grp.grpcode = formdata["Code"].ToString();
                    grp.grpname = formdata["Name"].ToString();
                    grp.DateCreated = DateTime.Today;
                    grp.accountcode = formdata["Account"].ToString();
                    grp.annmonth = formdata["Month"].ToString();
                    grp.grpclass = formdata["Report"].ToString();
                    grp.IsDeleted = false;

                    month = Convert.ToInt32(grp.annmonth);

                   
                        if (month < 1 || month > 12)
                        {
                            throw new Exception("Invalid month input");
                        }
                   

                    using (var _context= context)
                    {
                        if (Id == 0)
                        {
                            new CoreSystem<fl_grouptype>(_context).Save(grp);
                        }
                        else
                        {
                            grp.Id = Id;
                            new CoreSystem<fl_grouptype>(_context).Update(grp, grp.Id);
                        }
                    }
                }
                return RedirectToAction("Groups");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult DeleteGroup(long Id)
        {
            var grp = new fl_grouptype();
            using (var _context= context)
            {
                grp = new CoreSystem<fl_grouptype>(_context).Get(Id);
            }

            var mModel = new ModalModel()
            {
                Id = grp.Id,
                Desc = string.Format("Are you sure you want to delete Group [{0}]", grp.grpname)
            };

            return PartialView("_deleteConfirmation", mModel);
        }

        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult DelGroup(long Id)
        {
            using (var _context= context)
            {
                var grp = new CoreSystem<fl_grouptype>(_context).Get(Id);

                grp.IsDeleted = true;

                new CoreSystem<fl_grouptype>(_context).Update(grp, Id);

            }

            return RedirectToAction("Groups");
        }
        public ActionResult Agents()
        {
            Logger.Info("Inside Agents");
            var agents = new PagedResult<fl_agents>();
            try
            {
                getAgentType(0);
                getCostCentre(-10);
                using (var _context= context)
                {
                    Func<fl_agents, dynamic> orderFunc = u => u.Id;
                    var query = new CoreSystem<fl_agents>(_context).FindAll(x => x.IsDeleted == false);
                    agents = new CoreSystem<fl_agents>(_context).PagedQuery(orderFunc, query);

                }


                return PartialView("_agents", agents);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SearchAgent(AgentQueryModel searchmodel)
        {
            Logger.Info("Inside Search Agents");
            int xpage = 0; int xsize = 0;
            var agents = new PagedResult<fl_agents>();
            try
            {
                using (var _context = context)
                {
                    var query = _context.fl_agents.Include("ac_costCenter").Where(x => x.IsDeleted == false);

                    if (!string.IsNullOrEmpty(searchmodel.Name))
                    {
                        query = query.Where(x => x.agentname.ToLower().Contains(searchmodel.Name.ToLower()));
                    }
                    if (!string.IsNullOrEmpty(searchmodel.Type))
                    {
                        var agtype = (AgentType)Enum.Parse(typeof(AgentType), searchmodel.Type);
                        query = query.Where(x => x.agenttype == agtype);
                    }
                    if (!string.IsNullOrEmpty(searchmodel.Location))
                    {
                        var loc = Convert.ToInt32(searchmodel.Location);
                        query = query.Where(x => x.locationId == loc);
                    }
                    Func<fl_agents, dynamic> orderFunc = u => u.Id;
                    if (searchmodel.Page != null)
                    {
                        if (!string.IsNullOrEmpty(searchmodel.Page.Page))
                        {
                            int.TryParse(searchmodel.Page.Page, out xpage);
                        }

                        if (!string.IsNullOrEmpty(searchmodel.Page.Size))
                        {
                            int.TryParse(searchmodel.Page.Size, out xsize);
                        }
                    }

                    agents = new CoreSystem<fl_agents>(_context).PagedQuery(orderFunc, query, xpage, xsize);
                }
                
                return PartialView("_tbAgents", agents);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult Agent2(QueryModel query = null)
        {
            Logger.Info("Inside Agents");
            try
            {
                using (var _context = context)
                {
                    List<rptAgent> poltypes = new List<rptAgent>();

                     poltypes = new CoreSystem<fl_agents>(_context).FindAll(x => x.IsDeleted == false).Select(x=>new rptAgent() {
                         AgentCode = x.agentcode,
                         AgentName = x.agentname,
                         //AgentType = x.agenttype,
                         AgentLocation = x.ac_costCenter.Desc,
                         Phone = x.agentphone
                     }).ToList();

                    if (query == null)
                    {
                        return RedirectToAction("Agents");
                    }
                    else
                    {
                        var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.AgentDetails);
                        var rpt = new CrystalReportEngine();
                        rpt.reportFormat = ReportFormat.pdf;

                        rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                        var savedir = Server.MapPath(ConfigUtils.ReportPath);
                        var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                        rpt.ReportName = Path.Combine(savedir, reportName);
                        rpt.GenerateReport(poltypes);

                        return ExportReport(reportName);
                       

                    }
                }
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

       

        public ActionResult AddEditAgent(long AgentId = 0)
        {
            try
            {
                Logger.Info("Add/Edit Agents");
                fl_agents agent = new fl_agents();
                using (var _context = context)
                {
                    if (AgentId > 0)
                    {
                        agent = new CoreSystem<fl_agents>(_context).Get(AgentId);
                    }

                    var agTypeSelected = agent.Id > 0 ? (int)agent.agenttype : -1;
                    var locSelected = agent.Id > 0 ? (int)agent.locationId : 0;
                    var status = agent.Id > 0 ? (int)agent.status.GetValueOrDefault() : -1;
                    getAgentType(agTypeSelected);
                    getCostCentre(locSelected);
                    GetStatus(status);
                }

                return PartialView("_addEditAgents", agent);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SaveUpdateAgent(FormCollection formdata)
        {
            Logger.Info("About to save agent");
            try
            {
                int Id = 0;
                var agent = new fl_agents();
                

                if (formdata != null)
                {
                    int.TryParse(formdata["Id"].ToString(), out Id);
                    var agType=formdata["Type"].ToString();
                    agent.agenttype = (AgentType)Enum.Parse(typeof(AgentType),agType);
                    agent.agentcode = formdata["Code"].ToString();
                    agent.agentname = formdata["Name"].ToString();
                    agent.datecreated = DateTime.Today;
                    agent.CommissionRate = Convert.ToDecimal(formdata["Commission"].ToString());
                    agent.locationId = Convert.ToInt16(formdata["Location"].ToString());
                    agent.agentaddr = formdata["Address"].ToString();
                    agent.agentphone = formdata["Phone"].ToString();
                    agent.IsDeleted = false;
                    agent.exitdate = formdata["ExitDate"].ToString();
                    var status = formdata["Status"].ToString();
                    agent.status = (Status)Enum.Parse(typeof(Status), status);

                    using (var _context = context)
                    {
                        if (Id == 0)
                        {
                            agent.agentcode = new UtilitySystem().GenerateAgentCode(_context);
                            new CoreSystem<fl_agents>(_context).Save(agent);
                        }
                        else
                        {
                            agent.Id = Id;
                            new CoreSystem<fl_agents>(_context).Update(agent, agent.Id);
                        }
                    }
                   
                }
                return RedirectToAction("Agents");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult DeleteAgent(long Id)
        {
            var agent = new fl_agents();
            using (var _context = context)
            {
                agent = new CoreSystem<fl_agents>(_context).Get(Id);
            }
            var mModel = new ModalModel()
            {
                Id = agent.Id,
                Desc = string.Format("Are you sure you want to delete Agent [{0}]", agent.agentname)
            };

            return PartialView("_deleteConfirmation", mModel);
        }

        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult DelAgent(long Id)
        {
            using (var _context = context)
            {
                var agent = new CoreSystem<fl_agents>(_context).Get(Id);

                agent.IsDeleted = true;

                new CoreSystem<fl_agents>(_context).Update(agent, Id);
            }

            return RedirectToAction("Agents");
        }

        public ActionResult Location()
        {
            Logger.Info("Inside Location");
            try
            {
                var locs = new PagedResult<fl_location>();
                using (var _context = context)
                {
                    Func<fl_location, dynamic> orderFunc = u => u.Id;
                    var query = new CoreSystem<fl_location>(_context).FindAll(x => x.Isdeleted == false);
                    locs = new CoreSystem<fl_location>(_context).PagedQuery(orderFunc, query);
                }
                //var locs = new CoreSystem<fl_location>(_context).FindAll(x=>x.Isdeleted==false).ToList();
                return PartialView("_location", locs);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SearchLocation(SearchModel searchmodel)
        {
            Logger.Info("Inside Search Location");
            try
            {
                int xpage = 0; int xsize = 0;
                using (var _context = context)
                {
                    var query = new CoreSystem<fl_location>(_context).FindAll(x => x.Isdeleted == false);
                    if (!string.IsNullOrEmpty(searchmodel.SearchTerm))
                    {
                        query = query.Where(x => x.loccode.ToLower().Contains(searchmodel.SearchTerm.ToLower())
                            || x.locdesc.ToLower().Contains(searchmodel.SearchTerm.ToLower()) || x.locstate.ToLower().Contains(searchmodel.SearchTerm.ToLower()));
                    }

                    Func<fl_location, dynamic> orderFunc = u => u.Id;
                    if (searchmodel.Page != null)
                    {
                        if (!string.IsNullOrEmpty(searchmodel.Page.Page))
                        {
                            int.TryParse(searchmodel.Page.Page, out xpage);
                        }

                        if (!string.IsNullOrEmpty(searchmodel.Page.Size))
                        {
                            int.TryParse(searchmodel.Page.Size, out xsize);
                        }
                    }

                    var locs = new CoreSystem<fl_location>(_context).PagedQuery(orderFunc, query, xpage, xsize);
                    if (!searchmodel.IsReport)
                    {
                        return PartialView("_tbLocation", locs);
                    }
                    else
                    {
                        var rptFormat = !string.IsNullOrEmpty(searchmodel.ReportFormat) ? (ReportFormat)Enum.Parse(typeof(ReportFormat), searchmodel.ReportFormat) : ReportFormat.pdf;
                        var rpt = new CrystalReportEngine();
                        rpt.reportFormat = rptFormat != null ? rptFormat : ReportFormat.pdf;
                        var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.Location);
                        rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                        rpt.ReportName = ReportUtil.Constants.Location;

                        var contentType = rptFormat == ReportFormat.pdf ? "application/pdf" : "application/xls";
                        var savedir = Server.MapPath(ConfigUtils.ReportPath);
                        var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                        rpt.ReportName = Path.Combine(savedir, reportName);
                        rpt.GenerateReport(query.Select(x => new rptLocation()
                        {
                            Code = x.loccode,
                            Description = x.locdesc,
                            State = x.locstate
                        }).ToList());
                        return ExportReport(reportName);
                        //return new ReportFileActionResult(rpt.streamProduct, rpt.ReportName, contentType);
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult AddEditLocation(long Id = 0)
        {
            try
            {
                Logger.Info("Add/Edit Location");
                var loc = new fl_location();
                using (var _context = context)
                {
                    if (Id > 0)
                    {
                        loc = new CoreSystem<fl_location>(_context).Get(Id);
                    }

                    ViewBag.States = GetStates(loc.locstate);
                }
                return PartialView("_addEditLocation", loc);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SaveUpdateLocation(FormCollection formdata)
        {
            Logger.Info("About to save location");
            try
            {
                int Id = 0;
                var loc = new fl_location();

                if (formdata != null)
                {
                    int.TryParse(formdata["Id"].ToString(), out Id);
                    loc.locstate = formdata["State"].ToString();
                    loc.loccode = formdata["Code"].ToString();
                    loc.locdesc = formdata["Desc"].ToString();
                    loc.datecreated = DateTime.Today;
                    loc.Isdeleted = false;

                    var IsValid = validateLocation(loc.loccode, loc.locdesc, Id);
                    if (IsValid)
                    {
                        throw new Exception(string.Format("Location with Code {0} or Description {1} already exists", loc.loccode, loc.locdesc));
                    }
                    using (var _context = context)
                    {
                        if (Id == 0)
                        {
                            new CoreSystem<fl_location>(_context).Save(loc);
                        }
                        else
                        {
                            loc.Id = Id;
                            new CoreSystem<fl_location>(_context).Update(loc, loc.Id);
                        }
                    }
                }
                return RedirectToAction("Location");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        private bool validateLocation(string code, string desc, int Id)
        {
            try
            {
                var loc = new List<fl_location>();
                var _context = context;
                //using(var _context= context)
                //{

                //}

                var query = new CoreSystem<fl_location>(_context).FindAll(x => x.loccode.ToLower() == code.ToLower() || x.locdesc == desc.ToLower());

                if (Id > 0)
                {
                    query = query.Where(x => x.Id != Id);
                }

                loc = query.ToList();

                var isValid = loc.Any();

                return isValid;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. detail {0}", ex.ToString());
                throw;
            }
        }

        public ActionResult DeleteLocation(long Id)
        {
            var loc = new fl_location();
            using(var _context = context)
            {
                loc = new CoreSystem<fl_location>(_context).Get(Id);
            }

            var mModel = new ModalModel()
            {
                Id = loc.Id,
                Desc = string.Format("Are you sure you want to delete Location [{0}]", loc.locdesc)
            };

            return PartialView("_deleteConfirmation", mModel);
        }

        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult cDeleteLocation(long Id)
        {
            using (var _context = context)
            {
                var loc = new CoreSystem<fl_location>(_context).Get(Id);

                loc.Isdeleted = true;

                new CoreSystem<fl_location>(_context).Update(loc, Id);
            }
            return RedirectToAction("Location");
        }

        public ActionResult PolicyType()
        {
            return PolicyType2(null);
        }
        public ActionResult PolicyType2(QueryModel query=null)
        {
            Logger.Info("Inside PolicyType");
            try
            {
                using (var _context = context)
                {
                    List<rptPolicyType> poltypes2 = new List<rptPolicyType>();
                  
                    var poltypes = new CoreSystem<fl_poltype>(_context).FindAll(x => x.IsDeleted == false).ToList();
                    if (query == null)
                    {
                        return PartialView("_policyType", poltypes);
                    }
                    else
                    {
                        poltypes2 = new CoreSystem<fl_poltype>(_context).FindAll(x => x.IsDeleted == false).Select(x => new rptPolicyType()
                        {
                            PolicyType = x.poltype,
                            Code = x.code,
                            Description = x.poldesc,
                            IncomeAcct = x.income_account
                        }).ToList();

                        var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.PolicyType);
                        var rpt = new CrystalReportEngine();
                        rpt.reportFormat = ReportFormat.pdf;

                        rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                        var savedir = Server.MapPath(ConfigUtils.ReportPath);
                        var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                        rpt.ReportName = Path.Combine(savedir, reportName);
                        rpt.GenerateReport(poltypes2);

                        return ExportReport(reportName);
                        /*var rptFormat = !string.IsNullOrEmpty(query.ReportFormat) ? (ReportFormat)Enum.Parse(typeof(ReportFormat), query.ReportFormat) : ReportFormat.pdf;
                        var rpt = new CrystalReportEngine();
                        rpt.reportFormat = rptFormat != null ? rptFormat : ReportFormat.pdf;
                        rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), ReportUtil.GetConfig(ReportUtil.Constants.PolicyType));
                        rpt.ReportName = ReportUtil.Constants.PolicyType;
                        rpt.GenerateReport(poltypes.Select(x => new rptPolType()
                        {
                            PolicyType = x.poltype,
                            Description = x.poldesc,
                            IncomeAcct = x.income_account
                        }).ToList());
                        var contentType = rptFormat == ReportFormat.pdf ? "application/pdf" : "application/xls";
                        return new ReportFileActionResult(rpt.streamProduct, rpt.ReportName, contentType);*/

                    }
                }
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult AddEditPolicyType(long Id = 0)
        {
            try
            {
                Logger.Info("Add/Edit PolicyType");
                var poltype = new fl_poltype();
                using (var _context = context)
                {
                    if (Id > 0)
                    {
                        poltype = new CoreSystem<fl_poltype>(_context).Get(Id);
                    }
                    var incomeSelected = poltype.Id > 0 ? poltype.income_account : "";
                    var expSelected = poltype.Id > 0 ? poltype.expense_account : "";
                    var liabitySelected = poltype.Id > 0 ? poltype.liability_account : "";
                    var vatSelected = poltype.Id > 0 ? poltype.vat_account : "";

                    ViewBag.IncomeAcct = getAccounts(incomeSelected);
                    ViewBag.ExpenseAcct = getAccounts(expSelected);
                    ViewBag.LiabilityAcct = getAccounts(liabitySelected);
                    ViewBag.VatAcct = getAccounts(vatSelected);
                }
                return PartialView("_addEditPolicyType", poltype);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SaveUpdatePolicyType(FormCollection formdata)
        {
            Logger.Info("About to save PolicyType");
            try
            {
                int Id = 0;
                int term = 0;
                int matage = 0;
                decimal maxLoan = 0.0M;
                var poltype = new fl_poltype();

                if (formdata != null)
                {
                    int.TryParse(formdata["Id"].ToString(), out Id);
                    poltype.actype = formdata["Type"].ToString();
                    poltype.code = formdata["Code"].ToString();
                    poltype.poltype = formdata["PolType"].ToString(); 
                    poltype.poldesc = formdata["Desc"].ToString();
                    int.TryParse(formdata["Term"].ToString(), out term);
                    poltype.term = term;
                    int.TryParse(formdata["Matage"].ToString(), out matage);
                    poltype.matage = matage;
                    decimal.TryParse(formdata["MaxLoan"].ToString(), out maxLoan);
                    poltype.maxloan = maxLoan;
                    poltype.income_account = formdata["Income"].ToString();
                    poltype.liability_account = formdata["Liability"].ToString();
                    poltype.expense_account = formdata["Expense"].ToString();
                    poltype.vat_account = formdata["Vat"].ToString();

                    poltype.IsDeleted = false;

                    using(var _context = context)
                    {
                        if (Id == 0)
                        {
                            poltype.Datecreated = DateTime.Now;
                            new CoreSystem<fl_poltype>(_context).Save(poltype);
                        }
                        else
                        {
                            poltype.Id = Id;
                            poltype.DateModified = DateTime.Now;
                            new CoreSystem<fl_poltype>(_context).Update(poltype, poltype.Id);
                        }
                    }
                    
                }
                return RedirectToAction("PolicyType");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult DeletePolicyType(long Id)
        {
            var poltype = new fl_poltype();
            using(var _context= context)
            {
                poltype = new CoreSystem<fl_poltype>(_context).Get(Id);
            }

            var mModel = new ModalModel()
            {
                Id = poltype.Id,
                Desc = string.Format("Are you sure you want to delete Policy Type [{0}]", poltype.poldesc)
            };

            return PartialView("_deleteConfirmation", mModel);
        }

        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult cDeletePolicyType(long Id)
        {
            using (var _context = context)
            {
                var poltype = new CoreSystem<fl_poltype>(_context).Get(Id);

                poltype.IsDeleted = true;

                new CoreSystem<fl_poltype>(_context).Update(poltype, Id);
            }

            return RedirectToAction("PolicyType");
        }

        public ActionResult LifeRate()
        {
            Logger.Info("Inside Life Rate");
            try
            {
                var rates = new List<fl_premrate>();
                var _context = context;
                //using (var _context = context)
                //{
                    getGroup();
                    getPolicyType();
               
                    rates = new CoreSystem<fl_premrate>(_context).GetAll().OrderByDescending(x => x.period).Take(15).ToList();
                //}

                return PartialView("_lifeRate", rates);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        public ActionResult LifeRate2(QueryModel query = null)
        {
            Logger.Info("Inside PolicyType");
            try
            {
                using (var _context = context)
                {
                    List<rptLifeRate> liferate2 = new List<rptLifeRate>();
                    List<rptLifeRate> liferate3 = new List<rptLifeRate>();
                    rptLifeRate rate2 = new rptLifeRate();
                    

                    var liferate = new CoreSystem<fl_premrate>(_context).FindAll(x => x.IsDeleted == false).ToList();
                    if (query == null)
                    {
                        return PartialView("_policyType", liferate);
                    }
                    else
                    {
                        liferate2 = new CoreSystem<fl_premrate>(_context).FindAll(x => x.IsDeleted == false).Select(x => new rptLifeRate()
                        {
                           PolicyType = x.fl_poltype.poldesc,
                           Group = x.grpcodeId.Value,
                           Period = x.period
                        }).ToList();

                        foreach (var rate in liferate2)
                        {
                            liferate3.Add(new rptLifeRate
                            {
                                PolicyType = rate.PolicyType,
                                Period = rate.Period,
                                GroupDesc = GetGroupDesc(rate.Group)
                            });
                        }
                        var rptdir = ReportUtil.GetConfig(ReportUtil.Constants.LifeRate);
                        var rpt = new CrystalReportEngine();
                        rpt.reportFormat = ReportFormat.pdf;

                        rpt.ReportPath = Path.Combine(Server.MapPath(ReportUtil.GetConfig(ReportUtil.Constants.BaseURL)), rptdir);
                        var savedir = Server.MapPath(ConfigUtils.ReportPath);
                        var reportName = rptdir.Split('.')[0] + "_" + DateTime.Now.ToString("yyyyMMddhhmmssfff") + ".pdf";
                        rpt.ReportName = Path.Combine(savedir, reportName);
                        rpt.GenerateReport(liferate3);

                        return ExportReport(reportName);
                        

                    }
                }
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        private  string GetGroupDesc(int code)
        {
            //var grpdesc = string.Empty;
            var _context = context;
            var grpdesc = new CoreSystem<fl_grouptype>(_context).FindAll(x => x.IsDeleted == false)
                        .Where(x => x.Id == code).Select(x => x.grpname).FirstOrDefault(); 
            return grpdesc;
        }
        public ActionResult SearchLifeRate(RateQueryModel searchmodel)
        {
            Logger.Info("Inside search Life Rate");
            try
            {
                var rates = new List<fl_premrate>();
                using (var _context = context)
                {
                    var query = new CoreSystem<fl_premrate>(_context).GetAll().IncludeMultiple(p=>p.fl_poltype);
                    

                    if (!string.IsNullOrEmpty(searchmodel.Period))
                    {
                        query = query.Where(x => x.period == searchmodel.Period);
                    }
                    if (!string.IsNullOrEmpty(searchmodel.PolicyType))
                    {
                        var poltypeId = Convert.ToInt32(searchmodel.PolicyType);
                        query = query.Where(x => x.poltypeId == poltypeId);
                    }
                    if (!string.IsNullOrEmpty(searchmodel.Group))
                    {
                        var groupId = 0;
                        int.TryParse(searchmodel.Group, out groupId);
                        query = query.Where(x => x.grpcodeId == groupId);
                    }

                    rates = query.ToList();
                }
                return PartialView("_tbrates", rates);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult AddRate()
        {
            string policy = WebSecurity.Module.Trim().ToUpper();
            try
            {
                Logger.Info("Add liferates");
                getPolicyType();
                getGroup();
                var rate = new fl_premrate();
                if (policy == "PPP2")
                {
                    return PartialView("_addRate2", rate);
                }
                else
                {
                    return PartialView("_addRate", rate);
                }
                
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
            return View();
        }

        public ActionResult Saveliferate(string model)
        {
            Logger.Info("About to save life rate");
            try
            {
                int poltype = 0;
                var grpId = 0;
                //decimal interest = 0.0M;
                //decimal commrate = 0.0M;
                ////decimal retention = 0.0M;
                //decimal intrbound = 0.0M;
                //decimal commbound = 0.0M;
                var rate = new fl_premrate();
                var formdata = JsonConvert.DeserializeObject<Rate>(model);
                List<fl_premrateRules> rrules = null;
                if (formdata != null)
                {
                    grpId = formdata.Group;
                    rate.grpcodeId = grpId;
                    rate.grpcode = new CoreSystem<fl_grouptype>(context).FindAll(x => x.Id == grpId).Select(x => x.grpcode).FirstOrDefault();
                    rate.period = formdata.Period.ToString();
                    int.TryParse(formdata.PolType.ToString(), out poltype);
                    rate.poltypeId = poltype;
                    if (formdata.rateRules != null && formdata.rateRules.Any())
                    {
                        rrules = formdata.rateRules.Select(x => new fl_premrateRules()
                        {
                            CommBound=x.CommUpperLimit,
                            CommRate=x.Commission,
                            Interest=x.intr,
                            IntrBound=x.IntrUpperLimit,
                            Mkt_CommRate=x.MktCommRate
                        }).ToList();
                       
                        //rate.mkt_commrate = formdata.rateRules.MktCommRate.ToString();
                        //decimal.TryParse(formdata.rateRules.Commission.ToString(), out commrate);
                        //rate..commrate = commrate;

                        //decimal.TryParse(formdata.rateRules.Commission.ToString(), out commrate);
                        //rate.commrate = commrate;

                    }
                    rate.IsDeleted = false;

                    rate.Datecreated = DateTime.Now;
                    using (var _context = context)
                    {
                        if (new CoreSystem<fl_premrate>(_context).FindAll(x => x.period == rate.period && x.poltypeId == rate.poltypeId).Any())
                        {
                            throw new Exception("Rate has been added for this policy for this period");
                        }
                        new CoreSystem<fl_premrate>(_context).Save(rate);

                        foreach (var rule in rrules)
                        {
                            rule.PremRateId = rate.Id;
                            new CoreSystem<fl_premrateRules>(_context).Save(rule);
                        }
                    }
                }
                return RedirectToAction("LifeRate");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult GetRateRules(int Id)
        {
            try
            {
                var rate = new List<fl_premrateRules>();
                using (var _context = context)
                {
                    rate = _context.Set<fl_premrateRules>().Where(x=>x.PremRateId==Id).ToList();
                }
                return PartialView("_rateRules", rate);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult PublicHoliday()
        {
            try
            {
                var holidays = new PagedResult<fl_PublicHoliday>();
                Func<fl_PublicHoliday, dynamic> orderFunc = u => u.Id;
                using (var _context = context)
                {
                    var query = new CoreSystem<fl_PublicHoliday>(_context).GetAll();
                    holidays = new CoreSystem<fl_PublicHoliday>(_context).PagedQuery(orderFunc, query);
                }
                return PartialView("_publicholiday", holidays);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SearchPublicHoliday(string searchterm = "", string page = "", string size = "", SearchModel searchmodel=null)
        {
            int xpage = 0; int xsize = 0;
            var holidays = new PagedResult<fl_PublicHoliday>();
            try
            {
                using (var _context = context)
                {
                    if (searchmodel.Page==null)
                    {
                        Func<fl_PublicHoliday, dynamic> orderFunc = u => u.Id;
                        var query = new CoreSystem<fl_PublicHoliday>(_context).FindAll(x => x.IsDeleted == false);
                        if (!string.IsNullOrEmpty(searchterm))
                        {
                            query = query.Where(x => x.HolidayName.ToLower().Contains(searchterm.ToLower()) || x.HolidayMsg.ToLower().Contains(searchterm.ToLower()));
                        }
                        int.TryParse(page, out xpage);
                        int.TryParse(size, out xsize);
                        holidays = new CoreSystem<fl_PublicHoliday>(_context).PagedQuery(orderFunc, query, xpage, xsize); 
                    }
                    else
                    {
                        var query = new CoreSystem<fl_PublicHoliday>(_context).FindAll(x => x.IsDeleted == false);
                        if (!string.IsNullOrEmpty(searchmodel.SearchTerm))
                        {
                            query = query.Where(x => x.HolidayName.ToLower()
                            .Contains(searchmodel.SearchTerm.ToLower()) || x.HolidayMsg.ToLower()
                            .Contains(searchmodel.SearchTerm.ToLower()));
                        }

                        Func<fl_PublicHoliday, dynamic> orderFunc = u => u.Id;
                        if (searchmodel.Page != null)
                        {
                            if (!string.IsNullOrEmpty(searchmodel.Page.Page))
                            {
                                int.TryParse(searchmodel.Page.Page, out xpage);
                            }

                            if (!string.IsNullOrEmpty(searchmodel.Page.Size))
                            {
                                int.TryParse(searchmodel.Page.Size, out xsize);
                            }
                        }

                        holidays = new CoreSystem<fl_PublicHoliday>(_context).PagedQuery(orderFunc, query, xpage, xsize); 
                    }
                }

                return PartialView("_tbHolidays", holidays);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult AddEditHoliday(long HolidayId = 0)
        {
            try
            {
                Logger.Info("Holiday");
                fl_PublicHoliday holiday = new fl_PublicHoliday();

                var months = Enumerable.Range(1, 12).Select(i => new { ID = i, Name = DateTimeFormatInfo.CurrentInfo.GetMonthName(i) });

                ViewBag.Months= new SelectList(months, "ID", "Name");
                using (var _context = context)
                {
                    if (HolidayId > 0)
                    {
                        holiday = new CoreSystem<fl_PublicHoliday>(_context).Get(HolidayId);
                        ViewBag.Months = new SelectList(months, "ID", "Name",holiday.holidaymonth.GetValueOrDefault());
                    }
                }
                return PartialView("_addEditHoliday", holiday);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SaveUpdateHoliday(fl_PublicHoliday model)
        {
            Logger.Info("About to save Public holiday");
            try
            {
                var holiday = new fl_PublicHoliday();

                if (model==null)
                {
                    return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, "Invalid Data");
                }
                using (var _context = context)
                {
                    if (model.Id == 0)
                    {
                        holiday = model;
                        holiday.IsActive = true;
                        holiday.IsDeleted = false;
                        new CoreSystem<fl_PublicHoliday>(_context).Save(holiday);
                    }
                    else
                    {
                        holiday = _context.fl_PublicHoliday.Where(x => x.Id == model.Id).FirstOrDefault();
                        if (holiday== null)
                        {
                            return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, $"No Record for Public Holiday with Id {model.Id} found");
                        }
                        holiday = model;
                        holiday.IsActive = true;
                        holiday.IsDeleted = false;
                        holiday.Id = model.Id;
                        new CoreSystem<fl_PublicHoliday>(_context).Update(holiday, holiday.Id);
                    }
                }
                return RedirectToAction("PublicHoliday");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult ShowHolidayToggle(long Id)
        {
            var holiday = new fl_PublicHoliday();
            using (var _context = context)
            {
                holiday = new CoreSystem<fl_PublicHoliday>(_context).Get(Id);
            }

            var action = holiday.IsActive.GetValueOrDefault() ? "Deactivate" : "Activate";
            var mModel = new ModalModel()
            {
                Id = holiday.Id,
                Desc = string.Format($"Are you sure you want to {action} Public Holiday [{0}]", holiday.HolidayName)
            };

            return PartialView("_deleteConfirmation", mModel);
        }

        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult ToggleHoliday(long Id)
        {
            using (var _context = context)
            {
                var holiday = new CoreSystem<fl_PublicHoliday>(_context).Get(Id);

                holiday.IsDeleted = holiday.IsActive.GetValueOrDefault() ? true : false;
                holiday.IsActive = holiday.IsActive.GetValueOrDefault() ? false : true;

                new CoreSystem<fl_PublicHoliday>(_context).Update(holiday, Id);

            }

            return RedirectToAction("PublicHoliday");
        }
    }
}