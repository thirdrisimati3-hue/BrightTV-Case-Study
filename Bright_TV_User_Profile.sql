-- I needed to see the whole table before starting to do any analysis on it
SELECT *
FROM bright_tv.bright_tv.bright_tv_user_profile

--Checking for duplicates in my data
SELECT UserID, COUNT(*) AS duplicate_count
FROM bright_tv.bright_tv.bright_tv_user_profile
GROUP BY UserID
HAVING COUNT (*) > 1;

-- How big is this data or what is the size of the data
SELECT COUNT(*) AS number_of_rows,
       COUNT(DISTINCT UserID) AS number_subs
FROM bright_tv.bright_tv.bright_tv_user_profile;

-- Are there any rows where the UserID is NULL
SELECT COUNT(*) AS cnt
FROM bright_tv.bright_tv.bright_tv_user_profile
WHERE UserID IS NULL;

-------------------------------------------------------
-- Gender checks
------------------------------------------------------
SELECT DISTINCT Gender
FROM bright_tv.bright_tv.bright_tv_user_profile;

SELECT COUNT (*) AS gender_rows
FROM bright_tv.bright_tv.bright_tv_user_profile
WHERE Gender IS NULL;

-- Calculate the number of genders in the dataset
SELECT COUNT (*)
FROM bright_tv.bright_tv.bright_tv_user_profile
WHERE gender = ' ';

-- Where the gender is unknown, white it as "Unknown"
SELECT
       COUNT (DISTINCT UserID) AS Subs,
    CASE
        WHEN gender = ' ' THEN 'Unknown'
        WHEN gender = 'None' THEN 'Unknown'
        ELSE gender
    END AS Gender
FROM bright_tv.bright_tv.bright_tv_user_profile
GROUP BY Gender;

---------------------------------------------
-- Race Checks
--------------------------------------------

SELECT DISTINCT Race
FROM bright_tv.bright_tv.bright_tv_user_profile;

SELECT COUNT (*) AS number_rows
FROM bright_tv.bright_tv.bright_tv_user_profile
WHERE Race IS NULL;

SELECT DISTINCT
    CASE 
        WHEN Race IN ('other') THEN 'None'
        WHEN Race = ' ' THEN 'None'
    ELSE Race 
END AS Race
FROM bright_tv.bright_tv.bright_tv_user_profile;

------------------------------------------------------
-- Province Checks
------------------------------------------------------
SELECT DISTINCT Province
FROM bright_tv.bright_tv.bright_tv_user_profile;

SELECT DISTINCT
    CASE
        WHEN Province = ' ' THEN 'Uncategorized'
        WHEN Province = 'None' THEN 'Uncategorized'
    ELSE Province
END AS Region
FROM bright_tv.bright_tv.bright_tv_user_profile;

--------------------------------------------------
-- Age Checks
--------------------------------------------------
SELECT MIN(AGE) AS min_age, ----- =0
       MAX(AGE) AS max_age  ----- =114
FROM bright_tv.bright_tv.bright_tv_user_profile;

SELECT COUNT (*) AS Cnt_age
FROM bright_tv.bright_tv.bright_tv_user_profile
WHERE Age IS NULL;
-----------------------------------------------------------
Running Cte
-----------------------------------------------------------
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
        WHEN (Email IS NOT NULL) OR (Email=' ') OR (Email NOT  IN ('None')) THEN 1
    ELSE 0
    END AS email_flag,

 CASE 
    WHEN `Social Media Handle` IS NOT NULL OR `Social Media Handle`= ' '  OR `Social Media Handle` NOT  IN ('None') THEN 1
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
    (COALESCE (UserID0,userid4)) AS userid,
    TO_CHAR(RecordDate2, 'yyyyMM') AS month_id,
    TO_DATE(RecordDate2) AS watch_date,
   -- TIME(RecordDate2) AS watch_time,
    TO_CHAR(RecordDate2,'DD') AS day_of_week,
    DAYNAME(RecordDate2) AS day_name,

    CASE
        WHEN day_name IN ('Sat', 'Sun') THEN 'weekend'
        ELSE 'weekend'
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

FROM bright_tv.bright_tv.bright_tv_viewership
)

SELECT COUNT(B.userid) AS subs,
        month_id,
        watch_date,
        day_of_week,
        day_name,
        day_classification,
        month_name,
        Tv_channel,
        wattch_time
        hour_of_day,
        duration,
        Region,
        age_groups,
        email_flag
        sm_flag,
        Race,
        Gender
FROM viewership AS A
LEFT JOIN user_profiles AS B
ON A.userid=B.UserID
GROUP BY ALL;

