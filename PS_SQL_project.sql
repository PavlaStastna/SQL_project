
-- TVORBA tabulky SECONDARY FINAL

-- Countries a Economies: transformace, propojení tabulek a vytvoření tabulky t_Pavla_Stastna_project_SQL_secondary_final

SELECT
	c.continent,
	e.country ,
	e.`year` , 
	e.GDP ,
	e.population ,
	e.gini 
FROM economies e
JOIN countries c ON e.country = c.country
WHERE continent = "Europe";

CREATE TABLE t_Pavla_Stastna_project_SQL_secondary_final (
	Continent TEXT, 
	Country TEXT, 	
	`year` INT(11), 	
	GDP DOUBLE);

ALTER TABLE t_Pavla_Stastna_project_SQL_secondary_final 
ADD population INT(11),
ADD gini INT(11);


-- vložení dat do tabulky
INSERT INTO t_Pavla_Stastna_project_SQL_secondary_final (Continent, country, `year`, GDP, population, gini)
SELECT
	c.continent,
	e.country ,
	e.`year` , 
	e.GDP ,
	e.population ,
	e.gini 
FROM economies e
JOIN countries c ON e.country = c.country
WHERE continent = "Europe";

-- prikaz, ktery vymaze vsechna data z tabulky (pouzito po opakovanem spusteni prikazu INSERT INTO - data byla duplikovana)
TRUNCATE TABLE t_Pavla_Stastna_project_SQL_secondary_final; 



-- vlozeni omezení >>> v případě opakovaného spuštění příkazu INSERT INTO, který obsahuje stejná data, příkaz zahlásí chybu a nedovolí data duplikovat 
ALTER TABLE t_Pavla_Stastna_project_SQL_secondary_final 
ADD CONSTRAINT unikatni_kombinace UNIQUE (Continent, country, `year`, GDP, population, gini);


-- úpravy datovych typů ve výsledné tabulce
ALTER TABLE t_Pavla_Stastna_project_SQL_secondary_final 
MODIFY COLUMN `year` YEAR,
MODIFY COLUMN gini FLOAT,
MODIFY COLUMN population INT,
MODIFY COLUMN GDP DECIMAL (20,2);



-- TVORBA tabulky PRIMARY FINAL

-- Czechia Payroll: transformace a napojeni pomocnych tabulek

SELECT
	cp.payroll_year AS `year`,
	ROUND(AVG(cp.value), 0) AS avg_payroll_amount,
	cpu.name AS payroll_currency,
	cpib.name AS payroll_branch_name
FROM czechia_payroll cp 
LEFT JOIN czechia_payroll_industry_branch cpib 
ON cp.industry_branch_code = cpib.code
LEFT JOIN czechia_payroll_unit cpu 
ON cp.unit_code = cpu.code
WHERE cp.value_type_code = '5958' AND cpib.name IS NOT NULL
GROUP BY cp.payroll_year, payroll_branch_name
ORDER BY payroll_branch_name, cp.payroll_year ASC;


-- Czechia Price: transformace a napojení pomocných tabulek

SELECT 
	YEAR (cp.date_from) AS `year`,
	ROUND(AVG(cp.value), 2) AS avg_grocery_price,
	cpc.price_value AS grocery_price_value, 
	cpc.price_unit AS grocery_price_unit,
	cpc.name AS grocery_type	
FROM czechia_price cp 
LEFT JOIN czechia_price_category cpc 
ON cp.category_code = cpc.code
GROUP BY grocery_type, `year`
ORDER BY grocery_type, `year`;



-- Propojení Czechia Payroll a Czechia Price přes atribut year

SELECT 
    payroll_data.`year`,
    payroll_data.avg_payroll_amount,
    payroll_data.payroll_currency,
    payroll_data.payroll_branch_name,
    price_data.avg_grocery_price,
    price_data.grocery_price_value,
    price_data.grocery_price_unit,
    price_data.grocery_type
