-- sale_order
-- order_id       user_id      order_status       create_time      last_update_time        product_id      product_num


-- user_info
-- user_id        sex          age

-- result:
-- user_id      sex     age     d7order_number      d14order_number(# of order_id)


WITH TEMP AS (
    SELECT 
        user_id,
        COUNT(DISTINCT IF(TO_DATE(create_time) BETWEEN DATE_SUB(CURRENT_DATE(), 6) AND CURRENT_DATE(), order_id, NULL)) AS 'd7order_number',
        COUNT(DISTINCT IF(TO_DATE(create_time) BETWEEN DATE_SUB(CURRENT_DATE(), 13) AND CURRENT_DATE(), order_id, NULL)) AS 'd14order_number'
    FROM 
        sale_order
    GROUP BY 
        user_id
)

SELECT 
    u.user_id,
    u.sex,
    u.age,
    s.d7order_number,
    s.d14order_number
FROM 
    user_info u 
LEFT JOIN 
    TEMP s 
ON 
    u.user_id = s. user_id;