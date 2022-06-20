﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Flex.Data.Model
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Entity.Core.Objects;
    using System.Linq;
    
    public partial class FlexEntities : DbContext
    {
        public FlexEntities()
            : base("name=FlexEntities")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<ac_costCenter> ac_costCenter { get; set; }
        public virtual DbSet<ac_jvdetails> ac_jvdetails { get; set; }
        public virtual DbSet<ac_jvheader> ac_jvheader { get; set; }
        public virtual DbSet<ac_pcvdetails> ac_pcvdetails { get; set; }
        public virtual DbSet<ac_pcvheader> ac_pcvheader { get; set; }
        public virtual DbSet<accchart> acccharts { get; set; }
        public virtual DbSet<ApiAuthToken> ApiAuthTokens { get; set; }
        public virtual DbSet<ClaimRequest> ClaimRequests { get; set; }
        public virtual DbSet<CustomerPolicy> CustomerPolicies { get; set; }
        public virtual DbSet<CustomerUser> CustomerUsers { get; set; }
        public virtual DbSet<fl_agents> fl_agents { get; set; }
        public virtual DbSet<fl_bank> fl_bank { get; set; }
        public virtual DbSet<fl_formfile> fl_formfile { get; set; }
        public virtual DbSet<fl_gpayclaim> fl_gpayclaim { get; set; }
        public virtual DbSet<fl_grouptype> fl_grouptype { get; set; }
        public virtual DbSet<fl_location> fl_location { get; set; }
        public virtual DbSet<fl_password> fl_password { get; set; }
        public virtual DbSet<fl_payclaim> fl_payclaim { get; set; }
        public virtual DbSet<fl_payhistory> fl_payhistory { get; set; }
        public virtual DbSet<fl_payhistorybak> fl_payhistorybak { get; set; }
        public virtual DbSet<fl_payinput> fl_payinput { get; set; }
        public virtual DbSet<fl_pendingSMS> fl_pendingSMS { get; set; }
        public virtual DbSet<fl_policyhistory> fl_policyhistory { get; set; }
        public virtual DbSet<fl_policyinput> fl_policyinput { get; set; }
        public virtual DbSet<fl_poltype> fl_poltype { get; set; }
        public virtual DbSet<fl_premrate> fl_premrate { get; set; }
        public virtual DbSet<fl_premrateRules> fl_premrateRules { get; set; }
        public virtual DbSet<fl_prgaccess> fl_prgaccess { get; set; }
        public virtual DbSet<fl_prgaccessXX> fl_prgaccessXX { get; set; }
        public virtual DbSet<fl_PublicHoliday> fl_PublicHoliday { get; set; }
        public virtual DbSet<fl_quotation> fl_quotation { get; set; }
        public virtual DbSet<fl_receiptcontrol> fl_receiptcontrol { get; set; }
        public virtual DbSet<fl_system> fl_system { get; set; }
        public virtual DbSet<fl_temphistory> fl_temphistory { get; set; }
        public virtual DbSet<fl_translog> fl_translog { get; set; }
        public virtual DbSet<LinkRole> LinkRoles { get; set; }
        public virtual DbSet<Module> Modules { get; set; }
        public virtual DbSet<NextofKin_BeneficiaryStaging> NextofKin_BeneficiaryStaging { get; set; }
        public virtual DbSet<Notification> Notifications { get; set; }
        public virtual DbSet<OnlineReciept> OnlineReciepts { get; set; }
        public virtual DbSet<PendingEmail> PendingEmails { get; set; }
        public virtual DbSet<PersonalDetailsStaging> PersonalDetailsStagings { get; set; }
        public virtual DbSet<Portlet> Portlets { get; set; }
        public virtual DbSet<Role> Roles { get; set; }
        public virtual DbSet<Tab> Tabs { get; set; }
        public virtual DbSet<UserRole> UserRoles { get; set; }
        public virtual DbSet<UserSession> UserSessions { get; set; }
        public virtual DbSet<ac_rctdetails> ac_rctdetails { get; set; }
        public virtual DbSet<ac_rctheader> ac_rctheader { get; set; }
        public virtual DbSet<fl_gpayhistory> fl_gpayhistory { get; set; }
        public virtual DbSet<fl_payinput2> fl_payinput2 { get; set; }
        public virtual DbSet<fl_premrate_temp> fl_premrate_temp { get; set; }
        public virtual DbSet<fl_state> fl_state { get; set; }
        public virtual DbSet<fl_temppolinput> fl_temppolinput { get; set; }
        public virtual DbSet<vProduction> vProductions { get; set; }
        public virtual DbSet<vwPolicy> vwPolicies { get; set; }
        public virtual DbSet<vwPolicyHistory> vwPolicyHistories { get; set; }
        public virtual DbSet<fl_month> fl_month { get; set; }
        public virtual DbSet<VPayhistorybyAgent> VPayhistorybyAgents { get; set; }
    
        [DbFunction("Entities", "SPLIT_STRING")]
        public virtual IQueryable<SPLIT_STRING_Result> SPLIT_STRING(string @string, string delimiter)
        {
            var stringParameter = @string != null ?
                new ObjectParameter("String", @string) :
                new ObjectParameter("String", typeof(string));
    
            var delimiterParameter = delimiter != null ?
                new ObjectParameter("Delimiter", delimiter) :
                new ObjectParameter("Delimiter", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.CreateQuery<SPLIT_STRING_Result>("[Entities].[SPLIT_STRING](@String, @Delimiter)", stringParameter, delimiterParameter);
        }
    
        public virtual int deleteclaim(Nullable<int> claimid)
        {
            var claimidParameter = claimid.HasValue ?
                new ObjectParameter("claimid", claimid) :
                new ObjectParameter("claimid", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("deleteclaim", claimidParameter);
        }
    
        public virtual int fl_annual_interest_calc(string wdate, string poltype, string grpcode, string wrate, string guser, string optintr)
        {
            var wdateParameter = wdate != null ?
                new ObjectParameter("wdate", wdate) :
                new ObjectParameter("wdate", typeof(string));
    
            var poltypeParameter = poltype != null ?
                new ObjectParameter("poltype", poltype) :
                new ObjectParameter("poltype", typeof(string));
    
            var grpcodeParameter = grpcode != null ?
                new ObjectParameter("grpcode", grpcode) :
                new ObjectParameter("grpcode", typeof(string));
    
            var wrateParameter = wrate != null ?
                new ObjectParameter("wrate", wrate) :
                new ObjectParameter("wrate", typeof(string));
    
            var guserParameter = guser != null ?
                new ObjectParameter("guser", guser) :
                new ObjectParameter("guser", typeof(string));
    
            var optintrParameter = optintr != null ?
                new ObjectParameter("optintr", optintr) :
                new ObjectParameter("optintr", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("fl_annual_interest_calc", wdateParameter, poltypeParameter, grpcodeParameter, wrateParameter, guserParameter, optintrParameter);
        }
    
        public virtual int fl_annual_interest_calcTSP(string wdate, string poltype, string grpcode, string wrate1, string wrate2, string wrate3, string wrate4, string wrate5, string guser, string optintr)
        {
            var wdateParameter = wdate != null ?
                new ObjectParameter("wdate", wdate) :
                new ObjectParameter("wdate", typeof(string));
    
            var poltypeParameter = poltype != null ?
                new ObjectParameter("poltype", poltype) :
                new ObjectParameter("poltype", typeof(string));
    
            var grpcodeParameter = grpcode != null ?
                new ObjectParameter("grpcode", grpcode) :
                new ObjectParameter("grpcode", typeof(string));
    
            var wrate1Parameter = wrate1 != null ?
                new ObjectParameter("wrate1", wrate1) :
                new ObjectParameter("wrate1", typeof(string));
    
            var wrate2Parameter = wrate2 != null ?
                new ObjectParameter("wrate2", wrate2) :
                new ObjectParameter("wrate2", typeof(string));
    
            var wrate3Parameter = wrate3 != null ?
                new ObjectParameter("wrate3", wrate3) :
                new ObjectParameter("wrate3", typeof(string));
    
            var wrate4Parameter = wrate4 != null ?
                new ObjectParameter("wrate4", wrate4) :
                new ObjectParameter("wrate4", typeof(string));
    
            var wrate5Parameter = wrate5 != null ?
                new ObjectParameter("wrate5", wrate5) :
                new ObjectParameter("wrate5", typeof(string));
    
            var guserParameter = guser != null ?
                new ObjectParameter("guser", guser) :
                new ObjectParameter("guser", typeof(string));
    
            var optintrParameter = optintr != null ?
                new ObjectParameter("optintr", optintr) :
                new ObjectParameter("optintr", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("fl_annual_interest_calcTSP", wdateParameter, poltypeParameter, grpcodeParameter, wrate1Parameter, wrate2Parameter, wrate3Parameter, wrate4Parameter, wrate5Parameter, guserParameter, optintrParameter);
        }
    
        public virtual int fl_backupb4_interest()
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("fl_backupb4_interest");
        }
    
        public virtual int fl_create_statement(string ipolno, string idate, string ipoltype, string globalstation, string intrate)
        {
            var ipolnoParameter = ipolno != null ?
                new ObjectParameter("ipolno", ipolno) :
                new ObjectParameter("ipolno", typeof(string));
    
            var idateParameter = idate != null ?
                new ObjectParameter("idate", idate) :
                new ObjectParameter("idate", typeof(string));
    
            var ipoltypeParameter = ipoltype != null ?
                new ObjectParameter("ipoltype", ipoltype) :
                new ObjectParameter("ipoltype", typeof(string));
    
            var globalstationParameter = globalstation != null ?
                new ObjectParameter("globalstation", globalstation) :
                new ObjectParameter("globalstation", typeof(string));
    
            var intrateParameter = intrate != null ?
                new ObjectParameter("intrate", intrate) :
                new ObjectParameter("intrate", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("fl_create_statement", ipolnoParameter, idateParameter, ipoltypeParameter, globalstationParameter, intrateParameter);
        }
    
        public virtual ObjectResult<fl_generate_serialno_Result> fl_generate_serialno(string poltype)
        {
            var poltypeParameter = poltype != null ?
                new ObjectParameter("poltype", poltype) :
                new ObjectParameter("poltype", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<fl_generate_serialno_Result>("fl_generate_serialno", poltypeParameter);
        }
    
        public virtual ObjectResult<fl_grat_statement_Result> fl_grat_statement(string globalpol, string polno, string grpcode, string globalstation, string txtdate1)
        {
            var globalpolParameter = globalpol != null ?
                new ObjectParameter("globalpol", globalpol) :
                new ObjectParameter("globalpol", typeof(string));
    
            var polnoParameter = polno != null ?
                new ObjectParameter("polno", polno) :
                new ObjectParameter("polno", typeof(string));
    
            var grpcodeParameter = grpcode != null ?
                new ObjectParameter("grpcode", grpcode) :
                new ObjectParameter("grpcode", typeof(string));
    
            var globalstationParameter = globalstation != null ?
                new ObjectParameter("globalstation", globalstation) :
                new ObjectParameter("globalstation", typeof(string));
    
            var txtdate1Parameter = txtdate1 != null ?
                new ObjectParameter("txtdate1", txtdate1) :
                new ObjectParameter("txtdate1", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<fl_grat_statement_Result>("fl_grat_statement", globalpolParameter, polnoParameter, grpcodeParameter, globalstationParameter, txtdate1Parameter);
        }
    
        public virtual int fl_Prepare_message(string rct_code, string rct_number, string rcth_date, string telephone)
        {
            var rct_codeParameter = rct_code != null ?
                new ObjectParameter("rct_code", rct_code) :
                new ObjectParameter("rct_code", typeof(string));
    
            var rct_numberParameter = rct_number != null ?
                new ObjectParameter("rct_number", rct_number) :
                new ObjectParameter("rct_number", typeof(string));
    
            var rcth_dateParameter = rcth_date != null ?
                new ObjectParameter("rcth_date", rcth_date) :
                new ObjectParameter("rcth_date", typeof(string));
    
            var telephoneParameter = telephone != null ?
                new ObjectParameter("telephone", telephone) :
                new ObjectParameter("telephone", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("fl_Prepare_message", rct_codeParameter, rct_numberParameter, rcth_dateParameter, telephoneParameter);
        }
    
        public virtual int fl_Prepare_message_only(string rct_code, string rct_number, string rcth_date, string telephone, Nullable<decimal> wamount, string msg)
        {
            var rct_codeParameter = rct_code != null ?
                new ObjectParameter("rct_code", rct_code) :
                new ObjectParameter("rct_code", typeof(string));
    
            var rct_numberParameter = rct_number != null ?
                new ObjectParameter("rct_number", rct_number) :
                new ObjectParameter("rct_number", typeof(string));
    
            var rcth_dateParameter = rcth_date != null ?
                new ObjectParameter("rcth_date", rcth_date) :
                new ObjectParameter("rcth_date", typeof(string));
    
            var telephoneParameter = telephone != null ?
                new ObjectParameter("telephone", telephone) :
                new ObjectParameter("telephone", typeof(string));
    
            var wamountParameter = wamount.HasValue ?
                new ObjectParameter("wamount", wamount) :
                new ObjectParameter("wamount", typeof(decimal));
    
            var msgParameter = msg != null ?
                new ObjectParameter("msg", msg) :
                new ObjectParameter("msg", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("fl_Prepare_message_only", rct_codeParameter, rct_numberParameter, rcth_dateParameter, telephoneParameter, wamountParameter, msgParameter);
        }
    
        public virtual int fl_Prepare_message_rctreversal(string rct_code, string rct_number, string rcth_date, string telephone, Nullable<decimal> wamount)
        {
            var rct_codeParameter = rct_code != null ?
                new ObjectParameter("rct_code", rct_code) :
                new ObjectParameter("rct_code", typeof(string));
    
            var rct_numberParameter = rct_number != null ?
                new ObjectParameter("rct_number", rct_number) :
                new ObjectParameter("rct_number", typeof(string));
    
            var rcth_dateParameter = rcth_date != null ?
                new ObjectParameter("rcth_date", rcth_date) :
                new ObjectParameter("rcth_date", typeof(string));
    
            var telephoneParameter = telephone != null ?
                new ObjectParameter("telephone", telephone) :
                new ObjectParameter("telephone", typeof(string));
    
            var wamountParameter = wamount.HasValue ?
                new ObjectParameter("wamount", wamount) :
                new ObjectParameter("wamount", typeof(decimal));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("fl_Prepare_message_rctreversal", rct_codeParameter, rct_numberParameter, rcth_dateParameter, telephoneParameter, wamountParameter);
        }
    
        public virtual int fl_Prepare_message2(string rct_code, string rct_number, string rcth_date, string telephone, Nullable<decimal> wamount, string msg)
        {
            var rct_codeParameter = rct_code != null ?
                new ObjectParameter("rct_code", rct_code) :
                new ObjectParameter("rct_code", typeof(string));
    
            var rct_numberParameter = rct_number != null ?
                new ObjectParameter("rct_number", rct_number) :
                new ObjectParameter("rct_number", typeof(string));
    
            var rcth_dateParameter = rcth_date != null ?
                new ObjectParameter("rcth_date", rcth_date) :
                new ObjectParameter("rcth_date", typeof(string));
    
            var telephoneParameter = telephone != null ?
                new ObjectParameter("telephone", telephone) :
                new ObjectParameter("telephone", typeof(string));
    
            var wamountParameter = wamount.HasValue ?
                new ObjectParameter("wamount", wamount) :
                new ObjectParameter("wamount", typeof(decimal));
    
            var msgParameter = msg != null ?
                new ObjectParameter("msg", msg) :
                new ObjectParameter("msg", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("fl_Prepare_message2", rct_codeParameter, rct_numberParameter, rcth_dateParameter, telephoneParameter, wamountParameter, msgParameter);
        }
    
        public virtual ObjectResult<string> fl_receipt_reversal(string poltype, string receipt)
        {
            var poltypeParameter = poltype != null ?
                new ObjectParameter("poltype", poltype) :
                new ObjectParameter("poltype", typeof(string));
    
            var receiptParameter = receipt != null ?
                new ObjectParameter("receipt", receipt) :
                new ObjectParameter("receipt", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<string>("fl_receipt_reversal", poltypeParameter, receiptParameter);
        }
    
        public virtual int fl_receipt_reversal_delete(string poltype, string receipt)
        {
            var poltypeParameter = poltype != null ?
                new ObjectParameter("poltype", poltype) :
                new ObjectParameter("poltype", typeof(string));
    
            var receiptParameter = receipt != null ?
                new ObjectParameter("receipt", receipt) :
                new ObjectParameter("receipt", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("fl_receipt_reversal_delete", poltypeParameter, receiptParameter);
        }
    
        public virtual int fl_restoreb4_interest()
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("fl_restoreb4_interest");
        }
    
        public virtual int fl_updatereceipt2()
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("fl_updatereceipt2");
        }
    
        public virtual int fl_updatereceipt3()
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("fl_updatereceipt3");
        }
    
        public virtual ObjectResult<string> fl_updatereceipt3_new(string poltype, string wdate1, string wdate2, string wsource)
        {
            var poltypeParameter = poltype != null ?
                new ObjectParameter("poltype", poltype) :
                new ObjectParameter("poltype", typeof(string));
    
            var wdate1Parameter = wdate1 != null ?
                new ObjectParameter("wdate1", wdate1) :
                new ObjectParameter("wdate1", typeof(string));
    
            var wdate2Parameter = wdate2 != null ?
                new ObjectParameter("wdate2", wdate2) :
                new ObjectParameter("wdate2", typeof(string));
    
            var wsourceParameter = wsource != null ?
                new ObjectParameter("wsource", wsource) :
                new ObjectParameter("wsource", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<string>("fl_updatereceipt3_new", poltypeParameter, wdate1Parameter, wdate2Parameter, wsourceParameter);
        }
    
        public virtual ObjectResult<string> fl_updgrat_receipt(string poltype, string guser, string receipt, string msg)
        {
            var poltypeParameter = poltype != null ?
                new ObjectParameter("poltype", poltype) :
                new ObjectParameter("poltype", typeof(string));
    
            var guserParameter = guser != null ?
                new ObjectParameter("guser", guser) :
                new ObjectParameter("guser", typeof(string));
    
            var receiptParameter = receipt != null ?
                new ObjectParameter("receipt", receipt) :
                new ObjectParameter("receipt", typeof(string));
    
            var msgParameter = msg != null ?
                new ObjectParameter("msg", msg) :
                new ObjectParameter("msg", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<string>("fl_updgrat_receipt", poltypeParameter, guserParameter, receiptParameter, msgParameter);
        }
    
        public virtual ObjectResult<string> fl_updgrat_receipt_original(string poltype, string guser, string receipt, string msg)
        {
            var poltypeParameter = poltype != null ?
                new ObjectParameter("poltype", poltype) :
                new ObjectParameter("poltype", typeof(string));
    
            var guserParameter = guser != null ?
                new ObjectParameter("guser", guser) :
                new ObjectParameter("guser", typeof(string));
    
            var receiptParameter = receipt != null ?
                new ObjectParameter("receipt", receipt) :
                new ObjectParameter("receipt", typeof(string));
    
            var msgParameter = msg != null ?
                new ObjectParameter("msg", msg) :
                new ObjectParameter("msg", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<string>("fl_updgrat_receipt_original", poltypeParameter, guserParameter, receiptParameter, msgParameter);
        }
    
        public virtual ObjectResult<string> fl_updgrat_receipt_smsonly(string poltype, string guser, string receipt, string msg)
        {
            var poltypeParameter = poltype != null ?
                new ObjectParameter("poltype", poltype) :
                new ObjectParameter("poltype", typeof(string));
    
            var guserParameter = guser != null ?
                new ObjectParameter("guser", guser) :
                new ObjectParameter("guser", typeof(string));
    
            var receiptParameter = receipt != null ?
                new ObjectParameter("receipt", receipt) :
                new ObjectParameter("receipt", typeof(string));
    
            var msgParameter = msg != null ?
                new ObjectParameter("msg", msg) :
                new ObjectParameter("msg", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<string>("fl_updgrat_receipt_smsonly", poltypeParameter, guserParameter, receiptParameter, msgParameter);
        }
    
        public virtual ObjectResult<qrystatement_Result> qrystatement(string policyno, string poltype, string month, string year)
        {
            var policynoParameter = policyno != null ?
                new ObjectParameter("policyno", policyno) :
                new ObjectParameter("policyno", typeof(string));
    
            var poltypeParameter = poltype != null ?
                new ObjectParameter("poltype", poltype) :
                new ObjectParameter("poltype", typeof(string));
    
            var monthParameter = month != null ?
                new ObjectParameter("month", month) :
                new ObjectParameter("month", typeof(string));
    
            var yearParameter = year != null ?
                new ObjectParameter("year", year) :
                new ObjectParameter("year", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<qrystatement_Result>("qrystatement", policynoParameter, poltypeParameter, monthParameter, yearParameter);
        }
    
        public virtual int SaveNextKinBen()
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("SaveNextKinBen");
        }
    
        public virtual ObjectResult<sp_CommissionReport_Result> sp_CommissionReport(string sdate, string edate, string module)
        {
            var sdateParameter = sdate != null ?
                new ObjectParameter("sdate", sdate) :
                new ObjectParameter("sdate", typeof(string));
    
            var edateParameter = edate != null ?
                new ObjectParameter("edate", edate) :
                new ObjectParameter("edate", typeof(string));
    
            var moduleParameter = module != null ?
                new ObjectParameter("module", module) :
                new ObjectParameter("module", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<sp_CommissionReport_Result>("sp_CommissionReport", sdateParameter, edateParameter, moduleParameter);
        }
    
        public virtual ObjectResult<sp_MaturityReport_Result> sp_MaturityReport()
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<sp_MaturityReport_Result>("sp_MaturityReport");
        }
    }
}
