use SATenantConsolidated_Tabs3_and_MyCase
go

set quoted_identifier on
go

/* ------------------------------------------------------------------------------
Create Highrise case group
*/ ------------------------------------------------------------------------------
insert into [sma_MST_CaseGroup]
	(
		[cgpsCode],
		[cgpsDscrptn],
		[cgpnRecUserId],
		[cgpdDtCreated],
		[cgpnModifyUserID],
		[cgpdDtModified],
		[cgpnLevelNo],
		[IncidentTypeID],
		[LimitGroupStatuses]
	)
	select
		null	   as [cgpsCode],
		'Highrise' as [cgpsDscrptn],
		368		   as [cgpnRecUserId],
		GETDATE()  as [cgpdDtCreated],
		null	   as [cgpnModifyUserID],
		null	   as [cgpdDtModified],
		null	   as [cgpnLevelNo],
		(
			select
				IncidentTypeID
			from [sma_MST_IncidentTypes]
			where Description = 'General Negligence'
		)		   as [IncidentTypeID],
		null	   as [LimitGroupStatuses]
	where
		not exists (select 1 from [sma_MST_CaseGroup] cg where cg.cgpsDscrptn = 'Highrise');
go

/* ------------------------------------------------------------------------------
Create Highrise case type
*/ ------------------------------------------------------------------------------
insert into [sma_MST_CaseType]
	(
		[cstsCode],
		[cstsType],
		[cstsSubType],
		[cstnWorkflowTemplateID],
		[cstnExpectedResolutionDays],
		[cstnRecUserID],
		[cstdDtCreated],
		[cstnModifyUserID],
		[cstdDtModified],
		[cstnLevelNo],
		[cstbTimeTracking],
		[cstnGroupID],
		[cstnGovtMunType],
		[cstnIsMassTort],
		[cstnStatusID],
		[cstnStatusTypeID],
		[cstbActive],
		[cstbUseIncident1],
		[cstsIncidentLabel1],
		[VenderCaseType]
	)
	select
		null				as [cstsCode],
		'Highrise'			as [cstsType],
		null				as [cstsSubType],
		null				as [cstnWorkflowTemplateID],
		720					as [cstnExpectedResolutionDays],
		368					as [cstnRecUserID],
		GETDATE()			as [cstdDtCreated],
		368					as [cstnModifyUserID],
		GETDATE()			as [cstdDtModified],
		0					as [cstnLevelNo],
		null				as [cstbTimeTracking],
		(
			select
				cgpnCaseGroupID
			from sma_MST_CaseGroup
			where cgpsDscrptn = 'Highrise'
		)					as [cstnGroupID],
		null				as [cstnGovtMunType],
		null				as [cstnIsMassTort],
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)					as [cstnStatusID],
		(
			select
				stpnStatusTypeID
			from [sma_MST_CaseStatusType]
			where stpsStatusType = 'Status'
		)					as [cstnStatusTypeID],
		1					as [cstbActive],
		1					as [cstbUseIncident1],
		'Incident 1'		as [cstsIncidentLabel1],
		'Baldante_Highrise' as [VenderCaseType]
	where
		not exists (select 1 from [sma_MST_CaseType] CST where CST.cstsType = 'Highrise');
go

-- [sma_MST_CaseSubType]
insert into [sma_MST_CaseSubType]
	(
		[cstsCode],
		[cstnGroupID],
		[cstsDscrptn],
		[cstnRecUserId],
		[cstdDtCreated],
		[cstnModifyUserID],
		[cstdDtModified],
		[cstnLevelNo],
		[cstbDefualt],
		[saga],
		[cstnTypeCode]
	)
	select
		null		   as [cstscode],
		cstnCaseTypeID as [cstngroupid],
		'Unknown'	   as [cstsdscrptn],
		368			   as [cstnrecuserid],
		GETDATE()	   as [cstddtcreated],
		null		   as [cstnmodifyuserid],
		null		   as [cstddtmodified],
		null		   as [cstnlevelno],
		1			   as [cstbdefualt],
		null		   as [saga],
		(
			select
				stcnCodeId
			from [sma_MST_CaseSubTypeCode]
			where stcsDscrptn = 'Unknown'
		)			   as [cstntypecode]
	from [sma_MST_CaseType] cst
	where
		cst.cstsType = 'Highrise'
		and not exists (
			select
				1
			from [sma_MST_CaseSubType] st
			where st.cstnGroupID = (
					select
						ct.cstnCaseTypeID
					from sma_MST_CaseType ct
					where ct.cstsType = 'Highrise'
				)
				and st.cstsDscrptn = 'Unknown'
		);

