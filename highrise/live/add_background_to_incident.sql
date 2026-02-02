SELECT sti.CaseId, sti.IncidentFacts
FROM sma_TRN_Incidents sti


update inc
SET inc.IncidentFacts =
    LTRIM(RTRIM(
        -- IncidentFacts (if exists) + CRLF + background
        COALESCE(inc.IncidentFacts, '')
        + CASE
            WHEN isnull(inc.IncidentFacts,'') <> ''
                 THEN CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
            ELSE ''
          END
        + c.background
    ))
--select c.background
from sma_TRN_Incidents inc
join sma_TRN_Cases cas on cas.casnCaseID=inc.CaseId
join Baldante_Highrise_20260127..contacts c on c.company_name = cas.cassCaseNumber and cas.source_db = 'Tabs3'
where isnull(c.background, '') <> ''


SELECT * FROM sma_TRN_Cases stc where stc.cassCaseNumber='46120.252'

select 
	cas.casscasenumber,
	c.background,
	inc.IncidentFacts,
    LTRIM(RTRIM(
        -- IncidentFacts (if exists) + CRLF + background
        COALESCE(inc.IncidentFacts, '')
        + CASE
            WHEN isnull(inc.IncidentFacts,'') <> ''
                THEN CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
            ELSE ''
          END
        + c.background
    )) as result
--select c.background
from sma_TRN_Incidents inc
join sma_TRN_Cases cas on cas.casnCaseID=inc.CaseId
join Baldante_Highrise_20260127..contacts c on c.company_name = cas.cassCaseNumber and cas.source_db = 'Tabs3'
where isnull(c.background, '') <> ''
and cas.cassCaseNumber='46120.252'



SELECT
cas.cassCaseNumber,
    inc.CaseId,
    LEN(inc.IncidentFacts)        AS StoredLen,
    LEN(c.background)             AS BackgroundLen,
    LEN(inc.IncidentFacts) - LEN(c.background) AS Delta
FROM sma_TRN_Incidents inc
JOIN sma_TRN_Cases cas
    ON cas.casnCaseID = inc.CaseId
JOIN Baldante_Highrise_20260127..contacts c
    ON c.company_name = cas.cassCaseNumber
   AND cas.source_db = 'Tabs3'
WHERE c.background IS NOT NULL
  AND LEN(c.background) > LEN(inc.IncidentFacts);
