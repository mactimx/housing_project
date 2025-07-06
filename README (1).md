# Real Estate Properties Analysis
![Create a banner imag](https://github.com/user-attachments/assets/b25d84e0-6bdb-4f06-9752-3e4862c132a6)

## Table of Contents

- [Project Overview](#Project-overview)
- [Data Sources](#data-sources)
- [Key Business Questions Answered](#key-business-questions-answered)
- [Recommendations](#recommendations)

### Project Overview
---
This project analyzes the relationship between housing prices and square footage (living area vs. lot size) using a real estate dataset. The goal is to determine which factor—living space (sqft_living) or lot size (sqft_lot)—has a stronger correlation with home prices. Aslo price variation over a period was also analysed. <br>

The analysis includes: <br> ✅ **Correlation coefficients** between price and square footage
<br> ✅ **Price per sqft** comparisons (living area vs. lot size)
<br> ✅ **Geographic trends** (by ZIP code)
<br> ✅ **Property size brackets** (small, medium, large homes)

### 📂 Data Sources

Real Estate Data: The primary dataset used for this analysis is the "housing.csv" file, containing detailed information about properties.

**Dataset**
The dataset contains the following key columns:

- **price** (sale price)
- **sqft_living** (interior living space)
- **sqft_lo**t (total lot size)
- **zipcode** (location identifier)
- **Additional features:** bedrooms, bathrooms, condition, grade, year built

### 🛠 Tools & Technologies

- **SQL** PostgreSQL for data analysis
- **Python** for visualization with matplotlib/seaborn
- **GitHub** documentation & version control


### Data Cleaning/Preparation

In the initial data preparation phase, we performed the following tasks:
1. Data loading and inspection.
2. Handling missing values.
3. Data cleaning and formatting.

### Exploratory Data Analysis

EDA involved exploring the real estate data to gain insiht of the dataset as:
- **Record Count:** Determine the total number of records in the dataset.
- **zipcode Count:** Find out how many unique locations are in the dataset.
- **Null Value Check:** Check for any null values in the dataset and delete records with missing data.

``` sql
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

```

### 🔍 Key Business Questions Answered
**1. Pricing Analysis**
- What is the average, median, and range of home prices in different zip codes?
- How does price correlate with square footage (living area vs. lot size)?
- Which zip codes have the highest and lowest price per square foot?

**2. Property Characteristics**
- How does the number of bedrooms/bathrooms affect price?
- What's the relationship between home grade/condition and price?
- Do waterfront properties command a significant price premium?

**3. Temporal Trends**
- How have prices changed over the recorded time period (2014-2015)?
- Are there seasonal patterns in home sales prices?
- Which months have the highest/lowest average sale prices?

**4. Location Analysis**
- How do prices vary by latitude/longitude (geographic distribution)?
- What's the price distribution in different zip codes?
- Are there clusters of high-value properties in specific areas?

**5. Market Segmentation**
- What are the characteristics of homes in different price brackets?
- How do property features differ between high-end and mid-range homes?

### 📊 Data Analysis Approach
Using SQL and python the business question was answered as follows:
**1. Correlation Analysis**
- Pearson correlation coefficients between price and:
  - sqft_living
  - sqft_lot

**2. Price per Sqft Trends**
- Calculate average price per sqft for living area vs. lot size.
- Analyze how this metric changes across different home sizes.

**3. Geographic Trends (ZIP Code Analysis)**
- Group data by ZIP code to identify:
  - Areas where living space is more valuable
  - Areas where lot size drives pricing

**4. Segmentation by Home Size**
- Categorize homes into:
  - Small (<1,500 sqft)
  - Medium (1,500–3,000 sqft)
  - Large (>3,000 sqft)
- Compare correlations and price per sqft trends.


```sql
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


```
Using python **Pearson correlation coefficients** between price and sqft_living was computed and **plotted.**

```python
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
df = pd.read_csv(r'C:\Users\timka\Downloads\housing.csv')
print(df.head())

plt.figure(figsize=(10, 6))
sns.scatterplot(x='sqft_living', y='price', data=df, alpha=0.4)
sns.regplot(x='sqft_living', y='price', data=df, scatter=False, color='red', line_kws={"linewidth": 2})
plt.title('Price vs. Living Area (sqft)')
plt.xlabel('Living Area (sqft)')
plt.ylabel('Price')
plt.tight_layout()
plt.savefig('price_vs_sqft_living.png', dpi=300)  # Saves to current working directory
plt.show()
```
The 
![price_vs_sqft_living](https://github.com/user-attachments/assets/a88fc7bf-5057-45be-a781-7815304f6b87)

**2. Property Characteristics**
- How does the number of bedrooms/bathrooms affect price?
- What's the relationship between home grade/condition and price?
- Do waterfront properties command a significant price premium?

```sql
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
```

using python to plot the impact of waterfront on properties.

```python
sns.barplot(x='waterfront', y='price', data=df, estimator=np.mean)
plt.title('Average Price: Waterfront vs. Non-Waterfront')
plt.xlabel('Waterfront (1 = Yes, 0 = No)')
plt.ylabel('Average Price')
plt.savefig('Average Price: Waterfront vs. Non-Waterfront.png', dpi=300)  # Saves to current working directory
plt.show()
```
![monthly_avg_price](https://github.com/user-attachments/assets/adb70d19-4da1-4720-a671-c62f22772012)

**3. Temporal Trends**
- How have prices changed over the recorded time period (2014-2015)?
- Are there seasonal patterns in home sales prices?
- Which months have the highest/lowest average sale prices?

```sql
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
```
To visualize price variation over a period of 1 year, python was used.
```python
monthly_avg = df.groupby('month')['price'].mean()
import matplotlib.pyplot as plt

monthly_avg.plot(figsize=(12, 6), marker='o', title='Monthly Avg Price (2014–2015)')
plt.ylabel('Average Price')
plt.xlabel('Month')
plt.xticks(range(1, 13))
plt.grid(True)
plt.tight_layout()
plt.savefig("C:/Users/timka/Downloads/Monthly Avg Price(2014-2015.jpg", format='jpg', dpi=300, bbox_inches='tight')
plt.show()
```
![Monthly Avg Price(2014-2015](https://github.com/user-attachments/assets/e9060b3d-9ae9-4ebb-81a5-6088bd480499)


**4. Location Analysis**
- How do prices vary by latitude/longitude (geographic distribution)?
- What's the price distribution in different zip codes?
- Are there clusters of high-value properties in specific areas?
  
```sql
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
ORDER BY avg_price;
```

**5. Market Segmentation**
- What are the characteristics of homes in different price brackets?
- How do property features differ between high-end and mid-range homes?
```sql
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

```

### 📊 Data Analysis Approach

Include some interesting code/features worked with

```sql
SELECT * FROM table1
WHERE cond = 2;
```

### 📈 Results/Findings

✔ Living area (sqft_living) have a stronger correlation with price than lot size.

✔ Price per sqft (living area) is higher than price per sqft (lot size).

✔ Medium-sized homes (1,500–3,000 sqft) show the strongest correlation.

✔ Luxury homes (>3,000 sqft) have weaker correlations due to other premium factors.



### Recommendations

Based on the analysis, we recommend the following actions:<br>
- **Prioritize Living Area in Pricing Models** - Since sqft_living is strongly correlated with price, it should be a primary predictor in any pricing algorithm or regression model.
- **Use Price-per-Sqft (Living) as a Market Benchmark** This metric performs better across diverse zip codes and home types than lot-based ratios.<br>
- **For Real Estate Agents or Platforms** - Market reports should emphasize living-area pricing.


### 📂 Repository Structure
```housing-price-analysis/  
├── data/                  # Raw dataset (CSV)  
├── sql_queries/           # SQL scripts for analysis  
│   ├── correlation_analysis.sql  
│   ├── price_per_sqft.sql  
│   └── zipcode_analysis.sql  
├── notebooks/             # (Optional) Jupyter notebooks for visualization  
├── docs/                  # Project documentation  
└── README.md              # Overview & setup instructions  
```
### 🚀 How to Use This Project
1. Clone the repo:
```bash
git clone https://github.com/mactimx/housing_project.git
```
2. Run SQL queries (using PostgreSQL, MySQL, or BigQuery).
3. Visualize results (optional Python scripts).
   
### 📜 License
This project is open-source under the **MIT License.**