--join [CaseTypeMap] map
--	on map.[SmartAdvocate Case Type] = cst.cststype
--left join [sma_MST_CaseSubType] sub
--	on sub.[cstngroupid] = cstnCaseTypeID
--		and sub.[cstsdscrptn] = [SmartAdvocate Case Sub Type]
--where
--	sub.cstnCaseSubTypeID is null
--	and
--	ISNULL([SmartAdvocate Case Sub Type], '') <> ''
go


/* ------------------------------------------------------------------------------
Create default SubRoleCodes
*/ ------------------------------------------------------------------------------
insert into [sma_mst_SubRoleCode]
	(
		srcsDscrptn,
		srcnRoleID
	)
	(
	-- Default Roles
	select
		'(P)-Default Role',
		4
	union all
	select
		'(D)-Default Role',
		5
	)

	except

	select
		srcsDscrptn,
		srcnRoleID
	from [sma_mst_SubRoleCode];
go


/* ------------------------------------------------------------------------------
Create Highrise SubRoles
*/ ------------------------------------------------------------------------------
insert into sma_MST_SubRole
	(
		sbrnRoleID,
		sbrsDscrptn,
		sbrnCaseTypeID,
		sbrnTypeCode
	)
	select
		src.srcnRoleID	  as sbrnRoleID,
		src.srcsDscrptn	  as sbrsDscrptn,
		ct.cstnCaseTypeID as sbrnCaseTypeID,
		src.srcnCodeID	  as sbrnTypeCode
	from sma_mst_SubRoleCode src
	cross join sma_MST_CaseType ct
	where
		ct.cstsType = 'Highrise'
		and src.srcsDscrptn in
		(
		'(P)-Default Role',
		'(D)-Default Role'
		)
		and not exists (
			select
				1
			from sma_MST_SubRole sr
			where sr.sbrnRoleID = src.srcnRoleID
				and sr.sbrnCaseTypeID = ct.cstnCaseTypeID
		);
go


/* ------------------------------------------------------------------------------
1. Create Case Staging Table
------------------------------------------------------------------------------ */
if OBJECT_ID('conversion.Highrise_Case_Staging', 'U') is not null
	drop table conversion.Highrise_Case_Staging;

create table conversion.Highrise_Case_Staging (
	StagingID		   INT identity (1, 1) primary key,
	source_table	   VARCHAR(20), -- 'contacts' or 'company'
	source_id		   INT,
	contact_name	   VARCHAR(255),
	company_name	   VARCHAR(255),
	tags			   VARCHAR(MAX),
	PrimaryTag		   VARCHAR(MAX),
	MappedStateID	   INT,
	MappedCaseTypeID   INT,
	IsDuplicateOfTabs3 BIT default 0
);
go

/* ------------------------------------------------------------------------------
2. Populate [Highrise_Case_Staging]
------------------------------------------------------------------------------ */
insert into conversion.Highrise_Case_Staging
	(
		source_table, source_id, contact_name, company_name, tags
	)
	select
		'contacts'	   as source_table,
		c.id		   as source_id,
		c.name		   as contact_name,
		c.company_name as company_name,
		c.tags		   as tags
	from Baldante_Highrise..contacts c
	left join sma_TRN_Cases cas on cas.cassCaseNumber = c.company_name
			and cas.source_db = 'Tabs3'
	where
		cas.casnCaseID is null

	union all

	select
		'company' as source_table,
		com.id	  as source_id,
		null	  as contact_name,
		com.Name  as company_name,
		null	  as tags
	from Baldante_Highrise..company com
	left join sma_TRN_Cases cas on cas.cassCaseNumber = com.Name
			and cas.source_db = 'Tabs3'
	where
		cas.casnCaseID is null;
go

select * from conversion.Highrise_Case_Staging

/* ------------------------------------------------------------------------------
3. State mapping using case tags
PrimaryTag is only populated if the tag is found in [HighriseTagStateMap]
------------------------------------------------------------------------------ */
update staging
set staging.PrimaryTag = ct.SingleTag,
	staging.MappedStateID = st.sttnStateID
