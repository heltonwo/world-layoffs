-- ============================================================================
-- 03_orchestrator.sql
-- RUNS THE PIPELINE FROM START TO END
-- RUN THROUGH TERMINAL
-- COMMAND >>> duckdb world_layoffs.duckdb -c ".read 02-sqlduckdb/03_orchestrator.sql"
-- =============================================================

.read 02-sqlduckdb/01_ingestion.sql
.read 02-sqlduckdb/02_tranformations.sql
.read 02-sqlduckdb/04_reclassify.sql
.read 02-sqlduckdb/05_export.sql
.read 02-sqlduckdb/06_eda.sql
