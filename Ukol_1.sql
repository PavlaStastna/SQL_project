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

