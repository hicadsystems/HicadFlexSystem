using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Configuration;
using System.Linq;
using System.Web;

namespace Flex.Util
{
   
    public class ReportUtil
    {
        public class Constants
        {
            public const string SettingsKey = "CrystalReport.Settings";

            public const string BaseURL = "BaseURL";

            public const string Location = "Location";
            public const string PolicyType = "PolicyType";
            public const string ApprovedProposal = "ApprovedProposal";
            public const string LifeRate = "LifeRate";

            public const string MemberList = "MemberList";
            public const string MemberListByAgent = "MemberListByAgent";
            public const string MemberListByLocation = "MemberListByLocation";

            public const string Statement = "Statement";
            public const string InvHistory = "InvestmentHistory";
            public const string RctValue_Rct = "ReceiptCurrentValue_Receipt";
            public const string PolCurrentValue = "PolicyCurrentValue";
            public const string RctValue_Pol = "ReceiptCurrentValue_Policy";

            public const string Production = "Production";
            public const string ProductionByAgent = "ProductionByAgent";
            public const string ProductionSummary = "ProductionSummary";
            public const string ProductionSummaryByAgent = "ProductionSummaryByAgent";
            public const string ProductAnalysis = "ProductAnalysis";
            public const string RecieptListing = "RecieptListing";
            public const string FundGroup = "FundGroup";
            public const string ClaimStatement = "ClaimStatement";
            public const string ClaimApproval = "ClaimApproval";
            public const string ClaimSummary = "ClaimSummary";
            public const string ClaimDateRange = "ClaimDateRange";

            public const string Commisssion = "Commisssion";
            public const string CommisssionSummary = "CommisssionSummary";

            public const string Maturity = "Maturity";

            public const string Receipt = "Receipt";


            public const string CoyName = "CoyName";
            public const string CoyAddress = "CoyAddress";
            public const string statementAA = "statementAA";
            public const string statement1 = "statement1";
            public const string statement2 = "statement2";

            public const string statement3 = "statement3";
            public const string statement4 = "statement4";
            public const string statement5 = "statement5";
            public const string statement6 = "statement6";
            public const string statement7 = "statement7";
            public const string statement8 = "statement8";

            public const string statement9 = "statement9";
            public const string statement10 = "statement10";
            public const string statement11 = "statement11";
            public const string statement12 = "statement12";

            public const string statement1A = "statement1A";
            public const string statement2A = "statement2A";

            public const string statement3A = "statement3A";
            public const string statement4A = "statement4A";
            public const string statement5A = "statement5A";
            public const string statement6A = "statement6A";
            public const string statement7A = "statement7A";
            public const string statement8A = "statement8A";

            public const string statement9A = "statement9A";
            public const string statement10A = "statement10A";
            public const string statement11A = "statement11A";
            public const string statement12A = "statement12A";

            public const string AgentDetails = "AgentDetails";
            public const string ApprovedPolicy = "ApprovedPolicy";
            public const string PaymentListing = "PaymentListing";


        }
        public static string GetConfig(string key)
        {
            var wfSection = ConfigurationManager.GetSection(Constants.SettingsKey) as NameValueCollection;
            return wfSection[key];
        }

    }
}