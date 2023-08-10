# 1. Show all the columns and rows in the table
SELECT * FROM worldpopulation.world_population;
# Current World population
SELECT FORMAT((SUM(`2022 Population`)),0) AS `total world population` 
FROM worldpopulation.world_population;

# World population in 1980
SELECT FORMAT((SUM(`1980 Population`)),0) AS `total world population` 
FROM worldpopulation.world_population;

# total population change from 1980 to 2022
SELECT FORMAT(SUM(`2022 Population`)-SUM(`1980 Population`),0) AS `total world population` 
FROM worldpopulation.world_population;

# 2. Show all the distinct continents in the table
SELECT DISTINCT Continent FROM worldpopulation.world_population;
# 3. Show all the distinct countries in the table
SELECT DISTINCT `Country/Territory` FROM worldpopulation.world_population ORDER BY `Country/Territory` ASC;
# 4. Display number of countries in the world
SELECT COUNT(DISTINCT `Country/Territory`) AS Country_Count FROM worldpopulation.world_population;

# 5. Display top 10 ranked countries in the world
SELECT `Rank`,`Country/Territory` AS Country,`2022 Population` 
FROM worldpopulation.world_population
WHERE `Rank` BETWEEN 1 AND 10 
ORDER BY `RANK` ASC;

# 6. Display bottom 10 ranked countries in the world
SELECT `Rank`,`Country/Territory` AS Country,`2022 Population` 
FROM worldpopulation.world_population
ORDER BY `RANK` DESC
LIMIT 10;

# 7. Display 20 highest populated countries in the world
SELECT `Rank`,`Country/Territory` AS Country,`2022 Population` 
FROM worldpopulation.world_population
ORDER BY `2022 Population` DESC
LIMIT 20;

# 8. Display 20 least populated countries in the world
SELECT `Rank`,`Country/Territory` AS Country,`2022 Population` 
FROM worldpopulation.world_population
ORDER BY `2022 Population` ASC
LIMIT 20;

# 9. Display top 20 countries with largest area/size in the world
SELECT ROW_NUMBER() OVER () AS `row_number`,`Country/Territory` AS Country, 
	format(`Area (kmsq)`,0) AS `Area km^2` 
FROM worldpopulation.world_population
ORDER BY `Area (kmsq)` DESC
LIMIT 20;

# 10. Display 20 countries with smallest area/size in the world
SELECT ROW_NUMBER() OVER () AS `row_number`,`Country/Territory` AS Country, 
	format(`Area (kmsq)`,0) AS `Area km^2` 
FROM worldpopulation.world_population
ORDER BY `Area (kmsq)` ASC
LIMIT 20;


# 11. Display 20 highly densly populated countries in the world
SELECT ROW_NUMBER() OVER () AS `row_number`,
	`Country/Territory` AS Country,
    `Density (per kmsq)`
FROM worldpopulation.world_population
ORDER BY `Density (per kmsq)` DESC
LIMIT 20;

# 12. Display 20 least densly populated countries in the world
SELECT ROW_NUMBER() OVER () AS `row_number`,
	`Country/Territory` AS Country,
	`Density (per kmsq)`
FROM worldpopulation.world_population
ORDER BY `Density (per kmsq)` ASC
LIMIT 20;

# 13. Display top 20 countries with highest growth rate
SELECT ROW_NUMBER() OVER () AS `row_number`,
	`Country/Territory` AS Country,
	`Growth Rate`
FROM worldpopulation.world_population
ORDER BY `Growth Rate` DESC
LIMIT 20;

# 14. Display top 20 countries with lowest growth rate
SELECT ROW_NUMBER() OVER () AS `row_number`,
	`Country/Territory` AS Country,
	`Growth Rate`
FROM worldpopulation.world_population
ORDER BY `Growth Rate` ASC
LIMIT 20;

# 15. Display top 20 countries with highest world population contribution
SELECT ROW_NUMBER() OVER () AS `row_number`,
	`Country/Territory` AS Country,
	`World Population Percentage`
FROM worldpopulation.world_population
ORDER BY `World Population Percentage` DESC
LIMIT 20;

# 16. Display top 15 countries with highest world population contribution in
# context to individual population, area and growth rate
SELECT ROW_NUMBER() OVER () AS `row_number`,
	`Country/Territory` AS Country,
    format(`2022 Population`,0) AS Population, 
    format(`Area (kmsq)`,0) AS `Area km^2`,
    `Growth Rate`,
	`World Population Percentage`
FROM worldpopulation.world_population
ORDER BY `World Population Percentage` DESC
LIMIT 15;


# 17. changes in Top 15 countries with highest population over each decade
WITH pop_1980 as(
	SELECT ROW_NUMBER() OVER () AS `row_number`,
		`Country/Territory` AS `1980's Country`,
		format(`1980 Population`,0) AS `1980's Population`
    FROM worldpopulation.world_population
    ORDER BY `1980 Population` DESC
    LIMIT 15
), pop_1990 AS(
	SELECT ROW_NUMBER() OVER () AS `row_number`,
		`Country/Territory` AS `1990's Country`,
		format(`1990 Population`,0) AS `1990's Population`
    FROM worldpopulation.world_population
    ORDER BY `1990 Population` DESC
    LIMIT 15
), pop_2000 AS(
	SELECT ROW_NUMBER() OVER () AS `row_number`,
		`Country/Territory` AS `2000's Country`,
		format(`2000 Population`,0) AS `2000's Population`
    FROM worldpopulation.world_population
    ORDER BY `2000 Population` DESC
    LIMIT 15
), pop_2010 AS(
	SELECT ROW_NUMBER() OVER () AS `row_number`,
		`Country/Territory` AS `2010's Country`,
		format(`2010 Population`,0) AS `2010's Population`
    FROM worldpopulation.world_population
    ORDER BY `2010 Population` DESC
    LIMIT 15
), pop_2020 AS(
	SELECT ROW_NUMBER() OVER () AS `row_number`,
		`Country/Territory` AS `2020's Country`,
		format(`2020 Population`,0) AS `2020's Population`
    FROM worldpopulation.world_population
    ORDER BY `2020 Population` DESC
    LIMIT 15
)
SELECT * FROM pop_1980
INNER JOIN pop_1990 USING(`row_number`)
INNER JOIN pop_2000 USING(`row_number`)
INNER JOIN pop_2010 USING(`row_number`)
INNER JOIN pop_2020 USING(`row_number`)
ORDER BY `row_number`;


