SELECT product_id, store1, store2, store3
FROM Products

PIVOT(
    max(price) for store in (store1, store2, store3)
) cte2

SELECT
  product_id,
  MAX(CASE WHEN store = 'store1' THEN price END) AS store1,
  MAX(CASE WHEN store = 'store2' THEN price END) AS store2,
  MAX(CASE WHEN store = 'store3' THEN price END) AS store3
FROM Products GROUP BY product_id;


select product_id, store, price
from(
    select *
    from Products
)t1
UNPIVOT(
    price for store in (store1, store2, store3)
)t2

SELECT product_id, 'store1' AS store, store1 AS price 
FROM Products 
WHERE store1 IS NOT NULL
UNION 
SELECT product_id, 'store2' AS store, store2 AS price 
FROM Products 
WHERE store2 IS NOT NULL
UNION 
SELECT product_id, 'store3' AS store, store3 AS price 
FROM Products 
WHERE store3 IS NOT NULL