use SATenantConsolidated_Tabs3_and_MyCase
go

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'conversion')
BEGIN
    EXEC('CREATE SCHEMA conversion')
END
GO

CREATE TABLE [conversion].[HighriseTagStateMap] (
    [TagName] [varchar](255),
    [StateAbbreviation] [varchar](2)
)
GO

INSERT INTO [conversion].[HighriseTagStateMap] ([TagName], [StateAbbreviation])
VALUES
('Absued at NJ Shore','NJ'),
('Abused at NJ Shore','NJ'),
('Crossover NJ','NJ'),
('CSA- NJ Church','NJ'),
('New Jersey Training School','NJ'),
('New Jersey Training School for boys','NJ'),
('NJ','NJ'),
('NJ  Claim','NJ'),
('NJ - Non Catholic Church','NJ'),
('NJ 3rd Party','NJ'),
('NJ 3rd Party Case','NJ'),
('NJ 3rd Party minor','NJ'),
('NJ ADULT','NJ'),
('NJ Adult Case','NJ'),
('NJ Archdiocese','NJ'),
('NJ Baptist Church','NJ'),
('NJ Chuch','NJ'),
('NJ Church','NJ'),
('NJ Church Claim','NJ'),
('NJ Crossover','NJ'),
('NJ Crossover Case','NJ'),
('NJ crossover claim','NJ'),
('NJ- CSA/Medical Setting','NJ'),
('NJ CVA','NJ'),
('NJ Dentention Center','NJ'),
('NJ Detention Center','NJ'),
('NJ Doctor','NJ'),
('NJ Does Meet Criteria','NJ'),
('NJ Dr. Renner','NJ'),
('NJ DYFS','NJ'),
('NJ Episcopal Church','NJ'),
('NJ GENERAL (MINOR)','NJ'),
('NJ Juvenile Detention Center','NJ'),
('NJ Minor Abuse Claim','NJ'),
('NJ Minor claim','NJ'),
('NJ Minors','NJ'),
('NJ non-catholic church','NJ'),
('NJ Non-Program','NJ'),
('NJ Orthodox Church','NJ'),
('NJ Police Athletic League (PAL)','NJ'),
('NJ Religious Order','NJ'),
('NJ School','NJ'),
('NJ School Case','NJ'),
('NJ School Claim','NJ'),
('NJ Schools','NJ'),
('NJ Sex Abuse Case','NJ'),
('NJ Training School for Boys','NJ'),
('NJ Youth Advocate','NJ'),
('NJ-Doctor','NJ'),
('NJTS','NJ'),
('Nursing Home NJ','NJ'),
('PA 3rd Party','PA'),
('PA 3rd Party Case','PA'),
('PA Archdiocese','PA'),
('PA Case','PA'),
('PA Child Support Lien','PA'),
('PA Church','PA'),
('PA Crossover','PA'),
('PA Does Not Meet Criteria','PA'),
('PA General Sex Abuse','PA'),
('PA In Statute','PA'),
('PA Juvenile Detention','PA'),
('PA Not Retained','PA'),
('PA rehab center','PA'),
('PA School','PA'),
('PA Window Case','PA'),
('Pennsylvania Juvenile Detention','PA'),
('Pennsylvania Psychiatric Institute','PA'),
('Registering as a NJ Claim','NJ'),
('Stepping Stone Group Home NJ','NJ'),
('The New Jersey Training School and the Highland School','NJ'),
('Wall Township NJ','NJ');
GO