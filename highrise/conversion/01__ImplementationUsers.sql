USE SATenantConsolidated_Tabs3_And_MyCase
GO


--SELECT DISTINCT [user_id] FROM PracticeMasterBaldante..CMJRNL WHERE isnull([user_id],'') <> ''

if exists (select * from sys.objects where name='implementation_users' and type='U')
begin
    drop table implementation_users
end
GO
create table implementation_users ( 
			Syst varchar(10),
			Staff varchar(50), 
			SAloginID varchar(20), 
			SAFirst varchar(50), 
			SALast varchar(50),
			SAusrnUserID int, 
			SAusrnContactID int )
GO

insert into implementation_users (Syst, Staff, SAFirst, SALast, SAloginID )
SELECT 'T3', 'ADAMD', 'Adam', 'D', 'AdamD' UNION
SELECT 'HR', 'Aimee W.', 'Aimee', 'W', 'AimeeW' UNION
SELECT 'HR', 'Ally C.', 'Ally', 'C', 'AllyC' UNION
SELECT 'T3', 'AMYC', 'Amy', 'C', 'AmyC' UNION
SELECT 'T3', 'AMY', 'Amy', 'C', 'AmyC' UNION
SELECT 'T3', 'ANDREAM', 'Andrea', 'M', 'AndreaM' UNION
SELECT 'HR', 'Andrea Y.', 'Andrea', 'Y', 'AndreaY' UNION
SELECT 'HR', 'Annalise F.', 'Annalise', 'Felicien', 'AnnaliseF' UNION
SELECT 'HR', 'Anthony P.', 'Anthony', 'P', 'AnthonyP' UNION
SELECT 'MC', '', 'Aron', 'Minkoff', 'AronM' UNION
SELECT 'T3', 'ARONM', 'Aron', 'Minkoff', 'AronM' UNION
SELECT 'HR', 'Banita W.', 'Banita', 'W', 'BanitaW' UNION
SELECT 'HR', 'Brandon M.', 'Brandon', 'M', 'BrandonM' UNION
SELECT 'HR', 'Caroline G.', 'Caroline', 'Goldstein', 'CarolineG' UNION
SELECT 'T3', 'CAROLINEG', 'Caroline', 'Goldstein', 'CarolineG' UNION
SELECT 'MC', '', 'Cecilia', 'Bright', 'CelieB' UNION
SELECT 'T3', 'CELIEB', 'Cecilia', 'Bright', 'CelieB' UNION
SELECT 'HR', 'Cheryl K.', 'Cheryl', 'Klucaric', 'CherylK' UNION
SELECT 'MC', '', 'Cheryl', 'Klucaric', 'CherylK' UNION
SELECT 'T3', 'CHERYLK', 'Cheryl', 'Klucaric', 'CherylK' UNION
SELECT 'T3', 'CHRISTYM', 'Christy', 'M', 'ChristyM' UNION
SELECT 'T3', 'CTM', 'Christy', 'M', 'ChristyM' UNION
SELECT 'T3', 'CLAREW', 'Clare', 'W', 'ClareW' UNION
SELECT 'HR', 'Corina H.', 'Corina', 'H', 'CorinaH' UNION
SELECT 'HR', 'Corinne M.', 'Corinne', 'Morgan', 'CorinneM' UNION
SELECT 'MC', '', 'Corinne', 'Morgan', 'CorinneM' UNION
SELECT 'T3', 'CORINNEM', 'Corinne', 'Morgan', 'CorinneM' UNION
SELECT 'HR', 'Corinne N.', 'Corinne', 'Noyd', 'CorinneN' UNION
SELECT 'T3', 'DANIELLA', 'Daniella', 'Price', 'DaniellaP' UNION
SELECT 'HR', 'Danielle D.', 'Danielle', 'Derohannesian', 'DanielleD' UNION
SELECT 'T3', 'DANIELLE', 'Danielle', 'Derohannesian', 'DanielleD' UNION
SELECT 'HR', 'Danielle K.', 'Danielle', 'Kowalski', 'DanielleK' UNION
SELECT 'HR', 'Danielle P.', 'Daniella', 'Price', 'DaniellaP' UNION
SELECT 'T3', 'DARLENET', 'Darlene', 'T', 'DarleneT' UNION
SELECT 'HR', 'Derveleen C.', 'Derveleen', 'C', 'DerveleenC' UNION
SELECT 'T3', 'ELAINEB', 'Elaine', 'B', 'ElaineB' UNION
SELECT 'HR', 'Ellen G.', 'Ellen', 'Gemberling', 'EllenG' UNION
SELECT 'MC', '', 'Ellen', 'Gemberling', 'EllenG' UNION
SELECT 'T3', 'ELLENG', 'Ellen', 'Gemberling', 'EllenG' UNION
SELECT 'HR', 'Emily K.', 'Emily', 'Knight', 'EmilyK' UNION
SELECT 'T3', 'ERICKC', 'Erick', 'C', 'ErickC' UNION
SELECT 'HR', 'Ethan D.', 'Ethan', 'Durand', 'EthanD' UNION
SELECT 'MC', '', 'Ethan', 'Durand', 'EthanD' UNION
SELECT 'HR', 'Eva L.', 'Eva', 'L', 'EvaL' UNION
SELECT 'HR', 'Eve B.', 'Eve', 'B', 'EveB' UNION
SELECT 'HR', 'Gabreil M.', 'Gabriel', 'Magee', 'GabreilM' UNION
SELECT 'T3', 'GABRIEL', 'Gabriel', 'Magee', 'GabreilM' UNION
SELECT 'HR', 'Grace W.', 'Grace', 'Welsh', 'GraceW' UNION
SELECT 'HR', 'Hallie R.', 'Hallie', 'R', 'HallieR' UNION
SELECT 'T3', 'JACKC', 'Jack', 'C', 'JackC' UNION
SELECT 'HR', 'Jamie H.', 'Jamie', 'Hutchinson', 'JamieH' UNION
SELECT 'T3', 'JAMIEH', 'Jamie', 'Hutchinson', 'JamieH' UNION
SELECT 'HR', 'Johanna C.', 'Johanna', 'C', 'JohannaC' UNION
SELECT 'MC', '', 'John', 'Baldante', 'JohnB' UNION
SELECT 'T3', 'JOHNB', 'John', 'Baldante', 'JohnB' UNION
SELECT 'HR', 'Jonathan S.', 'Jonathan', 'S', 'JonathanS' UNION
SELECT 'HR', 'Juankenia G.', 'Juankenia', 'G', 'JuankeniaG' UNION
SELECT 'HR', 'Kaitlin S.', 'Kaitlin', 'S', 'KaitlinS' UNION
SELECT 'MC', '', 'Kathleen', 'Butler', 'KathleenB' UNION
SELECT 'HR', 'Kathleen M.', 'Kathleen', 'M', 'KathleenM' UNION
SELECT 'T3', 'KATHM', 'Kath', 'M', 'KathM' UNION
SELECT 'T3', 'KM', 'Kath', 'M', 'KathM' UNION
SELECT 'HR', 'Kevin P.', 'Kevin', 'P', 'KevinP' UNION
SELECT 'MC', '', 'Kyle', 'Keller', 'KyleK' UNION
SELECT 'T3', 'KYLEK', 'Kyle', 'Keller', 'KyleK' UNION
SELECT 'T3', 'LAWRENCE', 'Lawrence', 'Finney', 'LawrenceF' UNION
SELECT 'HR', 'Mark C.', 'Mark', 'Cohen', 'MarkC' UNION
SELECT 'MC', '', 'Mark', 'Cohen', 'MarkC' UNION
SELECT 'T3', 'MARKC', 'Mark', 'Cohen', 'MarkC' UNION
SELECT 'T3', 'MARKL', 'Mark', 'Levy', 'MarkL' UNION
SELECT 'T3', 'MARTING', 'Martin', 'Rubenstein', 'MartinR' UNION
SELECT 'HR', 'Martin R.', 'Martin', 'Rubenstein', 'MartinR' UNION
SELECT 'MC', '', 'Martin', 'Rubenstein', 'MartinR' UNION
SELECT 'HR', 'Mary D.', 'Mary', 'D', 'MaryD' UNION
SELECT 'HR', 'Maureen K.', 'Maureen', 'K', 'MaureenK' UNION
SELECT 'T3', 'MDD', 'MDD', '', 'MDD' UNION
SELECT 'T3', 'MELISSAW', 'Melissa', 'W', 'MelissaW' UNION
SELECT 'T3', 'MICHELEN', 'Michele', 'N', 'MicheleN' UNION
SELECT 'HR', 'Mistye S.', 'Mistye', 'Stack', 'MistyeS' UNION
SELECT 'HR', 'Mobin C.', 'Mobin', 'C', 'MobinC' UNION
SELECT 'HR', 'Nick K.', 'Nick', 'K', 'NickK' UNION
SELECT 'T3', 'RANNICAA', 'Rannica', 'A', 'RannicaA' UNION
SELECT 'T3', 'RICKB', 'Rick', 'B', 'RickB' UNION
SELECT 'T3', 'RIMMAB', 'Rimma', 'B', 'RimmaB' UNION
SELECT 'HR', 'Sandra L.', 'Sandra', 'L', 'SandraL' UNION
SELECT 'HR', 'Sarah G.', 'Sarah', 'G', 'SarahG' UNION
SELECT 'HR', 'Sarahlyn M.', 'Sarahlyn', 'M', 'SarahlynM' UNION
SELECT 'T3', 'SARAK', 'Sara', 'K', 'SaraK' UNION
SELECT 'HR', 'Selene B.', 'Selene', 'B', 'SeleneB' UNION
SELECT 'HR', 'Shanna M.', 'Shanna', 'M', 'ShannaM' UNION
SELECT 'HR', 'Sharise P.', 'Sharise', 'P', 'ShariseP' UNION
SELECT 'T3', 'SHARISEP', 'Sharise', 'P', 'ShariseP' UNION
SELECT 'T3', 'SP', 'Sharise', 'P', 'ShariseP' UNION
SELECT 'HR', 'Shawni G.', 'Shawni', 'Gilbert', 'ShawniG' UNION
SELECT 'MC', '', 'Shawni', 'Gilbert', 'ShawniG' UNION
SELECT 'HR', 'Shelby K.', 'Shelby', 'K', 'ShelbyK' UNION
SELECT 'HR', 'Sophia A.', 'Sophia', 'Abramson', 'SophiaA' UNION
SELECT 'HR', 'Stacy H.', 'Stacy', 'Hughes', 'StacyH' UNION
SELECT 'HR', 'Steve M.', 'Steve', 'M', 'SteveM' UNION
SELECT 'HR', 'Suzanne A.', 'Suzanne', 'A', 'SuzanneA' UNION
SELECT 'HR', 'Taylor G.', 'Taylor', 'Gordon', 'TaylorG' UNION
SELECT 'HR', 'Taylor H.', 'Taylor', 'H', 'TaylorH' UNION
SELECT 'T3', 'THERESAC', 'Theresa', 'C', 'TheresaC' UNION
SELECT 'HR', 'Thomas F.', 'Thomas', 'F', 'ThomasF' UNION
SELECT 'MC', '', 'Tracey', 'Del Giorno', 'TraceyD' UNION
SELECT 'MC', '', 'Troy', 'Carey', 'TroyC' UNION
SELECT 'T3', 'TROYC', 'Troy', 'Carey', 'TroyC' UNION
SELECT 'HR', 'Val S.', 'Val', 'Sauler', 'ValS' UNION
SELECT 'MC', '', 'Val', 'Sauler', 'ValS' UNION
SELECT 'T3', 'VALS', 'Val', 'Sauler', 'ValS' UNION
SELECT 'MC', '', 'Yvonne', 'Marple', 'YvonneM' 



update iu
set SAusrnUserID = u.usrnUserID,
	SAusrncontactID = u.usrnContactID
FROM implementation_users iu
LEFT JOIN [sma_MST_Users] u on u.[usrsLoginID] = iu.saloginid
GO