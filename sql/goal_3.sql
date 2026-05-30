-- Queries: Group operating-condition variability (std dev of process variables) by quality tier,
-- Mechanism to explain distribution
-- Purpose: Goal 3 — identify whether, when the plant produces premium output, the operating conditions 
-- (chemical flows, water levels, air injection) run more steadily
-- Key finding: Premium hours look slightly steadier on a few variables.


USE industrial_plant;

SELECT
    h.quality_tier,
    AVG(std_ph),
    AVG(std_starch_flow),
    AVG(std_amina_flow),
    AVG(std_ore_pulp_flow),
    AVG(std_ore_pulp_density),
    AVG(std_airflow_col01),
    AVG(std_airflow_col02),
    AVG(std_airflow_col03),
    AVG(std_airflow_col04),
    AVG(std_airflow_col05),
    AVG(std_airflow_col06),
    AVG(std_airflow_col07),
    AVG(std_level_col01),
    AVG(std_level_col02),
    AVG(std_level_col03),
    AVG(std_level_col04),
    AVG(std_level_col05),
    AVG(std_level_col06),
    AVG(std_level_col07)
FROM hourly_metrics h
GROUP BY h.quality_tier;