from conversion.Highrise_Case_Staging staging
cross apply (
	-- 3a. use staging.source_id to find the top SingleTag from [baldante_highrise].[conversion].[ContactTags]
	select top 1
		tag.SingleTag,
		tag.ordinal
	from Baldante_Highrise.conversion.ContactTags tag
		join conversion.HighriseTagStateMap map
			on tag.SingleTag = map.TagName
	--where tag.id = staging.source_id
	where tag.name = staging.contact_name
	order by tag.ordinal asc
) ct
-- 3b. Lookup the SingleTag fetched in part 1 to get the mapped State
join conversion.HighriseTagStateMap map_final
	on ct.SingleTag = map_final.TagName
-- 3c. get the state ID
join sma_MST_States st
	on st.sttsCode = map_final.StateAbbreviation;
go

-- 3d. Default remaining NULLs to PA (2)
update conversion.Highrise_Case_Staging
set MappedStateID = 2
where MappedStateID is null;
go

select * from conversion.Highrise_Case_Staging


/* ------------------------------------------------------------------------------
4. Map Case Type (Priority 1: Sex Abuse Map)
use [HighRiseSexAbuseCaseMap]
------------------------------------------------------------------------------ */
update staging
set staging.MappedCaseTypeID = cst.cstnCaseTypeID
from conversion.Highrise_Case_Staging staging
-- 4a. use staging.primaryTag to access [HighRiseSexAbuseCaseMap]
-- select * from conversion.[HighRiseSexAbuseCaseMap]
join conversion.HighRiseSexAbuseCaseMap map
	on map.case_tag = staging.PrimaryTag
join sma_MST_States st
	on st.sttnStateID = staging.MappedStateID
join sma_MST_CaseType cst
	on cst.cstsType = map.SA_Case_Type
where staging.MappedCaseTypeID is null
and map.casestate = st.sttsCode
and ISNULL(staging.tags, '') like
case when ISNULL(map.Secondary_Tags, '') <> '' then '%' + map.Secondary_Tags + '%' else ISNULL(staging.tags, '') end
and ISNULL(map.AdditionalCondition, '') not like 'Plaintiff DOB%';	-- exclude this condition until next step
go

select * from conversion.Highrise_Case_Staging where MappedCaseTypeID is not null


/* ------------------------------------------------------------------------------
5. Map Case Type (Priority 1.5: DOB Age Window Mappings)
DISREGARD - no DOB for Highrise contacts
------------------------------------------------------------------------------ */

---- Update for "DOB is on or before 11/26/1989"
--update staging
--set staging.MappedCaseTypeID = cst.cstnCaseTypeID
--from conversion.Highrise_Case_Staging staging
--join sma_MST_IndvContacts indv
--	on indv.source_id = staging.source_id
--	and indv.source_db = 'highrise'
--join conversion.HighRiseSexAbuseCaseMap map
--	on map.case_tag = staging.PrimaryTag
--join sma_MST_CaseType cst
--	on cst.cstsType = map.SA_Case_Type
--where staging.MappedCaseTypeID is null
--and map.AdditionalCondition like '%DOB is on or before%'
--and indv.cindBirthDate <= '11/26/1989'
--and indv.cindBirthDate is not null; -- Ensure we have a date to compare
--go

---- Update for "DOB is after 11/26/1989"
--update staging
--set staging.MappedCaseTypeID = cst.cstnCaseTypeID
--from conversion.Highrise_Case_Staging staging
--join sma_MST_IndvContacts indv
--	on indv.source_id = staging.source_id
--	and indv.source_db = 'highrise'
--join conversion.HighRiseSexAbuseCaseMap map
--	on map.case_tag = staging.PrimaryTag
--join sma_MST_CaseType cst
--	on cst.cstsType = map.SA_Case_Type
--where staging.MappedCaseTypeID is null
--and map.AdditionalCondition like '%DOB is after%'
--and indv.cindBirthDate > '11/26/1989'
--and indv.cindBirthDate is not null;
--go


/* ------------------------------------------------------------------------------
6. Final Fallback: Default Highrise
------------------------------------------------------------------------------ */
update s
set s.MappedCaseTypeID = (
	select
		cstnCaseTypeID
	from sma_MST_CaseType
	where cstsType = 'Highrise'
)
from conversion.Highrise_Case_Staging s
where s.MappedCaseTypeID is null;
go