# 18. Top 5 populated countries for each continent

SELECT s.Continent, 
	s.Country, 
    format(s.Population,0) AS Population
FROM (
    SELECT Continent, `Country/Territory` AS `Country`, `2022 Population` AS Population,
           ROW_NUMBER() OVER (PARTITION BY Continent ORDER BY `2022 Population` DESC) AS row_num
    FROM worldpopulation.world_population
) AS s
WHERE row_num <= 5;

# 19. Top 5 least populated countries for each continent

SELECT s.Continent, 
	s.Country, 
    format(s.Population,0) AS Population
FROM (
    SELECT Continent, `Country/Territory` AS `Country`, `2022 Population` AS Population,
           ROW_NUMBER() OVER (PARTITION BY Continent ORDER BY `2022 Population` ASC) AS row_num
    FROM worldpopulation.world_population
) AS s
WHERE row_num <= 5;

# 20. Countries that increased highest number of people in last 4 decades (1980-2020)
SELECT ROW_NUMBER() OVER () AS `row_number`,
	`Country/Territory` AS `Country`,
    format(`1980 Population`,0) AS `1980's Population`,
    format(`2020 Population`,0) AS `2020's Population`,
    format(`2020 Population`-`1980 Population`,0) AS `Population difference`,
    ((`2020 Population`-`1980 Population`)/`1980 Population`)*100 AS `Growth%`
FROM worldpopulation.world_population
ORDER BY `2020 Population`-`1980 Population` DESC
LIMIT 15;

# 21. Countries that increased highest number of people in last decade (2010-2020)
SELECT ROW_NUMBER() OVER () AS `row_number`,
	`Country/Territory` AS `Country`,
    format(`2010 Population`,0) AS `2010's Population`,
    format(`2020 Population`,0) AS `2020's Population`,
    format(`2020 Population`-`2010 Population`,0) AS `Population difference`,
    ((`2020 Population`-`2010 Population`)/`2010 Population`)*100 AS `Growth%`
FROM worldpopulation.world_population
ORDER BY `2020 Population`-`2010 Population` DESC
LIMIT 15;

# 22. Countries that increased lowest number of people in last 4 decades (1980-2020)
SELECT ROW_NUMBER() OVER () AS `row_number`,
	`Country/Territory` AS `Country`,
    format(`1980 Population`,0) AS `1980's Population`,
    format(`2020 Population`,0) AS `2020's Population`,
    format(`2020 Population`-`1980 Population`,0) AS `Population difference`,
    ((`2020 Population`-`1980 Population`)/`1980 Population`)*100 AS `Growth%`
FROM worldpopulation.world_population
ORDER BY `2020 Population`-`1980 Population` ASC
LIMIT 15;

# 23. Countries that increased lowest number of people in last decade (2010-2020)
SELECT ROW_NUMBER() OVER () AS `row_number`,
	`Country/Territory` AS `Country`,
    format(`2010 Population`,0) AS `2010's Population`,
    format(`2020 Population`,0) AS `2020's Population`,
    format(`2020 Population`-`2010 Population`,0) AS `Population difference`,
    ((`2020 Population`-`2010 Population`)/`2010 Population`)*100 AS `Growth%`
FROM worldpopulation.world_population
ORDER BY `2020 Population`-`2010 Population` ASC
LIMIT 15;

# 24. Current Total population per each continent
SELECT
	Continent,
    FORMAT(SUM(`2022 Population`),0) AS `Population`
FROM worldpopulation.world_population
GROUP BY Continent
ORDER BY SUM(`2022 Population`) DESC;

# 25. Total population per each continent in 1980
SELECT
	Continent,
    FORMAT(SUM(`1980 Population`),0) AS `Population`
FROM worldpopulation.world_population
GROUP BY Continent
ORDER BY SUM(`1980 Population`) DESC;

# 26. Countries that highest growth percent in last 4 decades (1980-2020)
SELECT ROW_NUMBER() OVER () AS `row_number`,
	`Country/Territory` AS `Country`,
    format(`1980 Population`,0) AS `1980's Population`,
    format(`2020 Population`,0) AS `2020's Population`,
    format(`2020 Population`-`1980 Population`,0) AS `Population difference`,
    ((`2020 Population`-`1980 Population`)/`1980 Population`)*100 AS `Growth%`
FROM worldpopulation.world_population
ORDER BY ((`2020 Population`-`1980 Population`)/`1980 Population`)*100 DESC
LIMIT 15;

# 27. Countries that highest growth percent in last decade (2010-2020)
SELECT ROW_NUMBER() OVER () AS `row_number`,
	`Country/Territory` AS `Country`,
    format(`2010 Population`,0) AS `2010's Population`,
    format(`2020 Population`,0) AS `2020's Population`,
    format(`2020 Population`-`2010 Population`,0) AS `Population difference`,
    ((`2020 Population`-`2010 Population`)/`2010 Population`)*100 AS `Growth%`
FROM worldpopulation.world_population
ORDER BY ((`2020 Population`-`2010 Population`)/`2010 Population`)*100 DESC
LIMIT 15;
