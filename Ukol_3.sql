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