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
ROUND(SUM(so)::numeric / SUM(g)::numeric,*100 2) AS avg_stikeouts,
ROUND(SUM(hr)::numeric / SUM(g)::numeric,*100 2) AS avg_homerun
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
ROUND(SUM(so)::numeric / SUM(g)::numeric*100, 2) AS avg_stikeouts,
ROUND(SUM(hr)::numeric / SUM(g)::numeric*100, 2) AS avg_homerun
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
ROUND(SUM(hr)::numeric/ SUM(g)::numeric*100,2) AS avg_homerun,
ROUND(SUM(so)::numeric/ SUM(g)::numeric*100,2) AS avg_strikeout
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

SELECT decade, ROUND(total_so::numeric /total_game::numeric*100, 2) AS so_pergame,
		ROUND(total_hr::numeric /total_game::numeric*100, 2) AS hr_pergame
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


/*
=========================================================================================================
    QUESTION ::
        Q7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
			What is the smallest number of wins for a team that did win the world series? Doing this will probably 
			result in an unusually small number of wins for a world series champion – determine why this is the case. 
			Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that 
			a team with the most wins also won the world series? What percentage of the time?
    SOURCES ::
        * team
    DIMENSIONS :: 
        * name, w, g, wswin
    FACTS ::
        * MAX, SUM, MIN
    FILTERS ::
        * yearid between 1970 - 2016, the problem year 1981, world series won or lost
    DESCRIPTION ::
        ...
    ANSWER ::
       	* Seattle Mariners had the largest win but didn't win worldseries
		*
*/
--Team with the largest wins but didn't win world series: Seattle Mariners

SELECT yearid, name, g AS games, MAX(w),wswin
FROM teams
GROUP BY yearid, teamid, name, wswin, g
HAVING MAX (w) = (SELECT MAX(w) FROM teams WHERE yearid >= 1970 AND wswin = 'N') AND yearid >= 1970 AND wswin = 'N'


--Alternative way of writing query but output same query result

SELECT yearid, name AS team_name, g AS games, MAX(w), wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'N'
GROUP BY yearid, name, g, wswin
ORDER BY max DESC, yearid
LIMIT 1;

--Before removing the problem year, team with smallest wins that also win world series : Los Angeles Dodgers with 63 largest wins

SELECT yearid, name, g AS games, MIN(w), wswin
FROM teams
GROUP BY yearid, name, g, wswin
HAVING MIN(w) = (SELECT MIN(w) FROM teams WHERE yearid >= 1970 AND wswin = 'Y') 
				AND yearid >= 1970 AND wswin = 'Y'

-- After removing the problem year 1981 that had lesser total games played,
-- St. Louis Cardinals had the smallest wins of 83 and also won world series

SELECT yearid, teamid, name, MIN(w),wswin
FROM teams
GROUP BY yearid, teamid, name, wswin
HAVING MIN(w) = (SELECT MIN(w) FROM teams WHERE yearid >= 1970 AND yearid <> 1981 AND wswin = 'Y') 
				AND yearid >= 1970 AND yearid <> 1981 AND wswin = 'Y'

--Alternatively:
-- Los Angeles Dodgers, smallest wins 63, and won world series. In year 1981, total games played were less than the rest of the year from 1970 t0 2016

SELECT yearid, name AS team_name, MIN(w) AS smallest_win, wswin AS worldseries_win, g AS games
FROM teams
WHERE yearid >= 1970 AND wswin = 'Y' 
GROUP BY yearid, name, wswin, g
ORDER BY smallest_win ASC
Limit 1;

-- After removing the problem year, St. Louis Cardinals, smallest wins 83, and also won world series

SELECT yearid, name AS team_name, MIN(w) AS smallest_win, wswin AS worldseries_win, g AS games
FROM teams
WHERE yearid >= 1970 AND yearid <> 1981 AND wswin = 'Y' 
GROUP BY yearid, name, wswin, g
ORDER BY smallest_win ASC
Limit 1;


--Team that largest win that also won world series : New York Yankee. Percentage won was 1.01

SELECT team_name, SUM(wins)AS total_wins, SUM(worldseries)::numeric AS total_wswin,
ROUND(SUM(worldseries)::numeric*100 / SUM(wins)::numeric, 2) AS pct_win
FROM
	(SELECT yearid, name AS team_name, w AS wins,(SELECT MAX(w) FROM teams) AS max_win , 
		CASE WHEN UPPER(wswin) = 'Y' THEN 1
		 	WHEN UPPER(wswin) = 'N' THEN 0
		END AS worldseries
	FROM teams
	WHERE yearid >=1970 AND yearid <> 1981 AND wswin = 'Y'
	GROUP BY yearid,name, w, wswin
	ORDER BY wins DESC) AS sub
