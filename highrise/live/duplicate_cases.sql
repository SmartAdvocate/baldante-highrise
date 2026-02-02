/* ------------------------------------------------------------------------------
remove duplicate cases
https://smartadvocate.slack.com/lists/TBXC0RF51/F096MN1LHLY?record_id=Rec0AB55X388J

duplicate cases exist as created from both [contacts] and [company]
1. move data from the case created from [company] into the contacts case
- emails, tasks, notes
- for each duplicated case, find unique records for each table and update the caseid to point to the [contacts] case
*/ ------------------------------------------------------------------------------

--verify problem
SELECT * FROM sma_TRN_Cases stc where stc.cassCaseNumber like '%and%'

select
	stc.casnCaseID,
	stc.cassCaseNumber,
	stc.source_id,
	stc.source_db,
	stc.source_ref
from sma_TRN_Cases stc
where
	stc.cassCaseNumber like '46171.053 and 46120.261'

SELECT * FROM Baldante_Highrise_20260127..contacts c where c.id='335572684'
SELECT * FROM Baldante_Highrise_20260127..company c where c.id='344033888'

IF OBJECT_ID('conversion.duplicateHighriseCases','U') IS NOT NULL
    DROP TABLE conversion.duplicateHighriseCases;
GO


-- total dupes
SELECT
    stc.*
INTO conversion.duplicateHighriseCases
FROM sma_TRN_Cases stc
WHERE stc.cassCaseNumber IS NOT NULL
  AND EXISTS (
        SELECT 1
        FROM sma_TRN_Cases c2
        WHERE c2.cassCaseNumber = stc.cassCaseNumber
          AND c2.source_ref = 'contacts'
    )
  AND EXISTS (
        SELECT 1
        FROM sma_TRN_Cases c3
        WHERE c3.cassCaseNumber = stc.cassCaseNumber
          AND c3.source_ref = 'company'
    )
ORDER BY stc.cassCaseNumber;
GO

select * from conversion.duplicateHighriseCases


WITH CaseMap AS (
    SELECT
        d.cassCaseNumber,
        MAX(CASE WHEN d.source_ref = 'contacts' THEN d.casnCaseID END) AS ContactsCaseID,
        MAX(CASE WHEN d.source_ref = 'company'  THEN d.casnCaseID END) AS CompanyCaseID
    FROM conversion.duplicateHighriseCases d
    GROUP BY d.cassCaseNumber
)
SELECT *
FROM CaseMap;


/* ------------------------------------------------------------------------------
Notes
- Compare note records between duplicate cases and look for unique entries
*/ ------------------------------------------------------------------------------
select * from sma_TRN_Notes n where n.notnCaseID in (select d.casnCaseID from conversion.duplicateHighriseCases d) order by n.notmDescription

WITH CaseMap AS (
    SELECT
        d.cassCaseNumber,
        MAX(CASE WHEN d.source_ref = 'contacts' THEN d.casnCaseID END) AS ContactsCaseID,
        MAX(CASE WHEN d.source_ref = 'company'  THEN d.casnCaseID END) AS CompanyCaseID
    FROM conversion.duplicateHighriseCases d
    GROUP BY d.cassCaseNumber
)
SELECT
    cm.cassCaseNumber,
    n_company.notnNoteID,
    n_company.notnCaseID  AS CompanyCaseID,
    cm.ContactsCaseID
FROM CaseMap cm
JOIN sma_TRN_Notes n_company
    ON n_company.notnCaseID = cm.CompanyCaseID
LEFT JOIN sma_TRN_Notes n_contacts
    ON n_contacts.notnCaseID   = cm.ContactsCaseID
   AND n_contacts.notmDescription = n_company.notmDescription
   AND n_contacts.notmPlainText   = n_company.notmPlainText
   AND n_contacts.notdDtCreated   = n_company.notdDtCreated
WHERE n_contacts.notnNoteID IS NULL;

/* ------------------------------------------------------------------------------
Tasks
*/ ------------------------------------------------------------------------------
WITH CaseMap AS (
    SELECT
        d.cassCaseNumber,
        MAX(CASE WHEN d.source_ref = 'contacts' THEN d.casnCaseID END) AS ContactsCaseID,
        MAX(CASE WHEN d.source_ref = 'company'  THEN d.casnCaseID END) AS CompanyCaseID
    FROM conversion.duplicateHighriseCases d
    GROUP BY d.cassCaseNumber
)
SELECT
    cm.cassCaseNumber,
    t_company.tskID,
    t_company.tskCaseID AS CompanyCaseID,
    cm.ContactsCaseID
FROM CaseMap cm
JOIN sma_TRN_TaskNew t_company
    ON t_company.tskCaseID = cm.CompanyCaseID
LEFT JOIN sma_TRN_TaskNew t_contacts
    ON t_contacts.tskCaseID        = cm.ContactsCaseID
   AND t_contacts.tskSummary       = t_company.tskSummary
   AND t_contacts.tskCreatedDt     = t_company.tskCreatedDt
   AND t_contacts.tskCreatedUserID = t_company.tskCreatedUserID
WHERE t_contacts.tskID IS NULL;

/* ------------------------------------------------------------------------------
Emails
*/ ------------------------------------------------------------------------------
WITH CaseMap AS (
    SELECT
        d.cassCaseNumber,
        MAX(CASE WHEN d.source_ref = 'contacts' THEN d.casnCaseID END) AS ContactsCaseID,
        MAX(CASE WHEN d.source_ref = 'company'  THEN d.casnCaseID END) AS CompanyCaseID
    FROM conversion.duplicateHighriseCases d
    GROUP BY d.cassCaseNumber
)
SELECT
    cm.cassCaseNumber,
    e_company.emlnEmailID,
    e_company.emlnCaseID AS CompanyCaseID,
    cm.ContactsCaseID
FROM CaseMap cm
JOIN sma_TRN_Emails e_company
    ON e_company.emlnCaseID = cm.CompanyCaseID
LEFT JOIN sma_TRN_Emails e_contacts
    ON e_contacts.emlnCaseID        = cm.ContactsCaseID
   AND e_contacts.emlsSubject       = e_company.emlsSubject
   AND e_contacts.emldDtCreated     = e_company.emldDtCreated
   AND e_contacts.emlnRecUserID     = e_company.emlnRecUserID
WHERE e_contacts.emlnEmailID IS NULL;


select * from sma_TRN_Emails ste where ste.emlnCaseID in (select d.casnCaseID from conversion.duplicateHighriseCases d)

select * from conversion.duplicateHighriseCases d


-- remove dupes
UPDATE cas
set cas.cassCaseNumber = null
select *
from sma_TRN_Cases cas
join conversion.duplicateHighriseCases dupes on cas.casnCaseID=dupes.casnCaseID
where dupes.source_ref='company'




/* ------------------------------------------------------------------------------
now that the [company] dupes are gone:
Migrate data from cases with "and" to each respective case
46120.268 and 46171.109 -> 46120.268, 46171.109

https://smartadvocate.slack.com/lists/TBXC0RF51/F096MN1LHLY?record_id=Rec0ABHU2782G
*/ ------------------------------------------------------------------------------


SELECT * FROM sma_TRN_Cases stc where stc.cassCaseNumber='46120.268 and 46171.109'
SELECT * FROM sma_TRN_Cases stc where stc.cassCaseNumber='46120.268'
SELECT * FROM sma_TRN_Cases stc where stc.cassCaseNumber='46171.109'


SELECT n.* 
FROM sma_TRN_Notes n
join sma_TRN_Cases stc on n.notnCaseID=stc.casnCaseID where stc.cassCaseNumber='46120.268 and 46171.109'