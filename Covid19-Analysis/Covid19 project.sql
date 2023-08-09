-- Intoduction:
-- In the wake of the unprecedented global pandemic caused by the novel coronavirus (COVID-19), data-driven insights have 
-- become invaluable tools in understanding the complex dynamics of the virus's spread and impact. This project endeavors 
-- to harness the power of SQL (Structured Query Language) to delve into the intricate world of COVID-19 data analysis. 
-- By leveraging the wealth of information available, ranging from infection rates and testing efforts to vaccination 
-- progress and mortality figures, this project aims to uncover patterns, trends, and correlations that shed light on 
-- the virus's progression and its influence on societies worldwide. Through careful database design, precise querying, 
-- and insightful visualization, this endeavor seeks to contribute to our understanding of the pandemic's effects, 
-- ultimately aiding in decision-making, resource allocation, and public health strategies.


-- 1. Since we have imported date column as a VARCHAR, we need to convert this column into 'DATE' type
SELECT * FROM Covid.coviddeaths;

UPDATE Covid.coviddeaths SET date = STR_TO_DATE(date, '%Y-%m-%d');
ALTER TABLE Covid.coviddeaths CHANGE COLUMN date date DATE;

SELECT * FROM Covid.covidvaccinations;

UPDATE Covid.covidvaccinations SET date = STR_TO_DATE(date, '%Y-%m-%d');
ALTER TABLE Covid.covidvaccinations CHANGE COLUMN date date DATE;

-- 2. There seem to be some error in the data, for data above date 5/25/2023, total_cases, total_deaths are not existant
-- so we delete those rows with date>=5/25/2023

SELECT * FROM Covid.coviddeaths WHERE date>="2023-05-25";

DELETE FROM Covid.coviddeaths WHERE date>="2023-05-25";

SELECT * FROM Covid.covidvaccinations WHERE date>="2023-05-25";

DELETE FROM Covid.covidvaccinations WHERE date>="2023-05-25";

-- 3. Return the first 5 rows of CovidDeaths Table
SELECT * FROM Covid.coviddeaths
LIMIT 5;

-- 4. Return the first 5 rows of CovidVaccinations Table
SELECT * FROM Covid.covidvaccinations
LIMIT 5;

-- 5. Lets take a look at total cases and total deaths for all countries
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid.coviddeaths
ORDER BY 1,2;


-- 6. Top 20 countries with highest number of cases
SELECT location AS Country, MAX(total_cases) AS Total_cases, MAX(total_deaths) AS Total_deaths
FROM Covid.coviddeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY 2 DESC
LIMIT 20;

-- 7. Top 20 countries with highest number of deaths
SELECT c.location AS Country, MAX(c.total_cases) AS Total_cases, MAX(c.total_deaths) AS Total_deaths
FROM Covid.coviddeaths c
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 3 DESC
LIMIT 20;


SELECT continent,location, MAX(total_deaths) AS TotalDeathCount
FROM Covid.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent,location
ORDER BY 1 ASC,3 DESC;

-- 8. Total deaths vs total cases
-- Daily Likelihood of dying if you contact covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid.coviddeaths
WHERE location = "India"
ORDER BY 1,2;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid.coviddeaths
WHERE location = "United States"
ORDER BY 1,2;


-- Likelihood of dying if you contact covid in all countries
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid.coviddeaths
WHERE date="2023-05-24" AND 
continent IS NOT NULL
-- location NOT IN ("World","High income",'Upper middle income','Europe','Asia','North America','South America','Lower middle income')
ORDER BY 4 DESC,5 DESC;

-- another way to do it

