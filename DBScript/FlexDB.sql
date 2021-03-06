
CREATE PROCEDURE [dbo].[qrystatement]
@policyno   varchar(20),
@poltype  varchar(2),
@month nvarchar(2),
@year nvarchar(4)
	/*
	(
	@parameter1 int = 5,
	@parameter2 datatype OUTPUT
	)
	*/
AS
declare @polno varchar(20),@curyear integer,@prvyear integer,@prvdate smalldatetime,@exitdate varchar(8),@amount money,@openb money,
		@mm smallint,@origdate smalldatetime,@origdate2 smalldatetime,@trandate smalldatetime,@receiptno varchar(12),@wreceiptno varchar(12),
		@gir smallint,@grpcode varchar(5),@pcn varchar(5),@period varchar(6),@wind varchar(12),@wctodate integer,@wctyear integer,@loan money,
		@curintr money,@curintr2 money,@curintr5 money,@amount2 money,@amount5 money,@cumintr money,@cumintr2 money,@cumintr5 money
declare @openb2 money,@openb5 money,@loan2 money,@loan5 money,@doctype varchar(12),@hold varchar(10), @amt money,
		@effperiod varchar(6),@prvperiod varchar(6),@period2 varchar(6),@period5 varchar(6),
		@amountx money,@cumintrx money,@curintrx money,@openbx money,@loanx money
		
declare @temTable as table (receiptno nvarchar(20), amount decimal(18,2), intr decimal(18,2),  policyno nvarchar(20), transdate datetime, orig_date datetime, RefNum nvarchar(20))

	/* SET NOCOUNT ON */ 
--delete from fl_temphistory --where workstation=@wstation


	declare mytab cursor for
	select policyno,exitdate,pcn,dob 
	from fl_policyinput 
	where policyno=@policyno and poltype=@poltype
	open mytab
	fetch next from mytab into @polno, @exitdate,@pcn,@hold
	If @@fetch_status<>0 return 7
	  	--set @curyear = Year(getdate()) 
		set @prvyear = cast(@year as int) - 1
		set @effperiod = @year + replicate('0',(2-len(@month)))+ @month
		--if len(@effperiod) = 1 set @effperiod = '0' + @effperiod
		--set @prvperiod = cast(@prvyear as varchar) + '11'
		--set @effperiod = cast(@curyear as varchar) + @effperiod
		--set @wind = '12/01/' + cast(@prvyear as varchar)
		--set @prvdate = cast(@wind as smalldatetime)
		--set @return_code = 'YES'
		while @@fetch_status=0   --for each policy
		begin
			--set @wind = '0'
			--If IsNull(@exitdate,'11111111')<> '11111111' --goto nextrecord1
			declare mytab1 cursor for
			select orig_date, trandate, receiptno, gir, grpcode, period, cur_intr, amount, openbalance, cumul_intr, loanamt, doctype, poltype 
			from fl_payhistory 
			where policyno=@polno and left(convert(nvarchar(10),orig_date,112),6) <= @effperiod and gir=0
			order by receiptno,period,trandate
			open mytab1
			fetch next from mytab1 into @origdate, @trandate, @receiptno, @gir, @grpcode, @period, @curintr, @amount, @openb, @cumintr, @loan, @doctype, @poltype
			--If @@fetch_status<>0 GoTo nextrecord
			set @wctyear = 0
			set @wctodate = 0
			while @@fetch_status=0   --for each receipt
			begin
				--If @effperiod < @period  GoTo nextreceipt1
				--set @wreceiptno = @receiptno
				if year(@origdate) < @year 
				begin
					set @wreceiptno = ' Open Bal'
					set @hold = '01/01/' + @year
					set @origdate2 = cast(@hold as datetime)
					--set @curintr2 = isnull(@curintrx,0) + isnull(@curintr,0)
					set @openb2 =  isnull(@amount,0) + isnull(@cumintr,0) -  isnull(@curintr,0)
					set @amount2 = @openb2
					insert into @temTable(receiptno, amount, intr,  policyno , transdate  )
						values(@wreceiptno,@amount2,@curintr,@polno,@hold)
				end
				else
				begin
					set @openb2 =  isnull(@amount,0) + isnull(@cumintr,0) -  isnull(@curintr,0)
					set @amount2 = @openb2

					insert into @temTable(receiptno, amount, intr,  policyno , transdate, orig_date  )
						values(@receiptno,@amount2,@curintr,@polno,@trandate,@origdate)
				end

				fetch next from mytab1 into @origdate, @trandate, @receiptno, @gir, @grpcode, @period, @curintr, @amount, @openb, @cumintr, @loan, @doctype, @poltype
			END
			close mytab1
			deallocate mytab1
			fetch next from mytab into @polno, @exitdate,@pcn,@hold
close mytab
deallocate mytab

END

select max(t.policyno) policyno, max(receiptno) Receiptno, sum(amount) amount, sum(intr) intr, convert(nvarchar(10),max(transdate),103) transdate , convert(nvarchar(10),max(orig_date),103) origindate , sum(amount)  +  sum(intr)  total, max(surname) surname, max(title) title, max(othername) othername, max(location) location
from @temTable t,  fl_policyinput pi
where t.policyno=pi.policyno
group by receiptno,transdate,orig_date
order by orig_date


RETURN

