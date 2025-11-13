
--1: Inserting a small test college
INSERT INTO Fall25_S0003_T1_College (Name, College_ID, Phone, Email)
SELECT 'Update_Test_College','UTA001','1234567890','trytest@uta.edu'
FROM dual
WHERE NOT EXISTS (
  SELECT 1 FROM Fall25_S0003_T1_College WHERE College_ID='UTA001'
);

   
--creating new college id and inserting new student on those

-- 2 updating address of college of new student

INSERT INTO Fall25_S0003_T1_Student
    (Name, Email, College_ID, Student_ID, Acad_Status, Major)
VALUES
    ('Test Update Student',
     'testupdate.student@edu.com',
     'UTA001',         -- your new College_ID
     '90001234',         -- 8-char student ID (required)
     'Bachelor',
     'CS');
     
     --3 Inserting new location for new college
     INSERT INTO Fall25_S0003_T1_Location
    (State, Zip_Code, City, Street_Address, College_ID)
VALUES
    ('TX', '76180', 'Fort Worth', '200 New Campus Dr', 'UTA001');

     
     -- 4 updating address of college of new student
     UPDATE Fall25_S0003_T1_Location
SET State = 'TX',
    Zip_Code = '76230',
    City = 'North Richland Hills',
    Street_Address = '200 Updated Drive'
WHERE College_ID = 'UTA001';

--5 Updating student major and college id
UPDATE Fall25_S0003_T1_Student
SET Major = 'Business',
    College_ID = '21183528'         -- choose any valid existing college_id
WHERE Email = 'testupdate.student@edu.com';

--6 Deleting the new student

DELETE FROM Fall25_S0003_T1_Student
WHERE Email = 'testupdate.student@edu.com'
  AND EXISTS (
        SELECT 1 FROM Fall25_S0003_T1_Student 
        WHERE Email = 'testupdate.student@edu.com'
      );



-- 7: Delete a test college if you had one with no students
DELETE FROM Fall25_S0003_T1_College c
 WHERE c.College_ID = 'UTA001'
   AND NOT EXISTS (
         SELECT 1 FROM Fall25_S0003_T1_Student s
         WHERE s.College_ID = c.College_ID
       )
   AND ROWNUM <= 1;           -- remove just one to change counts safely
   
   --8 Delete all rows with drama as favourites
   DELETE FROM Fall25_S0003_T1_Favorite_Genre
WHERE UPPER(TRIM(Genre)) = 'DRAMA';
   

-- 8 Insert a favourite genre if none exist
INSERT INTO Fall25_S0003_T1_Favorite_Genre (Genre, Student_Email)
SELECT 'Drama', s.Email
FROM Fall25_S0003_T1_Student s
WHERE NOT EXISTS (
  SELECT 1 FROM Fall25_S0003_T1_Favorite_Genre fg WHERE fg.Student_Email = s.Email
)
AND ROWNUM = 1;

--9update phone number format 
UPDATE Fall25_S0003_T1_Content_Provider
   SET Phone = SUBSTR(Phone,1,3)||'-'||SUBSTR(Phone,4,3)||'-'||SUBSTR(Phone,7,4)
 WHERE LENGTH(TRIM(Phone)) = 10;
 
