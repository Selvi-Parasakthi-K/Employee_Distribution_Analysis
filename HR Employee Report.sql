create database projects;

SELECT * FROM hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr;


SELECT birthdate FROM hr;


SET sql_safe_updates = 0;
UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;


ALTER TABLE hr
MODIFY COLUMN birthdate DATE;


UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;


ALTER TABLE hr
MODIFY COLUMN hire_date DATE;


ALTER TABLE hr ADD COLUMN age INT;


UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());


SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM hr;


SELECT count(*) FROM hr WHERE age < 18;


SELECT COUNT(*) FROM hr WHERE termdate > CURDATE();


SELECT COUNT(*)
FROM hr
WHERE termdate = '0000-00-00';


SELECT location FROM hr;




-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, count(*) AS count from hr
WHERE age >= 18 OR termdate = '0000-00-00'
GROUP BY gender;


-- 2. What is the race/ethnicity breakdown of employees in the company?
select race, count(*) as count
from hr
where age >=  18 or termdate = '0000-00-00'
group by race
order by count(*) desc;


-- 3. What is the age distribution of employees in the company?
select 
	min(age) as youngest,
    max(age) as oldest
from hr
where age >= 18 or termdate = '0000-00-00';

select
	case
		when age >= 18 and age <=24 then '18-24'
        when age >= 25 and age <=34 then '25-34'
        when age >= 35 and age <=44 then '35-44'
        when age >= 45 and age <=54 then '45-54'
        when age >= 55 and age <=64 then '55-64'
        else '65+'
	end as age_group,gender,
    count(*) as count
from hr
where age >= 18 or termdate = '0000-00-00'
group by age_group,gender
order by age_group,gender;


-- 4. How many employees work at headquarters versus remote locations?
select location, count(*) as count from hr
where age >= 18 or termdate = '0000-00-00'
group by location;


-- 5. What is the average length of employment for employees who have been terminated?
select 
	round(avg(datediff(termdate, hire_date))/365,0) as avg_length_employment
from hr
where termdate <= curdate() and termdate <> '0000-00-00' or age >= 18;



-- 6. How does the gender distribution vary across departments and job titles?
select department, gender, count(*) as count from hr
where age >= 18 or termdate = '0000-00-00'
group by department, gender
order by department;


-- 7. What is the distribution of job titles across the company?
select jobtitle, count(*) as count from hr
where age >= 18 or termdate = '0000-00-00'
group by jobtitle
order by jobtitle desc;


-- 8. Which department has the highest turnover rate?
select department,total_count,terminated_count,terminated_count/total_count as termination_rate
from(
	select department,
    count(*) as total_count,
    sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminated_count
    from hr
    where age >= 18
    group by department
    ) as subquery
    order by termination_rate desc;
    
    
    -- 9. What is the distribution of employees across locations by city and state?
    select location_state, count(*) as count
    from hr
    where age >= 18 or termdate = '0000-00-00'
    group by location_state
    order by count desc;
    
    
    -- 10. How has the company's employee count changed over time based on hire and term dates?
    select year, hires, terminations, hires - terminations as net_change,
    round((hires - terminations)/hires * 100,2) as net_change_percent
    from(
		select
			year(hire_date) as year,
            count(*) as hires,
            sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminations
            from hr
            where age >= 18
            group by year(hire_date)
            ) as subquery
		order by year asc;
        
        

-- 11. What is the tenure distribution for each department?
select department, round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
from hr
where termdate <= curdate() and termdate<> '0000-00-00' and age >= 18
group by department;
    
