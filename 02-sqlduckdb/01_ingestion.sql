-- ===============================
-- 01_ingestion.sql
-- ==============================


-- DROPPING SCHEMA IF EXISTS 
DROP SCHEMA IF EXISTS layoffs CASCADE;

-- CREATING SCHEMA 
CREATE SCHEMA layoffs;

-- USE THIS SCHEMA BY DEFAULT
USE layoffs;

-- CREATING LAYOFF RAW /BRONZE Layer
CREATE OR REPLACE TABLE layoffs_raw AS
    SELECT *
    FROM 'data/layoffs.csv';

-- VALIDATION    
SELECT *
FROM layoffs_raw;