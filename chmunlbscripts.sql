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
