/*
    QUESTION ::What range of years does the provided database cover?
        ...
    SOURCES :: appearances table 
        * batting, fielding, pitching
    DIMENSIONS :: yearid
        * 
    FACTS :: 
        * Maximum year
		* Minimum year
    FILTERS ::
        * ...
    DESCRIPTION :: Searching through appearnaces table where all the games data contained
        ...
    ANSWER :: FROM 1871 TO 2016 
        ...
*/
 
SELECT MIN(yearid) AS start_year, MAX(yearid) AS end_year
FROM appearances;

--OR demo from Taylor's query

	SELECT MAX(yearid), MIN(yearid) 
	  	  FROM batting	  
UNION ALL
	  
	  SELECT MAX(yearid), MIN(yearid) 
	  FROM fielding
	
UNION ALL
	  
	  SELECT MAX(yearid), MIN(yearid) 
	  FROM pitching

/*
    QUESTION :: 2.Find the name and height of the shortest player in the database.
	              How many games did he play in? What is the name of the team for which he played?
        ...
    SOURCES :: people, appearances, teams
        * ...
    DIMENSIONS :: 
        * ...
    FACTS :: 
        * ...
    FILTERS :: playerid
        * ...
    DESCRIPTION :: Find minimum height, use player id to find how many games he played, then join with team table 
        ...			teamid to find for which team he played.
    ANSWER :: Name => Eddie Gaedel; height => 43; total games played => 52; team name => St. Louis Browns;  
        ...
*/

/*
--what is the minimum height? 43
SELECT MIN(height)
FROM people;
--get the playerid with the shortest height => gaedeed01
SELECT playerid, namefirst, namelast, COUNT(*)
FROM people
WHERE height = 43
GROUP BY playerid, namefirst, namelast;
*/

SELECT p.namefirst, p.namelast, t.name AS team_name, p.height AS shortest_height, COUNT(a.g_all) AS num_gamesplayed
FROM   people AS p, appearances AS a, teams AS t
WHERE  p.playerid = a.playerid
	AND a.teamid = t.teamid
	AND p.playerid = 'gaedeed01'
GROUP BY p.namefirst, p.namelast, p.height, t.name;


/*
===========================================================================
    QUESTION ::
		*3.Find all players in the database who played at Vanderbilt University.Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. 
				Which Vanderbilt player earned the most money in the majors?
   	SOURCES :: 
        * people, salaries, collegeplaying
    DIMENSIONS :: 
        * playerid, schoolid, salary
    FACTS :: 
        * player who has heighest salary & played at Vanderbilt University
    FILTERS :: 
        * schoolid = 'vandy'
    DESCRIPTION ::
        ...
    ANSWER :: David Price earned the most money in the majors
        ...
*/
SELECT cp.playerid, p.namefirst, p.namelast, SUM(s.salary) As total_salary
FROM collegeplaying AS cp, salaries AS s, people as p
WHERE 	cp.playerid = s.playerid
	AND cp.playerid = p.playerid 
	AND	schoolid = 'vandy' 
GROUP BY cp.playerid, p.namefirst, p.namelast
ORDER BY total_salary DESC;


--Alternatively-----


WITH max_salary AS(
		SELECT s.playerid, SUM(s.salary) AS total_salary
		FROM salaries AS s
		JOIN collegeplaying AS cp
		ON s.playerid = cp.playerid
WHERE cp.schoolid = 'vandy'
GROUP BY s.playerid)
							
SELECT p.namefirst, p.namelast, total_salary
FROM people AS p
JOIN max_salary
ON p.playerid = max_salary.playerid
GROUP BY p.namefirst, p.namelast, total_salary
ORDER BY total_salary DESC;

/*
    QUESTION :: 
        *4. Using the fielding table, group players into three groups based on their position: 
			label players with position OF as "Outfield", those with position "SS", "1B", "2B", 
			and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
			Determine the number of putouts made by each of these three groups in 2016
    SOURCES :: 
        * fielding
    DIMENSIONS :: 
        * pos, po, yearid
    FACTS :: 
        * ...
    FILTERS :: 
        * yearid = '2016'
    DESCRIPTION :: 
        the the number of putouts by each groups in 2016
    ANSWER :: 
        29560 total putouts by 'Outfield'; 41424 total putouts by 'Battery'; 58934 total putouts by infield
*/

SELECT CASE WHEN pos = 'OF' THEN 'Outfield'
	   		WHEN pos = 'SS' OR pos = '1B' OR pos ='2B' OR pos ='3B' THEN 'Infield'
			ELSE 'Battery' END AS position,
	  SUM(po) AS total_putouts,
	  yearid
