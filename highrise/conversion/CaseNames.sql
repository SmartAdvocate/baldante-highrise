use SATenantConsolidated_Tabs3_and_MyCase
go

set quoted_identifier on
go

/*===========================================================================
	Create temp table with recalculated case names
===========================================================================*/

-- Drop temp table if it already exists
if OBJECT_ID('dbo.TempCaseName', 'U') is not null
	drop table dbo.TempCaseName;

go

/*--------------------------------------------------------------------------
	Unified contacts view (individual + organization)
--------------------------------------------------------------------------*/
with
	AllContacts
	as (
		 select
			 cinnContactID						as ContactID,
			 cinnContactCtg						as ContactCtg,
			 cinsFirstName + ' ' + cinsLastName as ContactName,
			 saga
		 from sma_MST_IndvContacts

		 union all

		 select
			 connContactID,
			 connContactCtg,
			 consName,
			 saga
		 from sma_MST_OrgContacts
		)
select
	cas.casnCaseID													 as CaseID,
	cas.cassCaseName												 as CaseName,
	ISNULL(pl.ContactName, '') + ' v. ' + ISNULL(df.ContactName, '') as NewCaseName
into dbo.TempCaseName
from sma_TRN_Cases cas
-- Primary Plaintiff
left join sma_TRN_Plaintiff plf
	on plf.plnnCaseID = cas.casnCaseID
		and plf.plnbIsPrimary = 1
left join AllContacts pl
	on pl.ContactId = plf.plnnContactID
		and pl.ContactCtg = plf.plnnContactCtg
-- Primary Defendant
left join sma_TRN_Defendants def
	on def.defnCaseID = cas.casnCaseID
		and def.defbIsPrimary = 1
left join AllContacts df
	on df.ContactId = def.defnContactID
		and df.ContactCtg = def.defnContactCtgID
where
	cas.source_db = 'highrise'
go

--select * from TempCaseName where CaseID = 43128

/*===========================================================================
	Update case names
===========================================================================*/

alter table sma_TRN_Cases disable trigger all;
go

update cas
set cas.cassCaseName = tcn.NewCaseName
from sma_TRN_Cases cas
join dbo.TempCaseName tcn
	on tcn.CaseID = cas.casnCaseID
where ISNULL(tcn.CaseName, '') = ISNULL(cas.cassCaseName, '')

go

alter table sma_TRN_Cases enable trigger all;
go
