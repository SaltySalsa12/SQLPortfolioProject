Select location, sum(new_deaths)
from PortfolioProject..CovidDeaths
where date = '2020-01-05 00:00:00.000' and continent is not null
group by location
order by 1,2



--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select the data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--looking at total cases vs total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location = 'United States'
order by 1,2

--Looking at Total Cases Vs Total Deaths
--Shows Liklihood of death if covid is contracted

Select location, date, total_cases, total_deaths, (cast(total_deaths as int)/cast(total_cases as int))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths$
Where location = 'Canada'
order by 1,2

--looking at Total Cases Vs Population
--Shows what percentage of people got COVID

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where location = 'Canada'
order by 1,2

--Looking at countries with highest infection rate compared to its population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
group by population, location
order by PercentPopulationInfected desc

--showing the countries with the highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not Null 
group by location
order by TotalDeathCount desc

--breaking things down by continents
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not Null 
group by continent
order by TotalDeathCount desc

--breaking down things by location where continent value is null
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is Null 
group by location
order by TotalDeathCount desc

Select date, sum(new_cases) as TotalCases, SUM(cast(new_deaths as float)) as TotalDeath, sum(cast(isnull(new_deaths, 0) as int))/sum(convert(float,new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
group by date
order by 1,2

--This operation is the same as last but here we check the total percentage of deaths over the course of 4 years and the total cases in the same time frame
Select sum(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and new_deaths is not null and new_cases is not null
order by 1,2

--looking at Total Population vs Vaccinations (what is the total number of people in the world that is vaccinated?)

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using Partition By clause to show daily sum of vaccinations per day and showing a total on the partition column
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccNumbers
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--To actually show the total population vs vaccinations, we need to create either a temp table or CTE to perform calculations based on the temp columns we create\
--With CTE
With popvsvac (continent, location, date, population, new_vaccinations, RollingVaccNumbers) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccNumbers
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * --the "*" here selects all the columns in the CTE we created and not the ACTUAL two tables we have
, (RollingVaccNumbers/population)*100 as PercentVaccinated
From popvsvac
order by 2,3

--Temp Table

Drop table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccNumbers numeric
)
Insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccNumbers
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * --the "*" here selects all the columns in the CTE we created and not the ACTUAL two tables we have
, (RollingVaccNumbers/population)*100 as PercentVaccinated
From #PercentPeopleVaccinated
order by 2,3


--Creating View for Visualisation
Create view PercentPeopleVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccNumbers
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * 
from PercentPeopleVaccinated