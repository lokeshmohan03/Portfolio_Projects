select *
from Portfolio_Project..CovidDeaths
where continent is not null
order by  3,4

select Location, date,total_cases, new_cases, total_deaths, population
from Portfolio_Project..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths 

select Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From Portfolio_Project..CovidDeaths
where location like '%states%'
order by 1,2

select Location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From Portfolio_Project..CovidDeaths
where location like '%india%'
order by 1,2

-- looking at total cases vs population
-- shows what percentage of people got covid 

select Location, date, total_cases, population, (total_cases/population)*100 as DeathPercent
From Portfolio_Project..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rates compared to population 

select Location, population, MAX(total_cases) as highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
From Portfolio_Project..CovidDeaths
group by Location, population
order by Percent_Population_Infected desc

--showing countries with highest death count per population 

select location, MAX(cast(total_deaths as int)) as Total_death_Count
from Portfolio_Project..CovidDeaths
where continent is not null
group by location
order by Total_death_Count desc

--showing data by filtered by continent 

select location, MAX(cast(total_deaths as int)) as Total_death_Count
from Portfolio_Project..CovidDeaths
where continent is null
group by location
order by Total_death_Count desc

-- showing continents with highest death count 

select continent, MAX(cast(total_deaths as int)) as Total_death_Count
from Portfolio_Project..CovidDeaths
where continent is not null
group by continent
order by Total_death_Count desc


-- Global Numbers 

Select Sum(new_cases) as total_cases, Sum(cast (new_deaths as int)) as total_deaths,  Sum(cast (new_deaths as int))/Sum(new_cases)*100 as DeathPercent
from Portfolio_Project..CovidDeaths
where continent is not null 
--group by date 
order by 1,2 asc 

-- Looking at total population vs vaccinations 

select dea.continent, dea. location, dea.date, dea. population, vac.new_vaccinations
, Sum(CONVERT(INT,vac.new_vaccinations)) Over (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) as Rolling_People_Vaccinated
From Portfolio_Project..CovidDeaths dea 
Join Portfolio_Project..CovidVacc vac 
on dea.location = vac.location
and dea.date = vac. date
where dea.continent is not null 
order by 2,3

--Using CTE

with PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
select dea.continent, dea. location, dea.date, dea. population, vac.new_vaccinations
, Sum(CONVERT(INT,vac.new_vaccinations)) Over (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) as Rolling_People_Vaccinated
From Portfolio_Project..CovidDeaths dea 
Join Portfolio_Project..CovidVacc vac 
on dea.location = vac.location
and dea.date = vac. date
where dea.continent is not null 
--order by 2,3
)
select *, (Rolling_People_Vaccinated/population) * 100 as Rolling_VAC_Percent
From PopvsVac 

--Temp table

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
Rolling_People_Vaccinated numeric 
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea. location, dea.date, dea. population, vac.new_vaccinations
, Sum(CONVERT(INT,vac.new_vaccinations)) Over (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) as Rolling_People_Vaccinated
From Portfolio_Project..CovidDeaths dea 
Join Portfolio_Project..CovidVacc vac 
on dea.location = vac.location
and dea.date = vac. date
--where dea.continent is not null 
--order by 2,3
select *, (Rolling_People_Vaccinated/population) * 100
From #PercentPopulationVaccinated


-- Creating Views 

Create view PercentPopulationVaccinated as
select dea.continent, dea. location, dea.date, dea. population, vac.new_vaccinations
, Sum(CONVERT(INT,vac.new_vaccinations)) Over (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) as Rolling_People_Vaccinated
From Portfolio_Project..CovidDeaths dea 
Join Portfolio_Project..CovidVacc vac 
on dea.location = vac.location
and dea.date = vac. date
where dea.continent is not null 
--order by 2,3