use SATenantConsolidated_Tabs3_and_MyCase
go


--select * from Baldante_Highrise..tasks where company_id = 341408048
--select * from Baldante_Highrise..contacts where id = 341408048

--select * from Baldante_Highrise..notes where contact_id = 290875904
--select * from Baldante_Highrise..company c where id = 290875904

--SELECT top 10 t.*, c.id, cas.casnCaseID
--FROM Baldante_Highrise..tasks t
--join Baldante_Highrise..contacts c
--on t.contact_id = c.id
--join Baldante_Consolidated..sma_TRN_Cases cas on cas.cassCaseNumber = c.company_name and cas.source_db = 'tabs3'

set quoted_identifier on
go


/* ------------------------------------------------------------------------------
Build staging table [stg_Highrise_Tasks]
*/ ------------------------------------------------------------------------------
if OBJECT_ID('dbo.stg_Highrise_Tasks', 'U') is not null
	drop table dbo.stg_Highrise_Tasks;

go

create table dbo.stg_Highrise_Tasks (
	source_table   VARCHAR(25),
	task_id		   INT			 not null,
	task_key	   VARCHAR(30)	 null,
	contact_id	   INT,
	company_id	   INT,
	about		   NVARCHAR(400) null,
	body		   NVARCHAR(MAX) null,
	written_date   DATETIME		 null,
	author		   NVARCHAR(200) null,
	cas_casnCaseID INT			 not null,
	cas_source_id  VARCHAR(20)	 not null,
	cas_source_db  VARCHAR(20)	 not null,
	cas_source_ref VARCHAR(20)	 null
);

create index IX_stg_Highrise_Tasks_email
on dbo.stg_Highrise_Tasks (task_id);

create index IX_stg_Highrise_Tasks_case
on dbo.stg_Highrise_Tasks (cas_casnCaseID);
go

insert into dbo.stg_Highrise_Tasks
	(
		source_table, task_id, task_key, contact_id, company_id,
		about, body, written_date, author,
		cas_casnCaseID, cas_source_id, cas_source_db, cas_source_ref
	)
	select
		source_table,
		task_id,
		task_key,
		contact_id,
		company_id,
		about,
		body,
		written_date,
		author,
		cas_casnCaseID,
		cas_source_id,
		cas_source_db,
		cas_source_ref
	from (
		select
			sub.*,
			ROW_NUMBER() over (
			PARTITION BY sub.body, sub.written_date, sub.author, sub.cas_casnCaseID
			order by (case when sub.source_table = 'contacts' then 1 else 2 end), sub.task_id
			) as row_num
		from (
				-- 1. Tasks from [contacts] for highrise cases
				select
					'contacts'	   as source_table,
					t.id		   as task_id,
					t.task_key,
					t.contact_id,
					t.company_id,
					t.about,
					t.body,
					t.written_date,
					t.author,
					cas.casnCaseID as cas_casnCaseID,
					cas.source_id  as cas_source_id,
					cas.source_db  as cas_source_db,
					cas.source_ref as cas_source_ref
				from Baldante_Highrise..tasks t
					join Baldante_Highrise..contacts c
						on t.contact_id = c.id
					join sma_TRN_Cases cas
						on cas.source_id = c.id
						and cas.source_db = 'highrise'
						and cas.source_ref = 'contacts'
					--where t.about = 'Marcus Hansford'

				union all

				-- 2. Tasks from [company] for highrise cases
				select
					'company',
					t.id,
					t.task_key,
					t.contact_id,
					t.company_id,
					t.about,
					t.body,
					t.written_date,
					t.author,
					cas.casnCaseID,
					cas.source_id,
					cas.source_db,
					cas.source_ref
				from Baldante_Highrise..tasks t
					join Baldante_Highrise..company com
						on t.company_id = com.id
					join sma_TRN_Cases cas
						on cas.source_id = com.id
						and cas.source_db = 'highrise'
						and cas.source_ref = 'company'

				union all

				-- 3. Tasks from [contacts] for Tabs3 cases
				select
					'contacts',
					t.id,
					t.task_key,
					t.contact_id,
					t.company_id,
					t.about,
					t.body,
					t.written_date,
					t.author,
					cas.casnCaseID,
					cas.source_id,
					cas.source_db,
					cas.source_ref
				from Baldante_Highrise..tasks t
					join Baldante_Highrise..contacts c
						on t.contact_id = c.id
					join sma_TRN_Cases cas
						on cas.cassCaseNumber = c.company_name
						and cas.source_db = 'Tabs3'
						--where t.about = 'Marcus Hansford'

				union all

				-- 4. Tasks from [company] for Tabs3 cases
				select
					'company',
					t.id,
					t.task_key,
					t.contact_id,
					t.company_id,
					t.about,
					t.body,
					t.written_date,
					t.author,
					cas.casnCaseID,
					cas.source_id,
					cas.source_db,
					cas.source_ref
				from Baldante_Highrise..tasks t
					join Baldante_Highrise..company com
						on t.company_id = com.id
					join sma_TRN_Cases cas
						on cas.cassCaseNumber = com.name
						and cas.source_db = 'Tabs3'
						--where t.about = 'Marcus Hansford'
			) sub
	) final
	where
		final.row_num = 1;
