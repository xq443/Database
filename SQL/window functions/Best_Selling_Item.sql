WITH CTE AS(
    SELECT
        DATE_FORMAT(invoiceddate, '%m') AS "month",
        SUM(quantity * unitprice) AS total_invoice,
        description,
        DENSE_RANK() OVER(PARTITION BY DATE_FORMAT(invoiceddate, '%m') ORDER BY SUM(quantity * unitprice)) AS rnk
    FROM  online_retail
    GROUP BY DATE_FORMAT(invoiceddate, '%m'), description
    ORDER BY DATE_FORMAT(invoiceddate, '%m'), description
)

SELECT month, description, total_invoice
FROM CTE
WHERE rnk = 1;