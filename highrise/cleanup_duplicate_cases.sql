/*
https://smartadvocate.slack.com/lists/TBXC0RF51/F096MN1LHLY?record_id=Rec0AB55X388J

duplicate cases exist as created from both [contacts] and [company]

1. move data from the case created from [company] into the contacts case
- emails, tasks, notes
- for each duplicated case, find unique records for each table and update the caseid to point to the [contacts] case
*/


/* ------------------------------------------------------------------------------
verify problem
*/ ------------------------------------------------------------------------------
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
    stc.cassCaseNumber,
    stc.casnCaseID,
    stc.source_id,
    stc.source_db,
    stc.source_ref
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

/* ------------------------------------------------------------------------------
set case number to null
*/ ------------------------------------------------------------------------------
UPDATE stc
SET cassCaseNumber = NULL
FROM sma_TRN_Cases stc
JOIN conversion.duplicateHighriseCases dup
    ON stc.casnCaseID = dup.casnCaseID
WHERE stc.source_ref = 'company';


SELECT *
FROM sma_TRN_Cases stc
JOIN conversion.duplicateHighriseCases dup
    ON stc.casnCaseID = dup.casnCaseID
WHERE stc.source_ref = 'company';

--select *
--from sma_TRN_Notes n_company
--left join sma_TRN_Notes n_contacts
--    on n_company.notnCaseID = n_contacts.notnCaseID
--    and n_company.notmDescription = n_contacts.notmDescription
--    and n_company.notmPlainText = n_contacts.notmPlainText
--    and n_company.notdDtCreated = n_contacts.notdDtCreated
--where n_company.notnCaseID in (select hc.casnCaseID from conversion.duplicateHighriseCases hc)
--and n_contacts.notnNoteID is null


--SELECT 
--    sttn.tskCaseID AS DuplicateCaseID,
--    sttn.tskID AS UniqueTaskID,
--    sttn.tskDescription,
--    sttn.tskDueDate
--FROM sma_TRN_TaskNew sttn
--LEFT JOIN sma_TRN_TaskNew original 
--    ON sttn.tskDescription = original.tskDescription
--    AND sttn.tskDueDate = original.tskDueDate
--    AND sttn.tskStartDate = original.tskStartDate
--    AND original.tskCaseID IN (30454, 31691, 32338, 32357, 32347, 32276, 32813, 32145, 31968, 31956, 31700, 31971, 32031, 31974, 32794, 32604, 32866, 33927, 33188, 32461, 32756, 34408, 32219, 31719, 32655, 34300) -- Original ID List
--WHERE sttn.tskCaseID IN (34848, 34849, 34851, 34855, 34858, 34859, 34860, 34861, 34862, 34863, 34864, 34865, 34866, 34867, 34868, 34871, 34872, 34874, 34875, 34876, 34878, 34879, 34880, 34881, 34882, 34883, 34886, 34888, 34889, 34891, 34893, 34895, 34847, 34896) -- Duplicate ID List
--AND original.tskID IS NULL;

--SELECT * FROM sma_TRN_Cases stc where stc.source_ref='company'