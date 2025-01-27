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