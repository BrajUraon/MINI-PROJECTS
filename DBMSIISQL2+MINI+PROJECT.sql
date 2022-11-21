-- MINI PROJECT SQL2 --

create database SQL2_project2;
use SQL2_project2;

#Composite data of a business organisation, confined to ‘sales and delivery’ domain is given for the period of last decade. 
#From the given data retrieve solutions for the given scenario.

#Q1. Join all the tables and create a new table called combined_table.
#(market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)
-- Solution
CREATE TABLE combined_table AS
SELECT mf.Ord_id,mf.Prod_id,mf.Ship_id,mf.Cust_id,Sales,Discount,Order_Quantity,Profit,Shipping_Cost,Product_Base_Margin,
Customer_Name,Province,Region,Customer_Segment,od.Order_ID,Order_Date,Order_Priority,Product_Category,Product_Sub_Category,Ship_Mode,Ship_Date
FROM market_fact mf 
JOIN cust_dimen cd 
ON mf.cust_id=cd.cust_id 
JOIN orders_dimen od 
ON mf.Ord_id=od.Ord_id
JOIN prod_dimen pd 
ON mf.Prod_id=pd.Prod_id 
join shipping_dimen sd 
ON mf.Ship_id=sd.Ship_id;

SELECT*FROM combined_table;

#Q2. Find the top 3 customers who have the maximum number of orders
-- Solution
SELECT mf.cust_id,customer_name,count(distinct Ord_id) order_count
FROM market_fact mf 
JOIN cust_dimen cd
ON mf.cust_id=cd.cust_id
GROUP BY mf.cust_id,customer_name
ORDER BY order_count DESC
LIMIT 3;

#Q3. Create a new column DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
UPDATE combined_table SET Ship_Date = STR_TO_DATE(Ship_Date, '%d-%m-%Y');

ALTER TABLE combined_table MODIFY Ship_Date DATE;

UPDATE combined_table SET Order_Date = STR_TO_DATE(Order_Date, '%d-%m-%Y');

ALTER TABLE combined_table MODIFY Order_Date DATE;

ALTER TABLE combined_table ADD COLUMN DaysTakenForDelivery INT;

UPDATE combined_table SET DaysTakenForDelivery = DATEDIFF(Ship_Date, Order_Date);

select cust_id,customer_name,ship_date,order_date,daystakenfordelivery from combined_table;

#Q4. Find the customer whose order took the maximum time to get delivered.
-- Solution
SELECT cust_id,customer_name,MAX(daystakenfordelivery) FROM combined_table;

#Q5. Retrieve total sales made by each product from the data (use Windows function).
-- Solution
SELECT DISTINCT Prod_id,TRUNCATE(SUM(Sales) over(PARTITION BY Prod_id),2) Total_Sales FROM combined_table;

#Q6. Retrieve total profit made from each product from the data (use windows function).
-- Solution
SELECT DISTINCT Prod_id,TRUNCATE(SUM(Profit) OVER(PARTITION BY Prod_id),2) Total_Profit FROM combined_table;

#Q7. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011.
-- Solution
SELECT * FROM (
SELECT (
SELECT COUNT(cn) FROM (
SELECT DISTINCT customer_name cn 
FROM combined_table 
WHERE MONTHNAME(order_date)='January')t1)total_unique_jan,
CASE WHEN(COUNT(DISTINCT MONTH(order_date) IN (2,3,4,5,6,7,8,9,10,11,12) AND YEAR(order_date)='2011') )
THEN COUNT(customer_name) ELSE 0 END total_month_count FROM combined_table)t2;


#Q8. Retrieve month-by-month customer retention rate since the start of the business.(using views)
## Tips:
#1: Create a view where each user’s visits are logged by month, allowing for the possibility that these will have occurred over multiple 
# years since whenever business started operations
# 2: Identify the time lapse between each visit. So, for each person and for each month, we see when the next visit is.
# 3: Calculate the time gaps between visits
# 4: categorise the customer with time gap 1 as retained, >1 as irregular and NULL as churned
# 5: calculate the retention month wise
-- Solution
CREATE OR REPLACE VIEW v1 AS
SELECT cust_id,customer_name,order_date FROM combined_table;
SELECT * FROM v1;
SELECT abc Month,100-per Retention_rate FROM(
SELECT * FROM (
SELECT *,MAX(c1) OVER(PARTITION BY abc),c1/MAX(c1) OVER(PARTITION BY abc)*100 per 
FROM (SELECT abc,category,COUNT(*)c1 
FROM(SELECT cust_id customer_id,customer_name,abc, CASE WHEN dd<=1 THEN 'retained' WHEN dd>1 THEN 'irregular' ELSE 'churned' END category
FROM (SELECT a-MONTH(order_date)dd,cust_id,customer_name,MONTH(order_date)abc 
FROM (SELECT cust_id,customer_name,MONTHNAME(order_date),MONTH(order_date)abc,YEAR(order_date),order_date,
LEAD(MONTH(order_date))OVER(PARTITION BY cust_id,YEAR(order_date) ORDER BY MONTH(order_date))a
FROM v1)t)t1 ORDER BY abc)uff GROUP BY abc,category WITH ROLLUP ORDER BY abc)uff2)uff3 WHERE category='churned')uff4;
