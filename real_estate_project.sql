-- create TABLE
DROP TABLE IF EXISTS housing_project;


CREATE TABLE housing_project (
	id INT PRIMARY KEY,
	date DATE,
	price INT,
	bedrooms INT,
	bathrooms NUMERIC(4, 2),
	sqft_living	INT,
	sqft_lot INT,
	floors NUMERIC(4, 2),
	waterfront BOOLEAN DEFAULT TRUE,
	view VARCHAR(20),
	condition VARCHAR(20),
	grade INT,
	yr_built INT,
	zipcode	INT,
	lat	NUMERIC(6, 4),
	long NUMERIC(6, 3)
);

SELECT * FROM housing_project;

-- Explore dataset

-- count total dataset
SELECT COUNT(*)
FROM housing_project;

-- count distinct area (zipcode) data
SELECT DISTINCT zipcode
FROM housing_project;    --- we have 70 unique zipcodes

-- checking for null or empty 
SELECT *
FROM housing_project
WHERE 
	date IS NULL OR price IS NULL OR bedrooms IS NULL OR bathrooms IS NULL OR sqft_living IS NULL OR
	sqft_lot IS NULL OR floors IS NULL OR waterfront IS NULL OR view IS NULL OR condition 
	IS NULL OR grade IS NULL OR yr_built IS NULL OR zipcode IS NULL OR lat IS NULL OR long IS NULL;

-- no empty cells in the data set

/* Key Business Questions
1. Pricing Analysis
a. What is the average, median, and range of home prices in different zip codes?

b. How does price correlate with square footage (living area vs. lot size)?

c. Which zip codes have the highest and lowest price per square foot?
*/



-- 1a. What is the average, median, and range of home prices in different zip codes?
SELECT zipcode
	,AVG(price) AS avg_price
	,PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) AS median_price
	,MIN(price) AS min_price
	,MAX(price) AS max_price
FROM housing_project
GROUP BY zipcode
ORDER BY avg_price DESC;


-- 1b. How does price correlate with square footage (living area vs. lot size)?
SELECT	CORR(price, sqft_living) AS living_corr
		,CORR(price, sqft_lot) AS lot_corr
FROM housing_project;    


-- 1c. Which zip codes have the highest and lowest price per square foot?
SELECT zipcode
	,AVG(price/sqft_living) AS avg_price_per_sqft
	,AVG(sqft_living) AS avg_living_area
FROM housing_project
GROUP BY zipcode
ORDER BY avg_price_per_sqft;

/* 2. Property Characteristics
2a. How does the number of bedrooms/bathrooms affect price?

2b. What's the relationship between home grade/condition and price?

2c. Do waterfront properties command a significant price premium?
*/

SELECT * FROM housing_project;

-- 2a. How does the number of bedrooms/bathrooms affect price?
SELECT
	bedrooms
	,AVG(price) AS avg_price
	,AVG(price/sqft_living) AS avg_price_per_sqft
FROM housing_project
GROUP BY bedrooms
ORDER BY bedrooms DESC;

-- how bathrooms affect price
SELECT
	ROUND(bathrooms, 0) AS bathrooms
	,AVG(price) AS avg_price
	,AVG(price/sqft_living)
FROM housing_project
GROUP BY bathrooms
ORDER BY bathrooms DESC;




-- 2b. What's the relationship between home grade/condition and price?

SELECT 
	condition
	,COUNT(*) AS total
	,AVG(price) AS avg_price
	,AVG(price/sqft_living) AS Avg_price_per_sqft
FROM housing_project
GROUP BY condition
ORDER BY Avg_price_per_sqft DESC;

-- 2c. Do waterfront properties command a significant price premium?

SELECT
	AVG(CASE WHEN waterfront = 'true' THEN price END) AS avg_waterfront_price
	,AVG(CASE WHEN waterfront = 'false' THEN price END) AS Avg_non_waterfront_price
	,AVG(CASE WHEN waterfront = 'true' THEN price END) - 
		AVG(CASE WHEN waterfront = 'false' THEN price END) AS price_difference
FROM housing_project;



SELECT
	waterfront
	,COUNT(*) AS num_properties
	,AVG(price) AS avg_price
FROM housing_project
GROUP BY waterfront
ORDER BY waterfront; -- this give the average price for waterfront and non waterfront properties



-- to check premium

SELECT
	ROUND(100.0 *(
		(SELECT AVG(price) FROM housing_project WHERE waterfront = 'true') -
		(SELECT AVG(price) FROM housing_project WHERE waterfront = 'false'))
		/(SELECT AVG(price) FROM housing_project WHERE waterfront = 'false'), 2
	) AS price_premium_percentage;


/* 3. Temporal Trends
3a. How have prices changed over the recorded time period (2014-2015)?

3b. Are there seasonal patterns in home sales prices?

3c. Which months have the highest/lowest average sale prices?
*/

SELECT * FROM housing_project;
-- 3a. How have prices changed over the recorded time period (2014-2015)?
SELECT 
	EXTRACT(YEAR FROM date) AS year
	,AVG(price) AS avg_price
	,COUNT(*) AS num_sales
FROM housing_project
GROUP BY year
ORDER by year;

-- to get percentage price change
WITH yearly_avg AS (
	SELECT 
		EXTRACT(YEAR FROM date) AS year
		,AVG(price) AS avg_price
	FROM housing_project
	GROUP BY year
)
SELECT 
	ROUND(100* 
		(MAX(avg_price) - MIN(avg_price))/MIN(avg_price), 2
	) AS price_growth_percent
FROM yearly_avg
WHERE year BETWEEN 2014 AND 2015;