WHERE yearid <> 1981 
GROUP BY team_name, worldseries
ORDER BY total_wswin DESC
LIMIT 1;

/*
========================================================================================================
	QUESTION ::
        Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. 
		Repeat for the lowest 5 average attendance.
    SOURCES ::
        * homegames, parks, teams
    DIMENSIONS ::
        * homegames.yearid, homegames.team, teams.teamid, park, parks.park_name, homegames.game, homegames.attendance
    FACTS ::
        * Average attendance per game which is the total number of attendance divided by number games.
	FILTERS ::
        * yearid = 2016 and total game >= 10
    DESCRIPTION ::
        ...
    ANSWER ::
        Top 5: 
		1.	Dodger Stadium; Los Angeles Dodgers; 45719
		2.	Busch Stadium III; St. Louis Cardinals; 42524
		3.	Rogers Centre; Toronto Blue Jays; 41877
		4.	AT&T Park; San Francisco Giants; 41546
		5.	Wrigley Field;	Chicago Cubs; 39906
		
		Lowest 5:
		1.	Tropicana Field;	Tampa Bay Rays;	15878
		2.	Oakland-Alameda Country Coliseum;	Oakland Athletics;	18784
		3.	Progressive Field;	Cleveland Indians;	19650
		4.	Marlins Park;	Miami Marlins;	21405
		5.	U.S. Cellular Field;	Chicago White Sox;	21559
*/

WITH top AS (SELECT year, hg.team, hg.park, p.park_name, games, hg.attendance,
			 hg.attendance / games AS avg_attendance
FROM homegames AS hg
LEFT JOIN parks AS p
ON hg.park = p.park
WHERE year= 2016 AND games >= 10
GROUP BY year, hg.park, hg.team, p.park_name, games, hg.attendance
ORDER BY avg_attendance DESC
LIMIT 5)
 

SELECT DISTINCT p.park_name, t.name AS team_name, top.avg_attendance
FROM top
LEFT JOIN parks AS p
ON top.park = p.park
LEFT JOIN teams AS t
ON top.team = t.teamid
WHERE yearid = 2016 AND games >= 10
GROUP BY p.park_name, t.name, top.avg_attendance
ORDER BY avg_attendance DESC
LIMIT 5;



-- To find lowest 5 average attendance

WITH lowest AS (
	SELECT year, hg.team, hg.park, p.park_name, games, hg.attendance, hg.attendance / games AS avg_attendance
	FROM homegames AS hg
	LEFT JOIN parks AS p
	ON hg.park = p.park
	WHERE year= 2016 AND games >= 10
	GROUP BY year, hg.park, hg.team, p.park_name, games, hg.attendance
	ORDER BY avg_attendance ASC
	LIMIT 5)
 

SELECT DISTINCT p.park_name, t.name AS team_name, lowest.avg_attendance
FROM lowest
LEFT JOIN parks AS p
ON lowest.park = p.park
LEFT JOIN teams AS t
ON lowest.team = t.teamid
WHERE yearid = 2016 AND games >= 10
GROUP BY p.park_name, t.name, lowest.avg_attendance
ORDER BY avg_attendance ASC
LIMIT 5;

/*
================================================================================================
   QUESTION ::
       9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
		Give their full name and the teams that they were managing when they won the award.

    SOURCES ::
        * managers, people, teamsfranchises

    DIMENSIONS ::
        * yearid, awardid, franchname, namefirst, namelast, namegiven,lgid, teamid, playerid

    FACTS ::
        * ...

    FILTERS ::
        * awardid, lgid = 'NL' AND lgid = 'AL'

    DESCRIPTION ::
        ...

    ANSWER ::
        * Jim Richard Leyland - he managed Pittsburgh Pirates  & Detroit Tigers teams when he won TSN Manager award of the year
		* Davey Allen Johnson - he managed  Baltimore Orioles and Washington Senators when he won TSN Manager ward of the year
*/

Select DISTINCT am.yearid, CONCAT(p.namefirst, ' ', substring(p.namegiven,7), ' ', p.namelast) AS fullname, 
am.awardid, t.franchname, am.lgid
FROM awardsmanagers as am
JOIN managers AS m 
ON am.playerid = m.playerid AND am.yearid = m.yearid
JOIN people AS p 
ON am.playerid = p.playerid
JOIN teamsfranchises AS t 
ON m.teamid = t.franchid
WHERE am.playerid IN (SELECT playerid FROM awardsmanagers 
					  WHERE awardid = 'TSN Manager of the Year' AND lgid = 'NL'
 					INTERSECT 
					  SELECT playerid FROM awardsmanagers 
					  WHERE awardid = 'TSN Manager of the Year' AND lgid = 'AL') 
		AND awardid = 'TSN Manager of the Year'
ORDER BY fullname, am.yearid;