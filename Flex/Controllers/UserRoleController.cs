using Flex.Business;
using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.Utility;
using Flex.Data.ViewModel;
using Flex.Util;
using Flex.Utility.Security;
using Flex.Utility.Utils;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Mvc;

namespace Flex.Controllers
{
    public class UserRoleController : ContainerController
    {
        public ActionResult Users()
        {
            Logger.Info("Inside Users");

            try
            {
                var users=new UserAuthSystem(context).FindAll(x=>x.IsDeleted==false).Take(100).ToList().Select(x=> new UserAuthViewModel() {
                    Username=x.userid,
                    Branch=x.branch.GetValueOrDefault(),
                    Dept=x.userdept,
                    Email=x.email,
                    Id=x.Id,
                    Mobile=x.mobile,
                    Name=x.Name,
                    Status=(UserStatus)x.status
                }).OrderBy(x=>x.Name).ToList();

                return PartialView("_users",users);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult UserInput()
        {
            try
            {
                ViewBag.Roles = GetRoles();
                return PartialView("_AddUser", new fl_password());
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        
        public ActionResult AddUser(UserBindingModel User)
        {
            try
            {
                if (User.UserName==null)
                {
                    throw new Exception("Invalid Data");
                }
                using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                {
                    var password = string.Empty;
                    try
                    {
                        if (new UserAuthSystem(context).validateUser(User.UserName,User.Email))
                        {
                            throw new Exception(string.Format("User already exists with username {0} or email {1}", User.UserName, User.Email));
                        }
                        var userData = new fl_password();

                        userData.branch = 0;
                        userData.datecreated = DateTime.Today;
                        userData.Name = User.Name;
                        userData.passworddate = DateTime.Today.AddDays(30);
                        userData.status = UserStatus.New;
                        userData.userdept = User.Dept;
                        userData.userid = User.UserName;
                        userData.email = User.Email;
                        userData.mobile = User.Phone;
                        password = WebUtils.UserPwd;
                        userData.userpassword = new MD5Password().CreateSecurePassword(password);
                        userData.IsDeleted = false;
                        new UserAuthSystem(context).Save(userData);

                        var userRole = new UserRole();
                        userRole.RoleId = int.Parse(User.Role);
                        userRole.UserId = userData.Id;

                        new CoreSystem<UserRole>(context).Save(userRole);

                        var pEmail = new PendingEmail();
                        StringBuilder body = new StringBuilder();

                        body.AppendFormat("<p>Dear {0}</p><br/>", userData.Name);
                        body.Append("<p>Please find your user details for Flex Application below</p><br/>");
                        body.AppendFormat("<p>Username : {0}</p><br/>", userData.userid);
                        body.AppendFormat("<p>Password : {0}</p><br/>", password);

                        pEmail.Body = body.ToString();
                        pEmail.From = ConfigUtils.MailFrom;
                        pEmail.IsBodyHtml = true;
                        pEmail.Sender = ConfigUtils.Sender;
                        pEmail.Subject = "Password";
                        pEmail.To = userData.email;
                        pEmail.DueDate = DateTime.Now;
                        new CoreSystem<PendingEmail>(context).Save(pEmail);

                        transaction.Commit();
                    }
                    catch (Exception)
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
                return RedirectToAction("Users");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult EditUser(long Id)
        {
            try
            {
                var user = new UserAuthSystem(context).Get(Id);
                var roleId = 0;
                var userStatus = 0;
                if (user != null)
                {
                    if (user.UserRoles != null && user.UserRoles.Any())
                    {
                        int.TryParse(user.UserRoles.FirstOrDefault().RoleId.ToString(), out roleId);
                    }
                    ViewBag.Roles = GetRoles(roleId);

                    int.TryParse(((int)user.status).ToString(), out userStatus);
                    ViewBag.UserStatus = GetUserStatus(userStatus);
                }
                return PartialView("_AddUser", user);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult UpdateUser(UserBindingModel model)
        {
            try
            {
                if (model.UserName == null)
                {
                    throw new Exception("Invalid Data");
                }
                using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                {
                    var password = string.Empty;
                    try
                    {
                        var user = new UserAuthSystem(context).Get(model.Id);
                        if (user==null)
                        {
                            throw new Exception(string.Format("User already exists with username {0} or email {1}", model.UserName, model.Email));
                        }
                        var userData = new fl_password();

                        user.Name = model.Name;
                        user.status = (UserStatus)Enum.Parse(typeof(UserStatus),model.Status);
                        user.userdept = model.Dept;
                        user.userid = model.UserName;
                        user.email = model.Email;

                        new UserAuthSystem(context).Update(user,user.Id);

                        var userRole = new CoreSystem<UserRole>(context).FindAll(x=>x.UserId==user.Id).FirstOrDefault();
                        if (userRole== null)
                        {
                            userRole = new UserRole()
                            {
                                RoleId = int.Parse(model.Role),
                                UserId = user.Id
                            };
                            new CoreSystem<UserRole>(context).Save(userRole);
                        }
                        else
                        {
                            userRole.RoleId = int.Parse(model.Role);
                            new CoreSystem<UserRole>(context).Update(userRole,userRole.Id);
                        }

                        transaction.Commit();
                    }
                    catch (Exception)
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
                return RedirectToAction("Users");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }


        public ActionResult ConfirmDeleteUser(long Id)
        {
            try
            {
                var user = new UserAuthSystem(context).Get(Id);
                var modal = new ModalModel();
                if (user != null)
                {
                    modal.Desc = string.Format("Do you want to delete user [{0}]", user.userid);
                    modal.Id = user.Id;
                }
                return PartialView("_deleteConfirmation", modal);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult DeleteUser(long Id)
        {
            try
            {
                using(var _context= context)
                {
                    var user = new UserAuthSystem(_context).Get(Id);
                    if (user != null)
                    {
                        user.Deleteddate = DateTime.Now;
                        user.Deletedby = WebSecurity.CurrentUser(Request);
                        user.IsDeleted = true;

                        new UserAuthSystem(_context).Update(user, user.Id);
                    }
                }
                
                return RedirectToAction("Users");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }


        public ActionResult Roles()
        {
            try
            {
                var roles = new CoreSystem<Role>(context).GetAll().ToList();

                return PartialView("_roles", roles);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult AddEditRole(int Role)
        {
            try
            {
                var lRoles = new RoleLinks();
                var menus = new List<Menu>();
                if (Role > 0)
                {
                    var r = new CoreSystem<Role>(context).Get(Role);
                    var linkRoles = new CoreSystem<LinkRole>(context).FindAll(x => x.RoleID == Role);
                    lRoles.Desc = r.Description;
                    lRoles.Name = r.Name;
                    foreach (var lr in linkRoles.Where(x=>x.Type==LinkType.Portlet))
                    {
                        var lRole = new Menu();
                        lRole.Portlet = (int)lr.LinkId;
                        lRole.Tabs = linkRoles.Where(x => x.Parent == lr.LinkId).Select(x => x.LinkId).Cast<int>().ToList();
                        menus.Add(lRole);
                    }
                }
                lRoles.Menu = menus;
                lRoles.RoleId = Role;
                var portlets = new PortletSystem(context).GetAll().ToList();

                ViewBag.PortletTabs = portlets;

                return PartialView("_addRole", lRoles);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred. Details [{0}]", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SaveUpdateRole(RoleBindingModel role)
        {
            try
            {
                using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                {
                    try
                    {
                        var rl = new Role();
                        rl.Description = role.Desc;
                        rl.Name = role.Name;
                        if (role.Id > 0)
                        {
                            rl.Id = role.Id;
                            //var delRol = context.LinkRoles.SqlQuery(string.Format("delete from LinkRole where RoleId={0}", rl.Id)).ToList();
                            context.Database.ExecuteSqlCommand("delete from LinkRole where RoleId =@roleId", new SqlParameter("@roleId", rl.Id));
                            new CoreSystem<Role>(context).Update(rl, rl.Id);
                        }else
                        {
                            new CoreSystem<Role>(context).Save(rl);
                        }
                        foreach (var link in role.links)
                        {

                            var plinkrole = new LinkRole();

                            string[] splitter = { "|" };
                            var menu = link.Split(splitter, StringSplitOptions.RemoveEmptyEntries);

                            plinkrole.LinkId = int.Parse(menu[0]);
                            plinkrole.Parent = 0;
                            plinkrole.RoleID = rl.Id;
                            plinkrole.Type = LinkType.Portlet;

                            new CoreSystem<LinkRole>(context).Save(plinkrole);

                            string[] splitter2 = { ";" };
                            var tabs = menu[1].Split(splitter2, StringSplitOptions.RemoveEmptyEntries);

                            foreach (var item in tabs)
                            {
                                var tlinkrole = new LinkRole();

                                tlinkrole.LinkId = int.Parse(item);
                                tlinkrole.Parent = int.Parse(menu[0]);
                                tlinkrole.RoleID = rl.Id;
                                tlinkrole.Type = LinkType.Tab;

                                new CoreSystem<LinkRole>(context).Save(tlinkrole);
                            }
                        }

                        transaction.Commit();
                    }
                    catch (Exception)
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
                return RedirectToAction("Roles");
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }
        protected SelectList GetRoles(int roleId=0)
        {
            var roles = new CoreSystem<Role>(context).GetAll();
            if (roleId > 0)
            {
                return new SelectList(roles, "ID", "Name",roleId);
            }
            return new SelectList(roles, "ID", "Name");
        }

        public ActionResult ResetPassword(long Id)
        {
            try
            {
                var User = new UserAuthSystem(context).Get(Id);
                return PartialView("_resetPwd", User);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        [HttpPost]
        public ActionResult PasswordReset(string Id)
        {
            try
            {
                long id;
                Int64.TryParse(Id, out id);
                var user = new UserAuthSystem(context).Get(id);

                var nPwd = WebUtils.UserPwd;
                var pwd = new MD5Password().CreateSecurePassword(nPwd);

                user.userpassword = pwd;
                user.status = UserStatus.New;
                user.modifydate = DateTime.Now;
                user.passworddate = DateTime.Now;
                using (var transaction = context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                {
                    try
                    {
                        new UserAuthSystem(context).Update(user, user.Id);

                        var pemail = new PendingEmail();
                        StringBuilder body = new StringBuilder();
                        body.AppendFormat("<p>Hello {0}</p><br/>", user.Name);
                        body.AppendFormat("Your Password has been reset to {0}", nPwd);
                        body.Append("Thanks");
                        pemail.Body = body.ToString();
                        pemail.DueDate = DateTime.Now;
                        pemail.From = "NLPC";
                        pemail.IsBodyHtml = true;
                        pemail.Subject = "Password Reset";
                        pemail.To = user.email;
                        var err = string.Empty;
                        new CoreSystem<PendingEmail>(context).Save(pemail);
                        //new NotificationSystem().SendMail(pemail, out err);

                        transaction.Commit();
                    }
                    catch (Exception)
                    {
                        transaction.Rollback();
                        throw;
                    }
                }

                //return new HttpStatusCodeResult(System.Net.HttpStatusCode.OK, string.Format("Password Reset Successful for {0} with password {1}", user.userid, nPwd));

                return new JsonResult()
                {
                    Data = string.Format("Password Reset Successful for {0} with password {1}", user.userid, nPwd)
                };
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

        public ActionResult SearchUsers(string searchterm = "")
        {
            var users = new UserAuthSystem(context).FindAll(x => x.IsDeleted == false).Take(100).ToList().Select(x => new UserAuthViewModel()
            {
                Username = x.userid,
                Branch = x.branch.GetValueOrDefault(),
                Dept = x.userdept,
                Email = x.email,
                Id = x.Id,
                Mobile = x.mobile,
                Name = x.Name,
                Status = (UserStatus)x.status
            }).OrderBy(x => x.Name).ToList();

            try
            {
                if (!string.IsNullOrEmpty(searchterm))
                {
                    users = users.Where(x => x.Name.ToLower().Contains(searchterm.ToLower())).ToList();
                }

                return PartialView("_tbUsers", users);
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                return new HttpStatusCodeResult(System.Net.HttpStatusCode.BadRequest, ex.Message);
            }
        }

    }
}