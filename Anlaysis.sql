SELECT city, state, count(*) AS order_count, SUM(price) AS total_revenue
FROM customer_location
GROUP BY city, state
ORDER BY 3 DESC, 4 DESC;

SELECT ProductCategory, ROUND(SUM(price)) AS total_revenue, ROUND(AVG(price), 2) AS average_order_value 
FROM product_category
WHERE ProductCategory IS NOT NULL
GROUP BY ProductCategory
ORDER BY 2 DESC;

SELECT ProductCategory, SUM(Q1) as Q1_revenue, 
        SUM(Q2) as Q2_revenue, 
        SUM(Q3) as Q3_revenue, 
        SUM(Q4) as Q4_revenue 
FROM
(SELECT month, orderid, price,productcategory,productid,purchasetimestamp, 
    CASE
        WHEN month <=3 THEN price
        ELSE 0
    END AS Q1,
    CASE
        WHEN month >3 and month < 7 THEN price
        ELSE 0
    END AS Q2,
    CASE
        WHEN month >7 and month < 10 THEN price
        ELSE 0
    END AS Q3,
    CASE
        WHEN month >10 THEN price
        ELSE 0
    END AS Q4
FROM (
SELECT EXTRACT(MONTH FROM purchasetimestamp) AS month, orderid, price,productcategory,productid,purchasetimestamp
FROM product_category
))
WHERE ProductCategory IS NOT NULL
GROUP BY ProductCategory
ORDER BY 2 DESC, 3 DESC, 4 DESC, 5 DESC;

SELECT SellerState, CustomerState, count(*) AS order_count, SUM(price) AS total_revenue
FROM seller_state
GROUP BY SellerState, CustomerState
ORDER BY 3 DESC, 4 DESC;