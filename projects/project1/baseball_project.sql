/* -------------------- BASEBALL DATABASE DATA ANALYSIS --------------------------
Database: Sean Lahman Baseball Database
*/

--------------------------------------- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
SELECT * FROM schools;
SELECT * FROM school_details;


-- 2. In each decade, how many schools were there that produced players?
SELECT 
    (yearid / 10)::int * 10 AS decade, -- making sure yearid is an integer
    COUNT(DISTINCT schoolid) AS num_schools
FROM schools
GROUP BY (yearid / 10) * 10
ORDER BY decade;


-- 3. What are the names of the top 5 schools that produced the most players?
SELECT 
    sd.name_full,
    COUNT(DISTINCT s.playerid) AS total_players
FROM schools s
JOIN school_details sd
    ON s.schoolid = sd.schoolid
GROUP BY sd.name_full
ORDER BY total_players DESC
LIMIT 5;


-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
WITH ranked_schools AS (
    SELECT 
        sd.name_full,
        (s.yearid / 10)::int * 10 AS decade,
        COUNT(DISTINCT s.playerid) AS total_players,
        ROW_NUMBER() OVER (
            PARTITION BY (s.yearid / 10)::int * 10
            ORDER BY 
                COUNT(DISTINCT s.playerid) DESC,
                sd.name_full ASC
        ) AS decade_rank
    FROM schools s
    INNER JOIN school_details sd
        ON s.schoolid = sd.schoolid
    GROUP BY 
        (s.yearid / 10)::int * 10,
        sd.name_full
)
SELECT 
    decade,
    name_full,
    total_players,
    decade_rank
FROM ranked_schools
WHERE decade_rank <= 3
ORDER BY decade, decade_rank, name_full;


--------------------------------------- PART II: SALARY ANALYSIS
-- 1. View the salaries table
SELECT teamid FROM salaries
GROUP BY teamid;

-- 2. Return the top 20% of teams in terms of average annual spending
WITH avg_salary AS (
    SELECT 
        teamid, 
        ROUND(AVG(salary), 2) AS team_avg_salary
    FROM salaries
    GROUP BY teamid
),
ranked_teams AS (
    SELECT 
        teamid,
        team_avg_salary,
        NTILE(5) OVER (
            ORDER BY team_avg_salary DESC
        ) AS spending_group
    FROM avg_salary
)
SELECT 
    teamid,
    team_avg_salary
FROM ranked_teams
WHERE spending_group = 1
ORDER BY team_avg_salary DESC;


-- 3. For each team, show the cumulative sum of spending over the years
WITH annual_spending AS (
    SELECT 
        teamid,
        yearid,
        SUM(salary) AS annual_salary
    FROM salaries
    GROUP BY teamid, yearid
),
cumulative_spending AS (
    SELECT 
        teamid,
        yearid,
        annual_salary,
        SUM(annual_salary) OVER (
            PARTITION BY teamid
            ORDER BY yearid
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_salary
    FROM annual_spending
)
SELECT *
FROM cumulative_spending
ORDER BY teamid, yearid;


-- 4. Return the first year that each team's cumulative spending surpassed 1 billion

WITH annual_spending AS (
    SELECT 
        teamid,
        yearid,
        SUM(salary) AS annual_salary
    FROM salaries
    WHERE salary IS NOT NULL
    GROUP BY teamid, yearid
),
cumulative_spending AS (
    SELECT 
        teamid,
        yearid,
        annual_salary,
        SUM(annual_salary) OVER (
            PARTITION BY teamid
            ORDER BY yearid
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_salary
    FROM annual_spending
),
first_billion_year AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY teamid
            ORDER BY yearid
        ) AS row_num
    FROM cumulative_spending
    WHERE cumulative_salary > 1000000000
)
SELECT 
    teamid,
    yearid AS first_year_over_1b,
    annual_salary,
    cumulative_salary
FROM first_billion_year
WHERE row_num = 1
ORDER BY teamid;



--------------------------------------- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table
SELECT COUNT(DISTINCT playerid) 
FROM players;

-- 2. For each player, calculate their age at their first game,
-- their age at their last game, and their career length in years.
-- Sort from longest career to shortest career.

SELECT 
    namegiven,
    debut,
    finalgame,
    MAKE_DATE(birthyear, birthmonth, birthday) AS birth_date,
    DATE_PART('year', AGE(debut, MAKE_DATE(birthyear, birthmonth, birthday))) 
        AS first_game_age,
    DATE_PART('year', AGE(finalgame, MAKE_DATE(birthyear, birthmonth, birthday))) 
        AS last_game_age,
    DATE_PART('year', AGE(finalgame, debut)) 
        AS career_length_years
FROM players
WHERE debut IS NOT NULL
  AND finalgame IS NOT NULL
  AND birthyear IS NOT NULL
  AND birthmonth IS NOT NULL
  AND birthday IS NOT NULL
ORDER BY career_length_years DESC;


-- 3. What team did each player play on for their starting and ending years?
SELECT  
    p.namegiven,
    s.yearid AS starting_year,
    s.teamid AS starting_team,
    e.yearid AS ending_year,
    e.teamid AS ending_team
FROM players p
INNER JOIN salaries s
    ON p.playerid = s.playerid
   AND DATE_PART('year', p.debut)::int = s.yearid
INNER JOIN salaries e
    ON p.playerid = e.playerid
   AND DATE_PART('year', p.finalgame)::int = e.yearid
WHERE p.debut IS NOT NULL
  AND p.finalgame IS NOT NULL
ORDER BY p.namegiven;


-- 4. How many players started and ended on the same team and also played for over a decade?
SELECT  
    p.namegiven,
    s.yearid AS starting_year,
    s.teamid AS starting_team,
    e.yearid AS ending_year,
    e.teamid AS ending_team
