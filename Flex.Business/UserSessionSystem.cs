using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Utility.Security;
using Flex.Utility.Utils;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Entity;
using System.Data.SqlTypes;
using System.Linq;
using System.Text;
using Type=System.Type;
namespace Flex.Business
{
    public class UserSessionSystem : CoreSystem<UserSession>
    {
        private DbContext _context;
        public UserSessionSystem(DbContext context)
            : base(context)
        {
            _context = context;
        }

        public UserSession GetActiveUserSession(long userId, System.Type userType)
        {
            UserSession usession= new UserSession();
            if (userType==typeof(CustomerUser))
            {
                usession = FindAll(x => x.SessionStatus == UserSessionStatus.Active && x.ExpiryDate > DateTime.Now && x.CustomerUserID == userId).FirstOrDefault();
            }
            else
            {
                usession = FindAll(x => x.SessionStatus == UserSessionStatus.Active && x.ExpiryDate > DateTime.Now && x.UserId == userId).FirstOrDefault();

            }

            return usession;
        }

        static readonly bool AllowMultiSessionsPerUser = Convert.ToBoolean(ConfigurationManager.AppSettings["AllowMultiSessionsPerUser"] ?? "false");
        static readonly bool AllowActiveSessionReuse = Convert.ToBoolean(ConfigurationManager.AppSettings["AllowActiveSessionReuse"] ?? "false");
        public UserSession ProvisionSessionFor(CustomerUser user, bool getUsable)
        {
            bool allowMultiSessionsPerUser = AllowMultiSessionsPerUser;
            bool reuseActiveSessions = AllowActiveSessionReuse;

            UserSession uSession = null;
            uSession = GetActiveUserSession(user.Id, typeof(CustomerUser));
            if (uSession == null || !reuseActiveSessions)
            {
                string token = new MD5Password().CreateSecurePassword(String.Concat(user.Id.ToString(), user.username, DateTime.Now.ToString("o")));
                uSession = new UserSession
                {
                    LastAccessed = DateTime.Now,
                    CustomerUser = user,
                    ExpiryDate = DateTime.Now.AddMinutes(ConfigUtils.SessionTimeout),
                    SessionStatus = UserSessionStatus.Active, 
                    CustomerUserID=user.Id,
                    Token=token,
                    IsDeleted=false,
                    DateCreated=DateTime.Now
                };

                if (!getUsable)
                {
                    uSession.ExpiryDate = DateTime.Now.AddMinutes(5);
                    uSession.SessionStatus = UserSessionStatus.Temporal;
                }


                if (true || getUsable)
                {
                    if (getUsable)
                    {
                        //capture first login here if need be
                        if (user.firstLoginDate <= SqlDateTime.MinValue.Value)
                        {
                            user.firstLoginDate = DateTime.Now;
                            new CustomerAuthSystem(_context).Update(user,user.Id);
                        }
                    }
                    Save(uSession);
                }
            }
            return uSession;
        }

        public UserSession ProvisionSessionFor(fl_password user, bool getUsable)
        {
            bool allowMultiSessionsPerUser = AllowMultiSessionsPerUser;
            bool reuseActiveSessions = AllowActiveSessionReuse;

            UserSession uSession = null;
            uSession = GetActiveUserSession((long)user.Id, typeof(fl_password));
            if (uSession == null || !reuseActiveSessions)
            {
                string token = new MD5Password().CreateSecurePassword(String.Concat(user.Id.ToString(), user.userid, DateTime.Now.ToString("o")));
                uSession = new UserSession
                {
                    LastAccessed = DateTime.Now,
                    fl_password = user,
                    ExpiryDate = DateTime.Now.AddMinutes(ConfigUtils.SessionTimeout),
                    SessionStatus = UserSessionStatus.Active,
                    UserId = user.Id,
                    Token = token,
                    IsDeleted = false,
                    DateCreated = DateTime.Now
                };

                if (!getUsable)
                {
                    uSession.ExpiryDate = DateTime.Now.AddMinutes(5);
                    uSession.SessionStatus = UserSessionStatus.Temporal;
                }


                if (true || getUsable)
                {
                    Save(uSession);
                }
            }
            return uSession;
        }

        public UserSession GetActiveSession(string authToken)
        {
            UserSession usession = null;
            using (var transaction = _context.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
            {
                try
                {
                    var query = _context.Set<UserSession>().Include(y=>y.fl_password).Include(j=> j.fl_password.UserRoles).Where(x => x.IsDeleted == false && ( x.SessionStatus == UserSessionStatus.Active
                      || x.SessionStatus == UserSessionStatus.Temporal) && x.Token == authToken && x.ExpiryDate > DateTime.Now);

                    usession = query.FirstOrDefault();

                    if (usession !=null)
                    {
                        usession.AccessCount++;
                        usession.LastAccessed = DateTime.Now;
                        usession.ExpiryDate = DateTime.Now.AddMinutes(ConfigUtils.SessionTimeout);
                        Update(usession, usession.Id);
                    }

                    transaction.Commit();
                }
                catch (Exception ex)
                {
                    Logger.InfoFormat("Error occurred. Details {0}", ex.ToString());
                    transaction.Rollback();
                }

            }
            return usession;

        }

        //public UserSession GetActiveSession(string authtoken)
        //{
        //    ISession session = GetSession();
        //    UserSession uSession = null;
        //    using (ITransaction trans = session.BeginTransaction(IsolationLevel.ReadCommitted))
        //    {
        //        var query = GetSession().QueryOver<UserSession>()
        //            .Where(
        //            x => x.IsDeleted == false
        //                && (x.SessionStatus == UserSessionStatus.Active || x.SessionStatus == UserSessionStatus.Temporal)
        //                && x.Token == authtoken
        //                && x.ExpiryDate > DateTime.Now);
        //        uSession = query.Fetch(x => x.CorporateUser).Eager.SingleOrDefault();
        //        var sessionAudited = false;
        //        if (uSession != null && DateTime.Now.Subtract(uSession.LastAccessed.Value).TotalMinutes >= 1)
        //        {
        //            uSession.ExtendedInfo.PasswordExpiry = uSession.CorporateUser.PasswordAge.Value;
        //            uSession.AccessCount++;
        //            uSession.LastAccessed = DateTime.Now;
        //            uSession.ExpiryDate = DateTime.Now.AddMinutes(CoreUtils.SessionTimeout);
        //            session.Update(uSession);
        //            sessionAudited = true;
        //        }
        //        if (uSession != null && uSession.SessionStatus == UserSessionStatus.Temporal)
        //        {
        //            if (!sessionAudited)
        //            {
        //                uSession.AccessCount++;
        //                uSession.LastAccessed = DateTime.Now;
        //            }
        //            if (uSession.AccessCount >= 5)
        //            {
        //                uSession.ExpiryDate = DateTime.Now;
        //                uSession.SessionStatus = UserSessionStatus.EndedBySecuritySystem;
        //            }
        //            session.Update(uSession);
        //        }
        //        trans.Commit();
        //    }
        //    return uSession;
        //}

    }
}
