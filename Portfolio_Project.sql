select * from coviddeaths order by 3,4
select * from covidvaccinations order by 3,4

select location, date, total_cases, new_cases, total_deaths, population from coviddeaths order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths*100.0)/total_cases as DeathPercentage from coviddeaths 
where location like '%India%' and continent is not null
order by 1,2

--Total Cases Vs Population- Show what percentage of people got Covid
select location, Date, population, total_cases, (total_cases *100.00)/Population as InfectionRate 
from CovidDeaths 
where location like '%India%' and continent is not null
order by 1,2

--Countries with high infection rate
select location,population, max(total_cases) as  HighestInfectionCount, max(total_cases*100.00/Population) as HighInfectionRate
from CovidDeaths where continent is not null
group by location, Population
order by 4 DESC

--Showing countries with Highest death Count per population

select location,max(total_deaths) as HighDeathCount from CovidDeaths
where continent is not null
group by location
order by HighDeathCount desc



--showing continent with Highest death count
select continent, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathCount desc

--Global Numbers
select date,sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(New_deaths)*100.00/sum(new_cases) as DeathRate
--avg(total_cases) AverageTotalCases , avg(total_deaths) AverageTotalDeaths
from CovidDeaths
where continent is not null
group by date
order by 1,2 Desc


--Covid Vaccinations
Select * from CovidVaccinations

--Join 2 tables
select * from CovidDeaths d join CovidVaccinations v on d.[date]=v.[date] and d.[location]=v.[location] where d.continent is not null

--Total population and vaccination
select  d.continent,d.location, d.date, d.Population, v.new_vaccinations, sum(new_vaccinations) over (partition by d.location order by d.location,d.date) RollingPeopleVaccinated
from CovidDeaths d join CovidVaccinations v on d.[date]=v.[date] and d.[location]=v.[location] 
where d.continent is not null
order by 2,3

--Use CTE
with PopvsVac (continent, location,Date, population, New_vaccinations, RollingPeopleVaccinated) as 
(select  d.continent, d.location, d.date, d.Population, v.new_vaccinations, sum(new_vaccinations) over (partition by d.location order by d.location,d.date) RollingPeopleVaccinated
from CovidDeaths d join CovidVaccinations v on d.[date]=v.[date] and d.[location]=v.[location] 
where d.continent is not null)
--select *, (RollingPeopleVaccinated*100.00/population) as VaccinationRate from PopvsVac 
select  location, max(RollingPeopleVaccinated*100.00/population) as VaccinationRate from PopvsVac group by location


--Use Temp table
drop table if exists #percentPopulationVaccinated
create table #PercentPopulationVaccinated(
    continent nvarchar(255),
    location nvarchar(255),
    date datetime, 
    Population numeric, 
    new_vaccinations numeric, 
    RollingPeopleVaccinated numeric

)
insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.Population, v.new_vaccinations, sum(new_vaccinations) over (partition by d.location order by d.location,d.date) RollingPeopleVaccinated
from CovidDeaths d join CovidVaccinations v on d.[date]=v.[date] and d.[location]=v.[location] 
where d.continent is not null

select *,(RollingPeopleVaccinated*100.00)/Population as VaccRate from #PercentPopulationVaccinated


--Data type of column
select column_Name, DATA_TYPE from PortfolioProject.INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='CovidDeaths'
--Cast: cast(columnName)

--Create view to store data for later visualisation
create view PercentPopulationVaccinated as 
select d.continent, d.location, d.date, d.Population, v.new_vaccinations, sum(new_vaccinations) over (partition by d.location order by d.location,d.date) RollingPeopleVaccinated
from CovidDeaths d join CovidVaccinations v on d.[date]=v.[date] and d.[location]=v.[location] 
where d.continent is not null