FROM 
    -- První poddotaz: data o mzdách
    (SELECT
		cp.payroll_year AS `year`,
		ROUND(AVG(cp.value), 0) AS avg_payroll_amount,
		cpu.name AS payroll_currency,
		cpib.name AS payroll_branch_name
	FROM czechia_payroll cp 
	LEFT JOIN czechia_payroll_industry_branch cpib 
		ON cp.industry_branch_code = cpib.code
	LEFT JOIN czechia_payroll_unit cpu 
		ON cp.unit_code = cpu.code
	WHERE cp.value_type_code = '5958' AND cpib.name IS NOT NULL
	GROUP BY cp.payroll_year, payroll_branch_name
	ORDER BY payroll_branch_name, cp.payroll_year ASC     
    ) AS payroll_data
LEFT JOIN 
    -- Druhý poddotaz: data o cenách
    (SELECT 
		YEAR (cp.date_from) AS `year`,
		ROUND(AVG(cp.value), 2) AS avg_grocery_price,
		cpc.price_value AS grocery_price_value, 
		cpc.price_unit AS grocery_price_unit,
		cpc.name AS grocery_type	
	FROM czechia_price cp 
	LEFT JOIN czechia_price_category cpc 
		ON cp.category_code = cpc.code
	GROUP BY grocery_type, `year`
	ORDER BY grocery_type, `year`
	    ) AS price_data
ON payroll_data.`year` = price_data.`year` -- Spojení podle roku
ORDER BY payroll_data.payroll_branch_name, `year`, price_data.grocery_type;


-- vytvoření tabulky t_Pavla_Stastna_project_SQL_primary_final

CREATE TABLE IF NOT EXISTS t_Pavla_Stastna_project_SQL_primary_final (
	`year` YEAR,
	avg_payroll_amount INTEGER,
	payroll_currency TEXT,
	payroll_branch_name TEXT,
	avg_grocery_price FLOAT,
	grocery_price_value FLOAT,
	grocery_price_unit TEXT,
	grocery_type TEXT);


-- vložení dat do vytvořené tabulky

INSERT INTO t_Pavla_Stastna_project_SQL_primary_final (`year`, avg_payroll_amount, payroll_currency, payroll_branch_name, avg_grocery_price, grocery_price_value, grocery_price_unit, grocery_type)
SELECT 
    payroll_data.`year`,
    payroll_data.avg_payroll_amount,
    payroll_data.payroll_currency,
    payroll_data.payroll_branch_name,
    price_data.avg_grocery_price,
    price_data.grocery_price_value,
    price_data.grocery_price_unit,
    price_data.grocery_type
FROM 
    -- První poddotaz: data o mzdách
    (SELECT
		cp.payroll_year AS `year`,
		ROUND(AVG(cp.value), 0) AS avg_payroll_amount,
		cpu.name AS payroll_currency,
		cpib.name AS payroll_branch_name
	FROM czechia_payroll cp 
	LEFT JOIN czechia_payroll_industry_branch cpib 
		ON cp.industry_branch_code = cpib.code
	LEFT JOIN czechia_payroll_unit cpu 
		ON cp.unit_code = cpu.code
	WHERE cp.value_type_code = '5958' AND cpib.name IS NOT NULL
	GROUP BY cp.payroll_year, payroll_branch_name
	ORDER BY payroll_branch_name, cp.payroll_year ASC     
    ) AS payroll_data
LEFT JOIN 
    -- Druhý poddotaz: data o cenách
    (SELECT 
		YEAR (cp.date_from) AS `year`,
		ROUND(AVG(cp.value), 2) AS avg_grocery_price,
		cpc.price_value AS grocery_price_value, 
		cpc.price_unit AS grocery_price_unit,
		cpc.name AS grocery_type	
	FROM czechia_price cp 
	LEFT JOIN czechia_price_category cpc 
		ON cp.category_code = cpc.code
	GROUP BY grocery_type, `year`
	ORDER BY grocery_type, `year`
	    ) AS price_data
