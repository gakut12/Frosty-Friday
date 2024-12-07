-- Setting Environment
use role sysadmin;
use warehouse gaku_wh;
use database frosty_friday;
create or replace schema week122;

-- Setup Script
-- Step 1
CREATE TABLE student_enroll_info (
    student_id INT PRIMARY KEY,
    course VARCHAR(50),
    duration VARCHAR(50)
);

-- Step 2: Insert data into the table
INSERT INTO student_enroll_info (student_id, course, duration) VALUES
(1, 'CSE', 'Four Years'),
(2, 'EEE', 'Three Years'),
(3, 'CSE', 'Four Years'),
(4, 'MSC', 'Three Years'),
(5, 'BSC', 'Three Years'),
(6, 'Mech', 'Four Years');


select * from student_enroll_info;

-- course count (1)
select course, count(*) from student_enroll_info group by course;

-- duration count(2)
select duration, count(*) from student_enroll_info group by duration;


--  (1) union all (2)
select course, count(*) from student_enroll_info group by course
union all 
select duration, count(*) from student_enroll_info group by duration;


-- use group by grouping sets
select 
    count(*)
    , course
    , duration 
from 
    student_enroll_info
group by grouping sets (course, duration)
;


-- use group by ( without grouping sets)
select 
    count(*)
    , course
    , duration 
from 
    student_enroll_info
group by course, duration
;
