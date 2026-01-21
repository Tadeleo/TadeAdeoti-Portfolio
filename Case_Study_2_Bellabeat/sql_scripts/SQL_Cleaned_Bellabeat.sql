DECLARE
 TIMESTAMP_REGEX STRING DEFAULT r'^\d{4}-\d{1,2}-\d{1,2}[T ]\d{1,2}:\d{1,2}:\d{1,2}(\.\d{1,6})? *(([+-]\d{1,2}(:\d{1,2})?)|Z|UTC)?$';
DECLARE
 DATE_REGEX STRING DEFAULT r'^\d{4}-(?:[1-9]|0[1-9]|1[012])-(?:[1-9]|0[1-9]|[12][0-9]|3[01])$';
DECLARE
 TIME_REGEX STRING DEFAULT r'^\d{1,2}:\d{1,2}:\d{1,2}(\.\d{1,6})?$';

 DECLARE
 MORNING_START,
 MORNING_END,
 AFTERNOON_END,
 EVENING_END INT64;

 SET
 MORNING_START = 6;
SET
 MORNING_END = 12;
SET
 AFTERNOON_END = 18;
SET
 EVENING_END = 21;

SELECT
 column_name,
 COUNT(table_name)
FROM
 `tade-bigquery-project.Bellabeat.INFORMATION_SCHEMA.COLUMNS`
GROUP BY
 1;

SELECT
 table_name,
 SUM(CASE
     WHEN column_name = "Id" THEN 1
   ELSE
   0
 END
   ) AS has_id_column
FROM
 `tade-bigquery-project.Bellabeat.INFORMATION_SCHEMA.COLUMNS`
GROUP BY
 1
ORDER BY
 1 ASC;

SELECT
 table_name,
 SUM(CASE
     WHEN data_type IN ("TIMESTAMP", "DATETIME", "TIME", "DATE") THEN 1
   ELSE
   0
 END
   ) AS has_time_info
FROM
 `tade-bigquery-project.Bellabeat.INFORMATION_SCHEMA.COLUMNS`
WHERE
 data_type IN ("TIMESTAMP",
   "DATETIME",
   "DATE")
GROUP BY
 1
HAVING
 has_time_info = 0;


 SELECT
 CONCAT(table_catalog,".",table_schema,".",table_name) AS table_path,
 table_name,
 column_name
FROM
 `tade-bigquery-project.Bellabeat.INFORMATION_SCHEMA.COLUMNS`
WHERE
 data_type IN ("TIMESTAMP",
   "DATETIME",
   "DATE");



SELECT
 table_name,
 column_name
FROM
 `tade-bigquery-project.Bellabeat.INFORMATION_SCHEMA.COLUMNS`
WHERE
 REGEXP_CONTAINS(LOWER(column_name), "date|minute|daily|hourly|day|seconds");


SELECT
 ActivityDate,
 REGEXP_CONTAINS(STRING(ActivityDate), TIMESTAMP_REGEX) AS is_timestamp
FROM
 `tade-bigquery-project.Bellabeat.daily_activity3`
LIMIT
 5;

 SELECT
 ActivityDate,
 REGEXP_CONTAINS(STRING(ActivityDate), TIMESTAMP_REGEX) AS is_timestamp
FROM
 `tade-bigquery-project.Bellabeat.daily_activity4`
LIMIT
 5;


SELECT
 CASE
   WHEN MIN(REGEXP_CONTAINS(STRING(ActivityDate), TIMESTAMP_REGEX)) = TRUE THEN "Valid"
 ELSE
 "Not Valid"
END
 AS valid_test
FROM
 `tade-bigquery-project.Bellabeat.daily_activity4`;



 SELECT
 DISTINCT table_name
FROM
 `tade-bigquery-project.Bellabeat.INFORMATION_SCHEMA.COLUMNS`
WHERE
 REGEXP_CONTAINS(LOWER(table_name),"day|daily");


SELECT
 column_name,
 data_type,
 COUNT(table_name) AS table_count
FROM
 `tade-bigquery-project.Bellabeat.INFORMATION_SCHEMA.COLUMNS`
WHERE
 REGEXP_CONTAINS(LOWER(table_name),"day|daily")
GROUP BY
 1,
 2;



 -- Step 1: Combine both tables for daily activity using UNION
-- Step 2: Use a Window Function (ROW_NUMBER) to rank duplicates by TotalSteps
WITH CombinedActivity AS (
    SELECT * FROM `tade-bigquery-project.Bellabeat.daily_activity3`
    UNION ALL
    SELECT * FROM `tade-bigquery-project.Bellabeat.daily_activity4`
),
RankedActivity AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Id, ActivityDate 
               ORDER BY TotalSteps DESC
           ) as rank_id
    FROM CombinedActivity
)
-- Step 3: Select only the 'top' record for each ID and Date
SELECT 
    Id, ActivityDate, TotalSteps, TotalDistance, VeryActiveMinutes, 
    FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories
