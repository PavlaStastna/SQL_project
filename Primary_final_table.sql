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

