-- =========================
-- 02_tranformations.sql
-- ==========================

-- 1) IDENTIFIYING DUPLICATES 

WITH cte AS(
    SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, location, 
            industry, total_laid_off,
            percentage_laid_off, date, 
            stage, country, funds_raised_millions)AS rownum
    FROM layoffs_raw )
    
SELECT * FROM cte 
WHERE rownum >1;

-- 2) STANDARDIZE DATA AND PUT IN FORMATED TABLE
CREATE OR REPLACE TABLE layoffs_formated AS
WITH rawstd AS(
    SELECT CASE LOWER(TRIM(company))
           WHEN 'bytedance' THEN 'ByteDance'
           WHEN 'clearco'   THEN 'Clearco'
           WHEN 'curefit'   THEN 'Curefit'
           WHEN 'salesloft' THEN 'Salesloft'
           WHEN 'appgate'   THEN 'Appgate'
           ELSE TRIM(company)
       END AS company,
       
    CASE WHEN location LIKE  '%Düsseldorf'THEN 'Dusseldorf' ELSE location END AS location,
    CASE WHEN industry LIKE '%Crypto%' THEN 'Crypto' ELSE industry END AS industry,
    total_laid_off, percentage_laid_off, date, 
    stage, country, funds_raised_millions   
    FROM layoffs_raw
    ),
cte AS(
SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, location, industry,
    total_laid_off, percentage_laid_off, date, 
    stage, country, funds_raised_millions)AS rownum
    FROM rawstd
)
SELECT    company,location,
        NULLIF(industry,'NULL')AS industry,
        TRY_CAST(NULLIF(total_laid_off,'NULL')AS INTEGER)AS total_laid_off,
        TRY_CAST(NULLIF(percentage_laid_off,'NULL')AS FLOAT) AS percentage_laid_off,
        TRY_CAST(TRY_STRPTIME(date,'%m/%d/%Y')AS DATE)AS date,
        stage, TRIM(TRAILING '.' FROM country)AS country,
        TRY_CAST(NULLIF(funds_raised_millions,'NULL')AS FLOAT)AS funds_raised_millions
FROM cte
WHERE rownum = 1;


-- 3) Handling Nulls with Join
-- Step 1
SELECT  t1.company , t1.location , t1.industry AS dest,
        t2.company , t2.location , t2.industry AS src

    FROM layoffs_formated AS t1
    JOIN layoffs_formated AS t2
        ON t1.company =t2.company
    WHERE(t1.industry ISNULL OR t1.industry = '') 
    AND  (t2.industry IS NOT NULL AND t2.industry <> '');

UPDATE layoffs_formated AS t1
SET industry = t2.industry 
FROM  layoffs_formated AS t2
WHERE t1.company =t2.company
    AND  (t1.industry ISNULL OR t1.industry = '') 
    AND  (t2.industry IS NOT NULL AND t2.industry <> '');



-- Step 2 - Manual fix
UPDATE layoffs_formated
SET industry = 'Other'
WHERE company = 'Bally''s Interactive';

SELECT * 
FROM layoffs_formated 
WHERE company LIKE 'Ball%';

-- 4) DATA QUALITY FIX - Netflix funding outlier
-- Source file reports 121,900M (~$121.9B) for Netflix, which is not realistic.
-- Public sources disagree on the true pre-IPO value (~100-130M), so it is set to NULL
-- instead of inventing a number. NULL is ignored by SUM/MAX aggregations.
-- The AND condition keeps the script safe to re-run.
UPDATE layoffs_formated
SET funds_raised_millions = NULL
WHERE company = 'Netflix' AND funds_raised_millions = 121900;
 
 
-- 5) FINAL TABLE Cleaned /Silver Layer
CREATE OR REPLACE TABLE layoffs_cleaned AS(
    SELECT *
    FROM  layoffs_formated
);
 
-- Validation
 
SELECT company, location,industry
FROM layoffs_cleaned
WHERE company IN ('Airbnb', 'Carvana', 'Juul');
 
 
SELECT *
FROM  layoffs_cleaned
LIMIT 20;
 
SELECT DISTINCT industry
FROM layoffs_cleaned;
 
SELECT *
FROM layoffs_cleaned
WHERE industry = 'Other'
ORDER BY company
LIMIT 20;
 
-- Validation: Netflix fix (funds_raised_millions should be NULL)
SELECT company, date, funds_raised_millions
FROM layoffs_cleaned
WHERE company = 'Netflix'; 
