
ALTER TABLE [dbo].[Bill_Description]  WITH CHECK ADD FOREIGN KEY([bill_id])
REFERENCES [dbo].[Bill_Details] ([bill_id])
GO
ALTER TABLE [dbo].[Bill_Description]  WITH CHECK ADD FOREIGN KEY([product_id])
REFERENCES [dbo].[Inventory] ([product_id])
GO
ALTER TABLE [dbo].[Bill_Details]  WITH CHECK ADD FOREIGN KEY([store_name])
REFERENCES [dbo].[Store] ([store_name])
GO
ALTER TABLE [dbo].[USer_Bill ]  WITH CHECK ADD FOREIGN KEY([bill_id])
REFERENCES [dbo].[Bill_Details] ([bill_id])
GO

SELECT
    u.user_id,
    SUM(bd.bill_value) AS total_purchase_amount
FROM
    user_bill u
    JOIN bill_details bd ON u.bill_id = bd.bill_id
GROUP BY
    u.user_id
HAVING
    SUM(bd.bill_value) > 1000  
ORDER BY
    total_purchase_amount DESC;

--USer LOyalty 
SELECT
    u.user_id,
    COUNT(DISTINCT bd.store_name) AS unique_stores_visited,
    COUNT(DISTINCT bd.bill_id) AS total_transactions
FROM
    user_bill u
    JOIN bill_details bd ON u.bill_id = bd.bill_id
GROUP BY
    u.user_id
ORDER BY
    total_transactions DESC;

---USER TRANSACTION COUNT
SELECT
    u.user_id,
    COUNT(bd.bill_id) AS transaction_count
FROM
    user_bill u
    JOIN bill_details bd ON u.bill_id = bd.bill_id
GROUP BY
    u.user_id
HAVING
    COUNT(bd.bill_id) > 10  -- Set your threshold for high-frequency users
ORDER BY
    transaction_count DESC;
	
	---USER DISTRIBUTION ACROSS ZONES
	SELECT
    s.zone_name,
    COUNT(DISTINCT u.user_id) AS user_count
FROM
    user_bill u
    JOIN bill_details bd ON u.bill_id = bd.bill_id
    JOIN store s ON bd.store_name = s.store_name
GROUP BY
    s.zone_name
ORDER BY
    user_count DESC;

	--Store Analysis:
--Total Sales by Store:


SELECT
    store_name,
    SUM(bill_value) AS total_sales
FROM
    bill_details
GROUP BY
    store_name;

--Average Discount by Store:
SELECT
    store_name,
    AVG(bill_discount) AS average_discount
FROM
    bill_details
GROUP BY
    store_name;

--Inventory Analysis:

--Product Count by Category:


SELECT
    inventory_category,
    COUNT(*) AS product_count
FROM
    inventory
GROUP BY
    inventory_category;

--Average Price by Category:

SELECT
    inventory_category,
    AVG(price) AS average_price
FROM
    inventory
GROUP BY
    inventory_category;

--Bill Details Analysis:
--Monthly Sales Trend:


SELECT
    YEAR(transaction_date) AS year,
    MONTH(transaction_date) AS month,
    SUM(bill_value) AS monthly_sales
FROM
    bill_details
GROUP BY
    YEAR(transaction_date), MONTH(transaction_date);

--Top 5 Bills with Highest Discount:
SELECT TOP 5
    bill_id,
    bill_discount
FROM
    bill_details
ORDER BY
    bill_discount DESC;

--User Analysis:
--Top 3 Purchasers:
SELECT TOP 3
    u.user_id,
    SUM(bd.bill_value) AS total_purchase_amount
FROM
    user_bill u
    JOIN bill_details bd ON u.bill_id = bd.bill_id
GROUP BY
    u.user_id
ORDER BY
    total_purchase_amount DESC;

--User Purchase Frequency:


SELECT
    u.user_id,
    COUNT(bd.bill_id) AS purchase_frequency
FROM
    user_bill u
    JOIN bill_details bd ON u.bill_id = bd.bill_id
GROUP BY
    u.user_id;

--Advanced Analysis:
--Products Bought Together (Association Analysis):

SELECT
    bd1.product_id AS product1,
    bd2.product_id AS product2,
    COUNT(*) AS frequency
FROM
    bill_description bd1
    JOIN bill_description bd2 ON bd1.bill_id = bd2.bill_id
WHERE
    bd1.product_id < bd2.product_id
GROUP BY
    bd1.product_id, bd2.product_id
ORDER BY
    frequency DESC;
SELECT
    u.user_id,
    YEAR(bd.transaction_date) AS year,
    MONTH(bd.transaction_date) AS month,
    SUM(bd.bill_value) AS monthly_spending
FROM
    user_bill u
    JOIN bill_details bd ON u.bill_id = bd.bill_id
GROUP BY
    u.user_id, YEAR(bd.transaction_date), MONTH(bd.transaction_date)
ORDER BY
    monthly_spending DESC;

--TOP 3 profitable products 
SELECT TOP 3
    bld.product_id,
    SUM(bd.bill_value) AS total_sales,
    AVG(bd.bill_discount) AS average_discount
FROM
    bill_details bd
    JOIN bill_description bld ON bd.bill_id = bld.bill_id
GROUP BY
    bld.product_id
ORDER BY
    total_sales DESC, average_discount;

--Total Sales by Store:


