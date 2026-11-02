WITH user_profiles AS (
SELECT UserID, 
    CASE
        WHEN Province = ' ' THEN 'Uncategorized'
        WHEN Province = 'None' THEN 'Uncategorized'
    ELSE Province
    END AS Region,
    Age,
    CASE
        WHEN Age = 0 THEN 'Infants'
        WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
        WHEN Age BETWEEN 13 AND 19 THEN 'Teenager'
        WHEN Age BETWEEN 20 AND 35 THEN 'Youth'
        WHEN Age BETWEEN 36 AND 50 THEN 'Adult'
        WHEN Age BETWEEN 51 AND 65 THEN 'Elder'
        WHEN Age >65 THEN 'Pensioner'
    END AS age_groups,

 CASE 
        WHEN (Email IS NOT NULL) OR (Email<>' ') OR (Email NOT  IN ('None')) THEN 1
    ELSE 0
    END AS email_flag,

 CASE 
    WHEN `Social Media Handle` IS NOT NULL OR `Social Media Handle`= '!= '  OR `Social Media Handle` NOT  IN ('None') THEN 1
        ELSE 0
    END AS SM_flag,
     
     CASE 
        WHEN Race = 'other' THEN 'None'
        WHEN Race = ' ' THEN 'None'
    ELSE Race
    END AS Race,
     CASE
        WHEN gender = ' ' THEN 'Unknown'
        WHEN gender = 'None' THEN 'Unknown'
        ELSE gender
    END AS Gender
FROM bright_tv.bright_tv.bright_tv_user_profile
), 

viewership AS (
SELECT
    (COALESCE (UserID0,userid4,0)) AS userid, 
    
    --Dates
    TO_CHAR(RecordDate2, 'yyyyMM') AS month_id,-- TO_CHAR means to converts a date into a string and TO_DATE means to convert a string into a date
    TO_DATE(RecordDate2) AS watch_date,-- It is to extract the date from the timestamp in our table
    DAYNAME(RecordDate2) AS day_name,

    --Time
   -- TIME(RecordDate2) AS watch_time,
    TO_CHAR(RecordDate2,'DD') AS day_of_week,
    date_format(RecordDate2,'HH:mm:ss') AS watch_time,
    HOUR(RecordDate2) AS hour_of_day,

    CASE
        WHEN watch_time BETWEEN '00:00:00' AND '05:59:00' THEN '01. Midnight'
        WHEN watch_time BETWEEN '06:00:00' AND '11:59:00' THEN '02. Morning'
        WHEN watch_time BETWEEN '12:00:00' AND '16:59:00' THEN '03. Afternoon'
        WHEN watch_time BETWEEN '17:00:00' AND '23:59:00' THEN '04. Evening'
        
    END AS time_of_day,
    
    date_format(`Duration 2`,'HH:mm:ss') AS duration,
    ROUND(Hour(`Duration 2`) * 60 + minute(`Duration 2`) + second(`Duration 2`) / 60, 2) AS duration_minute,
    CASE
        WHEN duration BETWEEN '00:00:00' AND '00:30:00' THEN '01. Low Usage <30 min'
         WHEN duration BETWEEN '00:30:01' AND '00:59:59' THEN '02. Med Usage < 60 min'
          WHEN duration BETWEEN '00:59:59' AND '00:30:00' THEN '03. High Usage >60 min'
          ELSE '04 No Usage'
    END AS screen_time_buckets,

    CASE
        WHEN day_name IN ('Sat', 'Sun') THEN 'weekend'
        ELSE 'weekday'
    END AS day_classification,
    MONTHNAME(RecordDate2) AS month_name,

     CASE
        WHEN Channel2 IN ('Sawsee', 'SawSee') THEN 'Sawsee'
        WHEN Channel2 IN ('SuperSport Live Events', 'Live on SuperSport','Supersport Live Events', 'DStv Events 1') THEN 'Live Events'
    ELSE Channel2
    END AS Tv_channel
  FROM bright_tv.bright_tv.bright_tv_viewership
)

SELECT COALESCE(A.userid,B.userid) AS sub_id,
        month_id,
        watch_date,
        day_of_week,
        day_name,
        day_classification,
        month_name,
        Tv_channel,
        screen_time_buckets,
        watch_time,
        hour_of_day,
        duration,
        duration_minute,
        time_of_day,
        Region,
        age_groups,
        email_flag
        sm_flag,
        Race,
        Gender
FROM viewership AS A
LEFT JOIN user_profiles AS B
ON A.userid=B.userid
GROUP BY ALL;
