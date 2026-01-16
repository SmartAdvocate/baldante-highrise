use SATenantConsolidated_Tabs3_and_MyCase
go


/* ------------------------------------------------------------------------------
Insert [sma_MST_Address] from highrise
------------------------------------------------------------------------------ */
exec AddBreadcrumbsToTable 'sma_MST_Address';
alter table [sma_MST_Address] disable trigger all
go

-- Home Address
insert into [sma_MST_Address]
	(
		[addnContactCtgID],
		[addnContactID],
		[addnAddressTypeID],
		[addsAddressType],
		[addsAddTypeCode],
		[addsAddress1],
		[addsAddress2],
		[addsAddress3],
		[addsStateCode],
		[addsCity],
		[addnZipID],
		[addsZip],
		[addsCounty],
		[addsCountry],
		[addbIsResidence],
		[addbPrimary],
		[adddFromDate],
		[adddToDate],
		[addnCompanyID],
		[addsDepartment],
		[addsTitle],
		[addnContactPersonID],
		[addsComments],
		[addbIsCurrent],
		[addbIsMailing],
		[addnRecUserID],
		[adddDtCreated],
		[addnModifyUserID],
		[adddDtModified],
		[addnLevelNo],
		[caseno],
		[addbDeleted],
		[addsZipExtn],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select distinct
		ioci.CTG			  as addncontactctgid,
		ioci.CID			  as addncontactid,
		t.addnAddTypeID		  as addnaddresstypeid,
		t.addsDscrptn		  as addsaddresstype,
		t.addsCode			  as addsaddtypecode,
		LEFT(a.[address], 75) as addsaddress1,
		null				  as addsaddress2,
		null				  as addsaddress3,
		null				  as addsstatecode,
		null				  as addscity,
		null				  as addnzipid,
		null				  as addszip,
		null				  as addscounty,
		null				  as addscountry,
		null				  as addbisresidence,
		0					  as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		null				  as [addscomments],
		null,
		null,
		368					  as addnrecuserid,
		GETDATE()			  as addddtcreated,
		368					  as addnmodifyuserid,
		GETDATE()			  as addddtmodified,
		null,
		null,
		null,
		null,
		null				  as saga,
		a.id				  as source_id,
		'highrise'			  as source_db,
		'address'			  as source_ref
	--select distinct c.id, c.name, a.address, ioci.CID, ioci.CTG
	from Baldante_Highrise..address a
	join Baldante_Highrise..contacts c
		on c.id = a.contact_id
	join IndvOrgContacts_Indexed ioci
		on ioci.Name = c.name
			and ioci.source_db = 'Tabs3'
			and ioci.CTG = 1
	--join sma_MST_IndvContacts indv
	--	on c.id = indv.saga
	--		and indv.[source_db] = 'highrise'
	--		and indv.[source_ref] = 'contacts'
	join [sma_MST_AddressTypes] as t
		on t.addnContactCategoryID = ioci.CTG
			and t.addsCode = 'HM'
	left join sma_MST_Address addr
		on addr.addnContactID = ioci.CID
			and addr.addnContactCtgID = ioci.CTG
			and addr.addsAddress1 = LEFT(a.[address], 75)
			and addr.addsAddTypeCode = 'HM'
	where
		ISNULL(a.address, '') <> ''
		and addr.addnAddressID is null
--and ioci.CID = 12663

;
go

-- add 'Other' address to any contacts with no addresses
--insert into [sma_MST_Address]
--	(
--		addnContactCtgID,
--		addnContactID,
--		addnAddressTypeID,
--		addsAddressType,
--		addsAddTypeCode,
--		addbPrimary,
--		addnRecUserID,
--		adddDtCreated
--	)
--	select
--		i.cinnContactCtg as addncontactctgid,
--		i.cinnContactID	 as addncontactid,
--		(
--		 select
--			 addnAddTypeID
--		 from [sma_MST_AddressTypes]
--		 where addsDscrptn = 'Other'
--			 and addnContactCategoryID = i.cinnContactCtg
--		)				 as addnaddresstypeid,
--		'Other'			 as addsaddresstype,
--		'OTH'			 as addsaddtypecode,
--		1				 as addbprimary,
--		368				 as addnrecuserid,
--		GETDATE()		 as addddtcreated
--	from [sma_MST_IndvContacts] i
--	left join [sma_MST_Address] a
--		on a.addncontactid = i.cinnContactID
--			and a.addncontactctgid = i.cinnContactCtg
--	where
--		a.addnAddressID is null
--go


-- update primary address
--update [sma_MST_Address]
--set addbPrimary = 1
--from (
-- select
--	 i.cinnContactID															   as cid,
--	 a.addnAddressID															   as aid,
--	 ROW_NUMBER() over (partition by i.cinnContactID order by a.addnAddressID asc) as rownumber
-- from [sma_MST_Indvcontacts] i
-- join [sma_MST_Address] a
--	 on a.addnContactID = i.cinnContactID
--	 and a.addnContactCtgID = i.cinnContactCtg
--	 and a.addbPrimary <> 1
-- where i.cinnContactID not in (
--	  select
--		  i.cinnContactID
--	  from [sma_MST_Indvcontacts] i
--	  join [sma_MST_Address] a
--		  on a.addnContactID = i.cinnContactID
--		  and a.addnContactCtgID = i.cinnContactCtg
--		  and a.addbPrimary = 1
--	 )
--) a
--where a.rownumber = 1
--and a.aid = addnAddressID


alter table [sma_MST_Address] enable trigger all
go

/* ------------------------------------------------------------------------------
Insert [sma_MST_ContactNumbers] from highrise
------------------------------------------------------------------------------ */
exec AddBreadcrumbsToTable 'sma_MST_ContactNumbers';
alter table [sma_MST_ContactNumbers] disable trigger all
go

insert into [sma_MST_ContactNumbers]
	(
		[cnnnContactCtgID],
		[cnnnContactID],
		[cnnnPhoneTypeID],
		[cnnsContactNumber],
		[cnnsExtension],
		[cnnbPrimary],
		[cnnbVisible],
		[cnnnAddressID],
		[cnnsLabelCaption],
		[cnnnRecUserID],
		[cnndDtCreated],
		[cnnnModifyUserID],
		[cnndDtModified],
		[cnnnLevelNo],
		[caseno],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		ioci.ctg								 as cnnncontactctgid,
		ioci.CID								 as cnnncontactid,
		t.ctynContactNoTypeID					 as cnnnphonetypeid,
		LEFT(dbo.parsePhone(p.phone_number), 30) as cnnscontactnumber,
		null									 as cnnsextension,
		1										 as cnnbprimary,
		null									 as cnnbvisible,
		--a.addnAddressID							  as cnnnaddressid,
		null									 as cnnnaddressid,
		'Home Phone'							 as cnnslabelcaption,
		368										 as cnnnrecuserid,
		GETDATE()								 as cnnddtcreated,
		368										 as cnnnmodifyuserid,
		GETDATE()								 as cnnddtmodified,
		null									 as cnnnlevelno,
		null									 as caseno,
		null									 as saga,
		p.id									 as source_id,
		'highrise'								 as source_db,
		'phone'									 as source_ref
	--select 	LEFT(dbo.FormatPhone(p.phone_number), 30) as FormatPhone,
	--		LEFT(dbo.parsePhone(p.phone_number), 30) as ParsePhone,
	--		p.phone_number
	from Baldante_Highrise..phone as p
	join Baldante_Highrise..contacts c
		on p.contact_id = c.id
	join IndvOrgContacts_Indexed ioci
		on ioci.Name = c.name
			and ioci.source_db = 'Tabs3'
			and ioci.CTG = 1
	--join [sma_MST_IndvContacts] as indv
	--	on indv.saga = p.contact_id
	--		and indv.[source_db] = 'highrise'
	--		and indv.[source_ref] = 'contacts'
	--join [sma_MST_Address] as a
	--	on a.addnContactID = ioci.CID
	--		and a.addnContactCtgID = ioci.CTG
	--		and a.addbPrimary = 1
	join sma_MST_ContactNoType as t
		on t.ctysDscrptn = 'Home Primary Phone'
			and t.ctynContactCategoryID = 1
	left join sma_MST_ContactNumbers cn
		on cn.cnnnContactID = ioci.CID
			and cn.cnnnContactCtgID = ioci.CTG
			and cn.cnnsContactNumber = LEFT(dbo.FormatPhone(p.phone_number), 30)
			and cn.cnnnPhoneTypeID = t.ctynContactNoTypeID
	where
		ISNULL(p.phone_number, '') <> ''
		and cn.cnnnContactNumberID is null
go


--------------------------------------------------------------
--ONE PHONE NUMBER AS PRIMARY
--------------------------------------------------------------
update [sma_MST_ContactNumbers]
set cnnbPrimary = 0
from (
 select
	 ROW_NUMBER() over (partition by cnnnContactID order by cnnnContactNumberID) as RowNumber,
	 cnnnContactNumberID														 as ContactNumberID
 from [sma_MST_ContactNumbers]
 where cnnnContactCtgID = (
	  select
		  ctgnCategoryID
	  from [sma_MST_ContactCtg]
	  where ctgsDesc = 'Individual'
	 )
) A
where A.RowNumber <> 1
and A.ContactNumberID = cnnnContactNumberID


--update [sma_MST_ContactNumbers]
--set cnnbPrimary = 0
--from (
-- select
--	 ROW_NUMBER() over (partition by cnnnContactID order by cnnnContactNumberID) as RowNumber,
--	 cnnnContactNumberID														 as ContactNumberID
-- from [sma_MST_ContactNumbers]
-- where cnnnContactCtgID = (
--	  select
--		  ctgnCategoryID
--	  from [sma_MST_ContactCtg]
--	  where ctgsDesc = 'Organization'
--	 )
--) A
--where A.RowNumber <> 1
--and A.ContactNumberID = cnnnContactNumberID


alter table [sma_MST_ContactNumbers] enable trigger all
go

/* ------------------------------------------------------------------------------
Insert [sma_MST_EmailWebsite] for highrise contacts
------------------------------------------------------------------------------ */
exec AddBreadcrumbsToTable 'sma_MST_EmailWebsite';
alter table [sma_MST_EmailWebsite] disable trigger all;
go

insert into [sma_MST_EmailWebsite]
	(
		[cewnContactCtgID],
		[cewnContactID],
		[cewsEmailWebsiteFlag],
		[cewsEmailWebSite],
		[cewbDefault],
		[cewnRecUserID],
		[cewdDtCreated],
		[cewnModifyUserID],
		[cewdDtModified],
		[cewnLevelNo],
		[saga],
		[source_id],
		[source_db],
		[source_ref]
	)
	select
		ioci.CTG		as cewncontactctgid,
		ioci.CID		as cewncontactid,
		'E'				as cewsemailwebsiteflag,
		e.email_address as cewsemailwebsite,
		null			as cewbdefault,
		368				as cewnrecuserid,
		GETDATE()		as cewddtcreated,
		368				as cewnmodifyuserid,
		GETDATE()		as cewddtmodified,
		null			as cewnlevelno,
		null			as saga,
		e.id			as source_id,
		'highrise'		as source_db,
		'email_address' as source_ref
	--select *
	from Baldante_Highrise..email_address as e
	join Baldante_Highrise..contacts c
		on e.contact_id = c.id
	join IndvOrgContacts_Indexed ioci
		on ioci.Name = c.name
			and ioci.source_db = 'Tabs3'
			and ioci.CTG = 1
	--join [sma_MST_IndvContacts] as indv
	--	on indv.saga = e.contact_id
	--		and indv.[source_db] = 'highrise'
	--		and indv.[source_ref] = 'contacts'
	left join sma_MST_EmailWebsite ew
		on ew.cewnContactID = ioci.CID
			and ew.cewnContactCtgID = ioci.CTG
			and ew.cewsEmailWebSite = e.email_address
	where
		ISNULL(e.email_address, '') <> ''
		and ew.cewnEmlWSID is null
go

alter table [sma_MST_EmailWebsite] enable trigger all
go