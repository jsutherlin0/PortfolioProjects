SELECT location, total_cases, new_cases, total_deaths, population
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths`
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows liklihoood of death in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths`
WHERE location like '%States%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as CasesByPercentage
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths`
WHERE location like '%States%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
SELECT location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths`
Group by location,population
order by PercentPopulationInfected desc

--Showing Countries with  Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths`
Where continent is not null
Group by location
order by TotalDeathCount desc



-- SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
-- FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths`
-- Where continent is null
-- Group by location
-- order by TotalDeathCount desc

--Breaking things down by Continent
SELECT continent, MAX(total_deaths)as TotalDeathCount
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths`
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths`
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
Select date,SUM(new_deaths) as total_deaths,SUM(new_cases)as total_cases, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths`
where continent is not null
group by date
order by 1,2

Select SUM(new_deaths) as total_deaths,SUM(new_cases)as total_cases, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths`
where continent is not null
order by 1,2


--VAX DB
SELECT *
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_vaccinations`

-- Joining
select *
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths` as dea
join `my-first-sandbox-project-jsuth.covid_analysis.covid_vaccinations` as vax
  on dea.location = vax.location
  and dea.date = vax.date

--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(vax.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths` as dea
join `my-first-sandbox-project-jsuth.covid_analysis.covid_vaccinations` as vax
  on dea.location = vax.location
  and dea.date = vax.date
where dea.continent is not null
order by 2,3

-- USE CTE
--PopvsVax = population vs vaccination
With PopvsVax as
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(vax.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths` as dea
join `my-first-sandbox-project-jsuth.covid_analysis.covid_vaccinations` as vax
  on dea.location = vax.location
  and dea.date = vax.date
where dea.continent is not null
)
Select *
From PopvsVax

-- Creating view to store data for later visualizations
Create View `my-first-sandbox-project-jsuth.covid_analysis.PopvsVax` AS

select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, SUM(vax.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM `my-first-sandbox-project-jsuth.covid_analysis.covid_deaths` as dea
join `my-first-sandbox-project-jsuth.covid_analysis.covid_vaccinations` as vax
  on dea.location = vax.location
  and dea.date = vax.date
where dea.continent is not null