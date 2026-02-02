/* ------------------------------------------------------------------------------
1. Create Case Staging Table
------------------------------------------------------------------------------ */
if OBJECT_ID('conversion.Highrise_Case_Staging', 'U') is not null
	drop table conversion.Highrise_Case_Staging;

create table conversion.Highrise_Case_Staging (
	StagingID		   INT identity (1, 1) primary key,
	source_table	   VARCHAR(20),
	source_id		   INT,
	contact_name	   VARCHAR(255),
	company_name	   VARCHAR(255),
	tags			   VARCHAR(MAX),
	SingleTag	   VARCHAR(MAX),
	MappedStateID	   INT,
	MappedCaseTypeID   INT,
	MappedCaseType varchar(255)
);
go

/* ------------------------------------------------------------------------------
2. Populate [Highrise_Case_Staging]
------------------------------------------------------------------------------ */
insert into conversion.Highrise_Case_Staging
	(
		source_table, source_id, contact_name, company_name, tags, SingleTag
	)
	select
		'contacts'	   as source_table,
		c.id		   as source_id,
		c.name		   as contact_name,
		c.company_name as company_name,
		c.tags		   as tags,
		map.singletag
	from Baldante_Highrise_20260128..contacts c
	LEFT join baldante_sa.conversion.HighRiseContactTagsFromMap map
		on map.id = c.id
		and map.TagNum = 1
	left join sma_TRN_Cases cas on cas.cassCaseNumber = c.company_name
			and cas.source_db = 'Tabs3'
	where
		cas.casnCaseID is null

	union

	select
		'company' as source_table,
		com.id	  as source_id,
		null	  as contact_name,
		com.Name  as company_name,
		null		   as tags,
		map.singletag
	from Baldante_Highrise_20260128..company com
	LEFT join baldante_sa.conversion.HighRiseContactTagsFromMap map
		on map.id = com.id
		and map.TagNum = 1
	left join sma_TRN_Cases cas on cas.cassCaseNumber = com.Name
			and cas.source_db = 'Tabs3'
	where
		cas.casnCaseID is null;
go

select * from conversion.Highrise_Case_Staging 
where source_id in (334332806,
335623813,
346338805)


--select * from conversion.Highrise_Case_Staging stg
--join baldante_sa.conversion.HighRiseContactTagsFromMap map on map.ID = stg.source_id
--where  stg.source_id in (334332806,
--335623813,
--346338805)

--select * from conversion.Highrise_Case_Staging stg
--join baldante_sa.conversion.HighriseTagStateMap map2 on map2.tagname = stg.source_id
--where  stg.source_id in (334332806,
--335623813,
--346338805)

/* ------------------------------------------------------------------------------
state mapping - [HighriseTagStateMap]
*/ ------------------------------------------------------------------------------
--select * from baldante_sa.conversion.HighriseTagStateMap

update staging
set staging.MappedStateID = st.sttnStateID
from conversion.Highrise_Case_Staging staging
join baldante_sa.conversion.HighriseTagStateMap state_map on state_map.TagName = staging.SingleTag
LEFT join sma_MST_States st
	on st.sttsCode = state_map.StateAbbreviation;

-- remaining records default to PA (state id = 2)
update conversion.Highrise_Case_Staging
set MappedStateID = 2
where MappedStateID is null;
go

select * from conversion.Highrise_Case_Staging 
where source_id in (334332806,
335623813,
346338805)

/* ------------------------------------------------------------------------------
case type mapping - [HighRiseSexAbuseCaseMap]
*/ ------------------------------------------------------------------------------
--select * from baldante_sa.conversion.HighRiseSexAbuseCaseMap 

-- First, handle mappings that REQUIRE a Secondary Tag (The "Minor" rows)
update staging
set staging.MappedCaseTypeID = cst.cstnCaseTypeID,
 staging.MappedCaseType = cst.cstsType
