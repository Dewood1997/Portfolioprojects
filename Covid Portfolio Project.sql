Select *
From Portfolio_Project.dbo.Covid_Deaths$
where continent is not null
Order by 3,4


--Select *
--From Portfolio_Project.dbo.Covid_Vaccinations$
--Order by 3,4

--Select Data that we are gonna be using

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project.dbo.Covid_Deaths$
where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths
--It shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project.dbo.Covid_Deaths$
Where location like '%Lebanon%' and continent is not null
Order by 1,2


--Looking at Total Cases vs Population
--It shows what percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio_Project.dbo.Covid_Deaths$
--Where location like '%Lebanon%' and continent is not null
Order by 1,2


--Looking at Countries with Highest Infection Rate Compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_Project.dbo.Covid_Deaths$
--Where location like '%Lebanon%' and continent is not null
Group by location, population
Order by PercentPopulationInfected desc


--Showing the countries with Highest Death Count Per Population


Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project.dbo.Covid_Deaths$
--Where location like '%Lebanon%'
where continent is not null
Group by location
Order by TotalDeathCount desc


--Let's break things down by continent


Select continent, Max(cast(total_deaths as bigint)) as TotalDeathCount
From Portfolio_Project.dbo.Covid_Deaths$
--Where location like '%Lebanon%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--More accurate by continent

Select location, Max(cast(total_deaths as bigint)) as TotalDeathCount
From Portfolio_Project.dbo.Covid_Deaths$
--Where location like '%Lebanon%'
where continent is null
Group by location
Order by TotalDeathCount desc

--Showing the continent with highest death count per population

Select continent, Max(cast(total_deaths as bigint)) as TotalDeathCount
From Portfolio_Project.dbo.Covid_Deaths$
--Where location like '%Lebanon%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project.dbo.Covid_Deaths$
--Where location like '%Lebanon%' 
Where continent is not null
Group by date
Order by 1,2

--If date is removed

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project.dbo.Covid_Deaths$
--Where location like '%Lebanon%' 
Where continent is not null
--Group by date
Order by 1,2

--looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Deaths$ dea
Join Portfolio_Project..Covid_Vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--USE CTE
with PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Deaths$ dea
Join Portfolio_Project..Covid_Vaccinations$ vac
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

)
Select* , (RollingPeopleVaccinated/population)*100
From PopvsVac



--TEMP TABLE

Drop Table if exists #PercentpopulationVaccianted
Create Table #PercentpopulationVaccianted
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccianted  numeric
)
insert into #PercentpopulationVaccianted

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Deaths$ dea
Join Portfolio_Project..Covid_Vaccinations$ vac
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
Select* ,(RollingPeopleVaccianted/population)*100
From #PercentpopulationVaccianted

--Create View to store data for later visualizations
go 
CREATE VIEW PercentpopulationVaccianted
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..Covid_Deaths$ dea
Join Portfolio_Project..Covid_Vaccinations$ vac
    on dea.location = vac.location
    and dea.date = vac.date
Where dea.continent is not null
go
--order by 2,3

Select *
From PercentpopulationVaccianted