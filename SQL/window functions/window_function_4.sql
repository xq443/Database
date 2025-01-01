-- goods_type      goods_name      price
-- phone           iphone          3099
-- phone           huawei          3099
-- phone           xiaomi          3099
-- fruits          apple           40
-- fruits          pomegrande      40
-- fruits          guava           40
-- laptop          macbook         9931
-- laptop          macbook         9931
-- laptop          macbook         9931

-- parttion by goods_type, sort the price in asc order, 30% low, 30% - 85% mid, 85% high

WITH RANKING AS( 
    SELECT 
        goods_name,
        price,
        goods_type,
        ROW_NUMBER() OVER(PARTITION BY goods_type ORDER BY price) AS rnk,
        COUNT(1) OVER(PARTITION BY goods_type) AS cnt_by_type
    FROM 
        TABLE 
),

PROPORTION AS (
    SELECT 
        goods_name,
        price,
        goods_type,
        rnk / cnt_by_type AS proportion
    FROM 
        RANKING
)

SELECT
    goods_name,
    price,
    goods_type,
    CASE WHEN proportion < 0.3 THEN 'low' 
         WHEN proportion >= 0.3 AND proportion <= 0.85 THEN 'mid' 
         WHEN proportion >= 0.85 THEN 'high'
    END AS tag
FROM 
    PROPORTION;
