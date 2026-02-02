USE Baldante_Highrise_20260128
GO

create schema conversion


SELECT id, [name], tags, company_name, ltrim(rtrim(value)) as SingleTag, ordinal
INTO conversion.ContactTags
from Baldante_Highrise_20260128..contacts
cross apply string_split(tags,',', 1)
order by id, ordinal

select * from conversion.ContactTags