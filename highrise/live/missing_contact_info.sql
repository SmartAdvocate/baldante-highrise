/*
insert email addresses
insert phone numbers
run primary contact no update
insert addresses
clean blank other addresses
rebuild ACI
rebuild ioci
*/


select c.id, c.name, a.*, e.*, p.*
from Baldante_Highrise_20260128..contacts c
left join Baldante_Highrise_20260128..address a on a.contact_id='346243438'
left join Baldante_Highrise_20260128..email_address e on e.contact_id='346243438'
left join Baldante_Highrise_20260128..phone p on p.contact_id='346243438'
where c.id='346243438'

SELECT * FROM Baldante_Highrise_20260128..contacts
SELECT * FROM Baldante_Highrise_20260128..company
SELECT * FROM Baldante_Highrise_20260128..address a


use baldante_SA
go



/* ------------------------------------------------------------------------------
Insert email addresses
*/ ------------------------------------------------------------------------------
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
		matchedContacts.CTG			  as cewncontactctgid,
		matchedContacts.CID			  as cewncontactid,
		'E'							  as cewsemailwebsiteflag,
		matchedContacts.email_address as cewsemailwebsite,
		null						  as cewbdefault,
		368							  as cewnrecuserid,
		GETDATE()					  as cewddtcreated,
		368							  as cewnmodifyuserid,
		GETDATE()					  as cewddtmodified,
		null						  as cewnlevelno,
		null						  as saga,
		matchedContacts.id			  as source_id,
		'highrise'					  as source_db,
		'email_address'				  as source_ref
	from (
		-- direct join to highrise contacts
		select
			ioci.CID,
			ioci.CTG,
			e.email_address,
			e.id
		from Baldante_Highrise_20260128..email_address as e
			join Baldante_Highrise_20260128..contacts c
				on e.contact_id = c.id
			join IndvOrgContacts_Indexed ioci
				on ioci.source_id = e.contact_id
		where ioci.source_db = 'highrise'
			and ISNULL(e.email_address, '') <> ''

		union

		-- match on name for Tabs3 contacts
		select
			ioci.CID,
			ioci.CTG,
			e.email_address,
			e.id
		from Baldante_Highrise_20260128..email_address as e
			join Baldante_Highrise_20260128..contacts c
				on e.contact_id = c.id
			join IndvOrgContacts_Indexed ioci
				on ioci.Name = c.name
		where ioci.source_db = 'Tabs3'
			and ioci.CTG = 1
			and ISNULL(e.email_address, '') <> ''
	) as matchedContacts
	left join sma_MST_EmailWebsite ew
		on ew.cewnContactID = matchedContacts.CID
		and ew.cewnContactCtgID = matchedContacts.CTG
		and ew.cewsEmailWebSite = matchedContacts.email_address
	where
		ew.cewnEmlWSID is null;

go

alter table [sma_MST_EmailWebsite] enable trigger all
go


select ew.cewnContactID, ew.cewnContactCtgID, ew.cewsEmailWebSite
FROM sma_MST_EmailWebsite ew
group by ew.cewnContactID, ew.cewnContactCtgID, ew.cewsEmailWebSite
having count(ew.cewsEmailWebSite)>1

----select --*,
----e.email_address,
----count(*)
--from Baldante_Highrise_20260128..email_address as e
--join Baldante_Highrise_20260128..contacts c
--	on e.contact_id = c.id
--join IndvOrgContacts_Indexed ioci
--	on ioci.Name = c.name
--		and ioci.CTG = 1
--left join sma_MST_EmailWebsite ew
--	on ew.cewnContactID = ioci.CID
--		and ew.cewnContactCtgID = ioci.CTG
--		and ew.cewsEmailWebSite = e.email_address
--where
--	ISNULL(e.email_address, '') <> ''
--	and ew.cewnEmlWSID is null
----group by e.email_address
----having count(e.email_address) > 1
--order by e.email_address


-- duplicate emails for Aaron Williams
SELECT * FROM Baldante_Highrise_20260128..email_address ea where ea.contact_id='342189767'
SELECT * FROM IndvOrgContacts_Indexed ioci where name = 'Aaron Williams'
SELECT * FROM Baldante_Highrise_20260128..contacts c where c.id in ('334779465',
'336273257')
-- pass (separate files):
--Aaron Williams.txt
--Aaron Williams-336273257.txt

