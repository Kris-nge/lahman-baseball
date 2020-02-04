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
