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