-- duplicate emails for William Carter
SELECT * FROM Baldante_Highrise_20260128..contacts c where c.filename='William Carter-335567194.txt'
SELECT * FROM Baldante_Highrise_20260128..email_address ea where ea.contact_id='335567194'
SELECT * FROM IndvOrgContacts_Indexed ioci where name = 'William Carter'
SELECT * FROM Baldante_Highrise_20260128..contacts c where c.id in (
'334087319',
'335567194',
'335833666')
-- pass (separate files):
--William Carter.txt
--William Carter-335567194.txt
--William Carter-335833666.txt

-- duplicates: angelica.m.cruz32@gmail.com
SELECT * FROM Baldante_Highrise_20260128..email_address ea where ea.email_address = 'angelica.m.cruz32@gmail.com'
SELECT * FROM Baldante_Highrise_20260128..contacts c where c.id='346338805'
SELECT * FROM IndvOrgContacts_Indexed ioci where name = 'Kevin Williams'
SELECT * FROM Baldante_Highrise_20260128..contacts c where c.id in (
'334332806',
'335199028',
'335623813',
'346338805')
-- pass (separate files):
--Kevin Williams.txt
--Kevin James Williams.txt
--Kevin Williams-335623813.txt
--Kevin Williams-346338805.txt




/* ------------------------------------------------------------------------------
[sma_MST_ContactNumbers]
*/ ------------------------------------------------------------------------------



/* ------------------------------------------------------------------------------
02.02.2026
- keep the min([cnnnContactNumberID])
- ignore blank [cnnsContactNumber]
*/ ------------------------------------------------------------------------------

-- tanya left the source data in comments
select * from sma_MST_ContactNumbers where cnnsContactNumber = ''


-- count dupe groups
select cn.cnnnContactID, cn.cnnnContactCtgID, cn.cnnsContactNumber, count(*)
FROM sma_MST_ContactNumbers cn
--where isnull(cnnsContactNumber,'')<>'' --and cn.source_db='highrise'
group by cn.cnnnContactID, cn.cnnnContactCtgID, cn.cnnsContactNumber
having count(cn.cnnsContactNumber)>1
-- 1440 GROUPS (not total dupes)


WITH dups AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                cnnnContactID,
                cnnnContactCtgID,
                cnnsContactNumber
            ORDER BY
                cnnnContactNumberID
        ) AS rn
    FROM sma_mst_contactnumbers
    WHERE cnnsContactNumber <> ''
)
SELECT *
FROM dups
WHERE rn > 1;

select cnnnContactNumberID, cnnnContactID, cnnnContactCtgID, cnnsContactNumber, cnnnPhoneTypeID, Comments, source_id, source_db, source_ref FROM [sma_MST_ContactNumbers] where cnnnContactID in(41,181,74)
SELECT cnnnContactID, cnnnContactCtgID, cnnsContactNumber, cnnnPhoneTypeID, source_id, source_db, source_ref FROM [sma_MST_ContactNumbers] where cnnnContactID in(6635,2993,6280,7750)


-- backup the dupes
IF OBJECT_ID('conversion.duplicate_ContactNumbers','U') IS NOT NULL
    DROP TABLE conversion.duplicate_ContactNumbers;
GO

WITH dups as
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                cnnnContactID,
                cnnnContactCtgID,
                cnnsContactNumber
            ORDER BY
                cnnnContactNumberID
        ) AS rn
    FROM sma_mst_contactnumbers
    WHERE cnnsContactNumber <> ''
)
SELECT d.*
INTO conversion.duplicate_ContactNumbers
FROM dups d
WHERE
    d.rn > 1
    --AND d.source_db = 'highrise'
   -- AND EXISTS (
   --     SELECT 1
   --     FROM sma_MST_ContactNumbers t
   --     WHERE
   --         t.cnnnContactID = d.cnnnContactID
			--and t.cnnnContactCtgID = d.cnnnContactCtgID
   --         AND t.cnnsContactNumber = d.cnnsContactNumber
   --         AND t.source_db = 'Tabs3'
   -- );

select * from conversion.duplicate_ContactNumbers

-- delete dupes
alter table sma_MST_ContactNumbers disable trigger all
go

delete cn
	from sma_MST_ContactNumbers cn
	join conversion.duplicate_ContactNumbers dupes
		on dupes.cnnnContactNumberID = cn.cnnnContactNumberID;


