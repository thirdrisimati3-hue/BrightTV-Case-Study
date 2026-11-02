SELECT *
FROM bright_tv.bright_tv.bright_tv_viewership
LIMIT 10;
-----------------------------------------------------------------------

SELECT COUNT(*) AS Number_rows,
       COUNT (COALESCE (UserID0,userid4)) AS Active_subs,
       COUNT (DISTINCT COALESCE (UserID0,userid4 )) AS Active_users
FROM bright_tv.bright_tv.bright_tv_viewership
WHERE UserID0 IS NOT NULL;

SELECT DISTINCT Channel2
FROM bright_tv.bright_tv.bright_tv_viewership;

SELECT DISTINCT
    CASE
        WHEN Channel2 IN ('Sawsee', 'SawSee') THEN 'Sawsee'
        WHEN Channel2 IN ('SuperSport Live Events', 'Live on SuperSport','Supersport Live Events', 'DStv Events 1') THEN 'Live Events'
    ELSE Channel2
    END AS Tv_channel
FROM bright_tv.bright_tv.bright_tv_viewership;

WITH base AS (
    SELECT (COALESCE (UserID0,userid4)) AS uderid
    FROM bright_tv.bright_tv.bright_tv_viewership 

),
viewership AS (

SELECT
    (COALESCE (UserID0,userid4)) AS userid,

    TO_CHAR(RecordDate2, 'yyyyMM') AS month_id,
    TO_DATE(RecordDate2) AS watch_date,
   -- TIME(RecordDate2) AS watch_time,
    TO_CHAR(RecordDate2,'DD') AS day_of_week,
    DAYNAME(RecordDate2) AS day_name,

    CASE
        WHEN day_name IN ('Sat', 'Sun') THEN 'weekend'
        ELSE 'weekday'
    END AS day_classification,
    MONTHNAME(RecordDate2) AS month_name,

     CASE
        WHEN Channel2 IN ('Sawsee', 'SawSee') THEN 'Sawsee'
        WHEN Channel2 IN ('SuperSport Live Events', 'Live on SuperSport','Supersport Live Events', 'DStv Events 1') THEN 'Live Events'
    ELSE Channel2
    END AS Tv_channel,
    date_format(RecordDate2,'HH:mm:ss') AS watch_time,
    HOUR(RecordDate2) AS hour_of_day,
    date_format(`Duration 2`,'HH:mm:ss') AS duration

FROM bright_tv.bright_tv.bright_tv_viewership;

)
