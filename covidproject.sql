select *
From PortfolioProject..coviddeaths
order by 3,4

select *
From PortfolioProject..covidvac
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths
order by 1,2

--looking at total cases vs total deaths
--show the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProject..coviddeaths
where location like '%states%'
order by 1,2

--looking at the total cases vs the population

select location, date, total_cases, population, (total_cases/population)*100 as infectionrate
From PortfolioProject..coviddeaths
where location like '%states%'
order by 1,2

--looking at countries with the highest infection rate compared to population

select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentpopulationinfected
From PortfolioProject..coviddeaths
--where location like '%states%'
group by location, population
order by percentpopulationinfected desc

--showing the countries with the highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
From PortfolioProject..coviddeaths
where continent is not null
group by location, population
order by totaldeathcount desc

--broken down by continent

select location, max(cast(total_deaths as int)) as totaldeathcount
From PortfolioProject..coviddeaths
where continent is null
group by location
order by totaldeathcount desc

--showing contintents with the highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
where continent is not null
group by continent
order by totaldeathcount desc

-- global numbers per day

select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..coviddeaths
where continent is not null
group by date
order by 1,2

--total global numbers

select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..coviddeaths
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinationnumber
from PortfolioProject..covidvac vac
join portfolioproject..coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with popvsvac (continent, location, date, population, new_vaccinations, rollingvaccinationnumber)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinationnumber
from PortfolioProject..covidvac vac
join portfolioproject..coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (rollingvaccinationnumber/population)*100
From popvsvac


-- temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinationnumber numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinationnumber
from PortfolioProject..covidvac vac
join portfolioproject..coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (rollingvaccinationnumber/population)*100
from #percentpopulationvaccinated


-- creating view to store data for later visualization

Create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvac vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *
from percentpopulationvaccinated