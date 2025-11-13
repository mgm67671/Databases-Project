-- QUERY 1: GROUP BY AND AGGREGATE QUERY
-- Find the total number of students and average watch duration by college
-- This query shows which colleges have the most active streaming users
select 
    COLLEGE.Name as CollegeName,
    count(distinct STUDENT.Email) as TotalStudents,
    avg
    (
        to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1)) * 60 + 
        to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') + 1))
    ) as AvgWatchMinutes
from 
    FALL25_S0003_T1_COLLEGE COLLEGE
    join FALL25_S0003_T1_STUDENT STUDENT on COLLEGE.College_ID = STUDENT.College_ID
    join FALL25_S0003_T1_WATCH_HISTORY HISTORY on STUDENT.Email = HISTORY.Student_Email
group by 
    COLLEGE.Name, 
    COLLEGE.College_ID
having 
    count(distinct STUDENT.Email) > 5
order by 
    TotalStudents desc;

-- QUERY 2: GROUP BY WITH MULTIPLE RELATIONS AND HAVING
-- Find content providers with their most expensive licenses and total content count
-- Shows which providers offer premium content and their catalog size
select 
    PROVIDER.Name as ProviderName,
    count(distinct CONTENT.Content_ID) as TotalContent,
    max(to_number(LICENSE.License_Cost)) as MaxLicenseCost,
    avg(to_number(LICENSE.License_Cost)) as AvgLicenseCost
from 
    FALL25_S0003_T1_CONTENT_PROVIDER PROVIDER
    join FALL25_S0003_T1_LICENSE LICENSE on PROVIDER.Content_ID = LICENSE.Provider_ID
    join FALL25_S0003_T1_CONTENT CONTENT on LICENSE.License_ID = CONTENT.License_ID
group by 
    PROVIDER.Name, 
    PROVIDER.Content_ID
having 
    count(distinct CONTENT.Content_ID) >= 3 
    and max(to_number(LICENSE.License_Cost)) > 50000
order by 
    MaxLicenseCost desc;

-- QUERY 3: GROUP BY WITH AGGREGATE AND NESTED SUBQUERY
-- Find students who have watched content above the average watch time per genre
-- This identifies power users for specific genres
select 
    GENRE.Genre as GenreName,
    STUDENT.Name as StudentName,
    count(WATCHES.Content_ID) as ContentWatched,
    avg
    (
        to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1)) * 60 + 
        to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') + 1))
    ) as AvgWatchMinutes
from 
    FALL25_S0003_T1_STUDENT STUDENT
    join FALL25_S0003_T1_WATCHES WATCHES on STUDENT.Email = WATCHES.Student_Email
    join FALL25_S0003_T1_CONTENT CONTENT on WATCHES.Content_ID = CONTENT.Content_ID
    join FALL25_S0003_T1_GENRE GENRE on CONTENT.Content_ID = GENRE.Content_ID
    join FALL25_S0003_T1_WATCH_HISTORY HISTORY on STUDENT.Email = HISTORY.Student_Email and CONTENT.Content_ID = HISTORY.Content_ID
where 
    GENRE.Genre = 'Drama'
group by 
    GENRE.Genre, 
    STUDENT.Name, 
    STUDENT.Email
having 
    avg
    (
        to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1)) * 60 + 
        to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') + 1))
    ) > 
    (
        select 
            avg
            (
                to_number(substr(SUBQUERY_HISTORY.Duration, 1, instr(SUBQUERY_HISTORY.Duration, ':') - 1)) * 60 + 
                to_number(substr(SUBQUERY_HISTORY.Duration, instr(SUBQUERY_HISTORY.Duration, ':') + 1))
            )
        from 
            FALL25_S0003_T1_WATCH_HISTORY SUBQUERY_HISTORY
            join FALL25_S0003_T1_CONTENT SUBQUERY_CONTENT on SUBQUERY_HISTORY.Content_ID = SUBQUERY_CONTENT.Content_ID
            join FALL25_S0003_T1_GENRE SUBQUERY_GENRE on SUBQUERY_CONTENT.Content_ID = SUBQUERY_GENRE.Content_ID
        where 
            SUBQUERY_GENRE.Genre = 'Drama'
    )
order by 
    AvgWatchMinutes desc;

-- QUERY 4: DATA ANALYSIS WITH CUBE (Data Warehouse Query)
-- Analyze content consumption patterns by college, content type, and year with subtotals
-- Provides comprehensive breakdown for business intelligence
select 
    coalesce(COLLEGE.Name, 'ALL COLLEGES') as CollegeName,
    coalesce(CONTENT.Type, 'ALL TYPES') as ContentType,
    coalesce(CONTENT.Year, 'ALL YEARS') as ContentYear,
    count(distinct HISTORY.Student_Email) as UniqueViewers,
    count(HISTORY.Watch_ID) as TotalViews,
    avg(to_number(CONTENT.Episodes)) as AvgEpisodes
