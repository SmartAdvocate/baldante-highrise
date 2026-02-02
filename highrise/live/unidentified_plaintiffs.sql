select
	stc.casnCaseID,
	stc.cassCaseNumber,
	stc.casnOrgCaseTypeID,
	stc.source_id,
	stc.source_db,
	stc.source_ref
from Baldante_SA..sma_TRN_Cases stc
where
	stc.casnCaseID in (30871,
	31786,
	34779)

SELECT * FROM Baldante_SA..sma_TRN_Plaintiff stp where stp.plnnCaseID=30871
SELECT * FROM Baldante_SA..IndvOrgContacts_Indexed ioci where ioci.CID=68


SELECT * FROM Baldante_Highrise_20260127..contacts c where c.id in (334332806,
335623813,
346338805)

SELECT * FROM Baldante_SA..IndvOrgContacts_Indexed ioci where ioci.source_id in ('334332806',
'335623813',
'346338805')

SELECT * FROM Baldante_SA..sma_MST_CaseType smct where smct.cstnCaseTypeID = 2816
SELECT * FROM Baldante_SA..sma_MST_SubRole smsr where sbrncasetypeid = 2816


-- find unid plaintiff
SELECT * FROM Baldante_SA..IndvOrgContacts_Indexed ioci where name like '%unidentified%'
SELECT * FROM Baldante_SA..IndvOrgContacts_Indexed ioci where name like 'unidentified plaintiff'
-- 15897
SELECT * FROM Baldante_SA..IndvOrgContacts_Indexed ioci where name like 'Plaintiff Unidentified'
--68

-- how many cases?
select stc.*
from Baldante_SA..sma_TRN_Plaintiff stp
join Baldante_SA..sma_TRN_Cases stc on stp.plnnCaseID = stc.casnCaseID
where stc.source_db='highrise' and stp.plnnContactID in (15897, 68) and stp.plnnContactCtg = 1


SELECT c.*, ioci.*, stc.casnCaseID, stc.cassCaseNumber, stc.source_id, stc.source_db, stc.source_ref
FROM Baldante_SA..sma_TRN_Cases stc
join Baldante_Highrise_20260127..contacts c
on stc.source_id = c.id and stc.source_db='highrise' and stc.source_ref='contacts'
join Baldante_SA..IndvOrgContacts_Indexed ioci on ioci.source_id = c.id and ioci.source_db='highrise' and ioci.source_ref='contacts'
where stc.casnCaseID=30871

SELECT * FROM sma_TRN_Cases stc where stc.casnCaseID=34103
SELECT * FROM Baldante_Highrise_20260128..contacts c where c.id=343623262
select * from Baldante_SA..IndvOrgContacts_Indexed ioci where name like 'Daniel Ellis'
-- hes from tabs....

select * from sma_MST_SubRole smsr where smsr.sbrnCaseTypeID=2626
SELECT * FROM sma_TRN_Plaintiff stp where stp.plnnCaseID=34103

update pln
set pln.plnnContactID = ioci.CID,
	pln.plnnContactCtg = ioci.CTG,
	pln.plnnAddressID = ioci.AID
--select *
from Baldante_SA..sma_TRN_Plaintiff pln
join Baldante_SA..sma_TRN_Cases stc
	on pln.plnnCaseID = stc.casnCaseID
join Baldante_Highrise_20260128..contacts c
	on c.id = stc.source_id
join Baldante_SA..IndvOrgContacts_Indexed ioci
	on ioci.source_id = c.id
	and ioci.source_db = 'highrise'
	and ioci.source_ref = 'contacts'
--join Baldante_SA..sma_MST_SubRole sr
--	on sr.sbrnCaseTypeID = stc.casnOrgCaseTypeID
--	and sr.sbrnRoleID = 4
--	and sr.sbrsDscrptn = '(P)-Plaintiff'
where stc.source_db = 'highrise'
and stc.source_ref = 'contacts'
and pln.plnnContactID in (15897, 68)
and pln.plnnContactCtg = 1



-- tabs3
update pln
set pln.plnnContactID = ioci.CID,
	pln.plnnContactCtg = ioci.CTG,
	pln.plnnAddressID = ioci.AID
--select *
from Baldante_SA..sma_TRN_Plaintiff pln
join Baldante_SA..sma_TRN_Cases stc
	on pln.plnnCaseID = stc.casnCaseID
join Baldante_Highrise_20260128..contacts c
	on c.id = stc.source_id
join Baldante_SA..IndvOrgContacts_Indexed ioci
	on ioci.name = c.name
	and ioci.source_db = 'Tabs3'
--join Baldante_SA..sma_MST_SubRole sr
--	on sr.sbrnCaseTypeID = stc.casnOrgCaseTypeID
--	and sr.sbrnRoleID = 4
--	and sr.sbrsDscrptn = '(P)-Plaintiff'
where stc.source_db = 'highrise'
and stc.source_ref = 'contacts'
and pln.plnnContactID in (15897, 68)
and pln.plnnContactCtg = 1



/* ------------------------------------------------------------------------------
update case names
*/ ------------------------------------------------------------------------------