-- Data Cleaning
/*
		1. Remove Duplicates
		2. Standarize the Data
		3. Null Values or blank values
		4. Remove Any Columns
*/

SELECT *
FROM layoffs;




# copy raw table into staging table
/*
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;
*/

SELECT *
FROM layoffs_staging;

/*
CREATE TABLE layoffs_distinct
LIKE layoffs;
*/

-- 1. Remove Dupliates

# quick and easy way to remove duplicates
/*
INSERT layoffs_distinct
SELECT DISTINCT *
FROM layoffs_staging
LIMIT 9999;
*/

SELECT *
FROM layoffs_distinct
LIMIT 9999;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



# another way to remove duplicates while allowing the user to identify the dupes
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2; 		# identical to layoffs_distinct but with row_num column











	-- 2. Standardizing data

-- company
SELECT company, (TRIM(company)) 
FROM layoffs_staging2;

update layoffs_staging2
SET company = TRIM(company);


-- industry
SELECT DISTINCT industry
FROM layoffs_staging2;

update layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- country
SELECT country
FROM layoffs_staging2
WHERE country LIKE 'United States'
ORDER BY 1;

update layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States';


-- date
SELECT `date`#, STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;




	-- 3. Null and Blank Values
    
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;




	-- 4. Remove Any Columns or Rows
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * 
FROM layoffs_staging2;