-- any left?
select cn.cnnnContactID, cn.cnnnContactCtgID, cn.cnnsContactNumber, cn.source_db, cn.source_ref, count(*)
FROM sma_MST_ContactNumbers cn
where isnull(cnnsContactNumber,'')<>'' --and cn.source_db='highrise'
group by cn.cnnnContactID, cn.cnnnContactCtgID, cn.cnnsContactNumber,  cn.source_db, cn.source_ref
having count(cn.cnnsContactNumber)>1

SELECT cnnnContactID, cnnnContactCtgID, cnnsContactNumber, cnnnPhoneTypeID, source_id, source_db, source_ref FROM [sma_MST_ContactNumbers] where cnnnContactID in(181)




-- insert missing numbers
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
		matchedContacts.ctg									   as cnnncontactctgid,
		matchedContacts.CID									   as cnnncontactid,
		t.ctynContactNoTypeID								   as cnnnphonetypeid,
		LEFT(dbo.parsePhone(matchedContacts.phone_number), 30) as cnnscontactnumber,
		null												   as cnnsextension,
		1													   as cnnbprimary,
		null												   as cnnbvisible,
		null												   as cnnnaddressid,
		'Home Phone'										   as cnnslabelcaption,
		368													   as cnnnrecuserid,
		GETDATE()											   as cnnddtcreated,
		368													   as cnnnmodifyuserid,
		GETDATE()											   as cnnddtmodified,
		null												   as cnnnlevelno,
		null												   as caseno,
		null												   as saga,
		matchedContacts.id									   as source_id,
		'highrise'											   as source_db,
		'phone_live'												   as source_ref
	from (
		-- direct join to highrise contacts
		select
			ioci.CID,
			ioci.CTG,
			p.phone_number,
			p.id
		from Baldante_Highrise_20260128..phone as p
			join Baldante_Highrise_20260128..contacts c
				on p.contact_id = c.id
			join IndvOrgContacts_Indexed ioci
				on ioci.source_id = p.contact_id
		where ioci.source_db = 'highrise'
			and ISNULL(p.phone_number, '') <> ''

		union

		-- match on name for Tabs3 contacts
		select
			ioci.CID,
			ioci.CTG,
			p.phone_number,
			p.id
		from Baldante_Highrise_20260128..phone as p
			join Baldante_Highrise_20260128..contacts c
				on p.contact_id = c.id
			join IndvOrgContacts_Indexed ioci
				on ioci.Name = c.name
		where ioci.source_db = 'Tabs3'
			and ioci.CTG = 1
			and ISNULL(p.phone_number, '') <> ''
	) as matchedContacts
	join sma_MST_ContactNoType as t
		on t.ctysDscrptn = 'Home Primary Phone'
		and t.ctynContactCategoryID = 1
	left join sma_MST_ContactNumbers cn
		on cn.cnnnContactID = matchedContacts.CID
		and cn.cnnnContactCtgID = matchedContacts.CTG
		and cn.cnnsContactNumber = LEFT(dbo.parsePhone(matchedContacts.phone_number), 30)
	where
		ISNULL(matchedContacts.phone_number, '') <> ''
		and cn.cnnnContactNumberID is null
	order by matchedContacts.CID, matchedContacts.CTG, matchedContacts.phone_number
go

--select * from Baldante_Highrise_20260128..phone p where p.id in(6791,6789)
--SELECT * FROM  Baldante_Highrise_20260128..contacts c where  c.id in(
--343055207,
--337218668)

select cn.cnnnContactID, cn.cnnnContactCtgID, cn.cnnnPhoneTypeID, cn.cnnsContactNumber
FROM sma_MST_ContactNumbers cn
group by cn.cnnnContactID, cn.cnnnContactCtgID, cn.cnnnPhoneTypeID, cn.cnnsContactNumber
having count(cn.cnnsContactNumber)>1

SELECT * FROM [sma_MST_ContactNumbers] where cnnnContactID=20389
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



alter table [sma_MST_ContactNumbers] enable trigger all
go



/* ------------------------------------------------------------------------------
address
1. delete all OTHER addresses
2. insert address
3. add OTHER address for any contacts without one
*/ ------------------------------------------------------------------------------
SELECT * FROM sma_MST_Address sma where sma.addsAddressType = 'Other'
SELECT count(*) FROM sma_MST_Address sma where sma.addsAddressType = 'Other' and isnull(addsAddress1,'') = '' and addbPrimary = 1


-- backup
IF OBJECT_ID('conversion.deletedOtherAddresses','U') IS NOT NULL
    DROP TABLE conversion.deletedOtherAddresses
go


select *
into conversion.deletedOtherAddresses
from sma_MST_Address
where addsAddressType = 'Other'
and isnull(addsAddress1,'') = '' and addbPrimary = 1


