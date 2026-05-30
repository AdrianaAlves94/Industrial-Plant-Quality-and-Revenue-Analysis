-- Queries: Build revenue_metrics (revenue per tonne = base + iron premium − silica penalty)
-- Purpose: Goal 5 — translate quality into money: revenue per tonne against the Platts $122.00 base
-- Key finding: revenue_per_tonne spans $109.15 to $128.62 across 4,097 hours (mean ≈ $120.91).

USE industrial_plant; 

SET @P_base := 122.00;
SET @VIU_Fe := 2.20;
SET @Fe_base := 65;
SET @Si_base := 2.0;
SET @Penalty_Si := 2.00;


CREATE TABLE revenue_metrics AS 
SELECT
    hour_id,
    avg_iron_cct,
    avg_silica_cct,
    (avg_iron_cct - @Fe_base) * @VIU_Fe AS iron_adjustment,
    GREATEST(0, avg_silica_cct - @Si_base) * @Penalty_Si AS silica_penalty,
    @P_base 
        + (avg_iron_cct - @Fe_base) * @VIU_Fe 
        - GREATEST(0, avg_silica_cct - @Si_base) * @Penalty_Si AS revenue_per_tonne
FROM hourly_metrics;


SELECT MIN(revenue_per_tonne) AS min_val, MAX(revenue_per_tonne) AS max_val 
FROM revenue_metrics;









