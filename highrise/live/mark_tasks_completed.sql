SELECT * FROM sma_TRN_TaskNew sttn where sttn.source_db='highrise' and tskCompleted <> 1

update t
set tskCompleted = 1,
	tskCompletedDt = GETDATE(),
	tskCompletedActualDt = GETDATE()
from sma_TRN_TaskNew t
where t.source_db = 'highrise'
and t.tskCompleted <> 1

--SELECT * FROM sma_TRN_TaskNew sttn where sttn.tskCaseID=15399