SELECT *
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4



--SELECT *
--FROM Covid_Project..CovidVaccination
--WHERE continent IS NOT NULL
--order by 3,4

-- Select data that we are going to use
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2

--Total cases vs Total deaths
--Shows likelyhood of dying if contacted by covid based on countries
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Covid_Project..CovidDeaths
WHERE location like '%bangladesh%' AND continent IS NOT NULL
order by 1,2

--Total cases vs Population
--Shows what percentage of population has gotten Covid
SELECT Location, date, population, total_cases,(total_cases/population)*100 AS Percentage_Population_Infected
FROM Covid_Project..CovidDeaths
--WHERE location like '%bangladesh%'
order by 1,2

--Highest case of Covid on per Country
SELECT Location, population, MAX(total_cases) AS Highest_Infection,MAX((total_cases/population)*100) AS Percentage_Population_Infected
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
order by Percentage_Population_Infected desc

--Highest Death of Covid on per Country
SELECT Location, MAX(CAST (total_deaths as INT)) AS Total_Death_Count
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
order by Total_Death_Count desc


--CONTINENT
--Total death by per Continent
SELECT continent, MAX(CAST (total_deaths as INT)) AS Total_Death_Count
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
order by Total_Death_Count desc

--Global Numbers

SELECT date, SUM(new_cases), SUM(CAST (new_deaths as INT)),SUM(CAST (new_deaths as INT))/SUM(new_cases)*100  AS Death_Percentage
FROM Covid_Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
order by 1,2

--JOIN Covid_Death and Covid_vaccination

SELECT *
FROM Covid_Project..CovidDeaths AS deaths
JOIN Covid_Project..CovidVaccination AS vaccination
	ON deaths.location=vaccination.location
	AND deaths.date=vaccination.date


--Rolling Vaccination Count
SELECT deaths.continent,deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,
SUM(CONVERT(BIGINT, vaccination.new_vaccinations)) 
	OVER (Partition by deaths.location ORDER BY deaths.location,deaths.date)
		AS Rolling_People_Vaccinated
FROM Covid_Project..CovidDeaths AS deaths
JOIN Covid_Project..CovidVaccination AS vaccination
	ON deaths.location=vaccination.location
	AND deaths.date=vaccination.date
WHERE deaths.continent IS NOT NULL
order by 2,3

--USE CTE(Total Population vs New Vaccination)
--In order to use "Rolling_People_Vaccination" column we need to use CTE or creating Temp Table
--We can not use the new column for calculation so we need to use CTE

WITH PopvsVac(continent,location,date,population,new_vaccination,rolling_people_vaccinated)
AS(
SELECT deaths.continent,deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,
SUM(CONVERT(BIGINT, vaccination.new_vaccinations)) 
	OVER (Partition by deaths.location ORDER BY deaths.date)
		AS Rolling_People_Vaccinated
FROM Covid_Project..CovidDeaths AS deaths
JOIN Covid_Project..CovidVaccination AS vaccination
	ON deaths.location=vaccination.location
	AND deaths.date=vaccination.date
WHERE deaths.continent IS NOT NULL
--order by 2,3
)
SELECT *,(Rolling_People_Vaccinated/Population)*100
FROM PopvsVac

--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT deaths.continent,deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,
SUM(CONVERT(BIGINT, vaccination.new_vaccinations)) 
	OVER (Partition by deaths.location ORDER BY deaths.location,deaths.date)
		AS Rolling_People_Vaccinated
FROM Covid_Project..CovidDeaths AS deaths
JOIN Covid_Project..CovidVaccination AS vaccination
	ON deaths.location=vaccination.location
	AND deaths.date=vaccination.date
WHERE deaths.continent IS NOT NULL
order by 2,3

SELECT *,(Rolling_People_Vaccinated/Population)*100
FROM #PercentPopulationVaccinated

USE Covid_Project;
GO

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent,deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations,
SUM(CONVERT(BIGINT, vaccination.new_vaccinations)) 
	OVER (Partition by deaths.location ORDER BY deaths.location,deaths.date)
		AS Rolling_People_Vaccinated
FROM Covid_Project..CovidDeaths AS deaths
JOIN Covid_Project..CovidVaccination AS vaccination
	ON deaths.location=vaccination.location
	AND deaths.date=vaccination.date
WHERE deaths.continent IS NOT NULL
--order by 2,3

--SELECT *
--FROM sys.views
--WHERE name = 'PercentPopulationVaccinated';

--SELECT 
--    DB_NAME() AS DatabaseName,
--    SCHEMA_NAME(schema_id) AS SchemaName,
--    name AS ViewName
--FROM sys.views
--WHERE name = 'PercentPopulationVaccinated';
