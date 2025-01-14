select *
From ProjectPortfolio..CovidDeaths$
Where continent is not null
order by 3,4


--select *
--From ProjectPortfolio..CovidVaccination$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, Population
From ProjectPortfolio..CovidDeaths$
Where continent is not null
order by 1,2

 -- Looking at total cases vs Total Deaths
 -- Shows  likelihood of dying if you contract covid in your country


 select location, date, total_cases,total_deaths, Population , (total_deaths/total_cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths$
Where location like '%kenya%'
and continent is not null
order by 1,2

-- Looking at total cases vs population
-- shows what percentage of population got covid

 select location, date,  Population , total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths$
Where location like '%kenya%'
and continent is not null
order by 1,2

-- looking at countries with highest infrction rate compared to population

 select location, Population , Max (total_cases) as  HighestInfectionCount, Max(total_cases/Population)*100 as PercentPopulationInfected
From ProjectPortfolio..CovidDeaths$
--Where location like '%kenya%'
Where continent is not null
Group by location, Population
order by PercentPopulationInfected desc

-- showing COuntries with Highest Deat Count Per Population

select location, MAX(cast(total_deaths as int) ) as TotalDeathCount
From ProjectPortfolio..CovidDeaths$
--Where location like '%kenya%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINET

-- Showing continets with the highest death count per population

select location, MAX(cast(total_deaths as int) ) as TotalDeathCount
From ProjectPortfolio..CovidDeaths$
--Where location like '%kenya%'
Where continent is not null
Group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS    
 

 Select date, SUM(new_cases) , SUM(cast(new_deaths as int)) , SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths$
--Where location like '%kenya%'
Where continent is not null
Group By date
order by 1,2

--Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(Int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccination$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continet, location,date, population, New_vaccinations, RollingPeopleVaccinations)
as
(
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(Int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccination$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select*,(RollingPeopleVaccinations/population)*100
From PopvsVac




-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continet nvarchar (260),
Location nvarchar (260),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(Int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccination$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select*,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




--Creating View to store data for later Visua;izations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date , dea.population, vac.new_vaccinations
, SUM(CONVERT(Int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--RollingPeopleVaccinated
From ProjectPortfolio..CovidDeaths$ dea
join ProjectPortfolio..CovidVaccination$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
