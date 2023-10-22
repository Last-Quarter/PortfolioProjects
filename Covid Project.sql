SELECT *
From PortfolioProject..CovidDeaths
WHERE continent	is not NULL
Order by location, date

--SELECT *
--From PortfolioProject..CovidVaccinations
--Order by location, date


SELECT location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
WHERE continent	is not NULL
Order by location, date

-- Total Cases vs Population
-- Shows likelihood of dying if you contract covid in US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%State%'
and continent	is not NULL
Order by location, date

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE location like '%State%'
Order by location, date


-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE location like '%State%'
Group by location, population
Order by PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%State%'
WHERE continent	is not NULL
Group by location, population
Order by TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%State%'
WHERE continent	is not NULL
Group by continent
Order by TotalDeathCount DESC


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE location like '%State%'
WHERE continent	is not NULL
--Group by date
Order by total_cases, total_deaths


--Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by 
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac(continent, location, date, population,
New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by 
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac




-- TEMP TABLE

DROP Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by 
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
--WHERE dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by 
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
--Order by 2,3


Select * 
From PercentPopulationVaccinated