-- FINAL CHECK
select * from conversion.Highrise_Case_Staging where MappedCaseTypeID is null

select
	s.source_table,
	s.company_name																																		   as [Case Number/Name],
	s.contact_name																																		   as [Highrise Contact],
	s.tags																																				   as [Raw Tags (Source)],
	s.PrimaryTag																																		   as [Tag Used for Mapping],
	map.StateAbbreviation																																   as [Mapped Abbrev],
	st.sttsDescription																																	   as [SA State Name],
	s.MappedStateID																																		   as [SA State ID],
	case when s.PrimaryTag is null then 'Fallback (No valid Tag found)' when map.TagName is not null then 'Mapped via Dictionary' else 'Error/Unknown' end as [Mapping Logic Path]
from conversion.Highrise_Case_Staging s
left join conversion.HighriseTagStateMap map on s.PrimaryTag = map.TagName
left join sma_MST_States st on s.MappedStateID = st.sttnStateID
order by [Mapping Logic Path], [Mapped Abbrev];

/* ------------------------------------------------------------------------------
Insert [sma_TRN_Cases] that don't yet exist from [contacts]
- [contact].[company_name] has no match to [sma_TRN_Cases].[cassCaseNumber]
*/ ------------------------------------------------------------------------------
exec AddBreadcrumbsToTable 'sma_TRN_Cases'
alter table [sma_TRN_Cases] disable trigger all
go

insert into [sma_TRN_Cases]
	(
		[cassCaseNumber],
		[casbAppName],
		[casnCaseTypeID],
		[casnState],
		[casdStatusFromDt],
		[casnStatusValueID],
		[casdsubstatusfromdt],
		[casnSubStatusValueID],
		[casdOpeningDate],
		[casnCaptionID],
		[casbMainCase],
		[casbInHouse],
		[casnStateID],
		[casnRecUserID],
		[casdDtCreated],
		[casnModifyUserID],
		[casdDtModified],
		[casnOrgCaseTypeID],
		[office_id],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		LEFT(s.company_name, 50) as [cassCaseNumber],
		''						 as [casbAppName],
		null					 as [casnCaseTypeID], -- Often left null if casnOrgCaseTypeID is populated
		s.MappedStateID			 as [casnState],
		GETDATE()				 as [casdStatusFromDt],
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)						 as [casnStatusValueID],
		GETDATE()				 as [casdsubstatusfromdt],
		(
			select
				cssnStatusID
			from [sma_MST_CaseStatus]
			where csssDescription = 'Presign - Not Scheduled For Sign Up'
		)						 as [casnsubstatusvalueid],
		'01-01-1922'			 as [casdOpeningDate],
		0						 as [casnCaptionID],
		1						 as [casbMainCase],
		1						 as [casbInHouse],
		s.MappedStateID			 as [casnStateID],
		368						 as [casnRecUserID],
		GETDATE()				 as [casdDtCreated],
		368						 as [casnModifyUserID],
		GETDATE()				 as [casdDtModified],
		s.MappedCaseTypeID		 as [casnOrgCaseTypeID], -- The mapped Case Type
		(
			select
				office_id
			from sma_mst_offices
			where office_name = 'Main - PA'
		)						 as [office_id],
		s.source_id				 as [source_id],
		'highrise'				 as [source_db],
		s.source_table			 as [source_ref]
	from conversion.Highrise_Case_Staging s
	-- Final safety check to ensure we don't insert duplicates if the script is re-run
	where
		not exists (
			select
				1
			from sma_TRN_Cases cas
			where cas.source_id = s.source_id
				and cas.source_db = 'highrise'
		);
go


/* ------------------------------------------------------------------------------
Insert [sma_TRN_Incidents] using Mapped State from Staging
------------------------------------------------------------------------------ */
alter table [sma_TRN_Incidents] disable trigger all
go