ON payroll_data.`year` = price_data.`year` -- Spojení podle roku
ORDER BY payroll_data.payroll_branch_name, `year`, price_data.grocery_type;


-- dodatečný příkaz: zabrání duplikaci dat při opakovaném spuštění příkazu INSERT INTO se stejným datovým balíčkem

ALTER TABLE t_Pavla_Stastna_project_SQL_primary_final 
ADD CONSTRAINT unikatni_kombinace UNIQUE (`year`, avg_payroll_amount, payroll_currency, payroll_branch_name, avg_grocery_price, grocery_price_value, grocery_price_unit, grocery_type);




-- ANALYZA DAT
-- Otazka 1: Rostou v prubehu let mdy ve vsech odvetvich, nebo v nekterých klesaji?

SELECT 
	`year`,
	payroll_branch_name,
	avg_payroll_amount,
	LAG(avg_payroll_amount) OVER (PARTITION BY payroll_branch_name ORDER BY `year`) AS prev_avg_payroll,
    avg_payroll_amount - LAG(avg_payroll_amount) OVER (PARTITION BY payroll_branch_name ORDER BY `year`) AS diff,
    CASE
        WHEN avg_payroll_amount - LAG(avg_payroll_amount) OVER (PARTITION BY payroll_branch_name ORDER BY `year`) > 0 THEN 'ascending'
        WHEN avg_payroll_amount - LAG(avg_payroll_amount) OVER (PARTITION BY payroll_branch_name ORDER BY `year`) < 0 THEN 'descending'
        ELSE 'no change'
    END AS trend
FROM t_Pavla_Stastna_project_SQL_primary_final tpspsp
GROUP BY payroll_branch_name, `year`
ORDER BY payroll_branch_name, `year`;


-- Otazka 2: kolik je mozné si koupit litru mléka a kilogramu chleba za prvni a posledni srovnatelné období v
-- dostupných datech cen a mezd?
	
	SELECT 
		`year`, 
		grocery_type,
		ROUND(AVG(avg_payroll_amount / avg_grocery_price), 0) AS amount_to_buy,
		grocery_price_unit 
	FROM t_Pavla_Stastna_project_SQL_primary_final tpspspf
	WHERE (grocery_type LIKE '%mléko%' OR grocery_type LIKE '%chléb%') 
		AND 
			(`year`= (SELECT MIN(`year`) FROM t_Pavla_Stastna_project_SQL_primary_final tpspspf WHERE avg_grocery_price IS NOT NULL) 
		OR 
			`year`= (SELECT MAX(`year`) FROM t_Pavla_Stastna_project_SQL_primary_final tpspspf WHERE avg_grocery_price IS NOT NULL))
	GROUP BY grocery_type, `year`;


-- Otazka 3: Ktera kategorie potravin zdrazuje nejpomaleji (je u ni nejnizsi percentualni mezirocni narust)?

SELECT 
	grocery_type,
	percent_change
FROM (
	SELECT 
		`year`,
		grocery_type, 
		avg_grocery_price, 
		ROUND(((avg_grocery_price - LAG(avg_grocery_price) OVER (PARTITION BY grocery_type ORDER BY `year`))/LAG(avg_grocery_price) OVER (PARTITION BY grocery_type ORDER BY `year`))*100, 2) AS percent_change
	FROM t_Pavla_Stastna_project_SQL_primary_final tpspspf	
	WHERE 
		(`year`= (SELECT MIN(`year`) FROM t_Pavla_Stastna_project_SQL_primary_final tpspspf WHERE avg_grocery_price IS NOT NULL) 
		OR 
		`year`= (SELECT MAX(`year`) FROM t_Pavla_Stastna_project_SQL_primary_final tpspspf WHERE avg_grocery_price IS NOT NULL))
	GROUP BY `year`, grocery_type 
	ORDER BY grocery_type, `year`) AS subquery_1
