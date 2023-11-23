SELECT product_id, store1, store2, store3
FROM Products

PIVOT(
    max(price) for store in (store1, store2, store3)
) cte2



select product_id, store, price
from(
    select *
    from Products
)t1
UNPIVOT(
    price for store in (store1, store2, store3)
)t2