CREATE TABLE transactions (
    warehouse VARCHAR(30) NOT NULL,
    status VARCHAR(30) NOT NULL,
    units INT(6) UNSIGNED,
    time time NOT NULL
);

INSERT INTO transactions (warehouse, status, units, time)
VALUES 
    ('xyz', 'start', 1, '01:00:00'),
    ('xyz', 'add', 2, '02:00:00'),
    ('xyz', 'add', 1, '03:00:00'),
    ('xyz', 'complete', null, '04:00:00'),
    ('xyz', 'start', 3, '05:00:00'),
    ('xyz', 'add', 2, '06:00:00'),
    ('xyz', 'complete', null, '07:00:00');

INSERT INTO transactions (warehouse, status, units, time)
VALUES 
    ('abc', 'start', 1, '01:00:00'),
    ('abc', 'add', 2, '02:00:00'),
    ('abc', 'complete', null, '04:00:00');


WITH s AS (
    SELECT 
        warehouse,
        `time` AS starttime,
        ROW_NUMBER() OVER (PARTITION BY warehouse ORDER BY `time`) AS sessionId
    FROM transactions
    WHERE status = 'start'
),
e AS (
    SELECT 
        warehouse,
        `time` AS endtime,
        ROW_NUMBER() OVER (PARTITION BY warehouse ORDER BY `time`) AS sessionId
    FROM transactions
    WHERE status = 'complete'
)
SELECT 
    s.warehouse,
    s.sessionId AS loop,
    COALESCE(SUM(t.units), 0) AS totalUnits,
    s.starttime,
    e.endtime
FROM s
JOIN e ON s.warehouse = e.warehouse AND s.sessionId = e.sessionId
LEFT JOIN transactions t ON t.warehouse = s.warehouse AND t.`time` BETWEEN s.starttime AND e.endtime
GROUP BY s.warehouse, s.sessionId, s.starttime, e.endtime
ORDER BY s.warehouse, s.sessionId;

Result:
warehouse loop total_units starttime endtime
xyz         1       4      01:00:00 04:00:00
xyz         2       5      05:00:00 07:00:00