GO
/****** Object:  Table [dbo].[ac_costCenter]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ac_costCenter](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Desc] [nvarchar](50) NULL,
 CONSTRAINT [PK_ac_costCenter] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[accchart]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[accchart](
	[acctcode1] [nvarchar](1) NULL,
	[acctcode2] [nvarchar](2) NULL,
	[acctcode3] [nvarchar](3) NULL,
	[acctcode4] [nvarchar](4) NULL,
	[acctcode5] [nvarchar](5) NULL,
	[acctcode6] [nvarchar](6) NULL,
	[acctnumber] [nvarchar](15) NOT NULL,
	[description] [nvarchar](60) NOT NULL,
	[acctcode7] [nvarchar](60) NULL,
	[oldnumber] [nvarchar](12) NULL,
	[acctype] [nvarchar](2) NULL,
	[acctsubtype] [nvarchar](1) NULL,
	[address] [nvarchar](100) NULL,
	[effdate] [char](10) NULL,
	[ledgerpasswd] [nvarchar](20) NULL,
	[ledgerpasswd2] [nvarchar](20) NULL,
	[subcode] [nvarchar](6) NULL,
	[blgroup1] [nvarchar](5) NULL,
	[blgroup2] [nvarchar](5) NULL,
	[blgroup3] [nvarchar](5) NULL,
	[blgroup4] [nvarchar](5) NULL,
	[blgroupdes1] [nvarchar](50) NULL,
	[blgroupdes2] [nvarchar](50) NULL,
	[blgroupdes3] [nvarchar](50) NULL,
	[blgroupdes4] [nvarchar](50) NULL,
	[blsum1] [nvarchar](5) NULL,
	[blsum2] [nvarchar](5) NULL,
	[blsum3] [nvarchar](5) NULL,
	[blsum4] [nvarchar](5) NULL,
	[blsumdesc1] [nvarchar](50) NULL,
	[blsumdesc2] [nvarchar](50) NULL,
	[blsumdesc3] [nvarchar](50) NULL,
	[blsumdesc4] [nvarchar](50) NULL,
	[cfgroup1] [nvarchar](5) NULL,
	[cfgroup2] [nvarchar](5) NULL,
	[cfgroup3] [nvarchar](5) NULL,
	[cfgroup4] [nvarchar](5) NULL,
	[cfgroupdes1] [nvarchar](50) NULL,
	[cfgroupdes2] [nvarchar](50) NULL,
	[cfgroupdes3] [nvarchar](50) NULL,
	[cfgroupdes4] [nvarchar](50) NULL,
	[cfsumdesc1] [nvarchar](50) NULL,
	[cfsumdesc2] [nvarchar](50) NULL,
	[cfsumdesc3] [nvarchar](50) NULL,
	[cfsumdesc4] [nvarchar](50) NULL,
	[createdby] [nvarchar](20) NULL,
	[datecreated] [datetime] NULL,
	[address1] [nvarchar](50) NULL,
	[address2] [nvarchar](50) NULL,
	[address3] [nvarchar](50) NULL,
	[telephone] [nvarchar](50) NULL,
	[email] [nvarchar](50) NULL,
	[trade] [nvarchar](50) NULL,
	[dateblocked] [smalldatetime] NULL,
 CONSTRAINT [PK_accchart] PRIMARY KEY CLUSTERED 
(
	[acctnumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ApiAuthToken]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ApiAuthToken](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[AppCode] [nvarchar](50) NULL,
	[Token] [nvarchar](50) NULL,
	[DateCreated] [datetime] NULL,
	[DateExpired] [datetime] NULL,
 CONSTRAINT [PK_ApiAuthToken] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ClaimRequest]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClaimRequest](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[ClaimNo] [nvarchar](50) NULL,
	[PolicyNo] [nvarchar](50) NULL,
	[Amount] [decimal](18, 2) NULL,
	[ClaimType] [int] NULL,
	[Status] [int] NULL,
	[DateCreated] [datetime2](7) NULL,
	[EffectiveDate] [datetime2](7) NULL,
	[Interest] [decimal](18, 2) NULL,
	[ApprovedAmount] [decimal](18, 2) NULL,
	[FundAmount] [decimal](18, 2) NULL,
 CONSTRAINT [PK_ClaimRequest] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerPolicies]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerPolicies](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerUserId] [bigint] NULL,
	[Policyno] [nvarchar](20) NULL,
 CONSTRAINT [PK_CustomerPolicies] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CustomerUser]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerUser](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[username] [nvarchar](40) NULL,
	[password] [nvarchar](100) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[createdby] [bigint] NULL,
	[datecreated] [datetime2](7) NULL DEFAULT (getdate()),
	[passworddate] [datetime2](7) NULL,
	[modifydate] [datetime2](7) NULL,
	[modifyby] [bigint] NULL,
	[lastLoginDate] [datetime] NOT NULL,
	[firstLoginDate] [datetime] NOT NULL,
	[status] [int] NULL,
	[email] [nvarchar](100) NULL,
	[phone] [nvarchar](15) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_CustomerUser] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_agents]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_agents](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[agentcode] [nvarchar](50) NULL,
	[agentname] [nvarchar](50) NULL,
	[locationId] [int] NULL,
	[agenttype] [int] NULL,
	[CommissionRate] [decimal](18, 2) NULL,
	[createdBy] [nvarchar](50) NULL,
	[datecreated] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
	[datemodified] [datetime2](7) NULL,
	[modifiedby] [nvarchar](50) NULL,
	[agentaddr] [nvarchar](100) NULL,
	[agentphone] [nvarchar](15) NULL,
 CONSTRAINT [PK_fl_agents] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_formfile]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_formfile](
	[formcode] [nvarchar](10) NOT NULL,
	[descr] [nvarchar](40) NULL,
 CONSTRAINT [PK_fl_formfile] PRIMARY KEY CLUSTERED 
(
	[formcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_gpayclaim]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_gpayclaim](
	[poltype] [nvarchar](3) NOT NULL,
	[grpcode] [nvarchar](5) NOT NULL,
	[pcn] [nvarchar](5) NOT NULL,
	[receiptno] [nvarchar](10) NOT NULL,
	[period] [nvarchar](6) NOT NULL,
	[policyno] [nvarchar](20) NOT NULL,
	[orig_date] [smalldatetime] NULL,
	[trandate] [smalldatetime] NULL,
	[gir] [real] NULL,
	[loanamt] [money] NULL,
	[doctype] [nvarchar](20) NULL,
	[psopen] [money] NULL,
	[psamount] [money] NULL,
	[pscur_intr] [money] NULL,
	[pscumul_intr] [money] NULL,
	[eropen] [money] NULL,
	[eramount] [money] NULL,
	[ercur_intr] [money] NULL,
	[ercumul_intr] [money] NULL,
	[eeopen] [money] NULL,
	[eeamount] [money] NULL,
	[eecur_intr] [money] NULL,
	[eecumul_intr] [money] NULL,
	[avopen] [money] NULL,
	[avamount] [money] NULL,
	[avcur_intr] [money] NULL,
	[avcumul_intr] [money] NULL,
	[ccopen] [money] NULL,
	[ccamount] [money] NULL,
	[cccur_intr] [money] NULL,
	[cccumul_intr] [money] NULL,
	[pscopen] [money] NULL,
	[pscamount] [money] NULL,
	[psccur_intr] [money] NULL,
	[psccumul_intr] [money] NULL,
	[updatedby] [nvarchar](20) NULL,
	[dateupdated] [smalldatetime] NULL,
 CONSTRAINT [PK_fl_gpayclaim] PRIMARY KEY CLUSTERED 
(
	[receiptno] ASC,
	[period] ASC,
	[policyno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_gpayhistory]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_gpayhistory](
	[poltype] [nvarchar](3) NOT NULL,
	[grpcode] [nvarchar](5) NOT NULL,
	[pcn] [nvarchar](5) NOT NULL,
	[receiptno] [nvarchar](10) NOT NULL,
	[period] [nvarchar](6) NOT NULL,
	[policyno] [nvarchar](20) NOT NULL,
	[orig_date] [smalldatetime] NULL,
	[trandate] [smalldatetime] NULL,
	[gir] [real] NULL,
	[loanamt] [money] NULL,
	[doctype] [nvarchar](20) NULL,
	[psopen] [money] NULL,
	[psamount] [money] NULL,
	[pscur_intr] [money] NULL,
	[pscumul_intr] [money] NULL,
	[eropen] [money] NULL,
	[eramount] [money] NULL,
	[ercur_intr] [money] NULL,
	[ercumul_intr] [money] NULL,
	[eeopen] [money] NULL,
	[eeamount] [money] NULL,
	[eecur_intr] [money] NULL,
	[eecumul_intr] [money] NULL,
	[avopen] [money] NULL,
	[avamount] [money] NULL,
	[avcur_intr] [money] NULL,
	[avcumul_intr] [money] NULL,
	[ccopen] [money] NULL,
	[ccamount] [money] NULL,
	[cccur_intr] [money] NULL,
	[cccumul_intr] [money] NULL,
	[pscopen] [money] NULL,
	[pscamount] [money] NULL,
	[psccur_intr] [money] NULL,
	[psccumul_intr] [money] NULL,
	[updatedby] [nvarchar](20) NULL,
	[dateupdated] [smalldatetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_grouptype]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_grouptype](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[grpcode] [nvarchar](50) NULL,
	[grpname] [nvarchar](100) NULL,
	[Address] [nvarchar](150) NULL,
	[accountcode] [nvarchar](50) NULL,
	[grpclass] [nvarchar](50) NULL,
	[IsDeleted] [bit] NULL,
	[DateCreated] [datetime2](7) NULL,
	[Createdby] [nvarchar](50) NULL,
 CONSTRAINT [PK_fl_grouptype] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_location]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_location](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[locdesc] [nvarchar](50) NULL,
	[locstate] [nvarchar](50) NULL,
	[loccode] [nvarchar](50) NULL,
	[datecreated] [datetime2](7) NULL,
	[createdby] [nvarchar](50) NULL,
	[datemodified] [datetime2](7) NULL,
	[modifiedby] [nvarchar](50) NULL,
	[Isdeleted] [bit] NULL,
 CONSTRAINT [PK_fl_location] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_logfile]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_logfile](
	[logdate] [datetime] NULL,
	[userid] [nvarchar](10) NULL,
	[formcode] [nvarchar](60) NULL,
	[prgaction] [nvarchar](20) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_password]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_password](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[userid] [nvarchar](20) NOT NULL,
	[userpassword] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](40) NULL,
	[userdept] [nvarchar](30) NULL,
	[createdby] [nvarchar](30) NULL,
	[datecreated] [datetime] NULL,
	[expirydate] [datetime] NULL,
	[passworddate] [datetime] NULL,
	[Deleteddate] [datetime] NULL,
	[Deletedby] [nvarchar](30) NULL,
	[modifydate] [datetime] NULL,
	[modifyby] [nvarchar](30) NULL,
	[lastlogindate] [datetime] NULL,
	[status] [int] NULL,
	[branch] [int] NULL,
	[mobile] [nvarchar](15) NULL,
	[email] [nvarchar](100) NULL,
 CONSTRAINT [PK_fl_password] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_payclaim]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_payclaim](
	[srn] [bigint] IDENTITY(1,1) NOT NULL,
	[policyno] [nvarchar](20) NOT NULL,
	[receiptno] [nvarchar](30) NOT NULL,
	[period] [nvarchar](6) NOT NULL,
	[grpcode] [nvarchar](5) NULL,
	[pcn] [nvarchar](5) NULL,
	[poltype] [nvarchar](3) NULL,
	[orig_date] [smalldatetime] NULL,
	[trandate] [smalldatetime] NULL,
	[amount] [money] NULL,
	[gir] [real] NULL,
	[cur_intr] [money] NULL,
	[cumul_intr] [money] NULL,
	[loanamt] [money] NULL,
	[doctype] [nvarchar](20) NULL,
	[openbalance] [money] NULL,
	[opendeposit] [money] NULL,
	[deposit] [money] NULL,
	[curdep_intr] [money] NULL,
	[cumuldep_intr] [money] NULL,
 CONSTRAINT [PK_fl_payclaim] PRIMARY KEY CLUSTERED 
(
	[srn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_payhistory]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_payhistory](
	[srn] [bigint] IDENTITY(1,1) NOT NULL,
	[policyno] [nvarchar](20) NOT NULL,
	[receiptno] [nvarchar](30) NOT NULL,
	[period] [nvarchar](6) NOT NULL,
	[grpcode] [nvarchar](5) NULL,
	[pcn] [nvarchar](5) NULL,
	[poltype] [nvarchar](3) NULL,
	[orig_date] [smalldatetime] NULL,
	[trandate] [smalldatetime] NULL,
	[amount] [money] NULL CONSTRAINT [DF_fl_payhistory_amount]  DEFAULT ((0.00)),
	[gir] [real] NULL CONSTRAINT [DF_fl_payhistory_gir]  DEFAULT ((0.00)),
	[cur_intr] [money] NULL CONSTRAINT [DF_fl_payhistory_cur_intr]  DEFAULT ((0.00)),
	[cumul_intr] [money] NULL CONSTRAINT [DF_fl_payhistory_cumul_intr]  DEFAULT ((0.00)),
	[loanamt] [money] NULL CONSTRAINT [DF_fl_payhistory_loanamt]  DEFAULT ((0.00)),
	[doctype] [int] NULL,
	[openbalance] [money] NULL CONSTRAINT [DF_fl_payhistory_openbalance]  DEFAULT ((0.00)),
	[opendeposit] [money] NULL CONSTRAINT [DF_fl_payhistory_opendeposit]  DEFAULT ((0.00)),
	[deposit] [money] NULL CONSTRAINT [DF_fl_payhistory_deposit]  DEFAULT ((0.00)),
	[curdep_intr] [money] NULL CONSTRAINT [DF_fl_payhistory_curdep_intr]  DEFAULT ((0.00)),
	[cumuldep_intr] [money] NULL CONSTRAINT [DF_fl_payhistory_cumuldep_intr]  DEFAULT ((0.00)),
 CONSTRAINT [PK_fl_payhistory] PRIMARY KEY CLUSTERED 
(
	[srn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_payinput]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_payinput](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[policyno] [nvarchar](20) NOT NULL,
	[receiptno] [nvarchar](30) NOT NULL,
	[type] [int] NOT NULL,
	[grpcode] [nvarchar](8) NULL,
	[pcn] [nvarchar](5) NULL,
	[reverseind] [bit] NULL,
	[trandate] [datetime2](7) NULL,
	[effdate] [datetime2](7) NOT NULL,
	[totamt] [money] NULL,
	[chequeno] [nvarchar](50) NULL,
	[payindicator] [nvarchar](1) NULL,
	[status] [nvarchar](1) NULL,
	[createdby] [nvarchar](20) NULL,
	[datecreated] [datetime2](7) NULL,
	[amount] [money] NULL,
	[poltype] [nvarchar](3) NULL,
 CONSTRAINT [PK_fl_payinput_1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_payinput2]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_payinput2](
	[policyno] [nvarchar](20) NOT NULL,
	[receiptno] [nvarchar](10) NOT NULL,
	[poltype] [nvarchar](3) NULL,
	[type] [nvarchar](15) NOT NULL,
	[grpcode] [nvarchar](8) NOT NULL,
	[pcn] [nvarchar](5) NOT NULL,
	[reverseind] [nvarchar](1) NULL,
	[trandate] [nvarchar](8) NULL,
	[effdate] [nvarchar](8) NOT NULL,
	[totamt] [money] NULL,
	[chequeno] [nvarchar](10) NULL,
	[payindicator] [nvarchar](1) NULL,
	[status] [nvarchar](1) NULL,
	[createdby] [nvarchar](20) NULL,
	[datecreated] [smalldatetime] NULL,
	[ps] [money] NULL,
	[er] [money] NULL,
	[ee] [money] NULL,
	[av] [money] NULL,
	[psc] [money] NULL,
	[cc] [money] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_pendingSMS]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_pendingSMS](
	[srn] [int] IDENTITY(1,1) NOT NULL,
	[telephone] [nvarchar](20) NULL,
	[message] [nvarchar](max) NULL,
	[isSent] [bit] NULL,
	[retrycount] [int] NULL,
 CONSTRAINT [PK_fl_pendingSMS_1] PRIMARY KEY CLUSTERED 
(
	[srn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_policyhistory]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_policyhistory](
	[period] [nvarchar](10) NOT NULL,
	[policyno] [nvarchar](20) NOT NULL,
	[pcn] [nvarchar](7) NOT NULL,
	[grpcode] [nvarchar](15) NOT NULL,
	[sex] [nvarchar](7) NULL,
	[title] [nvarchar](10) NULL,
	[surname] [nvarchar](30) NOT NULL,
	[othername] [nvarchar](30) NULL,
	[peradd] [ntext] NULL,
	[dob] [nvarchar](8) NULL,
	[nok] [nvarchar](30) NULL,
	[datecreated] [smalldatetime] NULL,
	[createdby] [nvarchar](20) NULL,
	[datemodified] [smalldatetime] NULL,
	[modifiedby] [nvarchar](20) NULL,
	[accdate] [datetime] NULL,
	[quoteno] [nvarchar](10) NULL,
	[poltype] [nvarchar](3) NOT NULL,
	[exitdate] [nvarchar](8) NULL,
	[location] [nvarchar](25) NULL,
	[agentcode] [nvarchar](15) NULL,
	[email] [nvarchar](50) NULL,
	[premium] [numeric](18, 0) NULL,
	[telephone] [nvarchar](15) NULL,
	[pinword] [nvarchar](30) NULL,
	[religion] [nvarchar](15) NULL,
 CONSTRAINT [PK_fl_policyhistory] PRIMARY KEY CLUSTERED 
(
	[period] ASC,
	[policyno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_policyinput]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_policyinput](
	[srn] [bigint] IDENTITY(1,1) NOT NULL,
	[policyno] [nvarchar](20) NOT NULL,
	[pcn] [nvarchar](7) NULL,
	[grpcode] [nvarchar](15) NULL,
	[sex] [nvarchar](7) NULL,
	[title] [nvarchar](10) NULL,
	[surname] [nvarchar](30) NULL,
	[othername] [nvarchar](30) NULL,
	[peradd] [nvarchar](max) NULL,
	[dob] [nvarchar](8) NULL,
	[nok] [nvarchar](30) NULL,
	[datecreated] [smalldatetime] NULL,
	[createdby] [nvarchar](20) NULL,
	[datemodified] [smalldatetime] NULL,
	[modifiedby] [nvarchar](20) NULL,
	[accdate] [datetime] NULL,
	[quoteno] [nvarchar](20) NULL,
	[poltype] [nvarchar](3) NOT NULL,
	[exitdate] [nvarchar](8) NULL,
	[location] [int] NULL,
	[agentcode] [nvarchar](15) NULL,
	[email] [nvarchar](50) NULL,
	[premium] [numeric](18, 0) NULL,
	[telephone] [nvarchar](15) NULL,
	[pinword] [nvarchar](30) NULL,
	[religion] [nvarchar](15) NULL,
	[status] [int] NULL,
 CONSTRAINT [PK_fl_policyinput_1] PRIMARY KEY CLUSTERED 
(
	[srn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_poltype]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_poltype](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[poltype] [nvarchar](50) NOT NULL,
	[poldesc] [nvarchar](50) NULL,
	[code] [nvarchar](5) NULL,
	[actype] [nvarchar](50) NULL,
	[term] [int] NULL,
	[matage] [int] NULL,
	[maxloan] [decimal](18, 2) NULL,
	[income_account] [nvarchar](50) NULL,
	[liability_account] [nvarchar](50) NULL,
	[expense_account] [nvarchar](50) NULL,
	[vat_account] [nvarchar](50) NULL,
	[Datecreated] [datetime2](7) NULL,
	[CreatedBy] [datetime2](7) NULL,
	[DateModified] [datetime2](7) NULL,
	[ModifiedBy] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_fl_poltype_1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_premrate]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_premrate](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[poltypeId] [int] NOT NULL,
	[grpId] [bigint] NULL,
	[period] [nvarchar](50) NULL,
	[interest] [decimal](18, 2) NULL,
	[commrate] [decimal](18, 2) NULL,
	[retention] [decimal](18, 2) NULL,
	[mkt_commrate] [nvarchar](50) NULL,
	[Datecreated] [datetime2](7) NULL,
	[CreatedBy] [datetime2](7) NULL,
	[DateModified] [datetime2](7) NULL,
	[ModifiedBy] [datetime2](7) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_fl_premrate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_premrateRules]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_premrateRules](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Interest] [decimal](18, 2) NULL,
	[CommRate] [decimal](18, 2) NULL,
	[Mkt_CommRate] [decimal](18, 2) NULL,
	[IntrBound] [decimal](18, 2) NULL,
	[CommBound] [decimal](18, 2) NULL,
	[PremRateId] [int] NULL,
 CONSTRAINT [PK_fl_premrateRules] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_prgaccess]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_prgaccess](
	[userid] [nvarchar](20) NOT NULL,
	[formcode] [nvarchar](10) NOT NULL,
	[descr] [nvarchar](60) NULL,
	[accesscode] [nvarchar](3) NULL,
	[createdby] [nvarchar](20) NULL,
 CONSTRAINT [PK_fl_prgaccess] PRIMARY KEY CLUSTERED 
(
	[userid] ASC,
	[formcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_prgaccessXX]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_prgaccessXX](
	[userid] [nvarchar](20) NOT NULL,
	[formcode] [nvarchar](10) NOT NULL,
	[descr] [nvarchar](60) NULL,
	[accesscode] [nvarchar](3) NULL,
	[createdby] [nvarchar](20) NULL,
 CONSTRAINT [PK_fl_prgaccessXX] PRIMARY KEY CLUSTERED 
(
	[userid] ASC,
	[formcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_PublicHoliday]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_PublicHoliday](
	[Id] [bigint] NOT NULL,
	[HolidayName] [nvarchar](20) NULL,
	[Holidayday] [int] NULL,
	[holidaymonth] [int] NULL,
	[HolidayMsg] [nvarchar](100) NULL,
 CONSTRAINT [PK_fl_PublicHoliday] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_quotation]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_quotation](
	[grpcode] [nvarchar](5) NOT NULL,
	[pcn] [nvarchar](6) NOT NULL,
	[poltype] [nvarchar](2) NOT NULL,
	[sex] [nvarchar](7) NULL,
	[title] [nvarchar](10) NULL,
	[surname] [nvarchar](30) NOT NULL,
	[othername] [nvarchar](30) NULL,
	[peradd] [ntext] NULL,
	[dob] [nvarchar](10) NULL,
	[nok] [nvarchar](30) NULL,
	[datecreated] [smalldatetime] NULL,
	[createdby] [nvarchar](20) NULL,
	[datemodified] [smalldatetime] NULL,
	[modifiedby] [nvarchar](20) NULL,
	[policyno] [nvarchar](20) NULL,
	[quoteno] [nvarchar](10) NULL,
	[tag] [nvarchar](15) NULL,
	[location] [nvarchar](25) NULL,
	[agentcode] [nvarchar](15) NULL,
	[email] [nvarchar](50) NULL,
	[premium] [numeric](18, 0) NULL,
	[telephone] [nvarchar](15) NULL,
	[religion] [nvarchar](15) NULL,
 CONSTRAINT [PK_fl_quotation] PRIMARY KEY CLUSTERED 
(
	[grpcode] ASC,
	[pcn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_receiptcontrol]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_receiptcontrol](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PolTypeId] [int] NULL,
	[PaymentMethod] [int] NULL,
	[Income_ledger] [nvarchar](50) NULL,
	[Bank_ledger] [nvarchar](50) NULL,
	[BankAccount] [nvarchar](50) NULL,
	[Bankname] [nvarchar](50) NULL,
	[Receiptcounter] [int] NULL,
	[DateCreated] [datetime2](7) NULL,
	[CreatedBy] [bigint] NULL,
	[DateModified] [datetime2](7) NULL,
	[ModifiedBy] [bigint] NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_fl_receiptcontrol] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_system]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_system](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[coycode] [nvarchar](10) NOT NULL,
	[coyname] [nvarchar](60) NULL,
	[coyaddress] [nvarchar](100) NULL,
	[town] [nvarchar](15) NULL,
	[lg] [nvarchar](15) NULL,
	[state] [nvarchar](20) NULL,
	[telephone] [nvarchar](20) NULL,
	[email] [nvarchar](50) NULL,
	[box] [nvarchar](30) NULL,
	[processyear] [nvarchar](11) NULL,
	[processmonth] [nvarchar](11) NULL,
	[installdate] [nvarchar](11) NULL,
	[createdby] [nvarchar](20) NULL,
	[datecreated] [datetime] NULL,
	[serialnumber] [nvarchar](15) NULL,
	[reassurance] [nvarchar](50) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_fl_system] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_temphistory]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_temphistory](
	[workstation] [nvarchar](20) NOT NULL,
	[policyno] [nvarchar](20) NOT NULL,
	[receiptno] [nvarchar](10) NOT NULL,
	[period] [nvarchar](6) NOT NULL,
	[grpcode] [nvarchar](5) NOT NULL,
	[pcn] [nvarchar](5) NOT NULL,
	[poltype] [nvarchar](3) NULL,
	[orig_date] [smalldatetime] NULL,
	[trandate] [smalldatetime] NULL,
	[amount] [money] NULL,
	[gir] [real] NULL,
	[cur_intr] [money] NULL,
	[cumul_intr] [money] NULL,
	[loanamt] [money] NULL,
	[doctype] [nvarchar](20) NULL,
	[openbalance] [money] NULL,
	[opendeposit] [money] NULL,
	[deposit] [money] NULL,
	[curdep_intr] [money] NULL,
	[cumuldep_intr] [money] NULL,
 CONSTRAINT [PK_fl_temphistory] PRIMARY KEY CLUSTERED 
(
	[workstation] ASC,
	[policyno] ASC,
	[receiptno] ASC,
	[period] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_temppolinput]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_temppolinput](
	[pcn] [nvarchar](7) NOT NULL,
	[grpcode] [nvarchar](15) NOT NULL,
	[sex] [nvarchar](7) NULL,
	[title] [nvarchar](10) NULL,
	[surname] [nvarchar](30) NOT NULL,
	[othername] [nvarchar](30) NULL,
	[peradd] [ntext] NULL,
	[dob] [nvarchar](8) NULL,
	[nok] [nvarchar](30) NULL,
	[datecreated] [smalldatetime] NULL,
	[createdby] [nvarchar](20) NULL,
	[datemodified] [smalldatetime] NULL,
	[modifiedby] [nvarchar](20) NULL,
	[accdate] [datetime] NULL,
	[quoteno] [nvarchar](10) NULL,
	[policyno] [nvarchar](20) NOT NULL,
	[poltype] [nvarchar](3) NOT NULL,
	[exitdate] [nvarchar](8) NULL,
	[location] [nvarchar](25) NULL,
	[agentcode] [nvarchar](15) NULL,
	[email] [nvarchar](50) NULL,
	[premium] [numeric](18, 0) NULL,
	[telephone] [nvarchar](15) NULL,
	[pinword] [nvarchar](30) NULL,
	[religion] [nvarchar](15) NULL,
	[workstation] [nvarchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_tempreceiptlist]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_tempreceiptlist](
	[work_station] [nvarchar](20) NULL,
	[policyno] [nvarchar](20) NULL,
	[receiptno] [nvarchar](10) NULL,
	[reverseind] [nvarchar](1) NULL,
	[trandate] [datetime] NULL,
	[totamt] [money] NULL,
	[chequeno] [nvarchar](10) NULL,
	[type] [nvarchar](15) NULL,
	[premium] [money] NULL,
	[prmloan] [money] NULL,
	[policyloan] [money] NULL,
	[others] [money] NULL,
	[commision] [money] NULL,
	[premiumno] [smallint] NULL,
	[createdby] [nvarchar](12) NULL,
	[datecreated] [smalldatetime] NULL,
	[processby] [nvarchar](12) NULL,
	[procdate] [smalldatetime] NULL,
	[polname] [nvarchar](50) NULL,
	[agentname] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[fl_translog]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fl_translog](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[receiptno] [nvarchar](50) NULL,
	[trandate] [datetime2](7) NULL,
	[bank_ledger] [nvarchar](50) NULL,
	[income_ledger] [nvarchar](50) NULL,
	[payee] [nvarchar](100) NULL,
	[paymentmethod] [int] NULL,
	[amount] [decimal](18, 2) NULL,
	[policyno] [nvarchar](50) NULL,
	[remark] [nvarchar](max) NULL,
	[Instrument] [int] NULL,
	[Isreversed] [bit] NULL,
	[chequeno] [nvarchar](50) NULL,
 CONSTRAINT [PK_fl_receipt] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LinkRole]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LinkRole](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[LinkId] [int] NULL,
	[RoleID] [int] NULL,
	[Type] [int] NOT NULL,
	[Parent] [int] NULL,
 CONSTRAINT [PK_LinkRole] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[NextofKin_BeneficiaryStaging]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NextofKin_BeneficiaryStaging](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[RegNo] [nvarchar](20) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Address] [nvarchar](50) NOT NULL,
	[Phone] [nvarchar](15) NULL,
	[Email] [nvarchar](50) NOT NULL,
	[Type] [int] NOT NULL,
	[Dob] [datetime2](7) NOT NULL,
	[RelationShip] [nvarchar](50) NULL,
	[Category] [int] NOT NULL,
	[PersonalDetailsStagingId] [bigint] NULL,
	[Proportion] [decimal](18, 2) NULL,
	[ApprovalStatus] [int] NULL,
	[IsSynched] [bit] NULL CONSTRAINT [DF_NextofKin_BeneficiaryStaging_IsSynched]  DEFAULT ((0)),
	[PolicyId] [bigint] NULL,
 CONSTRAINT [PK_NextofKin_Beneficiary] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Notification]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notification](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Policyno] [nvarchar](20) NOT NULL,
	[period] [nchar](10) NULL,
	[IsSent] [bit] NULL,
	[DateCreated] [datetime] NULL,
	[NotificationType] [int] NULL,
	[NotificationFor] [int] NULL,
 CONSTRAINT [PK_Notification] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OnlineReciept]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OnlineReciept](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PaymentDate] [datetime2](7) NULL,
	[ReceiptNo] [nvarchar](20) NULL,
	[PaymentChannel] [int] NULL,
	[InitialAmount] [decimal](18, 2) NULL,
	[FinalAmount] [decimal](18, 2) NULL,
	[Product] [nvarchar](30) NULL,
	[Policyno] [nvarchar](20) NULL,
	[IsSynched] [bit] NULL,
	[TransactionStatus] [int] NULL,
	[InitialResponseCode] [nvarchar](10) NULL,
	[InitialPaymentDate] [datetime2](7) NULL,
	[IntialResponseDecription] [nvarchar](100) NULL,
	[FinalResponseCode] [nvarchar](10) NULL,
	[FinalPaymentDate] [datetime2](7) NULL,
	[FinalResponseDecription] [nvarchar](100) NULL,
 CONSTRAINT [PK_OnlineReciept] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PendingEmail]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PendingEmail](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Subject] [varchar](500) NULL,
	[DueDate] [datetime] NOT NULL CONSTRAINT [DF_PendingEmail_DueDate]  DEFAULT (getdate()),
	[Body] [text] NULL,
	[From] [varchar](500) NULL,
	[To] [varchar](500) NULL,
	[Bcc] [varchar](500) NULL,
	[CC] [varchar](500) NULL,
	[ErrorMessage] [text] NULL,
	[IsBodyHtml] [bit] NULL CONSTRAINT [DF_PendingEmail_IsBodyHtml]  DEFAULT ((1)),
	[ReplyTo] [varchar](100) NULL,
	[Sender] [varchar](200) NULL,
	[Retries] [int] NULL CONSTRAINT [DF_PendingEmail_Retries]  DEFAULT ((0)),
	[Priority] [varchar](50) NULL,
	[ThrewException] [bit] NULL DEFAULT ((0)),
	[RetryCount] [int] NULL,
 CONSTRAINT [PK_PendingEmail] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PersonalDetailsStaging]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonalDetailsStaging](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[RegNo] [nvarchar](50) NULL,
	[Surname] [nvarchar](50) NULL,
	[OtherNames] [nvarchar](50) NULL,
	[ResAddress] [nvarchar](100) NULL,
	[OffAddress] [nvarchar](100) NULL,
	[PosAddress] [nvarchar](100) NULL,
	[Email] [nvarchar](100) NULL,
	[Phone] [nvarchar](15) NULL,
	[dob] [datetime2](7) NULL,
	[Occupation] [nvarchar](50) NULL,
	[ContribAmount] [decimal](18, 2) NULL,
	[ContribFreq] [nvarchar](10) NULL,
	[CommencementDate] [datetime2](7) NOT NULL,
	[Duration] [int] NULL,
	[Type] [int] NULL,
	[PolicyType] [int] NULL,
	[ApprovalStatus] [int] NULL,
	[IsSynched] [bit] NULL CONSTRAINT [DF_PersonalDetailsStaging_IsSynched]  DEFAULT ((0)),
	[DateCreated] [datetime2](7) NULL,
	[ApprovedBy] [bigint] NULL,
	[Location] [int] NULL,
 CONSTRAINT [PK_PersonalDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PolicyNoSerial]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PolicyNoSerial](
	[PolicyNo] [bigint] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Portlet]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Portlet](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[ImageUrl] [nvarchar](50) NULL,
	[Background] [nvarchar](50) NULL,
	[Order] [int] NULL,
 CONSTRAINT [PK_Portlet] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[QuotationNoSerial]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuotationNoSerial](
	[QuoteNo] [bigint] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ReceiptNo]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReceiptNo](
	[RctNo] [bigint] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Role]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](250) NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Tabs]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tabs](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[PortletId] [int] NULL,
	[icon] [nchar](10) NULL,
	[Controller] [nvarchar](50) NULL,
	[Action] [nvarchar](50) NULL,
	[Order] [int] NULL,
	[View] [nvarchar](50) NULL,
 CONSTRAINT [PK_Tabs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserRole]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRole](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[RoleId] [int] NULL,
	[UserId] [bigint] NULL,
 CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserSession]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserSession](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[IsDeleted] [bit] NULL,
	[DateCreated] [datetime2](7) NULL,
	[LastModifiedDate] [datetime2](7) NULL,
	[CustomerUserID] [bigint] NULL,
	[ExpiryDate] [datetime] NULL,
	[LastAccessed] [datetime] NULL,
	[LogoutDate] [datetime] NULL,
	[SessionStatus] [int] NULL,
	[AccessCount] [bigint] NULL,
	[Token] [nvarchar](50) NULL,
	[UserId] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[vwPolicyHistory]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwPolicyHistory]
AS
SELECT        dbo.fl_payhistory.policyno, dbo.fl_payhistory.receiptno, MAX(dbo.fl_payhistory.period) AS period, MAX(dbo.fl_payhistory.trandate) AS trandate, MAX(dbo.fl_payhistory.amount) AS amount, 
                         MAX(ISNULL(dbo.fl_payhistory.cumul_intr, 0.00)) AS cumul_intr, dbo.fl_policyinput.surname + ' ' + dbo.fl_policyinput.othername AS Name, dbo.fl_location.locdesc, dbo.fl_payhistory.doctype, 
                         MAX(ISNULL(dbo.fl_payhistory.cur_intr, 0.00)) AS cur_intr, ISNULL(dbo.fl_payhistory.gir, 0.00) AS gir
FROM            dbo.fl_payhistory INNER JOIN
                         dbo.fl_policyinput ON dbo.fl_payhistory.policyno = dbo.fl_policyinput.policyno INNER JOIN
                         dbo.fl_location ON dbo.fl_policyinput.location = dbo.fl_location.Id
WHERE        (ISNULL(dbo.fl_payhistory.gir, 0) = 0)
GROUP BY dbo.fl_payhistory.policyno, dbo.fl_payhistory.receiptno, dbo.fl_policyinput.surname, dbo.fl_policyinput.othername, dbo.fl_location.locdesc, dbo.fl_payhistory.doctype, dbo.fl_payhistory.cur_intr, 
                         dbo.fl_payhistory.gir

GO
/****** Object:  View [dbo].[vwPolicy]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwPolicy]
AS
SELECT        p.policyno, MAX(p.premium) AS premium, MAX(p.poltype) AS poltype, MAX(p.location) AS location, MAX(p.telephone) AS telephone, MAX(p.email) AS email, MAX(p.surname) AS surname, MAX(p.othername) 
                         AS othername, SUM(ISNULL(vph.amount, 0)) + SUM(ISNULL(vph.cumul_intr, 0)) AS balance, MAX(ISNULL(p.status, 1)) AS status, MAX(p.agentcode) AS agentcode, MAX(p.peradd) AS address, p.srn, 
                         dbo.fl_location.locdesc, a.agentname, MAX(p.accdate) AS accdate, p.title, p.exitdate
FROM            dbo.fl_policyinput AS p INNER JOIN
                         dbo.fl_location ON p.location = dbo.fl_location.Id LEFT OUTER JOIN
                         dbo.fl_agents AS a ON p.agentcode = a.agentcode LEFT OUTER JOIN
                         dbo.vwPolicyHistory AS vph ON p.policyno = vph.policyno
GROUP BY p.policyno, p.srn, dbo.fl_location.locdesc, a.agentname, p.title, p.exitdate

GO
/****** Object:  View [dbo].[vProduction]    Script Date: 12/20/2016 2:50:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vProduction]
AS
SELECT        vwp.policyno, vwp.agentname, vwp.agentcode, vwp.accdate, pi.receiptno, pi.chequeno, pi.totamt, pi.trandate, pi.amount, vwp.surname, vwp.othername, vwp.title, dbo.fl_translog.remark
FROM            dbo.vwPolicy AS vwp INNER JOIN
                         dbo.fl_payinput AS pi ON vwp.policyno = pi.policyno INNER JOIN
                         dbo.fl_translog ON pi.receiptno = dbo.fl_translog.receiptno

GO
SET IDENTITY_INSERT [dbo].[ac_costCenter] ON 

GO
INSERT [dbo].[ac_costCenter] ([Id], [Code], [Desc]) VALUES (1, N'LG', N'LAGOS')
GO
INSERT [dbo].[ac_costCenter] ([Id], [Code], [Desc]) VALUES (2, N'OG', N'OGUN')
GO
SET IDENTITY_INSERT [dbo].[ac_costCenter] OFF
GO
INSERT [dbo].[accchart] ([acctcode1], [acctcode2], [acctcode3], [acctcode4], [acctcode5], [acctcode6], [acctnumber], [description], [acctcode7], [oldnumber], [acctype], [acctsubtype], [address], [effdate], [ledgerpasswd], [ledgerpasswd2], [subcode], [blgroup1], [blgroup2], [blgroup3], [blgroup4], [blgroupdes1], [blgroupdes2], [blgroupdes3], [blgroupdes4], [blsum1], [blsum2], [blsum3], [blsum4], [blsumdesc1], [blsumdesc2], [blsumdesc3], [blsumdesc4], [cfgroup1], [cfgroup2], [cfgroup3], [cfgroup4], [cfgroupdes1], [cfgroupdes2], [cfgroupdes3], [cfgroupdes4], [cfsumdesc1], [cfsumdesc2], [cfsumdesc3], [cfsumdesc4], [createdby], [datecreated], [address1], [address2], [address3], [telephone], [email], [trade], [dateblocked]) VALUES (N'1', N'10', N'100', N'1000', N'10000', N'100000', N'100000-00001', N'ASSETS ON GENERATOR FOR DDG', NULL, N'', NULL, N'1', NULL, N'          ', NULL, NULL, N'00000', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'HICAD', CAST(N'2013-04-26 11:21:55.000' AS DateTime), N'', N'', N'', N'', N'', N'', NULL)
GO
INSERT [dbo].[accchart] ([acctcode1], [acctcode2], [acctcode3], [acctcode4], [acctcode5], [acctcode6], [acctnumber], [description], [acctcode7], [oldnumber], [acctype], [acctsubtype], [address], [effdate], [ledgerpasswd], [ledgerpasswd2], [subcode], [blgroup1], [blgroup2], [blgroup3], [blgroup4], [blgroupdes1], [blgroupdes2], [blgroupdes3], [blgroupdes4], [blsum1], [blsum2], [blsum3], [blsum4], [blsumdesc1], [blsumdesc2], [blsumdesc3], [blsumdesc4], [cfgroup1], [cfgroup2], [cfgroup3], [cfgroup4], [cfgroupdes1], [cfgroupdes2], [cfgroupdes3], [cfgroupdes4], [cfsumdesc1], [cfsumdesc2], [cfsumdesc3], [cfsumdesc4], [createdby], [datecreated], [address1], [address2], [address3], [telephone], [email], [trade], [dateblocked]) VALUES (N'1', N'11', N'111', N'1110', N'11100', N'111000', N'111000-00001', N'LAND', N'', N'0010101', N'', N'', N'', N'00001     ', NULL, NULL, N'00000', N'1111', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[accchart] ([acctcode1], [acctcode2], [acctcode3], [acctcode4], [acctcode5], [acctcode6], [acctnumber], [description], [acctcode7], [oldnumber], [acctype], [acctsubtype], [address], [effdate], [ledgerpasswd], [ledgerpasswd2], [subcode], [blgroup1], [blgroup2], [blgroup3], [blgroup4], [blgroupdes1], [blgroupdes2], [blgroupdes3], [blgroupdes4], [blsum1], [blsum2], [blsum3], [blsum4], [blsumdesc1], [blsumdesc2], [blsumdesc3], [blsumdesc4], [cfgroup1], [cfgroup2], [cfgroup3], [cfgroup4], [cfgroupdes1], [cfgroupdes2], [cfgroupdes3], [cfgroupdes4], [cfsumdesc1], [cfsumdesc2], [cfsumdesc3], [cfsumdesc4], [createdby], [datecreated], [address1], [address2], [address3], [telephone], [email], [trade], [dateblocked]) VALUES (N'1', N'11', N'111', N'1110', N'11100', N'111000', N'111000-00002', N'LAND2', N'', N'0010101A', N'', N'', N'', N'00002     ', NULL, NULL, N'00000', N'1111', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[accchart] ([acctcode1], [acctcode2], [acctcode3], [acctcode4], [acctcode5], [acctcode6], [acctnumber], [description], [acctcode7], [oldnumber], [acctype], [acctsubtype], [address], [effdate], [ledgerpasswd], [ledgerpasswd2], [subcode], [blgroup1], [blgroup2], [blgroup3], [blgroup4], [blgroupdes1], [blgroupdes2], [blgroupdes3], [blgroupdes4], [blsum1], [blsum2], [blsum3], [blsum4], [blsumdesc1], [blsumdesc2], [blsumdesc3], [blsumdesc4], [cfgroup1], [cfgroup2], [cfgroup3], [cfgroup4], [cfgroupdes1], [cfgroupdes2], [cfgroupdes3], [cfgroupdes4], [cfsumdesc1], [cfsumdesc2], [cfsumdesc3], [cfsumdesc4], [createdby], [datecreated], [address1], [address2], [address3], [telephone], [email], [trade], [dateblocked]) VALUES (N'1', N'11', N'111', N'1110', N'11100', N'111000', N'111000-00003', N'BUILDING', N'', N'0010102', N'', N'', N'', N'00003     ', NULL, NULL, N'00000', N'1111', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[accchart] ([acctcode1], [acctcode2], [acctcode3], [acctcode4], [acctcode5], [acctcode6], [acctnumber], [description], [acctcode7], [oldnumber], [acctype], [acctsubtype], [address], [effdate], [ledgerpasswd], [ledgerpasswd2], [subcode], [blgroup1], [blgroup2], [blgroup3], [blgroup4], [blgroupdes1], [blgroupdes2], [blgroupdes3], [blgroupdes4], [blsum1], [blsum2], [blsum3], [blsum4], [blsumdesc1], [blsumdesc2], [blsumdesc3], [blsumdesc4], [cfgroup1], [cfgroup2], [cfgroup3], [cfgroup4], [cfgroupdes1], [cfgroupdes2], [cfgroupdes3], [cfgroupdes4], [cfsumdesc1], [cfsumdesc2], [cfsumdesc3], [cfsumdesc4], [createdby], [datecreated], [address1], [address2], [address3], [telephone], [email], [trade], [dateblocked]) VALUES (N'1', N'11', N'111', N'1110', N'11100', N'111000', N'111000-00004', N'BUILDING 2', N'', N'0010102A', N'', N'', N'', N'00004     ', NULL, NULL, N'00000', N'1111', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[accchart] ([acctcode1], [acctcode2], [acctcode3], [acctcode4], [acctcode5], [acctcode6], [acctnumber], [description], [acctcode7], [oldnumber], [acctype], [acctsubtype], [address], [effdate], [ledgerpasswd], [ledgerpasswd2], [subcode], [blgroup1], [blgroup2], [blgroup3], [blgroup4], [blgroupdes1], [blgroupdes2], [blgroupdes3], [blgroupdes4], [blsum1], [blsum2], [blsum3], [blsum4], [blsumdesc1], [blsumdesc2], [blsumdesc3], [blsumdesc4], [cfgroup1], [cfgroup2], [cfgroup3], [cfgroup4], [cfgroupdes1], [cfgroupdes2], [cfgroupdes3], [cfgroupdes4], [cfsumdesc1], [cfsumdesc2], [cfsumdesc3], [cfsumdesc4], [createdby], [datecreated], [address1], [address2], [address3], [telephone], [email], [trade], [dateblocked]) VALUES (N'1', N'11', N'111', N'1110', N'11100', N'111000', N'111000-00005', N'BUILDING 3', N'', N'0010102B', N'', N'', N'', N'00005     ', NULL, NULL, N'00000', N'1111', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[accchart] ([acctcode1], [acctcode2], [acctcode3], [acctcode4], [acctcode5], [acctcode6], [acctnumber], [description], [acctcode7], [oldnumber], [acctype], [acctsubtype], [address], [effdate], [ledgerpasswd], [ledgerpasswd2], [subcode], [blgroup1], [blgroup2], [blgroup3], [blgroup4], [blgroupdes1], [blgroupdes2], [blgroupdes3], [blgroupdes4], [blsum1], [blsum2], [blsum3], [blsum4], [blsumdesc1], [blsumdesc2], [blsumdesc3], [blsumdesc4], [cfgroup1], [cfgroup2], [cfgroup3], [cfgroup4], [cfgroupdes1], [cfgroupdes2], [cfgroupdes3], [cfgroupdes4], [cfsumdesc1], [cfsumdesc2], [cfsumdesc3], [cfsumdesc4], [createdby], [datecreated], [address1], [address2], [address3], [telephone], [email], [trade], [dateblocked]) VALUES (N'1', N'11', N'111', N'1110', N'11100', N'111000', N'111000-00006', N'ABUJA LIAISON OFFICE', N'', N'0010102C', N'', N'', N'', N'00006     ', NULL, NULL, N'00000', N'1111', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[accchart] ([acctcode1], [acctcode2], [acctcode3], [acctcode4], [acctcode5], [acctcode6], [acctnumber], [description], [acctcode7], [oldnumber], [acctype], [acctsubtype], [address], [effdate], [ledgerpasswd], [ledgerpasswd2], [subcode], [blgroup1], [blgroup2], [blgroup3], [blgroup4], [blgroupdes1], [blgroupdes2], [blgroupdes3], [blgroupdes4], [blsum1], [blsum2], [blsum3], [blsum4], [blsumdesc1], [blsumdesc2], [blsumdesc3], [blsumdesc4], [cfgroup1], [cfgroup2], [cfgroup3], [cfgroup4], [cfgroupdes1], [cfgroupdes2], [cfgroupdes3], [cfgroupdes4], [cfsumdesc1], [cfsumdesc2], [cfsumdesc3], [cfsumdesc4], [createdby], [datecreated], [address1], [address2], [address3], [telephone], [email], [trade], [dateblocked]) VALUES (N'1', N'11', N'113', N'1130', N'11300', N'113000', N'113000-00001', N'OFFICE FURNITURE', N'', N'0010201', N'', N'', N'', N'00001     ', NULL, NULL, N'00000', N'1111', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[accchart] ([acctcode1], [acctcode2], [acctcode3], [acctcode4], [acctcode5], [acctcode6], [acctnumber], [description], [acctcode7], [oldnumber], [acctype], [acctsubtype], [address], [effdate], [ledgerpasswd], [ledgerpasswd2], [subcode], [blgroup1], [blgroup2], [blgroup3], [blgroup4], [blgroupdes1], [blgroupdes2], [blgroupdes3], [blgroupdes4], [blsum1], [blsum2], [blsum3], [blsum4], [blsumdesc1], [blsumdesc2], [blsumdesc3], [blsumdesc4], [cfgroup1], [cfgroup2], [cfgroup3], [cfgroup4], [cfgroupdes1], [cfgroupdes2], [cfgroupdes3], [cfgroupdes4], [cfsumdesc1], [cfsumdesc2], [cfsumdesc3], [cfsumdesc4], [createdby], [datecreated], [address1], [address2], [address3], [telephone], [email], [trade], [dateblocked]) VALUES (N'1', N'11', N'113', N'1130', N'11300', N'113000', N'113000-00002', N'OFFICE FURNITURE-STUDY CENTRE', N'', N'0010201A', N'', N'', N'', N'00002     ', NULL, NULL, N'00000', N'1111', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[accchart] ([acctcode1], [acctcode2], [acctcode3], [acctcode4], [acctcode5], [acctcode6], [acctnumber], [description], [acctcode7], [oldnumber], [acctype], [acctsubtype], [address], [effdate], [ledgerpasswd], [ledgerpasswd2], [subcode], [blgroup1], [blgroup2], [blgroup3], [blgroup4], [blgroupdes1], [blgroupdes2], [blgroupdes3], [blgroupdes4], [blsum1], [blsum2], [blsum3], [blsum4], [blsumdesc1], [blsumdesc2], [blsumdesc3], [blsumdesc4], [cfgroup1], [cfgroup2], [cfgroup3], [cfgroup4], [cfgroupdes1], [cfgroupdes2], [cfgroupdes3], [cfgroupdes4], [cfsumdesc1], [cfsumdesc2], [cfsumdesc3], [cfsumdesc4], [createdby], [datecreated], [address1], [address2], [address3], [telephone], [email], [trade], [dateblocked]) VALUES (N'1', N'11', N'113', N'1130', N'11300', N'113000', N'113000-00003', N'OFFICE FURNITURE-KADUNA S/CETR', N'', N'0010201B', N'', N'', N'', N'00003     ', NULL, NULL, N'00000', N'1111', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[accchart] ([acctcode1], [acctcode2], [acctcode3], [acctcode4], [acctcode5], [acctcode6], [acctnumber], [description], [acctcode7], [oldnumber], [acctype], [acctsubtype], [address], [effdate], [ledgerpasswd], [ledgerpasswd2], [subcode], [blgroup1], [blgroup2], [blgroup3], [blgroup4], [blgroupdes1], [blgroupdes2], [blgroupdes3], [blgroupdes4], [blsum1], [blsum2], [blsum3], [blsum4], [blsumdesc1], [blsumdesc2], [blsumdesc3], [blsumdesc4], [cfgroup1], [cfgroup2], [cfgroup3], [cfgroup4], [cfgroupdes1], [cfgroupdes2], [cfgroupdes3], [cfgroupdes4], [cfsumdesc1], [cfsumdesc2], [cfsumdesc3], [cfsumdesc4], [createdby], [datecreated], [address1], [address2], [address3], [telephone], [email], [trade], [dateblocked]) VALUES (N'1', N'11', N'113', N'1130', N'11300', N'113000', N'113000-00004', N'OFFICE FURNITURE-P/H S/CENTRE', N'', N'0010201C', N'', N'', N'', N'00004     ', NULL, NULL, N'00000', N'1111', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[ClaimRequest] ON 

GO
INSERT [dbo].[ClaimRequest] ([Id], [ClaimNo], [PolicyNo], [Amount], [ClaimType], [Status], [DateCreated], [EffectiveDate], [Interest], [ApprovedAmount], [FundAmount]) VALUES (10002, NULL, N'PPP/ABK/16/00001', CAST(3000.00 AS Decimal(18, 2)), 0, 4, CAST(N'2016-11-18 12:10:37.6694564' AS DateTime2), CAST(N'2016-11-19 00:00:00.0000000' AS DateTime2), NULL, NULL, NULL)
GO
INSERT [dbo].[ClaimRequest] ([Id], [ClaimNo], [PolicyNo], [Amount], [ClaimType], [Status], [DateCreated], [EffectiveDate], [Interest], [ApprovedAmount], [FundAmount]) VALUES (10003, NULL, N'PPP/ABK/16/00001', CAST(300000.00 AS Decimal(18, 2)), 0, 2, CAST(N'2016-11-18 12:59:32.7413693' AS DateTime2), CAST(N'2016-12-01 00:00:00.0000000' AS DateTime2), NULL, NULL, NULL)
GO
INSERT [dbo].[ClaimRequest] ([Id], [ClaimNo], [PolicyNo], [Amount], [ClaimType], [Status], [DateCreated], [EffectiveDate], [Interest], [ApprovedAmount], [FundAmount]) VALUES (10004, N'PPP16112700001', N'PPP/ABK/16/00001', CAST(30000.00 AS Decimal(18, 2)), 0, 5, CAST(N'2016-11-18 13:43:20.8094432' AS DateTime2), CAST(N'2016-12-31 00:00:00.0000000' AS DateTime2), CAST(5.00 AS Decimal(18, 2)), CAST(30000.00 AS Decimal(18, 2)), CAST(56644.39 AS Decimal(18, 2)))
GO
INSERT [dbo].[ClaimRequest] ([Id], [ClaimNo], [PolicyNo], [Amount], [ClaimType], [Status], [DateCreated], [EffectiveDate], [Interest], [ApprovedAmount], [FundAmount]) VALUES (10005, NULL, N'PPP/ABK/16/00001', CAST(400000.00 AS Decimal(18, 2)), 0, 3, CAST(N'2016-11-26 14:46:41.6336371' AS DateTime2), CAST(N'2016-11-26 00:00:00.0000000' AS DateTime2), CAST(5.50 AS Decimal(18, 2)), NULL, CAST(42415.16 AS Decimal(18, 2)))
GO
INSERT [dbo].[ClaimRequest] ([Id], [ClaimNo], [PolicyNo], [Amount], [ClaimType], [Status], [DateCreated], [EffectiveDate], [Interest], [ApprovedAmount], [FundAmount]) VALUES (10006, NULL, N'PPP/IBD/16/00008', CAST(500000.00 AS Decimal(18, 2)), 0, 0, CAST(N'2016-11-26 15:02:41.4951613' AS DateTime2), CAST(N'2016-11-26 00:00:00.0000000' AS DateTime2), NULL, NULL, NULL)
GO
INSERT [dbo].[ClaimRequest] ([Id], [ClaimNo], [PolicyNo], [Amount], [ClaimType], [Status], [DateCreated], [EffectiveDate], [Interest], [ApprovedAmount], [FundAmount]) VALUES (10007, NULL, N'PPP/ILR/16/00009', CAST(300000.00 AS Decimal(18, 2)), 0, 2, CAST(N'2016-11-27 22:02:28.1344961' AS DateTime2), CAST(N'2016-11-30 00:00:00.0000000' AS DateTime2), CAST(5.00 AS Decimal(18, 2)), NULL, CAST(0.00 AS Decimal(18, 2)))
GO
INSERT [dbo].[ClaimRequest] ([Id], [ClaimNo], [PolicyNo], [Amount], [ClaimType], [Status], [DateCreated], [EffectiveDate], [Interest], [ApprovedAmount], [FundAmount]) VALUES (10008, N'PPP16120300001', N'PPP/ABK/16/00001', CAST(300000.00 AS Decimal(18, 2)), 0, 5, CAST(N'2016-11-27 22:03:15.5941342' AS DateTime2), CAST(N'2016-11-30 00:00:00.0000000' AS DateTime2), CAST(5.00 AS Decimal(18, 2)), CAST(25000.00 AS Decimal(18, 2)), CAST(56406.58 AS Decimal(18, 2)))
GO
INSERT [dbo].[ClaimRequest] ([Id], [ClaimNo], [PolicyNo], [Amount], [ClaimType], [Status], [DateCreated], [EffectiveDate], [Interest], [ApprovedAmount], [FundAmount]) VALUES (10009, N'PPP16120300002', N'PPP/ABK/16/00001', CAST(0.00 AS Decimal(18, 2)), 1, 4, CAST(N'2016-12-03 15:12:23.7996717' AS DateTime2), CAST(N'2016-12-03 00:00:00.0000000' AS DateTime2), CAST(5.00 AS Decimal(18, 2)), CAST(1415.01 AS Decimal(18, 2)), CAST(1415.01 AS Decimal(18, 2)))
GO
SET IDENTITY_INSERT [dbo].[ClaimRequest] OFF
GO
SET IDENTITY_INSERT [dbo].[CustomerPolicies] ON 

GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (3, 10, N'PPP//16/5')
GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (4, 11, N'PPP//16/6')
GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (5, 12, N'PPP//16/7')
GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (6, 12, N'PPP/ABK/16/1')
GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (7, 14, N'PPP/ABK/16/00001')
GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (8, 15, N'PPP/LAG/16/00002')
GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (9, 16, N'PPP/LAG/16/00003')
GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (10, 17, N'PPP/IBD/16/00004')
GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (11, 18, N'PPP/ILR/16/00005')
GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (12, 19, N'PPP/IBD/16/00006')
GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (10010, 10017, N'PPP/ILR/16/00007')
GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (10020, 14, N'PPP/IBD/16/00008')
GO
INSERT [dbo].[CustomerPolicies] ([Id], [CustomerUserId], [Policyno]) VALUES (20011, 12, N'PPP/ILR/16/00009')
GO
SET IDENTITY_INSERT [dbo].[CustomerPolicies] OFF
GO
SET IDENTITY_INSERT [dbo].[CustomerUser] ON 

GO
INSERT [dbo].[CustomerUser] ([Id], [username], [password], [Name], [createdby], [datecreated], [passworddate], [modifydate], [modifyby], [lastLoginDate], [firstLoginDate], [status], [email], [phone], [IsDeleted]) VALUES (10, N'PPP//16/5', N'4CFEC54BB37148E81B36DB81EB9258F1', N'Owode Tope', NULL, CAST(N'2016-08-05 00:10:05.9567177' AS DateTime2), CAST(N'2016-10-31 21:05:27.2577368' AS DateTime2), CAST(N'2016-10-31 21:05:27.2577368' AS DateTime2), NULL, CAST(N'2016-10-17 18:15:06.207' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0, N'towode@parkwayprojects.com', N'08076545678', 0)
GO
INSERT [dbo].[CustomerUser] ([Id], [username], [password], [Name], [createdby], [datecreated], [passworddate], [modifydate], [modifyby], [lastLoginDate], [firstLoginDate], [status], [email], [phone], [IsDeleted]) VALUES (11, N'PPP//16/6', N'2B8CA7DAEEAE8427D3DA0C6BC8EE4863', N'Owode Tope', NULL, CAST(N'2016-08-05 00:15:50.1424238' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), 1, N'towode@parkwayprojects.com', N'08076545678', 0)
GO
INSERT [dbo].[CustomerUser] ([Id], [username], [password], [Name], [createdby], [datecreated], [passworddate], [modifydate], [modifyby], [lastLoginDate], [firstLoginDate], [status], [email], [phone], [IsDeleted]) VALUES (12, N'PPP//16/7', N'84E98F9F900B8B9159761EFF101E75BD', N'Owode Topw', NULL, CAST(N'2016-08-08 13:57:43.7033678' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), 1, N'towode@parkwayprojects.com', N'08076545678', 0)
GO
INSERT [dbo].[CustomerUser] ([Id], [username], [password], [Name], [createdby], [datecreated], [passworddate], [modifydate], [modifyby], [lastLoginDate], [firstLoginDate], [status], [email], [phone], [IsDeleted]) VALUES (13, N'PPP/ABK/16/1', N'DEDFDB7AF9F963A766B5635FFA183443', N'Owode Topw', NULL, CAST(N'2016-09-08 00:19:34.5085474' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0, N'towode@parkwayprojects.com', N'08076545678', 1)
GO
INSERT [dbo].[CustomerUser] ([Id], [username], [password], [Name], [createdby], [datecreated], [passworddate], [modifydate], [modifyby], [lastLoginDate], [firstLoginDate], [status], [email], [phone], [IsDeleted]) VALUES (14, N'PPP/ABK/16/00001', N'7C6A180B36896A0A8C02787EEAFB0E4C', N'Owode Topw', NULL, CAST(N'2016-09-08 00:28:49.5985348' AS DateTime2), CAST(N'2016-12-18 10:43:21.1803974' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), NULL, CAST(N'2016-11-27 14:22:26.307' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), 1, N'towode@parkwayprojects.com', N'08076545678', 0)
GO
INSERT [dbo].[CustomerUser] ([Id], [username], [password], [Name], [createdby], [datecreated], [passworddate], [modifydate], [modifyby], [lastLoginDate], [firstLoginDate], [status], [email], [phone], [IsDeleted]) VALUES (15, N'PPP/LAG/16/00002', N'47A4BD9BE34F4DC52A13FC4EB5BC9197', N'Owode Tope', NULL, CAST(N'2016-09-21 23:01:15.5339429' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0, N'towode@parkwayprojects.com', N'98765432', NULL)
GO
INSERT [dbo].[CustomerUser] ([Id], [username], [password], [Name], [createdby], [datecreated], [passworddate], [modifydate], [modifyby], [lastLoginDate], [firstLoginDate], [status], [email], [phone], [IsDeleted]) VALUES (16, N'PPP/LAG/16/00003', N'5E969904C3C2D89CC0341586129FD16C', N'Owode Tope', NULL, CAST(N'2016-09-21 23:01:16.2556187' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0, N'towode@parkwayprojects.com', N'98765432', NULL)
GO
INSERT [dbo].[CustomerUser] ([Id], [username], [password], [Name], [createdby], [datecreated], [passworddate], [modifydate], [modifyby], [lastLoginDate], [firstLoginDate], [status], [email], [phone], [IsDeleted]) VALUES (17, N'PPP/IBD/16/00004', N'C3DF3531CD0153997F60D4BA33018FCB', N'owode Tope', NULL, CAST(N'2016-09-25 12:11:24.1737320' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0, N'towode@parkwayprojects.com', N'09876543', 0)
GO
INSERT [dbo].[CustomerUser] ([Id], [username], [password], [Name], [createdby], [datecreated], [passworddate], [modifydate], [modifyby], [lastLoginDate], [firstLoginDate], [status], [email], [phone], [IsDeleted]) VALUES (18, N'PPP/ILR/16/00005', N'DB84770756AB3CD1DBBFC2332A9C4689', N'oowde Tope', NULL, CAST(N'2016-09-25 12:11:24.7602831' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0, N'towode@parkwayprojects.com', N'987654679', 0)
GO
INSERT [dbo].[CustomerUser] ([Id], [username], [password], [Name], [createdby], [datecreated], [passworddate], [modifydate], [modifyby], [lastLoginDate], [firstLoginDate], [status], [email], [phone], [IsDeleted]) VALUES (19, N'PPP/IBD/16/00006', N'C7189B0047785BC830A988DF4372C739', N'sjddjhdj jh', NULL, CAST(N'2016-09-25 12:11:24.7843398' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0, N'towode@parkwayprojects.com', N'8765456789', 0)
GO
INSERT [dbo].[CustomerUser] ([Id], [username], [password], [Name], [createdby], [datecreated], [passworddate], [modifydate], [modifyby], [lastLoginDate], [firstLoginDate], [status], [email], [phone], [IsDeleted]) VALUES (10017, N'PPP/ILR/16/00007', N'6CB75F652A9B52798EB6CF2201057C73', N'kckjckcjk KJKDJDKDJ', NULL, CAST(N'2016-10-13 23:41:16.7164351' AS DateTime2), CAST(N'2016-11-15 15:37:15.9684461' AS DateTime2), CAST(N'1900-01-01 00:00:00.0000000' AS DateTime2), NULL, CAST(N'2016-10-18 21:16:49.807' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), 1, N'towode@parkwayprojects.com', N'0987654567890', 0)
GO
SET IDENTITY_INSERT [dbo].[CustomerUser] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_agents] ON 

GO
INSERT [dbo].[fl_agents] ([Id], [agentcode], [agentname], [locationId], [agenttype], [CommissionRate], [createdBy], [datecreated], [IsDeleted], [datemodified], [modifiedby], [agentaddr], [agentphone]) VALUES (1, N'123', N'Owode', 1, 1, CAST(7.50 AS Decimal(18, 2)), NULL, CAST(N'2016-10-02 00:00:00.0000000' AS DateTime2), 0, NULL, NULL, N'Yaba', NULL)
GO
INSERT [dbo].[fl_agents] ([Id], [agentcode], [agentname], [locationId], [agenttype], [CommissionRate], [createdBy], [datecreated], [IsDeleted], [datemodified], [modifiedby], [agentaddr], [agentphone]) VALUES (2, N'098', N'Temmy', 2, 0, CAST(9.00 AS Decimal(18, 2)), NULL, CAST(N'2016-09-22 00:00:00.0000000' AS DateTime2), 1, NULL, NULL, N'ddkjdkd', NULL)
GO
INSERT [dbo].[fl_agents] ([Id], [agentcode], [agentname], [locationId], [agenttype], [CommissionRate], [createdBy], [datecreated], [IsDeleted], [datemodified], [modifiedby], [agentaddr], [agentphone]) VALUES (3, N'499095', N'Temmy', 1, 1, CAST(7.50 AS Decimal(18, 2)), NULL, CAST(N'2016-11-14 00:00:00.0000000' AS DateTime2), 0, NULL, NULL, N'dkdkddlkdlkd', N'08082468616')
GO
INSERT [dbo].[fl_agents] ([Id], [agentcode], [agentname], [locationId], [agenttype], [CommissionRate], [createdBy], [datecreated], [IsDeleted], [datemodified], [modifiedby], [agentaddr], [agentphone]) VALUES (10003, N'0004', N'Owode Tope', 1, 1, CAST(7.00 AS Decimal(18, 2)), NULL, CAST(N'2016-11-23 00:00:00.0000000' AS DateTime2), 0, NULL, NULL, N'Lagos', N'09083783738')
GO
SET IDENTITY_INSERT [dbo].[fl_agents] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_grouptype] ON 

GO
INSERT [dbo].[fl_grouptype] ([Id], [grpcode], [grpname], [Address], [accountcode], [grpclass], [IsDeleted], [DateCreated], [Createdby]) VALUES (1, N'ddmdnmd', N'Owode Tope', N']][;l;,mvncvxcxz\', N'111000-00001', N'0;1;2;4;5;', 1, CAST(N'2016-09-22 00:00:00.0000000' AS DateTime2), NULL)
GO
INSERT [dbo].[fl_grouptype] ([Id], [grpcode], [grpname], [Address], [accountcode], [grpclass], [IsDeleted], [DateCreated], [Createdby]) VALUES (2, N'djkjfkfj', N'ckjkfjfk', N'kdjkjfkfjk', N'111000-00001', N'', 1, CAST(N'2016-09-19 00:00:00.0000000' AS DateTime2), NULL)
GO
INSERT [dbo].[fl_grouptype] ([Id], [grpcode], [grpname], [Address], [accountcode], [grpclass], [IsDeleted], [DateCreated], [Createdby]) VALUES (5, N'Union', N'kdjkdjdkj', N'dkjkdjkdjdk', N'111000-00002', N'1;2;', 0, CAST(N'2016-10-02 00:00:00.0000000' AS DateTime2), NULL)
GO
SET IDENTITY_INSERT [dbo].[fl_grouptype] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_location] ON 

GO
INSERT [dbo].[fl_location] ([Id], [locdesc], [locstate], [loccode], [datecreated], [createdby], [datemodified], [modifiedby], [Isdeleted]) VALUES (2, N'Lagos', N'Lagos', N'LAG', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_location] ([Id], [locdesc], [locstate], [loccode], [datecreated], [createdby], [datemodified], [modifiedby], [Isdeleted]) VALUES (3, N'Abeokuta', N'Ogun', N'ABK', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_location] ([Id], [locdesc], [locstate], [loccode], [datecreated], [createdby], [datemodified], [modifiedby], [Isdeleted]) VALUES (4, N'ilorin', N'Kwara', N'ILR', CAST(N'2016-09-24 00:00:00.0000000' AS DateTime2), NULL, NULL, NULL, 0)
GO
INSERT [dbo].[fl_location] ([Id], [locdesc], [locstate], [loccode], [datecreated], [createdby], [datemodified], [modifiedby], [Isdeleted]) VALUES (5, N'lllll', N'lllll', N'llll', CAST(N'2016-09-08 00:00:00.0000000' AS DateTime2), NULL, NULL, NULL, 1)
GO
INSERT [dbo].[fl_location] ([Id], [locdesc], [locstate], [loccode], [datecreated], [createdby], [datemodified], [modifiedby], [Isdeleted]) VALUES (6, N'IBADAN', N'Oyo', N'IBD', CAST(N'2016-09-24 00:00:00.0000000' AS DateTime2), NULL, NULL, NULL, 0)
GO
SET IDENTITY_INSERT [dbo].[fl_location] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_password] ON 

GO
INSERT [dbo].[fl_password] ([Id], [userid], [userpassword], [Name], [userdept], [createdby], [datecreated], [expirydate], [passworddate], [Deleteddate], [Deletedby], [modifydate], [modifyby], [lastlogindate], [status], [branch], [mobile], [email]) VALUES (1, N'owode', N'7C6A180B36896A0A8C02787EEAFB0E4C', N'Owode', N'Finance', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2016-12-12 15:21:00.537' AS DateTime), 1, 0, NULL, NULL)
GO
INSERT [dbo].[fl_password] ([Id], [userid], [userpassword], [Name], [userdept], [createdby], [datecreated], [expirydate], [passworddate], [Deleteddate], [Deletedby], [modifydate], [modifyby], [lastlogindate], [status], [branch], [mobile], [email]) VALUES (2, N'underwriter', N'6CB75F652A9B52798EB6CF2201057C73', N'Test Underwriter', NULL, NULL, CAST(N'2016-10-02 00:00:00.000' AS DateTime), NULL, CAST(N'2016-11-01 00:00:00.000' AS DateTime), NULL, NULL, NULL, NULL, NULL, 1, 0, NULL, NULL)
GO
INSERT [dbo].[fl_password] ([Id], [userid], [userpassword], [Name], [userdept], [createdby], [datecreated], [expirydate], [passworddate], [Deleteddate], [Deletedby], [modifydate], [modifyby], [lastlogindate], [status], [branch], [mobile], [email]) VALUES (5, N'agent', N'6CB75F652A9B52798EB6CF2201057C73', N'Test agent', NULL, NULL, CAST(N'2016-10-02 00:00:00.000' AS DateTime), NULL, CAST(N'2016-12-16 16:17:18.497' AS DateTime), NULL, NULL, CAST(N'2016-10-31 21:05:48.520' AS DateTime), NULL, CAST(N'2016-11-16 16:17:30.277' AS DateTime), 1, 0, N'08082468616', N'towode@parkwayprojects.com')
GO
INSERT [dbo].[fl_password] ([Id], [userid], [userpassword], [Name], [userdept], [createdby], [datecreated], [expirydate], [passworddate], [Deleteddate], [Deletedby], [modifydate], [modifyby], [lastlogindate], [status], [branch], [mobile], [email]) VALUES (10002, N'CHIEF', N'7C6A180B36896A0A8C02787EEAFB0E4C', N'Agunbiade', N'Admin', NULL, CAST(N'2016-11-26 00:00:00.000' AS DateTime), NULL, CAST(N'2016-12-26 12:26:29.223' AS DateTime), NULL, NULL, CAST(N'2016-11-26 12:25:36.370' AS DateTime), NULL, CAST(N'2016-11-26 12:26:39.530' AS DateTime), 1, 0, N'08082468616', N'chief@hicadsystemsltd.com')
GO
SET IDENTITY_INSERT [dbo].[fl_password] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_payclaim] ON 

GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (1, N'PPP/ABK/16/00001', N'16PPP00000001', N'201609', NULL, NULL, NULL, CAST(N'2016-09-20 00:45:00' AS SmallDateTime), CAST(N'2016-09-20 00:45:00' AS SmallDateTime), 30000.0000, NULL, NULL, NULL, NULL, N'', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (2, N'PPP/ABK/16/00001', N'PPP16092400001', N'201609', NULL, NULL, NULL, CAST(N'2016-09-24 18:28:00' AS SmallDateTime), CAST(N'2016-09-24 18:28:00' AS SmallDateTime), 3000.0000, NULL, NULL, NULL, NULL, N'', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (3, N'PPP/ABK/16/00001', N'PPP16092400002', N'201609', NULL, NULL, NULL, CAST(N'2016-09-24 20:10:00' AS SmallDateTime), CAST(N'2016-09-24 20:10:00' AS SmallDateTime), 9000.0000, NULL, NULL, NULL, NULL, N'', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (4, N'PPP/ABK/16/00001', N'16PPP00000001', N'201609', NULL, NULL, NULL, CAST(N'2016-09-20 00:45:00' AS SmallDateTime), CAST(N'2016-09-20 00:45:00' AS SmallDateTime), 30000.0000, NULL, NULL, NULL, NULL, N'', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (5, N'PPP/ABK/16/00001', N'PPP16092400001', N'201609', NULL, NULL, NULL, CAST(N'2016-09-24 18:28:00' AS SmallDateTime), CAST(N'2016-09-24 18:28:00' AS SmallDateTime), 3000.0000, NULL, NULL, NULL, NULL, N'', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (6, N'PPP/ABK/16/00001', N'PPP16092400005', N'201609', NULL, NULL, N'PPP', CAST(N'2016-09-24 22:09:00' AS SmallDateTime), CAST(N'2016-09-24 22:09:00' AS SmallDateTime), 10000.0000, NULL, NULL, NULL, NULL, N'', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (7, N'PPP/ABK/16/00001', N'PPP16092400002', N'201609', NULL, NULL, NULL, CAST(N'2016-09-24 20:10:00' AS SmallDateTime), CAST(N'2016-09-24 20:10:00' AS SmallDateTime), 9000.0000, NULL, NULL, NULL, NULL, N'', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (8, N'PPP/ABK/16/00001', N'PPP16092400005R', N'201609', NULL, NULL, NULL, CAST(N'2016-09-24 22:12:00' AS SmallDateTime), CAST(N'2016-09-24 22:12:00' AS SmallDateTime), -10000.0000, NULL, NULL, NULL, NULL, N'', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (9, N'PPP/ABK/16/00001', N'PPP16112600001', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-26 15:24:00' AS SmallDateTime), CAST(N'2016-11-26 15:24:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, N'PaymentVoucher', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (10, N'PPP/ABK/16/00001', N'PPP16112600002', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-26 15:30:00' AS SmallDateTime), CAST(N'2016-11-26 15:30:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, N'Reciept', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (11, N'PPP/ABK/16/00001', N'PPP16112600003', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-26 16:28:00' AS SmallDateTime), CAST(N'2016-11-26 16:28:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, N'Reciept', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (12, N'PPP/ABK/16/00001', N'PPP16112600004', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-26 16:29:00' AS SmallDateTime), CAST(N'2016-11-26 16:29:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, N'Reciept', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (13, N'PPP/ABK/16/00001', N'PPP16112600005', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-26 16:33:00' AS SmallDateTime), CAST(N'2016-11-26 16:33:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, N'Reciept', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (14, N'PPP/ABK/16/00001', N'PPP16112600006', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-26 16:40:00' AS SmallDateTime), CAST(N'2016-11-26 16:40:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, N'Reciept', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (15, N'PPP/ABK/16/00001', N'PPP16112700001', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-27 12:36:00' AS SmallDateTime), CAST(N'2016-11-27 12:36:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, N'Reciept', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (16, N'PPP/ABK/16/00001', N'PPP16112900001', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-29 00:14:00' AS SmallDateTime), CAST(N'2016-11-29 00:14:00' AS SmallDateTime), -30000.0000, NULL, NULL, NULL, NULL, N'PaymentVoucher', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (17, N'PPP/ABK/16/00001', N'PPP16120300001', N'201612', NULL, NULL, N'PPP', CAST(N'2016-12-03 12:41:00' AS SmallDateTime), CAST(N'2016-12-03 12:41:00' AS SmallDateTime), -25000.0000, NULL, NULL, NULL, NULL, N'PaymentVoucher', NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payclaim] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (18, N'PPP/ABK/16/00001', N'PPP16120300002', N'201612', NULL, NULL, N'PPP', CAST(N'2016-12-03 15:42:00' AS SmallDateTime), CAST(N'2016-12-03 15:42:00' AS SmallDateTime), -1415.0100, NULL, NULL, NULL, NULL, N'PaymentVoucher', NULL, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[fl_payclaim] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_payhistory] ON 

GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (1, N'PPP/ABK/16/00001', N'16PPP00000001', N'201609', NULL, NULL, NULL, CAST(N'2016-09-20 00:45:00' AS SmallDateTime), CAST(N'2016-09-20 00:45:00' AS SmallDateTime), 30000.0000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (2, N'PPP/ABK/16/00001', N'PPP16092400001', N'201609', NULL, NULL, NULL, CAST(N'2016-09-24 18:28:00' AS SmallDateTime), CAST(N'2016-09-24 18:28:00' AS SmallDateTime), 3000.0000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (3, N'PPP/ABK/16/00001', N'PPP16092400002', N'201609', NULL, NULL, NULL, CAST(N'2016-09-24 20:10:00' AS SmallDateTime), CAST(N'2016-09-24 20:10:00' AS SmallDateTime), 9000.0000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (4, N'PPP/ABK/16/00001', N'16PPP00000001', N'201609', NULL, NULL, NULL, CAST(N'2016-09-20 00:45:00' AS SmallDateTime), CAST(N'2016-09-20 00:45:00' AS SmallDateTime), 30000.0000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (5, N'PPP/ABK/16/00001', N'PPP16092400001', N'201609', NULL, NULL, NULL, CAST(N'2016-09-24 18:28:00' AS SmallDateTime), CAST(N'2016-09-24 18:28:00' AS SmallDateTime), 3000.0000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (6, N'PPP/ABK/16/00001', N'PPP16092400005', N'201609', NULL, NULL, N'PPP', CAST(N'2016-09-24 22:09:00' AS SmallDateTime), CAST(N'2016-09-24 22:09:00' AS SmallDateTime), 10000.0000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (7, N'PPP/ABK/16/00001', N'PPP16092400002', N'201609', NULL, NULL, NULL, CAST(N'2016-09-24 20:10:00' AS SmallDateTime), CAST(N'2016-09-24 20:10:00' AS SmallDateTime), 9000.0000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (8, N'PPP/ABK/16/00001', N'PPP16092400005R', N'201609', NULL, NULL, NULL, CAST(N'2016-09-24 22:12:00' AS SmallDateTime), CAST(N'2016-09-24 22:12:00' AS SmallDateTime), -10000.0000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (9, N'PPP/ABK/16/00001', N'PPP16112600001', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-26 15:24:00' AS SmallDateTime), CAST(N'2016-11-26 15:24:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (10, N'PPP/ABK/16/00001', N'PPP16112600002', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-26 15:30:00' AS SmallDateTime), CAST(N'2016-11-26 15:30:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (11, N'PPP/ABK/16/00001', N'PPP16112600003', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-26 16:28:00' AS SmallDateTime), CAST(N'2016-11-26 16:28:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (12, N'PPP/ABK/16/00001', N'PPP16112600004', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-26 16:29:00' AS SmallDateTime), CAST(N'2016-11-26 16:29:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (13, N'PPP/ABK/16/00001', N'PPP16112600005', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-26 16:33:00' AS SmallDateTime), CAST(N'2016-11-26 16:33:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (14, N'PPP/ABK/16/00001', N'PPP16112600006', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-26 16:40:00' AS SmallDateTime), CAST(N'2016-11-26 16:40:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (10009, N'PPP/ABK/16/00001', N'PPP16112700001', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-27 12:36:00' AS SmallDateTime), CAST(N'2016-11-27 12:36:00' AS SmallDateTime), 2000.0000, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (10010, N'PPP/ABK/16/00001', N'PPP16112900001', N'201611', NULL, NULL, N'PPP', CAST(N'2016-11-29 00:14:00' AS SmallDateTime), CAST(N'2016-11-29 00:14:00' AS SmallDateTime), -30000.0000, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (10011, N'PPP/ABK/16/00001', N'PPP16120300001', N'201612', NULL, NULL, N'PPP', CAST(N'2016-12-03 12:41:00' AS SmallDateTime), CAST(N'2016-12-03 12:41:00' AS SmallDateTime), -25000.0000, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (10015, N'PPP/ABK/16/00001', N'PPP16120300002', N'201612', NULL, NULL, N'PPP', CAST(N'2016-12-03 15:42:00' AS SmallDateTime), CAST(N'2016-12-03 15:42:00' AS SmallDateTime), -1415.0100, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[fl_payhistory] ([srn], [policyno], [receiptno], [period], [grpcode], [pcn], [poltype], [orig_date], [trandate], [amount], [gir], [cur_intr], [cumul_intr], [loanamt], [doctype], [openbalance], [opendeposit], [deposit], [curdep_intr], [cumuldep_intr]) VALUES (10016, N'PPP/ABK/16/00001', N'PPP16120300003', N'201612', NULL, NULL, N'PPP', CAST(N'2016-12-03 15:44:00' AS SmallDateTime), CAST(N'2016-12-03 15:44:00' AS SmallDateTime), -30000.0000, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[fl_payhistory] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_payinput] ON 

GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (3, N'PPP/ABK/16/00001', N'16PPP00000001', 0, NULL, NULL, 1, CAST(N'2016-09-20 00:44:46.8765038' AS DateTime2), CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 30000.0000, N'', NULL, NULL, NULL, CAST(N'2016-09-20 00:44:46.8765038' AS DateTime2), 30000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (7, N'PPP/ABK/16/00001', N'PPP16092400001', 0, NULL, NULL, 1, CAST(N'2016-09-24 18:27:48.4657145' AS DateTime2), CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 3000.0000, N'', NULL, NULL, NULL, CAST(N'2016-09-24 18:27:48.4657145' AS DateTime2), 3000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (8, N'PPP/ABK/16/00001', N'PPP16092400002', 0, NULL, NULL, 1, CAST(N'2016-09-24 20:09:35.9399549' AS DateTime2), CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 9000.0000, N'', NULL, NULL, NULL, CAST(N'2016-09-24 20:09:35.9399549' AS DateTime2), 9000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (9, N'PPP/ABK/16/00001', N'16PPP00000001', 0, NULL, NULL, 1, CAST(N'2016-09-20 00:44:46.8765038' AS DateTime2), CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 30000.0000, N'', NULL, NULL, NULL, CAST(N'2016-09-20 00:44:46.8765038' AS DateTime2), 30000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (10, N'PPP/ABK/16/00001', N'PPP16092400001', 0, NULL, NULL, 1, CAST(N'2016-09-24 18:27:48.4657145' AS DateTime2), CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 3000.0000, N'', NULL, NULL, NULL, CAST(N'2016-09-24 18:27:48.4657145' AS DateTime2), 3000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (11, N'PPP/ABK/16/00001', N'PPP16092400005', 0, NULL, NULL, 1, CAST(N'2016-09-24 22:09:08.2778629' AS DateTime2), CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 10000.0000, N'', NULL, NULL, NULL, CAST(N'2016-09-24 22:09:08.2778629' AS DateTime2), 10000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (12, N'PPP/ABK/16/00001', N'PPP16092400002', 0, NULL, NULL, 1, CAST(N'2016-09-24 20:09:35.9399549' AS DateTime2), CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 9000.0000, N'', NULL, NULL, NULL, CAST(N'2016-09-24 20:09:35.9399549' AS DateTime2), 9000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (13, N'PPP/ABK/16/00001', N'PPP16092400005R', 2, NULL, NULL, NULL, CAST(N'2016-09-24 22:11:32.3876242' AS DateTime2), CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), -10000.0000, N'', NULL, NULL, NULL, CAST(N'2016-09-24 22:11:32.3876242' AS DateTime2), -10000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (14, N'PPP/ABK/16/00001', N'PPP16112600001', 1, NULL, NULL, NULL, NULL, CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 2000.0000, N'', NULL, NULL, NULL, CAST(N'2016-11-26 15:23:43.1088169' AS DateTime2), 2000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (15, N'PPP/ABK/16/00001', N'PPP16112600002', 0, NULL, NULL, NULL, NULL, CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 2000.0000, N'', NULL, NULL, NULL, CAST(N'2016-11-26 15:30:03.6187912' AS DateTime2), 2000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (16, N'PPP/ABK/16/00001', N'PPP16112600003', 0, NULL, NULL, NULL, NULL, CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 2000.0000, N'', NULL, NULL, NULL, CAST(N'2016-11-26 16:28:16.7644836' AS DateTime2), 2000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (17, N'PPP/ABK/16/00001', N'PPP16112600004', 0, NULL, NULL, NULL, NULL, CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 2000.0000, N'', NULL, NULL, NULL, CAST(N'2016-11-26 16:28:56.5591193' AS DateTime2), 2000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (18, N'PPP/ABK/16/00001', N'PPP16112600005', 0, NULL, NULL, NULL, NULL, CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 2000.0000, N'', NULL, NULL, NULL, CAST(N'2016-11-26 16:32:41.3157113' AS DateTime2), 2000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (19, N'PPP/ABK/16/00001', N'PPP16112600006', 0, NULL, NULL, NULL, NULL, CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 2000.0000, N'', NULL, NULL, NULL, CAST(N'2016-11-26 16:40:07.6723942' AS DateTime2), 2000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (10014, N'PPP/ABK/16/00001', N'PPP16112700001', 0, NULL, NULL, NULL, NULL, CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 2000.0000, N'', NULL, NULL, NULL, CAST(N'2016-11-27 12:35:38.5903589' AS DateTime2), 2000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (10015, N'PPP/ABK/16/00001', N'PPP16112900001', 1, NULL, NULL, NULL, CAST(N'2016-11-29 00:13:33.9389723' AS DateTime2), CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), -30000.0000, N'UBA/03903903', NULL, NULL, N'', CAST(N'2016-11-29 00:13:33.9389723' AS DateTime2), -30000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (10016, N'PPP/ABK/16/00001', N'PPP16120300001', 1, NULL, NULL, NULL, CAST(N'2016-12-03 12:40:47.4045070' AS DateTime2), CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), -25000.0000, N'UBA/03903903', NULL, NULL, N'', CAST(N'2016-12-03 12:40:47.4045070' AS DateTime2), -25000.0000, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (10020, N'PPP/ABK/16/00001', N'PPP16120300002', 1, NULL, NULL, NULL, CAST(N'2016-12-03 15:41:48.3015767' AS DateTime2), CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), -1415.0100, N'UBA/03903903', NULL, NULL, N'', CAST(N'2016-12-03 15:41:48.3015767' AS DateTime2), -1415.0100, N'PPP')
GO
INSERT [dbo].[fl_payinput] ([Id], [policyno], [receiptno], [type], [grpcode], [pcn], [reverseind], [trandate], [effdate], [totamt], [chequeno], [payindicator], [status], [createdby], [datecreated], [amount], [poltype]) VALUES (10021, N'PPP/ABK/16/00001', N'PPP16120300003', 1, NULL, NULL, NULL, CAST(N'2016-12-03 15:44:06.6142999' AS DateTime2), CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), -30000.0000, N'cash', NULL, NULL, N'', CAST(N'2016-12-03 15:44:06.6142999' AS DateTime2), -30000.0000, N'PPP')
GO
SET IDENTITY_INSERT [dbo].[fl_payinput] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_pendingSMS] ON 

GO
INSERT [dbo].[fl_pendingSMS] ([srn], [telephone], [message], [isSent], [retrycount]) VALUES (1, N'+2348082468616', N'Testing Testing', 0, 4)
GO
SET IDENTITY_INSERT [dbo].[fl_pendingSMS] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_policyinput] ON 

GO
INSERT [dbo].[fl_policyinput] ([srn], [policyno], [pcn], [grpcode], [sex], [title], [surname], [othername], [peradd], [dob], [nok], [datecreated], [createdby], [datemodified], [modifiedby], [accdate], [quoteno], [poltype], [exitdate], [location], [agentcode], [email], [premium], [telephone], [pinword], [religion], [status]) VALUES (2, N'PPP/ABK/16/00001', NULL, NULL, NULL, NULL, N'Owode', N'Topw', N'kdkdjdk', N'20160915', NULL, CAST(N'2016-09-08 00:29:00' AS SmallDateTime), NULL, NULL, NULL, CAST(N'2016-09-08 00:28:49.193' AS DateTime), N'PPP20160907002', N'PPP', N'', 3, NULL, N'towode@parkwayprojects.com', CAST(100 AS Numeric(18, 0)), N'08076545678', NULL, NULL, 1)
GO
INSERT [dbo].[fl_policyinput] ([srn], [policyno], [pcn], [grpcode], [sex], [title], [surname], [othername], [peradd], [dob], [nok], [datecreated], [createdby], [datemodified], [modifiedby], [accdate], [quoteno], [poltype], [exitdate], [location], [agentcode], [email], [premium], [telephone], [pinword], [religion], [status]) VALUES (3, N'PPP/LAG/16/00002', NULL, NULL, NULL, NULL, N'Owode', N'Tope', NULL, N'20160916', NULL, CAST(N'2016-09-21 23:00:00' AS SmallDateTime), NULL, NULL, NULL, CAST(N'2016-09-21 23:00:20.000' AS DateTime), N'PPP20160921001', N'PPP', NULL, 2, NULL, N'towode@parkwayprojects.com', CAST(2000 AS Numeric(18, 0)), N'98765432', NULL, NULL, NULL)
GO
INSERT [dbo].[fl_policyinput] ([srn], [policyno], [pcn], [grpcode], [sex], [title], [surname], [othername], [peradd], [dob], [nok], [datecreated], [createdby], [datemodified], [modifiedby], [accdate], [quoteno], [poltype], [exitdate], [location], [agentcode], [email], [premium], [telephone], [pinword], [religion], [status]) VALUES (4, N'PPP/LAG/16/00003', NULL, NULL, NULL, NULL, N'Owode', N'Tope', NULL, N'20160916', NULL, CAST(N'2016-09-21 23:01:00' AS SmallDateTime), NULL, NULL, NULL, CAST(N'2016-09-21 23:01:16.237' AS DateTime), N'PPP20160921002', N'PPP', NULL, 2, NULL, N'towode@parkwayprojects.com', CAST(2000 AS Numeric(18, 0)), N'98765432', NULL, NULL, NULL)
GO
INSERT [dbo].[fl_policyinput] ([srn], [policyno], [pcn], [grpcode], [sex], [title], [surname], [othername], [peradd], [dob], [nok], [datecreated], [createdby], [datemodified], [modifiedby], [accdate], [quoteno], [poltype], [exitdate], [location], [agentcode], [email], [premium], [telephone], [pinword], [religion], [status]) VALUES (5, N'PPP/IBD/16/00004', NULL, NULL, NULL, NULL, N'owode', N'Tope', NULL, N'20160901', NULL, CAST(N'2016-09-25 12:11:00' AS SmallDateTime), NULL, NULL, NULL, CAST(N'2016-09-25 12:11:23.443' AS DateTime), N'PPP20160925001', N'PPP', NULL, 6, NULL, N'towode@parkwayprojects.com', CAST(3500 AS Numeric(18, 0)), N'09876543', NULL, NULL, NULL)
GO
INSERT [dbo].[fl_policyinput] ([srn], [policyno], [pcn], [grpcode], [sex], [title], [surname], [othername], [peradd], [dob], [nok], [datecreated], [createdby], [datemodified], [modifiedby], [accdate], [quoteno], [poltype], [exitdate], [location], [agentcode], [email], [premium], [telephone], [pinword], [religion], [status]) VALUES (6, N'PPP/ILR/16/00005', NULL, NULL, NULL, NULL, N'oowde', N'Tope', NULL, N'20160909', NULL, CAST(N'2016-09-25 12:11:00' AS SmallDateTime), NULL, NULL, NULL, CAST(N'2016-09-25 12:11:24.743' AS DateTime), N'PPP20160925002', N'PPP', NULL, 4, NULL, N'towode@parkwayprojects.com', CAST(7000 AS Numeric(18, 0)), N'987654679', NULL, NULL, NULL)
GO
INSERT [dbo].[fl_policyinput] ([srn], [policyno], [pcn], [grpcode], [sex], [title], [surname], [othername], [peradd], [dob], [nok], [datecreated], [createdby], [datemodified], [modifiedby], [accdate], [quoteno], [poltype], [exitdate], [location], [agentcode], [email], [premium], [telephone], [pinword], [religion], [status]) VALUES (7, N'PPP/IBD/16/00006', NULL, NULL, NULL, NULL, N'sjddjhdj', N'jh', NULL, N'20160914', NULL, CAST(N'2016-09-25 12:11:00' AS SmallDateTime), NULL, NULL, NULL, CAST(N'2016-09-25 12:11:24.773' AS DateTime), N'PPP20160925003', N'PPP', NULL, 6, NULL, N'towode@parkwayprojects.com', CAST(2000 AS Numeric(18, 0)), N'8765456789', NULL, NULL, NULL)
GO
INSERT [dbo].[fl_policyinput] ([srn], [policyno], [pcn], [grpcode], [sex], [title], [surname], [othername], [peradd], [dob], [nok], [datecreated], [createdby], [datemodified], [modifiedby], [accdate], [quoteno], [poltype], [exitdate], [location], [agentcode], [email], [premium], [telephone], [pinword], [religion], [status]) VALUES (9, N'PPP/ILR/16/00007', NULL, NULL, NULL, NULL, N'kckjckcjk', N'KJKDJDKDJ', NULL, N'20000907', NULL, CAST(N'2016-10-13 23:40:00' AS SmallDateTime), NULL, NULL, NULL, CAST(N'2016-10-13 23:40:17.933' AS DateTime), NULL, N'PPP', NULL, 4, NULL, N'towode@parkwayprojects.com', CAST(20000 AS Numeric(18, 0)), N'0987654567890', NULL, NULL, 1)
GO
INSERT [dbo].[fl_policyinput] ([srn], [policyno], [pcn], [grpcode], [sex], [title], [surname], [othername], [peradd], [dob], [nok], [datecreated], [createdby], [datemodified], [modifiedby], [accdate], [quoteno], [poltype], [exitdate], [location], [agentcode], [email], [premium], [telephone], [pinword], [religion], [status]) VALUES (19, N'PPP/IBD/16/00008', NULL, NULL, NULL, NULL, N'Owode', N'PPP/ABK/16/00001', NULL, N'20160915', NULL, CAST(N'2016-10-19 22:26:00' AS SmallDateTime), NULL, NULL, NULL, CAST(N'2016-10-19 22:26:13.780' AS DateTime), NULL, N'PPP', NULL, 6, NULL, N'towode@parkwayprojects.com', CAST(5000 AS Numeric(18, 0)), N'08076545678', NULL, NULL, 1)
GO
INSERT [dbo].[fl_policyinput] ([srn], [policyno], [pcn], [grpcode], [sex], [title], [surname], [othername], [peradd], [dob], [nok], [datecreated], [createdby], [datemodified], [modifiedby], [accdate], [quoteno], [poltype], [exitdate], [location], [agentcode], [email], [premium], [telephone], [pinword], [religion], [status]) VALUES (10010, N'PPP/ILR/16/00009', NULL, NULL, NULL, NULL, N'owode', N'Tope', NULL, N'20161012', NULL, CAST(N'2016-10-31 20:36:00' AS SmallDateTime), NULL, NULL, NULL, CAST(N'2016-10-31 20:36:12.307' AS DateTime), NULL, N'PPP', NULL, 4, NULL, N'towode@parkwayprojects.com', CAST(3000 AS Numeric(18, 0)), N'09409404940', NULL, NULL, 1)
GO
SET IDENTITY_INSERT [dbo].[fl_policyinput] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_poltype] ON 

GO
INSERT [dbo].[fl_poltype] ([Id], [poltype], [poldesc], [code], [actype], [term], [matage], [maxloan], [income_account], [liability_account], [expense_account], [vat_account], [Datecreated], [CreatedBy], [DateModified], [ModifiedBy], [IsDeleted]) VALUES (1, N'PPP', N'hh', NULL, N'dkldkldk', 1, 3, CAST(0.00 AS Decimal(18, 2)), N'111000-00006', N'111000-00004', N'111000-00004', N'111000-00003', NULL, NULL, CAST(N'2016-09-24 16:13:47.9760575' AS DateTime2), NULL, 0)
GO
INSERT [dbo].[fl_poltype] ([Id], [poltype], [poldesc], [code], [actype], [term], [matage], [maxloan], [income_account], [liability_account], [expense_account], [vat_account], [Datecreated], [CreatedBy], [DateModified], [ModifiedBy], [IsDeleted]) VALUES (2, N'', N'', NULL, N'', 0, 0, CAST(0.00 AS Decimal(18, 2)), N'', N'', N'111000-00002', N'111000-00001', CAST(N'2016-09-19 23:45:49.2386755' AS DateTime2), NULL, NULL, NULL, 1)
GO
INSERT [dbo].[fl_poltype] ([Id], [poltype], [poldesc], [code], [actype], [term], [matage], [maxloan], [income_account], [liability_account], [expense_account], [vat_account], [Datecreated], [CreatedBy], [DateModified], [ModifiedBy], [IsDeleted]) VALUES (3, N'01', N'E.P.R.P/PERSONAL PROVIDENT PLAN', N'PPP', N'01', 3, 1, CAST(0.00 AS Decimal(18, 2)), N'100000-00001', N'111000-00001', N'113000-00003', N'113000-00003', CAST(N'2016-11-23 21:02:16.1099073' AS DateTime2), NULL, NULL, NULL, 0)
GO
SET IDENTITY_INSERT [dbo].[fl_poltype] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_premrate] ON 

GO
INSERT [dbo].[fl_premrate] ([Id], [poltypeId], [grpId], [period], [interest], [commrate], [retention], [mkt_commrate], [Datecreated], [CreatedBy], [DateModified], [ModifiedBy], [IsDeleted]) VALUES (3, 1, 1, N'2015102', CAST(5.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(4999999.00 AS Decimal(18, 2)), N'5', CAST(N'2016-08-29 23:05:53.8269675' AS DateTime2), NULL, NULL, NULL, 0)
GO
INSERT [dbo].[fl_premrate] ([Id], [poltypeId], [grpId], [period], [interest], [commrate], [retention], [mkt_commrate], [Datecreated], [CreatedBy], [DateModified], [ModifiedBy], [IsDeleted]) VALUES (6, 3, 5, N'2016', NULL, NULL, NULL, NULL, CAST(N'2016-11-25 00:37:39.1050947' AS DateTime2), NULL, NULL, NULL, 0)
GO
INSERT [dbo].[fl_premrate] ([Id], [poltypeId], [grpId], [period], [interest], [commrate], [retention], [mkt_commrate], [Datecreated], [CreatedBy], [DateModified], [ModifiedBy], [IsDeleted]) VALUES (7, 3, 5, N'201601', NULL, NULL, NULL, NULL, CAST(N'2016-11-25 00:40:28.7568253' AS DateTime2), NULL, NULL, NULL, 0)
GO
INSERT [dbo].[fl_premrate] ([Id], [poltypeId], [grpId], [period], [interest], [commrate], [retention], [mkt_commrate], [Datecreated], [CreatedBy], [DateModified], [ModifiedBy], [IsDeleted]) VALUES (8, 1, 5, N'201601', NULL, NULL, NULL, NULL, CAST(N'2016-11-25 00:44:51.5906348' AS DateTime2), NULL, NULL, NULL, 0)
GO
INSERT [dbo].[fl_premrate] ([Id], [poltypeId], [grpId], [period], [interest], [commrate], [retention], [mkt_commrate], [Datecreated], [CreatedBy], [DateModified], [ModifiedBy], [IsDeleted]) VALUES (1004, 1, 5, N'201602', NULL, NULL, NULL, NULL, CAST(N'2016-11-26 12:52:43.2913702' AS DateTime2), NULL, NULL, NULL, 0)
GO
SET IDENTITY_INSERT [dbo].[fl_premrate] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_premrateRules] ON 

GO
INSERT [dbo].[fl_premrateRules] ([Id], [Interest], [CommRate], [Mkt_CommRate], [IntrBound], [CommBound], [PremRateId]) VALUES (1, CAST(5.00 AS Decimal(18, 2)), CAST(7.50 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(10000.00 AS Decimal(18, 2)), CAST(10000.00 AS Decimal(18, 2)), 8)
GO
INSERT [dbo].[fl_premrateRules] ([Id], [Interest], [CommRate], [Mkt_CommRate], [IntrBound], [CommBound], [PremRateId]) VALUES (2, CAST(5.00 AS Decimal(18, 2)), CAST(7.00 AS Decimal(18, 2)), CAST(6.50 AS Decimal(18, 2)), CAST(10000.00 AS Decimal(18, 2)), CAST(10000.00 AS Decimal(18, 2)), 1004)
GO
INSERT [dbo].[fl_premrateRules] ([Id], [Interest], [CommRate], [Mkt_CommRate], [IntrBound], [CommBound], [PremRateId]) VALUES (3, CAST(5.50 AS Decimal(18, 2)), CAST(7.50 AS Decimal(18, 2)), CAST(7.00 AS Decimal(18, 2)), CAST(500000.00 AS Decimal(18, 2)), CAST(500000.00 AS Decimal(18, 2)), 1004)
GO
SET IDENTITY_INSERT [dbo].[fl_premrateRules] OFF
GO
INSERT [dbo].[fl_PublicHoliday] ([Id], [HolidayName], [Holidayday], [holidaymonth], [HolidayMsg]) VALUES (1, N'XMAA', 10, 3, N'Happy Xmas to our lovely customer')
GO
SET IDENTITY_INSERT [dbo].[fl_receiptcontrol] ON 

GO
INSERT [dbo].[fl_receiptcontrol] ([Id], [PolTypeId], [PaymentMethod], [Income_ledger], [Bank_ledger], [BankAccount], [Bankname], [Receiptcounter], [DateCreated], [CreatedBy], [DateModified], [ModifiedBy], [IsDeleted]) VALUES (3, 1, 3, N'111000-00001', N'111000-00002', N'kcjkcjckcjkcj', N'ckjckjck', NULL, CAST(N'2016-09-24 00:00:00.0000000' AS DateTime2), NULL, NULL, NULL, 0)
GO
INSERT [dbo].[fl_receiptcontrol] ([Id], [PolTypeId], [PaymentMethod], [Income_ledger], [Bank_ledger], [BankAccount], [Bankname], [Receiptcounter], [DateCreated], [CreatedBy], [DateModified], [ModifiedBy], [IsDeleted]) VALUES (4, 1, 0, N'111000-00003', N'100000-00001', N'944984948', N'UBA', NULL, CAST(N'2016-09-24 00:00:00.0000000' AS DateTime2), NULL, NULL, NULL, 0)
GO
INSERT [dbo].[fl_receiptcontrol] ([Id], [PolTypeId], [PaymentMethod], [Income_ledger], [Bank_ledger], [BankAccount], [Bankname], [Receiptcounter], [DateCreated], [CreatedBy], [DateModified], [ModifiedBy], [IsDeleted]) VALUES (1009, 1, 1, N'111000-00001', N'111000-00001', N'944984948', N'UBA', NULL, CAST(N'2016-11-16 00:00:00.0000000' AS DateTime2), NULL, NULL, NULL, 0)
GO
SET IDENTITY_INSERT [dbo].[fl_receiptcontrol] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_system] ON 

GO
INSERT [dbo].[fl_system] ([Id], [coycode], [coyname], [coyaddress], [town], [lg], [state], [telephone], [email], [box], [processyear], [processmonth], [installdate], [createdby], [datecreated], [serialnumber], [reassurance], [IsDeleted]) VALUES (12, N'NLPC', N'Owode Tope', N'295 herbert macaulay way', N'Yaba', N'djhdjdhj', N'Lagos', N'08076545678', N'towode@parkwayprojects.com', N'jdhjdhdj', N'2014', N'12', N'2016-12-09', NULL, CAST(N'2016-08-20 00:00:00.000' AS DateTime), NULL, NULL, 0)
GO
SET IDENTITY_INSERT [dbo].[fl_system] OFF
GO
SET IDENTITY_INSERT [dbo].[fl_translog] ON 

GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (8, N'16PPP00000001', CAST(N'2016-09-20 00:44:46.5532311' AS DateTime2), N'kcjckcjk', N'kfjkfjfk', NULL, 3, CAST(30000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'dfghjklk;', 0, 1, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (12, N'PPP16092400001', CAST(N'2016-09-24 18:27:48.0889141' AS DateTime2), N'9849489489', N'9839389489', NULL, 0, CAST(3000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Oct', 0, 1, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (13, N'PPP16092400002', CAST(N'2016-09-24 20:09:35.8576748' AS DateTime2), N'9849489489', N'9839389489', NULL, 0, CAST(9000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Oct', 0, 1, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (18, N'16PPP00000001R', CAST(N'2016-09-24 21:59:28.1023121' AS DateTime2), N'kcjckcjk', N'kfjkfjfk', NULL, 3, CAST(-30000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Reversal on 16PPP00000001', 2, 1, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (19, N'PPP16092400001R', CAST(N'2016-09-24 22:08:06.3047004' AS DateTime2), N'9849489489', N'9839389489', NULL, 0, CAST(-3000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Reversal on PPP16092400001', 2, 1, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (20, N'PPP16092400005', CAST(N'2016-09-24 22:09:07.7874291' AS DateTime2), N'100000-00001', N'111000-00003', NULL, 0, CAST(10000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Oct', 0, 1, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (21, N'PPP16092400002R', CAST(N'2016-09-24 22:10:06.4428324' AS DateTime2), N'9849489489', N'9839389489', NULL, 0, CAST(-9000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Reversal on PPP16092400002', 2, 1, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (22, N'PPP16092400005R', CAST(N'2016-09-24 22:11:32.2845234' AS DateTime2), N'100000-00001', N'111000-00003', NULL, 0, CAST(-10000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Reversal on PPP16092400005', 2, 1, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (10014, N'PPP16112600001', CAST(N'2016-11-26 15:23:43.0117276' AS DateTime2), N'100000-00001', N'111000-00003', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Oct', 1, NULL, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (10015, N'PPP16112600002', CAST(N'2016-11-26 15:30:03.6057782' AS DateTime2), N'100000-00001', N'111000-00003', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Oct', 0, NULL, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (10016, N'PPP16112600003', CAST(N'2016-11-26 16:28:03.8073881' AS DateTime2), N'100000-00001', N'111000-00003', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Oct', 0, NULL, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (10017, N'PPP16112600004', CAST(N'2016-11-26 16:28:56.5521157' AS DateTime2), N'100000-00001', N'111000-00003', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Oct', 0, NULL, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (10018, N'PPP16112600005', CAST(N'2016-11-26 16:32:41.0243937' AS DateTime2), N'100000-00001', N'111000-00003', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Oct', 0, NULL, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (10019, N'PPP16112600006', CAST(N'2016-11-26 16:40:07.3840785' AS DateTime2), N'100000-00001', N'111000-00003', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Oct', 0, NULL, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (20014, N'PPP16112700001', CAST(N'2016-11-27 12:35:38.4845103' AS DateTime2), N'100000-00001', N'111000-00003', NULL, 0, CAST(2000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Oct', 0, NULL, NULL)
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (20015, N'PPP16112900001', CAST(N'2016-11-29 00:13:33.6467374' AS DateTime2), N'111000-00001', N'111000-00001', NULL, 1, CAST(-30000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Partial Withdrwal on Policy PPP/ABK/16/00001', 1, NULL, N'UBA/03903903')
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (20016, N'PPP16120300001', CAST(N'2016-12-03 12:40:47.3354416' AS DateTime2), N'111000-00001', N'111000-00001', NULL, 1, CAST(-25000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Partial Withdrwal on Policy PPP/ABK/16/00001', 1, NULL, N'UBA/03903903')
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (20020, N'PPP16120300002', CAST(N'2016-12-03 15:41:48.2815118' AS DateTime2), N'111000-00001', N'111000-00001', NULL, 1, CAST(-1415.01 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Full Withdral on Policy PPP/ABK/16/00001', 1, NULL, N'UBA/03903903')
GO
INSERT [dbo].[fl_translog] ([Id], [receiptno], [trandate], [bank_ledger], [income_ledger], [payee], [paymentmethod], [amount], [policyno], [remark], [Instrument], [Isreversed], [chequeno]) VALUES (20021, N'PPP16120300003', CAST(N'2016-12-03 15:44:06.6082917' AS DateTime2), N'100000-00001', N'111000-00003', NULL, 0, CAST(-30000.00 AS Decimal(18, 2)), N'PPP/ABK/16/00001', N'Partial Withdrwal on Policy PPP/ABK/16/00001', 1, NULL, N'cash')
GO
SET IDENTITY_INSERT [dbo].[fl_translog] OFF
GO
SET IDENTITY_INSERT [dbo].[LinkRole] ON 

GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (2010, 1, 1005, 0, 0)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (2011, 2, 1005, 1, 1)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (2012, 3, 1005, 1, 1)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (2013, 2, 1005, 0, 0)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (2014, 8, 1005, 1, 2)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (2015, 9, 1005, 1, 2)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (2016, 11, 1005, 1, 2)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (2017, 12, 1005, 1, 2)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4091, 1, 1012, 0, 0)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4092, 2, 1012, 1, 1)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4093, 3, 1012, 1, 1)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4094, 6, 1012, 1, 1)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4095, 2, 1012, 0, 0)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4096, 7, 1012, 1, 2)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4097, 8, 1012, 1, 2)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4098, 9, 1012, 1, 2)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4099, 10, 1012, 1, 2)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4100, 11, 1012, 1, 2)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4101, 12, 1012, 1, 2)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4102, 14, 1012, 1, 2)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4103, 3, 1012, 0, 0)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4104, 13, 1012, 1, 3)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4105, 15, 1012, 1, 3)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4106, 4, 1012, 0, 0)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4107, 16, 1012, 1, 4)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4108, 17, 1012, 1, 4)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4109, 1004, 1012, 0, 0)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4110, 1016, 1012, 1, 1004)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4111, 1017, 1012, 1, 1004)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4112, 1018, 1012, 1, 1004)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4113, 1019, 1012, 1, 1004)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4114, 1020, 1012, 1, 1004)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4115, 1021, 1012, 1, 1004)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4116, 1022, 1012, 1, 1004)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4117, 1023, 1012, 1, 1004)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4118, 1005, 1012, 0, 0)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4119, 1024, 1012, 1, 1005)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4120, 1025, 1012, 1, 1005)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4121, 1026, 1012, 1, 1005)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4122, 1027, 1012, 1, 1005)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4123, 1028, 1012, 1, 1005)
GO
INSERT [dbo].[LinkRole] ([Id], [LinkId], [RoleID], [Type], [Parent]) VALUES (4124, 2024, 1012, 1, 1005)
GO
SET IDENTITY_INSERT [dbo].[LinkRole] OFF
GO
SET IDENTITY_INSERT [dbo].[NextofKin_BeneficiaryStaging] ON 

GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (1, N'PPP20160010001', N'Owode Tope', N'295 herbert macaulay way', N'08076545678', N'towode@parkwayprojects.com', 0, CAST(N'1988-01-21 00:09:00.0000000' AS DateTime2), NULL, 0, 1, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (2, N'PPP20160010001', N'Owode Tope', N'295 herbert macaulay way', N'08076545678', N'towode@parkwayprojects.com', 0, CAST(N'1996-05-01 00:00:00.0000000' AS DateTime2), N'1', 1, 1, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (3, N'PPP20160010002', N'Owode Oluwatoyosi', N'9876567890', N'09876567890', N'temmyowode@gmail.com', 0, CAST(N'1996-01-01 00:05:00.0000000' AS DateTime2), NULL, 0, 2, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (4, N'PPP20160010002', N'Owode Tope Muiz', N'lkjdhkddmndm', N'', N'temmyowode@gmail.com', 0, CAST(N'2013-05-29 00:00:00.0000000' AS DateTime2), N'4', 1, 2, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (5, N'PPP20160004001', N'Owode Tope', N'295 herbert macaulay way', N'08076545678', N'towode@parkwayprojects.com', 0, CAST(N'1988-01-21 00:09:00.0000000' AS DateTime2), NULL, 0, 3, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (6, N'PPP20160004001', N'Owode Tope', N'295 herbert macaulay way', N'08076545678', N'towode@parkwayprojects.com', 0, CAST(N'1988-09-21 00:00:00.0000000' AS DateTime2), N'0', 1, 3, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (7, N'PPP20160004002', N'Owode Tope', N'295 herbert macaulay way', N'08076545678', N'towode@parkwayprojects.com', 0, CAST(N'1988-01-21 00:09:00.0000000' AS DateTime2), NULL, 0, 4, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (8, N'PPP20160004002', N'Owode Tope', N'295 herbert macaulay way', N'08076545678', N'towode@parkwayprojects.com', 0, CAST(N'1988-09-21 00:00:00.0000000' AS DateTime2), N'0', 1, 4, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (9, N'PPP20160004002', N'Owode Tope', N'295 herbert macaulay way', N'08076545678', N'towode@parkwayprojects.com', 0, CAST(N'1988-09-21 00:00:00.0000000' AS DateTime2), N'0', 1, 4, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (10, N'PPP20160008001', N'Owode Tope', N'295 herbert macaulay way', N'08076545678', N'towode@parkwayprojects.com', 0, CAST(N'1988-01-21 00:09:00.0000000' AS DateTime2), NULL, 0, 5, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (11, N'PPP20160008001', N'Owode Tope', N'295 herbert macaulay way', N'08076545678', N'towode@parkwayprojects.com', 0, CAST(N'1988-09-21 00:00:00.0000000' AS DateTime2), N'1', 1, 5, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (12, N'PPP20160007001', N'jfdhfjfhjfh', N'jfchjfhfjh', N'94859859589', N'temi_owode@yahoo.com', 0, CAST(N'2016-01-07 00:09:00.0000000' AS DateTime2), NULL, 0, 6, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (13, N'PPP20160007001', N'jhfjfhfjfhj', N'jhdjdfhdjdh', N'948598598', N'temmyowode@gmail.com', 0, CAST(N'2016-09-22 00:00:00.0000000' AS DateTime2), N'1', 1, 6, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (14, N'PPP20160907002', N'Owode Tope', N'295 herbert macaulay way', N'08076545678', N'towode@parkwayprojects.com', 0, CAST(N'1988-01-21 00:09:00.0000000' AS DateTime2), NULL, 0, 7, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (15, N'PPP20160907002', N'Owode Tope', N'295 herbert macaulay way', N'98767890', N'towode@parkwayprojects.com', 0, CAST(N'1996-05-01 00:00:00.0000000' AS DateTime2), N'3', 1, 7, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (16, N'PPP20160921001', N'Owode', N'kjgfdfghjk', N'976543456', N'towode@parkwayprojects.com', 0, CAST(N'2016-09-03 00:00:00.0000000' AS DateTime2), NULL, 1, 8, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (17, N'PPP20160921001', N'kdjdkdjk', N'kkj', N'087654', N'towode@parkwayprojects.com', 0, CAST(N'2016-09-09 00:00:00.0000000' AS DateTime2), N'0', 0, 8, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (18, N'PPP20160921002', N'Owode', N'kjgfdfghjk', N'976543456', N'towode@parkwayprojects.com', 0, CAST(N'2016-09-03 00:00:00.0000000' AS DateTime2), NULL, 1, 9, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (19, N'PPP20160921002', N'kdjdkdjk', N'kkj', N'087654', N'towode@parkwayprojects.com', 0, CAST(N'2016-09-09 00:00:00.0000000' AS DateTime2), N'0', 0, 9, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (20, N'PPP20160921003', N'kjhgfds', N'fcgvhjnkl', N'3456789', N'towode@parkwayprojects.com', 0, CAST(N'2016-09-03 00:00:00.0000000' AS DateTime2), NULL, 1, 10, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (21, N'PPP20160921003', N'Owode', N'jhgfdsfadsdgg', NULL, N'towode@parkwayprojects.com', 0, CAST(N'2016-09-08 00:00:00.0000000' AS DateTime2), N'0', 0, 10, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (22, N'PPP20160925001', N'kekejek', N'kdjkdjk', N'87654567', N'towode@parkwayprojects.com', 0, CAST(N'2016-09-15 00:00:00.0000000' AS DateTime2), NULL, 1, 11, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (23, N'PPP20160925001', N'dmdnmdnm', N'msmdndmn', N'87656790', N'towode@parkwayprojects.com', 0, CAST(N'2016-09-15 00:00:00.0000000' AS DateTime2), N'0', 0, 11, CAST(70.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (24, N'PPP20160925001', N'dmdnmdnm', N'msmdndmn', N'87656790', N'towode@parkwayprojects.com', 0, CAST(N'2016-09-15 00:00:00.0000000' AS DateTime2), N'0', 0, 11, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (25, N'PPP20160925002', N'kjkdkjekj', N'kdjkdjk', N'09876567890', N'towode@parkwayprojects.com', 0, CAST(N'2016-09-09 00:00:00.0000000' AS DateTime2), NULL, 1, 12, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (26, N'PPP20160925002', N'smdmdmdnm', N'mndmndm', N'876567890', N'towode@parkwayprojects.com', 0, CAST(N'2016-09-16 00:00:00.0000000' AS DateTime2), N'1', 0, 12, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (27, N'PPP20160925003', N'dmddmdndm', N'mdmddnm', N'0987656789', N'towode@parkwayprojects.com', 0, CAST(N'2016-09-16 00:00:00.0000000' AS DateTime2), NULL, 1, 13, CAST(0.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (28, N'PPP20160925003', N'kjdkdjdk', N'kjkdjdkdj', N'98756789', N'towode@parkwayprojects.com', 0, CAST(N'2016-09-15 00:00:00.0000000' AS DateTime2), N'3', 0, 13, CAST(100.00 AS Decimal(18, 2)), 0, 0, NULL)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (10022, N'PPP/ILR/16/00007', N'jdmnmdndmn', N'dmndmdn', N'09876543', N'towode@parkwayprojects.com', 0, CAST(N'2000-09-07 00:00:00.0000000' AS DateTime2), NULL, 0, NULL, NULL, 1, 1, 9)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (10023, N'PPP/ILR/16/00007', N'ddndmndmn', N'mdnmdndm', N'09876543', N'towode@parkwayprojects.com', 0, CAST(N'2000-09-07 00:00:00.0000000' AS DateTime2), N'2', 1, NULL, CAST(100.00 AS Decimal(18, 2)), 1, 1, 9)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (10024, N'PPP/ILR/16/00009', N'Owode', N'dlkdldk', N'08082468616', N'towode@parkwayprojects.com', 0, CAST(N'2016-10-19 00:00:00.0000000' AS DateTime2), NULL, 0, NULL, NULL, 1, 1, 10010)
GO
INSERT [dbo].[NextofKin_BeneficiaryStaging] ([Id], [RegNo], [Name], [Address], [Phone], [Email], [Type], [Dob], [RelationShip], [Category], [PersonalDetailsStagingId], [Proportion], [ApprovalStatus], [IsSynched], [PolicyId]) VALUES (10025, N'PPP/ILR/16/00009', N'kcflkf', N'djfkfjk', N'08082468616', N'towode@parkwayprojects.com', 0, CAST(N'2016-10-13 00:00:00.0000000' AS DateTime2), NULL, 1, NULL, CAST(100.00 AS Decimal(18, 2)), 1, 1, 10010)
GO
SET IDENTITY_INSERT [dbo].[NextofKin_BeneficiaryStaging] OFF
GO
SET IDENTITY_INSERT [dbo].[Notification] ON 

GO
INSERT [dbo].[Notification] ([Id], [Policyno], [period], [IsSent], [DateCreated], [NotificationType], [NotificationFor]) VALUES (14, N'YOL/281', N'201603    ', 1, CAST(N'2016-03-17 15:13:23.127' AS DateTime), 1, 3)
GO
INSERT [dbo].[Notification] ([Id], [Policyno], [period], [IsSent], [DateCreated], [NotificationType], [NotificationFor]) VALUES (18, N'YOL/281', N'2016      ', 1, CAST(N'2016-03-17 15:46:26.773' AS DateTime), 1, 0)
GO
INSERT [dbo].[Notification] ([Id], [Policyno], [period], [IsSent], [DateCreated], [NotificationType], [NotificationFor]) VALUES (19, N'YOL/281', N'2016      ', 1, CAST(N'2016-03-17 15:46:49.783' AS DateTime), 0, 0)
GO
SET IDENTITY_INSERT [dbo].[Notification] OFF
GO
SET IDENTITY_INSERT [dbo].[PendingEmail] ON 

GO
INSERT [dbo].[PendingEmail] ([ID], [Subject], [DueDate], [Body], [From], [To], [Bcc], [CC], [ErrorMessage], [IsBodyHtml], [ReplyTo], [Sender], [Retries], [Priority], [ThrewException], [RetryCount]) VALUES (3, N'Password', CAST(N'2016-10-02 14:30:51.953' AS DateTime), N'<p>Dear Test agent</p><br/><p>Please find your user details for Flex Application below</p><br/><p>Username : agent</p><br/><p>Password : oh5JLR</p><br/>', N'temmyowode@gmail.com', N'towode@parkwayprojects.com', NULL, NULL, NULL, 1, NULL, N'NLPC LTD', NULL, NULL, NULL, NULL)
GO
INSERT [dbo].[PendingEmail] ([ID], [Subject], [DueDate], [Body], [From], [To], [Bcc], [CC], [ErrorMessage], [IsBodyHtml], [ReplyTo], [Sender], [Retries], [Priority], [ThrewException], [RetryCount]) VALUES (10002, N'Password', CAST(N'2016-11-26 12:24:51.770' AS DateTime), N'<p>Dear Agunbiade</p><br/><p>Please find your user details for Flex Application below</p><br/><p>Username : CHIEF</p><br/><p>Password : An8ZwM</p><br/>', N'temmyowode@gmail.com', N'chief@hicadsystemsltd.com', NULL, NULL, NULL, 1, NULL, N'NLPC LTD', NULL, NULL, NULL, NULL)
GO
SET IDENTITY_INSERT [dbo].[PendingEmail] OFF
GO
SET IDENTITY_INSERT [dbo].[PersonalDetailsStaging] ON 

GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (1, N'PPP20160010001', N'Owode', N'Topw', N'295 herbert macaulay way', N'295 herbert macaulay way', N'295 herbert macaulay way', N'towode@parkwayprojects.com', N'08076545678', CAST(N'1988-09-21 00:00:00.0000000' AS DateTime2), N'IT', CAST(200.00 AS Decimal(18, 2)), N'1', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 2, 0, 1, 1, 0, CAST(N'2016-07-10 00:00:00.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (2, N'PPP20160010002', N'Owode', N'Temmy', N'hddmdndmdn', N'', N'', N'te', N'98767890', CAST(N'1990-12-27 00:00:00.0000000' AS DateTime2), N'Teacher', CAST(5000.00 AS Decimal(18, 2)), N'1', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 2, 0, 1, 1, 0, CAST(N'2016-07-10 00:00:00.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (3, N'PPP20160004001', N'Owode', N'Tope', N'295 herbert macaulay way', N'295 herbert macaulay way', N'', N'towode@parkwayprojects.com', N'08076545678', CAST(N'1988-09-21 00:00:00.0000000' AS DateTime2), N'IT', CAST(1000.00 AS Decimal(18, 2)), N'2', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 10000, 0, 1, 1, 0, CAST(N'2016-08-04 00:00:00.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (4, N'PPP20160004002', N'Owode', N'Tope', N'295 herbert macaulay way', N'295 herbert macaulay way', N'', N'towode@parkwayprojects.com', N'08076545678', CAST(N'1988-09-21 00:00:00.0000000' AS DateTime2), N'IT', CAST(1000.00 AS Decimal(18, 2)), N'2', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 10000, 0, 1, 1, 0, CAST(N'2016-08-04 00:00:00.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (5, N'PPP20160008001', N'Owode', N'Topw', N'295 herbert macaulay way', N'295 herbert macaulay way', N'295 herbert macaulay way', N'towode@parkwayprojects.com', N'08076545678', CAST(N'1988-09-21 00:00:00.0000000' AS DateTime2), N'IT', CAST(100.00 AS Decimal(18, 2)), N'1', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 3, 0, 1, 1, 0, CAST(N'2016-08-08 00:00:00.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (6, N'PPP20160007001', N'owode', N'Tope', N'ddkjkdjdkj', N'kdjdkfjdk', N'kdjkdjdk', N'`kdjdkjdk', N'`dskjdkdjk', CAST(N'2016-09-07 00:00:00.0000000' AS DateTime2), N'fkkfofjkfjk', CAST(9000.00 AS Decimal(18, 2)), N'1', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 2, 0, 1, 0, 0, CAST(N'2016-09-07 00:00:00.0000000' AS DateTime2), NULL, NULL)
GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (7, N'PPP20160907002', N'Owode', N'Topw', N'kdkdjdk', N'295 herbert macaulay way', N'295 herbert macaulay way', N'towode@parkwayprojects.com', N'08076545678', CAST(N'2016-09-15 00:00:00.0000000' AS DateTime2), N'IT', CAST(100.00 AS Decimal(18, 2)), N'2', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 3, 0, 1, 1, 0, CAST(N'2016-09-07 00:00:00.0000000' AS DateTime2), NULL, 3)
GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (8, N'PPP20160921001', N'Owode', N'Tope', NULL, NULL, NULL, N'towode@parkwayprojects.com', N'98765432', CAST(N'2016-09-16 00:00:00.0000000' AS DateTime2), N'IT', CAST(2000.00 AS Decimal(18, 2)), N'1', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 2000, 0, 1, 1, 0, CAST(N'2016-09-21 00:00:00.0000000' AS DateTime2), NULL, 2)
GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (9, N'PPP20160921002', N'Owode', N'Tope', NULL, NULL, NULL, N'towode@parkwayprojects.com', N'98765432', CAST(N'2016-09-16 00:00:00.0000000' AS DateTime2), N'IT', CAST(2000.00 AS Decimal(18, 2)), N'1', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 2000, 0, 1, 1, 0, CAST(N'2016-09-21 00:00:00.0000000' AS DateTime2), NULL, 2)
GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (10, N'PPP20160921003', N'lklklkl', N'kkjkjk', NULL, N'h765456789', NULL, N'towode@parkwayprojects.com', NULL, CAST(N'2016-09-15 00:00:00.0000000' AS DateTime2), N'kdkjdkd', CAST(6000.00 AS Decimal(18, 2)), N'1', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 5, 0, 1, 0, 0, CAST(N'2016-09-21 00:00:00.0000000' AS DateTime2), NULL, 2)
GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (11, N'PPP20160925001', N'owode', N'Tope', NULL, NULL, NULL, N'towode@parkwayprojects.com', N'09876543', CAST(N'2016-09-01 00:00:00.0000000' AS DateTime2), N'Banker', CAST(3500.00 AS Decimal(18, 2)), N'1', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 3, 0, 1, 1, 0, CAST(N'2016-09-25 00:00:00.0000000' AS DateTime2), NULL, 6)
GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (12, N'PPP20160925002', N'oowde', N'Tope', NULL, NULL, NULL, N'towode@parkwayprojects.com', N'987654679', CAST(N'2016-09-09 00:00:00.0000000' AS DateTime2), N'ddkdkdj', CAST(7000.00 AS Decimal(18, 2)), N'1', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 1, 0, 1, 1, 0, CAST(N'2016-09-25 00:00:00.0000000' AS DateTime2), NULL, 4)
GO
INSERT [dbo].[PersonalDetailsStaging] ([Id], [RegNo], [Surname], [OtherNames], [ResAddress], [OffAddress], [PosAddress], [Email], [Phone], [dob], [Occupation], [ContribAmount], [ContribFreq], [CommencementDate], [Duration], [Type], [PolicyType], [ApprovalStatus], [IsSynched], [DateCreated], [ApprovedBy], [Location]) VALUES (13, N'PPP20160925003', N'sjddjhdj', N'jh', NULL, NULL, NULL, N'towode@parkwayprojects.com', N'8765456789', CAST(N'2016-09-14 00:00:00.0000000' AS DateTime2), N'Banker', CAST(2000.00 AS Decimal(18, 2)), N'1', CAST(N'0001-01-01 00:00:00.0000000' AS DateTime2), 7, 0, 1, 1, 0, CAST(N'2016-09-25 00:00:00.0000000' AS DateTime2), NULL, 6)
GO
SET IDENTITY_INSERT [dbo].[PersonalDetailsStaging] OFF
GO
SET IDENTITY_INSERT [dbo].[Portlet] ON 

GO
INSERT [dbo].[Portlet] ([Id], [Name], [ImageUrl], [Background], [Order]) VALUES (1, N'Proposal & Policy', N'/images/Customer.png', N'tile-green', 1)
GO
INSERT [dbo].[Portlet] ([Id], [Name], [ImageUrl], [Background], [Order]) VALUES (2, N'SetUp', N'/images/setup.png', N'tile-dark-blue', 0)
GO
INSERT [dbo].[Portlet] ([Id], [Name], [ImageUrl], [Background], [Order]) VALUES (3, N'Payment', NULL, N'tile-orange', 2)
GO
INSERT [dbo].[Portlet] ([Id], [Name], [ImageUrl], [Background], [Order]) VALUES (4, N'User & Role Mgt.', NULL, N'tile-blue', 3)
GO
INSERT [dbo].[Portlet] ([Id], [Name], [ImageUrl], [Background], [Order]) VALUES (1004, N'Reports', NULL, N'tile-orange', 4)
GO
INSERT [dbo].[Portlet] ([Id], [Name], [ImageUrl], [Background], [Order]) VALUES (1005, N'Claim', NULL, N'tile-dark-blue', 5)
GO
SET IDENTITY_INSERT [dbo].[Portlet] OFF
GO
SET IDENTITY_INSERT [dbo].[Role] ON 

GO
INSERT [dbo].[Role] ([Id], [Name], [Description]) VALUES (1005, N'Underwriter', N'ddjdhdj')
GO
INSERT [dbo].[Role] ([Id], [Name], [Description]) VALUES (1012, N'Admin', N'dkkdjdkdj')
GO
SET IDENTITY_INSERT [dbo].[Role] OFF
GO
SET IDENTITY_INSERT [dbo].[Tabs] ON 

GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (2, N'Customer', 1, NULL, N'CustPolicy', N'Customers', 1, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (3, N'Proposal Listing', 1, NULL, N'CustPolicy', N'Proposal', 0, N'_proposalLayout')
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (6, N'Policy', 1, NULL, N'CustPolicy', N'Policy', 2, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (7, N'Company Profile', 2, NULL, N'SetUp', N'CompanyProfile', 0, N'_coyProfileLayOut')
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (8, N'Group Name', 2, NULL, N'SetUp', N'Groups', 1, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (9, N'Agents', 2, NULL, N'SetUp', N'Agents', 2, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (10, N'Policy Type', 2, NULL, N'SetUp', N'PolicyType', 3, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (11, N'Life Rate', 2, NULL, N'SetUp', N'LifeRate', 4, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (12, N'Location', 2, NULL, N'SetUp', N'Location', 5, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (13, N'Payments Listing', 3, NULL, N'Payment', N'Listing', 0, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (14, N'Payments Accounts', 2, NULL, N'Payment', N'Accounts', 1, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (15, N'Transaction Post', 3, NULL, N'Payment', N'TransactionPost', 2, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (16, N'Users', 4, NULL, N'UserRole', N'Users', 0, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (17, N'Roles', 4, NULL, N'UserRole', N'Roles', 1, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1016, N'Members Register', 1004, NULL, N'Report', N'MemberRegister', 0, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1017, N'Statement of Account', 1004, NULL, N'Report', N'Statment', 1, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1018, N'Investment History', 1004, NULL, N'Report', N'Investment', 2, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1019, N'Production', 1004, NULL, N'Report', N'Production', 3, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1020, N'Receipt Listing', 1004, NULL, N'Report', N'Reciept', 4, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1021, N'Commission Statement', 1004, NULL, N'Report', N'Commission', 5, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1022, N'Maturity List', 1004, NULL, N'Report', N'MaturityList', 6, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1023, N'Fund Grouping', 1004, NULL, N'Report', N'FundGroup', 7, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1024, N'Claim Calculation', 1005, NULL, N'Claim', N'Calculation', 1, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1025, N'Report', 1005, NULL, N'Claim', N'Report', 2, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1026, N'Claim within Date Range', 1005, NULL, N'Claim', N'ClaimDate', 3, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1027, N'Policy Reactivation', 1005, NULL, N'Claim', N'PolicyReactivation', 4, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (1028, N'Claim Request', 1005, NULL, N'Claim', N'ClaimRequest', 0, NULL)
GO
INSERT [dbo].[Tabs] ([Id], [Name], [PortletId], [icon], [Controller], [Action], [Order], [View]) VALUES (2024, N'Claim Payment', 1005, NULL, N'Claim', N'Payment', 5, NULL)
GO
SET IDENTITY_INSERT [dbo].[Tabs] OFF
GO
SET IDENTITY_INSERT [dbo].[UserRole] ON 

GO
INSERT [dbo].[UserRole] ([Id], [RoleId], [UserId]) VALUES (1, 1005, 2)
GO
INSERT [dbo].[UserRole] ([Id], [RoleId], [UserId]) VALUES (4, 1005, 5)
GO
INSERT [dbo].[UserRole] ([Id], [RoleId], [UserId]) VALUES (10002, 1012, 1)
GO
INSERT [dbo].[UserRole] ([Id], [RoleId], [UserId]) VALUES (10003, 1012, 10002)
GO
SET IDENTITY_INSERT [dbo].[UserRole] OFF
GO
SET IDENTITY_INSERT [dbo].[UserSession] ON 

GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (1, 0, NULL, NULL, NULL, CAST(N'2016-07-27 10:09:42.147' AS DateTime), CAST(N'2016-07-27 10:04:42.143' AS DateTime), NULL, 1, NULL, N'A09A9B9A8E6873465D76C71B3343FF19', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (2, 0, NULL, NULL, NULL, CAST(N'2016-07-27 10:19:03.933' AS DateTime), CAST(N'2016-07-27 10:14:03.933' AS DateTime), NULL, 1, NULL, N'48A37B01B63C5F038BCAD4BBD829DAE7', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (3, 0, NULL, NULL, NULL, CAST(N'2016-07-27 11:04:19.917' AS DateTime), CAST(N'2016-07-27 10:59:19.917' AS DateTime), NULL, 1, NULL, N'57A45AC2F1B1DF499900AD74F6C6064E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (4, 0, NULL, NULL, NULL, CAST(N'2016-07-27 11:25:28.980' AS DateTime), CAST(N'2016-07-27 11:20:28.980' AS DateTime), NULL, 1, NULL, N'C6D125B98A354122CA893726F08C495C', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (5, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:22.250' AS DateTime), CAST(N'2016-07-29 16:53:22.250' AS DateTime), NULL, 1, NULL, N'D029B3A1F47D5642B688BC5365F3258C', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (6, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:27.790' AS DateTime), CAST(N'2016-07-29 16:53:27.790' AS DateTime), NULL, 1, NULL, N'A831AB19AE0D379C0267A10826AE021A', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (7, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:29.133' AS DateTime), CAST(N'2016-07-29 16:53:29.133' AS DateTime), NULL, 1, NULL, N'CB4C70AC1B9DCEBBF2D21CBF176C4F2E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (8, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:29.810' AS DateTime), CAST(N'2016-07-29 16:53:29.810' AS DateTime), NULL, 1, NULL, N'A5983EEB5FE0656817C1737AD2E96D68', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (9, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:31.067' AS DateTime), CAST(N'2016-07-29 16:53:31.067' AS DateTime), NULL, 1, NULL, N'D9F90440DFC084A01E08920DD6948458', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (10, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:31.917' AS DateTime), CAST(N'2016-07-29 16:53:31.917' AS DateTime), NULL, 1, NULL, N'0517709A91B69AC82D0F5B13F51EA8D0', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (11, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:32.840' AS DateTime), CAST(N'2016-07-29 16:53:32.840' AS DateTime), NULL, 1, NULL, N'BE0CEB15915E813DC3A776F07C3052E0', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (12, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:34.967' AS DateTime), CAST(N'2016-07-29 16:53:34.967' AS DateTime), NULL, 1, NULL, N'0DD568B2C9AA3C4AB6D7A141A2155EEE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (13, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:35.470' AS DateTime), CAST(N'2016-07-29 16:53:35.470' AS DateTime), NULL, 1, NULL, N'6EBACD04C426C9FAE57CC5B0252728A1', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (14, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:35.700' AS DateTime), CAST(N'2016-07-29 16:53:35.700' AS DateTime), NULL, 1, NULL, N'0BE877F5CFE7BCDCBDC7C1AF7A1926C1', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (15, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:35.923' AS DateTime), CAST(N'2016-07-29 16:53:35.923' AS DateTime), NULL, 1, NULL, N'B2D48142F0460643D38AE8050E4EC970', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (16, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:36.127' AS DateTime), CAST(N'2016-07-29 16:53:36.127' AS DateTime), NULL, 1, NULL, N'22AA11DC750A709DF723122195545ECE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (17, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:36.353' AS DateTime), CAST(N'2016-07-29 16:53:36.353' AS DateTime), NULL, 1, NULL, N'5EA7FB1DDD90A54799B8A702659AE308', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (18, 0, NULL, NULL, NULL, CAST(N'2016-07-29 16:58:36.573' AS DateTime), CAST(N'2016-07-29 16:53:36.573' AS DateTime), NULL, 1, NULL, N'586D5E183E0546DD6066D165165424C1', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (19, 0, NULL, NULL, NULL, CAST(N'2016-07-30 22:16:01.997' AS DateTime), CAST(N'2016-07-30 22:11:01.997' AS DateTime), NULL, 1, NULL, N'C0B1D8049F36E374D83CA4576EB09471', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (20, 0, NULL, NULL, NULL, CAST(N'2016-08-01 22:56:37.377' AS DateTime), CAST(N'2016-08-01 22:51:37.377' AS DateTime), NULL, 1, NULL, N'EF02A3B885C0ADA3686F2A14DD1DE445', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (21, 0, NULL, NULL, NULL, CAST(N'2016-08-01 22:56:52.127' AS DateTime), CAST(N'2016-08-01 22:51:52.127' AS DateTime), NULL, 1, NULL, N'8E79ED59B918EDA5CBBFF224BAA76BDF', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (22, 0, NULL, NULL, NULL, CAST(N'2016-08-01 22:57:18.730' AS DateTime), CAST(N'2016-08-01 22:52:18.730' AS DateTime), NULL, 1, NULL, N'C98804A5694BB656B8EFFD2BED4DB22D', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (23, 0, NULL, NULL, NULL, CAST(N'2016-08-02 15:29:05.840' AS DateTime), CAST(N'2016-08-02 15:24:05.840' AS DateTime), NULL, 1, NULL, N'1E86DF48863E163B1DAD2503F079A7EF', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (24, 0, NULL, NULL, NULL, CAST(N'2016-08-04 09:25:40.133' AS DateTime), CAST(N'2016-08-04 09:20:40.133' AS DateTime), NULL, 1, NULL, N'E9D051555BFAFE6E95632E68392A453A', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (25, 0, NULL, NULL, NULL, CAST(N'2016-08-04 17:03:46.230' AS DateTime), CAST(N'2016-08-04 16:58:46.230' AS DateTime), NULL, 1, NULL, N'B7451584081929EBD3691CAF51E741D3', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (26, 0, NULL, NULL, NULL, CAST(N'2016-08-04 23:21:15.990' AS DateTime), CAST(N'2016-08-04 23:16:15.990' AS DateTime), NULL, 1, NULL, N'9606189F90FE3F2B30E28934F8DA689F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (27, 0, NULL, NULL, NULL, CAST(N'2016-08-08 13:43:38.297' AS DateTime), CAST(N'2016-08-08 13:38:38.297' AS DateTime), NULL, 1, NULL, N'8E063DD03481B9749AFCEA3B342BC0B8', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (28, 0, NULL, NULL, NULL, CAST(N'2016-08-13 15:52:15.207' AS DateTime), CAST(N'2016-08-13 15:47:15.207' AS DateTime), NULL, 1, NULL, N'29E8C337E66874EB68EF4CA299C34E06', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (29, 0, NULL, NULL, NULL, CAST(N'2016-08-13 20:33:18.270' AS DateTime), CAST(N'2016-08-13 20:28:18.270' AS DateTime), NULL, 1, NULL, N'8A8815D0170909645E1E0F4DDE0EBD23', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30, 0, NULL, NULL, NULL, CAST(N'2016-08-14 09:53:33.120' AS DateTime), CAST(N'2016-08-14 09:48:33.120' AS DateTime), NULL, 1, NULL, N'3E4619C10DFAECFE20D210FF464FA865', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (31, 0, NULL, NULL, NULL, CAST(N'2016-08-14 09:55:45.080' AS DateTime), CAST(N'2016-08-14 09:50:45.080' AS DateTime), NULL, 1, NULL, N'80CAD7477A6C8CDA8394D7A5C679B2DF', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (32, 0, NULL, NULL, NULL, CAST(N'2016-08-14 13:03:49.323' AS DateTime), CAST(N'2016-08-14 12:58:49.323' AS DateTime), NULL, 1, NULL, N'9A2446D167713C68086352426BA400AB', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (33, 0, NULL, NULL, NULL, CAST(N'2016-08-15 12:43:44.967' AS DateTime), CAST(N'2016-08-15 12:38:44.967' AS DateTime), NULL, 1, NULL, N'1DDBDDB05C2C70AD6C91284EE77E206E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (34, 0, NULL, NULL, NULL, CAST(N'2016-08-15 13:35:01.967' AS DateTime), CAST(N'2016-08-15 13:30:01.967' AS DateTime), NULL, 1, NULL, N'DCD106EFA8CE1046A8CF0F1BF57B5AA8', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (35, 0, NULL, NULL, NULL, CAST(N'2016-08-15 16:07:58.597' AS DateTime), CAST(N'2016-08-15 16:02:58.597' AS DateTime), NULL, 1, NULL, N'D2A297F99C37FED91E420D359A44EBE4', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (36, 0, NULL, NULL, NULL, CAST(N'2016-08-15 17:46:07.850' AS DateTime), CAST(N'2016-08-15 17:41:07.847' AS DateTime), NULL, 1, NULL, N'121EF5184667BC96B2D9313007901E1E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (37, 0, NULL, NULL, NULL, CAST(N'2016-08-16 21:52:04.440' AS DateTime), CAST(N'2016-08-16 21:47:04.437' AS DateTime), NULL, 1, NULL, N'506C7D23605F68C49B329F05771F6CCC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (38, 0, NULL, NULL, NULL, CAST(N'2016-08-17 22:23:49.463' AS DateTime), CAST(N'2016-08-17 22:18:49.463' AS DateTime), NULL, 1, NULL, N'A9AAC128B99B25F3C108A1BF06C0ECFE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (39, 0, NULL, NULL, NULL, CAST(N'2016-08-18 16:13:38.627' AS DateTime), CAST(N'2016-08-18 16:08:38.627' AS DateTime), NULL, 1, NULL, N'B440BFA5DCADE80428155B4781F3A6F3', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40, 0, NULL, NULL, NULL, CAST(N'2016-08-20 14:38:39.640' AS DateTime), CAST(N'2016-08-20 14:33:39.640' AS DateTime), NULL, 1, NULL, N'217062961B925B34734C3335FBFD0317', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (41, 0, NULL, NULL, NULL, CAST(N'2016-08-22 22:15:02.060' AS DateTime), CAST(N'2016-08-22 22:10:02.060' AS DateTime), NULL, 1, NULL, N'39C864CF0F506FF518C56CDF5D5498EC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (42, 0, NULL, NULL, NULL, CAST(N'2016-08-22 22:15:08.947' AS DateTime), CAST(N'2016-08-22 22:10:08.947' AS DateTime), NULL, 1, NULL, N'811E7109D795FE3B60760B19696CE452', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (43, 0, NULL, NULL, NULL, CAST(N'2016-08-22 22:20:35.733' AS DateTime), CAST(N'2016-08-22 22:15:35.733' AS DateTime), NULL, 1, NULL, N'D8A1168AC07091262BDECBEAFCFFE8CE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (44, 0, NULL, NULL, NULL, CAST(N'2016-08-22 22:27:55.800' AS DateTime), CAST(N'2016-08-22 22:22:55.800' AS DateTime), NULL, 1, NULL, N'986CD65026E75D11EEDE680A3CD569D0', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (45, 0, NULL, NULL, NULL, CAST(N'2016-08-23 21:49:46.560' AS DateTime), CAST(N'2016-08-23 21:44:46.560' AS DateTime), NULL, 1, NULL, N'63F774049111C25CDC2E2D1FBBC57B95', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (46, 0, NULL, NULL, NULL, CAST(N'2016-08-24 09:16:49.787' AS DateTime), CAST(N'2016-08-24 09:11:49.787' AS DateTime), NULL, 1, NULL, N'98C79F2BCCF94D781176D074332FEDD2', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (47, 0, NULL, NULL, NULL, CAST(N'2016-08-25 21:43:02.997' AS DateTime), CAST(N'2016-08-25 21:38:02.997' AS DateTime), NULL, 1, NULL, N'68F713175ADBA93CE8EBF13319CAC3CB', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (48, 0, NULL, NULL, NULL, CAST(N'2016-08-29 20:58:54.683' AS DateTime), CAST(N'2016-08-29 20:53:54.683' AS DateTime), NULL, 1, NULL, N'3D4F82208C12783899D44380324C3A5C', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (49, 0, NULL, NULL, NULL, CAST(N'2016-09-03 13:54:53.107' AS DateTime), CAST(N'2016-09-03 13:49:53.107' AS DateTime), NULL, 1, NULL, N'3FE1F45136CE7A357D8E7BCD319B0C88', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50, 0, NULL, NULL, NULL, CAST(N'2016-09-03 17:48:42.740' AS DateTime), CAST(N'2016-09-03 17:43:42.740' AS DateTime), NULL, 1, NULL, N'866B7B600B0C7B2E473311AA1649D1C5', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (51, 0, NULL, NULL, NULL, CAST(N'2016-09-05 21:22:19.550' AS DateTime), CAST(N'2016-09-05 21:17:19.550' AS DateTime), NULL, 1, NULL, N'13C7845544B48747EE33233253BF8CAA', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (52, 0, NULL, NULL, NULL, CAST(N'2016-09-07 14:02:36.847' AS DateTime), CAST(N'2016-09-07 13:57:36.847' AS DateTime), NULL, 1, NULL, N'C90C4494A03008B087142F5DDD5E0994', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (53, 0, NULL, NULL, NULL, CAST(N'2016-09-07 18:52:16.407' AS DateTime), CAST(N'2016-09-07 18:47:16.407' AS DateTime), NULL, 1, NULL, N'7E445DADBCF4BE02EAFF886972043689', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (54, 0, NULL, NULL, NULL, CAST(N'2016-09-08 00:04:52.027' AS DateTime), CAST(N'2016-09-07 23:59:52.027' AS DateTime), NULL, 1, NULL, N'D5D5492206598867C8818B8C95DAE298', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (55, 0, NULL, NULL, NULL, CAST(N'2016-09-10 14:10:34.387' AS DateTime), CAST(N'2016-09-10 14:05:34.387' AS DateTime), NULL, 1, NULL, N'EACE2ADB35B7EB8C47AE6BA978874974', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (56, 0, NULL, NULL, NULL, CAST(N'2016-09-14 22:36:24.987' AS DateTime), CAST(N'2016-09-14 22:31:24.987' AS DateTime), NULL, 1, NULL, N'7D9B4A78C13AA416CA48824C733142BE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (57, 0, NULL, NULL, NULL, CAST(N'2016-09-19 18:05:53.310' AS DateTime), CAST(N'2016-09-19 18:00:53.310' AS DateTime), NULL, 1, NULL, N'B7373BE9BC3ED4D7720001CDE5C0644F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (58, 0, NULL, NULL, NULL, CAST(N'2016-09-19 21:45:00.610' AS DateTime), CAST(N'2016-09-19 21:40:00.610' AS DateTime), NULL, 1, NULL, N'734055AC5E6650E95EE20F161E51DBC6', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (59, 0, NULL, NULL, NULL, CAST(N'2016-09-20 13:15:01.583' AS DateTime), CAST(N'2016-09-20 13:10:01.583' AS DateTime), NULL, 1, NULL, N'DF6E6CD10BFF9560F89AFA646D85297D', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60, 0, NULL, NULL, NULL, CAST(N'2016-09-21 22:59:56.280' AS DateTime), CAST(N'2016-09-21 22:54:56.280' AS DateTime), NULL, 1, NULL, N'A67DFE0C52AC07D4D1D667D8713C55A3', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (61, 0, NULL, NULL, NULL, CAST(N'2016-09-22 17:38:18.540' AS DateTime), CAST(N'2016-09-22 17:33:18.540' AS DateTime), NULL, 1, NULL, N'0C309B7D08EF3A9B47FCDF1AA969CB37', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (62, 0, NULL, NULL, NULL, CAST(N'2016-09-22 21:42:57.010' AS DateTime), CAST(N'2016-09-22 21:37:57.010' AS DateTime), NULL, 1, NULL, N'71E9A23C3BAEC9BE13D4F64B1BDA6D8E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (63, 0, NULL, NULL, NULL, CAST(N'2016-09-24 14:36:42.690' AS DateTime), CAST(N'2016-09-24 14:31:42.690' AS DateTime), NULL, 1, NULL, N'0876C7C5F26E4C3B9810F65CB3BEA64D', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (64, 0, NULL, NULL, NULL, CAST(N'2016-09-24 19:02:52.527' AS DateTime), CAST(N'2016-09-24 18:57:52.523' AS DateTime), NULL, 1, NULL, N'0718CC4AD2D4651F043212F8CC743DE2', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (65, 0, NULL, NULL, NULL, CAST(N'2016-09-25 11:08:10.597' AS DateTime), CAST(N'2016-09-25 11:03:10.597' AS DateTime), NULL, 1, NULL, N'60E7B51CE9D7B840649AF1931C5362FC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (66, NULL, NULL, NULL, NULL, CAST(N'2016-09-25 20:50:16.167' AS DateTime), CAST(N'2016-09-25 20:45:16.167' AS DateTime), NULL, 1, NULL, N'B347F23BAF1461D13479F3FAE54F2FA4', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (10063, NULL, NULL, NULL, NULL, CAST(N'2016-10-01 09:54:15.503' AS DateTime), CAST(N'2016-10-01 09:49:15.503' AS DateTime), NULL, 1, NULL, N'09EE27F8D1FE75B62E62EE3F34E60542', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (10064, NULL, NULL, NULL, NULL, CAST(N'2016-10-01 19:28:51.737' AS DateTime), CAST(N'2016-10-01 19:23:51.737' AS DateTime), NULL, 1, NULL, N'AEA26BA82CE93B22BE7BAF8999F136FA', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (20063, NULL, NULL, NULL, NULL, CAST(N'2016-10-02 11:12:46.860' AS DateTime), CAST(N'2016-10-02 11:07:46.860' AS DateTime), NULL, 1, NULL, N'3C3609260F38B63D8E936F8CA924E431', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (20064, NULL, NULL, NULL, NULL, CAST(N'2016-10-02 13:05:50.733' AS DateTime), CAST(N'2016-10-02 13:00:50.733' AS DateTime), NULL, 1, NULL, N'F63F570FC56F274165BCC3D14D69864B', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (20065, NULL, NULL, NULL, NULL, CAST(N'2016-10-02 13:46:23.787' AS DateTime), CAST(N'2016-10-02 13:41:23.787' AS DateTime), NULL, 1, NULL, N'4BD8A3EFFA64D5A96752D4C7CDC5B7FD', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30063, NULL, NULL, NULL, NULL, CAST(N'2016-10-03 12:46:48.180' AS DateTime), CAST(N'2016-10-03 12:41:48.180' AS DateTime), NULL, 1, NULL, N'320C07C4EE5C421D845FCA768C16E8D1', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30064, NULL, NULL, NULL, NULL, CAST(N'2016-10-03 14:30:39.987' AS DateTime), CAST(N'2016-10-03 14:25:39.987' AS DateTime), NULL, 1, NULL, N'53F5DF22DCA4A252D578CBFB034F2FA9', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30065, NULL, NULL, NULL, NULL, CAST(N'2016-10-03 19:30:13.663' AS DateTime), CAST(N'2016-10-03 19:25:13.663' AS DateTime), NULL, 1, NULL, N'8AEF04956EEC4AF9B4B9864674F2DC00', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30066, NULL, NULL, NULL, NULL, CAST(N'2016-10-04 10:19:05.913' AS DateTime), CAST(N'2016-10-04 10:14:05.913' AS DateTime), NULL, 1, NULL, N'987566EB157180AC8106E5B240BABA66', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30067, NULL, NULL, NULL, NULL, CAST(N'2016-10-04 10:51:09.640' AS DateTime), CAST(N'2016-10-04 10:46:09.637' AS DateTime), NULL, 1, NULL, N'588ADEBE03ED7BD061435C2794C45E13', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30068, NULL, NULL, NULL, NULL, CAST(N'2016-10-04 12:24:27.820' AS DateTime), CAST(N'2016-10-04 12:19:27.820' AS DateTime), NULL, 1, NULL, N'E273FBD23AC97C839E29F0D9A73AB09A', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30069, NULL, NULL, NULL, NULL, CAST(N'2016-10-04 16:00:26.447' AS DateTime), CAST(N'2016-10-04 15:55:26.447' AS DateTime), NULL, 1, NULL, N'989114A49E784657FCCCB5C4BA7B3331', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30070, NULL, NULL, NULL, NULL, CAST(N'2016-10-04 16:01:49.657' AS DateTime), CAST(N'2016-10-04 15:56:49.657' AS DateTime), NULL, 1, NULL, N'5CC2FA142969302B72EA73886DBF5C22', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30071, NULL, NULL, NULL, NULL, CAST(N'2016-10-04 16:15:52.040' AS DateTime), CAST(N'2016-10-04 16:10:52.037' AS DateTime), NULL, 1, NULL, N'16E60D9822287185006F44C6CE04DA09', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30072, NULL, NULL, NULL, NULL, CAST(N'2016-10-04 16:21:19.020' AS DateTime), CAST(N'2016-10-04 16:16:19.020' AS DateTime), NULL, 1, NULL, N'FA1374733098DCA150B65DD3F4DAEF4D', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30073, NULL, NULL, NULL, NULL, CAST(N'2016-10-04 16:24:41.127' AS DateTime), CAST(N'2016-10-04 16:19:41.127' AS DateTime), NULL, 1, NULL, N'843501426ADD9DE331417A4DD47C68C7', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30074, NULL, NULL, NULL, NULL, CAST(N'2016-10-04 16:27:27.517' AS DateTime), CAST(N'2016-10-04 16:22:27.517' AS DateTime), NULL, 1, NULL, N'E76622DF611DB19BEF1B406A085CBEC2', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30075, NULL, NULL, NULL, NULL, CAST(N'2016-10-04 16:39:33.060' AS DateTime), CAST(N'2016-10-04 16:34:33.057' AS DateTime), NULL, 1, NULL, N'1468250F7EB112C678F7B3C9B0521E2D', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30076, NULL, NULL, NULL, NULL, CAST(N'2016-10-04 17:45:02.033' AS DateTime), CAST(N'2016-10-04 17:40:02.033' AS DateTime), NULL, 1, NULL, N'18B86F23CC1278BBD1B26229AAFADE48', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30077, NULL, NULL, NULL, NULL, CAST(N'2016-10-04 17:49:26.057' AS DateTime), CAST(N'2016-10-04 17:44:26.057' AS DateTime), NULL, 1, NULL, N'8D175A234FA0DC0F8F6E03D9CB6CA7A4', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30078, 0, CAST(N'2016-10-04 18:06:17.3326538' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 18:11:17.330' AS DateTime), CAST(N'2016-10-04 18:06:17.330' AS DateTime), NULL, 1, NULL, N'9BDD2A7546D09BBEDBA4B65731B21F30', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30079, 0, CAST(N'2016-10-04 18:10:04.3410317' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 18:15:04.340' AS DateTime), CAST(N'2016-10-04 18:10:04.340' AS DateTime), NULL, 6, NULL, N'89E0631A0C82BA2BF108514D1D79ACEB', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30080, 0, CAST(N'2016-10-04 18:10:24.1185186' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 18:15:24.120' AS DateTime), CAST(N'2016-10-04 18:10:24.120' AS DateTime), NULL, 6, NULL, N'3B597F7B1670B0B9FB908C7FD0688059', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30081, 0, CAST(N'2016-10-04 18:40:09.2415387' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 18:45:09.240' AS DateTime), CAST(N'2016-10-04 18:40:09.240' AS DateTime), NULL, 1, NULL, N'0E10A5894A1AC9F80F3A38AB9841855A', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30082, 0, CAST(N'2016-10-04 21:33:07.1340687' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:38:07.133' AS DateTime), CAST(N'2016-10-04 21:33:07.133' AS DateTime), NULL, 6, NULL, N'2EE1D165ECF70BEB5ABCC190030F0A44', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30083, 0, CAST(N'2016-10-04 21:33:46.5589192' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:38:46.560' AS DateTime), CAST(N'2016-10-04 21:33:46.560' AS DateTime), NULL, 6, NULL, N'C34E027CDED27A9640E57056F3D697F4', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30084, 0, CAST(N'2016-10-04 21:33:48.1454006' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:38:48.147' AS DateTime), CAST(N'2016-10-04 21:33:48.147' AS DateTime), NULL, 6, NULL, N'C0BA2DAE8312BA10DBD502C32D701A79', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30085, 0, CAST(N'2016-10-04 21:33:55.1459400' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:38:55.147' AS DateTime), CAST(N'2016-10-04 21:33:55.147' AS DateTime), NULL, 6, NULL, N'E8D9568BE7CDBE4DC4E09B58FCB32F4E', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30086, 0, CAST(N'2016-10-04 21:36:08.5321206' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:41:08.533' AS DateTime), CAST(N'2016-10-04 21:36:08.533' AS DateTime), NULL, 6, NULL, N'EE96B04F842B82F671CC6877BE60E592', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30087, 0, CAST(N'2016-10-04 21:37:39.2010565' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:42:39.200' AS DateTime), CAST(N'2016-10-04 21:37:39.200' AS DateTime), NULL, 1, NULL, N'21053B08CBB9DA650F1FA51F3062D676', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30088, 0, CAST(N'2016-10-04 21:38:12.7179614' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:43:12.717' AS DateTime), CAST(N'2016-10-04 21:38:12.717' AS DateTime), NULL, 6, NULL, N'160110B7E9D075CCB836A64D982927DC', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30089, 0, CAST(N'2016-10-04 21:39:52.5703371' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:44:52.570' AS DateTime), CAST(N'2016-10-04 21:39:52.570' AS DateTime), NULL, 6, NULL, N'7E16A43263ECD7FBB78B404596A9EC56', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30090, 0, CAST(N'2016-10-04 21:41:04.9425136' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:46:04.943' AS DateTime), CAST(N'2016-10-04 21:41:04.943' AS DateTime), NULL, 6, NULL, N'22692668FEF72778F56FEE465CFC2FF7', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30091, 0, CAST(N'2016-10-04 21:46:51.0230341' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:51:51.023' AS DateTime), CAST(N'2016-10-04 21:46:51.023' AS DateTime), NULL, 6, NULL, N'E352490F2538A3BFAD7218FF11CBCE1C', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30092, 0, CAST(N'2016-10-04 21:47:48.3905434' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:52:48.390' AS DateTime), CAST(N'2016-10-04 21:47:48.390' AS DateTime), NULL, 6, NULL, N'DD942CE4333DCC7171EE0C3D2871E41F', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30093, 0, CAST(N'2016-10-04 21:49:57.2501468' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:54:57.250' AS DateTime), CAST(N'2016-10-04 21:49:57.250' AS DateTime), NULL, 6, NULL, N'4F74F08222A04F9A988B273B9C293F32', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30094, 0, CAST(N'2016-10-04 21:51:13.6119461' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 21:56:13.613' AS DateTime), CAST(N'2016-10-04 21:51:13.613' AS DateTime), NULL, 6, NULL, N'1871089D21E87612FFFFE3A31AC4D43F', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30095, 0, CAST(N'2016-10-04 21:57:12.5944438' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 22:02:12.593' AS DateTime), CAST(N'2016-10-04 21:57:12.593' AS DateTime), NULL, 6, NULL, N'8A0909CEA53308D4AE3E51DB3F7A59A9', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30096, 0, CAST(N'2016-10-04 21:57:49.7872052' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 22:02:49.787' AS DateTime), CAST(N'2016-10-04 21:57:49.787' AS DateTime), NULL, 6, NULL, N'0A30A98ED5C4AEE3AADCE1CA6AB34453', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30097, 0, CAST(N'2016-10-04 22:02:38.2041761' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 22:07:38.203' AS DateTime), CAST(N'2016-10-04 22:02:38.200' AS DateTime), NULL, 6, NULL, N'FC609EC3867CCA15D17386177BFE7EE4', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30098, 0, CAST(N'2016-10-04 22:04:27.1156023' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 22:09:27.117' AS DateTime), CAST(N'2016-10-04 22:04:27.117' AS DateTime), NULL, 6, NULL, N'B15E66DE589AE300ABB8ADE93CEBFA08', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30099, 0, CAST(N'2016-10-04 22:07:08.1931440' AS DateTime2), NULL, NULL, CAST(N'2016-10-04 22:12:08.193' AS DateTime), CAST(N'2016-10-04 22:07:08.193' AS DateTime), NULL, 6, NULL, N'43C98068BB8B9533F9CE038D803CD395', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30100, 0, CAST(N'2016-10-06 08:02:22.8669869' AS DateTime2), NULL, NULL, CAST(N'2016-10-06 08:07:22.867' AS DateTime), CAST(N'2016-10-06 08:02:22.867' AS DateTime), NULL, 1, NULL, N'002E4AC145C0388F0D41E0077591BCCC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30101, 0, CAST(N'2016-10-06 10:39:54.5643008' AS DateTime2), NULL, NULL, CAST(N'2016-10-06 10:44:54.563' AS DateTime), CAST(N'2016-10-06 10:39:54.563' AS DateTime), NULL, 1, NULL, N'BFD253D7D340DF6C3DAAFCFF204DBEB5', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30102, 0, CAST(N'2016-10-06 11:42:58.7784665' AS DateTime2), NULL, NULL, CAST(N'2016-10-06 11:47:58.777' AS DateTime), CAST(N'2016-10-06 11:42:58.777' AS DateTime), NULL, 1, NULL, N'814EA63BD53D5F1C4BE7BF6748BB92BB', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30103, 0, CAST(N'2016-10-06 11:43:05.7782043' AS DateTime2), NULL, NULL, CAST(N'2016-10-06 11:48:05.777' AS DateTime), CAST(N'2016-10-06 11:43:05.777' AS DateTime), NULL, 1, NULL, N'7565A83A7123E1C1E3B165F90EF17A3F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30104, 0, CAST(N'2016-10-06 21:05:22.1261186' AS DateTime2), NULL, NULL, CAST(N'2016-10-06 21:10:22.123' AS DateTime), CAST(N'2016-10-06 21:05:22.123' AS DateTime), NULL, 1, NULL, N'9427DEE5D6F9DB27FE4BD154E16F1F6B', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30105, 0, CAST(N'2016-10-06 21:11:58.6509519' AS DateTime2), NULL, NULL, CAST(N'2016-10-06 21:16:58.650' AS DateTime), CAST(N'2016-10-06 21:11:58.650' AS DateTime), NULL, 1, NULL, N'05E5F17A3213C28254CA2EC8472CE652', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30106, 0, CAST(N'2016-10-06 21:48:17.6777573' AS DateTime2), NULL, NULL, CAST(N'2016-10-06 22:04:53.040' AS DateTime), CAST(N'2016-10-06 21:59:53.040' AS DateTime), NULL, 6, NULL, N'32837BB287E9520CCC6E33AE985C3FA6', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30107, 0, CAST(N'2016-10-08 11:21:04.5590151' AS DateTime2), NULL, NULL, CAST(N'2016-10-08 11:26:05.917' AS DateTime), CAST(N'2016-10-08 11:21:05.917' AS DateTime), NULL, 1, NULL, N'C89D7857C622CF62310E302BE4B93286', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30108, 0, CAST(N'2016-10-08 11:33:05.0502408' AS DateTime2), NULL, NULL, CAST(N'2016-10-08 11:38:23.323' AS DateTime), CAST(N'2016-10-08 11:33:23.323' AS DateTime), NULL, 1, NULL, N'64A9DBAD192D2ECE092B2333A28C73CE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30109, 0, CAST(N'2016-10-08 16:14:08.8955979' AS DateTime2), NULL, NULL, CAST(N'2016-10-08 16:22:41.620' AS DateTime), CAST(N'2016-10-08 16:17:41.620' AS DateTime), NULL, 1, NULL, N'F078713386489AD058922780C8393A5F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30110, 0, CAST(N'2016-10-08 16:24:16.9184658' AS DateTime2), NULL, NULL, CAST(N'2016-10-08 16:33:22.210' AS DateTime), CAST(N'2016-10-08 16:28:22.210' AS DateTime), NULL, 1, NULL, N'1B7304563CC0C8B6E53B4B533FA00B67', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30111, 0, CAST(N'2016-10-08 16:53:17.5406226' AS DateTime2), NULL, NULL, CAST(N'2016-10-08 16:58:20.547' AS DateTime), CAST(N'2016-10-08 16:53:20.547' AS DateTime), NULL, 1, NULL, N'B8781C6145F72A38139A6716BF8C3A53', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30112, 0, CAST(N'2016-10-08 17:00:44.5045359' AS DateTime2), NULL, NULL, CAST(N'2016-10-08 17:05:49.937' AS DateTime), CAST(N'2016-10-08 17:00:49.937' AS DateTime), NULL, 1, NULL, N'6BBB8E15175E6B7D9D1000E688CF3BE5', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30113, 0, CAST(N'2016-10-09 08:57:39.6022747' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:02:40.150' AS DateTime), CAST(N'2016-10-09 08:57:40.150' AS DateTime), NULL, 1, NULL, N'C567AD4E21A8E6CC2A2C0FD91135F299', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30114, 0, CAST(N'2016-10-09 08:58:33.6276181' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:03:33.710' AS DateTime), CAST(N'2016-10-09 08:58:33.710' AS DateTime), NULL, 1, NULL, N'8EEC7B9EC78AD19E5C39FDF5A38DA677', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30115, 0, CAST(N'2016-10-09 08:58:55.2025396' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:03:55.230' AS DateTime), CAST(N'2016-10-09 08:58:55.230' AS DateTime), NULL, 1, NULL, N'8F3C3CDAA833B81AA78B2E932AC0D0FC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30116, 0, CAST(N'2016-10-09 09:00:18.8470614' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:05:32.633' AS DateTime), CAST(N'2016-10-09 09:00:32.633' AS DateTime), NULL, 1, NULL, N'EAAFB6B0C3B1C85B963F63B8C1088016', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30117, 0, CAST(N'2016-10-09 09:26:08.5604454' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:31:09.190' AS DateTime), CAST(N'2016-10-09 09:26:09.190' AS DateTime), NULL, 1, NULL, N'435FD8C599D5724ACB1A4F1D712DD8ED', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30118, 0, CAST(N'2016-10-09 09:28:36.9406502' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:33:42.747' AS DateTime), CAST(N'2016-10-09 09:28:42.747' AS DateTime), NULL, 1, NULL, N'638403DD966EEA13F09728E9CF2AB53B', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30119, 0, CAST(N'2016-10-09 09:29:28.3235268' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:34:35.023' AS DateTime), CAST(N'2016-10-09 09:29:35.023' AS DateTime), NULL, 1, NULL, N'D70E619EE9E172FC4381899F8A3B0913', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30120, 0, CAST(N'2016-10-09 09:33:03.7218579' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:38:03.760' AS DateTime), CAST(N'2016-10-09 09:33:03.760' AS DateTime), NULL, 1, NULL, N'A810DFD693DD3EE9DA8729219D2D53D4', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30121, 0, CAST(N'2016-10-09 09:33:34.8761933' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:38:41.577' AS DateTime), CAST(N'2016-10-09 09:33:41.577' AS DateTime), NULL, 1, NULL, N'83E958BAD75C1072532DAB2F5543FCD6', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30122, 0, CAST(N'2016-10-09 09:45:28.1107059' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:50:47.243' AS DateTime), CAST(N'2016-10-09 09:45:47.243' AS DateTime), NULL, 1, NULL, N'BC97EF1823AB9462437262A9D4FB5498', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30123, 0, CAST(N'2016-10-09 09:48:09.3963881' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:53:11.410' AS DateTime), CAST(N'2016-10-09 09:48:11.410' AS DateTime), NULL, 1, NULL, N'590B46E5BFCD9273CD8983D79A6A8422', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30124, 0, CAST(N'2016-10-09 09:48:41.9674561' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:53:56.713' AS DateTime), CAST(N'2016-10-09 09:48:56.713' AS DateTime), NULL, 1, NULL, N'9EA43413D651499F445B671E0F766EBC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30125, 0, CAST(N'2016-10-09 09:49:17.8730635' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:54:21.540' AS DateTime), CAST(N'2016-10-09 09:49:21.540' AS DateTime), NULL, 1, NULL, N'10848D7E61FD8ED20B004B74DEE0E684', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30126, 0, CAST(N'2016-10-09 09:49:38.2790775' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:54:39.563' AS DateTime), CAST(N'2016-10-09 09:49:39.563' AS DateTime), NULL, 1, NULL, N'BEBCFBACF3216EF71560507FEDFBD688', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30127, 0, CAST(N'2016-10-09 09:49:55.6868624' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 09:55:06.903' AS DateTime), CAST(N'2016-10-09 09:50:06.903' AS DateTime), NULL, 1, NULL, N'38B5A68FDB918ECFD509340926A629D0', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30128, 0, CAST(N'2016-10-09 10:04:09.5322147' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 10:11:49.797' AS DateTime), CAST(N'2016-10-09 10:06:49.797' AS DateTime), NULL, 1, NULL, N'ACF5E5EC06EACFF6C9AE7F29F8688E00', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30129, 0, CAST(N'2016-10-09 13:49:00.6326455' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 13:54:18.070' AS DateTime), CAST(N'2016-10-09 13:49:18.070' AS DateTime), NULL, 1, NULL, N'528CAD2578ED172BE9D00611366118B8', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30130, 0, CAST(N'2016-10-09 13:59:09.2255407' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 14:08:32.700' AS DateTime), CAST(N'2016-10-09 14:03:32.700' AS DateTime), NULL, 1, NULL, N'D2CCD91BDAADEB7A95B9EC2B9FBFFF94', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30131, 0, CAST(N'2016-10-09 16:04:00.9679745' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 16:21:31.007' AS DateTime), CAST(N'2016-10-09 16:16:31.007' AS DateTime), NULL, 1, NULL, N'54BA995AE9EEE0C87959D18525E6635A', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30132, 0, CAST(N'2016-10-09 16:48:54.4261899' AS DateTime2), NULL, NULL, CAST(N'2016-10-09 16:57:06.470' AS DateTime), CAST(N'2016-10-09 16:52:06.470' AS DateTime), NULL, 1, NULL, N'E033C0DC23F8F879068E2612625BAA4B', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30133, 0, CAST(N'2016-10-10 22:23:45.1047414' AS DateTime2), NULL, NULL, CAST(N'2016-10-10 22:29:50.797' AS DateTime), CAST(N'2016-10-10 22:24:50.797' AS DateTime), NULL, 1, NULL, N'7B0AB88C2C428CE702B5BE96623D6C6F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30134, 0, CAST(N'2016-10-10 22:35:22.1552181' AS DateTime2), NULL, NULL, CAST(N'2016-10-10 22:40:30.347' AS DateTime), CAST(N'2016-10-10 22:35:30.347' AS DateTime), NULL, 1, NULL, N'80DE9F06A542C47DF35A4B298CB22451', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30135, 0, CAST(N'2016-10-10 22:46:30.3265587' AS DateTime2), NULL, NULL, CAST(N'2016-10-10 23:13:51.827' AS DateTime), CAST(N'2016-10-10 23:08:51.827' AS DateTime), NULL, 1, NULL, N'412E760041808FD71BC2BA4984D10D04', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30136, 0, CAST(N'2016-10-10 23:20:26.8953074' AS DateTime2), NULL, NULL, CAST(N'2016-10-10 23:58:46.440' AS DateTime), CAST(N'2016-10-10 23:53:46.440' AS DateTime), NULL, 1, NULL, N'C4F6134C4AB8C810BBF3FB7C09B3F676', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30137, 0, CAST(N'2016-10-11 10:10:27.3156241' AS DateTime2), NULL, NULL, CAST(N'2016-10-11 10:20:34.950' AS DateTime), CAST(N'2016-10-11 10:15:34.950' AS DateTime), NULL, 1, NULL, N'0F83E83FEDD5067F3E9F732B54DA0F7F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (30138, 0, CAST(N'2016-10-11 10:32:01.6416278' AS DateTime2), NULL, NULL, CAST(N'2016-10-11 10:37:01.693' AS DateTime), CAST(N'2016-10-11 10:32:01.693' AS DateTime), NULL, 1, NULL, N'7BECCDA8991B02719CC5B27024295F1A', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40100, 0, CAST(N'2016-10-13 20:45:51.8124317' AS DateTime2), NULL, NULL, CAST(N'2016-10-13 20:57:38.730' AS DateTime), CAST(N'2016-10-13 20:52:38.730' AS DateTime), NULL, 1, NULL, N'C7713E40766C7CDCE490452028040936', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40101, 0, CAST(N'2016-10-13 21:57:03.6922241' AS DateTime2), NULL, NULL, CAST(N'2016-10-13 22:04:14.727' AS DateTime), CAST(N'2016-10-13 21:59:14.727' AS DateTime), NULL, 1, NULL, N'B9996EB68A628F6B762E354129A518A3', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40102, 0, CAST(N'2016-10-13 22:15:41.1411571' AS DateTime2), NULL, NULL, CAST(N'2016-10-13 22:34:57.580' AS DateTime), CAST(N'2016-10-13 22:29:57.580' AS DateTime), NULL, 1, NULL, N'B0B6DA01D3EE666931C39A0D9F75BCB4', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40103, 0, CAST(N'2016-10-13 22:36:11.6186168' AS DateTime2), NULL, NULL, CAST(N'2016-10-13 22:48:35.980' AS DateTime), CAST(N'2016-10-13 22:43:35.980' AS DateTime), NULL, 1, NULL, N'ECCC3F786D85392B7C7F1438DC0A620A', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40104, 0, CAST(N'2016-10-13 23:30:20.5533311' AS DateTime2), NULL, NULL, CAST(N'2016-10-13 23:37:29.587' AS DateTime), CAST(N'2016-10-13 23:32:29.587' AS DateTime), NULL, 1, NULL, N'E7E81C8361109763839CAABF3C312A76', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40105, 0, CAST(N'2016-10-14 11:55:57.6603508' AS DateTime2), NULL, NULL, CAST(N'2016-10-14 12:10:25.970' AS DateTime), CAST(N'2016-10-14 12:05:25.970' AS DateTime), NULL, 1, NULL, N'7D6811A5D202299C95095F179728E442', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40106, 0, CAST(N'2016-10-14 12:36:26.0197935' AS DateTime2), NULL, NULL, CAST(N'2016-10-14 12:41:53.620' AS DateTime), CAST(N'2016-10-14 12:36:53.620' AS DateTime), NULL, 1, NULL, N'A803C702302825044E074F2136742D46', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40107, 0, CAST(N'2016-10-14 13:21:56.9783249' AS DateTime2), NULL, NULL, CAST(N'2016-10-14 13:27:21.267' AS DateTime), CAST(N'2016-10-14 13:22:21.267' AS DateTime), NULL, 1, NULL, N'3CF98F61CADBD2B787E71DF5D9A389BF', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40108, 0, CAST(N'2016-10-14 13:31:16.7093491' AS DateTime2), NULL, NULL, CAST(N'2016-10-14 13:37:12.717' AS DateTime), CAST(N'2016-10-14 13:32:12.717' AS DateTime), NULL, 1, NULL, N'447F8E1C96B5575B02988FEF1AFCB43B', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40109, 0, CAST(N'2016-10-14 15:03:00.2031932' AS DateTime2), NULL, NULL, CAST(N'2016-10-14 15:08:01.160' AS DateTime), CAST(N'2016-10-14 15:03:01.160' AS DateTime), NULL, 1, NULL, N'D898033B927BF21D40466AE4966D90D6', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40110, 0, CAST(N'2016-10-14 15:09:56.8972363' AS DateTime2), NULL, NULL, CAST(N'2016-10-14 15:15:12.397' AS DateTime), CAST(N'2016-10-14 15:10:12.397' AS DateTime), NULL, 1, NULL, N'7091025AAEDB90C07E387B99A828D51B', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40111, 0, CAST(N'2016-10-14 16:48:50.6552396' AS DateTime2), NULL, NULL, CAST(N'2016-10-14 16:53:52.547' AS DateTime), CAST(N'2016-10-14 16:48:52.547' AS DateTime), NULL, 1, NULL, N'879AAEC830467B242CAACBE6E25D6C5F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40112, 0, CAST(N'2016-10-15 07:01:42.1369273' AS DateTime2), NULL, NULL, CAST(N'2016-10-15 07:06:57.147' AS DateTime), CAST(N'2016-10-15 07:01:57.147' AS DateTime), NULL, 1, NULL, N'3A74FF58C8807593F9FC33BE9B798B93', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40113, 0, CAST(N'2016-10-15 09:15:12.4328158' AS DateTime2), NULL, NULL, CAST(N'2016-10-15 09:42:26.720' AS DateTime), CAST(N'2016-10-15 09:37:26.720' AS DateTime), NULL, 1, NULL, N'BF5C96F02819DB6CFEC5B823DC249085', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40114, 0, CAST(N'2016-10-15 10:25:26.7130410' AS DateTime2), NULL, NULL, CAST(N'2016-10-15 10:30:32.587' AS DateTime), CAST(N'2016-10-15 10:25:32.587' AS DateTime), NULL, 1, NULL, N'EDC3A9833C3E883DC05CE3B0DE4E154A', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40115, 0, CAST(N'2016-10-15 11:03:12.8472776' AS DateTime2), NULL, NULL, CAST(N'2016-10-15 11:09:11.587' AS DateTime), CAST(N'2016-10-15 11:04:11.587' AS DateTime), NULL, 1, NULL, N'FDA92AC74108D44285446C2B83CAE782', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40116, 0, CAST(N'2016-10-15 11:10:26.3651483' AS DateTime2), NULL, NULL, CAST(N'2016-10-15 11:28:05.520' AS DateTime), CAST(N'2016-10-15 11:23:05.520' AS DateTime), NULL, 1, NULL, N'11589375BBB1325F3165067427813CCB', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40117, 0, CAST(N'2016-10-15 11:28:37.9413394' AS DateTime2), NULL, NULL, CAST(N'2016-10-15 11:36:45.670' AS DateTime), CAST(N'2016-10-15 11:31:45.670' AS DateTime), NULL, 1, NULL, N'2250A8D28636575958EBF1377933C51F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40118, 0, CAST(N'2016-10-15 12:23:12.5675974' AS DateTime2), NULL, NULL, CAST(N'2016-10-15 12:36:08.563' AS DateTime), CAST(N'2016-10-15 12:31:08.563' AS DateTime), NULL, 1, NULL, N'9CC50A3C96165E602CFA4D7CEAFAD1C6', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40119, 0, CAST(N'2016-10-15 13:07:56.1182483' AS DateTime2), NULL, NULL, CAST(N'2016-10-15 13:25:43.843' AS DateTime), CAST(N'2016-10-15 13:20:43.843' AS DateTime), NULL, 1, NULL, N'16DD7EF51FDDCA68A457367B299F1641', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40120, 0, CAST(N'2016-10-15 13:55:12.5415495' AS DateTime2), NULL, NULL, CAST(N'2016-10-15 14:00:59.057' AS DateTime), CAST(N'2016-10-15 13:55:59.057' AS DateTime), NULL, 1, NULL, N'63A0929865776D4852F93B9AD0A30997', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40121, NULL, NULL, NULL, 10, CAST(N'2016-10-15 21:04:14.480' AS DateTime), CAST(N'2016-10-15 20:59:14.477' AS DateTime), NULL, 6, NULL, N'970BD9E570AC8E50BBAFBDB0DF15E1C3', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40122, NULL, NULL, NULL, 10, CAST(N'2016-10-15 21:05:36.253' AS DateTime), CAST(N'2016-10-15 21:00:36.253' AS DateTime), NULL, 6, NULL, N'8589B1D1EBCF171B042DDF9F0EFB53C5', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40123, NULL, NULL, NULL, 10, CAST(N'2016-10-15 21:06:06.207' AS DateTime), CAST(N'2016-10-15 21:01:06.207' AS DateTime), NULL, 6, NULL, N'E48A86F389D6846FF80DD17EE3E87C50', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40124, NULL, NULL, NULL, 10, CAST(N'2016-10-15 21:07:37.167' AS DateTime), CAST(N'2016-10-15 21:02:37.167' AS DateTime), NULL, 6, NULL, N'DEFA254608D853049193E43888E00ED2', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40125, NULL, NULL, NULL, 10, CAST(N'2016-10-15 21:38:43.640' AS DateTime), CAST(N'2016-10-15 21:33:43.637' AS DateTime), NULL, 6, NULL, N'4DD5303806AF91EB83DADE553F5A2143', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40126, NULL, NULL, NULL, 10, CAST(N'2016-10-15 21:41:11.603' AS DateTime), CAST(N'2016-10-15 21:36:11.600' AS DateTime), NULL, 6, NULL, N'F1DFA3B9A978A15FA23D116CEBBF4C40', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40127, NULL, NULL, NULL, 10, CAST(N'2016-10-15 21:44:11.060' AS DateTime), CAST(N'2016-10-15 21:39:11.060' AS DateTime), NULL, 6, NULL, N'412F033324F9E6B913F75C8BE2E95846', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40128, NULL, NULL, NULL, 10, CAST(N'2016-10-15 21:46:34.737' AS DateTime), CAST(N'2016-10-15 21:41:34.737' AS DateTime), NULL, 6, NULL, N'2967C563352A41DEDD352E5F5B8C3097', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40129, NULL, NULL, NULL, 10, CAST(N'2016-10-15 23:29:44.247' AS DateTime), CAST(N'2016-10-15 23:24:44.247' AS DateTime), NULL, 6, NULL, N'006D464411B30642B6D21E63A9A0CD17', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40130, NULL, NULL, NULL, 10, CAST(N'2016-10-15 23:30:07.577' AS DateTime), CAST(N'2016-10-15 23:25:07.577' AS DateTime), NULL, 6, NULL, N'162A93EAD688D6712822EEF629CD2FC0', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40131, NULL, NULL, NULL, 10, CAST(N'2016-10-15 23:32:36.030' AS DateTime), CAST(N'2016-10-15 23:27:36.030' AS DateTime), NULL, 6, NULL, N'CF4F7904207082A5B6B943A720130A3C', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40132, NULL, NULL, NULL, 10, CAST(N'2016-10-15 23:35:54.877' AS DateTime), CAST(N'2016-10-15 23:30:54.877' AS DateTime), NULL, 6, NULL, N'D8D4ACF63004BAE32D2A9847779D84B5', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40133, NULL, NULL, NULL, 10, CAST(N'2016-10-15 23:37:35.423' AS DateTime), CAST(N'2016-10-15 23:32:35.423' AS DateTime), NULL, 6, NULL, N'AA3B9F0812CFBA5C5DDDFEFAC6E6B7BF', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40134, NULL, NULL, NULL, 10, CAST(N'2016-10-15 23:41:36.807' AS DateTime), CAST(N'2016-10-15 23:36:36.807' AS DateTime), NULL, 6, NULL, N'5D2DE8F4E378FD50AD095D56262AA18D', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40135, NULL, NULL, NULL, 10, CAST(N'2016-10-15 23:44:56.157' AS DateTime), CAST(N'2016-10-15 23:39:56.157' AS DateTime), NULL, 6, NULL, N'BA4E5F01B388DF0D27A0109D705DCC4C', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40136, NULL, NULL, NULL, 10, CAST(N'2016-10-15 23:45:29.203' AS DateTime), CAST(N'2016-10-15 23:40:29.203' AS DateTime), NULL, 6, NULL, N'8C1C8EB3E9DFEFB88859B3F44184E04C', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40137, 0, CAST(N'2016-10-15 23:47:23.8910008' AS DateTime2), NULL, 10, CAST(N'2016-10-15 23:55:42.853' AS DateTime), CAST(N'2016-10-15 23:50:42.537' AS DateTime), NULL, 6, NULL, N'9D46934977FBFDDB2D5D946E3661C824', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40138, 0, CAST(N'2016-10-15 23:54:17.8494529' AS DateTime2), NULL, 10, CAST(N'2016-10-15 23:59:35.970' AS DateTime), CAST(N'2016-10-15 23:54:35.970' AS DateTime), NULL, 6, NULL, N'EE990B3E18F6D3B8F1EC5C3E48B04859', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40139, 0, CAST(N'2016-10-16 14:27:37.9839115' AS DateTime2), NULL, 10, CAST(N'2016-10-16 14:32:37.983' AS DateTime), CAST(N'2016-10-16 14:27:37.983' AS DateTime), NULL, 6, NULL, N'AE9D5D75420285CA4C2C89DF8DD4536B', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40140, 0, CAST(N'2016-10-16 14:27:49.1125513' AS DateTime2), NULL, 10, CAST(N'2016-10-16 14:32:49.113' AS DateTime), CAST(N'2016-10-16 14:27:49.113' AS DateTime), NULL, 6, NULL, N'4A50159301FF7BECC994A041140B4F34', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40141, 0, CAST(N'2016-10-16 14:30:23.4347645' AS DateTime2), NULL, 10, CAST(N'2016-10-16 14:35:23.437' AS DateTime), CAST(N'2016-10-16 14:30:23.437' AS DateTime), NULL, 6, NULL, N'380D76F5CAF6BB22DFAA070B17C1D33A', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40142, 0, CAST(N'2016-10-16 14:30:35.8373946' AS DateTime2), NULL, 10, CAST(N'2016-10-16 14:35:35.837' AS DateTime), CAST(N'2016-10-16 14:30:35.837' AS DateTime), NULL, 6, NULL, N'EE4F4C75DE37E209B95C0C9BB3934B1F', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40143, 0, CAST(N'2016-10-16 14:33:56.2449703' AS DateTime2), NULL, 10, CAST(N'2016-10-16 14:38:56.247' AS DateTime), CAST(N'2016-10-16 14:33:56.247' AS DateTime), NULL, 6, NULL, N'0C9CC43B3C8CE0C896054220E00D72AC', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40144, 0, CAST(N'2016-10-16 14:37:28.0919645' AS DateTime2), NULL, 10, CAST(N'2016-10-16 14:42:48.593' AS DateTime), CAST(N'2016-10-16 14:37:48.593' AS DateTime), NULL, 6, NULL, N'8202DA18895E78A76980729096A620C7', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40145, 0, CAST(N'2016-10-16 14:38:09.7661629' AS DateTime2), NULL, 10, CAST(N'2016-10-16 14:43:09.767' AS DateTime), CAST(N'2016-10-16 14:38:09.767' AS DateTime), NULL, 1, NULL, N'6C87F95B9664A37CFAC6C2FD2ABAA5CB', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40146, 0, CAST(N'2016-10-16 14:38:22.8151348' AS DateTime2), NULL, 10, CAST(N'2016-10-16 14:43:22.817' AS DateTime), CAST(N'2016-10-16 14:38:22.817' AS DateTime), NULL, 1, NULL, N'5D62E2CD1EC4A1751C6C2D1AE6BB9937', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40147, 0, CAST(N'2016-10-16 14:38:51.6708945' AS DateTime2), NULL, 10, CAST(N'2016-10-16 14:43:51.670' AS DateTime), CAST(N'2016-10-16 14:38:51.670' AS DateTime), NULL, 1, NULL, N'F9D86BC6FC2578E822E7481B1B4538C3', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40148, 0, CAST(N'2016-10-16 14:40:43.3273805' AS DateTime2), NULL, 10, CAST(N'2016-10-16 14:45:43.327' AS DateTime), CAST(N'2016-10-16 14:40:43.327' AS DateTime), NULL, 1, NULL, N'ACD2DE85C2C1470EFEA9D1CDDD671AC6', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40149, 0, CAST(N'2016-10-16 14:45:11.9278302' AS DateTime2), NULL, 10, CAST(N'2016-10-16 15:02:06.037' AS DateTime), CAST(N'2016-10-16 14:57:06.037' AS DateTime), NULL, 1, NULL, N'1E52B2E2217C23FF3613CEE878602F72', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40150, 0, CAST(N'2016-10-16 15:18:46.8368496' AS DateTime2), NULL, 10, CAST(N'2016-10-16 15:23:47.147' AS DateTime), CAST(N'2016-10-16 15:18:47.147' AS DateTime), NULL, 1, NULL, N'D46B8F06B94143872010256AC2E2BDD8', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40151, 0, CAST(N'2016-10-16 15:22:54.3274532' AS DateTime2), NULL, 10, CAST(N'2016-10-16 15:27:54.373' AS DateTime), CAST(N'2016-10-16 15:22:54.373' AS DateTime), NULL, 1, NULL, N'AB9C232E74E0938330023558AFDDC691', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40152, 0, CAST(N'2016-10-16 15:23:02.8184242' AS DateTime2), NULL, 10, CAST(N'2016-10-16 15:39:32.633' AS DateTime), CAST(N'2016-10-16 15:34:32.633' AS DateTime), NULL, 1, NULL, N'407E180479FB50AB3D2D4201D4AEA67C', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (40153, 0, CAST(N'2016-10-16 15:36:49.9309888' AS DateTime2), NULL, 10017, CAST(N'2016-10-16 15:42:17.717' AS DateTime), CAST(N'2016-10-16 15:37:17.717' AS DateTime), NULL, 6, NULL, N'4BB8B2C55356F72656C3D239D9B7CB75', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50121, 0, CAST(N'2016-10-17 18:15:08.9648853' AS DateTime2), NULL, 10, CAST(N'2016-10-17 18:20:15.423' AS DateTime), CAST(N'2016-10-17 18:15:15.423' AS DateTime), NULL, 1, NULL, N'522958425556BA3094E52B5C76C6AB94', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50122, 0, CAST(N'2016-10-17 18:18:06.5667770' AS DateTime2), NULL, 10017, CAST(N'2016-10-17 18:23:06.627' AS DateTime), CAST(N'2016-10-17 18:18:06.627' AS DateTime), NULL, 1, NULL, N'AC198520098C12CA8A1F5C82B4A43220', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50123, 0, CAST(N'2016-10-17 18:24:41.6535539' AS DateTime2), NULL, 10017, CAST(N'2016-10-17 18:40:08.420' AS DateTime), CAST(N'2016-10-17 18:35:08.420' AS DateTime), NULL, 1, NULL, N'52A423C8D38738C672DC43FAB614B7EE', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50124, 0, CAST(N'2016-10-17 21:26:18.9628274' AS DateTime2), NULL, 10017, CAST(N'2016-10-17 21:31:19.937' AS DateTime), CAST(N'2016-10-17 21:26:19.937' AS DateTime), NULL, 1, NULL, N'11958B2FCF28194D264C14F817A0D49C', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50125, 0, CAST(N'2016-10-17 21:38:31.6178778' AS DateTime2), NULL, 10017, CAST(N'2016-10-17 21:43:41.177' AS DateTime), CAST(N'2016-10-17 21:38:41.177' AS DateTime), NULL, 1, NULL, N'F62EA5F5FE7ECD0CE3F1C849A1BC1775', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50126, 0, CAST(N'2016-10-17 21:50:40.9990087' AS DateTime2), NULL, NULL, CAST(N'2016-10-17 21:56:04.213' AS DateTime), CAST(N'2016-10-17 21:51:04.213' AS DateTime), NULL, 1, NULL, N'F8BC6F4478D642BE06F53A6B3191F211', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50127, 0, CAST(N'2016-10-17 22:08:51.7621487' AS DateTime2), NULL, 10017, CAST(N'2016-10-17 22:23:30.280' AS DateTime), CAST(N'2016-10-17 22:18:30.280' AS DateTime), NULL, 1, NULL, N'62F64D35813631FE16FB25DBFF2747B8', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50128, 0, CAST(N'2016-10-17 22:23:37.4800865' AS DateTime2), NULL, 10017, CAST(N'2016-10-17 22:35:18.463' AS DateTime), CAST(N'2016-10-17 22:30:18.463' AS DateTime), NULL, 1, NULL, N'6AEBFA32E2372427B68248E1CEDB15E7', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50129, 0, CAST(N'2016-10-17 22:41:17.8699179' AS DateTime2), NULL, 10017, CAST(N'2016-10-17 23:03:27.317' AS DateTime), CAST(N'2016-10-17 22:58:27.317' AS DateTime), NULL, 1, NULL, N'3FCE7ABDFE926AED8A288B5CC697996E', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50130, 0, CAST(N'2016-10-17 23:06:48.7771768' AS DateTime2), NULL, 14, CAST(N'2016-10-17 23:19:11.277' AS DateTime), CAST(N'2016-10-17 23:14:11.277' AS DateTime), NULL, 6, NULL, N'01A453B1F65F889161FD62E62B1F4B4A', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50131, 0, CAST(N'2016-10-17 23:14:58.2486196' AS DateTime2), NULL, 14, CAST(N'2016-10-17 23:27:58.673' AS DateTime), CAST(N'2016-10-17 23:22:58.673' AS DateTime), NULL, 1, NULL, N'430DD98B98E77F0BEA6E703046E92A50', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50132, 0, CAST(N'2016-10-18 21:16:50.7467762' AS DateTime2), NULL, 10017, CAST(N'2016-10-18 21:22:00.077' AS DateTime), CAST(N'2016-10-18 21:17:00.077' AS DateTime), NULL, 1, NULL, N'A2BB968FD685C063F7BF1188FF78E66E', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50133, 0, CAST(N'2016-10-18 21:19:25.2744979' AS DateTime2), NULL, 14, CAST(N'2016-10-18 21:33:32.290' AS DateTime), CAST(N'2016-10-18 21:28:32.290' AS DateTime), NULL, 1, NULL, N'1E8DD78BCC814413203895653959C93E', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50134, 0, CAST(N'2016-10-18 22:01:09.9644179' AS DateTime2), NULL, 14, CAST(N'2016-10-18 22:11:28.373' AS DateTime), CAST(N'2016-10-18 22:06:28.373' AS DateTime), NULL, 1, NULL, N'2B3371F7151FBC50BF88CBCE9A826982', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50135, 0, CAST(N'2016-10-19 20:38:56.9572562' AS DateTime2), NULL, 14, CAST(N'2016-10-19 20:44:05.957' AS DateTime), CAST(N'2016-10-19 20:39:05.957' AS DateTime), NULL, 1, NULL, N'5E8DE50CAB12D1625F2170089E01DB8C', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50136, 0, CAST(N'2016-10-19 20:45:29.2162942' AS DateTime2), NULL, 14, CAST(N'2016-10-19 20:53:43.217' AS DateTime), CAST(N'2016-10-19 20:48:43.217' AS DateTime), NULL, 1, NULL, N'E227B02EF22E7ADF702FC742F3C045FF', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50137, 0, CAST(N'2016-10-19 20:47:11.2013409' AS DateTime2), NULL, NULL, CAST(N'2016-10-19 20:53:17.407' AS DateTime), CAST(N'2016-10-19 20:48:17.407' AS DateTime), NULL, 1, NULL, N'4C9EFE1BDB46B9CEDE84AA16CD3B9395', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50138, 0, CAST(N'2016-10-19 21:09:01.6727547' AS DateTime2), NULL, 14, CAST(N'2016-10-19 21:14:02.567' AS DateTime), CAST(N'2016-10-19 21:09:02.567' AS DateTime), NULL, 1, NULL, N'3FFE0766A5CEA1CC8E9370486906F4FC', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50139, 0, CAST(N'2016-10-19 21:20:53.0946787' AS DateTime2), NULL, 14, CAST(N'2016-10-19 21:38:26.927' AS DateTime), CAST(N'2016-10-19 21:33:26.927' AS DateTime), NULL, 1, NULL, N'49F42A21F5F798FB32CB95D856C4E9BD', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50140, 0, CAST(N'2016-10-19 21:39:51.5419918' AS DateTime2), NULL, 14, CAST(N'2016-10-19 21:47:32.770' AS DateTime), CAST(N'2016-10-19 21:42:32.770' AS DateTime), NULL, 1, NULL, N'B3F3957DFEB8EE202E3EDA7023B4C00F', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50141, 0, CAST(N'2016-10-19 22:16:06.8060884' AS DateTime2), NULL, 14, CAST(N'2016-10-19 22:31:14.267' AS DateTime), CAST(N'2016-10-19 22:26:14.267' AS DateTime), NULL, 1, NULL, N'12864BE25BAA88526B3F00212521A266', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50142, 0, CAST(N'2016-10-20 09:31:34.9530758' AS DateTime2), NULL, NULL, CAST(N'2016-10-20 09:37:35.020' AS DateTime), CAST(N'2016-10-20 09:32:35.020' AS DateTime), NULL, 1, NULL, N'648A7D838D16D2A72647C1ECEC8FC901', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50143, 0, CAST(N'2016-10-20 16:59:04.3015208' AS DateTime2), NULL, NULL, CAST(N'2016-10-20 17:04:17.850' AS DateTime), CAST(N'2016-10-20 16:59:17.850' AS DateTime), NULL, 1, NULL, N'89B682C9EDC6345E5F16E8D97BF80A67', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50144, 0, CAST(N'2016-10-20 17:12:59.1526616' AS DateTime2), NULL, NULL, CAST(N'2016-10-20 17:32:22.077' AS DateTime), CAST(N'2016-10-20 17:27:22.077' AS DateTime), NULL, 1, NULL, N'44D046844968B06C9107660F5DD0D327', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50145, 0, CAST(N'2016-10-20 17:41:00.7704080' AS DateTime2), NULL, NULL, CAST(N'2016-10-20 17:46:51.970' AS DateTime), CAST(N'2016-10-20 17:41:51.970' AS DateTime), NULL, 1, NULL, N'73E7470F662A6F1B7515203323BE187E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50146, 0, CAST(N'2016-10-20 18:00:58.2297773' AS DateTime2), NULL, NULL, CAST(N'2016-10-20 18:09:51.930' AS DateTime), CAST(N'2016-10-20 18:04:51.930' AS DateTime), NULL, 1, NULL, N'6A5597C73EE676041E66B9BCEF0CF4CE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50147, 0, CAST(N'2016-10-20 21:53:38.6790337' AS DateTime2), NULL, 14, CAST(N'2016-10-20 22:19:05.980' AS DateTime), CAST(N'2016-10-20 22:14:05.980' AS DateTime), NULL, 1, NULL, N'DFE34FE600805366CCF7D433AD70E440', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50148, 0, CAST(N'2016-10-20 22:05:17.4676407' AS DateTime2), NULL, NULL, CAST(N'2016-10-20 22:13:43.580' AS DateTime), CAST(N'2016-10-20 22:08:43.580' AS DateTime), NULL, 1, NULL, N'5C9B9CC426459733816FF9703E4569D8', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50149, 0, CAST(N'2016-10-20 22:15:17.6896629' AS DateTime2), NULL, NULL, CAST(N'2016-10-20 22:31:59.670' AS DateTime), CAST(N'2016-10-20 22:26:59.670' AS DateTime), NULL, 1, NULL, N'AC72218162D29FA8E590234F336ADB5B', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50150, 0, CAST(N'2016-10-20 22:23:57.5696481' AS DateTime2), NULL, NULL, CAST(N'2016-10-20 22:33:51.367' AS DateTime), CAST(N'2016-10-20 22:28:51.367' AS DateTime), NULL, 1, NULL, N'D947A3DBEECABCB521C6F2F738ABC2CC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (50151, 0, CAST(N'2016-10-20 22:28:03.7851145' AS DateTime2), NULL, NULL, CAST(N'2016-10-20 22:33:30.917' AS DateTime), CAST(N'2016-10-20 22:28:30.917' AS DateTime), NULL, 1, NULL, N'2DB2B372753100228C67086C3016E5D4', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60135, 0, CAST(N'2016-10-24 20:45:40.5479486' AS DateTime2), NULL, NULL, CAST(N'2016-10-24 21:03:07.517' AS DateTime), CAST(N'2016-10-24 20:58:07.517' AS DateTime), NULL, 1, NULL, N'9F840A56DC91B6ABE34E6CC4A12D9B2F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60136, 0, CAST(N'2016-10-24 21:51:36.5585534' AS DateTime2), NULL, NULL, CAST(N'2016-10-24 21:56:37.717' AS DateTime), CAST(N'2016-10-24 21:51:37.717' AS DateTime), NULL, 1, NULL, N'DC800E9E96106D9270DC63E5E6325C0E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60137, 0, CAST(N'2016-10-24 22:06:42.0542417' AS DateTime2), NULL, NULL, CAST(N'2016-10-24 22:24:11.970' AS DateTime), CAST(N'2016-10-24 22:19:11.970' AS DateTime), NULL, 1, NULL, N'E20BB18E314D5AFC3E2DCBE12203BC7C', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60138, 0, CAST(N'2016-10-24 22:35:58.4571954' AS DateTime2), NULL, NULL, CAST(N'2016-10-24 23:00:06.953' AS DateTime), CAST(N'2016-10-24 22:55:06.953' AS DateTime), NULL, 1, NULL, N'DD5F6402779602EF1F14659BE10EE231', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60139, 0, CAST(N'2016-10-24 23:23:48.3974516' AS DateTime2), NULL, NULL, CAST(N'2016-10-24 23:36:07.813' AS DateTime), CAST(N'2016-10-24 23:31:07.813' AS DateTime), NULL, 1, NULL, N'0C264A04DF5CF5D7BBC941B2AA6F21D0', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60140, 0, CAST(N'2016-10-25 21:46:54.9277560' AS DateTime2), NULL, 14, CAST(N'2016-10-25 21:52:05.467' AS DateTime), CAST(N'2016-10-25 21:47:05.467' AS DateTime), NULL, 1, NULL, N'49E076DFF622434AE8A064E085DCC16E', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60141, 0, CAST(N'2016-10-25 22:30:52.4406074' AS DateTime2), NULL, 14, CAST(N'2016-10-25 22:35:57.400' AS DateTime), CAST(N'2016-10-25 22:30:57.400' AS DateTime), NULL, 1, NULL, N'1606835CAF72525D326B9CD7C8D6C815', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60142, 0, CAST(N'2016-10-26 20:37:09.8439778' AS DateTime2), NULL, NULL, CAST(N'2016-10-26 20:43:24.840' AS DateTime), CAST(N'2016-10-26 20:38:24.840' AS DateTime), NULL, 1, NULL, N'188DE364A2B3E3D5DFA74F183D23FE08', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60143, 0, CAST(N'2016-10-26 20:43:48.7033995' AS DateTime2), NULL, NULL, CAST(N'2016-10-26 20:52:58.710' AS DateTime), CAST(N'2016-10-26 20:47:58.710' AS DateTime), NULL, 1, NULL, N'47F2897311F1B35FDC60361EF081D3B1', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60144, 0, CAST(N'2016-10-26 21:01:48.4403995' AS DateTime2), NULL, NULL, CAST(N'2016-10-26 21:22:36.130' AS DateTime), CAST(N'2016-10-26 21:17:36.130' AS DateTime), NULL, 1, NULL, N'79C591EBB33673CC632D6B02BDD90E26', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60145, 0, CAST(N'2016-10-26 21:24:02.3663970' AS DateTime2), NULL, NULL, CAST(N'2016-10-26 21:31:22.280' AS DateTime), CAST(N'2016-10-26 21:26:22.280' AS DateTime), NULL, 1, NULL, N'F46C935F5A13C8EB750BDC45D6E4AFF3', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60146, 0, CAST(N'2016-10-26 21:35:57.7434334' AS DateTime2), NULL, NULL, CAST(N'2016-10-26 21:49:47.213' AS DateTime), CAST(N'2016-10-26 21:44:47.213' AS DateTime), NULL, 1, NULL, N'62D4143ADD6531D56E2737B65A612613', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60147, 0, CAST(N'2016-10-29 18:29:36.8850879' AS DateTime2), NULL, NULL, CAST(N'2016-10-29 18:34:45.967' AS DateTime), CAST(N'2016-10-29 18:29:45.967' AS DateTime), NULL, 1, NULL, N'ACE80E12BED0137BDADC4A7EC6E4C1D2', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60148, 0, CAST(N'2016-10-29 18:45:11.6847959' AS DateTime2), NULL, NULL, CAST(N'2016-10-29 18:50:16.077' AS DateTime), CAST(N'2016-10-29 18:45:16.077' AS DateTime), NULL, 1, NULL, N'83647942007E17B4B0291522228C5646', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60149, 0, CAST(N'2016-10-29 20:22:19.8440371' AS DateTime2), NULL, NULL, CAST(N'2016-10-29 20:27:23.490' AS DateTime), CAST(N'2016-10-29 20:22:23.490' AS DateTime), NULL, 1, NULL, N'41F695D37E71191E23915B5BA12D0A56', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60150, 0, CAST(N'2016-10-30 06:48:02.9498775' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 07:17:29.037' AS DateTime), CAST(N'2016-10-30 07:12:29.037' AS DateTime), NULL, 1, NULL, N'A27E6F2C185CD9A0763B88097F521A83', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60151, 0, CAST(N'2016-10-30 07:25:09.5209238' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 07:55:01.627' AS DateTime), CAST(N'2016-10-30 07:50:01.627' AS DateTime), NULL, 1, NULL, N'0B1CE33F96205EE2B81FBF7F3BD6C8E5', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60152, 0, CAST(N'2016-10-30 07:59:20.0843823' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 08:05:17.547' AS DateTime), CAST(N'2016-10-30 08:00:17.547' AS DateTime), NULL, 1, NULL, N'C5B0C0F6B843794765FF78E271D4A80F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60153, 0, CAST(N'2016-10-30 08:18:52.7549606' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 08:24:00.507' AS DateTime), CAST(N'2016-10-30 08:19:00.507' AS DateTime), NULL, 1, NULL, N'4E2241C7F3417A9F8512A6B9D5531CF8', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60154, 0, CAST(N'2016-10-30 08:58:49.5080776' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 09:16:59.147' AS DateTime), CAST(N'2016-10-30 09:11:59.147' AS DateTime), NULL, 1, NULL, N'DD627871E3B59090ADD5562C73844D9D', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60155, 0, CAST(N'2016-10-30 09:21:27.8649708' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 09:33:45.360' AS DateTime), CAST(N'2016-10-30 09:28:45.360' AS DateTime), NULL, 1, NULL, N'7736C85A7AD74D4384B55021DE880223', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60156, 0, CAST(N'2016-10-30 09:44:28.9905613' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 09:51:20.077' AS DateTime), CAST(N'2016-10-30 09:46:20.077' AS DateTime), NULL, 1, NULL, N'4A3D8011F3B4DE0115BACFD89D5F5667', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60157, 0, CAST(N'2016-10-30 11:36:23.0495596' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 11:45:47.270' AS DateTime), CAST(N'2016-10-30 11:40:47.270' AS DateTime), NULL, 1, NULL, N'A0E45C9909842C2F93D576207A410DE3', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60158, 0, CAST(N'2016-10-30 12:37:17.5675610' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 12:42:37.810' AS DateTime), CAST(N'2016-10-30 12:37:37.810' AS DateTime), NULL, 1, NULL, N'08D11F9AFE506D260E7869D82FE0D5C9', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60159, 0, CAST(N'2016-10-30 12:37:57.9980135' AS DateTime2), NULL, 14, CAST(N'2016-10-30 12:48:30.080' AS DateTime), CAST(N'2016-10-30 12:43:30.080' AS DateTime), NULL, 1, NULL, N'9C4B53D4237F7558E841175F556817C8', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60160, 0, CAST(N'2016-10-30 12:43:46.1731405' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 12:51:10.117' AS DateTime), CAST(N'2016-10-30 12:46:10.117' AS DateTime), NULL, 1, NULL, N'1E05B5A9A3032BF34A662444B80191E2', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60161, 0, CAST(N'2016-10-30 12:46:28.8753556' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 12:51:38.480' AS DateTime), CAST(N'2016-10-30 12:46:38.480' AS DateTime), NULL, 1, NULL, N'A7F78CA7079311640B90DA6159987F67', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60162, 0, CAST(N'2016-10-30 12:47:12.2101653' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 12:52:20.917' AS DateTime), CAST(N'2016-10-30 12:47:20.917' AS DateTime), NULL, 1, NULL, N'F3EB73F9C6F90CEA73AAB59447A27BE4', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60163, 0, CAST(N'2016-10-30 13:05:09.1760402' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 13:11:00.060' AS DateTime), CAST(N'2016-10-30 13:06:00.060' AS DateTime), NULL, 1, NULL, N'6EC62B51CAD9165049F154F4B37FA8C0', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60164, 0, CAST(N'2016-10-30 13:14:37.0519883' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 13:29:21.700' AS DateTime), CAST(N'2016-10-30 13:24:21.700' AS DateTime), NULL, 1, NULL, N'01991CC0091B9AC414F994EF136734D8', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60165, 0, CAST(N'2016-10-30 13:24:32.8881488' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 13:30:12.693' AS DateTime), CAST(N'2016-10-30 13:25:12.693' AS DateTime), NULL, 1, NULL, N'0A2EB2EDC756E3538F52236BD697B4AF', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60166, 0, CAST(N'2016-10-30 13:25:25.6093834' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 13:31:03.510' AS DateTime), CAST(N'2016-10-30 13:26:03.510' AS DateTime), NULL, 1, NULL, N'1AE5CC108C46B20A37AD48D4E94BD14F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60167, 0, CAST(N'2016-10-30 13:30:23.5031294' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 13:40:04.330' AS DateTime), CAST(N'2016-10-30 13:35:04.330' AS DateTime), NULL, 1, NULL, N'F3CA929C560EA58BADC0C9861030FD71', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60168, 0, CAST(N'2016-10-30 13:45:57.5974693' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 13:52:03.900' AS DateTime), CAST(N'2016-10-30 13:47:03.900' AS DateTime), NULL, 1, NULL, N'FB5AF397321BB55510CAA50703F5E147', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60169, 0, CAST(N'2016-10-30 13:57:10.9303156' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 14:08:28.303' AS DateTime), CAST(N'2016-10-30 14:03:28.303' AS DateTime), NULL, 1, NULL, N'04F1F60E188864464F6D9F76B838A177', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60170, 0, CAST(N'2016-10-30 14:10:30.4703552' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 14:21:25.097' AS DateTime), CAST(N'2016-10-30 14:16:25.097' AS DateTime), NULL, 1, NULL, N'5230AD1C686150DA2BEC0E8B50FA901C', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60171, 0, CAST(N'2016-10-30 14:17:48.8896502' AS DateTime2), NULL, NULL, CAST(N'2016-10-30 14:23:50.000' AS DateTime), CAST(N'2016-10-30 14:18:50.000' AS DateTime), NULL, 1, NULL, N'C5CED07691E1CD95E178293142744F51', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60172, 0, CAST(N'2016-10-31 20:32:26.5733301' AS DateTime2), NULL, NULL, CAST(N'2016-10-31 20:44:22.557' AS DateTime), CAST(N'2016-10-31 20:39:22.557' AS DateTime), NULL, 1, NULL, N'9ABD0823C99C7E660F6DD1F913BEEF0E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60173, 0, CAST(N'2016-10-31 20:47:36.8552720' AS DateTime2), NULL, NULL, CAST(N'2016-10-31 20:53:58.470' AS DateTime), CAST(N'2016-10-31 20:48:58.470' AS DateTime), NULL, 1, NULL, N'60E5AD7F5B50D906C6351310095F4CB4', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60174, 0, CAST(N'2016-10-31 21:05:00.4072308' AS DateTime2), NULL, NULL, CAST(N'2016-10-31 21:10:48.510' AS DateTime), CAST(N'2016-10-31 21:05:48.510' AS DateTime), NULL, 1, NULL, N'7F5AB661A85C2778DD506828342A1DDC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60175, 0, CAST(N'2016-11-01 21:53:31.9687062' AS DateTime2), NULL, NULL, CAST(N'2016-11-01 21:58:43.423' AS DateTime), CAST(N'2016-11-01 21:53:43.423' AS DateTime), NULL, 1, NULL, N'6F39D477B0D6FBEB1C86FA206E21D5EF', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60176, 0, CAST(N'2016-11-01 23:24:29.0259182' AS DateTime2), NULL, NULL, CAST(N'2016-11-01 23:44:48.140' AS DateTime), CAST(N'2016-11-01 23:39:48.140' AS DateTime), NULL, 1, NULL, N'AC308A29017B220763F4551DA702F9E7', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60177, 0, CAST(N'2016-11-02 08:45:29.3093192' AS DateTime2), NULL, NULL, CAST(N'2016-11-02 08:51:40.163' AS DateTime), CAST(N'2016-11-02 08:46:40.163' AS DateTime), NULL, 1, NULL, N'CA71EFB46F41690DA663F7360A8B0BFC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60178, 0, CAST(N'2016-11-02 08:55:13.1268520' AS DateTime2), NULL, NULL, CAST(N'2016-11-02 09:06:34.840' AS DateTime), CAST(N'2016-11-02 09:01:34.840' AS DateTime), NULL, 1, NULL, N'3835B16B1BF9F665B7B1DAE9E5B77DF6', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60179, 0, CAST(N'2016-11-03 18:06:19.9369438' AS DateTime2), NULL, NULL, CAST(N'2016-11-03 18:11:20.610' AS DateTime), CAST(N'2016-11-03 18:06:20.610' AS DateTime), NULL, 1, NULL, N'857359AE5B64BC7FB5560A2898840E7E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60180, 0, CAST(N'2016-11-03 18:13:41.6287700' AS DateTime2), NULL, NULL, CAST(N'2016-11-03 18:18:43.583' AS DateTime), CAST(N'2016-11-03 18:13:43.583' AS DateTime), NULL, 1, NULL, N'E1131E1B36F1AAF0FBF6BE9FB7AFE2EC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60181, 0, CAST(N'2016-11-03 18:54:09.3884436' AS DateTime2), NULL, NULL, CAST(N'2016-11-03 19:08:39.207' AS DateTime), CAST(N'2016-11-03 19:03:39.207' AS DateTime), NULL, 1, NULL, N'6DEEFA3C189C59D119C9E217DAF9273B', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60182, 0, CAST(N'2016-11-03 19:18:52.3163858' AS DateTime2), NULL, NULL, CAST(N'2016-11-03 20:08:51.370' AS DateTime), CAST(N'2016-11-03 20:03:51.370' AS DateTime), NULL, 1, NULL, N'CB815238CE6489416B45AD9925783AC0', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60183, 0, CAST(N'2016-11-03 20:18:50.8818665' AS DateTime2), NULL, NULL, CAST(N'2016-11-03 20:24:15.640' AS DateTime), CAST(N'2016-11-03 20:19:15.640' AS DateTime), NULL, 1, NULL, N'DCC4B2AE914D1B8ADC419226FB8E8B34', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (60184, 0, CAST(N'2016-11-03 20:25:44.9816820' AS DateTime2), NULL, NULL, CAST(N'2016-11-03 20:32:12.710' AS DateTime), CAST(N'2016-11-03 20:27:12.710' AS DateTime), NULL, 1, NULL, N'28B1F05F2EA9FB002F3E2200066AAFD9', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70179, 0, CAST(N'2016-11-05 16:53:43.5357718' AS DateTime2), NULL, NULL, CAST(N'2016-11-05 17:04:14.057' AS DateTime), CAST(N'2016-11-05 16:59:14.057' AS DateTime), NULL, 1, NULL, N'C152FB19BD5A00BEE75E065CA8442243', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70180, 0, CAST(N'2016-11-05 17:05:50.4035355' AS DateTime2), NULL, NULL, CAST(N'2016-11-05 17:11:24.633' AS DateTime), CAST(N'2016-11-05 17:06:24.633' AS DateTime), NULL, 1, NULL, N'94CEB1331C29FBFAC2658B4373EF8A03', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70181, 0, CAST(N'2016-11-05 17:13:53.2340301' AS DateTime2), NULL, NULL, CAST(N'2016-11-05 17:21:54.943' AS DateTime), CAST(N'2016-11-05 17:16:54.943' AS DateTime), NULL, 1, NULL, N'4991327F6DA4A62B9EF456E038B4EBFF', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70182, 0, CAST(N'2016-11-05 17:37:11.6640994' AS DateTime2), NULL, NULL, CAST(N'2016-11-05 17:43:24.097' AS DateTime), CAST(N'2016-11-05 17:38:24.097' AS DateTime), NULL, 1, NULL, N'4FE6A53D52EB5E8E544CEAF19FA404C9', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70183, 0, CAST(N'2016-11-05 17:57:33.0238941' AS DateTime2), NULL, NULL, CAST(N'2016-11-05 18:07:00.297' AS DateTime), CAST(N'2016-11-05 18:02:00.297' AS DateTime), NULL, 1, NULL, N'8DBFF806A1116249FA32BFDEA4ABB4B2', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70184, 0, CAST(N'2016-11-05 18:11:50.9777399' AS DateTime2), NULL, NULL, CAST(N'2016-11-05 18:19:19.450' AS DateTime), CAST(N'2016-11-05 18:14:19.450' AS DateTime), NULL, 1, NULL, N'D6FA8700ADA9A4B5864C5D6B22A3FC6A', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70185, 0, CAST(N'2016-11-05 20:38:08.3938884' AS DateTime2), NULL, NULL, CAST(N'2016-11-05 20:47:47.767' AS DateTime), CAST(N'2016-11-05 20:42:47.767' AS DateTime), NULL, 1, NULL, N'C3DA7E33C89293B1258E561BC2B17444', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70186, 0, CAST(N'2016-11-05 21:04:07.9826791' AS DateTime2), NULL, NULL, CAST(N'2016-11-05 21:09:18.267' AS DateTime), CAST(N'2016-11-05 21:04:18.267' AS DateTime), NULL, 1, NULL, N'05D653040B0C5A2BBA4FF4C88F0CB6D5', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70187, 0, CAST(N'2016-11-05 22:26:32.4862448' AS DateTime2), NULL, NULL, CAST(N'2016-11-05 22:34:34.773' AS DateTime), CAST(N'2016-11-05 22:29:34.773' AS DateTime), NULL, 1, NULL, N'AA539266B79EF3805DBA409C7CEA5091', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70188, 0, CAST(N'2016-11-05 22:36:20.8373142' AS DateTime2), NULL, NULL, CAST(N'2016-11-05 22:41:36.390' AS DateTime), CAST(N'2016-11-05 22:36:36.390' AS DateTime), NULL, 1, NULL, N'0C92FEA33D420895E0D4A2117DCCEFB9', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70189, 0, CAST(N'2016-11-05 22:48:50.7406722' AS DateTime2), NULL, NULL, CAST(N'2016-11-05 23:05:40.130' AS DateTime), CAST(N'2016-11-05 23:00:40.130' AS DateTime), NULL, 1, NULL, N'FF2E4E75ED37481A7A34080D22A2B307', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70190, 0, CAST(N'2016-11-05 23:06:33.7285092' AS DateTime2), NULL, NULL, CAST(N'2016-11-05 23:12:39.660' AS DateTime), CAST(N'2016-11-05 23:07:39.660' AS DateTime), NULL, 1, NULL, N'58C90F19CDDC8300B2FAAA7E73CD4ACC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70191, 0, CAST(N'2016-11-06 09:55:40.2473332' AS DateTime2), NULL, NULL, CAST(N'2016-11-06 10:05:32.670' AS DateTime), CAST(N'2016-11-06 10:00:32.670' AS DateTime), NULL, 1, NULL, N'78FA9AD564717864074445237D5B8ACA', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70192, 0, CAST(N'2016-11-06 13:06:39.4053466' AS DateTime2), NULL, NULL, CAST(N'2016-11-06 13:12:55.507' AS DateTime), CAST(N'2016-11-06 13:07:55.507' AS DateTime), NULL, 1, NULL, N'E8CDC8B7B22CFEFC523DB89B99B2B7CE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70193, 0, CAST(N'2016-11-06 13:15:48.2987252' AS DateTime2), NULL, NULL, CAST(N'2016-11-06 13:25:43.067' AS DateTime), CAST(N'2016-11-06 13:20:43.067' AS DateTime), NULL, 1, NULL, N'B6990F634D5AEEB65E2B59FF6983C9A4', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70194, 0, CAST(N'2016-11-06 15:31:40.3008285' AS DateTime2), NULL, NULL, CAST(N'2016-11-06 15:41:26.037' AS DateTime), CAST(N'2016-11-06 15:36:26.037' AS DateTime), NULL, 1, NULL, N'A06F8A2D0C48FA4EC1489501F7EC3A47', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (70195, 0, CAST(N'2016-11-06 20:32:18.7307412' AS DateTime2), NULL, NULL, CAST(N'2016-11-06 20:39:31.063' AS DateTime), CAST(N'2016-11-06 20:34:31.063' AS DateTime), NULL, 1, NULL, N'615C027CB6649A2D798D3A057D0230B5', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80179, 0, CAST(N'2016-11-07 21:11:43.6663887' AS DateTime2), NULL, NULL, CAST(N'2016-11-07 21:16:59.147' AS DateTime), CAST(N'2016-11-07 21:11:59.147' AS DateTime), NULL, 1, NULL, N'A3D28782A5303D1354EB195941CCE7B3', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80180, 0, CAST(N'2016-11-08 21:32:09.2662732' AS DateTime2), NULL, NULL, CAST(N'2016-11-08 21:37:13.397' AS DateTime), CAST(N'2016-11-08 21:32:13.397' AS DateTime), NULL, 1, NULL, N'21771EB2494B5A643FACA461D251BD6D', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80181, 0, CAST(N'2016-11-13 04:39:06.5792794' AS DateTime2), NULL, NULL, CAST(N'2016-11-13 04:50:51.507' AS DateTime), CAST(N'2016-11-13 04:45:51.507' AS DateTime), NULL, 1, NULL, N'DA04AE2FCD9823C5C3D7C0D6A0D85274', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80182, 0, CAST(N'2016-11-13 05:02:10.2898717' AS DateTime2), NULL, NULL, CAST(N'2016-11-13 05:13:15.087' AS DateTime), CAST(N'2016-11-13 05:08:15.087' AS DateTime), NULL, 1, NULL, N'324751244BB23ABE237EF1A037A7A23A', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80183, 0, CAST(N'2016-11-13 05:17:25.2479991' AS DateTime2), NULL, NULL, CAST(N'2016-11-13 05:30:43.767' AS DateTime), CAST(N'2016-11-13 05:25:43.767' AS DateTime), NULL, 1, NULL, N'6D16E4D59B5380D294C1456AA3BDB056', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80184, 0, CAST(N'2016-11-13 05:19:18.5429094' AS DateTime2), NULL, 14, CAST(N'2016-11-13 05:24:42.850' AS DateTime), CAST(N'2016-11-13 05:19:42.850' AS DateTime), NULL, 1, NULL, N'1903584CF5863A14E22BF5B08AB9631D', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80185, 0, CAST(N'2016-11-13 05:35:52.0582099' AS DateTime2), NULL, NULL, CAST(N'2016-11-13 05:45:45.897' AS DateTime), CAST(N'2016-11-13 05:40:45.897' AS DateTime), NULL, 1, NULL, N'92CBD100CF15C39484FAD42F17F7F9C0', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80186, 0, CAST(N'2016-11-13 13:06:48.9877987' AS DateTime2), NULL, NULL, CAST(N'2016-11-13 13:19:50.313' AS DateTime), CAST(N'2016-11-13 13:14:50.313' AS DateTime), NULL, 1, NULL, N'5AB8A30B77027E58C180D76AC8D6C219', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80187, 0, CAST(N'2016-11-13 13:39:36.8134713' AS DateTime2), NULL, NULL, CAST(N'2016-11-13 13:44:54.137' AS DateTime), CAST(N'2016-11-13 13:39:54.137' AS DateTime), NULL, 1, NULL, N'F7EE4A8B7E154FC0152E104ECC7447E2', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80188, 0, CAST(N'2016-11-13 13:46:09.8650187' AS DateTime2), NULL, NULL, CAST(N'2016-11-13 13:57:42.873' AS DateTime), CAST(N'2016-11-13 13:52:42.873' AS DateTime), NULL, 1, NULL, N'C76E565EEE5C74BFEBD45D35FAEE11A2', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80189, 0, CAST(N'2016-11-13 13:58:47.0030446' AS DateTime2), NULL, NULL, CAST(N'2016-11-13 14:06:01.800' AS DateTime), CAST(N'2016-11-13 14:01:01.800' AS DateTime), NULL, 1, NULL, N'84E94AF075FCAA8BAF6B3FA1EADD4198', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80190, 0, CAST(N'2016-11-13 14:07:06.0088196' AS DateTime2), NULL, NULL, CAST(N'2016-11-13 14:15:07.233' AS DateTime), CAST(N'2016-11-13 14:10:07.233' AS DateTime), NULL, 1, NULL, N'E4B86C10E8E077430AFBBE9A50D73155', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80191, 0, CAST(N'2016-11-13 14:17:55.9516413' AS DateTime2), NULL, NULL, CAST(N'2016-11-13 14:22:56.120' AS DateTime), CAST(N'2016-11-13 14:17:56.120' AS DateTime), NULL, 1, NULL, N'8F2443DC575E03C8C9C9D5E218C5A712', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80192, 0, CAST(N'2016-11-13 15:01:53.2557170' AS DateTime2), NULL, NULL, CAST(N'2016-11-13 15:09:26.070' AS DateTime), CAST(N'2016-11-13 15:04:26.070' AS DateTime), NULL, 1, NULL, N'442ECC9FAE55D7DBDDB79E3C17F5D2D5', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80193, 0, CAST(N'2016-11-13 15:14:02.0218844' AS DateTime2), NULL, NULL, CAST(N'2016-11-13 15:33:59.670' AS DateTime), CAST(N'2016-11-13 15:28:59.670' AS DateTime), NULL, 1, NULL, N'3D62FBF151BEBC7A62A7D5CE4473552C', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80194, 0, CAST(N'2016-11-14 21:15:21.0564296' AS DateTime2), NULL, NULL, CAST(N'2016-11-14 22:15:21.697' AS DateTime), CAST(N'2016-11-14 22:10:21.697' AS DateTime), NULL, 1, NULL, N'50D02E2B26A1A54964DEB908CC0C8B45', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80195, 0, CAST(N'2016-11-14 21:24:18.0622094' AS DateTime2), NULL, 14, CAST(N'2016-11-14 21:30:09.770' AS DateTime), CAST(N'2016-11-14 21:25:09.770' AS DateTime), NULL, 1, NULL, N'CA1270825479E52CFC984330897A9F32', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80196, 0, CAST(N'2016-11-14 22:11:59.1372536' AS DateTime2), NULL, 14, CAST(N'2016-11-14 22:25:29.507' AS DateTime), CAST(N'2016-11-14 22:20:29.507' AS DateTime), NULL, 1, NULL, N'D1E1F9F6CA11CEEAF5094A98F67AFC64', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80197, 0, CAST(N'2016-11-14 22:32:52.2215239' AS DateTime2), NULL, 14, CAST(N'2016-11-14 22:40:43.917' AS DateTime), CAST(N'2016-11-14 22:35:43.917' AS DateTime), NULL, 1, NULL, N'4437989331F0C90D267D45EA3D793A22', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (80198, 0, CAST(N'2016-11-14 22:50:54.2428798' AS DateTime2), NULL, 14, CAST(N'2016-11-14 23:11:11.533' AS DateTime), CAST(N'2016-11-14 23:06:11.533' AS DateTime), NULL, 1, NULL, N'C04954C54C4EF9311786A4DF4AC6488B', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90181, 0, CAST(N'2016-11-16 09:35:42.0381933' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 09:46:22.860' AS DateTime), CAST(N'2016-11-16 09:41:22.860' AS DateTime), NULL, 1, NULL, N'E2A2D1D6A709E5ABE2733EC8C2A4952E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90182, 0, CAST(N'2016-11-16 09:42:03.0775593' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 09:47:30.497' AS DateTime), CAST(N'2016-11-16 09:42:30.497' AS DateTime), NULL, 6, NULL, N'6E61047268962C2D72152DE6DE5441A5', 2)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90183, 0, CAST(N'2016-11-16 09:47:37.9868250' AS DateTime2), NULL, 14, CAST(N'2016-11-16 09:57:53.563' AS DateTime), CAST(N'2016-11-16 09:52:53.563' AS DateTime), NULL, 1, NULL, N'BD254012277A35F6D44FE7AD9B0B8F0C', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90184, 0, CAST(N'2016-11-16 09:49:43.7217156' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 09:54:45.657' AS DateTime), CAST(N'2016-11-16 09:49:45.657' AS DateTime), NULL, 1, NULL, N'00B74B0B5D967535209E073CEBF37C48', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90185, 0, CAST(N'2016-11-16 09:56:28.3549626' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 10:07:03.933' AS DateTime), CAST(N'2016-11-16 10:02:03.933' AS DateTime), NULL, 1, NULL, N'B26759BD9060022186FAA6BE73D88578', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90186, 0, CAST(N'2016-11-16 12:34:47.6392622' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 12:39:48.137' AS DateTime), CAST(N'2016-11-16 12:34:48.137' AS DateTime), NULL, 1, NULL, N'CD68C144BEEF833E9D46E22DC6F77740', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90187, 0, CAST(N'2016-11-16 12:36:03.5808540' AS DateTime2), NULL, 14, CAST(N'2016-11-16 12:41:14.587' AS DateTime), CAST(N'2016-11-16 12:36:14.587' AS DateTime), NULL, 1, NULL, N'E59266FB6058105CFB279DA466E883D8', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90188, 0, CAST(N'2016-11-16 13:01:01.7612916' AS DateTime2), NULL, 14, CAST(N'2016-11-16 13:30:18.557' AS DateTime), CAST(N'2016-11-16 13:25:18.557' AS DateTime), NULL, 1, NULL, N'884472BA8EB855D3ACF7DC5A4AE6AA9C', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90189, 0, CAST(N'2016-11-16 14:15:56.7895917' AS DateTime2), NULL, 14, CAST(N'2016-11-16 14:24:58.553' AS DateTime), CAST(N'2016-11-16 14:19:58.553' AS DateTime), NULL, 1, NULL, N'7920E8CBD5B470589F442F634B2FEA38', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90190, 0, CAST(N'2016-11-16 14:16:46.9102040' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 14:37:18.453' AS DateTime), CAST(N'2016-11-16 14:32:18.453' AS DateTime), NULL, 1, NULL, N'89E6775281544A2E3E49C1F0E7FB0521', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90191, 0, CAST(N'2016-11-16 14:37:37.5994531' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 14:47:46.767' AS DateTime), CAST(N'2016-11-16 14:42:46.767' AS DateTime), NULL, 1, NULL, N'C4F7133873400D4CDB9FC98B10843285', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90192, 0, CAST(N'2016-11-16 15:01:47.9152835' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 15:06:48.187' AS DateTime), CAST(N'2016-11-16 15:01:48.187' AS DateTime), NULL, 1, NULL, N'50E6F02658DD6631C63E7277BBBF96C2', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90193, 0, CAST(N'2016-11-16 15:19:43.2813286' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 15:25:00.113' AS DateTime), CAST(N'2016-11-16 15:20:00.113' AS DateTime), NULL, 1, NULL, N'1FC24103E7C734B53D6BF2D69AD979C0', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90194, 0, CAST(N'2016-11-16 15:20:53.5992392' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 15:28:29.047' AS DateTime), CAST(N'2016-11-16 15:23:29.047' AS DateTime), NULL, 6, NULL, N'38A1EF368668D73EAB63D3C195599240', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90195, 0, CAST(N'2016-11-16 15:31:17.3695173' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 15:36:17.957' AS DateTime), CAST(N'2016-11-16 15:31:17.957' AS DateTime), NULL, 1, NULL, N'3CFE8A408EE1E75B7D76C3559DA49D82', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90196, 0, CAST(N'2016-11-16 15:31:44.8583002' AS DateTime2), NULL, 14, CAST(N'2016-11-16 15:37:06.107' AS DateTime), CAST(N'2016-11-16 15:32:06.107' AS DateTime), NULL, 1, NULL, N'7C8F13A6951907D424B8AB70F2684278', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90197, 0, CAST(N'2016-11-16 15:32:26.0571876' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 15:38:19.670' AS DateTime), CAST(N'2016-11-16 15:33:19.670' AS DateTime), NULL, 6, NULL, N'6C4E5C696A633693410EACE822B33C37', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90198, 0, CAST(N'2016-11-16 15:33:23.4345826' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 15:38:33.857' AS DateTime), CAST(N'2016-11-16 15:33:33.857' AS DateTime), NULL, 6, NULL, N'416492E750A7B317AB897C0EF94A19EF', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90199, 0, CAST(N'2016-11-16 15:33:36.0144103' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 15:38:46.063' AS DateTime), CAST(N'2016-11-16 15:33:46.063' AS DateTime), NULL, 6, NULL, N'57D5551D2DF1A963B64D2FC552617905', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90200, 0, CAST(N'2016-11-16 15:34:12.5318542' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 15:40:27.467' AS DateTime), CAST(N'2016-11-16 15:35:27.467' AS DateTime), NULL, 6, NULL, N'10904AC6536B4F1A1D35608CCB83FF5A', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90201, 0, CAST(N'2016-11-16 15:37:08.5828734' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 15:43:23.933' AS DateTime), CAST(N'2016-11-16 15:38:23.933' AS DateTime), NULL, 6, NULL, N'A28746BC2DF49F7F748EC5EE2342F284', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90202, 0, CAST(N'2016-11-16 15:38:38.3464384' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 15:43:38.347' AS DateTime), CAST(N'2016-11-16 15:38:38.347' AS DateTime), NULL, 6, NULL, N'BA20BBB05781E20FAB0F95BC4FA8C9B9', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90203, 0, CAST(N'2016-11-16 15:39:27.8309780' AS DateTime2), NULL, 14, CAST(N'2016-11-16 15:44:32.643' AS DateTime), CAST(N'2016-11-16 15:39:32.643' AS DateTime), NULL, 1, NULL, N'A481DC08CE2101A4EDBB671B80261089', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90204, 0, CAST(N'2016-11-16 15:43:58.6722337' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 15:49:04.440' AS DateTime), CAST(N'2016-11-16 15:44:04.440' AS DateTime), NULL, 1, NULL, N'90452687A4572E5137EDE9D47F6AD7BE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90205, 0, CAST(N'2016-11-16 15:44:19.4222381' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 15:49:19.423' AS DateTime), CAST(N'2016-11-16 15:44:19.423' AS DateTime), NULL, 6, NULL, N'5C9E723AC3B5429D65789567F57484B8', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90206, 0, CAST(N'2016-11-16 16:08:57.0609980' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 16:13:57.060' AS DateTime), CAST(N'2016-11-16 16:08:57.060' AS DateTime), NULL, 6, NULL, N'43A77A7FC0C35D9DAED1AA9B52E4D750', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90207, 0, CAST(N'2016-11-16 16:09:27.5033595' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 16:14:27.503' AS DateTime), CAST(N'2016-11-16 16:09:27.503' AS DateTime), NULL, 6, NULL, N'22D967A37A5A3B9865634E885F24D9FD', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90208, 0, CAST(N'2016-11-16 16:09:53.8600544' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 16:14:53.860' AS DateTime), CAST(N'2016-11-16 16:09:53.860' AS DateTime), NULL, 6, NULL, N'52E07CE922FE95FE5D5618DDB9A01321', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90209, 0, CAST(N'2016-11-16 16:11:11.1725197' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 16:16:11.173' AS DateTime), CAST(N'2016-11-16 16:11:11.173' AS DateTime), NULL, 6, NULL, N'0E436D6DA6C4C92D31B56B062B0F5434', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90210, 0, CAST(N'2016-11-16 16:14:50.5370852' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 16:20:01.633' AS DateTime), CAST(N'2016-11-16 16:15:01.633' AS DateTime), NULL, 6, NULL, N'6C893582030456596734B749E0B1D28D', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90211, 0, CAST(N'2016-11-16 16:15:04.1964618' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 16:20:14.930' AS DateTime), CAST(N'2016-11-16 16:15:14.930' AS DateTime), NULL, 6, NULL, N'B79BE47197460011095CFD45D6B3971F', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90212, 0, CAST(N'2016-11-16 16:15:25.1080806' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 16:20:25.107' AS DateTime), CAST(N'2016-11-16 16:15:25.107' AS DateTime), NULL, 6, NULL, N'DC8740990338D90CF1CA94DB4F14E2CE', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90213, 0, CAST(N'2016-11-16 16:15:29.9626309' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 16:20:29.963' AS DateTime), CAST(N'2016-11-16 16:15:29.963' AS DateTime), NULL, 6, NULL, N'DFA96C31EB79F92C35A2A5F9F720C284', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90214, 0, CAST(N'2016-11-16 16:17:06.5646448' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 16:22:18.860' AS DateTime), CAST(N'2016-11-16 16:17:18.860' AS DateTime), NULL, 6, NULL, N'15C14872BAA4A87AEBA34449A37B5990', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90215, 0, CAST(N'2016-11-16 16:17:30.2929048' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 16:22:43.523' AS DateTime), CAST(N'2016-11-16 16:17:43.523' AS DateTime), NULL, 1, NULL, N'9376B93E71523CA5F27127A2E0769178', 5)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90216, 0, CAST(N'2016-11-16 16:17:55.5475938' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 16:27:51.870' AS DateTime), CAST(N'2016-11-16 16:22:51.870' AS DateTime), NULL, 1, NULL, N'64C7ED4B7A788EC9B7E52EC013BF009E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90217, 0, CAST(N'2016-11-16 16:29:39.3095966' AS DateTime2), NULL, 14, CAST(N'2016-11-16 16:53:14.310' AS DateTime), CAST(N'2016-11-16 16:48:14.310' AS DateTime), NULL, 1, NULL, N'72E37AEDDB86AB07A0EB605B701D047B', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90218, 0, CAST(N'2016-11-16 16:58:28.3057879' AS DateTime2), NULL, 14, CAST(N'2016-11-16 17:06:58.157' AS DateTime), CAST(N'2016-11-16 17:01:58.157' AS DateTime), NULL, 1, NULL, N'9A7FE93656FF766778C0C05FA0BB2040', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90219, 0, CAST(N'2016-11-16 17:02:53.1953257' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 17:10:19.610' AS DateTime), CAST(N'2016-11-16 17:05:19.610' AS DateTime), NULL, 1, NULL, N'AD5568CF94CD15A76F2F404D86B19FF0', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (90220, 0, CAST(N'2016-11-16 17:18:44.1644373' AS DateTime2), NULL, NULL, CAST(N'2016-11-16 17:23:50.247' AS DateTime), CAST(N'2016-11-16 17:18:50.247' AS DateTime), NULL, 1, NULL, N'E53BA2102F5686AAB1DDD5643395F99A', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100181, 0, CAST(N'2016-11-18 10:23:05.8106713' AS DateTime2), NULL, NULL, CAST(N'2016-11-18 10:28:06.447' AS DateTime), CAST(N'2016-11-18 10:23:06.447' AS DateTime), NULL, 1, NULL, N'92921E63C5EC5DB7288ADA601870D43E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100182, 0, CAST(N'2016-11-18 10:37:23.9834405' AS DateTime2), NULL, NULL, CAST(N'2016-11-18 10:42:28.467' AS DateTime), CAST(N'2016-11-18 10:37:28.467' AS DateTime), NULL, 1, NULL, N'E1009B1EBC139259052EC209289FA963', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100183, 0, CAST(N'2016-11-18 10:42:55.9680124' AS DateTime2), NULL, 14, CAST(N'2016-11-18 10:48:27.900' AS DateTime), CAST(N'2016-11-18 10:43:27.900' AS DateTime), NULL, 6, NULL, N'45E78FE1E21F00B075D43BF8F32D3333', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100184, 0, CAST(N'2016-11-18 10:54:03.4494322' AS DateTime2), NULL, 14, CAST(N'2016-11-18 11:06:15.260' AS DateTime), CAST(N'2016-11-18 11:01:15.260' AS DateTime), NULL, 1, NULL, N'F7DC41EC4FF8542077A176EC1B15001B', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100185, 0, CAST(N'2016-11-18 11:13:53.8356271' AS DateTime2), NULL, 14, CAST(N'2016-11-18 11:35:44.013' AS DateTime), CAST(N'2016-11-18 11:30:44.013' AS DateTime), NULL, 1, NULL, N'265D0989729A691DAC420100EE41C64E', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100186, 0, CAST(N'2016-11-18 11:36:47.8914939' AS DateTime2), NULL, 14, CAST(N'2016-11-18 11:47:29.720' AS DateTime), CAST(N'2016-11-18 11:42:29.720' AS DateTime), NULL, 1, NULL, N'1E0E620C49DAA76610B38271A0BCA307', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100187, 0, CAST(N'2016-11-18 11:48:57.8389358' AS DateTime2), NULL, 14, CAST(N'2016-11-18 11:54:53.133' AS DateTime), CAST(N'2016-11-18 11:49:53.133' AS DateTime), NULL, 1, NULL, N'6F19FB837A547933A1AD98EDA95FB04D', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100188, 0, CAST(N'2016-11-18 11:51:46.9878690' AS DateTime2), NULL, 14, CAST(N'2016-11-18 11:56:53.683' AS DateTime), CAST(N'2016-11-18 11:51:53.683' AS DateTime), NULL, 1, NULL, N'F445394D77B976C753894C38594F1F89', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100189, 0, CAST(N'2016-11-18 11:57:35.2311012' AS DateTime2), NULL, 14, CAST(N'2016-11-18 12:15:37.887' AS DateTime), CAST(N'2016-11-18 12:10:37.887' AS DateTime), NULL, 1, NULL, N'B3575C7206F6CF9AEC012C638E0DD9AA', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100190, 0, CAST(N'2016-11-18 12:19:41.0686377' AS DateTime2), NULL, 14, CAST(N'2016-11-18 12:30:48.577' AS DateTime), CAST(N'2016-11-18 12:25:48.577' AS DateTime), NULL, 1, NULL, N'4EC132132E32CC3562F04146A53DBA0F', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100191, 0, CAST(N'2016-11-18 12:20:52.1241969' AS DateTime2), NULL, NULL, CAST(N'2016-11-18 12:26:06.393' AS DateTime), CAST(N'2016-11-18 12:21:06.393' AS DateTime), NULL, 1, NULL, N'289B0EB3C9C6A167332445B1DA3828C5', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100192, 0, CAST(N'2016-11-18 12:34:58.2834433' AS DateTime2), NULL, 14, CAST(N'2016-11-18 12:44:35.950' AS DateTime), CAST(N'2016-11-18 12:39:35.950' AS DateTime), NULL, 1, NULL, N'56A1E158C5C7BBFFF79864C45C1B7869', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100193, 0, CAST(N'2016-11-18 12:47:49.0407099' AS DateTime2), NULL, 14, CAST(N'2016-11-18 12:53:31.357' AS DateTime), CAST(N'2016-11-18 12:48:31.357' AS DateTime), NULL, 1, NULL, N'7AD67DA0ECFBC0798D8F4B81DC71EFCF', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100194, 0, CAST(N'2016-11-18 12:51:07.6668454' AS DateTime2), NULL, NULL, CAST(N'2016-11-18 13:00:57.893' AS DateTime), CAST(N'2016-11-18 12:55:57.893' AS DateTime), NULL, 1, NULL, N'781272CFDCEBC3B35A94042D652C3D74', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100195, 0, CAST(N'2016-11-18 12:56:59.0460474' AS DateTime2), NULL, 14, CAST(N'2016-11-18 13:02:07.810' AS DateTime), CAST(N'2016-11-18 12:57:07.810' AS DateTime), NULL, 1, NULL, N'5738BBD0A5956FA6DD562CA680B6151A', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100196, 0, CAST(N'2016-11-18 12:57:44.1018153' AS DateTime2), NULL, 14, CAST(N'2016-11-18 13:04:32.783' AS DateTime), CAST(N'2016-11-18 12:59:32.783' AS DateTime), NULL, 1, NULL, N'39923180B78E0128187A6D1EB97EDC86', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100197, 0, CAST(N'2016-11-18 12:59:51.9363187' AS DateTime2), NULL, NULL, CAST(N'2016-11-18 13:07:39.327' AS DateTime), CAST(N'2016-11-18 13:02:39.327' AS DateTime), NULL, 1, NULL, N'8500E8CD0E014FA8C10DE55CF3503A1E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100198, 0, CAST(N'2016-11-18 13:35:27.2451592' AS DateTime2), NULL, NULL, CAST(N'2016-11-18 13:46:15.520' AS DateTime), CAST(N'2016-11-18 13:41:15.520' AS DateTime), NULL, 1, NULL, N'49E8F8751B1F5C8D245CC4BFDCC5D7A5', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100199, 0, CAST(N'2016-11-18 13:41:44.6419417' AS DateTime2), NULL, NULL, CAST(N'2016-11-18 13:46:53.103' AS DateTime), CAST(N'2016-11-18 13:41:53.103' AS DateTime), NULL, 1, NULL, N'24A753E8DFBCB615C789F643215C35EE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100200, 0, CAST(N'2016-11-18 13:42:20.6106060' AS DateTime2), NULL, 14, CAST(N'2016-11-18 13:48:20.883' AS DateTime), CAST(N'2016-11-18 13:43:20.883' AS DateTime), NULL, 1, NULL, N'EB46D350057433E263363918F4D0C966', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100201, 0, CAST(N'2016-11-18 13:43:37.2107805' AS DateTime2), NULL, NULL, CAST(N'2016-11-18 13:54:50.117' AS DateTime), CAST(N'2016-11-18 13:49:50.117' AS DateTime), NULL, 1, NULL, N'420223FC994C1042833945756D4F0E29', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100202, 0, CAST(N'2016-11-18 14:22:35.9102965' AS DateTime2), NULL, NULL, CAST(N'2016-11-18 14:27:45.337' AS DateTime), CAST(N'2016-11-18 14:22:45.337' AS DateTime), NULL, 1, NULL, N'B22630ED38C34851A59D4DFA89A6E0FE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100203, 0, CAST(N'2016-11-18 17:20:14.4022688' AS DateTime2), NULL, NULL, CAST(N'2016-11-18 17:26:23.607' AS DateTime), CAST(N'2016-11-18 17:21:23.607' AS DateTime), NULL, 1, NULL, N'83CE09A986C7295733814439737CBDD6', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100204, 0, CAST(N'2016-11-18 17:27:55.9240892' AS DateTime2), NULL, NULL, CAST(N'2016-11-18 18:13:17.533' AS DateTime), CAST(N'2016-11-18 18:08:17.533' AS DateTime), NULL, 1, NULL, N'0506207D20750F29BD9424A46234CCEF', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100205, 0, CAST(N'2016-11-18 18:19:21.9558706' AS DateTime2), NULL, NULL, CAST(N'2016-11-18 18:24:29.490' AS DateTime), CAST(N'2016-11-18 18:19:29.490' AS DateTime), NULL, 1, NULL, N'FA3D8BA992906D4F9419AE0A1DA0EDB5', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100206, 0, CAST(N'2016-11-23 20:50:19.6236751' AS DateTime2), NULL, NULL, CAST(N'2016-11-23 20:55:58.120' AS DateTime), CAST(N'2016-11-23 20:50:58.120' AS DateTime), NULL, 1, NULL, N'F3119CF45CA21887871309F6F4345BA2', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100207, 0, CAST(N'2016-11-23 20:59:27.7895859' AS DateTime2), NULL, NULL, CAST(N'2016-11-23 21:09:37.397' AS DateTime), CAST(N'2016-11-23 21:04:37.397' AS DateTime), NULL, 1, NULL, N'627276A9ABB5C226CD20F51FBA7FF84B', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100208, 0, CAST(N'2016-11-23 21:19:34.2786729' AS DateTime2), NULL, NULL, CAST(N'2016-11-23 21:29:54.267' AS DateTime), CAST(N'2016-11-23 21:24:54.267' AS DateTime), NULL, 1, NULL, N'B30F6E89F9AC2B381F4EE0CBE89FECFB', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100209, 0, CAST(N'2016-11-24 22:28:26.3322242' AS DateTime2), NULL, NULL, CAST(N'2016-11-24 22:33:27.527' AS DateTime), CAST(N'2016-11-24 22:28:27.527' AS DateTime), NULL, 1, NULL, N'3745ECBFE42A191E38CDF751431A73BE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100210, 0, CAST(N'2016-11-24 22:55:24.3002952' AS DateTime2), NULL, NULL, CAST(N'2016-11-24 23:01:05.300' AS DateTime), CAST(N'2016-11-24 22:56:05.300' AS DateTime), NULL, 1, NULL, N'B6F7EB6ACB9A4E6F34148447AA026400', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100211, 0, CAST(N'2016-11-24 23:05:28.7439384' AS DateTime2), NULL, NULL, CAST(N'2016-11-24 23:23:10.683' AS DateTime), CAST(N'2016-11-24 23:18:10.683' AS DateTime), NULL, 1, NULL, N'71111C51A67C71EA5D59B05F95CB88E6', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100212, 0, CAST(N'2016-11-24 23:36:02.2019545' AS DateTime2), NULL, NULL, CAST(N'2016-11-24 23:54:19.647' AS DateTime), CAST(N'2016-11-24 23:49:19.647' AS DateTime), NULL, 1, NULL, N'C2DC1A65A89A991E8BA5DE417E60ED72', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100213, 0, CAST(N'2016-11-25 00:17:43.8270859' AS DateTime2), NULL, NULL, CAST(N'2016-11-25 00:34:34.277' AS DateTime), CAST(N'2016-11-25 00:29:34.277' AS DateTime), NULL, 1, NULL, N'39562686CFF3AFDC438274D82908ACA7', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100214, 0, CAST(N'2016-11-25 00:35:53.3405021' AS DateTime2), NULL, NULL, CAST(N'2016-11-25 00:49:51.827' AS DateTime), CAST(N'2016-11-25 00:44:51.827' AS DateTime), NULL, 1, NULL, N'526C57F0BEEEACE6415A21E7B2778C66', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (100215, 0, CAST(N'2016-11-25 00:51:35.5337572' AS DateTime2), NULL, NULL, CAST(N'2016-11-25 01:01:21.113' AS DateTime), CAST(N'2016-11-25 00:56:21.113' AS DateTime), NULL, 1, NULL, N'82898F3971C69F1AE938D1489D0497DF', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110206, 0, CAST(N'2016-11-26 12:23:41.0146192' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 12:29:52.130' AS DateTime), CAST(N'2016-11-26 12:24:52.130' AS DateTime), NULL, 1, NULL, N'FD8BD3E15A7F3B96576885C83ED3B4FA', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110207, 0, CAST(N'2016-11-26 12:25:30.5932195' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 12:30:36.360' AS DateTime), CAST(N'2016-11-26 12:25:36.360' AS DateTime), NULL, 1, NULL, N'8BBF16D50B6AA10444056D46DC33DE7F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110208, 0, CAST(N'2016-11-26 12:26:19.7684407' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 12:31:29.280' AS DateTime), CAST(N'2016-11-26 12:26:29.280' AS DateTime), NULL, 6, NULL, N'805016EB9B788A92FC6D7A738DCD5FE6', 10002)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110209, 0, CAST(N'2016-11-26 12:26:39.5437151' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 12:31:39.587' AS DateTime), CAST(N'2016-11-26 12:26:39.587' AS DateTime), NULL, 1, NULL, N'B59305AE72A0AB450ABC2392559997AE', 10002)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110210, 0, CAST(N'2016-11-26 12:35:08.7850027' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 12:40:14.443' AS DateTime), CAST(N'2016-11-26 12:35:14.443' AS DateTime), NULL, 1, NULL, N'A973B1A9782D732D9250888A12892CA2', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110211, 0, CAST(N'2016-11-26 12:50:12.4438112' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 12:58:56.873' AS DateTime), CAST(N'2016-11-26 12:53:56.873' AS DateTime), NULL, 1, NULL, N'D30FCE9FADC362F404D79706D0CE152F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110212, 0, CAST(N'2016-11-26 13:15:32.9283207' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 13:24:58.433' AS DateTime), CAST(N'2016-11-26 13:19:58.433' AS DateTime), NULL, 1, NULL, N'83EF7D671123AFD25D00D39DF098A87C', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110213, 0, CAST(N'2016-11-26 13:20:30.5560985' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 13:31:15.283' AS DateTime), CAST(N'2016-11-26 13:26:15.283' AS DateTime), NULL, 1, NULL, N'15C2A4F2218AB65D0FFA26EFFD1D77E5', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110214, 0, CAST(N'2016-11-26 13:33:51.0680768' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 13:40:09.137' AS DateTime), CAST(N'2016-11-26 13:35:09.137' AS DateTime), NULL, 1, NULL, N'E19AF9E875F3DFFBBFE6E4EAE672FB7A', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110215, 0, CAST(N'2016-11-26 14:31:46.1349939' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 14:36:47.553' AS DateTime), CAST(N'2016-11-26 14:31:47.553' AS DateTime), NULL, 1, NULL, N'76930197E539BA0AF216E723519216FA', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110216, 0, CAST(N'2016-11-26 14:44:54.0306397' AS DateTime2), NULL, 14, CAST(N'2016-11-26 14:51:41.727' AS DateTime), CAST(N'2016-11-26 14:46:41.727' AS DateTime), NULL, 1, NULL, N'7A682AEE3BA157B54870F1F3FE11B749', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110217, 0, CAST(N'2016-11-26 14:46:26.9309424' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 14:53:47.273' AS DateTime), CAST(N'2016-11-26 14:48:47.273' AS DateTime), NULL, 1, NULL, N'77F867307391711358DB947830EC0531', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110218, 0, CAST(N'2016-11-26 15:01:22.8618740' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 15:07:06.130' AS DateTime), CAST(N'2016-11-26 15:02:06.130' AS DateTime), NULL, 1, NULL, N'4CAE9E8BC67348441C185D6929171F49', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110219, 0, CAST(N'2016-11-26 15:01:29.0326351' AS DateTime2), NULL, 14, CAST(N'2016-11-26 15:07:44.480' AS DateTime), CAST(N'2016-11-26 15:02:44.480' AS DateTime), NULL, 1, NULL, N'FA4480BAD97D8F47C0D122A36CC8FDF0', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110220, 0, CAST(N'2016-11-26 15:21:07.2683295' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 15:35:03.710' AS DateTime), CAST(N'2016-11-26 15:30:03.710' AS DateTime), NULL, 1, NULL, N'1034B6AA4211D24E5AC0901F180F8360', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110221, 0, CAST(N'2016-11-26 15:42:01.5306585' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 15:47:18.057' AS DateTime), CAST(N'2016-11-26 15:42:18.057' AS DateTime), NULL, 1, NULL, N'BB177FD70184B255522874893C40AAD1', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110222, 0, CAST(N'2016-11-26 16:26:48.8939531' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 16:45:06.517' AS DateTime), CAST(N'2016-11-26 16:40:06.517' AS DateTime), NULL, 1, NULL, N'43B17198E3A92DDF6B7965376CA720FC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (110223, 0, CAST(N'2016-11-26 16:53:55.3373700' AS DateTime2), NULL, NULL, CAST(N'2016-11-26 16:58:55.923' AS DateTime), CAST(N'2016-11-26 16:53:55.923' AS DateTime), NULL, 1, NULL, N'9253FFFA821F3AFD0B4988EC7FCA4BB7', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120206, 0, CAST(N'2016-11-27 12:34:03.0760385' AS DateTime2), NULL, NULL, CAST(N'2016-11-27 12:44:12.397' AS DateTime), CAST(N'2016-11-27 12:39:12.397' AS DateTime), NULL, 1, NULL, N'A796259770F8035B13DF6F546B51F4B3', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120207, 0, CAST(N'2016-11-27 12:36:05.4066388' AS DateTime2), NULL, 14, CAST(N'2016-11-27 12:42:33.593' AS DateTime), CAST(N'2016-11-27 12:37:33.593' AS DateTime), NULL, 1, NULL, N'CE72D8D732151B2DA4BE96978FCEBC82', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120208, 0, CAST(N'2016-11-27 13:05:28.6070844' AS DateTime2), NULL, NULL, CAST(N'2016-11-27 13:10:35.817' AS DateTime), CAST(N'2016-11-27 13:05:35.817' AS DateTime), NULL, 1, NULL, N'89E60A5A52059666CF0975395EABE3FB', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120209, 0, CAST(N'2016-11-27 13:11:37.0526833' AS DateTime2), NULL, NULL, CAST(N'2016-11-27 13:24:43.960' AS DateTime), CAST(N'2016-11-27 13:19:43.960' AS DateTime), NULL, 1, NULL, N'A35AA97469DC6517DAAA92BC0B25AFBB', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120210, 0, CAST(N'2016-11-27 13:35:04.2986206' AS DateTime2), NULL, NULL, CAST(N'2016-11-27 13:50:51.243' AS DateTime), CAST(N'2016-11-27 13:45:51.243' AS DateTime), NULL, 1, NULL, N'79318A93F15F1840AB2F5DB11F3832F6', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120211, 0, CAST(N'2016-11-27 14:10:32.6677480' AS DateTime2), NULL, NULL, CAST(N'2016-11-27 14:25:44.863' AS DateTime), CAST(N'2016-11-27 14:20:44.863' AS DateTime), NULL, 1, NULL, N'294E84856C31AE030BFBC36B4C70972C', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120212, 0, CAST(N'2016-11-27 14:22:26.7606028' AS DateTime2), NULL, 14, CAST(N'2016-11-27 14:27:38.287' AS DateTime), CAST(N'2016-11-27 14:22:38.287' AS DateTime), NULL, 1, NULL, N'A894A5782E7685B41456A12D22672B12', NULL)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120213, 0, CAST(N'2016-11-27 21:18:14.6933672' AS DateTime2), NULL, NULL, CAST(N'2016-11-27 21:23:50.540' AS DateTime), CAST(N'2016-11-27 21:18:50.540' AS DateTime), NULL, 1, NULL, N'95BF8EF4647779206253A9DFBEE3FB84', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120214, 0, CAST(N'2016-11-27 21:33:23.5433735' AS DateTime2), NULL, NULL, CAST(N'2016-11-27 21:44:56.930' AS DateTime), CAST(N'2016-11-27 21:39:56.930' AS DateTime), NULL, 1, NULL, N'C94CAFF4099D72C248BCF873E8E2FC01', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120215, 0, CAST(N'2016-11-27 21:52:34.9162347' AS DateTime2), NULL, NULL, CAST(N'2016-11-27 22:12:37.560' AS DateTime), CAST(N'2016-11-27 22:07:37.560' AS DateTime), NULL, 1, NULL, N'EDF3C4EDE03DEF1D02843B7A04900A59', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120216, 0, CAST(N'2016-11-27 22:07:54.9756484' AS DateTime2), NULL, NULL, CAST(N'2016-11-27 22:14:44.807' AS DateTime), CAST(N'2016-11-27 22:09:44.807' AS DateTime), NULL, 1, NULL, N'A567444357496469DC672FB06EC9311E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120217, 0, CAST(N'2016-11-27 22:20:35.9946931' AS DateTime2), NULL, NULL, CAST(N'2016-11-27 22:42:51.977' AS DateTime), CAST(N'2016-11-27 22:37:51.977' AS DateTime), NULL, 1, NULL, N'A075A14BAEA02E748826B9345E05CAED', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120218, 0, CAST(N'2016-11-28 22:11:12.0562946' AS DateTime2), NULL, NULL, CAST(N'2016-11-28 22:25:39.047' AS DateTime), CAST(N'2016-11-28 22:20:39.047' AS DateTime), NULL, 1, NULL, N'50D7581D140E4814332831535F8BB8D3', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120219, 0, CAST(N'2016-11-28 22:44:18.2762047' AS DateTime2), NULL, NULL, CAST(N'2016-11-28 23:00:57.270' AS DateTime), CAST(N'2016-11-28 22:55:57.270' AS DateTime), NULL, 1, NULL, N'53A2A0C1B3E1BBF00DD03DD61DBD33E4', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120220, 0, CAST(N'2016-11-28 23:10:16.8858731' AS DateTime2), NULL, NULL, CAST(N'2016-11-28 23:23:17.577' AS DateTime), CAST(N'2016-11-28 23:18:17.577' AS DateTime), NULL, 1, NULL, N'46ABA37287303B195DEB376D820BFEF1', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120221, 0, CAST(N'2016-11-29 00:13:16.7509176' AS DateTime2), NULL, NULL, CAST(N'2016-11-29 00:20:10.357' AS DateTime), CAST(N'2016-11-29 00:15:10.357' AS DateTime), NULL, 1, NULL, N'6AC87C2F7FA5AE1DE95D62C8F83D2D55', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120222, 0, CAST(N'2016-12-03 11:14:57.4913051' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 11:20:41.127' AS DateTime), CAST(N'2016-12-03 11:15:41.127' AS DateTime), NULL, 1, NULL, N'02E472C2EEC8B60E58D07C4956D392FA', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120223, 0, CAST(N'2016-12-03 11:47:51.1257407' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 11:52:55.770' AS DateTime), CAST(N'2016-12-03 11:47:55.770' AS DateTime), NULL, 1, NULL, N'AE2660E0EC9CF6435BCE461A1601268E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120224, 0, CAST(N'2016-12-03 12:19:02.2247643' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 12:24:42.903' AS DateTime), CAST(N'2016-12-03 12:19:42.903' AS DateTime), NULL, 1, NULL, N'49C33D8B67AE0C2C8417FC54EED413A6', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120225, 0, CAST(N'2016-12-03 12:37:44.3280997' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 12:49:15.917' AS DateTime), CAST(N'2016-12-03 12:44:15.917' AS DateTime), NULL, 1, NULL, N'B6F1C7BCE57DF5069006DBE416F6810E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120226, 0, CAST(N'2016-12-03 12:50:05.6255018' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 13:02:02.300' AS DateTime), CAST(N'2016-12-03 12:57:02.300' AS DateTime), NULL, 1, NULL, N'C88FCA0A89279B2F0707D463174E781B', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120227, 0, CAST(N'2016-12-03 13:16:03.3319939' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 13:22:51.847' AS DateTime), CAST(N'2016-12-03 13:17:51.847' AS DateTime), NULL, 1, NULL, N'4A3CDEAA1D71D346AB10A5D35C209AED', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120228, 0, CAST(N'2016-12-03 13:29:56.5873396' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 13:52:09.263' AS DateTime), CAST(N'2016-12-03 13:47:09.263' AS DateTime), NULL, 1, NULL, N'81DA6CD5AD603CCAEAFD06992714199C', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120229, 0, CAST(N'2016-12-03 15:03:41.0410068' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 15:09:00.777' AS DateTime), CAST(N'2016-12-03 15:04:00.777' AS DateTime), NULL, 1, NULL, N'1D1A8FD4AA16D4908556F2E17FCFEFDE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120230, 0, CAST(N'2016-12-03 15:12:02.1144233' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 15:21:03.563' AS DateTime), CAST(N'2016-12-03 15:16:03.563' AS DateTime), NULL, 1, NULL, N'78F5D2879A2CAB7723CD7A3CA8E5CDBC', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120231, 0, CAST(N'2016-12-03 15:30:36.6699578' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 15:36:36.923' AS DateTime), CAST(N'2016-12-03 15:31:36.923' AS DateTime), NULL, 1, NULL, N'DE09F4136FC8A88F7ADDC1877EBDCB79', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120232, 0, CAST(N'2016-12-03 15:41:26.3080203' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 15:58:21.593' AS DateTime), CAST(N'2016-12-03 15:53:21.593' AS DateTime), NULL, 1, NULL, N'6F41EB3D4444290AC5E4B93F3DBEDA6E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120233, 0, CAST(N'2016-12-03 16:00:47.8661945' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 16:11:18.193' AS DateTime), CAST(N'2016-12-03 16:06:18.193' AS DateTime), NULL, 1, NULL, N'B01C5372EE99AE52823B68CD78D6878C', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120234, 0, CAST(N'2016-12-03 16:20:08.0479479' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 16:29:03.680' AS DateTime), CAST(N'2016-12-03 16:24:03.680' AS DateTime), NULL, 1, NULL, N'208EC3026B9CD9F5D1918D0B32C42989', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120235, 0, CAST(N'2016-12-03 16:32:10.1198069' AS DateTime2), NULL, NULL, CAST(N'2016-12-03 17:04:43.207' AS DateTime), CAST(N'2016-12-03 16:59:43.207' AS DateTime), NULL, 1, NULL, N'100D27854FE5F96236D37765B86F0637', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120236, 0, CAST(N'2016-12-07 22:08:32.1914898' AS DateTime2), NULL, NULL, CAST(N'2016-12-07 22:14:13.797' AS DateTime), CAST(N'2016-12-07 22:09:13.797' AS DateTime), NULL, 1, NULL, N'D29D52AEEA56F0556132803C4D73E1BE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120237, 0, CAST(N'2016-12-07 22:26:51.5523133' AS DateTime2), NULL, NULL, CAST(N'2016-12-07 22:32:19.510' AS DateTime), CAST(N'2016-12-07 22:27:19.510' AS DateTime), NULL, 1, NULL, N'1E61576270A619DE479F1910661D735D', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120238, 0, CAST(N'2016-12-11 16:15:10.0714025' AS DateTime2), NULL, NULL, CAST(N'2016-12-11 16:27:20.747' AS DateTime), CAST(N'2016-12-11 16:22:20.747' AS DateTime), NULL, 1, NULL, N'5F07D6A19873D8D07014E585B2E2155F', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120239, 0, CAST(N'2016-12-11 21:13:32.4783092' AS DateTime2), NULL, NULL, CAST(N'2016-12-11 21:21:37.180' AS DateTime), CAST(N'2016-12-11 21:16:37.180' AS DateTime), NULL, 1, NULL, N'2C9AA308D1850C06E0B2A3D0DED0CDE1', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120240, 0, CAST(N'2016-12-11 21:28:07.7384490' AS DateTime2), NULL, NULL, CAST(N'2016-12-11 21:55:46.557' AS DateTime), CAST(N'2016-12-11 21:50:46.557' AS DateTime), NULL, 1, NULL, N'A18BCDFED4BE65B804BBCB2E2E4D5057', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120241, 0, CAST(N'2016-12-11 22:28:24.7556715' AS DateTime2), NULL, NULL, CAST(N'2016-12-11 22:47:42.217' AS DateTime), CAST(N'2016-12-11 22:42:42.217' AS DateTime), NULL, 1, NULL, N'A940D8876663464D4C0D9E2240518705', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120242, 0, CAST(N'2016-12-11 22:48:23.8977845' AS DateTime2), NULL, NULL, CAST(N'2016-12-11 22:54:26.827' AS DateTime), CAST(N'2016-12-11 22:49:26.827' AS DateTime), NULL, 1, NULL, N'382458E1CC3CD056750D81D8B24879BE', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120243, 0, CAST(N'2016-12-12 10:29:34.9337438' AS DateTime2), NULL, NULL, CAST(N'2016-12-12 10:39:57.257' AS DateTime), CAST(N'2016-12-12 10:34:57.257' AS DateTime), NULL, 1, NULL, N'C207ABDED9ABA6C17F39453AC67C95E5', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120244, 0, CAST(N'2016-12-12 10:46:32.1732994' AS DateTime2), NULL, NULL, CAST(N'2016-12-12 11:01:16.420' AS DateTime), CAST(N'2016-12-12 10:56:16.420' AS DateTime), NULL, 1, NULL, N'EA8690C81C4D5AFC3C36E2216A43B62E', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120245, 0, CAST(N'2016-12-12 11:20:55.9553550' AS DateTime2), NULL, NULL, CAST(N'2016-12-12 11:33:22.943' AS DateTime), CAST(N'2016-12-12 11:28:22.943' AS DateTime), NULL, 1, NULL, N'41E8E9127E5F5C60E2CC5A8F67E9A236', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120246, 0, CAST(N'2016-12-12 12:13:18.9796772' AS DateTime2), NULL, NULL, CAST(N'2016-12-12 12:28:55.243' AS DateTime), CAST(N'2016-12-12 12:23:55.243' AS DateTime), NULL, 1, NULL, N'516176EB693D348EF675813A918C5F29', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120247, 0, CAST(N'2016-12-12 14:52:43.7854891' AS DateTime2), NULL, NULL, CAST(N'2016-12-12 15:07:14.870' AS DateTime), CAST(N'2016-12-12 15:02:14.870' AS DateTime), NULL, 1, NULL, N'C930C867A14839D43E87DDF1072FFDD8', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120248, 0, CAST(N'2016-12-12 15:12:22.8371283' AS DateTime2), NULL, NULL, CAST(N'2016-12-12 15:17:55.157' AS DateTime), CAST(N'2016-12-12 15:12:55.157' AS DateTime), NULL, 1, NULL, N'C2989CD5F4E37BCBEA7390EC7A8CE3F8', 1)
GO
INSERT [dbo].[UserSession] ([Id], [IsDeleted], [DateCreated], [LastModifiedDate], [CustomerUserID], [ExpiryDate], [LastAccessed], [LogoutDate], [SessionStatus], [AccessCount], [Token], [UserId]) VALUES (120249, 0, CAST(N'2016-12-12 15:21:00.5495287' AS DateTime2), NULL, NULL, CAST(N'2016-12-12 15:33:48.357' AS DateTime), CAST(N'2016-12-12 15:28:48.357' AS DateTime), NULL, 1, NULL, N'C1832440B10321AFA4C0517EE9909399', 1)
GO
SET IDENTITY_INSERT [dbo].[UserSession] OFF
GO
ALTER TABLE [dbo].[CustomerPolicies]  WITH CHECK ADD  CONSTRAINT [FK_CustomerPolicies_CustomerUser] FOREIGN KEY([CustomerUserId])
REFERENCES [dbo].[CustomerUser] ([Id])
GO
ALTER TABLE [dbo].[CustomerPolicies] CHECK CONSTRAINT [FK_CustomerPolicies_CustomerUser]
GO
ALTER TABLE [dbo].[fl_agents]  WITH CHECK ADD  CONSTRAINT [FK_fl_agents_ac_costCenter] FOREIGN KEY([locationId])
REFERENCES [dbo].[ac_costCenter] ([Id])
GO
ALTER TABLE [dbo].[fl_agents] CHECK CONSTRAINT [FK_fl_agents_ac_costCenter]
GO
ALTER TABLE [dbo].[fl_policyinput]  WITH CHECK ADD  CONSTRAINT [FK_fl_policyinput_fl_location] FOREIGN KEY([location])
REFERENCES [dbo].[fl_location] ([Id])
GO
ALTER TABLE [dbo].[fl_policyinput] CHECK CONSTRAINT [FK_fl_policyinput_fl_location]
GO
ALTER TABLE [dbo].[fl_premrate]  WITH CHECK ADD  CONSTRAINT [FK_fl_premrate_fl_grouptype] FOREIGN KEY([grpId])
REFERENCES [dbo].[fl_grouptype] ([Id])
GO
ALTER TABLE [dbo].[fl_premrate] CHECK CONSTRAINT [FK_fl_premrate_fl_grouptype]
GO
ALTER TABLE [dbo].[fl_premrate]  WITH CHECK ADD  CONSTRAINT [FK_fl_premrate_fl_poltype] FOREIGN KEY([poltypeId])
REFERENCES [dbo].[fl_poltype] ([Id])
GO
ALTER TABLE [dbo].[fl_premrate] CHECK CONSTRAINT [FK_fl_premrate_fl_poltype]
GO
ALTER TABLE [dbo].[fl_premrateRules]  WITH CHECK ADD  CONSTRAINT [FK_fl_premrateRules_fl_premrate] FOREIGN KEY([PremRateId])
REFERENCES [dbo].[fl_premrate] ([Id])
GO
ALTER TABLE [dbo].[fl_premrateRules] CHECK CONSTRAINT [FK_fl_premrateRules_fl_premrate]
GO
ALTER TABLE [dbo].[fl_receiptcontrol]  WITH CHECK ADD  CONSTRAINT [FK_fl_receiptcontrol_fl_poltype] FOREIGN KEY([PolTypeId])
REFERENCES [dbo].[fl_poltype] ([Id])
GO
ALTER TABLE [dbo].[fl_receiptcontrol] CHECK CONSTRAINT [FK_fl_receiptcontrol_fl_poltype]
GO
ALTER TABLE [dbo].[LinkRole]  WITH CHECK ADD  CONSTRAINT [FK_LinkRole_Role] FOREIGN KEY([RoleID])
REFERENCES [dbo].[Role] ([Id])
GO
ALTER TABLE [dbo].[LinkRole] CHECK CONSTRAINT [FK_LinkRole_Role]
GO
ALTER TABLE [dbo].[NextofKin_BeneficiaryStaging]  WITH CHECK ADD  CONSTRAINT [FK_NextofKin_BeneficiaryStaging_PersonalDetailsStaging] FOREIGN KEY([PersonalDetailsStagingId])
REFERENCES [dbo].[PersonalDetailsStaging] ([Id])
GO
ALTER TABLE [dbo].[NextofKin_BeneficiaryStaging] CHECK CONSTRAINT [FK_NextofKin_BeneficiaryStaging_PersonalDetailsStaging]
GO
ALTER TABLE [dbo].[PersonalDetailsStaging]  WITH CHECK ADD  CONSTRAINT [FK_PersonalDetailsStaging_fl_poltype] FOREIGN KEY([PolicyType])
REFERENCES [dbo].[fl_poltype] ([Id])
GO
ALTER TABLE [dbo].[PersonalDetailsStaging] CHECK CONSTRAINT [FK_PersonalDetailsStaging_fl_poltype]
GO
ALTER TABLE [dbo].[Tabs]  WITH CHECK ADD  CONSTRAINT [FK_Tabs_Portlet] FOREIGN KEY([PortletId])
REFERENCES [dbo].[Portlet] ([Id])
GO
ALTER TABLE [dbo].[Tabs] CHECK CONSTRAINT [FK_Tabs_Portlet]
GO
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_fl_password] FOREIGN KEY([UserId])
REFERENCES [dbo].[fl_password] ([Id])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_fl_password]
GO
ALTER TABLE [dbo].[UserRole]  WITH CHECK ADD  CONSTRAINT [FK_UserRole_Role] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Role] ([Id])
GO
ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_Role]
GO
ALTER TABLE [dbo].[UserSession]  WITH CHECK ADD  CONSTRAINT [FK_UserSession_CustomerUser] FOREIGN KEY([CustomerUserID])
REFERENCES [dbo].[CustomerUser] ([Id])
GO
ALTER TABLE [dbo].[UserSession] CHECK CONSTRAINT [FK_UserSession_CustomerUser]
GO
ALTER TABLE [dbo].[UserSession]  WITH CHECK ADD  CONSTRAINT [FK_UserSession_fl_password] FOREIGN KEY([UserId])
REFERENCES [dbo].[fl_password] ([Id])
GO
ALTER TABLE [dbo].[UserSession] CHECK CONSTRAINT [FK_UserSession_fl_password]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[37] 4[24] 2[14] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "vwp"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 13
         End
         Begin Table = "pi"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "fl_translog"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 136
               Right = 632
            End
            DisplayFlags = 280
            TopColumn = 9
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 13
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vProduction'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vProduction'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[26] 4[22] 2[30] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "p"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 16
         End
         Begin Table = "fl_location"
            Begin Extent = 
               Top = 6
               Left = 486
               Bottom = 136
               Right = 672
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 710
               Bottom = 136
               Right = 905
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "vph"
            Begin Extent = 
               Top = 6
               Left = 262
               Bottom = 136
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 15
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 141' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwPolicy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'0
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwPolicy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwPolicy'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[33] 4[11] 2[26] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "fl_payhistory"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 9
         End
         Begin Table = "fl_policyinput"
            Begin Extent = 
               Top = 6
               Left = 262
               Bottom = 136
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 18
         End
         Begin Table = "fl_location"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 12
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwPolicyHistory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwPolicyHistory'
GO
USE [master]
GO
ALTER DATABASE [NLPC_newdata] SET  READ_WRITE 
GO