from 
    FALL25_S0003_T1_COLLEGE COLLEGE
    join FALL25_S0003_T1_STUDENT STUDENT on COLLEGE.College_ID = STUDENT.College_ID
    join FALL25_S0003_T1_WATCH_HISTORY HISTORY on STUDENT.Email = HISTORY.Student_Email
    join FALL25_S0003_T1_CONTENT CONTENT on HISTORY.Content_ID = CONTENT.Content_ID
where 
    CONTENT.Year between '2020' and '2024'
group by 
    cube(COLLEGE.Name, CONTENT.Type, CONTENT.Year)
order by 
    CollegeName, 
    ContentType, 
    ContentYear;

-- QUERY 5: DATA ANALYSIS WITH ROLLUP
-- Revenue analysis by content provider and license type with hierarchical totals
-- Shows financial performance at different aggregation levels
select 
    coalesce(PROVIDER.Name, 'TOTAL ALL PROVIDERS') as ProviderName,
    coalesce(LICENSE.License_Type, 'ALL LICENSE TYPES') as LicenseType,
    count(LICENSE.License_ID) as LicenseCount,
    sum(to_number(LICENSE.License_Cost)) as TotalLicenseCost,
    avg(to_number(LICENSE.License_Cost)) as AvgLicenseCost
from 
    FALL25_S0003_T1_CONTENT_PROVIDER PROVIDER
    join FALL25_S0003_T1_LICENSE LICENSE on PROVIDER.Content_ID = LICENSE.Provider_ID
group by 
    rollup(PROVIDER.Name, LICENSE.License_Type)
order by 
    grouping(PROVIDER.Name), 
    grouping(LICENSE.License_Type), 
    TotalLicenseCost desc;

-- QUERY 6: DIVISION QUERY USING NOT EXISTS
-- Find students who have watched all content from providers that offer "Family" genre content
-- This demonstrates the division concept - students who are complete consumers of family content providers
select distinct 
    STUDENT.Name as StudentName, 
    STUDENT.Email as StudentEmail
from 
    FALL25_S0003_T1_STUDENT STUDENT
where 
    not exists 
    (
        select 
            CONTENT.Content_ID
        from 
            FALL25_S0003_T1_CONTENT CONTENT
            join FALL25_S0003_T1_LICENSE LICENSE on CONTENT.License_ID = LICENSE.License_ID
            join FALL25_S0003_T1_CONTENT_PROVIDER PROVIDER on LICENSE.Provider_ID = PROVIDER.Content_ID
        where 
            PROVIDER.Content_ID in 
            (
                select distinct 
                    SUBQUERY_PROVIDER.Content_ID
                from 
                    FALL25_S0003_T1_CONTENT_PROVIDER SUBQUERY_PROVIDER
                    join FALL25_S0003_T1_LICENSE SUBQUERY_LICENSE on SUBQUERY_PROVIDER.Content_ID = SUBQUERY_LICENSE.Provider_ID
                    join FALL25_S0003_T1_CONTENT SUBQUERY_CONTENT on SUBQUERY_LICENSE.License_ID = SUBQUERY_CONTENT.License_ID
                    join FALL25_S0003_T1_GENRE SUBQUERY_GENRE on SUBQUERY_CONTENT.Content_ID = SUBQUERY_GENRE.Content_ID
                where 
                    SUBQUERY_GENRE.Genre = 'Family'
            )
            and not exists 
            (
                select 
                    1
                from 
                    FALL25_S0003_T1_WATCHES WATCHES
                where 
                    WATCHES.Student_Email = STUDENT.Email 
                    and WATCHES.Content_ID = CONTENT.Content_ID
            )
    )
    and STUDENT.Email in 
    (
        select distinct 
            FAMILY_WATCHES.Student_Email
        from 
            FALL25_S0003_T1_WATCHES FAMILY_WATCHES
            join FALL25_S0003_T1_CONTENT FAMILY_CONTENT on FAMILY_WATCHES.Content_ID = FAMILY_CONTENT.Content_ID
            join FALL25_S0003_T1_GENRE FAMILY_GENRE on FAMILY_CONTENT.Content_ID = FAMILY_GENRE.Content_ID
        where 
            FAMILY_GENRE.Genre = 'Family'
    );

-- QUERY 7: WINDOWING WITH OVER CLAUSE
-- Rank students by their total watch time within each college and show running totals
-- Demonstrates advanced analytical functions for user engagement analysis
select 
    COLLEGE.Name as CollegeName,
    STUDENT.Name as StudentName,
    count(HISTORY.Watch_ID) as TotalWatches,
    sum
    (
        to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1 )) * 60 + 
        to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') +1 ))
    ) as TotalMinutes,
    rank() over 
    (
        partition by COLLEGE.College_ID 
        order by sum
        (
            to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1 )) * 60 + 
            to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') +1 ))
        ) desc
    ) as WatchRank,
    sum
    (
        sum
        (
            to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1 )) * 60 + 
            to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') +1 ))
        )
    ) 
    over 
    (
        partition by COLLEGE.College_ID 
        order by sum
        (
            to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1 )) * 60 + 
            to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') +1 ))
        ) desc 
        rows unbounded preceding    
    ) as RunningTotalMinutes
