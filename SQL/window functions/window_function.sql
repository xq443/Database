-- cid     sname       score
-- 1       cathy       89
-- 1       qin         88
-- 1       yy          99
-- 1       kd          22
-- 2       kj          24
-- 2       maeey       98

SELECT
    *,
    -- calculate the total score of each class
    SUM(score) OVER(PARTITION BY cid) AS 'total_score_class',

    -- for each class, calculate the total score less than or equal to the student's score.
    SUM(score) OVER(PARTITION BY cid ORDER BY score ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'accumulatice_score',

    -- ROW_NUMBER, DENSE_RANK, RANK
    -- sort by score asc for each class
    ROW_NUMBER() OVER(PARTITION BY cid ORDER BY score) AS 'score_rnk',
    -- 1 2 2 4 5
    RANK() OVER(PARTITION BY cid ORDER BY score) AS 'score_rnk_same',
    -- 1 2 2 3 4
    DENSE_RANK() OVER(PARTITION BY cid ORDER BY score) AS 'score_rnk_dense',

    -- lead/lag (col, offset, default)
    LAG(score, 1, 0) OVER(PARTITION BY cid ORDER BY score) AS 'lower_score',
    LEAD(score, 1, 0) OVER(PARTITION BY cid ORDER BY score) AS 'higher_score'
FROM
    score
