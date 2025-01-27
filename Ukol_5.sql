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