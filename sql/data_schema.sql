-- Queries: Define and populate the analysis DB — tier_thresholds, time_dim, hourly_metrics, daily_metrics
-- Purpose: Setup — aggregate raw 20s readings to hourly/daily and assign quality tiers; every goal query depends on these tables

USE industrial_plant;

CREATE TABLE tier_thresholds (
    tier_name VARCHAR(20) PRIMARY KEY,
    min_silica_pct DECIMAL(4,2),
    max_silica_pct DECIMAL(4,2),
    description VARCHAR(255)
);

INSERT INTO tier_thresholds (tier_name, min_silica_pct, max_silica_pct, description) VALUES
('premium',  NULL, 2.0, 'Silica below Platts 65% Fe benchmark'),
('standard', 2.0,  3.5, 'Silica within first Platts penalty band'),
('low',      3.5,  NULL, 'Silica in significant penalty territory');

CREATE TABLE time_dim (
    hour_id            DATETIME PRIMARY KEY,
    date               DATE,
    year               INT,
    month              INT,
    month_name         VARCHAR(20),
    day_of_week        VARCHAR(20),
    day_of_week_num    INT,
    hour_of_day        INT,
    time_of_day_bucket VARCHAR(20),
    is_weekend         BOOLEAN
);

INSERT INTO time_dim (hour_id, date, year, month, month_name, day_of_week, day_of_week_num, hour_of_day, time_of_day_bucket, is_weekend)
SELECT 
    h.hour_id,
    DATE(h.hour_id),
    YEAR(h.hour_id),
    MONTH(h.hour_id),
    MONTHNAME(h.hour_id),
    DAYNAME(h.hour_id),
    WEEKDAY(h.hour_id),
    HOUR(h.hour_id),
    CASE 
        WHEN HOUR(h.hour_id) < 6  THEN 'night'
        WHEN HOUR(h.hour_id) < 12 THEN 'morning'
        WHEN HOUR(h.hour_id) < 18 THEN 'afternoon'
        ELSE 'evening'
    END,
    WEEKDAY(h.hour_id) >= 5
FROM (
    SELECT DISTINCT DATE_FORMAT(date, '%Y-%m-%d %H:00:00') AS hour_id
    FROM plant_data
) h
ORDER BY h.hour_id;


DROP TABLE hourly_metrics;

CREATE TABLE hourly_metrics (
    hour_id                 DATETIME PRIMARY KEY,

    avg_iron_cct            DOUBLE,
    avg_silica_cct          DOUBLE,
    avg_iron_feed           DOUBLE,
    avg_silica_feed         DOUBLE,
    std_iron_cct            DOUBLE,
    std_silica_cct          DOUBLE,
    std_iron_feed           DOUBLE,
    std_silica_feed         DOUBLE,

    quality_tier            VARCHAR(20),

    avg_ph                  DOUBLE,  std_ph                  DOUBLE,
    avg_starch_flow         DOUBLE,  std_starch_flow         DOUBLE,
    avg_amina_flow          DOUBLE,  std_amina_flow          DOUBLE,
    avg_ore_pulp_flow       DOUBLE,  std_ore_pulp_flow       DOUBLE,
    avg_ore_pulp_density    DOUBLE,  std_ore_pulp_density    DOUBLE,

    avg_airflow_col01  DOUBLE,  std_airflow_col01  DOUBLE,
    avg_airflow_col02  DOUBLE,  std_airflow_col02  DOUBLE,
    avg_airflow_col03  DOUBLE,  std_airflow_col03  DOUBLE,
    avg_airflow_col04  DOUBLE,  std_airflow_col04  DOUBLE,
    avg_airflow_col05  DOUBLE,  std_airflow_col05  DOUBLE,
    avg_airflow_col06  DOUBLE,  std_airflow_col06  DOUBLE,
    avg_airflow_col07  DOUBLE,  std_airflow_col07  DOUBLE,

    avg_level_col01    DOUBLE,  std_level_col01    DOUBLE,
    avg_level_col02    DOUBLE,  std_level_col02    DOUBLE,
    avg_level_col03    DOUBLE,  std_level_col03    DOUBLE,
    avg_level_col04    DOUBLE,  std_level_col04    DOUBLE,
    avg_level_col05    DOUBLE,  std_level_col05    DOUBLE,
    avg_level_col06    DOUBLE,  std_level_col06    DOUBLE,
    avg_level_col07    DOUBLE,  std_level_col07    DOUBLE,

    FOREIGN KEY (hour_id) REFERENCES time_dim(hour_id)
);


ALTER TABLE tier_thresholds CHANGE tier_name quality_tier VARCHAR(20);

