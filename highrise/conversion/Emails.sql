use SATenantConsolidated_Tabs3_and_MyCase
go

set quoted_identifier on
go

if OBJECT_ID('dbo.stg_Highrise_Emails', 'U') is not null
	drop table dbo.stg_Highrise_Emails;

go

create table dbo.stg_Highrise_Emails (
	email_id	   INT			 not null,
	email_key	   VARCHAR(30)	 null,
	contact_id	   INT,
	company_id	   INT,
	subject		   NVARCHAR(400) null,
	body		   NVARCHAR(MAX) null,
	written_date   DATETIME		 null,
	author		   NVARCHAR(200) null,
	cas_casnCaseID INT			 not null,
	cas_source_id  VARCHAR(20)	 not null,
	cas_source_db  VARCHAR(20)	 not null,
	cas_source_ref VARCHAR(20)	 null
);

create index IX_stg_Highrise_Emails_email
on dbo.stg_Highrise_Emails (email_id);

create index IX_stg_Highrise_Emails_case
on dbo.stg_Highrise_Emails (cas_casnCaseID);
go


insert into dbo.stg_Highrise_Emails
	(
		email_id,
		email_key,
		contact_id,
		company_id,
		subject,
		body,
		written_date,
		author,
		cas_casnCaseID,
		cas_source_id,
		cas_source_db,
		cas_source_ref
	)

	-- emails from [contacts] for highrise cases
	select
		e.id,
		e.email_key,
		e.contact_id,
		e.company_id,
		e.subject,
		e.body,
		e.written_date,
		e.author,
		cas.casnCaseID,
		cas.source_id,
		cas.source_db,
		cas.source_ref
	from Baldante_Highrise..emails e
	join Baldante_Highrise..contacts c
		on e.contact_id = c.id
	join sma_TRN_Cases cas
		on cas.source_id = c.id
			and cas.source_db = 'highrise'
			and cas.source_ref = 'contacts'

	union all

	-- Emails from [company] for highrise cases
	select
		e.id,
		e.email_key,
		e.contact_id,
		e.company_id,
		e.subject,
		e.body,
		e.written_date,
		e.author,
		cas.casnCaseID,
		cas.source_id,
		cas.source_db,
		cas.source_ref
	from Baldante_Highrise..emails e
	join Baldante_Highrise..company com
		on e.company_id = com.id
	join sma_TRN_Cases cas
		on cas.source_id = com.id
			and cas.source_db = 'highrise'
			and cas.source_ref = 'company'

	union all

	-- emails from [contacts] for Tabs3 cases
	select
		e.id,
		e.email_key,
		e.contact_id,
		e.company_id,
		e.subject,
		e.body,
		e.written_date,
		e.author,
		cas.casnCaseID,
		cas.source_id,
		cas.source_db,
		cas.source_ref
	from Baldante_Highrise..emails e
	join Baldante_Highrise..contacts c
		on e.contact_id = c.id
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = c.company_name
			and cas.source_db = 'Tabs3'

	union all

	-- Emails from [company] for Tabs3 cases
	select
		e.id,
		e.email_key,
		e.contact_id,
		e.company_id,
		e.subject,
		e.body,
		e.written_date,
		e.author,
		cas.casnCaseID,
		cas.source_id,
		cas.source_db,
		cas.source_ref
	from Baldante_Highrise..emails e
	join Baldante_Highrise..company com
		on e.company_id = com.id
	join sma_TRN_Cases cas
		on cas.cassCaseNumber = com.name
			and cas.source_db = 'Tabs3'
go


select * from stg_Highrise_Emails


/* ------------------------------------------------------------------------------
Insert [sma_TRN_Emails]
*/ ------------------------------------------------------------------------------
alter table sma_trn_emails disable trigger all
go

insert into [dbo].[sma_TRN_Emails]
	(
		[emlnCaseID],
		[emlnFrom],
		[emlsTableName],
		[emlsColumnName],
		[emlnRecordID],
		[emlsSubject],
		[emlsSentReceived],
		[emlsContents],
		[emlbAcknowledged],
		[emldDate],
		[emlsFromEmailID],
		[emlsOutLookUserEmailID],	-- To
		[emlnTemplateID],
		[emlnPriority],
		[emlnRecUserID],
		[emldDtCreated],
		[emlnModifyUserID],
		[emldDtModified],
		[emlnLevelNo],
		[emlnReviewerContactId],
		[emlnReviewDate],
		[emlnDocumentAnalysisResultId],
		[emlnIsReviewed],
		[emlnToContactID],
		[emlnToContactCtgID],
		[emlnDocPriority],
		[emlnDocumentID],
		[emlnDeleteFlag],
		[emlsCCAddresses],
		[emlsBCCAddresses],
		--[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		e.cas_casnCaseID	   as [emlncaseid],
		iu.SAusrnUserID		   as [emlnfrom],
		''					   as [emlstablename],
		''					   as [emlscolumnname],
		0					   as [emlnrecordid],
		LEFT(e.[subject], 200) as [emlssubject],	--nvarchar 400
		'S'					   as [emlssentreceived],
		CONVERT(TEXT, e.body)  as [emlscontents],
		null				   as [emlbacknowledged],
		case
			when ISDATE(e.written_date) = 1 and
				e.written_date between '1/1/1900' and '6/6/2079' then e.written_date
			else null
		end					   as [emlddate],
		iu.SAusrnUserID		   as [emlsfromemailid],	-- From Address (100)
		null				   as [emlsoutlookuseremailid],	-- To Address (4000)
		0					   as [emlntemplateid],
		0					   as [emlnpriority],
		iu.SAusrnUserID		   as [emlnrecuserid],
		case
			when ISDATE(e.written_date) = 1 and
				e.written_date between '1/1/1900' and '6/6/2079' then e.written_date
			else null
		end					   as [emlddtcreated],
		null				   as [emlnmodifyuserid],
		null				   as [emlddtmodified],
		null				   as [emlnlevelno],
		null				   as [emlnreviewercontactid],
		null				   as [emlnreviewdate],
		null				   as [emlndocumentanalysisresultid],
		null				   as [emlnisreviewed],
		null				   as [emlntocontactid],
		null				   as [emlntocontactctgid],
		3					   as [emlndocpriority],
		null				   as [emlndocumentid],
		null				   as [emlndeleteflag],
		null				   as [emlsccaddresses],
		null				   as [emlsbccaddresses],
		--null				   as [saga],
		e.email_id			   as [source_id],
		'highrise'			   as [source_db],
		'emails'			   as [source_ref]
	--select *
	from stg_Highrise_Emails e
	left join implementation_users iu
		on iu.Staff = e.author
			and iu.Syst = 'HR'
go

alter table sma_trn_emails enable trigger all
go