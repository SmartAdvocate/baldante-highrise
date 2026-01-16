use SATenantConsolidated_Tabs3_and_MyCase
go


--select * from Baldante_Highrise..notes where contact_id = 290875962
--select * from Baldante_Highrise..contacts where id = 290875962

--select * from Baldante_Highrise..notes where company_id = 341408048
--select * from Baldante_Highrise..company c where id = 341408048

set quoted_identifier on
go

if OBJECT_ID('dbo.stg_Highrise_Notes', 'U') is not null
	drop table dbo.stg_Highrise_Notes;

go

create table dbo.stg_Highrise_Notes (
	note_id		   INT			 not null,
	note_key	   VARCHAR(30)	 null,
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

create index IX_stg_Highrise_Notes_email
on dbo.stg_Highrise_Notes (note_id);

create index IX_stg_Highrise_Notes_case
on dbo.stg_Highrise_Notes (cas_casnCaseID);
go


insert into dbo.stg_Highrise_Notes
	(
		note_id,
		note_key,
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
	)

	-- notes from [contacts] for highrise cases
	select
		n.id,
		n.note_key,
		n.contact_id,
		n.company_id,
		n.about,
		n.body,
		n.written_date,
		n.author,
		cas.casnCaseID,
		cas.source_id,
		cas.source_db,
		cas.source_ref
	from Baldante_Highrise..notes n
	join Baldante_Highrise..contacts c
		on n.contact_id = c.id
	join sma_TRN_Cases cas
		on cas.source_id = c.id
			and cas.source_db = 'highrise'
			and cas.source_ref = 'contacts'

	union all

	-- notes from [company] for highrise cases
	select
		n.id,
		n.note_key,
		n.contact_id,
		n.company_id,
		n.about,
		n.body,
		n.written_date,
		n.author,
		cas.casnCaseID,
		cas.source_id,
		cas.source_db,
		cas.source_ref
	from Baldante_Highrise..notes n
	join Baldante_Highrise..company com
		on n.company_id = com.id
	join sma_TRN_Cases cas
		on cas.source_id = com.id
			and cas.source_db = 'highrise'
			and cas.source_ref = 'company'

	union all

	-- notes from [contacts] for Tabs3 cases
	select
		n.id,
		n.note_key,
		n.contact_id,
		n.company_id,
		n.about,
		n.body,
		n.written_date,
		n.author,
		cas.casnCaseID,
		cas.source_id,
		cas.source_db,
		cas.source_ref
	from Baldante_Highrise..notes n
	join Baldante_Highrise..contacts c
		on n.contact_id = c.id
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = c.company_name
			and cas.source_db = 'Tabs3'

	union all

	-- notes from [company] for Tabs3 cases
	select
		n.id,
		n.note_key,
		n.contact_id,
		n.company_id,
		n.about,
		n.body,
		n.written_date,
		n.author,
		cas.casnCaseID,
		cas.source_id,
		cas.source_db,
		cas.source_ref
	from Baldante_Highrise..notes n
	join Baldante_Highrise..company com
		on n.company_id = com.id
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = com.name
			and cas.source_db = 'Tabs3'
go


select * from stg_Highrise_Notes


/* ------------------------------------------------------------------------------
Insert [sma_TRN_Notes]
*/ ------------------------------------------------------------------------------
alter table [sma_TRN_Notes] disable trigger all
go

insert into [sma_TRN_Notes]
	(
		[notnCaseID],
		[notnNoteTypeID],
		[notmDescription],
		[notmPlainText],
		[notnContactCtgID],
		[notnContactId],
		[notsPriority],
		[notnFormID],
		[notnRecUserID],
		[notdDtCreated],
		[notnModifyUserID],
		[notdDtModified],
		[notnLevelNo],
		[notdDtInserted],
		[WorkPlanItemId],
		[notnSubject],
		--		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		n.cas_casnCaseID as [notnCaseID],
		(
		 select
			 MIN(nttnNoteTypeID)
		 from [sma_MST_NoteTypes]
		 where nttsDscrptn = 'General Comments'
		)				 as [notnNoteTypeID],
		CONCAT(
		COALESCE('Author: ' + n.author, '') + CHAR(10) + CHAR(13),
		COALESCE('About: ' + n.about, '') + CHAR(10) + CHAR(13),
		n.body)			 
		as [notmDescription],
		CONCAT(
		COALESCE('Author: ' + n.author, '') + '<br>',
		COALESCE('About: ' + n.about, '') + '<br>',
		n.body)			 as [notmPlainText],
		0				 as [notnContactCtgID],
		null			 as [notnContactId],
		null			 as [notsPriority],
		null			 as [notnFormID],
		iu.SAusrnUserID	 as [notnRecUserID],
		case
			when n.written_date between '1900-01-01' and '2079-06-06' then n.written_date
			else GETDATE()
		end				 as notdDtCreated,
		null			 as [notnModifyUserID],
		null			 as notdDtModified,
		null			 as [notnLevelNo],
		null			 as [notdDtInserted],
		null			 as [WorkPlanItemId],
		null			 as [notnSubject],
		--null			 [saga],
		n.note_id		 as [source_id],
		'highrise'		 as [source_db],
		'emails'		 as [source_ref]
	-- SELECT *
	from stg_Highrise_Notes n
	left join implementation_users iu
		on iu.Staff = n.author
			and iu.Syst = 'HR'
go

alter table [sma_TRN_Notes] enable trigger all
go