insert into [sma_TRN_Incidents]
	(
		[CaseId],
		[IncidentDate],
		[StateID],
		[LiabilityCodeId],
		[IncidentFacts],
		[MergedFacts],
		[Comments],
		[IncidentTime],
		[RecUserID],
		[DtCreated],
		[ModifyUserId],
		[DtModified]
	)
	select
		cas.casnCaseID	  as [CaseId],
		GETDATE()		  as [IncidentDate],
		stg.MappedStateID as [StateID],
		0				  as [LiabilityCodeId],
		c.background	  as [IncidentFacts],
		''				  as [MergedFacts],
		null			  as [Comments],
		null			  as [IncidentTime],
		368				  as [RecUserID],
		GETDATE()		  as [DtCreated],
		null			  as [ModifyUserId],
		null			  as [DtModified]
	--select *
	from conversion.Highrise_Case_Staging stg
	join [sma_TRN_cases] cas on cas.source_id = stg.source_id
			and cas.source_db = 'highrise'
			and cas.source_ref = stg.source_table
	left join Baldante_Highrise..contacts c on stg.source_table = 'contacts'
			and c.id = stg.source_id
	--where c.background is not null
	-- Ensure we don't create duplicate incidents if re-run
	where
		not exists (select 1 from [sma_TRN_Incidents] i where i.CaseId = cas.casnCaseID)
		and c.background is not null;
go

alter table [sma_TRN_Incidents] enable trigger all
go

/* ------------------------------------------------------------------------------
Update case incident date and state (Final Sync)
------------------------------------------------------------------------------ */
alter table [sma_TRN_Cases] disable trigger all
go

update cas
set cas.casdIncidentDate = inc.IncidentDate,
	cas.casnStateID = inc.StateID,
	cas.casnState = inc.StateID
from sma_trn_cases as cas
join sma_TRN_Incidents as inc
	on cas.casnCaseID = inc.CaseId
where cas.source_db = 'highrise';
go

alter table [sma_TRN_Cases] enable trigger all
go


/* ------------------------------------------------------------------------------
Populate blank case numbers
*/ ------------------------------------------------------------------------------

select
	c.id,
	IDENTITY(int, 1, 1) as rowID
into #update_case_numbers
from Baldante_Highrise..contacts c
where
	ISNULL(c.company_name, '') = ''

--select * from #update_case_numbers

update cas
set cassCaseNumber = RIGHT('00000' + CAST(rowID as VARCHAR(5)), 5)
from sma_TRN_Cases cas
join #update_case_numbers tmp
	on tmp.id = cas.source_id
	and cas.source_db = 'highrise'


