SELECT COUNT(DISTINCT category_name) as cnt,
        AVG(bottle_price) as avg_price
FROM table
GROUP BY vendor
ORDER BY COUNT(DISTINCT category_name) 