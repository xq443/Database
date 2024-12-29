-- Mock question 2: 

-- when kill 3 consecutively, the sound effect is "killing spree"
-- when kill 4 consecutively, the sound effect is "dominating"
-- know the timestamp when the sound effect plays
-- table schema : index, player_id, timestamp, kill_or_dead


-- row_number      player_id        time_stamp       kill_or_dead
--     1           ginger      2022-06-03 00:00:00        1        
--     2           ginger      2022-06-04 00:00:00        1 
--     3           ginger      2022-06-04 00:00:00        1    
--     4           ginger      2022-06-05 00:00:00        1      
--     5           ginger      2022-06-05 00:00:00        0  
--     6           ginger      2022-06-05 00:00:00        0  
--     7           ginger      2022-06-05 00:00:00        0  
        
WITH TEMP1 AS (
    SELECT  
        player_id,
        time_stamp,
        kill_or_dead,
        row_number,
        ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY time_stamp) AS consecutive_row_number,
        row_number - ROW_NUMBER() OVER(PARTITION BY player_id ORDER BY time_stamp) AS status_indicator
    FROM 
        table 
    WHERE 
        kill_or_dead = 1
    ORDER BY 
        row_number
),

TEMP2 AS (
    SELECT 
        player_id,
        time_stamp,
        kill_or_dead,
        status_indicator,
        ROW_NUMBER() OVER(PARITIION BY player_id, status_indicator ORDER BY time_stamp) AS consecutive_kills
    FROM    
        TEMP1 
)

SELECT
    *,
    CASE WHEN consecutive_kills = 3 THEN 'killing spree'
        WHEN consecutive_kills = 4 THEN 'dominating'
        ELSE 'no_sound' 
        END AS sound 
FROM 
    TEMP2 
WHERE 
    consecutive_kills >= 3
ORDER BY 
    time_stamp
