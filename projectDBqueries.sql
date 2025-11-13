-- Format Settings (comment out if not needed)
set pagesize 5000
set linesize 200
set trimspool on
set tab off
set wrap off
set colsep ' '

-- Column display formats and headings
column CollegeName                 format a30           heading 'COLLEGE'
column TotalStudents               format 9999990       heading 'TOTAL_STUDENTS'
column AvgWatchMinutes             format 9999990.000   heading 'AVG_MINUTES'

column ProviderName                format a30           heading 'PROVIDER'
column TotalContent                format 9999990       heading 'TOTAL_CONTENT'
column MaxLicenseCost              format 999999990.00  heading 'MAX_LICENSE_COST'
column AvgLicenseCost              format 999999990.00  heading 'AVG_LICENSE_COST'

column GenreName                   format a15           heading 'GENRE'
column StudentName                 format a25           heading 'STUDENT'
column StudentEmail                format a40           heading 'STUDENT_EMAIL'
column ContentWatched              format 9999990       heading 'CONTENT_WATCHED'

column ContentTitle                format a40           heading 'CONTENT_TITLE'
column UniqueViewers               format 9999990       heading 'UNIQUE_VIEWERS'
column TotalViews                  format 9999990       heading 'TOTAL_VIEWS'
column AvgRating                   format 990.000       heading 'AVG_RATING'
column CollegesWatching            format a60           heading 'COLLEGES_WATCHING'

column LicenseType                 format a20           heading 'LICENSE_TYPE'
column LicenseCount                format 9999990       heading 'LICENSE_COUNT'

column WatchRank                   format 9999990       heading 'WATCH_RANK'
column TotalMinutes                format 999999990     heading 'TOTAL_MINUTES'
column RunningTotalMinutes         format 9999999990    heading 'RUNNING_TOTAL_MINUTES'

column ContentType                 format a15           heading 'CONTENT_TYPE'
column ContentYear                 format a10           heading 'CONTENT_YEAR'

column PartnershipDiscount         format 990.00        heading 'PARTNERSHIP_DISCOUNT'
column ActiveStudents              format 9999990       heading 'ACTIVE_STUDENTS'
column AvgWatchesPerStudent        format 9990.000      heading 'AVG_WATCHES_PER_STUDENT'
column AvgUniqueContentPerStudent  format 9990.000      heading 'AVG_UNIQUE_CONTENT_PER_STUDENT'

-- End format settings

-- QUERY 1: GROUP BY AND AGGREGATE QUERY
-- Find the total number of students and average watch duration by college
-- Uses robust duration parsing (supports 'mm:ss' or plain minutes) and a lenient HAVING to show results
select 
    COLLEGE.Name as CollegeName,
    count(distinct STUDENT.Email) as TotalStudents,
    avg(
        case 
            when instr(HISTORY.Duration, ':') > 0 then
                to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1)) * 60 + 
                to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') + 1))
            else
                to_number(HISTORY.Duration)
        end
    ) as AvgWatchMinutes
from 
    FALL25_S0003_T1_COLLEGE COLLEGE
    join FALL25_S0003_T1_STUDENT STUDENT on COLLEGE.College_ID = STUDENT.College_ID
    join FALL25_S0003_T1_WATCH_HISTORY HISTORY on STUDENT.Email = HISTORY.Student_Email
group by 
    COLLEGE.Name, 
    COLLEGE.College_ID
having 
    count(distinct STUDENT.Email) >= 1
order by 
    TotalStudents desc, AvgWatchMinutes desc
fetch first 15 rows only;

-- QUERY 2: GROUP BY WITH MULTIPLE RELATIONS AND HAVING
-- Find content providers with their most expensive licenses and total content count
select 
    PROVIDER.Name as ProviderName,
    count(distinct CONTENT.Content_ID) as TotalContent,
    max(to_number(replace(replace(LICENSE.License_Cost,'$',''),',',''))) as MaxLicenseCost,
    avg(to_number(replace(replace(LICENSE.License_Cost,'$',''),',',''))) as AvgLicenseCost
from 
    FALL25_S0003_T1_CONTENT_PROVIDER PROVIDER
    join FALL25_S0003_T1_LICENSE LICENSE on PROVIDER.Content_ID = LICENSE.Provider_ID
    join FALL25_S0003_T1_CONTENT CONTENT on LICENSE.License_ID = CONTENT.License_ID
group by 
    PROVIDER.Name, 
    PROVIDER.Content_ID
having 
         count(distinct CONTENT.Content_ID) >= 1 
         and max(to_number(replace(replace(LICENSE.License_Cost,'$',''),',',''))) > 40000
order by 
    MaxLicenseCost desc;

-- QUERY 3: GROUP BY WITH AGGREGATE AND NESTED SUBQUERY
-- Find students who watched content at or above the average watch time for a given genre (choose a populated one)
select 
    GENRE.Genre as GenreName,
    STUDENT.Name as StudentName,
    count(WATCHES.Content_ID) as ContentWatched,
    avg(
        case 
            when instr(HISTORY.Duration, ':') > 0 then
                to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1)) * 60 + 
                to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') + 1))
            else
                to_number(HISTORY.Duration)
        end
    ) as AvgWatchMinutes