go

---- tasks from [contacts] for highrise cases
--select
--	'contacts' as source_table,
--	t.id,
--	t.task_key,
--	t.contact_id,
--	t.company_id,
--	t.about,
--	t.body,
--	t.written_date,
--	t.author,
--	cas.casnCaseID,
--	cas.source_id,
--	cas.source_db,
--	cas.source_ref
----select *
--from Baldante_Highrise..tasks t
--join Baldante_Highrise..contacts c on t.contact_id = c.id
--join sma_TRN_Cases cas on cas.source_id = c.id
--		and cas.source_db = 'highrise'
--		and cas.source_ref = 'contacts'

--union

---- tasks from [company] for highrise cases
--select
--	'company' as source_table,
--	t.id,
--	t.task_key,
--	t.contact_id,
--	t.company_id,
--	t.about,
--	t.body,
--	t.written_date,
--	t.author,
--	cas.casnCaseID,
--	cas.source_id,
--	cas.source_db,
--	cas.source_ref
----select *
--from Baldante_Highrise..tasks t
--join Baldante_Highrise..company com on t.company_id = com.id
--join sma_TRN_Cases cas on cas.source_id = com.id
--		and cas.source_db = 'highrise'
--		and cas.source_ref = 'company'

--union all

---- tasks from [contacts] for Tabs3 cases
--select
--	'contacts' as source_table,
--	t.id,
--	t.task_key,
--	t.contact_id,
--	t.company_id,
--	t.about,
--	t.body,
--	t.written_date,
--	t.author,
--	cas.casnCaseID,
--	cas.source_id,
--	cas.source_db,
--	cas.source_ref
----select *
--from Baldante_Highrise..tasks t
--join Baldante_Highrise..contacts c on t.contact_id = c.id
--join sma_TRN_Cases cas on cas.cassCaseNumber = c.company_name
--		and cas.source_db = 'Tabs3'

--union all

---- tasks from [company] for Tabs3 cases
--select
--	'company' as source_table,
--	t.id,
--	t.task_key,
--	t.contact_id,
--	t.company_id,
--	t.about,
--	t.body,
--	t.written_date,
--	t.author,
--	cas.casnCaseID,
--	cas.source_id,
--	cas.source_db,
--	cas.source_ref
--from Baldante_Highrise..tasks t
--join Baldante_Highrise..company com on t.company_id = com.id
--join sma_TRN_Cases cas on cas.cassCaseNumber = com.name
--		and cas.source_db = 'Tabs3'
go

