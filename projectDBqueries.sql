-- Format Settings
set pagesize 5000
set linesize 200
set trimspool on
set tab off
set wrap off
set colsep ' '

-- Column display formats
column CollegeName          format a35           heading 'College Name'
column StudentCount         format 9999990       heading 'Student Count'
column TotalWatches         format 9999990       heading 'Total Watches'
column AvgDuration          format 9999990.00    heading 'Avg Duration'

column ProviderName         format a35           heading 'Provider Name'
column LicenseType          format a20           heading 'License Type'
column TotalCost            format 999999990.00  heading 'Total Cost'

column ContentType          format a15           heading 'Content Type'
column ContentYear          format a15           heading 'Content Year'
column ViewerCount          format 9999990       heading 'Viewer Count'

column StudentName          format a30           heading 'Student Name'
column WatchCount           format 9999990       heading 'Watch Count'
column TotalMinutes         format 9999990       heading 'Total Minutes'
column AvgCollegeMinutes    format 9999990.00    heading 'Avg College Minutes'

column ContentTitle         format a50           heading 'Content Title'
column AvgRating            format 990.00        heading 'Avg Rating'

column Major                format a15           heading 'Major'
column MajorCount           format 9999990       heading 'Major Count'

-- End format settings

-- ============================================================================
-- QUERY 1: GROUP BY WITH HAVING
-- Find college names that have more than 3 students and show their total watches and average watch duration
-- ============================================================================
select
    COLLEGE.Name as CollegeName,
    count(HISTORY.Watch_ID) as TotalWatches,
    avg(to_number(HISTORY.Duration)) as AvgDuration
from
    Fall25_S0003_T1_College COLLEGE
    join Fall25_S0003_T1_Student STUDENT
        on COLLEGE.College_ID = STUDENT.College_ID
    join Fall25_S0003_T1_Watch_History HISTORY
        on STUDENT.Email = HISTORY.Student_Email
group by
    COLLEGE.Name
having
    count(distinct STUDENT.Email) > 3
order by
    TotalWatches desc;

/* Example Output:
    College Name                        Total Watches Avg Duration
    ----------------------------------- ------------- ------------
    Millsside University                           26       129.77
    Mccartyton University                          24       110.33
    North Kaitlyn University                       22       126.82
    Lake Gail University                           21       121.71
    New Debra University                           19       115.47
    Allisonburgh University                        18       146.22
    West Christinaton University                   16       166.25
    Lynnmouth University                           16       116.38
    North Beverly University                       15        83.60
    Simsfurt University                            14        78.57
    New Patrickburgh University                    14        76.00
    South Trevor University                        13       152.92
    Robinsonmouth University                       13       137.38

    13 rows selected.
*/

-- ============================================================================
-- QUERY 2: GROUP BY WITH HAVING AND SUBQUERY
-- Find the top 20 students who have watched content more times than the average student and show their student name and watch count
-- ============================================================================
select
    STUDENT.Name as StudentName,
    count(HISTORY.Watch_ID) as WatchCount
from
    Fall25_S0003_T1_Student STUDENT
    join Fall25_S0003_T1_Watch_History HISTORY
        on STUDENT.Email = HISTORY.Student_Email
group by
    STUDENT.Name,
    STUDENT.Email
having
    count(HISTORY.Watch_ID) > 
    (
        select 
            avg(WatchCount)
        from 
        (
            select 
                count(*) as WatchCount
            from 
                Fall25_S0003_T1_Watch_History
            group by 
                Student_Email
        )
    )
order by
    WatchCount desc
fetch first 20 rows only;

/* Example Output:
    Student Name                   Watch Count
    ------------------------------ -----------
    Jeremy Torres                            8
    Timothy Gonzales                         7
    Nicole Butler                            7
    Christopher Haas                         7
    Gilbert Williamson                       7
    Timothy Saunders                         7
    Sarah Robinson                           6
    Trevor Rodriguez                         6
    Nicholas Donaldson                       6
    Evelyn Lewis                             5
    Charles Dyer                             5
    Scott Glenn                              5
    Derek Taylor                             5
    Ashley Miller                            5
    Elizabeth Lopez                          5
    Tracy Freeman                            5
    Alice Parrish                            5
    Daniel Burgess                           5
    Anthony Thompson                         5
    Lauren Olson                             5

    20 rows selected.
*/

