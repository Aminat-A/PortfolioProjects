-- Covid 19 Data Exploration
-- Some of the skills used include: Joins,CTE's, Temp Table, Windows Function,Aggregate Funtion, Coverting Data Types and Creating Views. 
-- NOTE: I seperated the into two coviddeaths and covidvaccination

SELECT *
 FROM `Portfolio Project`.coviddeaths
  ORDER by 3,4;

 SELECT*
FROM `Portfolio Project`.coviddeaths
WHERE continent is not null
ORDER by 3,4;
  

-- Now we are going to be selecting the data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
 FROM `Portfolio Project`.coviddeaths
 ORDER BY 1,2;
 
-- Checking Total Cases vs Total Deaths in each country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM `Portfolio Project`.coviddeaths
 ORDER BY 1,2;
 
 
-- Total Cases vs Total Deaths in canada

 SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM `Portfolio Project`.coviddeaths 
 WHERE location like '%canada%'
 ORDER by 1,2;
 
-- Total Cases vs Popolation. This shows what percentage got covid in CANADA.

 SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
 FROM `Portfolio Project`.coviddeaths 
 -- WHERE location like '%canada%'
 ORDER by 1,2;
 
-- Looking at countries with Hightest Covid Rate compared to Population 
 
 SELECT location, population, MAX(total_cases)AS HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
 FROM `Portfolio Project`.coviddeaths 
 -- WHERE location like '%canada%'
 GROUP BY location, population
 ORDER by PercentPopulationInfected DESC;
 
 -- Showing countries with the Highest Death Count Per Population
 
  SELECT location, MAX(total_deaths) AS TotalDeathCount
 FROM `Portfolio Project`.coviddeaths
  -- WHERE location like '%canada%'
 WHERE continent is not null
 GROUP BY location
 ORDER by TotalDeathCount DESC;
 
 
 -- WE ARE GOING TO BREAK THINGS DOWN BY CONTINENT
 -- SHOWING CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION
 
 SELECT continent, MAX(total_deaths) AS TotalDeathCount
 FROM `Portfolio Project`.coviddeaths
 -- WHERE location like '%canada%'
 WHERE continent is not null
 GROUP BY continent
 ORDER by TotalDeathCount DESC;
 

 -- LOOKING AT THE COVID VACCINATION TABLE
 
 SELECT *
 FROM `Portfolio Project`.coviddeaths dea
 JOIN `Portfolio Project`.covidvaccination vac
 ON dea.location = vac.location
 and dea.date = vac.date;
 
 -- LOOKING AT TOTAL POPULATION VS VACCINATION
 
 SELECT dea . continent, dea . location, dea . date, dea . population, vac . new_vaccinations
 FROM `Portfolio Project`.coviddeaths dea
 JOIN `Portfolio Project`.covidvaccination vac
 ON dea.location = vac.location
 and dea . date = vac . date
  WHERE dea . continent is not null
  ORDER by 2,3;
  
  
   SELECT  dea . continent, dea . location, dea . date, dea . population, vac . new_vaccinations,
   SUM( vac . new_vaccinations ) OVER ( partition by dea . location)
 FROM `Portfolio Project`.coviddeaths dea
 JOIN `Portfolio Project`.covidvaccination vac
 ON dea.location = vac.location
 and dea . date = vac . date
  WHERE dea . continent is not null
  ORDER by 2,3;
  
  -- LOOKING AT NUMBER OF PEOPLE VACCINATED
 
   SELECT  dea . continent, dea . location, dea . date, dea . population, vac . new_vaccinations,
   SUM( vac . new_vaccinations ) OVER ( partition by dea . location order by dea . location,
   dea . date) as RollingPeopleVaccinated
 FROM `Portfolio Project`.coviddeaths dea
 JOIN `Portfolio Project`.covidvaccination vac
 ON dea.location = vac.location
 and dea . date = vac . date
  WHERE dea . continent is not null
  ORDER by 2,3;
  
  
  -- USE CTE to perform Calculation on Partition By in previous query.
  
  WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
  as
  (
  SELECT  dea . continent, dea . location, dea . date, dea . population, vac . new_vaccinations,
   SUM( vac . new_vaccinations ) OVER ( partition by dea . location order by dea . location,
   dea . date) as RollingPeopleVaccinated
  -- (RollingPeopleVaccinated/population)*100
 FROM `Portfolio Project`.coviddeaths dea
 JOIN `Portfolio Project`.covidvaccination vac
 ON dea.location = vac.location
 and dea . date = vac . date
  WHERE dea . continent is not null
  -- ORDER by 2,3
  )
  select * ,(RollingPeopleVaccinated/population)*100
  FROM PopvsVac


  -- creating a Temporary Table to perform Calculation on Partition By in previous query
  
Create Table PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea . population, vac . new_vaccinations
, SUM(vac . new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 


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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

 
 -- DROP TABLE
 
 Drop Table if exists #PercentPopulationVaccinated
 create Table #PercentPopulationVaccinated
  (
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
  )
  INSERT into #PercentPopulationVaccinated
  SELECT  dea . continent, dea . location, dea . date, dea . population, vac . new_vaccinations,
   SUM( vac . new_vaccinations ) OVER ( partition by dea . location order by dea . location,
   dea . date) as RollingPeopleVaccinated
  -- (RollingPeopleVaccinated/population)*100
 FROM `Portfolio Project`.coviddeaths dea
 JOIN `Portfolio Project`.covidvaccination vac
 ON dea.location = vac.location
 and dea . date = vac . date
 -- WHERE dea . continent is not null
  -- ORDER by 2,3

  SELECT * , (RollingPeopleVaccinated/population)*100
  FROM #PercentPopulationVaccinated
  
  

-- Creating View to store data for visualization

CREATE VIEW PercentPopulationVaccinated as
   SELECT  dea . continent, dea . location, dea . date, dea . population, vac . new_vaccinations,
   SUM( vac . new_vaccinations ) OVER ( partition by dea . location order by dea . location,
   dea . date) as RollingPeopleVaccinated
    -- (RollingPeopleVaccinated/population)*100
 FROM `Portfolio Project`.coviddeaths dea
 JOIN `Portfolio Project`.covidvaccination vac
 ON dea.location = vac.location
 and dea . date = vac . date
  WHERE dea . continent is not null

CREATE VIEW PercentPopulationVaccinated as
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
 FROM `Portfolio Project`.coviddeaths 
 -- WHERE location like '%canada%'
 -- ORDER by 1,2













 
 
 
 
 
 