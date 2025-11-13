--TEst 1 before and after value changed by 1
SELECT COUNT(*)
From Fall25_S0003_T1_College;

--TEST 2 BEfore and after run changed value by 1
SELECT COUNT(*)
From Fall25_S0003_T1_Student;

--USE for projectdbupdatesql 3 and 4
SELECT *
From Fall25_S0003_T1_Location
WHERE College_ID = 'UTA001';

--For 5th and 6th update
SELECT *
From Fall25_S0003_T1_Student
WHERE Email = 'testupdate.student@edu.com';
-- Which Content_ID did this target?

-- for 7
SELECT *
From Fall25_S0003_T1_College
WHERE College_ID = 'UTA001';


-- 8 : prints student wtih favourite and nor favourite
SELECT
    SUM(CASE WHEN fg.Student_Email IS NULL THEN 1 ELSE 0 END) AS students_without_favorite,
    SUM(CASE WHEN fg.Student_Email IS NOT NULL THEN 1 ELSE 0 END) AS students_with_at_least_one_favorite
FROM Fall25_S0003_T1_Student s
LEFT JOIN Fall25_S0003_T1_Favorite_Genre fg
  ON s.Email = fg.Student_Email;
--8 and 9 names of students with favourite genre as drama
SELECT 
    s.Name      AS Student_Name,
    s.Email,
    fg.Genre
FROM Fall25_S0003_T1_Favorite_Genre fg
JOIN Fall25_S0003_T1_Student s
  ON s.Email = fg.Student_Email
WHERE fg.Genre = 'Drama'
ORDER BY s.Name;

--9: Phone number format changed for normal to professional
SELECT *
FROM Fall25_S0003_T1_Content_Provider;



--Fall25_S0003_T1_Content_Provider
--Fall25_S0003_T1_Student
--Fall25_S0003_T1_College
--Fall25_S0003_T1_License
--Fall25_S0003_T1_Content
--Fall25_S0003_T1_Watch_History
--Fall25_S0003_T1_Watches
--Fall25_S0003_T1_Favorite_Content
--Fall25_S0003_T1_Favorite_Genre
--Fall25_S0003_T1_Partnership_Information
--Fall25_S0003_T1_Location
--Fall25_S0003_T1_Genre
--Fall25_S0003_T1_Language

SELECT 
    l.Zip_Code,
    s.Name AS Student_Name,
    s.Email,
    s.College_ID
FROM Fall25_S0003_T1_Student s
JOIN Fall25_S0003_T1_College c 
    ON s.College_ID = c.College_ID
JOIN Fall25_S0003_T1_Location l
    ON c.College_ID = l.College_ID
WHERE l.Zip_Code IN (
    SELECT Zip_Code
    FROM Fall25_S0003_T1_Location loc
    JOIN Fall25_S0003_T1_College col ON loc.College_ID = col.College_ID
    JOIN Fall25_S0003_T1_Student stu ON stu.College_ID = col.College_ID
    GROUP BY Zip_Code
    HAVING COUNT(*) > 1          -- only ZIP codes with 2+ students
)
ORDER BY l.Zip_Code, s.Name;


SELECT * 
FROM Fall25_S0003_T1_Location
WHERE College_ID = '0000UT01';

--its for the new english added test on language
SELECT 
    lg.Language,
    lg.Content_ID
FROM Fall25_S0003_T1_Language lg
WHERE lg.Language = 'English'
  AND lg.Content_ID = (
        SELECT Content_ID 
        FROM Fall25_S0003_T1_Content 
        WHERE ROWNUM = 1
      );

--Genre increase
SELECT 
    Genre,
    COUNT(*) AS num_contents
FROM Fall25_S0003_T1_Genre
GROUP BY Genre
ORDER BY num_contents DESC;