-- ============================================================================
-- QUERY 3: GROUP BY WITH HAVING AND SUBQUERY
-- Find the top 20 content titles that have been watched more times than average and show their content title and watch count
-- ============================================================================
select
    CONTENT.Title as ContentTitle,
    count(HISTORY.Watch_ID) as WatchCount
from
    Fall25_S0003_T1_Content CONTENT
    join Fall25_S0003_T1_Watch_History HISTORY
        on CONTENT.Content_ID = HISTORY.Content_ID
group by
    CONTENT.Title
having
    count(HISTORY.Watch_ID) > 
    (
        select 
            avg(ContentWatches)
        from 
        (
            select 
                count(*) as ContentWatches
            from 
                Fall25_S0003_T1_Watch_History
            group by 
                Content_ID
        )
    )
order by
    WatchCount desc
fetch first 20 rows only;

/* Example Output:
    Content Title                                      Watch Count
    -------------------------------------------------- -----------
    Self-enabling regional secured line                         10
    Centralized context-sensitive instruction set                8
    Streamlined contextually-based migration                     7
    Organized clear-thinking adapter                             7
    Triple-buffered even-keeled adapter                          7
    Open-source 6thgeneration strategy                           7
    Profit-focused systemic synergy                              7
    Reverse-engineered radical budgetary management              7
    Team-oriented non-volatile access                            7
    Proactive actuating instruction set                          6
    Devolved maximized implementation                            6
    Reverse-engineered systemic open system                      6
    Front-line attitude-oriented forecast                        6
    Managed attitude-oriented support                            6
    Re-engineered composite infrastructure                       6
    Streamlined national system engine                           6
    Programmable stable extranet                                 6
    Triple-buffered impactful application                        6
    Automated impactful architecture                             5
    Sharable grid-enabled time-frame                             5

    20 rows selected.
*/

-- ============================================================================
-- QUERY 4: DATA WAREHOUSE WITH ROLLUP
-- Find the top 25 provider names and license types with their total licensing costs including rollup subtotals
-- ============================================================================
select
    coalesce(PROVIDER.Name, 'ALL PROVIDERS') as ProviderName,
    coalesce(LICENSE.License_Type, 'ALL TYPES') as LicenseType,
    sum
    (
        to_number
        (
            replace
            (
                replace(LICENSE.License_Cost,'$',''),
                ',',
                ''
            )
        )
    ) as TotalCost
from
    Fall25_S0003_T1_Content_Provider PROVIDER
    join Fall25_S0003_T1_License LICENSE
        on PROVIDER.Content_ID = LICENSE.Provider_ID
group by
    rollup(PROVIDER.Name, LICENSE.License_Type)
order by
    TotalCost desc nulls last
fetch first 25 rows only;

/* Example Output:
    Provider Name                       License Type            Total Cost
    ----------------------------------- -------------------- -------------
    ALL PROVIDERS                       ALL TYPES               1142341.16
    Nguyen, Compton and Graham          ALL TYPES                284023.49
    Morgan, Hines and Ferguson          ALL TYPES                205745.05
    Black-White                         ALL TYPES                146540.60
    Morgan, Hines and Ferguson          Revenue-sharing          132153.71
    Gonzalez, Bell and Wilcox           ALL TYPES                127836.30
    Lane, Lopez and Chapman             ALL TYPES                101349.73
    Black-White                         CC                        99209.39
    Nguyen, Compton and Graham          CC                        98914.36
    Nguyen, Compton and Graham          Revenue-sharing           97554.41
    West, Adkins and Stephens           ALL TYPES                 95585.70
    James, Brown and Harris             ALL TYPES                 92584.39
    West, Adkins and Stephens           CC                        89907.45
    Nguyen, Compton and Graham          Fixed                     86493.87
    James, Brown and Harris             Fixed                     85762.27
    Lane, Lopez and Chapman             Fixed                     71107.89
    Gonzalez, Bell and Wilcox           Royalty-Based             63699.79
    Gonzalez, Bell and Wilcox           CC                        59222.02
    Morgan, Hines and Ferguson          Royalty-Based             46281.77
    Black-White                         Fixed                     38961.37
    Morgan, Hines and Ferguson          Time-based                27308.89
    Hunter-Nelson                       ALL TYPES                 24174.28
    Hunter-Nelson                       CC                        23457.38
    Lane, Lopez and Chapman             Royalty-Based             22170.38
    Hanna-Middleton                     ALL TYPES                 13217.52

    25 rows selected.
*/ 

