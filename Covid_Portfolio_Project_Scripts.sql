SELECT *
FROM   PortfolioProject..CovidDeaths
--Where continent is not null
ORDER BY 3,4 

SELECT *
FROM   PortfolioProject..CovidVaccinations
Where continent is not null
ORDER BY 3,4 

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage  
FROM   PortfolioProject..CovidDeaths
WHERE  location like '%states%'
and    continent is not null
Order by 1,2

-- Total Cases vs Population
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected  
FROM   PortfolioProject..CovidDeaths
WHERE  location like '%states%'
and    continent is not null
Order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected  
FROM   PortfolioProject..CovidDeaths
--WHERE  location like '%states%'
Where continent is not null
Group by location, population
Order by PercentPopulationInfected Desc

-- Countries with Highest Death Count per Population
Select location, population, MAX(CAST(total_deaths as int)) TotalDeathCount
FROM   PortfolioProject..CovidDeaths
--WHERE  location like '%states%'
Where continent is not null
Group by location, population
Order by TotalDeathCount Desc

-- Locations with Highest Death Count
Select location, MAX(CAST(total_deaths as int)) TotalDeathCount
FROM   PortfolioProject..CovidDeaths
--WHERE  location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount Desc

-- Continents with Highest Death Count
Select continent, MAX(CAST(total_deaths as int)) TotalDeathCount
FROM   PortfolioProject..CovidDeaths
--WHERE  location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount Desc

-- Global Death Percentage
SELECT SUM(new_cases) Total_Cases, SUM(CAST(new_deaths as int)) Total_Deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as Death_Percentage  
FROM   PortfolioProject..CovidDeaths
Where  continent is not null
Order by 1,2

-- Total Population vs Vaccinations (Using Common Table Expressions CTE)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From   PortfolioProject..CovidDeaths       dea
Join   PortfolioProject..CovidVaccinations vac
On     dea.location = vac.location
and    dea.date     = vac.date
Where  dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

-- -- Total Population vs Vaccinations (Using Temp Table)
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent               nvarchar(255),
Location			    nvarchar(255),
Date			        datetime,
Population			    numeric,
New_Vaccinations        numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From   PortfolioProject..CovidDeaths       dea
Join   PortfolioProject..CovidVaccinations vac
On     dea.location = vac.location
and    dea.date     = vac.date
Where  dea.continent is not null
Select *,(RollingPeopleVaccinated/Population)*100
From   #PercentPopulationVaccinated
Order By 2,3

-- -- Total Population vs Vaccinations (Using View)
Create or Alter View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From   PortfolioProject..CovidDeaths       dea
Join   PortfolioProject..CovidVaccinations vac
On     dea.location = vac.location
and    dea.date     = vac.date
Where  dea.continent is not null

Select *
From   PercentPopulationVaccinated
