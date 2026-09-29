-- ==================================
-- 02 - Data Cleaning
-- Run order : 00 -> 01 -> 02
-- Steps     : standardize, cast types, fill industry, build layoffs_cleaned
-- Requires  : stg2_layoffs from 01-mysql-ingestion.sql
-- Warning   : never run twice without re-running 01 first
--             (STR_TO_DATE on an already-DATE column turns every date into NULL)
-- ==================================

USE world_layoffs;

-- If Workbench raises Error 1175 (Safe Updates), uncomment:
-- SET SQL_SAFE_UPDATES = 0;


-- ==================================
-- Standardize: company / location
-- ==================================

UPDATE stg2_layoffs 
SET company = TRIM(company);

UPDATE stg2_layoffs
SET location = CASE
    WHEN location LIKE 'D%sseldorf'    THEN 'Dusseldorf'
    WHEN location LIKE 'Florian%polis' THEN 'Florianopolis'
    WHEN location LIKE 'Malm%'         THEN 'Malmo'
    ELSE location
END;


-- ==================================
-- Standardize: industry
-- ==================================

UPDATE stg2_layoffs 
SET industry = 'Crypto' 
WHERE industry LIKE '%Crypto%';


-- ==================================
-- Standardize: country
-- ==================================

UPDATE stg2_layoffs 
SET country = TRIM(TRAILING '.' FROM country);


-- ==================================
-- Cast: date (TEXT -> DATE)
-- ==================================

UPDATE stg2_layoffs 
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE stg2_layoffs 
MODIFY COLUMN `date` DATE;


-- ==================================
-- Cast: percentage_laid_off (TEXT -> FLOAT)
-- ==================================

ALTER TABLE stg2_layoffs 
MODIFY COLUMN percentage_laid_off FLOAT;


-- ==================================
-- Fill Missing Industry
-- ==================================

-- Manual fix
UPDATE stg2_layoffs 
SET industry = 'Other' 
WHERE company = 'Bally''s Interactive';

-- Self-join: copy industry from another row of the same company
UPDATE stg2_layoffs ta 
JOIN stg2_layoffs tb 
    ON ta.company = tb.company    
SET ta.industry = tb.industry
WHERE (ta.industry IS NULL OR ta.industry = '')  
  AND (tb.industry IS NOT NULL AND tb.industry <> '');


-- ==================================
-- Final Table (Silver Layer)
-- ==================================

DROP TABLE IF EXISTS layoffs_cleaned;

CREATE TABLE layoffs_cleaned AS
SELECT company, location, industry, total_laid_off, 
       percentage_laid_off, `date`, stage, country, funds_raised_millions
FROM stg2_layoffs;


-- ==================================
-- Validation
-- ==================================

SELECT COUNT(*) AS cleaned_rows 
FROM layoffs_cleaned;
-- expected: 2356

SELECT COUNT(*) AS industry_null 
FROM layoffs_cleaned 
WHERE industry IS NULL;

SELECT COUNT(*) AS date_null 
FROM layoffs_cleaned 
WHERE `date` IS NULL;

SELECT DISTINCT industry 
FROM layoffs_cleaned 
ORDER BY industry;