-- ============================================================================
-- QUERY 5: DATA WAREHOUSE WITH CUBE
-- Find content types and content years between 2020 and 2025 with viewer counts at all aggregation levels
-- ============================================================================
select
    coalesce(CONTENT.Type, 'ALL TYPES') as ContentType,
    coalesce(CONTENT.Year, 'ALL YEARS') as ContentYear,
    count(distinct HISTORY.Student_Email) as ViewerCount
from
    Fall25_S0003_T1_Content CONTENT
    join Fall25_S0003_T1_Watch_History HISTORY
        on CONTENT.Content_ID = HISTORY.Content_ID
where
    CONTENT.Year between '2020' and '2025'
group by
    cube(CONTENT.Type, CONTENT.Year)
order by
    ContentType,
    ContentYear;

/* Example Output:
    Content Type    Content Year    Viewer Count
    --------------- --------------- ------------
    ALL TYPES       2020                      10
    ALL TYPES       2021                      32
    ALL TYPES       2022                      25
    ALL TYPES       2023                      26
    ALL TYPES       2024                      24
    ALL TYPES       2025                      27
    ALL TYPES       ALL YEARS                 76
    Movie           2020                       3
    Movie           2021                      20
    Movie           2022                       8
    Movie           2023                      13
    Movie           2024                       6
    Movie           2025                       8
    Movie           ALL YEARS                 48
    TV Shows        2020                       7
    TV Shows        2021                      17
    TV Shows        2022                      17
    TV Shows        2023                      17
    TV Shows        2024                      18
    TV Shows        2025                      19
    TV Shows        ALL YEARS                 63

    21 rows selected.
*/

-- ============================================================================
-- QUERY 6: DIVISION QUERY
-- Find student names who have watched content in all available content types (Movie, TV Shows)
-- ============================================================================
select distinct
    STUDENT.Name as StudentName
from
    Fall25_S0003_T1_Student STUDENT
where
    not exists 
    (
        select 
            CONTENT.Type
        from 
            Fall25_S0003_T1_Content CONTENT
        where
            CONTENT.Type is not null
        minus
        select 
            C2.Type
        from 
            Fall25_S0003_T1_Watch_History HISTORY
            join Fall25_S0003_T1_Content C2
                on HISTORY.Content_ID = C2.Content_ID
        where 
            HISTORY.Student_Email = STUDENT.Email
        and
            C2.Type is not null
    )
    and exists
    (
        select 
            1
        from 
            Fall25_S0003_T1_Watch_History HISTORY
        where 
            HISTORY.Student_Email = STUDENT.Email
    );

/* Example Output:
    Student Name
    ------------------------------
    Derek Taylor
    Roy Williams
    Alice Parrish
    Emily Adams
    Samantha Heath
    Karina Taylor
    Paul Mann
    Trevor Rodriguez
    Paul Moreno
    Patricia Olson
    William Long
    Andrew Taylor
    Timothy Saunders
    Scott Glenn
    Gilbert Williamson
    Joel George
    Jenna Mccoy
    Teresa Johnson
    Victor Houston
    Denise Reid
    Lauren Olson
    Jeremy Torres
    Michelle Little
    Anthony Lynch
    Victor Diaz
    Grace Padilla
    Sarah Johnston
    Karen Norris
    Dean Garcia
    Heather Hernandez
    Miranda Jackson
    Alexandria Miller
    Nicholas Wilson
    Timothy Gonzales
    Christy Sandoval
    Christopher Haas
    Yolanda Terrell
    Daisy Arnold
    Anthony Thompson
    Shelly Evans
    Kayla Dickson
    Nicholas Donaldson
    Evelyn Lewis
    Harry Bishop
    Nicole Butler
    Lindsay Gray DDS
    Rick Williams
    Kyle Sexton
    Charles Dyer
    Ashley Miller
    Sarah Robinson
    Elizabeth Lopez
    Regina Dixon
    Laura Hernandez
    Eileen Ramirez
    Dr. Antonio Castillo
    Kimberly Morgan
    Joy Smith

    58 rows selected.
*/