FROM players p
INNER JOIN salaries s
    ON p.playerid = s.playerid
   AND DATE_PART('year', p.debut)::int = s.yearid
INNER JOIN salaries e
    ON p.playerid = e.playerid
   AND DATE_PART('year', p.finalgame)::int = e.yearid
WHERE p.debut IS NOT NULL
  AND p.finalgame IS NOT NULL
  AND s.teamid = e.teamid
  AND e.yearid - s.yearid > 10
ORDER BY p.namegiven;



--------------------------------------- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table
SELECT * FROM players;

-- 2. Which players have the same birthday?
WITH cte AS (SELECT p.playerid, pe.playerid,
					MAKE_DATE(p.birthyear, p.birthmonth, p.birthday) AS date_of_birth1,
					MAKE_DATE(pe.birthyear, pe.birthmonth, pe.birthday) AS date_of_birth2 
			FROM players p
			LEFT JOIN players pe
					ON p.playerid = pe.playerid)
SELECT * 
FROM cte
WHERE date_of_birth1 = date_of_birth2;


-- Which players have the same birthday?
WITH bn AS (
    SELECT  
        MAKE_DATE(birthyear, birthmonth, birthday) AS birthdate,
        namegiven
    FROM players
    WHERE birthyear IS NOT NULL
      AND birthmonth IS NOT NULL
      AND birthday IS NOT NULL
)
SELECT  
    birthdate,
    STRING_AGG(namegiven, ', ' ORDER BY namegiven) AS players
FROM bn
WHERE DATE_PART('year', birthdate) BETWEEN 1980 AND 1990
GROUP BY birthdate
HAVING COUNT(*) > 1
ORDER BY birthdate;

-- People who share the same month and day regardless of year (true “same birthday”)
SELECT  
    birthmonth,
    birthday,
    STRING_AGG(namegiven, ', ' ORDER BY namegiven) AS players
FROM players
WHERE birthmonth IS NOT NULL
  AND birthday IS NOT NULL
GROUP BY birthmonth, birthday
HAVING COUNT(*) > 1
ORDER BY birthmonth, birthday;


-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
WITH up AS (
    SELECT DISTINCT 
        s.teamid, 
        s.playerid, 
        p.bats
    FROM salaries s
    LEFT JOIN players p
        ON s.playerid = p.playerid
)
SELECT 
    teamid,
    ROUND(
        COUNT(DISTINCT CASE WHEN bats = 'R' THEN playerid END)::numeric
        / COUNT(DISTINCT playerid) * 100, 1
    ) AS bats_right,
    ROUND(
        COUNT(DISTINCT CASE WHEN bats = 'L' THEN playerid END)::numeric
        / COUNT(DISTINCT playerid) * 100, 1
    ) AS bats_left,

    ROUND(
        COUNT(DISTINCT CASE WHEN bats = 'B' THEN playerid END)::numeric
        / COUNT(DISTINCT playerid) * 100, 1
    ) AS bats_both
FROM up
GROUP BY teamid
ORDER BY teamid;


-- TASK 4: How have average height and weight at debut changed over the years,
-- and what is the decade-over-decade difference?

WITH hw AS (
    SELECT
        (DATE_PART('year', debut)::int / 10) * 10 AS decade,
        AVG(height) AS avg_height,
        AVG(weight) AS avg_weight
    FROM players
    WHERE debut IS NOT NULL
      AND height IS NOT NULL
      AND weight IS NOT NULL
    GROUP BY (DATE_PART('year', debut)::int / 10) * 10
)
SELECT
    decade,
    ROUND(avg_height::numeric, 2) AS avg_height,
    ROUND(avg_weight::numeric, 2) AS avg_weight,
    ROUND(
        (avg_height - LAG(avg_height) OVER (ORDER BY decade))::numeric, 2
    ) AS height_diff,
    ROUND(
        (avg_weight - LAG(avg_weight) OVER (ORDER BY decade))::numeric, 2
    ) AS weight_diff
FROM hw
ORDER BY decade;


-- ============================================================
-- Dashboard Query: Team Batting Composition
-- ============================================================
WITH unique_team_players AS (
    SELECT DISTINCT
        s.teamid,
        s.playerid,
        p.bats
    FROM salaries s
    INNER JOIN players p
        ON s.playerid = p.playerid
    WHERE p.bats IS NOT NULL
),
team_batting_summary AS (
    SELECT
        teamid,
        COUNT(DISTINCT playerid) AS total_players,
        COUNT(DISTINCT CASE WHEN bats = 'R' THEN playerid END) AS right_batters,
        COUNT(DISTINCT CASE WHEN bats = 'L' THEN playerid END) AS left_batters,
        COUNT(DISTINCT CASE WHEN bats = 'B' THEN playerid END) AS switch_hitters
    FROM unique_team_players
    GROUP BY teamid
)
SELECT
    teamid,
    total_players,
    right_batters,
    left_batters,
    switch_hitters,
    ROUND(right_batters::numeric / total_players * 100, 1) AS pct_right_batters,
    ROUND(left_batters::numeric / total_players * 100, 1) AS pct_left_batters,
    ROUND(switch_hitters::numeric / total_players * 100, 1) AS pct_switch_hitters,
    CASE
        WHEN right_batters >= left_batters 
         AND right_batters >= switch_hitters THEN 'Right-heavy roster'
        WHEN left_batters >= right_batters 
         AND left_batters >= switch_hitters THEN 'Left-heavy roster'
        ELSE 'Switch-hitter-heavy roster'
    END AS roster_profile
FROM team_batting_summary
ORDER BY total_players DESC, teamid;




