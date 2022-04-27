using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using Flex.Utility.Security;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Linq;
using System.Text;

namespace Flex.Business
{
    public class CustomerAuthSystem : CoreSystem<CustomerUser>
    {
        private DbContext _context;
        public CustomerAuthSystem(DbContext context)
            : base(context)
        {
            _context = context;
        }

        public AuthResult AuthenticateUser(String userName, string password, Boolean getUsable = true)
        {
            AuthResult res = new AuthResult() { };
            var user = FindAll(x => x.username == userName).FirstOrDefault();
            if (user != null)
            {
                if (new MD5Password().CreateSecurePassword(password) == user.password)
                {
                    // if (user.LastLoginDate <= SqlDateTime.MinValue.Value || user.Status == UserStatus.New)
                    //bool getUserInfo = false;
                    switch ((UserStatus)user.status)
                    {
                        case UserStatus.New:
                            res.Status = AuthStatus.FirstTime;
                            res.Description = "First time logon";
                            getUsable = false;
                            break;
                        case UserStatus.Inactive:
                            res.Status = AuthStatus.Disabled;
                            res.Description = "User inactive";
                            break;
                        case UserStatus.Exited:
                            res.Status = AuthStatus.DoesNotExist;
                            res.Description = "User exited";
                            break;
                        case UserStatus.Dormant:
                            res.Status = AuthStatus.Dormant;
                            res.Description = "User dormant";
                            break;
                        case UserStatus.AwaitingApproval:
                            res.Status = AuthStatus.AwaitingApproval;
                            res.Description = "Awaiting approval";
                            break;

                        //case UserStatus.New:
                        case UserStatus.Active:
                            res.Status = AuthStatus.Normal;
                            res.Description = "Successful";
                            //getUsable = true;
                            break;
                    }
                    if (res.Status == AuthStatus.Normal)
                    {
                        if (user.passworddate <= DateTime.Now)
                        {
                            res.Status = AuthStatus.PasswordExpired;
                            getUsable = false;
                        }

                        if (getUsable)
                        {
                            // update Last LoginDate
                            user.lastLoginDate = DateTime.Now;
                            Update(user,user.Id);
                        }

                    }

                    if (true)
                    {
                        var userType=user.GetType();
                        res.Session = new UserSessionSystem(_context).ProvisionSessionFor(user, getUsable);
                    }

                }
                else
                {
                    res.Description = "Invalid username or password";// "Invalid Password";
                    res.Status = AuthStatus.Failed;
                }
            }
            else
            {
                res.Description = "Invalid username or password";// "User does not exist";
                res.Status = AuthStatus.DoesNotExist;
            }
            return res;
        }

        public PagedResult<CustomerViewModel> SearchUser(string searchterm=null, int pagesize=0, int page=0)
        {
            Logger.Info("Inside Search Policy No");
            Logger.InfoFormat("Using Context: {0}", _context.Database.Connection.ConnectionString);
            try
            {
                var cust = FindAll(x => x.IsDeleted == false);
                if (!string.IsNullOrEmpty(searchterm))
                {
                    cust = cust.Where(x => x.Name.ToLower().Contains(searchterm.ToLower())
                        || x.phone.Contains(searchterm) || x.email.ToLower().Contains(searchterm.ToLower()));
                }
                int xPagesize = pagesize > 0 ? pagesize : 10; ;
                int xPage = page > 0 ? page : 1;
                var TotalCount = cust.Count();
                var skip = (xPage - 1) * xPagesize;
                var PagedCust = new PagedResult<CustomerViewModel>();
                PagedCust.LongRowCount = TotalCount;
                PagedCust.Items = cust.OrderBy(x => x.Id).Skip(skip).Take(xPagesize)
                    .Select(x => new CustomerViewModel() {
                        Email=x.email,
                        Id=x.Id,
                        Name=x.Name,
                        Phone=x.phone,
                        Policies=x.CustomerPolicies.Count(),
                        Username=x.username

                    }).ToList();
                PagedCust.PageSize = xPagesize;
                PagedCust.PageCount = TotalCount > 0 ? (int)Math.Ceiling(Convert.ToDouble(Convert.ToDouble(TotalCount) / Convert.ToDouble(xPagesize))) : 1;
                return PagedCust;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error occurred. Detail {0}", ex.ToString());
                throw;
            }

        }

        public ProcessResult ChangePassword(long userId, string newPassword, string oldPassword)
        {
            try
            {
                var desc = string.Empty;
                var hPwd = new MD5Password().CreateSecurePassword(oldPassword);
                var user = FindAll(x => x.Id == userId && x.password == hPwd).FirstOrDefault();
                if (user == null)
                {
                    return new ProcessResult()
                    {
                        Description = "Invalid Password"
                    };
                }
                var nhPwd = new MD5Password().CreateSecurePassword(newPassword);
                user.password = nhPwd;
                user.passworddate = DateTime.Now.AddDays(30);
                if (user.status == (int)UserStatus.New)
                {
                    user.status = (int)UserStatus.Active;
                }
                Update(user, user.Id);

                return new ProcessResult()
                {
                    AffectedItems = 1,
                    Description = "Password Changed Successfully"
                };
            }
            catch (Exception)
            {

                throw;
            }
        }

    }
}