-- ============================================================================
-- QUERY 7: WINDOWING WITH OVER
-- Find the top 15 students showing college name, student name, total minutes watched, and average minutes for their college using windowing
-- ============================================================================
select
    CollegeName,
    StudentName,
    TotalMinutes,
    AvgCollegeMinutes
from
(
    select
        COLLEGE.Name as CollegeName,
        STUDENT.Name as StudentName,
        sum(to_number(HISTORY.Duration)) as TotalMinutes,
        avg(sum(to_number(HISTORY.Duration))) over 
        (
            partition by COLLEGE.College_ID
        ) as AvgCollegeMinutes
    from
        Fall25_S0003_T1_College COLLEGE
        join Fall25_S0003_T1_Student STUDENT
            on COLLEGE.College_ID = STUDENT.College_ID
        join Fall25_S0003_T1_Watch_History HISTORY
            on STUDENT.Email = HISTORY.Student_Email
    group by
        COLLEGE.Name,
        COLLEGE.College_ID,
        STUDENT.Name
)
order by
    AvgCollegeMinutes desc,
    TotalMinutes desc
fetch first 15 rows only;

/* Example Output:
    College Name                        Student Name                   Total Minutes Avg College Minutes
    ----------------------------------- ------------------------------ ------------- -------------------
    North Gabrielle University          Derek Taylor                             686              686.00
    Allisonburgh University             Laura Hernandez                          744              658.00
    Allisonburgh University             Tracy Freeman                            686              658.00
    Allisonburgh University             Timothy Saunders                         662              658.00
    Allisonburgh University             Andrew Taylor                            540              658.00
    Leonardshire University             Nicole Butler                            884              548.67
    Leonardshire University             Brian Salazar                            492              548.67
    Leonardshire University             Hannah Kelly                             270              548.67
    Maryville University                Eileen Ramirez                           540              540.00
    West Christinaton University        Alice Parrish                           1212              532.00
    West Christinaton University        Heather Hernandez                        404              532.00
    West Christinaton University        Shelly Evans                             390              532.00
    West Christinaton University        Michelle Hernandez                       330              532.00
    West Christinaton University        Emily Adams                              324              532.00
    Millsside University                Christopher Haas                         942              482.00

    15 rows selected.
*/

-- ============================================================================
-- QUERY 8: LIKE OPERATOR WITH ORDER BY
-- Find the top 15 content titles containing the letter 'a' and show their content title, viewer count, and average rating
-- ============================================================================
select
    CONTENT.Title as ContentTitle,
    count(distinct HISTORY.Student_Email) as ViewerCount,
    avg(to_number(WATCHES.Rating)) as AvgRating
from
    Fall25_S0003_T1_Content CONTENT
    join Fall25_S0003_T1_Watch_History HISTORY
        on CONTENT.Content_ID = HISTORY.Content_ID
    left join Fall25_S0003_T1_Watches WATCHES
        on HISTORY.Student_Email = WATCHES.Student_Email
        and CONTENT.Content_ID = WATCHES.Content_ID
where
    CONTENT.Title like '%a%'
group by
    CONTENT.Title
order by
    AvgRating desc nulls last,
    ViewerCount desc
fetch first 15 rows only;

/* Example Output:
    Content Title                                      Viewer Count Avg Rating
    -------------------------------------------------- ------------ ----------
    Assimilated modular superstructure                            3      10.00
    Distributed upward-trending budgetary management              5       9.00
    Triple-buffered 5thgeneration installation                    5       8.00
    Centralized context-sensitive instruction set                 8       7.00
    Stand-alone mobile policy                                     4       7.00
    Proactive actuating instruction set                           6       5.00
    Devolved maximized implementation                             6       4.00
    Distributed 3rdgeneration methodology                         4       2.00
    Self-enabling regional secured line                          10
    Reverse-engineered radical budgetary management               7
    Team-oriented non-volatile access                             7
    Organized clear-thinking adapter                              7
    Triple-buffered even-keeled adapter                           7
    Open-source 6thgeneration strategy                            7
    Streamlined contextually-based migration                      7

    15 rows selected.
*/