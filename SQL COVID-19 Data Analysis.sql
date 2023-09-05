
-- COVID-19 Data Analysis: Exploring the Impact on Infections, Deaths, and Vaccinations
-- Source: Ourworldindata.org / March 1, 2020 - August 30, 2023




-- 1. Data Preparation

-- Exploring Raw Data: examining the unprocessed data from the Covid Deaths and Vaccinations table

SELECT *
FROM Datasets..Covid_deaths_table
ORDER BY location, date

SELECT *
FROM Datasets..Covid_vaccinations_table
ORDER BY location, date

-- Optimizing Data Tables: cleaning and creating and filtering Covid Deaths table

CREATE VIEW Covid_deaths_filtered AS
SELECT *
FROM Datasets..Covid_deaths_table
WHERE continent != '' -- excluding records with empty continents

-- Organizing Data: transferring the view to the database for future access

USE Datasets
GO
SELECT *
INTO Covid_deaths_filtered
FROM master.dbo.Covid_deaths_filtered
GO




-- 2. Data Selection

-- Picking Key Data: selecting columns of interest from the filtered Covid Deaths table data and sorting them logically

SELECT location,
       date,
       total_cases,
       new_cases,
       total_deaths,
       population
FROM Datasets..Covid_deaths_filtered
ORDER BY location, date




-- 3. Data Analysis and Insights

-- Death Percentage Analysis: calculating the death percentage based on total cases, providing insights into severity

SELECT location,
       date,
       total_cases,
       total_deaths,
       (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS death_percentage
FROM Datasets..Covid_deaths_filtered
ORDER BY death_percentage DESC

-- Population Infection Percentage: analyzing the relationship between total cases and population to gauge infection rates

SELECT location,
       date,
       population,
       total_cases,
       (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS percent_pop_infected
FROM Datasets..Covid_deaths_filtered
ORDER BY percent_pop_infected DESC

-- Spotting Hotspots: identifying countries with the highest infection rates relative to their population

SELECT
	location,
	population,
	MAX(CAST(total_cases AS INT)) AS highest_infection_count,
	MAX((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100) AS percent_pop_infected
FROM
	Datasets..Covid_deaths_filtered
GROUP BY location, population
ORDER BY
	percent_pop_infected DESC

-- Top Mortality Rates: determining which countries have the highest total death counts

SELECT location,
	   population,
	   MAX(CAST(total_deaths AS INT)) AS total_deaths_count
FROM Datasets..Covid_deaths_filtered
GROUP BY location, population
ORDER BY total_deaths_count DESC

-- Continent Check: grouping data by continents to assess regional impact

SELECT continent,
	   SUM(CAST(new_deaths AS INT)) AS total_deaths_count
FROM Datasets..Covid_deaths_filtered
GROUP BY continent
ORDER BY total_deaths_count DESC

-- Global Overview: summarizing global statistics, including total cases, total deaths, and death percentage

SELECT SUM(new_cases) AS total_cases,
	   SUM(new_deaths) AS total_deaths,
	   SUM(CAST(new_deaths AS INT)) / SUM(NULLIF(new_cases, 0)) * 100 AS death_percentage
FROM Datasets..Covid_deaths_filtered
	
-- Population vs. Vaccinations: demonstrating the relationship between population and vaccinations by calculating cumulative vaccinations over time

SELECT d.continent,
	   d.location,
	   d.date,
	   d.population,
	   SUM(CAST(v.new_vaccinations AS FLOAT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
FROM Datasets..Covid_deaths_filtered d
JOIN Datasets..Covid_vaccinations_table v
ON d.location = v.location
AND d.date = v.date
ORDER BY total_vaccinations DESC




-- 4. CTEs, Temporary Tables, and Views
	
-- CTE Utilization: leveraging Common Table Expressions for streamlined calculations and query readability

WITH pop_vs_vaccinations (continent, location, date, population, new_vaccinations, total_vaccinations)
AS
(
SELECT d.continent,
	   d.location,
	   d.date,
	   d.population,
	   v.new_vaccinations,
	   SUM(CAST(v.new_vaccinations AS float)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
FROM Datasets..Covid_deaths_filtered d
JOIN Datasets..Covid_vaccinations_table v
ON d.location = v.location
AND d.date = v.date
)
SELECT *, (total_vaccinations/population)*100 AS perc_pop_vs_vacc
FROM pop_vs_v




-- 4. CTEs, Temporary Tables and Views
	
-- CTE Utilization: leveraging Common Table Expressions for streamlined calculations and query readability

WITH pop_vs_vaccinations (continent, location, date, population, new_vaccinations, total_vaccinations)
AS
(
SELECT d.continent,
	   d.location,
	   d.date,
	   d.population,
	   v.new_vaccinations,
	   SUM(CAST(v.new_vaccinations AS float)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
FROM Datasets..Covid_deaths_filtered d
JOIN Datasets..Covid_vaccinations_table v
ON d.location = v.location
AND d.date = v.date
)
SELECT *, (total_vaccinations/population)*100 AS perc_pop_vs_vacc
FROM pop_vs_vaccinations

-- Temporary Tables: setting up temporary tables to make complex calculations more manageable

-- DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population FLOAT,
    new_vaccinations NVARCHAR(255),
    total_vaccinations NUMERIC
)

-- Adding data into the temporary table.

INSERT INTO #percent_population_vaccinated
SELECT d.continent,
	   d.location,
	   d.date,
	   d.population,
	   v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS FLOAT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
FROM Datasets..Covid_deaths_filtered d
JOIN Datasets..Covid_vaccinations_table v
ON d.location = v.location
AND d.date = v.date

-- Calculation and exploration of temporary table

SELECT *, (total_vaccinations / population) * 100 AS perc_pop_vs_vacc
FROM #percent_population_vaccinated

-- View Crafting: Establishing a data view to create informative graphs and visualizations

CREATE VIEW percent_population_vaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS FLOAT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
FROM Datasets..Covid_deaths_filtered d
JOIN Datasets..Covid_vaccinations_table v
ON d.location = v.location
AND d.date = v.date