-- delete all OTHER addresses
alter table sma_MST_Address disable trigger all
go

--delete 
----select *
--from sma_MST_Address
--where addsAddressType = 'Other'
--and isnull(addsAddress1,'') = ''


delete addr
	from sma_MST_Address addr
	join conversion.deletedOtherAddresses del
		on del.addnAddressID = addr.addnAddressID

select * from conversion.deletedOtherAddresses del

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
		matchedContacts.CTG				   as addncontactctgid,
		matchedContacts.CID				   as addncontactid,
		t.addnAddTypeID					   as addnaddresstypeid,
		t.addsDscrptn					   as addsaddresstype,
		t.addsCode						   as addsaddtypecode,
		LEFT(matchedContacts.street, 75)   as addsaddress1,
		null							   as addsaddress2,
		null							   as addsaddress3,
		(select st.sttnStateID from sma_MST_States st where st.sttsCode = matchedContacts.state) as addsstatecode,
		left(matchedContacts.city,50)			   as addscity,
		null							   as addnzipid,
		left(matchedContacts.zip,10)				   as addszip,
		null							   as addscounty,
		null							   as addscountry,
		null							   as addbisresidence,
		0								   as addbprimary,
		null,
		null,
		null,
		null,
		null,
		null,
		LEFT(matchedContacts.address, 500) as [addscomments],
		null,
		null,
		368								   as addnrecuserid,
		GETDATE()						   as addddtcreated,
		368								   as addnmodifyuserid,
		GETDATE()						   as addddtmodified,
		null,
		null,
		null,
		null,
		null							   as saga,
		matchedContacts.id				   as source_id,
		'highrise'						   as source_db,
		'address_live'					   as source_ref
	--select *
	from (
		-- direct join to highrise contacts
		select
			ioci.CID,
			ioci.CTG,
			a.id,
			a.address,
			a.street,
			a.city,
			a.state,
			a.zip
		from Baldante_Highrise_20260128..address a
			join Baldante_Highrise_20260128..contacts c
				on a.contact_id = c.id
			join IndvOrgContacts_Indexed ioci
				on ioci.source_id = a.contact_id
		where ioci.source_db = 'highrise'
			and ISNULL(a.address, '') <> ''

		union

		-- match on name for Tabs3 contacts
		select
			ioci.CID,
			ioci.CTG,
			a.id,
			a.address,
			a.street,
			a.city,
			a.state,
			a.zip
		from Baldante_Highrise_20260128..address a
			join Baldante_Highrise_20260128..contacts c
				on a.contact_id = c.id
			join IndvOrgContacts_Indexed ioci
				on ioci.Name = c.name
		where ioci.source_db = 'Tabs3'
			and ioci.CTG = 1
			and ISNULL(a.address, '') <> ''
	) as matchedContacts
	join [sma_MST_AddressTypes] as t on t.addnContactCategoryID = matchedContacts.CTG
			and t.addsCode = 'HM'
	left join sma_MST_Address addr on addr.addnContactID = matchedContacts.CID
			and addr.addnContactCtgID = matchedContacts.CTG
			and addr.addsAddress1 = LEFT(matchedContacts.street, 75)
			and addr.addsAddTypeCode = 'HM'
	where
		ISNULL(matchedContacts.address, '') <> ''
		and addr.addnAddressID is null
		--and matchedContacts.cid = 21396
go

-- insert OTHER address for all contacts without one
insert into [sma_MST_Address]
	(
		addnContactCtgID,
		addnContactID,
		addnAddressTypeID,
		addsAddressType,
		addsAddTypeCode,
		addbPrimary,
		addnRecUserID,
		adddDtCreated
	)
	select
		i.cinnContactCtg as addncontactctgid,
		i.cinnContactID	 as addncontactid,
		(
		 select
			 addnAddTypeID
		 from [sma_MST_AddressTypes]
		 where addsDscrptn = 'Other'
			 and addnContactCategoryID = i.cinnContactCtg
		)				 as addnaddresstypeid,
		'Other'			 as addsaddresstype,
		'OTH'			 as addsaddtypecode,
		1				 as addbprimary,
		368				 as addnrecuserid,
		GETDATE()		 as addddtcreated
	from [sma_MST_IndvContacts] i
	left join [sma_MST_Address] a
		on a.addncontactid = i.cinnContactID
			and a.addncontactctgid = i.cinnContactCtg
	where
		a.addnAddressID is null
go