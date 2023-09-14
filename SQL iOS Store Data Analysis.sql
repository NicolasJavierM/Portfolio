
-- iOS App Store Data Analysis Project
-- Source: Kaggle.com / Mobile App Store ( 7200 apps)




-- 1. Data Preparation & Validation

-- Exploring Raw Data: examining the unprocessed data from the IOS Store and IOS Description

SELECT *
FROM datasets..ios_store

SELECT *
FROM datasets..ios_description

-- Comparing the number of unique apps (IDs) in both tables

SELECT COUNT (DISTINCT id)
FROM datasets..ios_store

SELECT COUNT (DISTINCT id)
FROM datasets..ios_description

-- Verifying if there are null values in important columns

SELECT COUNT (*) AS mssing_values_store
FROM datasets..ios_store
WHERE COALESCE(id, track_name, price, user_rating, prime_genre, user_rating) IS NULL

SELECT COUNT (*) AS mssing_values_desc
FROM datasets..ios_description
WHERE COALESCE(id, track_name) IS NULL

-- Calculate how many apps belong to each genre

SELECT prime_genre, COUNT (id) AS apps
FROM datasets..ios_store
GROUP BY prime_genre
ORDER BY apps DESC

-- Reviewing summary statistics for app ratings

SELECT MIN(user_rating) AS min_user_rating,
	   MAX(user_rating) AS man_user_rating,
	   AVG(user_rating) AS avg_user_rating
FROM datasets..ios_store
WHERE user_rating > 0


-- 3. Data Analysis and Insights

-- 1. Comparison of Ratings Between Free and Paid Apps

SELECT
	AVG(CASE WHEN price > 0 THEN user_rating ELSE NULL END) AS avg_paid_rating,
	AVG(CASE WHEN price = 0 THEN user_rating ELSE NULL END) AS avg_free_rating
FROM datasets..ios_store;


-- 2. Impact of Supported Languages on Ratings

-- Before analyzing, checking the Minimum and Maximum Number of Supported Languages in Apps

SELECT
	MAX (lang_num) AS max_lang,
	MIN (lang_num) AS min_lang
FROM datasets..ios_store
WHERE lang_num > 0

-- Analyzing whether the number of supported languages influences ratings

SELECT
	AVG(CASE WHEN lang_num < 25 THEN user_rating ELSE NULL END) AS less_than_25_lang,
	AVG(CASE WHEN lang_num BETWEEN 25 AND 50 THEN user_rating ELSE NULL END) AS between_25_50_lang,
	AVG(CASE WHEN lang_num > 50 THEN user_rating ELSE NULL END) AS more_than_50_lang
FROM datasets..ios_store

-- 3. Identifying genres with lower average ratings

SELECT prime_genre, AVG (user_rating) AS avg_genre_rating
FROM datasets..ios_store
GROUP BY prime_genre
ORDER BY avg_genre_rating ASC

-- 4. Evaluating if the length of app descriptions is related to ratings

-- Before analyzing, checking the Maximum and Average Number of Supported Languages in Apps

SELECT
	MAX(LEN(app_desc)) AS max_length,
	AVG(LEN(app_desc)) AS avg_length
FROM datasets..ios_description

-- Evaluate if the length of app descriptions is related to ratings.

SELECT
	AVG(CASE WHEN LEN(d.app_desc) < 1000 THEN user_rating ELSE NULL END) AS short_description,
	AVG(CASE WHEN LEN(d.app_desc) BETWEEN 1000 AND 2000 THEN user_rating ELSE NULL END) AS med_short_description,
	AVG(CASE WHEN LEN(d.app_desc) > 2000 THEN user_rating ELSE NULL END) AS long_description
FROM datasets..ios_store AS s
JOIN datasets..ios_description AS d
on s.id = d.id


-- 5. Checking the Top Rated app for each genre and Rating Count

SELECT
	prime_genre,
	track_name,
	user_rating,
	rating_count_tot
FROM
(
SELECT
	prime_genre,
	track_name,
	user_rating,
	RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank,
	rating_count_tot
FROM datasets..ios_store
--WHERE prime_genre LIKE '%name%'
--WHERE track_name LIKE '%name%'
)
AS s
WHERE s.rank = 1
ORDER BY rating_count_tot DESC


-- Conclusions
-- 1. Paid apps generally have better ratings than free apps
-- 2. As an app has more available languages, it receives higher ratings
-- 3. Productivity, Music, and Photo & Video are the genres with the highest ratings, while Catalogs, Finance, and Books have the lowest ratings
-- 4. Apps with longer descriptions has a positive correlation with ratings
-- 5. Games genre have the highest volume of apps, and Head Soccer app has the highest rate per user in store