from conversion.Highrise_Case_Staging staging
-- 4a. use staging.primaryTag to access [HighRiseSexAbuseCaseMap]
-- select * from conversion.[HighRiseSexAbuseCaseMap]
join baldante_sa.conversion.HighRiseSexAbuseCaseMap map
	on map.case_tag = staging.SingleTag
join sma_MST_States st
	on st.sttnStateID = staging.MappedStateID
join sma_MST_CaseType cst
	on cst.cstsType = map.SA_Case_Type
where staging.MappedCaseTypeID is null
-- Logic: The full tags string contains the Secondary Tag
and staging.tags LIKE '%' + map.Secondary_Tags + '%' 
and map.Secondary_Tags IS NOT NULL;
--and map.SA_Case_Type not like '%minor%'


-- Second, handle mappings where NO minor tag should be present (The "Adult" rows)
update staging
set 
    staging.MappedCaseTypeID = cst.cstnCaseTypeID,
    staging.MappedCaseType = cst.cstsType
from conversion.Highrise_Case_Staging staging
join baldante_sa.conversion.HighRiseSexAbuseCaseMap map
	on map.case_tag = staging.SingleTag
join sma_MST_CaseType cst
	on cst.cstsType = map.SA_Case_Type
where staging.MappedCaseTypeID is null
and map.Secondary_Tags IS NULL




/* ------------------------------------------------------------------------------
Fill in any blank case types with the 'Highrise' case type
------------------------------------------------------------------------------ */
update staging
set staging.MappedCaseTypeID = (
	select
		cstnCaseTypeID
	from sma_MST_CaseType
	where cstsType = 'Highrise'
), staging.MappedCaseType = (select
		ct.cstsType
	from sma_MST_CaseType ct
	where cstsType = 'Highrise')
from conversion.Highrise_Case_Staging staging
where staging.MappedCaseTypeID is null;
go


/* ------------------------------------------------------------------------------
now, fix the case types
*/ ------------------------------------------------------------------------------
select * from conversion.Highrise_Case_Staging staging

-- which cases are wrong?
select
	cas.casnCaseID,
	cas.cassCaseNumber,
	cas.casnOrgCaseTypeID,
	ct.cstsType,
	stg.*
from sma_TRN_Cases cas
join sma_MST_CaseType ct
	on ct.cstnCaseTypeID = cas.casnOrgCaseTypeID
join conversion.Highrise_Case_Staging stg on cas.source_id = stg.source_id
		and cas.source_ref = stg.source_table
where
	cas.casnOrgCaseTypeID <> stg.MappedCaseTypeID
order by cas.casnCaseID


-- backup the cases
select cas.*
into baldante_sa.conversion.fix_case_types
from sma_TRN_Cases cas
join conversion.Highrise_Case_Staging stg on cas.source_id = stg.source_id
		and cas.source_ref = stg.source_table
where
	cas.casnOrgCaseTypeID <> stg.MappedCaseTypeID
order by cas.casnCaseID 

-- verify
select
	cas.casnCaseID,
	cas.cassCaseNumber,
	STRING_AGG(mtags.Name, ', ') WITHIN GROUP (ORDER BY mtags.Name ASC) as CombinedTags,
	cas.casnOrgCaseTypeID,
	ct.cstsType,
	staging.MappedCaseTypeID,
	staging.MappedCaseType
from sma_TRN_Cases cas
join sma_MST_CaseType ct on ct.cstnCaseTypeID = cas.casnOrgCaseTypeID
join sma_TRN_CaseTags tags on tags.CaseID = cas.casnCaseID
join sma_MST_CaseTags mtags on mtags.TagID=tags.TagID
join baldante_sa.conversion.fix_case_types fix on fix.casnCaseID = cas.casnCaseID
join baldante_sa.conversion.Highrise_Case_Staging staging on staging.source_id = cas.source_id
		and staging.source_table = cas.source_ref
