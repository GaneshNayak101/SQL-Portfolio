use demo; 

select * from covid_vaccination;

select * from covid_deaths;

-- change total_death column from varchar to int
update covid_deaths
set total_deaths = '0' 
where trim(total_deaths) = '' ; 

alter table covid_deaths
modify column total_deaths int(20) ; 


-- change new_vaccinations column from varchar to int
update covid_vaccination
set new_vaccinations = '0' 
where trim(new_vaccinations) = '' ; 

alter table covid_vaccination
modify column new_vaccinations int(20) ; 


-- select data that we need from covid deaths
select location, date, total_cases, population, total_deaths
from covid_deaths ;

-- 1. Infection rate in each country
create view infection_rate as
select location, max(population) as total_population  , max(total_cases) as total_infected, (max(total_cases) / max(population)) *100 as infection_rate
from covid_deaths
where trim(continent) != '' 
group by location
order by infection_rate desc; 


-- 2. Mortality rate in each country
select location, max(total_deaths) as total_death_count  , max(total_cases) as total_infected, (max(total_deaths) / max(total_cases)) *100 as death_rate
from covid_deaths
where continent is not null
group by location
order by death_rate desc; 


-- 3. Mortality rate in each Continent
select location, max(total_deaths) as total_death_count  , max(total_cases) as total_infected, (max(total_deaths) / max(total_cases)) *100 as death_rate
from covid_deaths
where trim(continent) = ''
group by location
order by death_rate desc; 

-- 4. Death rate ( what percentage of total population died due to covid) for each continent
select location, max(total_deaths) as total_death_count  , max(population) as total_population, (max(total_deaths) / max(population)) *100 as death_rate
from covid_deaths
where trim(continent) = ''
group by location
order by death_rate desc; 

-- 5. Global numbers 
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths) / sum(new_cases))*100 as mortality_rate
from covid_deaths
where trim(continent) != '' ;

-- 6. Vaccinated percentage country wise
with cte as 
(
	select d.continent, d.location, d.date, d.population,
	sum(v.new_vaccinations) over( partition by d.location order by d.location, d.date ) as rolling_sum_vaccination

	from covid_deaths as d inner join covid_vaccination as v
	on d.location = v.location and d.date = v.date
)

select location, max(population) as total_population, 
max(rolling_sum_vaccination) as total_vaccinated, 
( max(rolling_sum_vaccination)  / max(population)) *100 as vaccination_percentage

from cte
group by location
order by vaccination_percentage desc; 