--;
--with
--	cte_CaseTypeMapping as (
--		select
--			ct.id		   as contact_id,
--			st.sttnStateID as mapped_state_id,
--			st.sttsDescription,
--			ct.tags		   as original_tags,		-- Included for debugging
--			ct.SingleTag   as matched_tag,			-- Included for debugging
--			COALESCE(
--				(select top 1 cst.cstnCaseTypeID
--				from conversion.HighRiseSexAbuseCaseMap map
--				join sma_MST_CaseType cst
--					on cst.cstsType = map.SA_Case_Type
--				where map.case_tag = ct.SingleTag
--					and map.casestate = map_state.StateAbbreviation
--					and ISNULL(ct.tags, '') like
--						case	
--							when ISNULL(map.Secondary_Tags, '') <> '' then '%' + map.Secondary_Tags + '%'
--							else ISNULL(ct.tags, '')
--						end
--				),
--				(select cstnCaseTypeID
--				from sma_MST_CaseType
--				where cstsType = 'Highrise')
--				)			   as final_case_type_id
--		from baldante_highrise.conversion.ContactTags ct
--			join conversion.HighriseTagStateMap map_state
--				on ct.SingleTag = map_state.TagName
--			join sma_MST_States st
--				on st.sttsCode = map_state.StateAbbreviation
--		where ct.ordinal = 1
--	)
--	select * from cte_CaseTypeMapping
--	,
--	cte_cases as (
--		select
--			c.id		   as source_id,
--			c.company_name as case_number,
--			'contacts'	   as ref,
--			m.mapped_state_id,
--			m.final_case_type_id,
--			m.original_tags,
--			m.matched_tag
--		from Baldante_Highrise..contacts c
--			left join cte_CaseTypeMapping m
--				on c.id = m.contact_id
--			left join sma_TRN_Cases cas
--				on cas.cassCaseNumber = c.company_name
--				and cas.source_db = 'Tabs3'
--		where cas.casnCaseID is null

--		union all

--		select
--			com.id	  as source_id,
--			com.Name  as case_number,
--			'company' as ref,
--			m.mapped_state_id,
--			m.final_case_type_id,
--			m.original_tags,
--			m.matched_tag
--		from Baldante_Highrise..company com
--			left join cte_CaseTypeMapping m
--				on com.id = m.contact_id
--			left join sma_TRN_Cases cas
--				on cas.cassCaseNumber = com.Name
--				and cas.source_db = 'Tabs3'
--		where cas.casnCaseID is null
--	)
---- DEBUG SELECT BLOCK
--select
--	c.*
----c.ref		   as source_table,
----c.source_id,
----c.case_number,
----c.original_tags,
----c.matched_tag  as primary_mapping_tag,
----st.sttsCode	   as MappedState,
----cty.cstsType   as MappedCaseType,
----cg.cgpsDscrptn as MappedCaseGroup
--from cte_cases c
--left join sma_MST_States st on st.sttnStateID = c.mapped_state_id
--left join sma_MST_CaseType cty on cty.cstnCaseTypeID = c.final_case_type_id
--left join sma_MST_CaseGroup cg on cg.cgpnCaseGroupID = cty.cstnGroupID
--where
--	c.original_tags is not null
--order by primary_mapping_tag;
--insert into [sma_TRN_Cases]
--	(
--		[cassCaseNumber],
--		[casbAppName],
--		[cassCaseName],
--		[casnCaseTypeID],
--		[casnState],
--		[casdStatusFromDt],
--		[casnStatusValueID],
--		[casdsubstatusfromdt],
--		[casnSubStatusValueID],
--		[casdOpeningDate],
--		[casdClosingDate],
--		[casnCaseValueID],
--		[casnCaseValueFrom],
--		[casnCaseValueTo],
--		[casnCurrentCourt],
--		[casnCurrentJudge],
--		[casnCurrentMagistrate],
--		[casnCaptionID],
--		[cassCaptionText],
--		[casbMainCase],
--		[casbCaseOut],
--		[casbSubOut],
--		[casbWCOut],
--		[casbPartialOut],
--		[casbPartialSubOut],
--		[casbPartiallySettled],
--		[casbInHouse],
--		[casbAutoTimer],
--		[casdExpResolutionDate],
--		[casdIncidentDate],
--		[casnTotalLiability],
--		[cassSharingCodeID],
--		[casnStateID],
--		[casnLastModifiedBy],
--		[casdLastModifiedDate],
--		[casnRecUserID],
--		[casdDtCreated],
--		[casnModifyUserID],
--		[casdDtModified],
--		[casnLevelNo],
--		[cassCaseValueComments],
--		[casbRefIn],
--		[casbDelete],
--		[casbIntaken],
--		[casnOrgCaseTypeID],
--		[CassCaption],
--		[cassMdl],
--		[office_id],
--		[LIP],
--		[casnSeriousInj],
--		[casnCorpDefn],
--		[casnWebImporter],
--		[casnRecoveryClient],
--		[cas],
--		[ngage],
--		[casnClientRecoveredDt],
--		[CloseReason],
--		[saga],
--		[source_id],
--		[source_db],
--		[source_ref]
--	)
--	select distinct
--		LEFT(c.case_number, 50)		 as casscasenumber,
--		''							 as casbappname,
--		null						 as casscasename,
--		null						 as casncasetypeid,
--		--(
--		-- select
--		--	 [sttnStateID]
--		-- from [sma_MST_States]
--		-- where [sttsDescription] = (select StateName from conversion.office)
--		--)			   as casnstate,
--		--2						as casnstate,
--		ISNULL(c.mapped_state_id, 2) as casnstate, -- Use mapped ID, fallback to PA (2)
--		GETDATE()					 as casdstatusfromdt,
--		(
--			select
--				cssnStatusID
--			from [sma_MST_CaseStatus]
--			where csssDescription = 'Presign - Not Scheduled For Sign Up'
--		)							 as casnstatusvalueid,
--		GETDATE()					 as casdsubstatusfromdt,
--		(
--			select
--				cssnStatusID
--			from [sma_MST_CaseStatus]
--			where csssDescription = 'Presign - Not Scheduled For Sign Up'
--		)							 as casnsubstatusvalueid,
--		'01-01-1922'				 as casdopeningdate,
--		null						 as casdclosingdate,
--		null						 as [casncasevalueid],
--		null						 as [casncasevaluefrom],
--		null						 as [casncasevalueto],
--		null						 as [casncurrentcourt],
--		null						 as [casncurrentjudge],
--		null						 as [casncurrentmagistrate],
--		0							 as [casncaptionid],
--		null						 as casscaptiontext,
--		1							 as [casbmaincase],
--		0							 as [casbcaseout],
--		0							 as [casbsubout],
--		0							 as [casbwcout],
--		0							 as [casbpartialout],
--		0							 as [casbpartialsubout],
--		0							 as [casbpartiallysettled],
--		1							 as [casbinhouse],
--		null						 as [casbautotimer],
--		null						 as [casdexpresolutiondate],
--		null						 as [casdincidentdate],
--		0							 as [casntotalliability],
--		0							 as [casssharingcodeid],
--		--(
--		-- select
--		--	 [sttnStateID]
--		-- from [sma_MST_States]
--		-- where [sttsDescription] = (select StateName from conversion.office)
--		--)			   as [casnstateid],
--		--2						as [casnstateid],
--		ISNULL(c.mapped_state_id, 2) as [casnstateid],
--		null						 as [casnlastmodifiedby],
--		null						 as [casdlastmodifieddate],
--		368							 as [casnrecuserid],
--		GETDATE()					 as casddtcreated,
--		null						 as casnmodifyuserid,
--		null						 as casddtmodified,
--		''							 as casnlevelno,
--		''							 as casscasevaluecomments,
--		null						 as casbrefin,
--		null						 as casbdelete,
--		null						 as casbintaken,
--		(
--			select
--				smct.cstnCaseTypeID
--			from sma_MST_CaseType smct
--			where smct.cstsType = 'Highrise'
--		)							 as casnorgcasetypeid,
--		''							 as casscaption,
--		0							 as cassmdl,
--		(
--			select
--				office_id
--			from sma_mst_offices
--			where office_name = 'Main - PA'
--		)							 as office_id,
--		--4						as office_id,
--		null						 as [lip],
--		null						 as [casnseriousinj],
--		null						 as [casncorpdefn],
--		null						 as [casnwebimporter],
--		null						 as [casnrecoveryclient],
--		null						 as [cas],
--		null						 as [ngage],
--		null						 as [casnclientrecovereddt],
--		null						 as closereason,
--		null						 as [saga],
--		c.id						 as [source_id],
--		'highrise'					 as [source_db],
--		c.ref						 as [source_ref]	-- 'contacts' or 'company'
--	--select distinct *
--	from cte_cases c


