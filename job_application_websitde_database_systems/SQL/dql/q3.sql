--Q3
--Applications and interview scheduling
-- JOB SEEKERS:
-- Submit applications to job listings.

CREATE OR REPLACE FUNCTION submit_application(p_job_id INT, p_job_seeker_id INT)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Application (job_id, job_seeker_id, status, submission_date)
    VALUES (p_job_id, p_job_seeker_id, 'pending', CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

-- Usecase:
-- SELECT submit_application(2, 5);

--View application status: pending, hired, rejected.
CREATE OR REPLACE FUNCTION view_application_status(p_application_id INT)
RETURNS application_status AS $$
DECLARE
    v_status application_status;
BEGIN
    SELECT status
    INTO v_status
    FROM Application
    WHERE application_id = p_application_id;

    RETURN v_status;
END;
$$ LANGUAGE plpgsql;

-- Usecase:
-- SELECT view_application_status(3);

-- Withdraw submitted applications if desired.--
CREATE OR REPLACE FUNCTION delete_application(p_application_id INT)
RETURNS VOID AS $$
BEGIN
DELETE FROM Application
WHERE application_id = p_application_id;
END;
$$ LANGUAGE plpgsql;

-- Usecase:
-- SELECT delete_application(4);


-- RECRUITERS:
-- Review incoming applications with filtering by skills–
– Recruiter provides the job id and the skill, here we wrote the query for specific example, where the job_id is 4, and the skill searched is ‘Creativity’. We take the job_id too, because it is logical that the recruiter searches for specific job.

SELECT app.*
FROM Application app
JOIN Job_Seeker seeker ON app.job_seeker_id = seeker.user_id
JOIN JobSeeker_Skill jskill ON seeker.user_id = jskill.job_seeker_id
JOIN Skills skill ON jskill.skill_id = skill.skill_id
WHERE app.job_id =4
  AND skill.skill_name = ‘Creativity’;

-- Review incoming applications with filtering by experience–
– Brings only those applications, where the applicant has experience of working with given position, which is the same as the ‘title’ attribute in work history of each job seeker. We take the job_id too, because it is logical that the recruiter searches for specific job.

SELECT DISTINCT app.*
FROM Application app
JOIN Job_Seeker seeker ON app.job_seeker_id = seeker.user_id
JOIN Work_History work ON seeker.user_id = work.job_seeker_id
WHERE app.job_id =1
AND work.job_title = ‘Software Engineer';


-- Schedule interviews for selected candidate.
-- Schedules online interview for the candidate with application_id 15,
-- on 2025-05-05, at 14:00. We used the fetching property, in order to
-- bring the job seeker id and company id of that specific application automatically.

SELECT app.job_seeker_id, jobs.company_id
FROM Application app
JOIN Job_Listings jobs ON app.job_id = jobs.job_id
WHERE app.application_id = 15;

INSERT INTO Interview (application_id, job_seeker_id, company_id, interview_date, interview_time, interview_mode, feedback)
VALUES (15, v_job_seeker_id, v_company_id, '2025-05-05', '14:00', 'Online', NULL);

-- Updates the application status of the job seeker: hired or rejected.--
CREATE OR REPLACE FUNCTION update_application_status(p_application_id INT, p_new_status application_status)
RETURNS VOID AS $$
BEGIN
    UPDATE Application
    SET status = p_new_status
    WHERE application_id = p_application_id;
END;
$$ LANGUAGE plpgsql;

-- Usecase:
-- SELECT update_application_status(3, 'hired');
