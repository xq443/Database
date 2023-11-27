-- Input:
-- flights table
-- id     destination_location   source_location  plane_id  flight_start  flight_end
--                                                           DATETIME       DATETIME

-- Output:
-- id     destination_location   source_location    flight_start  flight_end

--extract the 2nd longest flight between each pair of cities. Order the flights by the flight id asc
--A->B  B->A are counted as the same pair of cities


WITH CTE1 AS(
    -- source -> destination
    SELECT
        id,
        CONCAT(source_location,'-',destination_location) AS trip_id
        destination_location,
        source_location,
        flight_start,
        flight_end,
        TIMESTAMPDIFF(SECOND, flight_start, flight_end) AS flight_time
    FROM
        flights

    UNION
     -- destination -> source
    SELECT
        id,
        CONCAT(destination_location,'-',source_location) AS trip_id
        destination_location,
        source_location,
        flight_start,
        flight_end,
        TIMESTAMPDIFF(SECOND, flight_start, flight_end) AS flight_time
    FROM
        flights
), 
CTE2 AS(
    SELECT 
        id,
        trip_id,
        destination_location, 
        source_location,
        flight_start,
        flight_end,
        ROW_NUMBER()OVER(PARTITION BY trip_id ORDER BY flight_time DESC) AS rnk
    FROM 
        CTE1
)

SELECT 
    DISTINCT id,
    destination_location, 
    source_location,
    flight_start,
    flight_end
FROM 
    CTE2
WHERE 
    rnk = 2
ORDER BY
    id

