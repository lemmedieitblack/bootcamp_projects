--Q5
--Reporting operations
-- Generate a list of top applicants based on total experience–
SELECT seeker.user_id, seeker.first_name, seeker.last_name, SUM(work.experience_years) AS total_experience
FROM Job_Seeker seeker
JOIN Work_History work ON seeker.user_id = work.job_seeker_id
GROUP BY seeker.user_id, seeker.first_name, seeker.last_name
ORDER BY total_experience DESC;

-- Generate a list of top applicants based on number of skills
SELECT seeker.user_id, seeker.first_name, seeker.last_name, COUNT(jskill.skill_id) AS skill_count
FROM Job_Seeker seeker
JOIN JobSeeker_Skill jskill ON seeker.user_id = jskill.job_seeker_id
GROUP BY seeker.user_id, seeker.first_name, seeker.last_name
ORDER BY skill_count DESC;

-- Generate a list of top applicants based on prior hiring success–
SELECT seeker.user_id, seeker.first_name, seeker.last_name, COUNT(app.application_id) AS hired_count
FROM Job_Seeker seeker
JOIN Application app ON seeker.user_id = app.job_seeker_id
WHERE app.status = 'hired'
GROUP BY seeker.user_id, seeker.first_name, seeker.last_name
ORDER BY hired_count DESC;

-- Identify the most in-demand skills across job seekers.--
SELECT skill.skill_name, COUNT(*) AS demand_count
FROM JobSeeker_Skill jskill
JOIN Skills skill ON jskill.skill_id = skill.skill_id
GROUP BY skill.skill_name
ORDER BY demand_count DESC;

-- Although DATE_TRUNC was not explicitly covered in our course materials, we used it in the following six queries as the easiest and most accurate way to group dates by month/week or quarter.
-- In this query, DATE_TRUNC('month', posting_date) cuts off the day and time parts, keeping only the year and month.
-- which allows us to correctly group and count job postings per month without needing complex formatting, the same thing works for week and quarter

-- Report on the number of job postings MONTHLY
SELECT DATE_TRUNC('month', posting_date) AS month, COUNT(*) AS job_postings
FROM Job_Listings
GROUP BY month
ORDER BY month;
-- Report on the number of hires MONTHLY
SELECT DATE_TRUNC('month', submission_date) AS month, COUNT(*) AS hires
FROM Application
WHERE status = 'hired'
GROUP BY month
ORDER BY month;

-- Report on the number of job postings WEEKLY
SELECT DATE_TRUNC('week', posting_date) AS week, COUNT(*) AS job_postings
FROM Job_Listings
GROUP BY week
ORDER BY week;
-- Report on the number of hires WEEKLY
SELECT DATE_TRUNC('week', submission_date) AS week, COUNT(*) AS hires
FROM Application
WHERE status = 'hired'
GROUP BY week
ORDER BY week;

-- Report on the number of job postings QUARTERLY
SELECT DATE_TRUNC('quarter', posting_date) AS quarter, COUNT(*) AS job_postings
FROM Job_Listings
GROUP BY quarter
ORDER BY quarter;
-- Report on the number of hires QUARTERLY
SELECT DATE_TRUNC('quarter', submission_date) AS quarter, COUNT(*) AS hires
FROM Application
WHERE status = 'hired'
GROUP BY quarter
ORDER BY quarter;

-- Track how many applications were submitted.
-- Returns the total number of applications submitted by the job seeker with user_id = 7.
SELECT COUNT(*) AS total_applications
FROM Application
WHERE job_seeker_id = 7;

-- Track how many applications led to interviews.
-- Returns the total number of applications submitted and how many of them resulted in interviews for the job seeker with user_id = 7.
SELECT 
    COUNT(DISTINCT app.application_id) AS total_applications,
    COUNT(DISTINCT intv.interview_id) AS total_interviews
FROM Application app
LEFT JOIN Interview intv ON app.application_id = intv.application_id
WHERE app.job_seeker_id = 7;

--Check the availability of jobs by a specific field, and notify job seekers when matching jobs appear.

CREATE OR REPLACE FUNCTION notify_job_seekers_on_new_job()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a notification if the new job title matches any work history title
    IF EXISTS (
        SELECT 1
        FROM Work_History
        WHERE NEW.title ILIKE '%' || job_title || '%'
    ) THEN
        INSERT INTO Notification (message)
        VALUES ('New job related to your experience: ' || NEW.title);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Usecase:
-- After inserting a new job listing like 
-- INSERT INTO Job_Listings (company_id, admin_id, title, location) VALUES (1, 1, 'Software Engineer', 'New York');
-- the trigger will automatically fire and insert into Notification if matched.


CREATE TRIGGER trg_notify_job_seekers
AFTER INSERT ON Job_Listings
FOR EACH ROW
EXECUTE FUNCTION notify_job_seekers_on_new_job();

--Automatically suggest similar job listings based on job seekers previous applications.

CREATE OR REPLACE FUNCTION notify_jobseekers_based_on_applications()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a notification if the new job title matches any previously applied job titles
    IF EXISTS (
        SELECT 1
        FROM Application app
        JOIN Job_Listings old_job ON app.job_id = old_job.job_id
        WHERE NEW.title ILIKE '%' || old_job.title || '%'
    ) THEN
        INSERT INTO Notification (message)
        VALUES ('New job similar to one you applied for: ' || NEW.title);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Usecase:
-- After inserting a new job listing like
-- INSERT INTO Job_Listings (company_id, admin_id, title, location) VALUES (2, 2, 'Backend Developer', 'Chicago');
-- the trigger will check if the title matches any previously applied jobs and create a Notification if matched.

CREATE TRIGGER trg_notify_on_new_job_from_applications
AFTER INSERT ON Job_Listings
FOR EACH ROW
EXECUTE FUNCTION notify_jobseekers_based_on_applications();
