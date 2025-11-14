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
    Samueltown University                          18       148.67
    Priceburgh University                          15       102.67
    West Kaylaport University                      14       132.14
    East Sharon University                         14       143.57
    Loriland University                            12       115.17
    South Angelton University                      12        67.83
    Ryanmouth University                           11        95.09
    Roweberg University                             8       135.00
    Davidside University                            8        29.75

    9 rows selected.
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
    Angela Taylor                           12
    Jerome James                             8
    Heather Rush                             7
    Cindy Rivera                             7
    Daniel Murphy                            7
    Gerald Barnes                            6
    Kaitlyn Becker                           6
    Alyssa Dodson                            6
    Jesse Ferrell                            6
    Nicole Zimmerman                         6
    Alisha Schneider                         6
    William Fry                              6
    Tara Oliver                              6
    Steven Hoffman                           5
    Jessica Ramirez                          5
    David Parrish                            5
    Catherine Harper                         5
    Emily Collins                            5
    Christopher Brown                        5
    Jennifer Robinson                        5

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
    Optimized needs-based productivity                           7
    Managed web-enabled capability                               7
    User-centric attitude-oriented focus group                   7
    Business-focused disintermediate paradigm                    7
    Pre-emptive coherent concept                                 6
    Profit-focused real-time throughput                          6
    Polarized exuding artificial intelligence                    6
    Cross-group bottom-line pricing structure                    6
    Grass-roots analyzing synergy                                6
    Profit-focused radical algorithm                             6
    Operative full-range definition                              6
    Expanded human-resource strategy                             6
    Synergized solution-oriented neural-net                      6
    Seamless executive throughput                                6
    Total exuding forecast                                       6
    Team-oriented upward-trending conglomeration                 6
    Synergized dedicated moderator                               6
    Extended static matrices                                     5
    Universal mobile matrices                                    5
    Balanced systematic algorithm                                5

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
    ALL PROVIDERS                       ALL TYPES                953842.04
    Williams-Martin                     ALL TYPES                170116.23
    Williams-Martin                     Revenue-sharing          153054.16
    Campbell, Walker and King           Time-based               107241.33
    Campbell, Walker and King           ALL TYPES                107241.33
    Adams, Johnson and Reed             ALL TYPES                 92193.54
    Adams, Johnson and Reed             Time-based                85502.67
    Whitney and Sons                    Time-based                83782.14
    Whitney and Sons                    ALL TYPES                 83782.14
    Ortega-Mcguire                      ALL TYPES                 78495.62
    Ortega-Mcguire                      Revenue-sharing           78401.53
    Hernandez, Mitchell and Chan        ALL TYPES                 66733.40
    Butler and Sons                     Royalty-Based             64679.28
    Butler and Sons                     ALL TYPES                 64679.28
    Hurley, Mejia and Hunter            Time-based                64468.73
    Hurley, Mejia and Hunter            ALL TYPES                 64468.73
    Hernandez, Mitchell and Chan        Fixed                     59540.66
    Burke, George and Guzman            ALL TYPES                 43847.63
    Burke, George and Guzman            Revenue-sharing           43389.63
    Allen, Johnson and Pope             ALL TYPES                 34193.79
    Lopez Group                         ALL TYPES                 31785.53
    Randall-Lin                         ALL TYPES                 31586.26
    Allen, Johnson and Pope             Fixed                     27897.95
    Randall-Lin                         Fixed                     26961.10
    Ali, Phillips and Pacheco           ALL TYPES                 24439.84

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
    ALL TYPES       2020                      22
    ALL TYPES       2021                       9
    ALL TYPES       2022                      36
    ALL TYPES       2023                      33
    ALL TYPES       2024                      19
    ALL TYPES       2025                       9
    ALL TYPES       ALL YEARS                 78
    Movie           2020                       8
    Movie           2021                       5
    Movie           2022                       7
    Movie           2023                      22
    Movie           2024                       1
    Movie           ALL YEARS                 38
    Seasons         2020                       4
    Seasons         2022                      18
    Seasons         2023                       6
    Seasons         2024                      14
    Seasons         2025                       2
    Seasons         ALL YEARS                 37
    TV Shows        2020                      11
    TV Shows        2021                       4
    TV Shows        2022                      14
    TV Shows        2023                       9
    TV Shows        2024                       6
    TV Shows        2025                       7
    TV Shows        ALL YEARS                 43

    26 rows selected.
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
    Cindy Rivera
    Heather Rush
    Lisa Diaz
    Gina Shields
    Dana Guerrero
    Angela Taylor
    Jerome James
    Karen Wise
    Gerald Barnes
    Daniel Murphy
    Jessica Ramirez
    Marie Sanchez
    Jesse Ferrell
    Kaitlyn Becker
    Emily Collins
    Alyssa Dodson
    Megan Anderson
    Jared Williams
    Jonathon Davis
    Tara Oliver
    Sheryl Martinez
    David Parrish
    Christopher Garcia
    Catherine Harper
    Alisha Schneider

    25 rows selected.
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
    Alvarezbury University              Gerald Barnes                            854              800.00
    Alvarezbury University              Jessica Ramirez                          746              800.00
    New Christopher University          Heather Rush                             744              744.00
    Samueltown University               Nicole Zimmerman                         906              669.00
    Samueltown University               Jerome James                             840              669.00
    Samueltown University               Carl Long                                690              669.00
    Samueltown University               Colleen Moran                            240              669.00
    Gallagherfurt University            Angela Taylor                            636              636.00
    Banksview University                Christopher Brown                        626              626.00
    South Natalie University            William Fry                              902              601.00
    South Natalie University            Karen Wise                               300              601.00
    Lisaview University                 Jennifer Robinson                        576              576.00
    East Trevor University              Cindy Rivera                            1016              544.00
    East Trevor University              David Hill                                72              544.00
    East Sharon University              Jesse Ferrell                           1164              502.50

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
    Synergized solution-oriented neural-net                       6       8.00
    Implemented optimizing info-mediaries                         5       8.00
    Team-oriented upward-trending conglomeration                  6       6.00
    Expanded human-resource strategy                              6       4.00
    Fully-configurable homogeneous architecture                   4       4.00
    Ameliorated background frame                                  2       2.00
    Optimized needs-based productivity                            7
    Business-focused disintermediate paradigm                     7
    Managed web-enabled capability                                7
    User-centric attitude-oriented focus group                    7
    Grass-roots analyzing synergy                                 6
    Seamless executive throughput                                 6
    Total exuding forecast                                        6
    Synergized dedicated moderator                                6
    Operative full-range definition                               6

    15 rows selected.
*/