INSERT INTO hourly_metrics (
    hour_id,
    avg_iron_cct, avg_silica_cct, avg_iron_feed, avg_silica_feed,
    std_iron_cct, std_silica_cct, std_iron_feed, std_silica_feed,
    quality_tier,
    avg_ph, std_ph,
    avg_starch_flow, std_starch_flow,
    avg_amina_flow, std_amina_flow,
    avg_ore_pulp_flow, std_ore_pulp_flow,
    avg_ore_pulp_density, std_ore_pulp_density,
    avg_airflow_col01, std_airflow_col01,
    avg_airflow_col02, std_airflow_col02,
    avg_airflow_col03, std_airflow_col03,
    avg_airflow_col04, std_airflow_col04,
    avg_airflow_col05, std_airflow_col05,
    avg_airflow_col06, std_airflow_col06,
    avg_airflow_col07, std_airflow_col07,
    avg_level_col01, std_level_col01,
    avg_level_col02, std_level_col02,
    avg_level_col03, std_level_col03,
    avg_level_col04, std_level_col04,
    avg_level_col05, std_level_col05,
    avg_level_col06, std_level_col06,
    avg_level_col07, std_level_col07
)
SELECT
    DATE_FORMAT(date, '%Y-%m-%d %H:00:00') AS hour_id,

    AVG(pct_iron_concentrate),
    AVG(pct_silica_concentrate),
    AVG(pct_iron_feed),
    AVG(pct_silica_feed),
    STDDEV_SAMP(pct_iron_concentrate),
    STDDEV_SAMP(pct_silica_concentrate),
    STDDEV_SAMP(pct_iron_feed),
    STDDEV_SAMP(pct_silica_feed),

    CASE
        WHEN AVG(pct_silica_concentrate) IS NULL THEN NULL
        WHEN AVG(pct_silica_concentrate) < 2.0  THEN 'premium'
        WHEN AVG(pct_silica_concentrate) < 3.5  THEN 'standard'
        ELSE 'low'
    END,

    AVG(ore_pulp_ph),         STDDEV_SAMP(ore_pulp_ph),
    AVG(starch_flow),         STDDEV_SAMP(starch_flow),
    AVG(amina_flow),          STDDEV_SAMP(amina_flow),
    AVG(ore_pulp_flow),       STDDEV_SAMP(ore_pulp_flow),
    AVG(ore_pulp_density),    STDDEV_SAMP(ore_pulp_density),

    AVG(flotation_column_01_air_flow), STDDEV_SAMP(flotation_column_01_air_flow),
    AVG(flotation_column_02_air_flow), STDDEV_SAMP(flotation_column_02_air_flow),
    AVG(flotation_column_03_air_flow), STDDEV_SAMP(flotation_column_03_air_flow),
    AVG(flotation_column_04_air_flow), STDDEV_SAMP(flotation_column_04_air_flow),
    AVG(flotation_column_05_air_flow), STDDEV_SAMP(flotation_column_05_air_flow),
    AVG(flotation_column_06_air_flow), STDDEV_SAMP(flotation_column_06_air_flow),
    AVG(flotation_column_07_air_flow), STDDEV_SAMP(flotation_column_07_air_flow),

    AVG(flotation_column_01_level), STDDEV_SAMP(flotation_column_01_level),
    AVG(flotation_column_02_level), STDDEV_SAMP(flotation_column_02_level),
    AVG(flotation_column_03_level), STDDEV_SAMP(flotation_column_03_level),
    AVG(flotation_column_04_level), STDDEV_SAMP(flotation_column_04_level),
    AVG(flotation_column_05_level), STDDEV_SAMP(flotation_column_05_level),
    AVG(flotation_column_06_level), STDDEV_SAMP(flotation_column_06_level),
    AVG(flotation_column_07_level), STDDEV_SAMP(flotation_column_07_level)

FROM plant_data
GROUP BY DATE_FORMAT(date, '%Y-%m-%d %H:00:00')
ORDER BY hour_id;


CREATE TABLE daily_metrics (
    date                            DATE PRIMARY KEY,

    avg_ph_daily                    DOUBLE,  std_ph_daily                    DOUBLE,
    avg_starch_flow_daily           DOUBLE,  std_starch_flow_daily           DOUBLE,
    avg_amina_flow_daily            DOUBLE,  std_amina_flow_daily            DOUBLE,
    avg_ore_pulp_flow_daily         DOUBLE,  std_ore_pulp_flow_daily         DOUBLE,
    avg_ore_pulp_density_daily      DOUBLE,  std_ore_pulp_density_daily      DOUBLE,

    avg_airflow_daily               DOUBLE,  std_airflow_daily               DOUBLE,
    avg_level_daily                 DOUBLE,  std_level_daily                 DOUBLE,

    avg_iron_feed_daily             DOUBLE,  std_iron_feed_daily             DOUBLE,
    avg_silica_feed_daily           DOUBLE,  std_silica_feed_daily           DOUBLE,
    avg_iron_cct_daily              DOUBLE,  std_iron_cct_daily              DOUBLE,
    min_iron_cct_daily              DOUBLE,  max_iron_cct_daily              DOUBLE,
    avg_silica_cct_daily            DOUBLE,  std_silica_cct_daily            DOUBLE,
    min_silica_cct_daily            DOUBLE,  max_silica_cct_daily            DOUBLE,

    hours_total                     INT,
    hours_premium                   INT,
    hours_standard                  INT,
    hours_low                       INT,
    pct_premium                     DOUBLE,
    pct_standard                    DOUBLE,
    pct_low                         DOUBLE,
    dominant_tier                   VARCHAR(20)
);



