-- ==================================
-- 01 - Ingestion
-- Run order : 00 -> 01 -> 02
-- Steps     : staging copy, duplicate detection, dedup table
-- Requires  : schema and table `layoffs` from 00-mysql-create-schema.sql
-- ==================================

USE world_layoffs;


-- ==================================
-- Staging Table (Raw Copy)
-- ==================================

DROP TABLE IF EXISTS staging_layoffs;

CREATE TABLE staging_layoffs LIKE layoffs;

INSERT INTO staging_layoffs
SELECT * FROM layoffs;


-- ==================================
-- Identify Duplicates
-- ==================================

WITH dup AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                company, location, industry, 
                total_laid_off, percentage_laid_off, 
                `date`, stage, country, funds_raised_millions
        ) AS rownum
    FROM staging_layoffs
)
SELECT * 
FROM dup
WHERE rownum > 1;


-- ==================================
-- Staging Table 2 (Without Duplicates)
-- Keeps only rownum = 1
-- ==================================

DROP TABLE IF EXISTS stg2_layoffs;

CREATE TABLE stg2_layoffs (
    company                 TEXT,
    location                TEXT,
    industry                TEXT,
    total_laid_off          INT DEFAULT NULL,
    percentage_laid_off     TEXT,
    `date`                  TEXT,
    stage                   TEXT,
    country                 TEXT,
    funds_raised_millions   INT DEFAULT NULL,
    rownum                  INT
) ENGINE = InnoDB 
  DEFAULT CHARSET = utf8mb4 
  COLLATE = utf8mb4_0900_ai_ci;

INSERT INTO stg2_layoffs (
    company, location, industry, total_laid_off, 
    percentage_laid_off, `date`, stage, country, 
    funds_raised_millions, rownum
)
WITH dup AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                company, location, industry, 
                total_laid_off, percentage_laid_off, 
                `date`, stage, country, funds_raised_millions
        ) AS rownum
    FROM staging_layoffs
)
SELECT * 
FROM dup
WHERE rownum < 2;


-- ==================================
-- Validation
-- ==================================

SELECT COUNT(*) AS stg2_rows 
FROM stg2_layoffs;
-- expected: 2356 (2361 - 5 duplicates)

SELECT COUNT(*) AS zero_total_laid_off
FROM stg2_layoffs
WHERE total_laid_off = 0;
-- expected: 0

SELECT COUNT(*) AS zero_funds_raised
FROM stg2_layoffs
WHERE funds_raised_millions = 0;
-- expected: 7 (legitimate zeros, e.g. Tuft & Needle)