-- 3b. Are there seasonal patterns in home sales prices?

SELECT 
	EXTRACT(MONTH FROM date) AS month
	,AVG(price) AS avg_price
	,COUNT(*) AS num_sales
FROM housing_project
GROUP BY month
ORDER by month;


-- 3c. Which months have the highest/lowest average sale prices?
WITH monthly AS (
	SELECT 
		EXTRACT(MONTH FROM date) AS month
		,AVG(price) AS avg_price
		,COUNT(*) AS num_sales
	FROM housing_project
	GROUP BY month
	ORDER by month
)
(
	SELECT 'Highest' AS label, month, avg_price FROM monthly ORDER BY avg_price DESC LIMIT 1
)
UNION ALL
(
	SELECT 'Lowest', month, avg_price FROM monthly ORDER BY avg_price ASC LIMIT 1
);

/* 4. Location Analysis
How do prices vary by latitude/longitude (geographic distribution)?

What's the price distribution in different zip codes?

Are there clusters of high-value properties in specific areas?
*/

SELECT * FROM housing_project;
-- 4a. How do prices vary by latitude/longitude (geographic distribution)?
SELECT
	ROUND(lat::numeric, 2) AS lat_bin
	,ROUND(long::numeric, 2) AS long_bin
	,AVG(price) AS avg_price
FROM housing_project
GROUP BY lat_bin, long_bin
ORDER BY avg_price DESC;

-- 4b. What's the price distribution in different zip codes?
SELECT
  zipcode,
  AVG(price) AS avg_price,
  COUNT(*) AS homes_sold
FROM housing_project
GROUP BY zipcode
ORDER BY avg_price DESC;

-- 4c. Are there clusters of high-value properties in specific areas?
SELECT
  ROUND(lat::numeric, 2) AS lat_bin,
  ROUND(long::numeric, 2) AS long_bin,
  COUNT(*) AS num_properties,
  ROUND(AVG(price), 2) AS avg_price
FROM housing_project
GROUP BY lat_bin, long_bin
HAVING COUNT(*) > 5  -- Filter out areas with very few homes
ORDER BY avg_price DESC;

-- 90% percentile
WITH percentiles AS (	
	SELECT 
		PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY price) AS price_90
	FROM housing_project
)
SELECT
	zipcode
	,COUNT(*) AS luxry_homes
	,ROUND(AVG(price), 0) AS avg_price
FROM housing_project, percentiles
WHERE price >= price_90
GROUP BY zipcode
ORDER BY avg_price


/* 5. Market Segmentation
5a. What are the characteristics of homes in different price brackets?

5b. How do property features differ between high-end and mid-range homes?
*/

SELECT * FROM housing_project;
-- 5a. What are the characteristics of homes in different price brackets?

WITH price_stats AS (
	SELECT
		PERCENTILE_CONT(ARRAY[0.33, 0.66])  -- classify homes into orice brackets
			WITHIN GROUP (ORDER BY price) AS breakpoints
	FROM housing_project
),
label_homes AS (
	SELECT *
		,CASE
			WHEN price <= (SELECT breakpoints[1] FROM price_stats) THEN 'Low'
			WHEN price <= (SELECT breakpoints[2] FROM price_stats) THEN 'Mid'
			ELSE 'High'
		END AS price_bracket
	FROM housing_project
)
SELECT 
	label_homes.price_bracket
	,COUNT(*) AS num_homes
	,ROUND(AVG(bedrooms), 2) AS avg_bedrooms
	,ROUND(AVG(bathrooms), 2) AS avg_bathrooms
	,ROUND(AVG(sqft_living), 0) AS avg_living_area
	,ROUND(AVG(sqft_lot), 0) AS avg_lot_are
	,ROUND(AVG(floors), 2) AS avg_floors
	,condition
FROM label_homes
GROUP BY label_homes.price_bracket, condition
ORDER BY 
  CASE label_homes.price_bracket 
    WHEN 'Low' THEN 1 
    WHEN 'Mid' THEN 2 
    ELSE 3 
  END;


-- 5b. How do property features differ between high-end and mid-range homes?
WITH price_cutoffs AS (
    SELECT 
        percentile_cont(0.66) WITHIN GROUP (ORDER BY price) AS p66
        ,percentile_cont(0.33) WITHIN GROUP (ORDER BY price) AS p33
    FROM housing_project
),
labeled_homes AS (
    SELECT
        *,
        CASE
            WHEN price > (SELECT p66 FROM price_cutoffs) THEN 'High'
            WHEN price > (SELECT p33 FROM price_cutoffs) THEN 'Mid'
            ELSE 'Low'
        END AS price_bracket
    FROM housing_project
),
filtered AS (
    SELECT * FROM labeled_homes
    WHERE price_bracket IN ('High', 'Mid')
)
SELECT
    price_bracket
    ,COUNT(*) AS num_homes
    ,ROUND(AVG(bedrooms), 2) AS avg_bedrooms
    ,ROUND(AVG(bathrooms), 2) AS avg_bathrooms
    ,ROUND(AVG(sqft_living), 0) AS avg_sqft_living
    ,ROUND(AVG(sqft_lot), 0) AS avg_sqft_lot
    ,ROUND(AVG(floors), 2) AS avg_floors
    ,view
    ,ROUND(AVG(grade), 2) AS avg_grade
    ,condition
FROM filtered
GROUP BY price_bracket, view, condition
ORDER BY 
    CASE price_bracket 
        WHEN 'Mid' THEN 1
        WHEN 'High' THEN 2
    END;


-- End of Project