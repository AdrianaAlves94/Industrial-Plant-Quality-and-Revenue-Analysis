-- Queries: Consecutive-hour streak length per tier; dip-recovery duration of non-premium runs between premium streaks
-- Purpose: Goal 4 — for each tier, measure how long the plant stays in that tier before it dips
-- Key finding: Premium streaks last longest in average, avg 5.27 h (standard 2.71 h, low 3.66 h). 
-- Non-premium dips average 5.30 h before recovery. 


USE industrial_plant;

DROP TABLE streak_summary;

CREATE TABLE streak_summary AS
WITH transitions AS (
  SELECT
   hour_id,
   quality_tier,
   CASE WHEN quality_tier <> COALESCE(LAG(quality_tier) OVER (ORDER BY hour_id), quality_tier) THEN 1 ELSE 0 END AS transition_flag
FROM hourly_metrics),

streak_groups AS (
SELECT
	t.hour_id,
	t.quality_tier,
	t.transition_flag,
    SUM(t.transition_flag) OVER (ORDER BY t.hour_id) AS streak_id
FROM transitions t)

SELECT DISTINCT
   s.hour_id,
   s.streak_id,
   s.quality_tier,
   COUNT(s.streak_id) OVER (PARTITION BY s.streak_id) AS streak_length
FROM streak_groups s;


SELECT
  ss.quality_tier,
  AVG(ss.streak_length) AS avg_length,
  MIN(ss.streak_length) AS min_length,
  MAX(ss.streak_length) AS max_length,
  COUNT(*) AS num_length
FROM streak_summary ss
GROUP BY ss.quality_tier;
  


CREATE TABLE dip_recovery AS
WITH binary_data AS (
    SELECT 
        hour_id,
        CASE WHEN quality_tier = 'premium' THEN 'premium' 
             ELSE 'non-premium' END AS binary_tier
    FROM hourly_metrics),

transitions AS (
  SELECT
   hour_id,
   binary_tier,
   CASE WHEN binary_tier <> COALESCE(LAG(binary_tier) OVER (ORDER BY hour_id), binary_tier) THEN 1 ELSE 0 END AS transition_flag
FROM binary_data),

streak_groups AS (
SELECT
	hour_id,
	binary_tier,
	transition_flag,
    SUM(t.transition_flag) OVER (ORDER BY t.hour_id) AS streak_id
FROM transitions t)

SELECT
   binary_tier,
   streak_id,
   COUNT(*) AS dip_duration
FROM streak_groups
WHERE binary_tier = 'non-premium'
GROUP BY streak_id;


SELECT
 binary_tier,
 AVG(dip_duration) AS avg_dip
FROM dip_recovery
GROUP BY binary_tier;