group by 
    cas.casnCaseID,
    cas.cassCaseNumber,
    cas.casnOrgCaseTypeID,
    ct.cstsType,
    staging.MappedCaseTypeID,
    staging.MappedCaseType
order by cas.casnCaseID



UPDATE cas
	set casnOrgCaseTypeID = staging.MappedCaseTypeID
from sma_TRN_Cases cas
join baldante_sa.conversion.fix_case_types fix on fix.casnCaseID = cas.casnCaseID
join baldante_sa.conversion.Highrise_Case_Staging staging on staging.source_id = cas.source_id
		and staging.source_table = cas.source_ref





/* ------------------------------------------------------------------------------
Update Plaintiff Roles
*/ ------------------------------------------------------------------------------

select ct.cstsType, sr.*
FROM sma_MST_SubRole sr
join sma_MST_CaseType ct on sr.sbrnCaseTypeID=ct.cstnCaseTypeID
where ct.cstnCaseTypeID=2612



update pln 
SET plnnRole = s.sbrnSubRoleId
--select
--	pln.plnnPlaintiffID,
--	pln.plnnCaseID,
--	pln.plnnRole as existing_role,
--	cas.casnOrgCaseTypeID,
--	s.sbrnSubRoleId as new_role,
--	s.sbrsCode,
--	s.sbrsDscrptn,
--	s.sbrnRoleID
from sma_TRN_Plaintiff pln
join Baldante_SA..sma_TRN_Cases cas on pln.plnnCaseID = cas.casnCaseID
join baldante_sa.conversion.fix_case_types fix on fix.casnCaseID = cas.casnCaseID
join [sma_MST_SubRole] s on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
		and s.sbrnRoleID = 4
		and s.sbrsDscrptn = '(P)-Plaintiff'



/* ------------------------------------------------------------------------------
Update Defendant Roles
*/ ------------------------------------------------------------------------------
update def
set defnSubRole = s.sbrnSubRoleId
--select
--	def.defnDefendentID,
--	def.defnCaseID,
--	def.defnSubRole as existing_role,
--	cas.casnOrgCaseTypeID,
--	s.sbrnSubRoleId as new_role,
--	s.sbrsCode,
--	s.sbrsDscrptn,
--	s.sbrnRoleID
from sma_TRN_Defendants def
join Baldante_SA..sma_TRN_Cases cas on def.defnCaseID = cas.casnCaseID
join baldante_sa.conversion.fix_case_types fix on fix.casnCaseID = cas.casnCaseID
join [sma_MST_SubRole] s on cas.casnOrgCaseTypeID = s.sbrnCaseTypeID
		and s.sbrnRoleID = 5
		and s.sbrsDscrptn = '(D)-Defendant'



/* ------------------------------------------------------------------------------
from joel bieber
*/ ------------------------------------------------------------------------------

--use JoelBieberSA_Needles
--go

--SELECT * FROM JoelBieberNeedles..matter m


--SELECT * FROM JoelBieberNeedles..cases c where c.matcode = 'SAS'
--SELECT cas.casnCaseID, cas.cassCaseNumber, cas.casnOrgCaseTypeID FROM sma_TRN_Cases cas where cas.cassCaseNumber in (226176,
--226177,
--226199,
--226200,
--226223)
--SELECT * FROM sma_MST_CaseType smct where smct.cstnCaseTypeID = 1590


--join caseTypeMixture mix
--		on mix.matcode = 'SAS'








--SELECT distinct cststype, cstnCaseTypeID, ct.*
--FROM sma_mst_casetype ct
--JOIN sma_trn_Cases cas on cas.casnOrgCaseTypeID = ct.cstnCaseTypeID
--where cststype IN ('Auto Accident TT','Auto Accidents TT','Auto Accident SE','Auto Accidents SE')


----keep Auto Accident TT	1536  remove Auto Accidents TT	1633
----keep Auto Accident SE	1579  remove Auto Accidents SE	1632