SELECT
    store_name,
    SUM(bill_value) AS total_sales
FROM
    bill_details
GROUP BY
    store_name;

--Average Discount by Store:

SELECT
    store_name,
    AVG(bill_discount) AS average_discount
FROM
    bill_details
GROUP BY
    store_name;

--Stores with the Highest Total Sales:

SELECT TOP 3
    store_name,
    SUM(bill_value) AS total_sales
FROM
    bill_details
GROUP BY
    store_name
ORDER BY
    total_sales DESC;

--Average Transaction Value by Store Over Time:
SELECT
    store_name,
    YEAR(transaction_date) AS transaction_year,
    AVG(bill_value) AS avg_transaction_value
FROM
    bill_details
GROUP BY
    store_name, YEAR(transaction_date)
ORDER BY
    store_name, transaction_year;

--Monthly Sales Trend for a Specific Store:

SELECT
    store_name,
    YEAR(transaction_date) AS transaction_year,
    MONTH(transaction_date) AS transaction_month,
    SUM(bill_value) AS monthly_sales
FROM
    bill_details
GROUP BY
    store_name, YEAR(transaction_date), MONTH(transaction_date)
ORDER BY
    store_name, transaction_year, transaction_month;

--Top 3 Stores by Average Transaction Value:

SELECT TOP 3
    store_name,
    AVG(bill_value) AS avg_transaction_value
FROM
    bill_details
GROUP BY
    store_name
ORDER BY
    avg_transaction_value DESC;


--Stores with High Sales Growth Rate:
SELECT
    store_name,
    (SUM(bill_value) - LAG(SUM(bill_value)) OVER (ORDER BY YEAR(transaction_date), MONTH(transaction_date))) / LAG(SUM(bill_value)) OVER (ORDER BY YEAR(transaction_date), MONTH(transaction_date)) AS sales_growth_rate
FROM
    bill_details
GROUP BY
    store_name
ORDER BY
    sales_growth_rate DESC;

--Stores with High and Low Discount Variation:
SELECT
    store_name,
    MAX(bill_discount) - MIN(bill_discount) AS discount_variation
FROM
    bill_details
GROUP BY
    store_name
ORDER BY
    discount_variation DESC;

--Stores with Consistently High Sales:

SELECT
    store_name,
    COUNT(DISTINCT YEAR(transaction_date)) AS consecutive_years
FROM
    bill_details
GROUP BY
    store_name
HAVING
    COUNT(DISTINCT YEAR(transaction_date)) = (SELECT COUNT(DISTINCT YEAR(transaction_date)) FROM bill_details);

--Top 3 Stores with High Sales and Low Discount:
SELECT TOP 3
    store_name,
    SUM(bill_value) AS total_sales,
    AVG(bill_discount) AS average_discount
FROM
    bill_details
GROUP BY
    store_name
ORDER BY
    total_sales DESC, average_discount ASC;

--Total Product Count by Category:

SELECT
    inventory_category,
    COUNT(*) AS product_count
FROM
    inventory
GROUP BY
    inventory_category;

--Average Price by Category:
SELECT
    inventory_category,
    AVG(price) AS average_price
FROM
    inventory
GROUP BY
    inventory_category;

--Top 5 Expensive Products:
SELECT TOP 5
    product_id,
    description,
    price
FROM
    inventory
ORDER BY
    price DESC;

--Products with Low Inventory (Less Than 10 Units):

SELECT
    product_id,
    description,
    COUNT(*) AS inventory_count
FROM
    inventory
GROUP BY
    product_id, description
HAVING
    inventory_count < 10;

--Average Inventory Age by Category:


SELECT
    inventory_category,
    AVG(DATEDIFF(YEAR, creation_date, GETDATE())) AS average_inventory_age
FROM
    inventory
GROUP BY
    inventory_category;

--Products with Zero Sales:
SELECT
    i.product_id,
    i.description,
    COUNT(bd.product_id) AS total_sales
FROM
    inventory i
    LEFT JOIN bill_description bd ON i.product_id = bd.product_id
GROUP BY
    i.product_id, i.description
HAVING
    COUNT(bd.product_id) = 0;

--Products with Highest and Lowest Inventory Turnover:
SELECT
    i.product_id,
    i.description,
    COUNT(bd.product_id) / DATEDIFF(MONTH, MIN(bd.transaction_date), MAX(bd.transaction_date)) AS inventory_turnover
FROM
    inventory i
    LEFT JOIN bill_description bd ON i.product_id = bd.product_id
GROUP BY
    i.product_id, i.description
ORDER BY
    inventory_turnover DESC;

--Products with Consistently Low Inventory:
SELECT
    i.product_id,
    i.description,
    COUNT(bd.product_id) AS total_sales
FROM
    inventory i
    LEFT JOIN bill_description bd ON i.product_id = bd.product_id
GROUP BY
    i.product_id, i.description
HAVING
    COUNT(bd.product_id) > 0
    AND COUNT(bd.product_id) < 5;

--Inventory Categories with Maximum Products:

SELECT
    inventory_category,
    COUNT(*) AS product_count
FROM
    inventory
GROUP BY
    inventory_category
ORDER BY
    product_count DESC;

--Products with Highest and Lowest Price in Each Category:

SELECT
    inventory_category,
    MAX(price) AS highest_price,
    MIN(price) AS lowest_price
FROM
    inventory
GROUP BY
    inventory_category;
