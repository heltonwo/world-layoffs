-- ===========================================================================
-- 05_export.sql
-- PURPOSE: Export the analysis-ready table (layoffs_analysis) to Parquet,
-- so it can be loaded into Power BI, Tableau, or any other BI tool without
-- needing a live connection to the DuckDB file.
-- Run this manually after 04_reclassify.sql, whenever you want a fresh export.
-- ===========================================================================


COPY layoffs_analysis TO 'data/layoffs_analysis.parquet' (FORMAT PARQUET);

-- Optional: also export as CSV, in case the BI tool of choice doesn't read Parquet
COPY layoffs_analysis TO 'data/layoffs_analysis.csv' (HEADER, DELIMITER ',');

-- Validation: confirm row count matches the source table
SELECT COUNT(*) AS exported_rows FROM layoffs_analysis;

-- duckdb world_layoffs.duckdb -c ".read sqlduckdb/05_export.sql"