
---- JAZZ QUERIES----
/*
For my first query I wanted to identify jazz standards in the dataset where the harmonic progression deviates 
from the typical 4-bar multiples in Western music. I used a simple query to retrieve the song ID, title, year, and the count of bars 
in the harmonic progression for each non-conforming song.
*/
SELECT SongID, Song, Year, Bars
FROM SONGS
WHERE MOD(Bars, 4) != 0;


/*
Crafted a join query to identify the top 10 instrumental-only songs frequently played at jam sessions. 
Retrieved relevant details such as song title, key signature, style, number of calls, 
and the title of the song it is a contrafact of (if applicable).
*/
SELECT SONGS.Song, SONGS.KeySignature, SONGS.Style, SONGS.Calls, C.Song AS Contrafact
FROM SONGS LEFT JOIN SONGS C
ON SONGS.ContrafactID = C.SongID
WHERE SONGS.Lyrics IS NULL
ORDER BY SONGS.Calls DESC
FETCH FIRST 10 ROWS ONLY;


/*
This set of SQL queries aims to identify prolific composers within the dataset—individuals who have written the music for more than 5 songs 
but have not contributed to the lyrics. 
The results include the unique identifier (ID), formatted name in the Last, First format (e.g., Parker, Charlie), 
and, where applicable, the age at death. 
The latter will be left blank for composers who are still alive. 
These queries shed light on notable individuals who have made significant contributions to music as composers without delving into lyricism.
*/

SELECT WRITERS.WriterID, LastName || ', ' || FirstName AS FullName, Died-Born AS AgeAtDeath
FROM CREDITS JOIN WRITERS 
ON CREDITS.WriterID = WRITERS.WriterID
WHERE Credit = 'Music'
GROUP BY WRITERS.WriterID, LastName, FirstName, Born, Died
HAVING COUNT(SongID) > 5
MINUS
SELECT WRITERS.WriterID, LastName || ', ' || FirstName AS FullName, Died-Born AS AgeAtDeath
FROM CREDITS JOIN WRITERS 
ON CREDITS.WriterID = WRITERS.WriterID
WHERE Credit = 'Lyrics';

/*
In exploring the rich cultural heritage of jazz often referred to as "African-American classical music," 
the following subquery delves into summary statistics for songs crafted by Black artists. 
The analysis encompasses the total number of songs where any of the writers were Black, 
along with key metrics such as the highest, average (rounded to 0 decimals), 
and lowest ranking among these songs. To ensure accuracy, 
each song is counted only once in these statistics, acknowledging the collaborative nature of music creation. 
*/

SELECT COUNT(SongID) AS TotalSongs, MIN(Ranking) AS HighestRank, ROUND(AVG(Ranking),0) AS AverageRank, MAX(Ranking) AS LowestRank
FROM SONGS
WHERE SongID IN
(SELECT SongID
FROM WRITERS JOIN CREDITS 
ON WRITERS.WriterID = CREDITS.WriterID
WHERE Race = 'Black');

/*
This subquery delves into the diverse origins of jazz standards, specifically those crafted for stage and screen. 
It provides insights into each type of source work, offering details such as the total number of songs composed for that type and the percentage 
it represents out of all songs written for source works. The percentage values are formatted with one decimal place for clarity, 
presenting a comprehensive view of the contribution of each source work type to the jazz repertoire

*/
SELECT WorkType, COUNT(SongID) AS Total, ROUND(COUNT(SongID)/
(SELECT COUNT(SongID)
FROM SONGS
WHERE WorkID IS NOT NULL) * 100, 1) || '%' AS Proportion
FROM WORKS JOIN SONGS 
ON WORKS.WorkID = SONGS.WorkID
GROUP BY WorkType;


