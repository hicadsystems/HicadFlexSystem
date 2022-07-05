using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using Flex.Utility.Security;
using Flex.Utility.Utils;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;

namespace Flex.Business
{
    public class UserAuthSystem : CoreSystem<fl_password>
    {
        private DbContext _context;
        public UserAuthSystem(DbContext context)
            : base(context)
        {
            _context = context;
        }

        public AuthResult AuthenticateUser(String userName, string password, Boolean getUsable = true)
        {
            AuthResult res = new AuthResult() { };
            var user = FindAll(x => x.userid == userName && x.IsDeleted==false).FirstOrDefault();
            if (user != null)
            {
                if (new MD5Password().CreateSecurePassword(password) == user.userpassword)
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
                            user.lastlogindate = DateTime.Now;
                            Update(user, (long)user.Id);
                        }

                    }

                    if (true)
                    {
                        var userType = user.GetType();
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
       


        public ProcessResult ChangePassword(long userId,string newPassword, string oldPassword)
        {
            try
            {
                var desc = string.Empty;
                var hPwd = new MD5Password().CreateSecurePassword(oldPassword);
                var user = FindAll(x => x.Id == userId && x.userpassword == hPwd).FirstOrDefault();
                if (user ==null)
                {
                    return new ProcessResult()
                    {
                        Description = "Invalid Password"
                    };
                }
                var nhPwd = new MD5Password().CreateSecurePassword(newPassword);
                user.userpassword = nhPwd;
                user.passworddate = DateTime.Now.AddDays(30);
                if (user.status==(int)UserStatus.New)
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

        public bool validateUser(string username, string email)
        {
            try
            {
                var userExists = FindAll(x => (x.userid == username || x.email == email) && x.IsDeleted==false).Any();

                return userExists;
            }
            catch (Exception)
            {

                throw;
            }
        }
    }
}