----drop TABLE #casetypeMap
--SELECT DISTINCT ct.cstnCaseTypeID, cststype, smcst.cstnCaseSubTypeID, smcst.cstsDscrptn, NULL AS NewCaseTypeID, NULL AS NewSubTypeID
--INTO #casetypeMap
--FROM sma_mst_casetype ct
--JOIN sma_trn_Cases cas on cas.casnOrgCaseTypeID = ct.cstnCaseTypeID
--LEFT JOIN sma_MST_CaseSubType smcst on smcst.cstnCaseSubTypeID = cas.casnCaseTypeID
--where cststype IN ('Auto Accidents TT','Auto Accidents SE')


----UPDATE NEW CASETYPE/SUBTYPE VALUES
--UPDATE #casetypeMap
--SET NewCaseTypeID = ct.cstnCaseTypeID,
--	NewSubTypeID = smcst.cstnCaseSubTypeID
----select m.*, ct.cstsType, ct.cstnCaseTypeID, smcst.cstsDscrptn, smcst.cstnCaseSubTypeID
--FROM #casetypeMap m
--JOIN sma_mst_casetype ct ON ct.cstsType = case WHEN m.cststype = 'Auto Accidents TT' then 'Auto Accident TT' 
--												WHEN m.cststype = 'Auto Accidents SE' then 'Auto Accident SE' END
--LEFT JOIN [sma_MST_CaseSubTypeCode] cod on cod.stcsDscrptn = m.cstsDscrptn
--LEFT JOIN sma_MST_CaseSubType smcst ON smcst.cstnGroupID = ct.cstnCaseTypeID AND smcst.cstnTypeCode = cod.stcnCodeId


----INSERT SUBTYPES IF THEY DO NOT EXIST
--INSERT INTO [dbo].[sma_MST_CaseSubTypeCode] ( stcsDscrptn )
--SELECT DISTINCT cstsDscrptn from #casetypeMap 
--    EXCEPT
--SELECT stcsDscrptn from [dbo].[sma_MST_CaseSubTypeCode]
--GO

--INSERT INTO [sma_MST_CaseSubType] ( [cstsCode], [cstnGroupID], [cstsDscrptn], [cstnRecUserId], [cstdDtCreated], [cstnModifyUserID], 
--      [cstdDtModified], [cstnLevelNo], [cstbDefualt], [saga], [cstnTypeCode] )
--SELECT  
--		null				as [cstsCode],
--		NewCaseTypeID		as [cstnGroupID],
--		ct.cstsDscrptn        as [cstsDscrptn], 
--		368 				as [cstnRecUserId],
--		getdate()			as [cstdDtCreated],
--		null				as [cstnModifyUserID],
--		null				as [cstdDtModified],
--		null				as [cstnLevelNo],
--		1					as [cstbDefualt],
--		null				as [saga],
--		(select stcnCodeId from [sma_MST_CaseSubTypeCode] where stcsDscrptn=ct.cstsDscrptn) as [cstnTypeCode] 
--from #casetypeMap ct
--LEFT JOIN [sma_MST_CaseSubTypeCode] cod on cod.stcsDscrptn = ct.cstsDscrptn
--LEFT JOIN [sma_MST_CaseSubType] sub on sub.[cstnGroupID] =ct.NewCaseTypeID and sub.cstnTypeCode = cod.stcnCodeId
--WHERE sub.cstnCaseSubTypeID IS NULL


--select * from #casetypeMap ct

----------------------------------------------------------------
----plaintiff and defendant roles
----------------------------------------------------------------
--INSERT INTO sma_MST_SubRole ( sbrnRoleID,sbrsDscrptn,sbrnCaseTypeID,sbrnTypeCode)
--SELECT T.sbrnRoleID,T.sbrsDscrptn, 1536, T.sbrnTypeCode
--FROM sma_MST_SubRole t
--WHERE sbrnCaseTypeID=1633
--EXCEPT SELECT sbrnRoleID,sbrsDscrptn,sbrnCaseTypeID,sbrnTypeCode FROM sma_MST_SubRole

