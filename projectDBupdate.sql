
-- ============================================================================
-- UPDATE 1: INSERT
-- Insert a new test college with College_ID, Name, Phone, and Email
-- ============================================================================
INSERT INTO Fall25_S0003_T1_College 
(
    Name, 
    College_ID, 
    Phone, 
    Email
)
SELECT 
    'Update_Test_College',
    'UTA001',
    '1234567890',
    'trytest@uta.edu'
FROM 
    dual
WHERE 
    NOT EXISTS 
    (
        SELECT 
            1 
        FROM 
            Fall25_S0003_T1_College 
        WHERE 
            College_ID = 'UTA001'
    );

-- ============================================================================
-- UPDATE 2: INSERT
-- Insert a new test student with Name, Email, College_ID, Student_ID, Acad_Status, and Major
-- ============================================================================
INSERT INTO Fall25_S0003_T1_Student
(
    Name, 
    Email, 
    College_ID, 
    Student_ID, 
    Acad_Status, 
    Major
)
VALUES
(
    'Test Update Student',
    'testupdate.student@edu.com',
    'UTA001',
    '90001234',
    'Bachelor',
    'CS'
);

-- ============================================================================
-- UPDATE 3: INSERT
-- Insert a new location for the test college with State, Zip_Code, City, Street_Address, and College_ID
-- ============================================================================
INSERT INTO Fall25_S0003_T1_Location
(
    State, 
    Zip_Code, 
    City, 
    Street_Address, 
    College_ID
)
VALUES
(
    'TX', 
    '76180', 
    'Fort Worth', 
    '200 New Campus Dr', 
    'UTA001'
);


-- ============================================================================
-- UPDATE 4: UPDATE
-- Update the location address for the test college, changing State, Zip_Code, City, and Street_Address
-- ============================================================================
UPDATE Fall25_S0003_T1_Location
SET 
    State = 'TX',
    Zip_Code = '76230',
    City = 'North Richland Hills',
    Street_Address = '200 Updated Drive'
WHERE 
    College_ID = 'UTA001';

-- ============================================================================
-- UPDATE 5: UPDATE
-- Update the test student's Major and College_ID to transfer them to a different college
-- ============================================================================
UPDATE Fall25_S0003_T1_Student
SET 
    Major = 'Bussiness',
    College_ID = '21745521'
WHERE 
    Email = 'testupdate.student@edu.com';

-- ============================================================================
-- UPDATE 6: DELETE
-- Delete the test student by Email
-- ============================================================================
DELETE FROM Fall25_S0003_T1_Student
WHERE 
    Email = 'testupdate.student@edu.com'
AND 
    EXISTS 
    (
        SELECT 
            1 
        FROM 
            Fall25_S0003_T1_Student 
        WHERE 
            Email = 'testupdate.student@edu.com'
    );


-- ============================================================================
-- UPDATE 7: DELETE
-- Delete the test college location and then the test college only if it has no students enrolled
-- ============================================================================
DELETE FROM Fall25_S0003_T1_Location
WHERE 
    College_ID = 'UTA001';

DELETE FROM Fall25_S0003_T1_College c
WHERE 
    c.College_ID = 'UTA001'
AND 
    NOT EXISTS 
    (
        SELECT 
            1 
        FROM 
            Fall25_S0003_T1_Student s
        WHERE 
            s.College_ID = c.College_ID
    )
AND 
    ROWNUM <= 1;

-- ============================================================================
-- UPDATE 8: DELETE
-- Delete all favorite genre rows where the genre is Drama
-- ============================================================================
DELETE FROM Fall25_S0003_T1_Favorite_Genre
WHERE 
    UPPER
    (
        TRIM(Genre)
    ) = 'DRAMA';

-- ============================================================================
-- UPDATE 9: INSERT
-- Insert Drama as a favorite genre for one student who has no favorite genres
-- ============================================================================
INSERT INTO Fall25_S0003_T1_Favorite_Genre 
(
    Genre, 
    Student_Email
)
SELECT 
    'Drama', 
    s.Email
FROM 
    Fall25_S0003_T1_Student s
WHERE 
    NOT EXISTS 
    (
        SELECT 
            1 
        FROM 
            Fall25_S0003_T1_Favorite_Genre fg 
        WHERE 
            fg.Student_Email = s.Email
    )
AND 
    ROWNUM = 1;

-- ============================================================================
-- UPDATE 10: UPDATE
-- Update all Content_Provider phone numbers to include dashes in format XXX-XXX-XXXX
-- ============================================================================
UPDATE Fall25_S0003_T1_Content_Provider
SET 
    Phone = SUBSTR(Phone,1,3) || '-' || SUBSTR(Phone,4,3) || '-' || SUBSTR(Phone,7,4)
WHERE 
    LENGTH
    (
        TRIM(Phone)
    ) = 10;
 
