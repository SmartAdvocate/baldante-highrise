SELECT * FROM Baldante_SATenantConsolidated_20251027..implementation_users

SELECT * FROM Baldante_Consolidated..implementation_users iu

SELECT * FROM Baldante_Consolidated..IndvOrgContacts_Indexed ioci

SELECT * FROM Baldante_Consolidated..sma_TRN_Cases stc
SELECT * FROM Baldante_Highrise..emails e

delete from Baldante_Consolidated..sma_TRN_Incidents


SELECT * FROM Baldante_Highrise..notes



SELECT * FROM Baldante_Consolidated..sma_TRN_Cases stc where stc.source_db = 'highrise'
--delete FROM Baldante_Consolidated..sma_TRN_Cases where source_db = 'highrise'

-- how many contacts have emails?
select count(*) FROM Baldante_Highrise..contacts c
join Baldante_Highrise..emails e on e.contact_id = c.id
-- 1769

-- out of those, how many have SA cases?
select count(*) FROM Baldante_Highrise..contacts c
join Baldante_Highrise..emails e on e.contact_id = c.id
join Baldante_Consolidated..sma_TRN_Cases cas on cas.source_id = c.id and cas.source_db = 'highrise'
-- 749

-- how many emails are linked to companies?
select count(*) FROM Baldante_Highrise..company com
join Baldante_Highrise..emails e on e.company_id = com.id
join Baldante_Consolidated..sma_TRN_Cases cas on cas.source_id = com.name and cas.source_db = 'highrise'
-- 749


SELECT * FROM Baldante_Highrise..emails e where e.company_id is not null



-- emails come from the company file, but can also come from contacts sometimes
SELECT * FROM Baldante_Highrise..notes

SELECT * FROM Baldante_Highrise..emails where company_id = 341408048
SELECT * FROM Baldante_Highrise..emails 

SELECT * FROM Baldante_Highrise..emails where contact_id = 342986010
SELECT * FROM Baldante_Highrise..contacts where id = 342986010
SELECT * FROM Baldante_Highrise..company c where id = 343620943

SELECT * FROM Baldante_Highrise..company c where id = 341408048
SELECT * FROM Baldante_Highrise..contacts c where c.company_id = 341408048

SELECT * FROM Baldante_Consolidated..sma_TRN_Plaintiff stp where stp.plnnCaseID=43128


SELECT * FROM Baldante_Consolidated..sma_MST_CaseType smct
SELECT * FROM Baldante_Consolidated..sma_MST_CaseSubType smcst
SELECT * FROM Baldante_Consolidated..sma_MST_CaseSubTypeCode smcstc

SELECT * FROM Baldante_Consolidated..sma_MST_SubRole smsr
SELECT * FROM Baldante_Consolidated..sma_mst_SubRoleCode smsrc --order by smsrc.srcsDscrptn



/*----------------------------------------------------------
2026.01.13

*/

SELECT * FROM CaseTypeMap ctm order by ctm.SA_Case_Group desc

-- groups
SELECT distinct ctm.SA_Case_Group FROM CaseTypeMap ctm order by ctm.SA_Case_Group desc
SELECT * FROM SATenantConsolidated_Tabs3_and_MyCase..sma_MST_CaseGroup smcg

select distinct map.SA_Case_Group, cg.cgpnCaseGroupID, cg.cgpsCode, cg.cgpsDscrptn FROM SATenantConsolidated_Tabs3_and_MyCase..sma_MST_CaseGroup cg
join CaseTypeMap map on map.SA_Case_Group = cg.cgpsDscrptn

-- types
SELECT distinct ctm.SA_Case_Type FROM CaseTypeMap ctm order by ctm.SA_Case_Type desc
SELECT * FROM SATenantConsolidated_Tabs3_and_MyCase..sma_MST_CaseType smct

SELECT * FROM Baldante_Highrise..contacts c



/* ------------------------------------------------------------------------------
2026.01.19
*/ ------------------------------------------------------------------------------
SELECT * FROM [sma_MST_ContactNumbers] where cnnnContactID = 12663

SELECT * FROM [sma_MST_ContactNumbers] where cnnnContactID = 2619

SELECT * FROM Baldante_Highrise..phone p join Baldante_Highrise..contacts c on c.id = p.contact_id where c.name like '%dixon%'

SELECT * 
FROM Baldante_Highrise..emails e where contact_id = 343188676

SELECT * 
FROM Baldante_Highrise..emails e where company_id = 344778563

SELECT * 
FROM Baldante_Highrise..tasks t where t.contact_id=343509826


join Baldante_Highrise..contacts c on c.id = e.contact_id
where c.name like '%dixon%'

SELECT * FROM [sma_TRN_TaskNew] where tskcaseid=56170

SELECT * FROM sma_trn_cases where casncaseid=32818
where source_id='343509826'


SELECT * FROM Baldante_Highrise..contacts c where c.background is not null