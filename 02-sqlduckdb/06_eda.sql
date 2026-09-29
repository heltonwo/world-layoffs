-- ============================================================
-- GLOBAL LAYOFF DASHBOARD - EXPLORATORY DATA ANALYSIS (EDA)
-- Database / Engine: DuckDB
-- Description: Queries aligning with Power BI Dashboard Visuals
-- ============================================================


-- ------------------------------------------------------------
-- 1. TOP KPI CARDS
-- ------------------------------------------------------------

-- KPI 1: Total Layoffs (Matches 384K Card)
SELECT 
    SUM(total_laid_off) AS total_layoffs 
FROM layoffs_analysis;

-- KPI 2: Total Funds Raised, counted once per company (Matches $754.38 B Card)
-- Note: funding repeats on every layoff round, so take the max per company.
-- Dividing by 1000 converts millions into billions.
SELECT 
    ROUND(SUM(max_funds) / 1000, 2) AS total_funds_raised_billions
FROM (
    SELECT company, MAX(funds_raised_millions) AS max_funds
    FROM layoffs_analysis
    GROUP BY company
);


-- ------------------------------------------------------------
-- 2. LEFT COLUMN VISUALS
-- ------------------------------------------------------------

-- Visual 1: Average Layoff % by Industry (Top 5 Bar Chart)
SELECT 
    industry,
    ROUND(AVG(percentage_laid_off) * 100, 1) AS avg_percentage_laid_off
FROM layoffs_analysis
WHERE percentage_laid_off IS NOT NULL
GROUP BY industry
ORDER BY avg_percentage_laid_off DESC
LIMIT 5;

-- Visual 2: Monthly Layoff Trend (Bottom Line Chart)
SELECT 
    STRFTIME(date, '%Y-%m') AS year_month,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_analysis
WHERE date IS NOT NULL
GROUP BY 1
ORDER BY year_month;


-- ------------------------------------------------------------
-- 3. RIGHT COLUMN VISUALS
-- ------------------------------------------------------------

-- Visual 1: Total Layoffs by Industry (Top 10 Column Chart)
SELECT 
    industry, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_analysis
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY total_layoffs DESC
LIMIT 10;

-- Visual 2: Funds Raised vs Total Layoffs by Company (Scatter Chart)
-- Note: max funding per company (funding repeats on every layoff round)
SELECT 
    company,
    MAX(funds_raised_millions) AS funds_raised,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_analysis
WHERE funds_raised_millions IS NOT NULL 
  AND total_laid_off IS NOT NULL
GROUP BY company;

-- Visual 3: Top 10 Companies by Layoffs (Bottom Horizontal Bar Chart)
SELECT 
    company, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_analysis
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;