--SELECT count(*) FROM Baldante_Highrise..tasks t
----18251
--SELECT count(*) FROM Baldante_Highrise..tasks t where t.contact_id is not null
----12232
--SELECT count(*) FROM Baldante_Highrise..tasks t where t.company_id is not null
--6019

--select * from stg_Highrise_Tasks where about = 'Marcus Hansford' -- contact_id = 343509826

/* ------------------------------------------------------------------------------
Insert [sma_MST_TaskCategory]
*/ ------------------------------------------------------------------------------
--select * from sma_MST_TaskCategory smtc

insert into [sma_MST_TaskCategory]
	(
		tskCtgDescription
	)

	select 'Highrise Task' except select tskCtgDescription from [sma_MST_TaskCategory]
go


/* ------------------------------------------------------------------------------
Insert [sma_TRN_TaskNew]
*/ ------------------------------------------------------------------------------
exec AddBreadcrumbsToTable 'sma_TRN_TaskNew'
alter table [sma_TRN_TaskNew] disable trigger all
go

insert into [sma_TRN_TaskNew]
	(
		[tskCaseID],
		[tskDueDate],
		[tskFollowDate],
		[tskStartDate],
		[tskCompletedDt],
		[tskRequestorID],
		[tskAssigneeId],
		[tskReminderDays],
		[tskDescription],
		[tskCreatedDt],
		[tskCreatedUserID],
		[tskModifiedDt],
		[tskModifyUserID],
		[tskMasterID],
		[tskCtgID],
		[tskSummary],
		[tskPriority],
		[tskCompleted],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		t.cas_casnCaseID																		   as [tskcaseid],
		case when ISDATE(t.written_date) = 1 and
				t.written_date between '1/1/1900' and '6/6/2079' then t.written_date else null end as [tskduedate],
		case when ISDATE(t.written_date) = 1 and
				t.written_date between '1/1/1900' and '6/6/2079' then t.written_date else null end as [tskFollowDate],
		case when ISDATE(t.written_date) = 1 and
				t.written_date between '1/1/1900' and '6/6/2079' then t.written_date else null end as [tskstartdate],
		null																					   as [tskcompleteddt],
		iu.SAusrnUserID																			   as [tskrequestorid],
		iu.SAusrnUserID																			   as [tskassigneeid],
		null																					   as [tskreminderdays],
		ISNULL(NULLIF(CONVERT(VARCHAR(MAX), t.body), '') + CHAR(13), '') +
		''																						   as [tskdescription],
		case when ISDATE(t.written_date) = 1 and
				t.written_date between '1/1/1900' and '6/6/2079' then t.written_date else null end as [tskcreateddt],
		iu.SAusrnUserID																			   as tskcreateduserid,
		null																					   as [tskmodifieddt],
		null																					   as [tskmodifyuserid],
		(
			select
				tskmasterid
			from sma_mst_Task_Template
			where tskMasterDetails = 'Custom Task'
		)																						   as [tskmasterid],
		(
			select
				tskctgid
			from sma_MST_TaskCategory
			where tskCtgDescription = 'Highrise Task'
		)																						   as [tskctgid],
		t.body																					   as [tsksummary],  -- Subject
		3																						   as [tskpriority], -- Normal priority
		0																						   as [tskcompleted], -- Not Started
		null																					   as [saga],
		t.task_id																				   as [source_id],
		'highrise'																				   as [source_db],
		'tasks'																					   as [source_ref]
	--SELECT *
	from stg_Highrise_Tasks t
	outer apply (
		select top 1
			iu.SAusrnUserID
		from implementation_users iu
		where iu.Staff = t.author
			and iu.Syst = 'HR'
		order by iu.SAusrnUserID -- Or another criteria to pick the "best" user match
	) iu
	where
		cas_casnCaseID = 56170
--left join implementation_users iu
--	on iu.Staff = t.author
--		and iu.Syst = 'HR'
go


alter table [sma_TRN_TaskNew] enable trigger all
go