from 
    FALL25_S0003_T1_STUDENT STUDENT
    join FALL25_S0003_T1_WATCHES WATCHES on STUDENT.Email = WATCHES.Student_Email
    join FALL25_S0003_T1_CONTENT CONTENT on WATCHES.Content_ID = CONTENT.Content_ID
    join FALL25_S0003_T1_GENRE GENRE on CONTENT.Content_ID = GENRE.Content_ID
    join FALL25_S0003_T1_WATCH_HISTORY HISTORY on STUDENT.Email = HISTORY.Student_Email and CONTENT.Content_ID = HISTORY.Content_ID
where 
    GENRE.Genre = 'Western'
group by 
    GENRE.Genre, 
    STUDENT.Name, 
    STUDENT.Email
having 
    avg(
        case 
            when instr(HISTORY.Duration, ':') > 0 then
                to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1)) * 60 + 
                to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') + 1))
            else
                to_number(HISTORY.Duration)
        end
    ) >= 
    (
        select 
            avg(
                case 
                    when instr(SUBQUERY_HISTORY.Duration, ':') > 0 then
                        to_number(substr(SUBQUERY_HISTORY.Duration, 1, instr(SUBQUERY_HISTORY.Duration, ':') - 1)) * 60 + 
                        to_number(substr(SUBQUERY_HISTORY.Duration, instr(SUBQUERY_HISTORY.Duration, ':') + 1))
                    else
                        to_number(SUBQUERY_HISTORY.Duration)
                end
            )
        from 
            FALL25_S0003_T1_WATCH_HISTORY SUBQUERY_HISTORY
            join FALL25_S0003_T1_CONTENT SUBQUERY_CONTENT on SUBQUERY_HISTORY.Content_ID = SUBQUERY_CONTENT.Content_ID
            join FALL25_S0003_T1_GENRE SUBQUERY_GENRE on SUBQUERY_CONTENT.Content_ID = SUBQUERY_GENRE.Content_ID
        where 
            SUBQUERY_GENRE.Genre = 'Western'
    )
order by 
    AvgWatchMinutes desc;

-- QUERY 4: DATA ANALYSIS WITH CUBE (Data Warehouse Query)
-- Analyze content consumption patterns by college, content type, and year with subtotals
-- Handles non-numeric 'Episodes' values by treating them as NULL in averaging
select 
    coalesce(COLLEGE.Name, 'ALL COLLEGES') as CollegeName,
    coalesce(CONTENT.Type, 'ALL TYPES') as ContentType,
    coalesce(CONTENT.Year, 'ALL YEARS') as ContentYear,
    count(distinct HISTORY.Student_Email) as UniqueViewers,
    count(HISTORY.Watch_ID) as TotalViews,
    avg(case when regexp_like(CONTENT.Episodes,'^\d+$') then to_number(CONTENT.Episodes) end) as AvgEpisodes
from 
    FALL25_S0003_T1_COLLEGE COLLEGE
    join FALL25_S0003_T1_STUDENT STUDENT on COLLEGE.College_ID = STUDENT.College_ID
    join FALL25_S0003_T1_WATCH_HISTORY HISTORY on STUDENT.Email = HISTORY.Student_Email
    join FALL25_S0003_T1_CONTENT CONTENT on HISTORY.Content_ID = CONTENT.Content_ID
where 
    CONTENT.Year between '2015' and '2025'
group by 
    cube(COLLEGE.Name, CONTENT.Type, CONTENT.Year)
having 
    grouping(COLLEGE.Name) = 1 
    and grouping(CONTENT.Type) = 1
order by 
    CollegeName, 
    ContentType, 
    ContentYear;

-- QUERY 5: DATA ANALYSIS WITH ROLLUP
-- Revenue analysis by content provider and license type with hierarchical totals
-- Cleans currency values prior to summation and averaging
select 
    coalesce(PROVIDER.Name, 'TOTAL ALL PROVIDERS') as ProviderName,
    coalesce(LICENSE.License_Type, 'ALL LICENSE TYPES') as LicenseType,
    count(LICENSE.License_ID) as LicenseCount,
    sum(to_number(replace(replace(LICENSE.License_Cost,'$',''),',',''))) as TotalLicenseCost,
    avg(to_number(replace(replace(LICENSE.License_Cost,'$',''),',',''))) as AvgLicenseCost
from 
    FALL25_S0003_T1_CONTENT_PROVIDER PROVIDER
    join FALL25_S0003_T1_LICENSE LICENSE on PROVIDER.Content_ID = LICENSE.Provider_ID
group by 
    rollup(PROVIDER.Name, LICENSE.License_Type)
having 
    grouping(LICENSE.License_Type) = 1
order by 
    grouping(PROVIDER.Name), 
    grouping(LICENSE.License_Type), 
    TotalLicenseCost desc
fetch first 20 rows only;

