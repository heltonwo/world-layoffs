-- ===============================================================================
-- 04_reclassify.sql
-- PURPOSE: Reclassify companies the original dataset filed under 'Other' industry,
-- mapping each to the most specific EXISTING category where it fits (Infrastructure,
-- Security, Hardware), and using 'Technology' only as a residual bucket for
-- generic SaaS/software with no better existing fit.
-- KNOWN LIMITATION: this list was built from manual review of a partial sample
-- of the 93 companies under 'Other' — not the full set. Some tech companies may
-- still remain miscategorized as 'Other'.
-- This is a SUBJECTIVE, MANUAL step — separate from the objective cleaning
-- done in 02_tranformations.sql. layoffs_cleaned stays untouched as the
-- source-of-truth silver layer.
-- =======================================================================

CREATE OR REPLACE TABLE layoffs_analysis AS
SELECT 
    company, location,
    CASE 
        WHEN industry = 'Other' AND company IN (
            'Twilio', 'RingCentral', 'Whispir', 'Whereby', 'Element', 'Ericsson'
        ) THEN 'Infrastructure'

        WHEN industry = 'Other' AND company IN (
            'SimilarWeb', 'Kandji', 'Smarsh', 'Karbon', 'Esper', 'EverBridge'
        ) THEN 'Security'

        WHEN industry = 'Other' AND company IN (
            'Synopsys', 'PuduTech', 'Plus One Robotics', 'Fluke'
        ) THEN 'Hardware'

        WHEN industry = 'Other' AND company IN (
            'Microsoft', 'Atlassian', 'Autodesk', 'Dropbox', 'ClickUp',
            'Coda', 'BlueStacks', 'Digimarc', 'Automation Anywhere',
            'American Robotics', 'Desktop Metal', 'Element AI',
            'Asana', 'Bonterra', 'SAP Labs', 'Workato', 'WalkMe',
            'Improbable', 'Kinde', 'Tonkean', 'LiveTiles', 'Teamwork',
            'ResearchGate', 'Jimdo', 'Q4', 'Intrinsic', 'Dispatch',
            'Consider.co', 'Submittable', 'Brodmann17', 'Unico',
            'Almanac', 'Benevity', 'Blackbaud', 'Catalant',
            'Dude Solutions', 'Dutchie', 'GoCanvas', 'Hopin', 'Hubilo'
        ) THEN 'Technology'

        ELSE industry
    END AS industry,
    total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
FROM layoffs_cleaned;

-- Validation
SELECT *
FROM layoffs_analysis
LIMIT 20;

SELECT DISTINCT industry
FROM layoffs_analysis
ORDER BY industry;