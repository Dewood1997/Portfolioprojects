SELECT *
FROM ProjectPortfolio1..Covid#Deaths
where continent is not null
Order by 3, 4

SELECT *
FROM ProjectPortfolio1..Covid#Vaccinations
Order by 3, 4

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio1..Covid#Deaths
where continent is not null
Order by 1,2

--Looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
FROM ProjectPortfolio1..Covid#Deaths
where continent is not null
Order by 1,2

--Looking at total cases vs total deaths in USA
--This shows the likelyhood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
FROM ProjectPortfolio1..Covid#Deaths
WHERE location like '%states%' and
continent is not null
Order by 1,2

--Looking at total cases vs total deaths in Lebanon
--This shows the likelyhood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
FROM ProjectPortfolio1..Covid#Deaths
WHERE location like '%Lebanon%'
Order by 1,2

--Looking at total cases vs Population
--Shows what % of population got Covid

SELECT location, date, population , total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM ProjectPortfolio1..Covid#Deaths
WHERE location like '%Lebanon%'
Order by 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population , Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
FROM ProjectPortfolio1..Covid#Deaths
--WHERE location like '%Lebanon%'
GROUP BY location, population
Order by  PercentagePopulationInfected desc

--Showing countries with Highest Death Count per Population  
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio1..Covid#Deaths
where continent is not null
GROUP BY location
Order by  TotalDeathCount desc

--Let’s break things down by continent

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio1..Covid#Deaths
where continent is not null
GROUP BY continent
Order by  TotalDeathCount desc

--Let’s break things down by continent | fixed

SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio1..Covid#Deaths
where continent is not null
GROUP BY location
Order by  TotalDeathCount desc

--Showing continents with the highest death count per population

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM ProjectPortfolio1..Covid#Deaths
where continent is not null
GROUP BY continent
Order by  TotalDeathCount desc

--Global Numbers

SELECT date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/ Sum(New_Cases)*100 as DeathPercentage
FROM ProjectPortfolio1..Covid#Deaths
Where continent is not null
group by date
Order by 1,2

--Global Numbers without date grouping

SELECT Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/ Sum(New_Cases)*100 as DeathPercentage
FROM ProjectPortfolio1..Covid#Deaths
Where continent is not null
--group by date
Order by 1,2

--CovidVaccinations

Select *
From ProjectPortfolio1..Covid#Vaccinations

--Joining the tables together 
Select *
From ProjectPortfolio1..Covid#Deaths as dea
Join  ProjectPortfolio1..Covid#Vaccinations as vac
      ON dea.location= vac.location
	  and dea.date= vac.date

--Looking at total Population vs Vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From ProjectPortfolio1..Covid#Deaths as dea
Join  ProjectPortfolio1..Covid#Vaccinations as vac
      ON dea.location= vac.location
	  and dea.date= vac.date
Where dea.continent is not null
Order by 2,3

--Looking at total Population vs Vaccination with partition

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100

From  ProjectPortfolio1..Covid#Deaths as dea
Join  ProjectPortfolio1..Covid#Vaccinations as  vac
      ON dea.location= vac.location
	  and dea.date= vac.date
Where dea.continent is not null
Order by 2,3

--Use CTE

with PopvsVac(contitent, location, date, popiulation, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100

From  ProjectPortfolio1..Covid#Deaths as dea
Join  ProjectPortfolio1..Covid#Vaccinations as  vac
      ON dea.location= vac.location
	  and dea.date= vac.date
Where dea.continent is not null
--Order by 2,3
)
SELECT *, (RollingPeopleVaccinated/popiulation)*100
FROM PopvsVac

--TEMP TABLE 

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100

From  ProjectPortfolio1..Covid#Deaths as dea
Join  ProjectPortfolio1..Covid#Vaccinations as  vac
      ON dea.location= vac.location
	  and dea.date= vac.date
--Where dea.continent is not null
--Order by 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100

From  ProjectPortfolio1..Covid#Deaths as dea
Join  ProjectPortfolio1..Covid#Vaccinations as  vac
      ON dea.location= vac.location
	  and dea.date= vac.date
Where dea.continent is not null
--Order by 2,3

--Query view
Select *
From PercentPopulationVaccinated