FROM fielding
WHERE  yearid = '2016'
GROUP BY position, yearid
ORDER BY total_putouts;

/*
    QUESTION :: 
        5. Find the average number of strikeouts per game by decade since 1920. 
		Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
    SOURCES :: 
        * Not sure which table to use but used data sources from batting, pitching, teams
    DIMENSIONS :: 
        * yearid, so, hr
    FACTS :: 
        * average home run and average strike out by decade
    FILTERS :: 
        * yearid >= 1920
    DESCRIPTION :: 
        ...
    ANSWER :: There's is a trend that both the average strike out and average homerun gradually increase from 1920 through 2016.
        ...
*/

SELECT trunc(yearid, -1) AS decade, 
--SUM(g) AS total_gameplayed , SUM(so)AS total_strikeouts,
ROUND(SUM(so)::numeric / SUM(g)::numeric, 2)*100 AS avg_stikeouts,
ROUND(SUM(hr)::numeric / SUM(g)::numeric, 2)*100 AS avg_homerun
FROM batting
WHERE trunc(yearid, -1) >=1920
GROUP BY trunc(yearid, -1)
ORDER BY trunc(yearid, -1)

/*
===========================================================
Average strike out per game since 1920 from pitching table
===========================================================
*/

SELECT trunc(yearid, -1) AS decade, 
--SUM(g) AS total_gameplayed , SUM(so)AS total_strikeouts,
ROUND(SUM(so)::numeric / SUM(g)::numeric, 2)*100 AS avg_stikeouts,
ROUND(SUM(hr)::numeric / SUM(g)::numeric, 2)*100 AS avg_homerun
FROM pitching
WHERE trunc(yearid, -1) >=1920
GROUP BY trunc(yearid, -1)
ORDER BY trunc(yearid, -1)

/*
===================================================
 Average home runs and strike outs from team table
===================================================
*/
SELECT trunc(yearid, -1) AS decade, 
--SUM(g) AS total_gameplayed , SUM(so)AS total_homerun, SUM(hr)AS total_homerun,
ROUND(SUM(hr)::numeric/ SUM(g)::numeric,2)*100 AS avg_homerun,
ROUND(SUM(so)::numeric/ SUM(g)::numeric,2)*100 AS avg_strikeout
FROM teams
WHERE trunc(yearid, -1) >=1920
GROUP BY trunc(yearid, -1)
ORDER BY trunc(yearid, -1)

 
/*
--===========================================================================
Which table? Teams OR batting OR pitching OR combination of batting & pitching?
Below query used the data from the combination of batting and pitching table that have both strike outs and home run data.
Used temp table.
===============================================================================
*/

SELECT * INTO hr_so
FROM
(SELECT trunc(p.yearid, -1) AS decade, SUM(p.g) + SUM(b.g) AS total_game, SUM(p.so) + SUM (b.so) AS total_so, SUM(p.hr)+SUM(b.hr) AS total_hr
FROM pitching AS p, batting as b
WHERE p.teamid = b.teamid AND trunc(p.yearid, -1) >= 1920
GROUP BY trunc(p.yearid, -1)) AS sub;

SELECT decade, ROUND(total_so::numeric /total_game::numeric, 2)*100 AS so_pergame,
		ROUND(total_hr::numeric /total_game::numeric, 2)*100 AS hr_pergame
FROM hr_so
GROUP BY decade, total_so, total_game, total_hr
ORDER BY decade ASC

DROP TABLE hr_so;


/*
 ================================================================================
 	QUESTION ::
        6.Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) 
		Consider only players who attempted at least 20 stolen bases.
    SOURCES ::
        * batting
    DIMENSIONS :: 
        * playerid, sb, so
    FACTS ::
        * SUM of stolen base divided by total attempt which is SUM of stolen base + caught stealing, cast the two numbers
		  to be numeric because bigint data type return 0 when do division ; then round to 2 decimal place and concat '%' sign
		  to show percentage in the query result
    FILTERS ::
        * yearid = 2016 and total attempt >= 20
    DESCRIPTION ::
        ...
    ANSWER ::
        Chris Owings has the most successful rate of 91.30%
*/


WITH top1 AS (SELECT sub.playerid, 
			  CONCAT(ROUND((sub.success::numeric * 100 / sub.attempt::numeric),2),'%') AS success_pct
FROM
		(SELECT playerid, SUM(sb) as success, SUM(sb + cs) as attempt
		FROM batting
		WHERE yearid = 2016
		GROUP BY playerid) as sub
WHERE sub.attempt >= 20
ORDER BY success_pct DESC
LIMIT 1)

SELECT p.namefirst, p.namelast, top1.success_pct
FROM top1
LEFT JOIN people as p
ON top1.playerid = p.playerid;

