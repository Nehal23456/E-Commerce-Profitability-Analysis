CREATE TABLE orders (
order_id VARCHAR(100),
customer_id VARCHAR(100),
order_date DATE,
channel VARCHAR(100),
payment_method VARCHAR(100),
region VARCHAR(100),
items_ordered INT,
primary_category VARCHAR(100),
gross_revenue DECIMAL(100,2),
discount_pct INT,
discount_amount DECIMAL(10,2),
shipping_cost DECIMAL(10,2),
product_cost DECIMAL(10,2),
platform_fee DECIMAL(10,2),
transaction_fee DECIMAL(10,2),
returned VARCHAR(100),
refund_amount DECIMAL(100,2),
net_revenue DECIMAL(100,2),
total_costs DECIMAL(100,2),
profit DECIMAL(100,2)
);

SELECT * FROM orders;

CREATE TABLE products (
product_id VARCHAR(100),
product_name VARCHAR(100),
category VARCHAR(100),
sub_category VARCHAR(100),
unit_cost DECIMAL(10,2),
selling_price DECIMAL(10,2),
shipping_cost_per_unit DECIMAL(100,2),
weight_lbs DECIMAL(10,2),
supplier VARCHAR(100),
customer_id VARCHAR(100)
);

CREATE TABLE marketing_spend (
month VARCHAR(100),
platform VARCHAR(100),
spend DECIMAL(10,2),
impressions INT,
clicks INT,
conversions INT,
revenue_attributed DECIMAL(10,2),
cpc DECIMAL(10,2),
cpa DECIMAL(10,2),
roas DECIMAL(10,2)
);


SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM marketing_spend;

   --- CATEGORY PROFITABILITY ---

-- 1. Group orders by product category
SELECT COUNT(order_id) AS no_of_orders, primary_category FROM orders
GROUP BY primary_category;

-- 2. Calculate total revenue, total costs, total profit and profit margin for each
SELECT ROUND(SUM(gross_revenue), 2) AS total_revenue, ROUND(SUM(profit), 2) AS total_profit,
ROUND((SUM(profit)/SUM(gross_revenue)*100),2) AS profit_margin 
FROM orders;

-- 3. Compare profitability by channel
SELECT (*), 
ROUND(SUM(gross_revenue), 2) AS gross_revenue,
ROUND(SUM(profit), 2) AS profit,

 --- CHANNEL ANALYSIS ---

-- 3. Identify the top and bottom performers
SELECT primary_category, SUM(profit) AS top_performer
FROM orders
GROUP BY primary_category
ORDER BY 2 DESC LIMIT 1;

SELECT primary_category, SUM(profit) AS bottom_performer
FROM orders
GROUP BY primary_category
ORDER BY 2 ASC LIMIT 1;

 --- MARKETING ROI ---

-- 1. Group by sales channel
SELECT channel, COUNT(order_id) AS no_of_orders
FROM orders
GROUP BY channel;

-- 2. Compare average order value, average profit and return rate cross channels
SELECT ROUND(AVG(gross_revenue), 2) AS average_order_value, 
ROUND(AVG(profit), 2) AS average_profit,
ROUND(AVG(
CASE 
WHEN returned = 'Yes' THEN 1
ELSE 0
END 
), 2) AS return_rate
FROM orders;

-- 3. Factor in platform fees for Marketplace and Social Commerce
SELECT channel,
ROUND(SUM(platform_fee), 2) AS PF_sum,
ROUND(AVG(platform_fee), 2) AS PF_avg
FROM orders
WHERE channel IN ('Marketplace', 'Social Commerce')
GROUP BY channel;

-- 4. Compare channels by profitability
SELECT channel,
ROUND(SUM(gross_revenue), 2) AS gross_revenue,
ROUND(SUM(profit), 2) AS profit,
ROUND((SUM(profit)/SUM(gross_revenue))*100, 2) AS profit_margin
FROM orders
GROUP BY channel;


-- 1. Analyze the marketing spend dataset
SELECT platform, SUM(spend) AS total_spend, 
SUM(impressions) AS total_impressions,
SUM(clicks) AS total_clicks
FROM marketing_spend
GROUP BY platform;

-- 2. Calculate ROAS, cost per acquisition and cost per click by platform
SELECT platform, SUM(spend) AS total_spend,
SUM(revenue_attributed) AS total_revenue_attributed,
ROUND(SUM(revenue_attributed)/SUM(spend) , 2) AS ROAS
FROM marketing_spend
GROUP BY platform
ORDER BY ROAS DESC ;


SELECT platform, SUM(spend) AS total_spend,
SUM(conversions) AS total_conversations,
ROUND(SUM(spend)/SUM(conversions), 2) AS cpa
FROM marketing_spend
GROUP BY platform
ORDER BY cpa DESC;


SELECT platform, SUM(spend) AS total_spend,
SUM(clicks) AS total_clicks,
ROUND(SUM(spend)/SUM(clicks), 2) AS cpc
FROM marketing_spend
GROUP BY platform 
ORDER BY cpc DESC ;

-- 3. Identify which platforms are underperforming
SELECT platform, SUM(spend) AS total_spend,
SUM(revenue_attributed) AS total_revenue_attributed,
ROUND(SUM(revenue_attributed)/SUM(spend), 2) AS roas,
ROUND(SUM(spend)/SUM(conversions), 2) AS cpa,
ROUND(SUM(spend)/SUM(clicks), 2) AS cpc
FROM marketing_spend
GROUP BY platform
ORDER BY roas ASC;

