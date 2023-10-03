SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;


-- SET NULL values to 0 (zero)
--UPDATE CovidDeaths SET new_cases=0 WHERE new_cases IS NULL;
--UPDATE CovidDeaths SET total_cases=0 WHERE total_cases IS NULL;
--UPDATE CovidDeaths SET total_deaths=0 WHERE total_deaths IS NULL;


-- Total Cases vs Total Deaths in United States
SELECT location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY location, date;


-- Total Cases vs Population in United States
SELECT location, date, population, total_cases, 
(total_cases/population)*100 AS CovidPercentage
FROM CovidDeaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY location, date;


-- Countries with highest infection rate
SELECT location, population, MAX(CAST(total_cases AS INT)) AS HighestInfection, 
MAX((total_cases/population))*100 AS CovidPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY CovidPercentage DESC;


-- Showing Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeath
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeath DESC;


-- Showing Continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeath
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeath DESC;


-- Global Numbers
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS bigint)) AS TotalDeaths, 
SUM(CAST(new_deaths AS bigint)) / SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL;


-- Total Population vs Vaccinations
SELECT CDs.continent, CDs.location, CDs.date, CDs.population, CVs.new_vaccinations,
SUM(CONVERT(bigint, CVs.new_vaccinations)) OVER (PARTITION BY CDs.location ORDER BY CDs.location, CDs.date) AS RollingVaccinated
FROM CovidDeaths CDs
JOIN CovidVaccinations CVs
ON CDs.location = CVs.location AND CDs.date = CVs.date
WHERE CDs.continent IS NOT NULL
ORDER BY location, date;


-- USE CTE
With PopvsVac(continent, location, date, population, new_vaccinations, RollingVaccinated)
AS
(SELECT CDs.continent, CDs.location, CDs.date, CDs.population, CVs.new_vaccinations,
SUM(CONVERT(bigint, CVs.new_vaccinations)) OVER (PARTITION BY CDs.location ORDER BY CDs.location, CDs.date) AS RollingVaccinated
FROM CovidDeaths CDs
JOIN CovidVaccinations CVs
ON CDs.location = CVs.location AND CDs.date = CVs.date
WHERE CDs.continent IS NOT NULL)
SELECT *, (RollingVaccinated/population)*100 AS RollingVaccinationPercentage
FROM PopvsVac;


-- Temp Table
CREATE TABLE #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT CDs.continent, CDs.location, CDs.date, CDs.population, CVs.new_vaccinations,
SUM(CONVERT(bigint, CVs.new_vaccinations)) OVER (PARTITION BY CDs.location ORDER BY CDs.location, CDs.date) AS RollingVaccinated
FROM CovidDeaths CDs
JOIN CovidVaccinations CVs
ON CDs.location = CVs.location AND CDs.date = CVs.date
WHERE CDs.continent IS NOT NULL
ORDER BY location, date

SELECT *
FROM #PercentPopulationVaccinated;



-- Create VIEW to store data for visualization
CREATE VIEW PercentPopulationVaccinated
AS
SELECT CDs.continent, CDs.location, CDs.date, CDs.population, CVs.new_vaccinations,
SUM(CONVERT(bigint, CVs.new_vaccinations)) OVER (PARTITION BY CDs.location ORDER BY CDs.location, CDs.date) AS RollingVaccinated
FROM CovidDeaths CDs
JOIN CovidVaccinations CVs
ON CDs.location = CVs.location AND CDs.date = CVs.date
WHERE CDs.continent IS NOT NULL;

SELECT * FROM PercentPopulationVaccinated;