USE [NLPC_NewData]
GO

/****** Object:  StoredProcedure [dbo].[fl_production]    Script Date: 12/03/2021 14:15:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Batch submitted through debugger: SQLQuery1.sql|7|0|C:\Users\EU-NAT~2\AppData\Local\Temp\~vs5BF7.sql
CREATE PROCEDURE [dbo].[fl_production]
	@indicator  as nvarchar (2),  --to capture options
    @globalpol  as nvarchar (2),
	@globalstation as nvarchar(20),
	@comm as nvarchar(3),
	@sdate as nvarchar(8),
	@edate as nvarchar(8),
	@wcode as nvarchar(20)
AS
BEGIN
	declare @pol nvarchar(20), @rct nvarchar(20), @wpol nvarchar(20),@agentcode as nvarchar(10),@agenttype as varchar(15)
	declare @turnover money, @Type nvarchar(2),@polname nvarchar(50),@comrate money,@comm_bound money,@agentname as varchar(20),@comrate1 money,
	   @comm_bound2 money,@comm_bound3 money,@tdate nvarchar(8),@tdate1 nvarchar(10),@tdate2 datetime,@amt money, @Prmloan money,@policyloan money
	declare   @Loc nvarchar(15),@custloc nvarchar(15),@accdate datetime, @sname as nvarchar(20), @oname as nvarchar(20),@title as nvarchar(20)
	declare @ccdate nvarchar (8),@mkt_comrate money,@others money, @procdate nvarchar (8), @cnt integer,@mkt_comrate2 money,@mkt_comrate3 money
	declare @agentstatus nvarchar(15),@exitdate nvarchar(8),@exitdate1 as datetime,@wcday integer,@prm money,@wxdate datetime,@wdate nvarchar(8),@hold nvarchar(8)
	
	declare  rt  cursor for
    select commrate,mkt_commrate,mkt_commrate2, mkt_commrate3,comm_bound,comm_bound2,comm_bound3 from fl_premrate where poltype=@globalpol and substring(period,1,6)=substring(@sdate,1, 6) order by period desc
    open rt
    fetch next from rt into @comrate,@mkt_comrate,@mkt_comrate2,@mkt_comrate3,@comm_bound,@comm_bound2,@comm_bound3
	if @@fetch_status<>0 --return 6 
	begin
		declare  rt1  cursor for
      	select commrate,mkt_commrate,mkt_commrate2, mkt_commrate3,comm_bound,comm_bound2,comm_bound3 from fl_premrate where poltype=@globalpol and left(period,4)=substring(@sdate,1, 4) order by period desc
	    open rt1
	    fetch next from rt1 into @comrate,@mkt_comrate,@mkt_comrate2,@mkt_comrate3,@comm_bound,@comm_bound2,@comm_bound3
		close rt1
		deallocate rt1
	end
   	close rt
	deallocate rt
--	select @comrate, @mkt_comrate, @mkt_comrate2, @mkt_comrate3
	set @comrate = isnull(@comrate,1)
	set @mkt_comrate= isnull(@mkt_comrate,1)
--	set @mkt_comrate2= isnull(@mkt_comrate2,1)
--	set @mkt_comrate3= isnull(@mkt_comrate3,1)
	set @comm_bound= isnull(@comm_bound,0)
	set @comm_bound2= isnull(@comm_bound2,0)
	set @comm_bound3= isnull(@comm_bound3,0)
--	select @comrate, @mkt_comrate, @mkt_comrate2, @mkt_comrate3
--return 99
 	delete from fl_tempreceiptlist where work_station=@globalstation
	set @cnt=0
	set @wpol = '0'
	if @indicator=4 and len(@wcode)>0
	begin
		declare inpt cursor for
		select policyno, receiptno, Type,trandate,amount  from fl_payinput where trandate>=@sdate and trandate<=@edate and poltype=@globalpol and policyno in (select policyno from fl_policyinput where agentcode=@wcode) order by policyno,trandate
	end
	Else
	begin
		declare inpt cursor for
   		select policyno, receiptno, Type,trandate,amount from fl_payinput where trandate>=@sdate and trandate<=@edate and poltype=@globalpol order by policyno,trandate
	end
	open inpt
	fetch next from inpt into @pol, @rct, @type, @tdate, @amt 
	if @@fetch_status<>0 return 7
	while @@fetch_status=0
	begin
--00000000000000000
--		select @pol, @rct, @type, @tdate, @amt, @comrate
--close inpt
--deallocate inpt 
--		return  9
--ppppppppppppppppppp
		set @comrate1 = @comrate
	    If @wpol <> @pol 
	    begin
			set @cnt = @cnt + 1
		    set @wpol=@pol
        	declare mytab1 cursor for
	        select surname,othername,title,agentcode,location,custloc,accdate from fl_policyinput where policyno=@pol
        	open mytab1 
			fetch next from mytab1 into @sname,@oname,@title,@agentcode,@Loc,@custloc,@accdate
			If @@fetch_status<>0 
			begin
				close mytab1
				deallocate mytab1
       			GoTo nextdoc
			end
			close mytab1
			deallocate mytab1
		end

        set @turnover = (select sum(totamt) from fl_payinput where trandate>=@sdate and trandate<=@edate and policyno in (select policyno from fl_policyinput where agentcode=@agentcode))
        set @turnover = isnull(@turnover ,0)
  	    If @Type = 'PV'
	    begin
            GoTo nextdoc
	    end
        declare mytab2 cursor for
	    select agentname,agenttype,agentstatus from fl_agents where agentcode=@agentcode
	    open mytab2
	    fetch next from mytab2 into @agentname ,@agenttype ,@agentstatus 
		if @@fetch_status<>0
		begin
			set @agenttype = 'Staff'
		    set @agentname = 'No Agent Name'
			set @comrate1 = 0
		end
	    close mytab2
 	    deallocate mytab2
		set @wdate = cast(Year(@accdate) as varchar)
		set @hold = cast(Month(@accdate) as varchar)
		if len(@hold) < 2 set @hold = '0' + @hold
		set @wdate = @wdate + @hold
		set @hold = cast(day(@accdate) as varchar)
		if len(@hold) < 2 set @hold = '0' + @hold
		set @wdate = @wdate + @hold
		set @prm=@amt

	    If @indicator='5' set @agentname=isnull(@loc,'NO LOC')
    	If @indicator='11' set @agentname=isnull(@custloc,'NO CUSTOMER LOC')
        set @polname = @sname + @oname + @title
	    if @comm = 'Yes' set @prm = 0
	    If @comm = 'Yes' set @ccdate = @tdate
	    if @comm <> 'Yes' set @ccdate = @wdate
	    if substring(@ccdate,1,4) = substring(@edate,1,4)
	    begin
    	    if substring(@ccdate,1,6)=substring(@edate,1,6)
			begin
				set @prmloan=@amt
				if @comm='Yes'
				begin
					set @prm=@amt
					if @agenttype='Staff'
					begin
		     			set @prmloan = @amt * @comrate1 / 100
					end
					else
					begin
		    			if @agenttype='Marketer'
		    			begin
							if @tdate<='20160501'
							begin
								set	@prmloan = @amt * @mkt_comrate / 100
							end
							else
							begin
			    				If @turnover <= @comm_bound
								begin
									set @prmloan = @amt * @mkt_comrate / 100
									goto updaterec
								end
								If @turnover <= @comm_bound2 
								begin
									set @prmloan = @amt * @mkt_comrate2 / 100
									goto updaterec
								end
								If @turnover > @comm_bound2 
								begin
									set @prmloan = @amt * @mkt_comrate3 / 100
									goto updaterec
								end

							end
	    				end
	    				else
	    				begin
							set @prmloan=@amt
		    			end
					end
	    		end
	    		else
	    		begin
					set @prmloan=0
	    		end
            End 
            Else
            begin
            	set @policyloan = @amt
            End 
    	end
		Else
		begin
			set @others = @amt
			If @comm = 'Yes' set @others = 0
		End
	    set @procdate = @ccdate
		If @agentstatus = 'Exit' Or @agentstatus = 'WithHold'
		begin
			set @others = 0
			set @prmloan = 0
		End 
----00000000000000000
--		select @pol,  @rct, @type, @amt, @prm, @prmloan, @agenttype, @cnt
--if @cnt>9
--begin
--	close inpt
--	deallocate inpt 
--	return  9
--end
----ppppppppppppppppppp
updaterec:
		set @tdate1 = substring(@tdate,5,2) + '/' + right(@tdate,2) + '/' + left(@tdate,4)
		set @tdate2 = cast(@tdate as datetime)

		insert into fl_tempreceiptlist (work_station, createdby,policyno,processby,datecreated,trandate,type, agentname,polname,receiptno,premium,
		prmloan,totamt,policyloan, others, procdate,chequeno)
		values
			(@globalstation,substring(@edate,1,6),@pol,@type,@tdate2 ,@tdate1,@agentcode,@agentname,@polname,@rct,@prm,
			@prmloan,@turnover,@policyloan,@others,@procdate,@agenttype)

nextdoc:
		fetch next from inpt into @pol,@rct,@type,@tdate,@amt
	end 
	close inpt
	deallocate inpt

end
----CALCULATING CLAW BACK
set @prm=0
set @prmloan=0
declare clwbk cursor for
select surname,othername,title,agentcode,location,custloc,accdate, policyno,exitdate from fl_policyinput where exitdate<=@edate and exitdate>=@sdate order by agentcode
open clwbk
fetch next from clwbk  into @sname,@oname,@title,@agentcode,@Loc,@custloc,@accdate,@pol,@exitdate
while @@fetch_status=0
begin
    set @tdate2 = DateAdd("YYYY", 3, @accdate) --add 3 years to accdate

set @wxdate = @tdate2
set @wdate = cast(Year(@wxdate) as varchar)
set @hold = cast(Month(@wxdate) as varchar)
if len(@hold) < 2 set @hold = '0' + @hold
set @wdate = @wdate + @hold
set @hold = cast(day(@wxdate) as varchar)
if len(@hold) < 2 set @hold = '0' + @hold
set @wdate = @wdate + @hold

    set @tdate =@wdate
    If @exitdate > @tdate	--if policy is more than 3 years goto next rec
	begin
         GoTo nextclw
	end
        
-- -- convert to datetime
	set @tdate1 = substring(@exitdate,1,4) + '/' + substring(@exitdate,5,2) + '/' + substring(@exitdate,7,2)
	set @exitdate1 = cast(@tdate1 as datetime)
    set @wcday = DateDiff(D, @exitdate1, @tdate2) --calc remaining days to 3 years
    Set @turnover = (select sum(totamt) from fl_payinput where policyno = @pol)
    set @amt = @turnover * 5 * @wcday / 109500  -- calc amount due

    declare mytab2 cursor for
	select agentname,agenttype,agentstatus from fl_agents where agentcode=@agentcode
	open mytab2
	fetch next from mytab2 into @agentname ,@agenttype ,@agentstatus 
	close mytab2
 	deallocate mytab2
    set @agentname = isnull(@agentname, 'No Agent Name')
    If @indicator=5  set @agentname = isnull(@loc, 'NO LOC')
    If @indicator=11 set @agentname = isnull(@custLoc, 'NO CUSTOMER LOC')
	set @polname = @sname + ' '+ @oname + ' '+ @title
    set @rct = 'ClawBack'
    set @policyloan = 0 - @turnover
    set @others = 0 - @amt
    set @procdate = @ccdate

	insert into fl_tempreceiptlist (work_station, createdby,policyno,processby,datecreated,trandate,type, agentname,polname,receiptno,premium,
	prmloan,totamt, policyloan, others, procdate)
	values
		(@globalstation,substring(@edate,1,6),@pol,@type,@tdate1 ,@tdate1,@agentcode,@agentname,@polname,@rct,@prm,
		@prmloan,@turnover,@policyloan,@others,	@procdate)

nextclw:
	fetch next from clwbk  into @sname,@oname,@title,@agentcode,@Loc,@custloc,@accdate,@pol,@exitdate

end
close clwbk
deallocate clwbk



GO

