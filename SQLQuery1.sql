select * 
from PortfolioProject1..CovidDeaths
order by 3,4 asc;

Select * from PortfolioProject1..CovidVaccination
order by 3,4;

--select data for deaths tables;

Select location, date, total_cases,new_cases,total_deaths,population
from PortfolioProject1..CovidDeaths
order by 1,2 asc;

--total cases vs total deaths

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
where location like '%china%'
order by 1,2 asc;

--total cases vs population

select location, date, total_cases, population, (total_deaths/population)*100 as PercentpopulationInfected
from PortfolioProject1..CovidDeaths
--where location like '%china%'
order by 1,2 asc;

--countries with highest infection rate 
select location,population,max(total_cases) as highest_count,max((total_cases/population)*100) as PercentpopulationInfected
from PortfolioProject1..CovidDeaths
group by location,population
order by PercentpopulationInfected desc;

select continent, max(cast(total_deaths as int)) as total_deaths 
from PortfolioProject1..CovidDeaths
where continent is not null
group by continent
order by total_deaths desc;

--global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases)*100)  as Death_percentage 
from PortfolioProject1..CovidDeaths
where continent is not null
--group by date
--order by date;


--very important query of partiton along with CTE
with popvsvac(continent, location, date, population, new_vaccination, SumOfVaccination)
as(
select d.continent,d.location,d.date,d.population,v.new_vaccinations, 
sum(v.new_vaccinations) over(partition by d.location order by d.location,d.date) as SumOfVaccination
from PortfolioProject1..CovidVaccination v
join PortfolioProject1..CovidDeaths d
on v.location=d.location and v.date=d.date
where d.continent is not null
--order by 2,3; // order by is not used with CTE(common table expression)
)
select *,(SumOfVaccination/population)*100 as RollingPercentageVac
from popvsvac;


--Above Query using Temp Table
Drop table if exists PercentPopulationVac
Create table PercentPopulationVac(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_Vaccination numeric,
SumOfVaccination numeric)

Insert into PercentPopulationVac
select d.continent,d.location,d.date,d.population,v.new_vaccinations, 
sum(v.new_vaccinations) over(partition by d.location order by d.location,d.date) as SumOfVaccination
from PortfolioProject1..CovidVaccination v
join PortfolioProject1..CovidDeaths d
on v.location=d.location and v.date=d.date
where d.continent is not null
--order by 2,3;

Select * ,(SumOfVaccination/population)*100 as RollingPercentageVac
from PercentPopulationVac;

--Creating Views
Create view PopulationVaccinated as
select d.continent,d.location,d.date,d.population,v.new_vaccinations, 
sum(v.new_vaccinations) over(partition by d.location order by d.location,d.date) as SumOfVaccination
from PortfolioProject1..CovidVaccination v
join PortfolioProject1..CovidDeaths d
on v.location=d.location and v.date=d.date
where d.continent is not null;
--order by 2,3;

Select * from PopulationVaccinated;