WHERE percent_change > 0
ORDER BY percent_change;


-- Otazka 4: Existuje rok, ve kterem byl mezirocni narust cen potravin vyrazne vyssi nez rust mezd (vetsi nez 10%)?

SELECT 
	`year`,
	avg_payroll_amount_per_year,
	ROUND((avg_payroll_amount_per_year - LAG(avg_payroll_amount_per_year) OVER (ORDER BY `year`))/LAG(avg_payroll_amount_per_year) OVER (ORDER BY `year`)*100, 1) AS avg_payroll_percent_change,
	avg_grocery_price_per_year,
	ROUND((avg_grocery_price_per_year - LAG(avg_grocery_price_per_year) OVER (ORDER BY `year`))/LAG(avg_grocery_price_per_year) OVER (ORDER BY `year`)*100, 1) AS avg_grocery_percent_change,
	(ROUND((avg_grocery_price_per_year - LAG(avg_grocery_price_per_year) OVER (ORDER BY `year`))/LAG(avg_grocery_price_per_year) OVER (ORDER BY `year`)*100, 1)) - (ROUND((avg_payroll_amount_per_year - LAG(avg_payroll_amount_per_year) OVER (ORDER BY `year`))/LAG(avg_payroll_amount_per_year) OVER (ORDER BY `year`)*100, 1)) AS diff_of_percent_change
FROM (
	SELECT 
		`year`,
		ROUND(AVG(avg_payroll_amount), 0) AS avg_payroll_amount_per_year,
		ROUND(AVG(avg_grocery_price), 2) AS avg_grocery_price_per_year 
	FROM t_Pavla_Stastna_project_SQL_primary_final tpspspf 
	GROUP BY `year`
	HAVING avg_grocery_price_per_year IS NOT NULL) AS subquery_2
ORDER BY `year`;


-- Otazka 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

SELECT
	payroll_and_grocery_avg.year,
	avg_payroll_amount_per_year,
	ROUND((avg_payroll_amount_per_year - LAG(avg_payroll_amount_per_year) OVER (ORDER BY payroll_and_grocery_avg.year))/(LAG(avg_payroll_amount_per_year) OVER (ORDER BY payroll_and_grocery_avg.year))*100, 2) AS avg_payroll_percent_change,
	avg_grocery_price_per_year,
	ROUND((avg_grocery_price_per_year - LAG(avg_grocery_price_per_year) OVER (ORDER BY payroll_and_grocery_avg.year))/(LAG(avg_grocery_price_per_year) OVER (ORDER BY payroll_and_grocery_avg.year))*100, 2) AS avg_grocery_percent_change,
	GDP,
	ROUND((GDP - LAG(GDP) OVER (ORDER BY payroll_and_grocery_avg.year))/(LAG(GDP) OVER (ORDER BY payroll_and_grocery_avg.year))*100, 2) AS GDP_percent_change
FROM 
	(SELECT 
		`year`,
		ROUND(AVG(avg_payroll_amount), 0) AS avg_payroll_amount_per_year,
		ROUND(AVG(avg_grocery_price), 2) AS avg_grocery_price_per_year 
	FROM t_Pavla_Stastna_project_SQL_primary_final tpspspf 
	GROUP BY `year`
	HAVING avg_grocery_price_per_year IS NOT NULL) AS payroll_and_grocery_avg
JOIN 
	(SELECT
		`year`,
		ROUND(GDP, 0) AS GDP
	FROM t_Pavla_Stastna_project_SQL_secondary_final tpspssf
	WHERE country = 'Czech Republic') AS CZ_GDP_per_year
ON payroll_and_grocery_avg.year = CZ_GDP_per_year.year
ORDER BY payroll_and_grocery_avg.year;