from 
    FALL25_S0003_T1_COLLEGE COLLEGE
    join FALL25_S0003_T1_STUDENT STUDENT on COLLEGE.College_ID = STUDENT.College_ID
    join FALL25_S0003_T1_WATCH_HISTORY HISTORY on STUDENT.Email = HISTORY.Student_Email
group by 
    COLLEGE.Name, 
    COLLEGE.College_ID, 
    STUDENT.Name, 
    STUDENT.Email
order by 
    COLLEGE.Name, 
    WatchRank;

-- QUERY 8: LIKE OPERATOR WITH JOIN AND ORDER BY/FETCH
-- Find top 10 most popular content titles containing "Love" in colleges with names starting with specific patterns
-- Shows content discovery and popularity metrics for targeted marketing
select 
    CONTENT.Title as ContentTitle,
    count(distinct HISTORY.Student_Email) as UniqueViewers,
    count(HISTORY.Watch_ID) as TotalViews,
    avg(cast(WATCHES.Rating as number)) as AvgRating,
    string_agg(distinct COLLEGE.Name, ', ') as CollegesWatching
from 
    FALL25_S0003_T1_CONTENT CONTENT
    join FALL25_S0003_T1_WATCH_HISTORY HISTORY on CONTENT.Content_ID = HISTORY.Content_ID
    join FALL25_S0003_T1_STUDENT STUDENT on HISTORY.Student_Email = STUDENT.Email
    join FALL25_S0003_T1_COLLEGE COLLEGE on STUDENT.College_ID = COLLEGE.College_ID
    left join FALL25_S0003_T1_WATCHES WATCHES on STUDENT.Email = WATCHES.Student_Email 
        and CONTENT.Content_ID = WATCHES.Content_ID
where 
    CONTENT.Title like '%Love%' 
    and COLLEGE.Name like 'College_%'
    and COLLEGE.College_ID like '0000000[1-5]'
group by 
    CONTENT.Title, 
    CONTENT.Content_ID
order by 
    UniqueViewers desc, 
    AvgRating desc
fetch first 10 rows only;

-- QUERY 9: COMPLEX JOIN WITH SUBQUERY AND AGGREGATION
-- Analyze partnership effectiveness by finding colleges with above-average student engagement
-- Uses multiple relations and nested queries to identify successful partnerships
select 
    COLLEGE.Name as CollegeName,
    PARTNERSHIP_INFO.Discount as PartnershipDiscount,
    count(distinct STUDENT.Email) as ActiveStudents,
    avg(STUDENT_STATS.TotalWatches) as AvgWatchesPerStudent,
    avg(STUDENT_STATS.UniqueContent) as AvgUniqueContentPerStudent
from 
    FALL25_S0003_T1_COLLEGE COLLEGE
    join FALL25_S0003_T1_PARTNERSHIP_INFORMATION PARTNERSHIP_INFO on COLLEGE.College_ID = PARTNERSHIP_INFO.College_ID
    join FALL25_S0003_T1_STUDENT STUDENT on COLLEGE.College_ID = STUDENT.College_ID
    join 
    (
        select 
            SUBQUERY_STUDENT.Email as StudentEmail,
            count(SUBQUERY_HISTORY.Watch_ID) as TotalWatches,
            count(distinct SUBQUERY_HISTORY.Content_ID) as UniqueContent
        from 
            FALL25_S0003_T1_STUDENT SUBQUERY_STUDENT
            join FALL25_S0003_T1_WATCH_HISTORY SUBQUERY_HISTORY on SUBQUERY_STUDENT.Email = SUBQUERY_HISTORY.Student_Email
        group by 
            SUBQUERY_STUDENT.Email
    ) STUDENT_STATS on STUDENT.Email = STUDENT_STATS.StudentEmail
where 
    PARTNERSHIP_INFO.End_Date > sysdate
group by 
    COLLEGE.Name, 
    COLLEGE.College_ID, 
    PARTNERSHIP_INFO.Discount
having 
    count(distinct STUDENT.Email) > 
    (
        select 
            avg(StudentCount)
        from 
        (
            select 
                count(distinct AVG_STUDENT.Email) as StudentCount
            from 
                FALL25_S0003_T1_COLLEGE AVG_COLLEGE
                join FALL25_S0003_T1_STUDENT AVG_STUDENT on AVG_COLLEGE.College_ID = AVG_STUDENT.College_ID
            group by 
                AVG_COLLEGE.College_ID
        )
    )
order by 
    AvgWatchesPerStudent desc;