--SELECT T.sbrnRoleID,T.sbrsDscrptn, 1579, T.sbrnTypeCode
--FROM sma_MST_SubRole t
--WHERE sbrnCaseTypeID=1632
--EXCEPT SELECT sbrnRoleID,sbrsDscrptn,sbrnCaseTypeID,sbrnTypeCode FROM sma_MST_SubRole



--SELECT map.*, cas.casnCaseID, cas.casnOrgCaseTypeID CaseType, CAS.casnCaseTypeID caseSubType
--INTO #cases
--from #casetypeMap map
--JOIN sma_trn_Cases cas on cas.casnOrgCaseTypeID = map.cstnCaseTypeID and isnull(cas.casnCaseTypeID,'') = isnull(map.cstnCaseSubTypeID,'')



--select p.plnnPlaintiffID, cas.casncaseid, p.plnnrole, sr.sbrsDscrptn, srnew.sbrnSubRoleId as NEWSubRoleID, srnew.sbrsDscrptn as NEWSubRoleDescr
--INTO #PLAINTIFF
--from #cases cas
--JOIN sma_TRN_Plaintiff p on p.plnnCaseID = cas.casnCaseID
--JOIN sma_MST_SubRole sr on p.plnnRole = sr.sbrnSubRoleId
--LEFT JOIN sma_MST_SubRole srNEW on srnew.sbrsDscrptn = sr.sbrsDscrptn and srnew.sbrnCaseTypeID = cas.newCaseTypeID

--select d.defnDefendentID, cas.casncaseid, d.defnSubRole, sr.sbrsDscrptn, srnew.sbrnSubRoleId as NEWSubRoleID, srnew.sbrsDscrptn as NEWSubRoleDescr
--INTO #DEFENDANT
--from #CASES cas
--JOIN sma_TRN_Defendants d on d.defnCaseID = cas.casnCaseID
--JOIN sma_MST_SubRole sr on d.defnSubRole = sr.sbrnSubRoleId
--LEFT JOIN sma_MST_SubRole srNEW on srnew.sbrsDscrptn = sr.sbrsDscrptn and srnew.sbrnCaseTypeID = cas.newCaseTypeID

--select * FROM #cases
--select * from #PLAINTIFF p
--select * FROM #DEFENDANT d


--update sma_TRN_Defendants
--SET defnSubRole = NEWSubRoleID
--FROM #DEFENDANT d
--JOIN sma_trn_Defendants def on d.defnDefendentID =def.defnDefendentID

--update sma_TRN_Plaintiff
--SET plnnRole = NEWSubRoleID
----select pl.*
--FROM #PLAINTIFF p
--JOIN sma_TRN_Plaintiff pl on pl.plnnPlaintiffID = p.plnnPlaintiffID


--alter table sma_trn_Cases disable trigger all
--GO
--update sma_trn_Cases 
--SET casnOrgCaseTypeID = newCaseTypeID,
--	casnCaseTypeID = NewSubTypeID
----select * 
--FROM #Cases c
--JOIN sma_trn_cases cas on c.casnCaseID = cas.casnCaseID

--alter table sma_trn_Cases enable trigger all
--GO




----keep Auto Accident TT	1536  remove Auto Accidents TT	1633
----keep Auto Accident SE	1579  remove Auto Accidents SE	1632


--delete from sma_MST_CaseType WHERE cstnCaseTypeID in (1632, 1633)



--delete
--from sma_MST_CaseSubType  
--WHERE cstnGroupID NOT IN (SELECT cstnCaseTypeID FROM sma_MST_CaseType)

--alter TABLE sma_MST_SubRole disable trigger all
--go
--delete from sma_MST_SubRole 
--WHERE sbrnCaseTypeID IN (1632, 1633)
--go
--ALTER TABLE sma_MST_SubRole enable trigger all
--go