INSERT INTO daily_metrics (
    date,
    avg_ph_daily, std_ph_daily,
    avg_starch_flow_daily, std_starch_flow_daily,
    avg_amina_flow_daily, std_amina_flow_daily,
    avg_ore_pulp_flow_daily, std_ore_pulp_flow_daily,
    avg_ore_pulp_density_daily, std_ore_pulp_density_daily,
    avg_airflow_daily, std_airflow_daily,
    avg_level_daily, std_level_daily,
    avg_iron_feed_daily, std_iron_feed_daily,
    avg_silica_feed_daily, std_silica_feed_daily,
    avg_iron_cct_daily, std_iron_cct_daily,
    min_iron_cct_daily, max_iron_cct_daily,
    avg_silica_cct_daily, std_silica_cct_daily,
    min_silica_cct_daily, max_silica_cct_daily,
    hours_total,
    hours_premium, hours_standard, hours_low,
    pct_premium, pct_standard, pct_low,
    dominant_tier
)
SELECT
    DATE(hour_id) AS date,
    
    AVG(avg_ph),               STDDEV_SAMP(avg_ph),
    AVG(avg_starch_flow),      STDDEV_SAMP(avg_starch_flow),
    AVG(avg_amina_flow),       STDDEV_SAMP(avg_amina_flow),
    AVG(avg_ore_pulp_flow),    STDDEV_SAMP(avg_ore_pulp_flow),
    AVG(avg_ore_pulp_density), STDDEV_SAMP(avg_ore_pulp_density),

    AVG((avg_airflow_col01 + avg_airflow_col02 + avg_airflow_col03 +
         avg_airflow_col04 + avg_airflow_col05 + avg_airflow_col06 +
         avg_airflow_col07) / 7.0),
    STDDEV_SAMP((avg_airflow_col01 + avg_airflow_col02 + avg_airflow_col03 +
                 avg_airflow_col04 + avg_airflow_col05 + avg_airflow_col06 +
                 avg_airflow_col07) / 7.0),

    AVG((avg_level_col01 + avg_level_col02 + avg_level_col03 +
         avg_level_col04 + avg_level_col05 + avg_level_col06 +
         avg_level_col07) / 7.0),
    STDDEV_SAMP((avg_level_col01 + avg_level_col02 + avg_level_col03 +
                 avg_level_col04 + avg_level_col05 + avg_level_col06 +
                 avg_level_col07) / 7.0),

    AVG(avg_iron_feed),          STDDEV_SAMP(avg_iron_feed),
    AVG(avg_silica_feed),        STDDEV_SAMP(avg_silica_feed),
    AVG(avg_iron_cct),   STDDEV_SAMP(avg_iron_cct),
    MIN(avg_iron_cct),   MAX(avg_iron_cct),
    AVG(avg_silica_cct), STDDEV_SAMP(avg_silica_cct),
    MIN(avg_silica_cct), MAX(avg_silica_cct),

    COUNT(*),
    SUM(CASE WHEN quality_tier = 'premium'  THEN 1 ELSE 0 END),
    SUM(CASE WHEN quality_tier = 'standard' THEN 1 ELSE 0 END),
    SUM(CASE WHEN quality_tier = 'low'      THEN 1 ELSE 0 END),

    100.0 * SUM(CASE WHEN quality_tier = 'premium'  THEN 1 ELSE 0 END) / COUNT(*),
    100.0 * SUM(CASE WHEN quality_tier = 'standard' THEN 1 ELSE 0 END) / COUNT(*),
    100.0 * SUM(CASE WHEN quality_tier = 'low'      THEN 1 ELSE 0 END) / COUNT(*),

    CASE
        WHEN SUM(CASE WHEN quality_tier = 'premium' THEN 1 ELSE 0 END) >=
             SUM(CASE WHEN quality_tier = 'standard' THEN 1 ELSE 0 END) AND
             SUM(CASE WHEN quality_tier = 'premium' THEN 1 ELSE 0 END) >=
             SUM(CASE WHEN quality_tier = 'low' THEN 1 ELSE 0 END)
        THEN 'premium'
        WHEN SUM(CASE WHEN quality_tier = 'standard' THEN 1 ELSE 0 END) >=
             SUM(CASE WHEN quality_tier = 'low' THEN 1 ELSE 0 END)
        THEN 'standard'
        ELSE 'low'
    END

FROM hourly_metrics
GROUP BY DATE(hour_id)
ORDER BY date;


SELECT * FROM daily_metrics;