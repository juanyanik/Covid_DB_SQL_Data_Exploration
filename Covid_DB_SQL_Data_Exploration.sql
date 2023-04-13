SELECT * 
FROM ProjectPortfolio..CovidDeaths
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
ORDER BY 1,2;

--Percentage of deaths among infected people
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM ProjectPortfolio..CovidDeaths
where location like '%Argentina%'
ORDER BY 1,2;

--Percentage of the population that got infected with Covid
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,4) AS covid_percentage
FROM ProjectPortfolio..CovidDeaths
where location like '%Argentina%'
ORDER BY 1,2;

--Countries ranked by the highest infection count
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 AS covid_percentage
FROM ProjectPortfolio..CovidDeaths
GROUP BY population, location
ORDER BY covid_percentage DESC;

--Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as Int)) AS total_death_count
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC;

SELECT continent, MAX(CAST(total_deaths as Int)) AS total_death_count
FROM ProjectPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC;

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM ProjectPortfolio..CovidDeaths as dea
JOIN ProjectPortfolio..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM ProjectPortfolio..CovidDeaths as dea
where continent is not null 
order by 1,2

-- Using CTE to perform Calculation on Partition By in previous query
WITH popvsvac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM ProjectPortfolio..CovidDeaths as dea
JOIN ProjectPortfolio..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (rolling_people_vaccinated/population)*100 
FROM popvsvac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM ProjectPortfolio..CovidDeaths as dea
JOIN ProjectPortfolio..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM ProjectPortfolio..CovidDeaths as dea
JOIN ProjectPortfolio..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

