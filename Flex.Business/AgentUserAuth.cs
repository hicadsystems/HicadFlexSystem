using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using Flex.Utility.Security;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flex.Business
{
    public class AgentUserAuth : CoreSystem<fl_agents>
    {
        private DbContext _context;
        public AgentUserAuth(DbContext context)
            : base(context)
        {
            _context = context;
        }

        public AuthResult AgentAuthenticateUser(String userName, string password, Boolean getUsable = true)
        {
            AuthResult res = new AuthResult() { };
            //  var user = FindAll(x => x.agentphone == userName).FirstOrDefault();
            var user2 = new CoreSystem<fl_agents>(_context).FindAll(x=>x.IsDeleted == false);
  
            var user = new CoreSystem<fl_agents>(_context).FindAll(x => x.agentphone == userName && x.password == password && x.IsDeleted == false).FirstOrDefault();
            if (user != null)
            {
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
                    if (user.datemodified <= DateTime.Now)
                    {
                        res.Status = AuthStatus.PasswordExpired;
                        getUsable = false;
                    }

                    if (getUsable)
                    {
                        // update Last LoginDate
                        user.datecreated = DateTime.Now;
                        Update(user, (long)user.Id);
                    }

                }

                if (true)
                {
                    res.Session = new UserSessionSystem(_context).ProvisionSessionFor(user, getUsable);
                }
            }
            else
            {
                res.Description = "Invalid username or password";// "User does not exist";
                res.Status = AuthStatus.DoesNotExist;
            }
            return res;
        }
        public ProcessResult ChangePassword(long userId, string newPassword, string oldPassword)
        {
            try
            {
                var desc = string.Empty;
                //var hPwd = new MD5Password().CreateSecurePassword(oldPassword);
                var user = FindAll(x => x.Id == userId && x.password == oldPassword).FirstOrDefault();
                if (user == null)
                {
                    return new ProcessResult()
                    {
                        Description = "Invalid Password"
                    };
                }
                //var nhPwd = new MD5Password().CreateSecurePassword(newPassword);
                user.password = newPassword;
                user.datemodified = DateTime.Now.AddDays(30);
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

        public bool validateUser(string username, string email)
        {
            try
            {
                var userExists = FindAll(x => (x.agentphone == username) && x.IsDeleted == false).Any();

                return userExists;
            }
            catch (Exception)
            {

                throw;
            }
        }

    }
}
