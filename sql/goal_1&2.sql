-- Queries: Tier distribution overall, by day-of-week and by time-of-day; plus premium-hour process averages per time bucket;
-- Mechanism to explain distribution
-- Purpose: Goal 1 & 2 — identify whether premium output varies by day-of-week and time-of-day, 
-- and what operating conditions differ in those periods
-- Key finding: Overall Premium 49.9% / Standard 32.4% / Low 17.7%. 
-- Time-of-day systematic but small — evening 53.7% highest, afternoon 47.0% lowest. Day-of-week (48.2–52.9%).

USE industrial_plant;

SELECT 
    quality_tier,
    COUNT(*) AS hours_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS pct_hours
FROM hourly_metrics
GROUP BY quality_tier
ORDER BY ( 
CASE
  WHEN quality_tier = 'premium' THEN 1 
  WHEN quality_tier = 'standard' THEN 2     
  ELSE 3
END);


SELECT
	day_of_week, 
	quality_tier,
    COUNT(*) AS hours_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS pct_total,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY t.day_of_week) AS pct_day
FROM hourly_metrics h
JOIN time_dim t ON h.hour_id = t.hour_id
GROUP BY t.day_of_week, h.quality_tier, t.day_of_week_num
ORDER BY t.day_of_week_num, 
    CASE quality_tier WHEN 'premium' THEN 1 WHEN 'standard' THEN 2 ELSE 3 END;


SELECT
	t.time_of_day_bucket, 
	h.quality_tier,
    COUNT(*) AS hours_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS pct_total,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY t.time_of_day_bucket) AS pct_bucket
FROM hourly_metrics h
JOIN time_dim t ON h.hour_id = t.hour_id
GROUP BY t.time_of_day_bucket, h.quality_tier
ORDER BY pct_bucket DESC;


SELECT
	t.time_of_day_bucket, 
	h.quality_tier,
    AVG(avg_iron_feed),
    AVG(avg_silica_feed),
    AVG(avg_ph),
    AVG(avg_starch_flow),
    AVG(avg_amina_flow),
    AVG(avg_ore_pulp_flow),
    AVG(avg_ore_pulp_density),
    AVG(avg_airflow_col01),
    AVG(avg_airflow_col02),
    AVG(avg_airflow_col03),
    AVG(avg_airflow_col04),
    AVG(avg_airflow_col05),
    AVG(avg_airflow_col06),
    AVG(avg_airflow_col07),
    AVG(avg_level_col01),
    AVG(avg_level_col02),
    AVG(avg_level_col03),
    AVG(avg_level_col04),
    AVG(avg_level_col05),
    AVG(avg_level_col06),
    AVG(avg_level_col07)
FROM hourly_metrics h
JOIN time_dim t ON t.hour_id = h.hour_id
WHERE h.quality_tier = 'premium'
GROUP BY t.time_of_day_bucket, h.quality_tier
ORDER BY
     (CASE WHEN t.time_of_day_bucket = 'morning' THEN 1 WHEN t.time_of_day_bucket = 'afternoon' THEN 2 WHEN t.time_of_day_bucket = 'evening' THEN 3 ELSE 4 END);