using Flex.Data.Enum;
using Flex.Data.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Flex.Data.ViewModel
{
    public class PesonalInfoBindingModel
    {
        public long CustomerId { get; set; }
        public string RegNo { get; set; }
        public string Surname { get; set; }

        public string Othernames { get; set; }

        public string ResAddress { get; set; }

        public string OfficeAddress { get; set; }

        public string PostalAddress { get; set; }

        public string Email { get; set; }

        public string Phone { get; set; }

        public DateTime? Dob { get; set; }

        public string Occupation { get; set; }

        public Decimal Amount { get; set; }

        public string Frequency{ get; set; }

        public DateTime? CommencementDate { get; set; }

        public int Duration { get; set; }

        public Flex.Data.Enum.Type Type { get; set; }

        public int PolicyType { get; set; }

        public int Location { get; set; }

        public string AgentCode { get; set; }
        public byte[] PictureFile { get; set; }
        //public string PictureFile { get; set; }
        public string GroupCode { get; set; }
        public string Religion { get; set; }
        public string Gender { get; set; }
        public NextofKinBeneficiaryBindingModel NextofKin{ get; set; }
        public List<NextofKinBeneficiaryBindingModel>  Beneficiary { get; set; }
        public NextofKinBeneficiaryBindingModel  Benefitiary { get; set; }
    }

    public class NextofKinBeneficiaryBindingModel
    {
        public long Id { get; set; }
        public string RegNo { get; set; }
        public string Name { get; set; }

        public string Address { get; set; }

        public string Email { get; set; }

        public string Phone { get; set; }

        //public DateTime? Dob { get; set; }
        public string Dob { get; set; }

        public string Relationship { get; set; }

        public Nullable<Decimal> Proportion { get; set; }

        public Category Category { get; set; }

        public Flex.Data.Enum.Type Type { get; set; }

        public long? PolicyId { get; set; }
        //public string RegNo { get; set; }

    }

    public class SignUpBindingModel
    {
        public PesonalInfoBindingModel PersonalInfo { get; set; }

    }

    public class AccountBindingModel
    {
        public string AccountNumber { get; set; }

        public string Description { get; set; }

        public string DescAccount 
        { 
            get 
            {
                return string.Format("{0}.../{1}", Description, AccountNumber);
            } 
        }
    }

    public class PolBindingModel
    {
        public string PolicyNo { get; set; }

        public string Surname { get; set; }

        public string OtherName { get; set; }

        public string PolicyName
        {
            get
            {
                return string.Format("{0} {1}.../{2}", Surname, OtherName,PolicyNo);
            }
        }
    }


    public class ModalModel
    {
        public long Id { get; set; }

        public string Desc { get; set; }
    }

    public class UserBindingModel
    {
        public long Id { get; set; }
        public string UserName { get; set; }

        public string Name { get; set; }

        public string Email { get; set; }

        public string Phone { get; set; }

        public string Dept { get; set; }

        public string Role { get; set; }

        public string Status { get; set; }
    }

    public class Menu
    {
        public int Portlet { get; set; }

        public List<int> Tabs { get; set; }
    }

    public class RoleLinks
    {
        public int RoleId { get; set; }

        public string Name { get; set; }

        public string Desc { get; set; }

        public List<Menu> Menu { get; set; }
    }

    public class RoleBindingModel
    {
        public string Name { get; set; }

        public string Desc { get; set; }

        public int Id { get; set; }

        public List<string> links { get; set; }
    }

    public class ChangePasswordBindingModel
    {
        public string OldPassword { get; set; }

        public string NewPassword { get; set; }
    }

    public class PolicyBindingModel
    {
        public int PolicyType { get; set; }

        public int Location { get; set; }

        public decimal Amount { get; set; }

        public int Frequency { get; set; }

        public int Duration { get; set; }
    }

    public class Production
    {
        public string PolicyNo { get; set; }

        public string ReceiptNo { get; set; }

        public DateTime Date { get; set; }

        public Decimal Amount { get; set; }

        public string Name { get; set; }

        public string AgentName { get; set; }

        public decimal PremiumLoan { get; set; }

        public decimal PolicyLoan { get; set; }

        public decimal Others { get; set; }

        public decimal AcceptanceDate { get; set; }
        public decimal Premium { get; set; }
    }

    public class Rate
    {
        public string Period { get; set; }

        public int PolType { get; set; }

        public int Group { get; set; }
        public decimal IntrBound { get; set; }
        public decimal CommBound { get; set; }
        public decimal Interest { get; set; }
        public string Interest2 { get; set; }
        public string Interest3 { get; set; }
        public string MktCommrate { get; set; }
        public string MktCommrate2 { get; set; }
        public string MktCommrate3 { get; set; }
        public decimal IntrBound2 { get; set; }
        public decimal IntrBound3 { get; set; }
        public decimal Commrate { get; set; }
        public string Commrate2 { get; set; }
        public string Commrate3 { get; set; }
        public decimal CommBound2 { get; set; }
        public decimal CommBound3 { get; set; }
        public IList<RateRules> rateRules { get; set; }
    }

    public class RateRules
    {
        public decimal intr { get; set; }

        public decimal Commission { get; set; }

        public decimal MktCommRate { get; set; }

        public decimal CommUpperLimit { get; set; }

        public decimal IntrUpperLimit { get; set; }
    }
    public class Maturity
    {
        public string PolicyNo { get; set; }
        public string Title { get; set; }
        public string Name { get; set; }
        public string AcceptDate { get; set; }
        public string ExitDate { get; set; }
        public string AgentCode { get; set; }
        public string AgentName { get; set; }
        public string Duedate { get; set; }
        public decimal Amount { get; set; }
    }
    public class Gratuity
    {
        public string title { get; set; }
        public string surname { get; set; }
        public string othername { get; set; }
        public string location { get; set; }
        public string policyno { get; set; }
        public string receiptno { get; set; }
        public DateTime trandate { get; set; }
        public string pcn { get; set; }
        public string grpcode { get; set; }
        public string gir { get; set; }
        public string period { get; set; }
        public string doctype { get; set; }
        public string poltype { get; set; }
        public DateTime orig_date { get; set; }
        public decimal ps { get; set; }
        public decimal er { get; set; }
        public decimal ee { get; set; }
        public decimal cc { get; set; }
        public decimal av { get; set; }
        public decimal psc { get; set; }
        public decimal psintr { get; set; }
        public decimal erintr { get; set; }

        public decimal eeintr { get; set; }
        public decimal ccintr { get; set; }
        public decimal avintr { get; set; }
        public decimal pscintr { get; set; }


        public decimal psamount { get; set; }
        public decimal psopen { get; set; }
        public decimal pscur_intr { get; set; }
        public decimal pscumul_intr { get; set; }
        public decimal eramount { get; set; }
        public decimal eropen { get; set; }
        public decimal ercur_intr { get; set; }
        public decimal ercumul_intr { get; set; }
        public decimal eeamount { get; set; }

        public decimal eeopen { get; set; }
        public decimal eecur_intr { get; set; }
        public decimal eecumul_intr { get; set; }
        public decimal avamount { get; set; }
        public decimal avopen { get; set; }
        public decimal avcur_intr { get; set; }
        public decimal avcumul_intr { get; set; }
        public decimal ccamount { get; set; }
        public decimal ccopen { get; set; }
        public decimal cccur_intr { get; set; }
        public decimal cccumul_intr { get; set; }
        public decimal pscamount { get; set; }
        public decimal pscopen { get; set; }
        public decimal psccur_intr { get; set; }
        public decimal psccumul_intr { get; set; }
        public decimal loanamt { get; set; }
        public string grpname { get; set; }
        public string email { get; set; }
    }
}