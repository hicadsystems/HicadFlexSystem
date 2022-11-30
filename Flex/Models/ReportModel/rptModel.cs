using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Flex.Models.ReportModel
{
    public class rptModel
    {
    }

    public class rptLocation
    {
        public string Code { get; set; }

        public string Description { get; set; }

        public string State { get; set; }
    }
    public class rptAgent
    {
        public string AgentCode { get; set; }

        public string AgentName { get; set; }

        //public Data.Enum.AgentType? AgentType { get; set; }
        public string AgentLocation { get; set; }
        public string Phone { get; set; }
    } 
    

    public class rptPolType
    {
        public string PolicyType { get; set; }
        public string Code { get; set; }
        public string Description { get; set; }
        public string IncomeAcct { get; set; }

    }
    public class rptPolicyType
    {
        public string PolicyType { get; set; }
        public string Code { get; set; }
        public string Description { get; set; }
        public string IncomeAcct { get; set; }

    }
    public class rptLifeRate
    {
        public string PolicyType { get; set; }
        public int Group { get; set; }
        public string GroupDesc { get; set; }
        public string Period { get; set; }

    }

    public class rptApprovedProp
    {
        public string QuoteNo { get; set; }

        public string Surname { get; set; }

        public string Othernames { get; set; }

        public string Address { get; set; }

        public DateTime DOB { get; set; }

        public string NOK { get; set; }

        public string Location { get; set; }

        public string PolicyNo { get; set; }

        public string Sex { get; set; }
    }

    public class rptMembers
    {
        public string PolicyNo { get; set; }

        public string Title { get; set; }

        public string Name { get; set; }

        public string AcceptDate { get; set; }

        public string ExitDate { get; set; }

        public string Location { get; set; }

        public string AgentCode { get; set; }

        public string AgentName { get; set; }
        public string Duedate { get; set; }
        public decimal Amount { get; set; }
    }

    public class rptStatement
    {
        public string Name { get; set; }

        public string PolicyNo { get; set; }

        public string Location { get; set; }

        public string ReceiptNo { get; set; }

        public string RefNo { get; set; }

        public string Date { get; set; }

        public Decimal Amount { get; set; }

        public Decimal Interest { get; set; }

        public Decimal Total
        {
            get
            {
                return (this.Amount + this.Interest);
            }
        }
    }

    public class rptInvestmentHistory
    {
        public string PolicyNo { get; set; }

        public string ReceiptNo { get; set; }

        public decimal Amount { get; set; }

        public DateTime Date { get; set; }

        public decimal Gir { get; set; }

        public decimal Cur_Intr { get; set; }

        public decimal Cumul_Intr { get; set; }
        public string Name { get; set; }
        public string Title { get; set; }
        public string OrigDate { get; set; }
        public string Remark { get; set; }
        public string Phone { get; set; }
        public Decimal Total
        {
            get
            {
                return (this.Amount + this.Cumul_Intr);
            }
        }
    }

    public class rptProduction
    {
        public string PolicyNo { get; set; }

        public string ReceiptNo { get; set; }

        public string Date { get; set; }

        public Decimal Amount { get; set; }

        public string Name { get; set; }

        public string AgentName { get; set; }

        public decimal PremiumLoan { get; set; }

        public decimal PolicyLoan { get; set; }

        public decimal Others { get; set; }

        public string AcceptanceDate { get; set; }
        public decimal Premium { get; set; }
    }

    public class rptRecieptList
    {
        public string RecieptNo { get; set; }

        public string PolicyNo { get; set; }

        public string Surname { get; set; }

        public string OtherName { get; set; }

        public string Title { get; set; }

        public string Date { get; set; }

        public string ChequeNo { get; set; }

        public decimal Amount { get; set; }

        public string Remark { get; set; }
    } 
    public class rptPaymentList
    {
        public string RecieptNo { get; set; }

        public string PolicyNo { get; set; }

        public DateTime TransDate { get; set; }

        public string ChequeNo { get; set; }

        public decimal Amount { get; set; }

    }

    public class rptFundGroup
    {
        public string PolicyNo { get; set; }

        public string Surname { get; set; }

        public string OtherNames { get; set; }

        public DateTime AcceptanceDate { get; set; }

        public Decimal Amount { get; set; }
    }

    public class rptClaim
    {
        public string PolicyNo { get; set; }

        public string Surname { get; set; }

        public string OtherNames { get; set; }

        public string Location { get; set; }

        public string Agent { get; set; }

        public decimal Amount { get; set; }

        public decimal  Interest { get; set; }

        public DateTime TransDate { get; set; }

        public string ReceiptNo { get; set; }

        public string Title { get; set; }

        public DateTime ExitDate { get; set; }

        public decimal Total {
            get
            {
                return this.Amount + this.Interest;
            }
        }
    }

    public class rptReceipt
    {
        public string TransDate { get; set; }

        public string ReceiptNo { get; set; }

        public string Payer { get; set; }

        public string Remarks { get; set; }

        public string RefNo { get; set; }

        public string BranchCode { get; set; }

        public string AmountinWord { get; set; }

        public string Amount { get; set; }
    }
    public class rptGratuity
    {
        public string Title { get; set; }
        public string Surname { get; set; }
        public string Othername { get; set; }
        public string Location { get; set; }
        public string Policyno { get; set; }
        public string Receiptno { get; set; }
        public DateTime Trandate { get; set; }
        public string Pcn { get; set; }
        public string Grpcode { get; set; }
        public string Gir { get; set; }
        public string Period { get; set; }
        public string Doctype { get; set; }
        public string Poltype { get; set; }
        public DateTime Orig_date { get; set; }

        public decimal Psamount { get; set; }
        public decimal Psopen { get; set; }
        public decimal Pscur_intr { get; set; }
        public decimal Pscumul_intr { get; set; }
        public decimal Eramount { get; set; }
        public decimal Eropen { get; set; }
        public decimal Ercur_intr { get; set; }
        public decimal Ercumul_intr { get; set; }
        public decimal Eeamount { get; set; }

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

        public decimal Eeopen { get; set; }
        public decimal Eecur_intr { get; set; }
        public decimal Eecumul_intr { get; set; }
        public decimal Avamount { get; set; }
        public decimal Avopen { get; set; }
        public decimal Avcur_intr { get; set; }
        public decimal Avcumul_intr { get; set; }
        public decimal Ccamount { get; set; }
        public decimal Ccopen { get; set; }
        public decimal Cccur_intr { get; set; }
        public decimal Cccumul_intr { get; set; }
        public decimal Pscamount { get; set; }
        public decimal Pscopen { get; set; }
        public decimal Psccur_intr { get; set; }
        public decimal Psccumul_intr { get; set; }
        public decimal Loanamt { get; set; }
        public string grpname { get; set; }
        public string email { get; set; }
        public string header { get; set; }
        public string naration { get; set; }
    }
    public class rptPesonalInfo
    {
        public string Surname { get; set; }
        public string RegNo { get; set; }

        public string Othernames { get; set; } = "";

        public string ResAddress { get; set; } = "";

        public string OfficeAddress { get; set; } = "";

        public string PostalAddress { get; set; } = "";

        public string Email { get; set; } = "";

        public string Phone { get; set; } = "";

        public DateTime Dob { get; set; }
        public string birthdate { get; set; }

        public string Occupation { get; set; } = "";

        public Decimal Amount { get; set; } = 0M;

        public string Frequency { get; set; } = "";

        public DateTime CommencementDate { get; set; }

        public int Duration { get; set; } = 0;

        public string IdentityType { get; set; } = "";
        public string IdentityNumber { get; set; } = "";

        public string AgentCode { get; set; } = "";
        public string GroupCode { get; set; } = "";
        public string Religion { get; set; } = "";
        public string Gender { get; set; } = "";

    }
    public class rptPesonalInfoAndNok
    {
      public string RegNo {get; set;} = "";
      public string Surname {get; set;} = "";
      public string OtherNames {get; set;} = "";
      public string ResAddress {get; set;} = "";
      public string OffAddress {get; set;} = "";
      public string Email {get; set;} = "";
      public string Phone {get; set;} = "";
      public DateTime dob {get; set;}
      public string Occupation {get; set;} = "";
        public decimal ContribAmount { get; set; }  = 0m;
      public string ContribFreq {get; set;} = "";
      public DateTime CommencementDate {get; set;} 
      public int Duration {get; set;} = 0;
      public int Type {get; set;} = 0;
      public int PolicyType {get; set;} = 0;
      public string IdentityNumber {get; set;} = "";
      public string IdentityType {get; set;} = "";
      public string agentcode {get; set;} = "";
      public string nokname {get; set;} = "";
      public string Address {get; set;} = "";
      public string nokphone {get; set;} = "";
      public string nokemail {get; set;} = "";
      public DateTime nokdob {get; set;} 
      public string RelationShip {get; set;} = "";
      public long PersonalDetailsStagingId {get; set;} =0;
        public decimal Proportion { get; set; } = 0m;
      public string locdesc {get; set;} = "";
      public string agentname {get; set;} = "";
      public string poldesc {get; set;} = "";
        public string photopath { get; set; } = "";

    }
}
