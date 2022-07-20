select * from PortfolioProject.. deaths
order by 3,4


select * from PortfolioProject.. vaccinations
where continent is not null
order by 3,4;

--SELECT THE DATA THAT WE ARE GOING TO BE USING 

select location,date,total_cases,new_cases,total_deaths
,population from PortfolioProject..deaths
where continent is not null
order by 1,2;


-- Looking at total cases versus total deaths -- 

--Likelihood of you dying if you contract covid 
select location,date,total_cases,total_deaths, 
(total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject..deaths
--where  location like '%india%'
continent is not null
order by 1,2;

--Looking at total cases vs population 
--shows what percentage of people got covid
select location,date,population,total_cases, 
(total_cases/population)*100 as deathpercentage
from PortfolioProject..deaths
where location like '%india%'
order by 1,2;

--Countries with highest infection rate wrt population (India)
select location,MAX(total_cases) as highestinfectedcount,population,max((total_cases)/(population))*100
as highest_infection_count
from PortfolioProject..deaths
where location = 'india'
Group by location,population
order by highest_infection_count desc;

--countries with highest death count per population 

select location,MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject ..deaths
where  continent is not null
group by location
order by Total_Death_Count desc;


--break things down by continent 
select continent,location,MAX(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject ..deaths
where  continent is not null
group by location,continent
order by Total_Death_Count desc;


-- Golbal Numbers by dateee
select date,
sum(new_cases) as total_cases,
sum(CAST(new_deaths as int)) as total_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject ..deaths
where continent is not null 
group by date
order by 1,2;

---Global numbers total
select --date,
sum(new_cases) as total_cases,
sum(CAST(new_deaths as int)) as total_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject ..deaths
where continent is not null 
--group by date
order by 1,2;


--Joining tables
select * 
from PortfolioProject..deaths as dea
join PortfolioProject..vaccinations as vac
 on dea.location= vac.location
 and dea.date=vac.date


 --Total population vs vaccination
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from PortfolioProject..deaths as dea
join PortfolioProject..vaccinations as vac
 on dea.location= vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 1,2,3;


 --vaccinations per day 
 with popvsvac (continent,location,date,population,new_vaccinations,rolling_people_vaccinated) 
 as
 (
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as bigint)) over
  (Partition by dea.location order by dea.location
  ,dea.date) as rolling_people_vaccinated
from PortfolioProject..deaths as dea
join PortfolioProject..vaccinations as vac
 on dea.location= vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 1,2,3;
 )
 select *, (rolling_people_vaccinated/population) * 100
 from popvsvac

 --Using CTE
  with popvsvac
  as
  

  --temptable
  create table #percentpopulationvaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  population numeric,
  new_vaccinations numeric,
  rolling_people_vaccinated numeric
  )

  insert into #percentpopulationvaccinated
  select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as bigint)) over
  (Partition by dea.location order by dea.location
  ,dea.date) as rolling_people_vaccinated
from PortfolioProject..deaths as dea
join PortfolioProject..vaccinations as vac
 on dea.location= vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 1,2,3;
 
 select *, (rolling_people_vaccinated/population) * 100
 from #percentpopulationvaccinated



 --Create view for visualization 

 create view percentpopulationvaccinated as
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as bigint)) over
  (Partition by dea.location order by dea.location
  ,dea.date) as rolling_people_vaccinated
from PortfolioProject..deaths as dea
join PortfolioProject..vaccinations as vac
 on dea.location= vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 1,2,3;



 use PortfolioProject

Select * from PortfolioProject..percentpopulationvaccinated
