/* ------------------------------------------------------------------------------
case tags
*/ ------------------------------------------------------------------------------
SELECT * FROM Baldante_Highrise_20260127..contacts c where c.id in (334332806,
335623813,
346338805)
--Glen Mills
--Glen Mills
--NJTS

SELECT * FROM Baldante_SA..sma_MST_CaseTags smct where name in ('Glen Mills',
'NJTS')
--77	NJTS
--635	Glen Mills


SELECT * FROM Baldante_SA..sma_TRN_CaseTags stct
join Baldante_SA..sma_MST_CaseTags smct on stct.TagID = smct.TagID
where stct.CaseID in (30871, 31786, 34779)



-- debug insert
insert into baldante_sa..sma_TRN_CaseTags
	(
		[CaseID],
		[TagID],
		[CreateUserID],
		[DtCreated],
		[DeleteUserID],
		[DtDeleted],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		cas.casnCaseID,
		t.TagID,
		368		   as CreateUserID,
		GETDATE()  as DtCreated,
		null	   as DeleteUserID,
		null	   as DtDeleted,
		null	   as [source_id],
		'highrise' as [source_db],
		'contacts' as [source_ref]
	--select c.*
	from Baldante_Highrise_20260128..contacts c
	join baldante_sa..sma_TRN_Cases cas
		--on cas.cassCaseNumber = c.company_name
	on cas.source_id = c.id
		and [source_db] = 'highrise'
	cross apply STRING_SPLIT(c.tags, ',') ss
	join baldante_sa.dbo.sma_MST_CaseTags t
		on t.Name = TRIM(ss.value)
	where
		ISNULL(c.tags, '') <> ''
		AND NOT EXISTS (
          SELECT 1 
          FROM baldante_sa..sma_TRN_CaseTags existing
          WHERE existing.CaseID = cas.casnCaseID 
            AND existing.TagID = t.TagID
      );
		--and c.id in (334332806, 335623813, 346338805)
	--order by cas.casnCaseID
go

-- these cases have no company_name, so they have auto generated case numbers, so the join to cases fails