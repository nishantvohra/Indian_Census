--Extract all the data from Table 1
select * from Area_Population;

--Extract all the data from Table 2
select * from Growth_sex_Literacy;

--Number of Rows in our data sets
select count(*) as 'Number of Rows' from Area_Population;
select count(*) as 'Number of Rows' from Growth_sex_Literacy;

--Extract data for only 2 States(Jharkhand and Bihar)
select a.*,g.* from Area_Population a join Growth_sex_Literacy g on a.State=g.State
Where a.State in ('Jharkhand','Bihar');

--Calculate Total Population of India
select sum(Population) as Total_population from Area_Population;

--Average Growth percentage of India
select Round(avg(Growth)*100,2) as Average_growth from Growth_sex_Literacy;

--Average Growth percentage by State
select State,Round(avg(Growth)*100,2) as Growth_percentage from Growth_sex_Literacy group by State Order by 2 desc;

--Average Sex Ratio Per State
select State, Round(avg(sex_ratio),0) as Average_Sex_Ratio from Growth_sex_Literacy group by State order by 2 desc;

--Average Literacy Rate per State
select state,round(avg(Literacy),2) as Average_Literacy_Rate from Growth_sex_Literacy group by state  having Avg(Literacy)>90 order by 2 desc; 

--Top 5 State Showing Highest Growth Ratio
select Top 5 State, round(avg(Growth)*100,2) as Average_Growth from Growth_sex_Literacy group by State order by Average_Growth desc;

-- Bottom 3 State Showing Sex Ratio
select top 3 State, Round(avg(sex_ratio),0) as Average_Sex_Ratio from Growth_sex_Literacy group by State order by 2;

--Top 3 and Bottom 3 States showing Average Literacy Rate
select * from (select Top 3 state,round(avg(Literacy),2) as Average_Literacy_Rate from Growth_sex_Literacy group by state order by 2) a
union
select * from (select Top 3 state,round(avg(Literacy),2) as Average_Literacy_Rate from Growth_sex_Literacy group by state order by 2 desc) b
order by Average_Literacy_Rate desc;

-- Area and Population of Sates Starting with letter 'A'
select * from Area_Population where state like '[a-A]%'

-- Area and Population of District Starting with letter 'A' and ending with letter 'D'
select * from Area_Population where District like '[a-A]%' and District like '%[d-D]';

-- Total Amount of Male and Female in each Distict.
with CTE as
(select g.District,g.State,g.Sex_Ratio/1000 as sex_ratio,a.Population from Growth_sex_Literacy g join Area_Population a on g.District=a.District)
select District,State, round(population/(sex_ratio+1),0) as Male_population, Round(population-(population/(sex_Ratio+1)),0) as Female_population, Population as Total_Population
from CTE

-- Total Literacy Rate in each state
select x.State, round((x.Average_Literacy/100)*x.Population,0) as Literate_people, x.Population-(round((x.Average_Literacy/100)*x.Population,0)) as Illiterate_people, x.Population
from (select g.State, avg(g.Literacy) as Average_Literacy,a.Population from Growth_sex_Literacy g join Area_Population a on g.State=a.State
group by g.State,a.Population) x;

-- Population in Previous Census
select sum(D.Previous_Census_Population) as Previous_Census, sum(D.Current_Census_Population) as Current_Census
from
(select x.District,x.State,round(x.Population/(1+x.Growth),0) as Previous_Census_Population, x.Population as Current_Census_Population
from (select G.District,G.State,G.Growth, a.Population from Growth_sex_Literacy G join Area_Population A on G.District=A.District)x) D

-- Population/Area


With Total_Population as
(select 1 as Prime_key,sum(D.Previous_Census_Population) as Previous_Census, sum(D.Current_Census_Population) as Current_Census
from
(select x.District,x.State,round(x.Population/(1+x.Growth),0) as Previous_Census_Population, x.Population as Current_Census_Population
from (select G.District,G.State,G.Growth, a.Population from Growth_sex_Literacy G join Area_Population A on G.District=A.District)x) D),
Total_Area as
(select 1 as Prime_key,sum(Area_km2) as Area
from Area_Population)

select A.Area/P.Current_Census as Current_AreaPerPopulation, A.Area/P.Previous_Census as Previous_AreaPerPopulation
from Total_Population P join Total_Area A on P.Prime_key=A.Prime_key

--Top 3 Disticts from Each State with Literacy Rate.
select A.State,A.District, A.Literacy, A.Distict_Rank from 
(Select G.District,G.State,G.Literacy, Rank() over (Partition by State Order by G.Literacy desc) as Distict_Rank from Growth_sex_Literacy G) A
where A.Distict_Rank in (1,2,3) order by A.State;



