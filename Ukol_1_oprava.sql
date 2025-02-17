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
