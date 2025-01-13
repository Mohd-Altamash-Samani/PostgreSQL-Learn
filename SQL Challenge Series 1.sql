-- Write a query to list distinct travel routes, normalizing source and destination, 
-- so that (source, destination) and (destination, source) are treated as the same route.

-- Creating the travel table
CREATE TABLE travel (
    source VARCHAR(15),
    destination VARCHAR(15),
    distance VARCHAR(15)
);

-- Inserting data into the travel table
INSERT INTO travel (source, destination, distance)
VALUES
    ('Thane', 'Dadar', 500),
    ('Dadar', 'Thane', 500),
    ('Karjat', 'Nashik', 200),
    ('Nashik', 'Karjat', 200),
    ('Rabodi', 'Mumbra', 1200),
    ('Mumbra', 'Rabodi', 1200);

-- Selecting all data from the travel table
SELECT * FROM travel;

-- Method 1: Using LEAST and GREATEST Functions
SELECT DISTINCT 
    LEAST(source, destination) AS source_normalized,
    GREATEST(source, destination) AS destination_normalized,
    distance
FROM travel
ORDER BY 
    source_normalized, 
    destination_normalized;

-- Method 2: Using Self-Join
WITH cte_t AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY source, destination) AS srn
    FROM travel
)
SELECT t1.source, t1.destination, t1.distance
FROM cte_t AS t1
JOIN cte_t AS t2
    ON (t1.source = t2.destination AND t1.destination = t2.source)
    AND t1.srn < t2.srn;

-- Write a query to generate all possible pairs of teams such that no team is paired with itself, 
-- and each pair is listed only once.

-- Creating the match table
CREATE TABLE match (
    team VARCHAR(10)
);

-- Inserting data into the match table
INSERT INTO match (team)
VALUES
    ('Aus'),
    ('Ind'),
    ('Eng'),
    ('Pak');

-- Selecting all data from the match table
SELECT * FROM match;

-- Generating All Possible Pairs
WITH cte AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY team ASC) AS id
    FROM match
)
SELECT a.team AS team1, b.team AS team2
FROM cte AS a
JOIN cte AS b
    ON a.id != b.id
WHERE a.id < b.id
ORDER BY a.team, b.team;

-- Divide employees into 4 equal-sized groups and display the concatenated employee IDs and names for each group.

-- Creating the emp table
CREATE TABLE emp (
    ID INT,
    name VARCHAR(10)
);

-- Inserting data into the emp table
INSERT INTO emp (ID, name)
VALUES
    (1, 'emp1'),
    (2, 'emp2'),
    (3, 'emp3'),
    (4, 'emp4'),
    (5, 'emp5'),
    (6, 'emp6'),
    (7, 'emp7'),
    (8, 'emp8');

-- Selecting all data from the emp table
SELECT * FROM emp;

-- Group Employees into Equal-Sized Groups
WITH cte AS (
    SELECT 
        CONCAT(ID, ' ', name) AS con,
        NTILE(4) OVER () AS groups
    FROM emp
)
SELECT 
    STRING_AGG(con, ', ') AS result,
    groups
FROM cte
GROUP BY groups
ORDER BY groups;

-- To generate a table of 7 using recursion in SQL

WITH RECURSIVE TableOfSeven AS (
    SELECT 1 AS multiplier, 7 AS result
    UNION ALL

    SELECT multiplier + 1, 7 * (multiplier + 1)
    FROM TableOfSeven
    WHERE multiplier < 10  
)
SELECT multiplier, result
FROM TableOfSeven;

