
Nashville Housing Data Cleaning & Analysis 
==================================================================

This project showcases advanced data cleaning, transformation, and exploratory analysis on the Nashville Housing Dataset using SQL Server. The goal is to demonstrate real-world data wrangling skills, generate deep insights, and prepare a refined dataset ready for analytics or reporting use cases.

Project Structure
-----------------
File                         | Description
----------------------------|-------------------------------------------------------------
DataCleaning_Enhanced.sql   | SQL queries for cleaning and preparing the housing dataset
DataInsights_Advanced.sql   | A rich set of exploratory and advanced analytical queries

Project Objectives
------------------
- Clean & standardize messy real-estate data
- Identify and fix missing, inconsistent, or duplicate values
- Perform advanced analysis using window functions, CTEs, aggregates, etc.
- Highlight actionable insights such as pricing trends, anomalies, and property behaviors

Data Cleaning Highlights (DataCleaning_Enhanced.sql)
-----------------------------------------------------
- Removed duplicate records using ROW_NUMBER()
- Standardized categorical values (SoldAsVacant, TaxDistrict)
- Trimmed whitespaces and corrected casing
- Filled missing values using domain-based logic or statistical imputation
- Created new derived columns such as SaleYear
- Removed unrealistic or future-dated entries
- Flagged anomalies such as extremely high acreage
- Normalized address and legal references

This file reflects strong command over practical SQL cleaning techniques on semi-structured real-world data.

Data Insights Highlights (DataInsights_Advanced.sql)
-----------------------------------------------------
Includes over 40 queries that span basic to highly advanced topics:

Exploratory Queries:
- Count and trends of property sales by year, month, bath type, land use
- Top-selling properties and most active buyers

Value & Pricing Analysis:
- Average and median sale prices per year
- Price per acre, per bedroom, and per square foot
- Volatility analysis using price variance
- Undervalued property detection (e.g., SalePrice < TotalValue × 0.6)
- Flip detection based on short resale windows

Advanced SQL Techniques:
- WINDOW FUNCTIONS: RANK, LAG, PERCENTILE_CONT, ROLLING AVERAGES
- CTEs: Complex comparisons, relative value analysis
- CORRELATIONS: Relationship between sale price and other variables
- DYNAMIC GROUPINGS: By ZIP code, land use, bedroom count, etc.
- ANOMALY FLAGS: Outlier flags, identical value mismatch detectors

These queries are crafted not only to extract insights but also to demonstrate mastery of SQL best practices for analytical problem-solving.

Tools Used
----------
- SQL Server (compatible with Azure Data Studio / SSMS)
- Dataset: Nashville Housing (real estate transactions)

Key Learning Outcomes
---------------------
- End-to-end SQL workflow from raw import → clean → analyze
- Writing modular, optimized, and maintainable SQL queries
- Preparing datasets for BI reporting or modeling
- Thinking like a data analyst: deriving value beyond the obvious

Ideal For
---------
- Data Analyst / Data Engineer portfolios
- Technical interview prep (SQL case studies)
- GitHub profile enhancement
- SQL-based data cleaning projects

How to Use
----------
1. Open either `.sql` file in your SQL Server tool (e.g., SSMS, Azure Data Studio)
2. Execute the cleaning script to prepare the dataset
3. Run queries from DataInsights_Advanced.sql to explore data-driven insights
4. Extend the analysis or join with other datasets to level up

Future Improvements
-------------------
- Export cleaned data to Power BI or Tableau for visual dashboards
- Join with external data (e.g., crime rates, schools) for geospatial insight
- Automate via stored procedures or pipelines (SSIS, Airflow, etc.)

Conclusion
----------
This project demonstrates how raw data can be converted into structured insights using SQL alone. The queries reflect real-world data quality challenges and illustrate how to extract meaningful patterns, trends, and business signals effectively.

Feel free to star, fork, or reference this project in your portfolio.