FROM RankedActivity
WHERE rank_id = 1;



-- Step 1: Combine both tables for hourly steps using UNION

-- Step 2: Use a Window Function (ROW_NUMBER) to rank duplicates by TotalSteps

WITH CombinedStep AS (

    SELECT * FROM `tade-bigquery-project.Bellabeat.hourly_steps3`

    UNION ALL

    SELECT * FROM `tade-bigquery-project.Bellabeat.hourly_step4`

),

RankedStep AS (

    SELECT *,

           ROW_NUMBER() OVER (

               PARTITION BY Id, ActivityHour

               ORDER BY StepTotal DESC

           ) as rank_id

    FROM CombinedStep

)

-- Step 3: Select only the 'top' record for each ID and Date

SELECT

    Id, ActivityHour, StepTotal

FROM RankedStep

WHERE rank_id = 1;


-- Step 1: Combine both tables for weight log using UNION

-- Step 2: Use a Window Function (ROW_NUMBER) to rank duplicates by TotalSteps

WITH CombinedWeight AS (

    SELECT * FROM `tade-bigquery-project.Bellabeat.weight_log3`

    UNION ALL

    SELECT * FROM `tade-bigquery-project.Bellabeat.weight_log4`

),

RankedWeight AS (

    SELECT *,

           ROW_NUMBER() OVER (

               PARTITION BY Id, Date

               ORDER BY WeightKg DESC

           ) as rank_id

    FROM CombinedWeight

)

-- Step 3: Select only the 'top' record for each ID and Date

SELECT

    Id, Date, WeightKg, WeightPounds, BMI, IsManualReport

FROM RankedWeight

WHERE rank_id = 1;

-- Step 1: Combine both tables for minute sleep using UNION
-- Step 2: Use a Window Function (ROW_NUMBER) to rank duplicates by TotalSteps
WITH CombinedSleep AS (
    SELECT * FROM `tade-bigquery-project.Bellabeat.minute_sleep3`
    UNION ALL
    SELECT * FROM `tade-bigquery-project.Bellabeat.minute_sleep4`
),
RankedSleep AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Id, date 
               ORDER BY logid DESC
           ) as rank_id
    FROM CombinedSleep
)
-- Step 3: Select only the 'top' record for each ID and Date
SELECT 
    Id, date, value, logid
FROM RankedSleep
WHERE rank_id = 1;



EXPORT DATA OPTIONS(
  uri = 'gs://bellabeat-exports/combined_sleep_*.csv',
  format = 'CSV',
  overwrite = true,
  header = true
)
AS
SELECT *
FROM `tade-bigquery-project.Bellabeat.CombinedSleep`;



CREATE TABLE `tade-bigquery-project.Bellabeat.Master_Hourly_Activity` AS
SELECT 
    -- Daily Activity Data (A)
    A.Id,
    A.ActivityDate,
    A.TotalSteps AS Daily_Total_Steps,
    A.Calories AS Daily_Total_Calories,
    A.VeryActiveMinutes,
    A.FairlyActiveMinutes,
    A.LightlyActiveMinutes,
    A.SedentaryMinutes,
    
    -- Hourly Step Data (S)
    S.ActivityHour,
    S.StepTotal AS Hourly_Steps,
    
    -- Weight Data (W)
    W.WeightKg,
    W.BMI,
    W.IsManualReport
    
FROM `tade-bigquery-project.Bellabeat.CombinedActivity` AS A
-- Join to Hourly Steps to see the breakdown of the day
LEFT JOIN `tade-bigquery-project.Bellabeat.CombinedStep` AS S
  ON A.Id = S.Id 
  AND A.ActivityDate = DATE(S.ActivityHour)
-- Join to Weight to see physical stats for that day
LEFT JOIN `tade-bigquery-project.Bellabeat.CombinedWeight` AS W
  ON A.Id = W.Id 
  AND A.ActivityDate = DATE(W.Date);

ALTER TABLE `tade-bigquery-project.Bellabeat.sleep_day4`
DROP COLUMN TotalMinutesAsleep;

SELECT
  Id,
  DATE(SleepDay) AS date,
  TotalMinutesAsleep
FROM `tade-bigquery-project.Bellabeat.sleep_day3`

UNION ALL

SELECT
  Id,
  DATE(SleepDay) AS date,
  TotalMinutesAsleep
FROM `tade-bigquery-project.Bellabeat.sleep_day4`;
