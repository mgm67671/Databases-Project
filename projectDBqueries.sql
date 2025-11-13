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

column ContentTitle                format a50           heading 'CONTENT_TITLE'
column UniqueViewers               format 9999990       heading 'UNIQUE_VIEWERS'
column TotalViews                  format 9999990       heading 'TOTAL_VIEWS'
column AvgRating                   format 990.000       heading 'AVG_RATING'
column CollegesWatching            format a60           heading 'COLLEGES_WATCHING'

column ProviderName                format a30           heading 'PROVIDER_NAME'
column LicenseType                 format a20           heading 'LICENSE_TYPE'
column LicenseCount                format 9999990       heading 'LICENSE_COUNT'
column TotalLicenseCost            format 999999990.00  heading 'TOTAL_LICENSE_COST'
column AvgLicenseCost              format 999999990.00  heading 'AVG_LICENSE_COST'

column WatchRank                   format 9999990       heading 'WATCH_RANK'
column TotalWatches                format 9999990       heading 'TOTAL_WATCHES'
column TotalMinutes                format 999999990     heading 'TOTAL_MINUTES'
column RunningTotalMinutes         format 9999999990    heading 'RUNNING_TOTAL_MINUTES'

column ContentType                 format a15           heading 'CONTENT_TYPE'
column ContentYear                 format a15           heading 'CONTENT_YEAR'
column AvgEpisodes                 format 990.000       heading 'AVG_EPISODES'

column PartnershipDiscount         format 990.00        heading 'PARTNERSHIP_DISCOUNT'
column ActiveStudents              format 9999990       heading 'ACTIVE_STUDENTS'
column AvgWatchesPerStudent        format 9990.000      heading 'AVG_WATCHES_PER_STUDENT'
column AvgUniqueContentPerStudent  format 9990.000      heading 'AVG_UNIQUE_CONTENT_PER_STUDENT'

-- End format settings

-- ============================================================================
-- QUERY 1: GROUP BY AND AGGREGATE QUERY WITH MULTIPLE RELATIONS
-- Business Goal: Identify colleges with multiple active students and their
-- average watch time to prioritize partnership renewal and resource allocation.
-- ============================================================================
select 
    COLLEGE.Name as CollegeName,
    count(distinct STUDENT.Email) as TotalStudents,
    count(HISTORY.Watch_ID) as TotalWatches,
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
    count(distinct STUDENT.Email) > 1
    and count(HISTORY.Watch_ID) >= 2
order by 
    TotalStudents desc, TotalWatches desc, AvgWatchMinutes desc
fetch first 15 rows only;

-- ============================================================================
-- QUERY 2: DATA WAREHOUSE ANALYSIS WITH CUBE
-- Business Goal: Analyze yearly content consumption trends across all colleges
-- to understand platform growth patterns and content popularity by year.
-- ============================================================================
-- Analyze content consumption patterns by college, content type, and year with subtotals
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
order by 
    CollegeName, 
    ContentType, 
    ContentYear;

-- ============================================================================
-- QUERY 3: DATA WAREHOUSE REVENUE ANALYSIS WITH ROLLUP
-- Business Goal: Calculate total licensing costs by provider with hierarchical 
-- subtotals to identify the most expensive content partnerships.
-- ============================================================================
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
/*having 
    grouping(LICENSE.License_Type) = 1*/
order by 
    grouping(PROVIDER.Name), 
    grouping(LICENSE.License_Type), 
    TotalLicenseCost desc
/*fetch first 20 rows only*/;

-- ============================================================================
-- QUERY 4: DIVISION QUERY - STUDENTS WHO RATED ALL WATCHED CONTENT
-- Business Goal: Find highly engaged students who provide ratings for every 
-- piece of content they watch, useful for identifying reliable reviewers.
-- ============================================================================
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

-- ============================================================================
-- QUERY 5: WINDOWING QUERY WITH OVER CLAUSE FOR STUDENT RANKING
-- Business Goal: Rank students by total watch time within each college to 
-- identify top viewers and calculate running totals for engagement metrics.
-- ============================================================================
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

-- ============================================================================
-- QUERY 6: CONTENT DISCOVERY WITH LIKE OPERATOR, ORDER BY, AND FETCH
-- Business Goal: Find the most popular content with specific keywords in the 
-- title to support content recommendation and marketing campaigns.
-- ============================================================================
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

-- ============================================================================
-- QUERY 7: PROVIDER ENGAGEMENT WITH NESTED SUBQUERY AND AGGREGATION
-- Business Goal: Identify content providers with the highest viewer engagement 
-- by analyzing catalog size and average watch frequency per student.
-- ============================================================================
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