-- QUERY 6: DIVISION QUERY USING NOT EXISTS
-- Students who rated ALL content they watched (division of WATCH_HISTORY by WATCHES)
select distinct 
    s.Name as StudentName, 
    s.Email as StudentEmail
from 
    FALL25_S0003_T1_STUDENT s
where 
    exists (select 1 from FALL25_S0003_T1_WATCH_HISTORY wh0 where wh0.Student_Email = s.Email)
    and not exists (
        select 1
        from FALL25_S0003_T1_WATCH_HISTORY wh
        where wh.Student_Email = s.Email
        and not exists (
            select 1
            from FALL25_S0003_T1_WATCHES w
            where w.Student_Email = s.Email
              and w.Content_ID   = wh.Content_ID
        )
    );

-- QUERY 7: WINDOWING WITH OVER CLAUSE
-- Rank students by their total watch time within each college and show running totals
-- Uses robust duration parsing to handle either 'mm:ss' or minute strings
select *
from (
    select 
        COLLEGE.Name as CollegeName,
        STUDENT.Name as StudentName,
        count(HISTORY.Watch_ID) as TotalWatches,
        sum(
            case 
                when instr(HISTORY.Duration, ':') > 0 then
                    to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1 )) * 60 + 
                    to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') +1 ))
                else
                    to_number(HISTORY.Duration)
            end
        ) as TotalMinutes,
        rank() over 
        (
            partition by COLLEGE.College_ID 
            order by sum(
                case 
                    when instr(HISTORY.Duration, ':') > 0 then
                        to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1 )) * 60 + 
                        to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') +1 ))
                    else
                        to_number(HISTORY.Duration)
                end
            ) desc
        ) as WatchRank,
        sum(
            sum(
                case 
                    when instr(HISTORY.Duration, ':') > 0 then
                        to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1 )) * 60 + 
                        to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') +1 ))
                    else
                        to_number(HISTORY.Duration)
                end
            )
        ) 
        over 
        (
            partition by COLLEGE.College_ID 
            order by sum(
                case 
                    when instr(HISTORY.Duration, ':') > 0 then
                        to_number(substr(HISTORY.Duration, 1, instr(HISTORY.Duration, ':') - 1 )) * 60 + 
                        to_number(substr(HISTORY.Duration, instr(HISTORY.Duration, ':') +1 ))
                    else
                        to_number(HISTORY.Duration)
                end
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
)
order by CollegeName, WatchRank
fetch first 20 rows only;

-- QUERY 8: LIKE OPERATOR WITH JOIN AND ORDER BY/FETCH
-- Find top 10 most popular content titles containing the letter 'o' (ensures sample data returns rows)
-- Shows content discovery and popularity metrics for targeted marketing
select 
    CONTENT.Title as ContentTitle,
    count(distinct HISTORY.Student_Email) as UniqueViewers,
    count(HISTORY.Watch_ID) as TotalViews,
    avg(to_number(WATCHES.Rating)) as AvgRating,
    listagg(distinct COLLEGE.Name, ', ') within group (order by COLLEGE.Name) as CollegesWatching
from 
    FALL25_S0003_T1_CONTENT CONTENT
    join FALL25_S0003_T1_WATCH_HISTORY HISTORY on CONTENT.Content_ID = HISTORY.Content_ID
    join FALL25_S0003_T1_STUDENT STUDENT on HISTORY.Student_Email = STUDENT.Email
    join FALL25_S0003_T1_COLLEGE COLLEGE on STUDENT.College_ID = COLLEGE.College_ID
    left join FALL25_S0003_T1_WATCHES WATCHES on STUDENT.Email = WATCHES.Student_Email 
        and CONTENT.Content_ID = WATCHES.Content_ID
where 
    CONTENT.Title like '%o%'
group by 
    CONTENT.Title, 
    CONTENT.Content_ID
order by 
    UniqueViewers desc, 
    AvgRating desc
fetch first 10 rows only;

-- QUERY 9: COMPLEX JOIN WITH SUBQUERY AND AGGREGATION
-- Provider engagement effectiveness: providers with at least one viewer, with per-student watch stats
select 
    p.Name as ProviderName,
    count(distinct wh.Student_Email) as ActiveStudents,
    count(distinct c.Content_ID) as CatalogSize,
    avg(stats.TotalWatches) as AvgWatchesPerStudent
from 
    FALL25_S0003_T1_CONTENT_PROVIDER p
    join FALL25_S0003_T1_LICENSE l on p.Content_ID = l.Provider_ID
    join FALL25_S0003_T1_CONTENT c on l.License_ID = c.License_ID
    left join FALL25_S0003_T1_WATCH_HISTORY wh on c.Content_ID = wh.Content_ID
    left join (
        select Student_Email, count(*) as TotalWatches
        from FALL25_S0003_T1_WATCH_HISTORY
        group by Student_Email
    ) stats on stats.Student_Email = wh.Student_Email
group by 
    p.Name
having 
    count(distinct wh.Student_Email) >= 1
order by 
    ActiveStudents desc, CatalogSize desc
fetch first 10 rows only;