--from Baldante_Highrise..contacts c
--left join sma_TRN_Cases cas
--	on cas.cassCaseNumber = c.company_name
--where
--	cas.casnCaseID is null


/* ------------------------------------------------------------------------------
Insert [sma_TRN_Cases] that don't yet exist from [company]
- [company].[name] has no match to [sma_TRN_Cases].[cassCaseNumber]
*/ ------------------------------------------------------------------------------
--alter table [sma_TRN_Cases] disable trigger all
--go

--insert into [sma_TRN_Cases]
--	(
--		[cassCaseNumber],
--		[casbAppName],
--		[cassCaseName],
--		[casnCaseTypeID],
--		[casnState],
--		[casdStatusFromDt],
--		[casnStatusValueID],
--		[casdsubstatusfromdt],
--		[casnSubStatusValueID],
--		[casdOpeningDate],
--		[casdClosingDate],
--		[casnCaseValueID],
--		[casnCaseValueFrom],
--		[casnCaseValueTo],
--		[casnCurrentCourt],
--		[casnCurrentJudge],
--		[casnCurrentMagistrate],
--		[casnCaptionID],
--		[cassCaptionText],
--		[casbMainCase],
--		[casbCaseOut],
--		[casbSubOut],
--		[casbWCOut],
--		[casbPartialOut],
--		[casbPartialSubOut],
--		[casbPartiallySettled],
--		[casbInHouse],
--		[casbAutoTimer],
--		[casdExpResolutionDate],
--		[casdIncidentDate],
--		[casnTotalLiability],
--		[cassSharingCodeID],
--		[casnStateID],
--		[casnLastModifiedBy],
--		[casdLastModifiedDate],
--		[casnRecUserID],
--		[casdDtCreated],
--		[casnModifyUserID],
--		[casdDtModified],
--		[casnLevelNo],
--		[cassCaseValueComments],
--		[casbRefIn],
--		[casbDelete],
--		[casbIntaken],
--		[casnOrgCaseTypeID],
--		[CassCaption],
--		[cassMdl],
--		[office_id],
--		[LIP],
--		[casnSeriousInj],
--		[casnCorpDefn],
--		[casnWebImporter],
--		[casnRecoveryClient],
--		[cas],
--		[ngage],
--		[casnClientRecoveredDt],
--		[CloseReason],
--		[saga],
--		[source_id],
--		[source_db],
--		[source_ref]
--	)
--	select
--		com.name	 as casscasenumber,
--		''			 as casbappname,
--		com.Name	 as casscasename,
--		null		 as casncasetypeid,
--		--(
--		-- select
--		--	 [sttnStateID]
--		-- from [sma_MST_States]
--		-- where [sttsDescription] = (select StateName from conversion.office)
--		--)			   as casnstate,
--		null		 as casnstate,
--		GETDATE()	 as casdstatusfromdt,
--		(
--		 select
--			 cssnStatusID
--		 from [sma_MST_CaseStatus]
--		 where csssDescription = 'Presign - Not Scheduled For Sign Up'
--		)			 as casnstatusvalueid,
--		GETDATE()	 as casdsubstatusfromdt,
--		(
--		 select
--			 cssnStatusID
--		 from [sma_MST_CaseStatus]
--		 where csssDescription = 'Presign - Not Scheduled For Sign Up'
--		)			 as casnsubstatusvalueid,
--		'01-01-1922' as casdopeningdate,
--		null		 as casdclosingdate,
--		null		 as [casncasevalueid],
--		null		 as [casncasevaluefrom],
--		null		 as [casncasevalueto],
--		null		 as [casncurrentcourt],
--		null		 as [casncurrentjudge],
--		null		 as [casncurrentmagistrate],
--		0			 as [casncaptionid],
--		null		 as casscaptiontext,
--		1			 as [casbmaincase],
--		0			 as [casbcaseout],
--		0			 as [casbsubout],
--		0			 as [casbwcout],
--		0			 as [casbpartialout],
--		0			 as [casbpartialsubout],
--		0			 as [casbpartiallysettled],
--		1			 as [casbinhouse],
--		null		 as [casbautotimer],
--		null		 as [casdexpresolutiondate],
--		null		 as [casdincidentdate],
--		0			 as [casntotalliability],
--		0			 as [casssharingcodeid],
--		--(
--		-- select
--		--	 [sttnStateID]
--		-- from [sma_MST_States]
--		-- where [sttsDescription] = (select StateName from conversion.office)
--		--)			   as [casnstateid],
--		2			 as [casnstateid],
--		null		 as [casnlastmodifiedby],
--		null		 as [casdlastmodifieddate],
--		368			 as [casnrecuserid],
--		GETDATE()	 as casddtcreated,
--		null		 as casnmodifyuserid,
--		null		 as casddtmodified,
--		''			 as casnlevelno,
--		''			 as casscasevaluecomments,
--		null		 as casbrefin,
--		null		 as casbdelete,
--		null		 as casbintaken,
--		(
--		 select
--			 smct.cstnCaseTypeID
--		 from sma_MST_CaseType smct
--		 where smct.cstsType = 'Highrise'
--		)			 as casnorgcasetypeid,
--		''			 as casscaption,
--		0			 as cassmdl,
--		--(
--		-- select
--		--	 office_id
--		-- from sma_MST_Offices	
--		-- where office_name = (select OfficeName from conversion.office)
--		--)			   as office_id,
--		4			 as office_id,
--		null		 as [lip],
--		null		 as [casnseriousinj],
--		null		 as [casncorpdefn],
--		null		 as [casnwebimporter],
--		null		 as [casnrecoveryclient],
--		null		 as [cas],
--		null		 as [ngage],
--		null		 as [casnclientrecovereddt],
--		null		 as closereason,
--		null		 as [saga],
--		com.id		 as [source_id],
--		'highrise'	 as [source_db],
--		'company'	 as [source_ref]
--	--select *
--	from Baldante_Highrise..company com
--	left join sma_TRN_Cases cas
--		on cas.cassCaseNumber = com.name
--	where
--		cas.casnCaseID is null
--go

--alter table [sma_TRN_Cases] enable trigger all
--go