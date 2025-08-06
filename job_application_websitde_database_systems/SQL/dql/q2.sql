--Post new job openings with all relevant details including required experience, skills, salary, and contract type
CREATE OR REPLACE FUNCTION post_new_job (
    p_company_id INT,
    p_admin_id INT,
    p_title VARCHAR,
    p_description TEXT,
    p_location VARCHAR,
    p_expiration_date DATE,
    p_required_experience INT,
    p_salary_range VARCHAR,
    p_contract_type VARCHAR
)
RETURNS VOID AS $$
BEGIN
    -- Insert a new job listing
    INSERT INTO Job_Listings (
        company_id, 
        admin_id, 
        title, 
        description, 
        location, 
        expiration_date, 
        required_experience, 
        salary_range, 
        contract_type, 
        status
    )
    VALUES (
        p_company_id,         
        p_admin_id,           
        p_title,              
        p_description,      
        p_location,           
        p_expiration_date,   
        p_required_experience, 
        p_salary_range,       
        p_contract_type,      
        'Open'                
    );
END;
$$ LANGUAGE plpgsql;

--Q2
-- Job listings and management
-- Post a new job with all the required details
SELECT post_new_job(
    1,                          -- company_id
    1,                          -- admin_id
    'Software Engineer',        -- job title
    'Looking for a passionate software engineer with experience in full-stack development.',  -- job description
    'Yerevan, Armenia',         -- location
    '2025-12-31',               -- expiration date
    3,                          -- required experience (in years)
    '2500-3000 USD',            -- salary range
    'Full-time'                 -- contract type
);



--System automatically marks jobs as "closed" upon reaching expiration date.
   UPDATE Job_Listings
   SET status = 'Closed'
   WHERE expiration_date < CURRENT_DATE
   AND status != 'Closed'; 

--This function updates job details (salary, required experience, description, etc.) based on the provided parameters, but only updates fields with non-NULL values. COALESCE() ensures that if a parameter is NULL, the existing value in the database is used instead of updating the column with a NULL value.

CREATE OR REPLACE FUNCTION update_job_details (
    p_job_id INT,
    p_salary_range VARCHAR DEFAULT NULL,
    p_required_experience INT DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_location VARCHAR DEFAULT NULL,
    p_expiration_date DATE DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    UPDATE Job_Listings
    SET 
        salary_range = COALESCE(p_salary_range, salary_range), 
        required_experience = COALESCE(p_required_experience, required_experience),  
        description = COALESCE(p_description, description),
        location = COALESCE(p_location, location), 
        expiration_date = COALESCE(p_expiration_date, expiration_date)
    WHERE job_id = p_job_id;
END;
$$ LANGUAGE plpgsql;

-- Example: Update salary range and required experience for job with job_id = 1
SELECT update_job_details(
    1,                          -- job_id
    '3000-3500 USD',            -- new salary range
    5,                          -- new required experience (in years)
    NULL,                       -- no change to description
    NULL,                       -- no change to location
    NULL                        -- no change to expiration date
);


--This function inserts a notification about a job update and sends it to all applicants who have applied for that specific job.

CREATE OR REPLACE FUNCTION notify_applicants_of_update (
    p_job_id INT,
    p_message TEXT
)
RETURNS VOID AS $$
DECLARE
    new_notification_id INT;
BEGIN
    -- Insert a new notification
    INSERT INTO Notification (message)
    VALUES (p_message)
    RETURNING notification_id INTO new_notification_id;

    --Insert records into Receives table to notify all applicants for this job
    INSERT INTO Receives (user_id, notification_id)
    SELECT job_seeker_id, new_notification_id
    FROM Application
    WHERE job_id = p_job_id;
END;
$$ LANGUAGE plpgsql;

--Search and filter jobs by category, location, salary, contract type, required skills, and other criteria.
CREATE OR REPLACE FUNCTION search_jobs (
    p_location VARCHAR DEFAULT NULL,
    p_salary_range_start VARCHAR DEFAULT NULL,
    p_salary_range_end VARCHAR DEFAULT NULL,
    p_contract_type VARCHAR DEFAULT NULL,
    p_required_experience INT DEFAULT NULL,
    p_skill_name VARCHAR DEFAULT NULL,
    p_status VARCHAR DEFAULT NULL
)
RETURNS TABLE(job_id INT, title VARCHAR, salary_range VARCHAR, location VARCHAR, contract_type VARCHAR, required_experience INT, status VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT jl.job_id, jl.title, jl.salary_range, jl.location, jl.contract_type, jl.required_experience, jl.status
    FROM Job_Listings jl
    LEFT JOIN JobSeeker_Skill jss ON jl.job_id = jss.job_id
    LEFT JOIN Skills s ON jss.skill_id = s.skill_id
    WHERE
        (jl.location = p_location OR p_location IS NULL) AND
        (jl.salary_range BETWEEN p_salary_range_start AND p_salary_range_end OR p_salary_range_start IS NULL OR p_salary_range_end IS NULL) AND
        (jl.contract_type = p_contract_type OR p_contract_type IS NULL) AND
        (jl.required_experience >= p_required_experience OR p_required_experience IS NULL) AND
        (s.skill_name = p_skill_name OR p_skill_name IS NULL) AND
        (jl.status = p_status OR p_status IS NULL);
END;
$$ LANGUAGE plpgsql;

--Example search by Location and Status
SELECT * FROM search_jobs(
    NULL,                 -- No category filter
    'Yerevan',            -- Location
    NULL,                 -- No salary filter
    NULL,                 -- No salary filter
    NULL,                 -- No contract type filter
    NULL,                 -- No required experience filter
    NULL,                 -- No skill filter
    'Open'                -- Status
);

--This function allows a job seeker to bookmark a job by saving the job ID and user ID in the Job_Bookmarks table, ensuring no duplicate bookmarks.

CREATE OR REPLACE FUNCTION bookmark_job (
    p_user_id INT,   -- User ID (job seeker)
    p_job_id INT     -- Job ID to be bookmarked
)
RETURNS VOID AS $$
BEGIN
    -- Check if the job is already bookmarked by the user
    IF NOT EXISTS (SELECT 1 FROM Job_Bookmarks WHERE user_id = p_user_id AND job_id = p_job_id) THEN
        -- Insert a new bookmark entry
        INSERT INTO Job_Bookmarks (user_id, job_id)
        VALUES (p_user_id, p_job_id);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Example: Bookmark job with job_id = 5 for user with user_id = 1
SELECT bookmark_job(1, 5);