SELECT location, MAX(date) AS LastDate, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 
(SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM Covid.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 4 DESC,5 DESC;


-- 9. Total cases vs population
-- 9.1 Shows what percentage of population got covid in United states

SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasesPercentage
FROM Covid.coviddeaths
WHERE location = "United States"
ORDER BY 1,2;

-- 9.2 Shows what percentage of population got covid in all countries
SELECT location, total_cases, population, (total_cases/population)*100 AS CasesPercentage
FROM Covid.coviddeaths
WHERE date="2023-05-24" AND 
continent IS NOT NULL
-- location NOT IN ("World","High income",'Upper middle income','Europe','Asia','North America','South America','Lower middle income')
ORDER BY 4 DESC;


-- 9.2 Looking at countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid.coviddeaths
-- WHERE location = "United States" 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- another way to do it

SELECT location, population, SUM(new_cases) AS HighestInfectionCount, 
       (SUM(new_cases)/MAX(population))*100 AS PercentPopulationInfected
FROM Covid.coviddeaths
-- WHERE location = "United States" 
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- 10. Create View for looking at countries with Highest Death Count 

CREATE VIEW DeathCount AS
SELECT location, SUM(new_deaths) AS TotalDeaths
FROM Covid.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- Total deaths all over the world

SELECT location, MAX(date) AS LastDate, SUM(new_deaths) AS TotalDeaths
FROM Covid.coviddeaths
WHERE location='world'
GROUP BY location;

-- 11 Looking at continents with Highest Death Count 
SELECT distinct continent FROM Covid.coviddeaths WHERE continent IS NOT NULL;

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM Covid.coviddeaths
WHERE continent IS NULL
AND location IN (SELECT DISTINCT continent FROM Covid.coviddeaths)
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Create View for looking at countires with highest covid cases

CREATE VIEW CasesCount AS
SELECT location, SUM(new_cases) AS TotalCases
FROM Covid.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- GLOBAL NUMBERS

-- Total cases all over the world

SELECT location, MAX(date) AS LastDate, SUM(new_cases) AS TotalCases
FROM Covid.coviddeaths
WHERE location='world'
GROUP BY location;

SELECT date, SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS New_Deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM Covid.coviddeaths 
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Joining coviddeaths and covidvaccinations tables for overall inspection
 SELECT *
 FROM Covid.coviddeaths dea
 JOIN Covid.covidvaccinations vac
 ON dea.location=vac.location
 AND dea.date=vac.date;
 
 -- Total vaccinations vs population using joined tables
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Covid.coviddeaths dea
JOIN Covid.covidvaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;
 
 
 -- USING "CTE" to calculate rolling sum of people vaccinated
 
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS( 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Covid.coviddeaths dea
JOIN Covid.covidvaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM PopvsVac
ORDER BY 1,2,3;
 
 
 
 -- Creating Temporary table to store the rolling sum people vaccinated metric for future use
 
 DROP TABLE IF EXISTS Percent_People_Vaccinated;
 CREATE TABLE Percent_People_Vaccinated(
 Continent text,
 Location text,
 Date date,
 Population bigint,
 New_vaccinations bigint,
 RollingPeopleVaccinated bigint
 );
 
INSERT INTO Percent_People_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Covid.coviddeaths dea
JOIN Covid.covidvaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL;
 
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPeopleVaccinated
FROM Percent_People_Vaccinated
ORDER BY 1,2,3;
 
 
 -- creating view to store data for later visulizations

use Covid;

CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL;
 
-- Deep dive into United States covid cases and deaths
SELECT location, date, new_cases, new_deaths, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid.coviddeaths
WHERE location = "United States"
ORDER BY 2;

-- Average cases and deaths from 2020-2022
SELECT AVG(new_cases), AVG(new_deaths)
FROM Covid.coviddeaths; 

-- Average cases and deaths from 2020
SELECT AVG(new_cases), AVG(new_deaths)
FROM Covid.coviddeaths
WHERE date BETWEEN '2020-01-01' AND '2020-12-31'; 

-- Average cases and deaths from 2021
SELECT AVG(new_cases), AVG(new_deaths)
FROM Covid.coviddeaths
WHERE date BETWEEN '2021-01-01' AND '2021-12-31'; 

-- Average cases and deaths from 2022
SELECT AVG(new_cases), AVG(new_deaths)
FROM Covid.coviddeaths
WHERE date BETWEEN '2022-01-01' AND '2022-12-31'; 


SELECT dea.location, dea.date, dea.new_cases, dea.new_deaths, dea.total_cases, dea.total_deaths, 
vac.new_vaccinations, vac.people_vaccinated, vac.total_vaccinations
FROM Covid.coviddeaths dea
INNER JOIN Covid.covidvaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.location='United States';
 

-- Conclusion:
-- We can observe that covid 19 virus had a significant impact on the world, infecting 766,917,644 people and causing death
-- to nearly 7 million people! That's a death percentage of ~1% of infected people. This is truly an devastaing number of people 
-- who have died. 

-- This is result of governments all over the world who have not made correct investment in bettering hospitals, number of beds, 
-- oxygen cylinders and had no responsive plan to combat pandemic's like Covid 19. This shows how ill prepared we as a species are 
-- and in future if more life threatneing virus emerges we need to be better prepared. This has been a wake up call to governments 
-- all over the world to prioritize people's health and make significant effort to increase health care. 

-- People who were suffereing previously with diseases like diabetes, high blood pressure etc had higher death/infection percentage, 
-- so as a society we need to choose healthy life by controling our food habits and exerciseing daily. For people who thought it 
-- won't make any difference then have been proven wrong as covid 19 had lesser impact on people with healthy life choices.









