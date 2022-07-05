using Flex.Data.Enum;
using Flex.Data.Model;
using Flex.Data.ViewModel;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;

namespace Flex.Business
{
    public class SignUpSystem : CoreSystem<PersonalDetailsStaging>
    {
        private DbContext _context;
        public SignUpSystem(DbContext context)
            : base(context)
        {
            _context = context;
        }
        public void SaveSignUp(PesonalInfoBindingModel personalInfo)
        {
            try
            {

                var pinfo = new PersonalDetailsStaging();
                var poltype = new CoreSystem<fl_poltype>(_context).Get(personalInfo.PolicyType);
                pinfo.RegNo = GenerateregNo(poltype.poltype);
                pinfo.ApprovalStatus = (int)ApprovalStatus.Pending;
                pinfo.ContribAmount = personalInfo.Amount;
                pinfo.ContribFreq = personalInfo.Frequency;
                pinfo.DateCreated = DateTime.Today;
                pinfo.dob = personalInfo.Dob;
                pinfo.Duration = personalInfo.Duration;
                pinfo.Email = personalInfo.Email;
                pinfo.IsSynched = false;
                pinfo.Occupation = personalInfo.Occupation;
                pinfo.OffAddress = personalInfo.OfficeAddress;
                pinfo.OtherNames = personalInfo.Othernames;
                pinfo.Phone = personalInfo.Phone;
                pinfo.PolicyType = (int)personalInfo.PolicyType;
                pinfo.PosAddress = personalInfo.PostalAddress;
                pinfo.ResAddress = personalInfo.ResAddress;
                pinfo.Surname = personalInfo.Surname;
                pinfo.Type = (int)Flex.Data.Enum.Type.New;
                pinfo.Location = personalInfo.Locationid;
                pinfo.IdentityNumber = personalInfo.IdentityNumber;
                pinfo.IdentityType = personalInfo.IdentityType;
                pinfo.PictureFile = personalInfo.PictureFile;
                pinfo.signature = personalInfo.signature;
                pinfo.agentcode = personalInfo.AgentCode;
                pinfo.TermsAndConditions = personalInfo.TermsAndConditions;

                var nextkinBen = new List<NextofKinBeneficiaryBindingModel>();

                nextkinBen.Add(personalInfo.NextofKin);
                nextkinBen.AddRange(personalInfo.Beneficiary);

                var nkinBen = nextkinBen.Select(x => new NextofKin_BeneficiaryStaging()
                {
                    Address = x.Address,
                    ApprovalStatus = (int)ApprovalStatus.Pending,
                    Category = (int)x.Category,
                    Dob = Convert.ToDateTime(x.Dob),
                    Email = x.Email,
                    IsSynched = false,
                    Name = x.Name,
                    //PersonalDetailsStagingId = pinfo,
                    PersonalDetailsStagingId = pinfo.Id,
                    Phone = x.Phone,
                    Proportion = x.Proportion,
                    RegNo = pinfo.RegNo,
                    RelationShip = x.Relationship,
                    Type = (int)x.Type,
                });
                /*foreach (var nkb in nkinBen)
                {
                    if (nkb.Dob.ToString().Contains("01/01/0001"))
                    {
                        nkb.Dob = null;
                    }
                }*/
                pinfo.NextofKin_BeneficiaryStaging = nkinBen.ToList();
               
                
                Save(pinfo);
            }
            catch (Exception ex)
            {

                throw;
            }
        }

        private string GenerateregNo(string PolicyType)
        {
            try
            {
                //_context = new nlpcdataEntities();
                var LastSn = UtilitySystem.GetNextSerialNumber(_context,SerialNoCountKey.QT);

                var Regno = string.Format("{0}{1}{2}", PolicyType, DateTime.Today.ToString("yyyyMMdd"), LastSn.ToString().PadLeft(3, '0'));

                return Regno;
            }
            catch (Exception)
            {

                throw;
            }
        }

        public IList<PersonalDetailsStaging> GetUnApprovedSignUp(DateTime datefrom, DateTime dateTo)
        {
            try
            {
                var unapproved=FindAll(x => x.DateCreated >= datefrom && x.DateCreated <= dateTo && x.ApprovalStatus == (int)ApprovalStatus.Pending);

                return unapproved.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred: {0}", ex.ToString());
                throw;
            }
        }

        public IList<PersonalDetailsStaging> GetApprovedSignUp(DateTime datefrom, DateTime dateTo)
        {
            try
            {
                var unapproved = FindAll(x => x.DateCreated >= datefrom && x.DateCreated <= dateTo &&x.ApprovalStatus == (int)ApprovalStatus.Approved);

                return unapproved.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred: {0}", ex.ToString());
                throw;
            }
        }

        public IList<PersonalDetailsStaging> GetDisApprovedSignUp(DateTime datefrom, DateTime dateTo)
        {
            try
            {
                var unapproved = FindAll(x => x.DateCreated >= datefrom && x.DateCreated <= dateTo && x.ApprovalStatus == (int)ApprovalStatus.Disapproved);

                return unapproved.ToList();
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("Error Occurred: {0}", ex.ToString());
                throw;
            }
        }

        public PersonalDetailsStaging RetriveSignUpDataByQuoteNo(string quoteNo)
        {
            try
            {
                var tempdata = FindAll(x => x.RegNo == quoteNo).FirstOrDefault();
                
                return tempdata;
            }
            catch (Exception ex)
            {
                Logger.InfoFormat("An Error Occurred. [Details: {0}]", ex.ToString());
                throw;
            }
        }

        public void ApproveSignUp(string Regno, long policyId)
        {
            try
            {
                var signupData = FindAll(x => x.RegNo == Regno).FirstOrDefault();
                if (signupData == null)
                {
                    throw new Exception(string.Format("No Signup Record Found for {0}", Regno));
                }
                signupData.ApprovalStatus = (int)ApprovalStatus.Approved;
                foreach (var nb in signupData.NextofKin_BeneficiaryStaging)
                {
                    nb.PolicyId = policyId;
                }

                Update(signupData, signupData.Id);

            }
            catch (Exception ex)
            {
                Logger.InfoFormat("An Error occurred. Details [{0},{1}]", ex.ToString(), ex.StackTrace);
                throw;
            }
        } 
        public void DisapproveSignUp(string Regno, long policyId)
        {
            try
            {
                var signupData = FindAll(x => x.RegNo == Regno).FirstOrDefault();
                if (signupData == null)
                {
                    throw new Exception(string.Format("No Signup Record Found for {0}", Regno));
                }
                signupData.ApprovalStatus = (int)ApprovalStatus.Disapproved;
                foreach (var nb in signupData.NextofKin_BeneficiaryStaging)
                {
                    nb.PolicyId = policyId;
                }

                Update(signupData, signupData.Id);

            }
            catch (Exception ex)
            {
                Logger.InfoFormat("An Error occurred. Details [{0},{1}]", ex.ToString(), ex.StackTrace);
                throw;
            }
        }
    }
}
