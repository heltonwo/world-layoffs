-- ==================================
-- 00 - Setup: Schema + Source Table
-- Run order : 00 -> 01 -> 02
-- Run once. Safe to re-run: it never drops anything.
-- ==================================

CREATE SCHEMA IF NOT EXISTS world_layoffs
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE world_layoffs;


-- ==================================
-- Manual Step: Import the Source CSV
-- ==================================
-- Workbench > right-click Tables > Table Data Import Wizard
--   File     : data/layoffs.csv
--   Table    : layoffs (new table)
--   Encoding : utf-8
--   Columns  : keep ALL columns as TEXT (do not use INT / DATE here).
--              Types are converted later, in 02-mysql-data-cleaning.sql.


-- ==================================
-- Validation
-- ==================================

SELECT COUNT(*) AS source_rows 
FROM layoffs;
-- expected: 2361
