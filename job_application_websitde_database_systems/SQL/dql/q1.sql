--Q1
--User registration and profile management queries--
--Job Seeker: Register and Fill Profile
CREATE OR REPLACE FUNCTION register_job_seeker(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_email VARCHAR,
    p_phone_number VARCHAR,
    p_password VARCHAR,
    p_city VARCHAR,
    p_street VARCHAR,
    p_desired_position VARCHAR,
    p_cv_url VARCHAR
) RETURNS VOID AS $$
BEGIN
    INSERT INTO Job_Seeker (
        first_name, last_name, email, phone_number, password,
        address,, desired_position, CV_url
    )
    VALUES (
        p_first_name, p_last_name, p_email, p_phone_number, p_password,
        ROW(p_city, p_street),, p_desired_position, p_cv_url
    );
END;
$$ LANGUAGE plpgsql;


--Job Seeker: Add Skills
CREATE OR REPLACE FUNCTION add_single_skill_with_proficiency(
    p_seeker_id INT,
    p_skill_name VARCHAR(100),
    p_proficiency VARCHAR(20)
) 
RETURNS VOID AS $$
DECLARE
    v_skill_id INT;
    v_existing_skill_id INT;
    v_existing_seeker_skill INT;
BEGIN
    -- Validate proficiency level
    IF p_proficiency NOT IN ('beginner', 'intermediate', 'advanced', 'expert') THEN
        RAISE EXCEPTION 'Invalid proficiency level. Must be: beginner, intermediate, advanced, or expert';
    END IF;

    -- Check if the skill already exists
    SELECT skill_id INTO v_existing_skill_id
    FROM Skills
    WHERE skill_name = p_skill_name;

    -- Insert the skill if it doesn't exist
    IF v_existing_skill_id IS NULL THEN
        INSERT INTO Skills (skill_name)
        VALUES (p_skill_name);

        -- Get the newly inserted skill_id
        SELECT skill_id INTO v_skill_id
        FROM Skills
        WHERE skill_name = p_skill_name;
    ELSE
        v_skill_id := v_existing_skill_id;
    END IF;

    -- Check if the job seeker already has this skill
    SELECT skill_id INTO v_existing_seeker_skill
    FROM JobSeeker_Skills
    WHERE seeker_id = p_seeker_id AND skill_id = v_skill_id;

    -- Insert or update the skill association with proficiency
    IF v_existing_seeker_skill IS NULL THEN
        INSERT INTO JobSeeker_Skills (seeker_id, skill_id, proficiency_level)
        VALUES (p_seeker_id, v_skill_id, p_proficiency);
    ELSE
        UPDATE JobSeeker_Skills
        SET proficiency_level = p_proficiency
        WHERE seeker_id = p_seeker_id AND skill_id = v_skill_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

--Job Seeker: View Profile
CREATE OR REPLACE FUNCTION view_job_seeker_profile(p_user_id INT)
RETURNS TABLE (
    user_id INT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
) AS $$
BEGIN
    RETURN QUERY
    SELECT *

    FROM Job_Seeker
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

--Job Seeker: Update Profile
-- Update first name
CREATE OR REPLACE FUNCTION update_first_name(p_user_id INT, p_first_name VARCHAR(50))
RETURNS VOID AS $$
BEGIN
    UPDATE Users
    SET first_name = p_first_name
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update last name
CREATE OR REPLACE FUNCTION update_last_name(p_user_id INT, p_last_name VARCHAR(50))
RETURNS VOID AS $$
BEGIN
    UPDATE Users
    SET last_name = p_last_name
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update email
CREATE OR REPLACE FUNCTION update_email(p_user_id INT, p_email VARCHAR(100))
RETURNS VOID AS $$
BEGIN
    UPDATE Users
    SET email = p_email
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update phone number
CREATE OR REPLACE FUNCTION update_phone_number(p_user_id INT, p_phone_number VARCHAR(20))
RETURNS VOID AS $$
BEGIN
    UPDATE Users
    SET phone_number = p_phone_number
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update password
CREATE OR REPLACE FUNCTION update_password(p_user_id INT, p_password VARCHAR(255))
RETURNS VOID AS $$
BEGIN
    UPDATE Users
    SET password = p_password
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update city
CREATE OR REPLACE FUNCTION update_city(p_user_id INT, p_city VARCHAR(100))
RETURNS VOID AS $$
BEGIN
    UPDATE Job_Seeker
    SET city = p_city
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update street
CREATE OR REPLACE FUNCTION update_street(p_user_id INT, p_street VARCHAR(100))
RETURNS VOID AS $$
BEGIN
    UPDATE Job_Seeker
    SET street = p_street
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update desired position
CREATE OR REPLACE FUNCTION update_desired_position(p_user_id INT, p_desired_position TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE Job_Seeker
    SET desired_position = p_desired_position
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update CV URL
CREATE OR REPLACE FUNCTION update_cv_url(p_user_id INT, p_cv_url TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE Job_Seeker
    SET CV_url = p_cv_url
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

--Job Seeker: Delete Profile (Cascade Delete)
CREATE OR REPLACE FUNCTION delete_job_seeker_profile(
    p_user_id INT
)
RETURNS VOID AS $$
BEGIN
    DELETE FROM Job_Seeker
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;
--Recruiter: Register and Fill Company Profile
CREATE OR REPLACE FUNCTION register_company(
    p_first_name TEXT,
    p_last_name TEXT,
    p_email TEXT,
    p_phone_number TEXT,
    p_password TEXT,
    p_company_name TEXT,
    p_industry TEXT,
    p_company_size INT,
    p_office_location TEXT,
    p_website TEXT,
    p_description TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Company (
        first_name, last_name, email, phone_number, password, company_name, 
        industry, company_size, office_location, website, description
    )
    VALUES (
        p_first_name, p_last_name, p_email, p_phone_number, p_password, p_company_name, 
        p_industry, p_company_size, p_office_location, p_website, p_description
    );
END;
$$ LANGUAGE plpgsql;


--Recruiter: View Company Info
CREATE OR REPLACE FUNCTION view_company_info(
    p_user_id INT
)
RETURNS TABLE (
    company_id INT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone_number TEXT,
    company_name TEXT,
    industry TEXT,
    company_size INT,
    office_location TEXT,
    website TEXT,
    description TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM Company
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;


--Recruiter: Update Company Info
-- Update company name
CREATE OR REPLACE FUNCTION update_company_name(p_user_id INT, p_company_name VARCHAR(100))
RETURNS VOID AS $$
BEGIN
    UPDATE Company
    SET company_name = p_company_name
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update industry
CREATE OR REPLACE FUNCTION update_industry(p_user_id INT, p_industry VARCHAR(100))
RETURNS VOID AS $$
BEGIN
    UPDATE Company
    SET industry = p_industry
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update company size
CREATE OR REPLACE FUNCTION update_company_size(p_user_id INT, p_company_size INT)
RETURNS VOID AS $$
BEGIN
    UPDATE Company
    SET company_size = p_company_size
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update office location
CREATE OR REPLACE FUNCTION update_office_location(p_user_id INT, p_office_location VARCHAR(100))
RETURNS VOID AS $$
BEGIN
    UPDATE Company
    SET office_location = p_office_location
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update website
CREATE OR REPLACE FUNCTION update_website(p_user_id INT, p_website VARCHAR(255))
RETURNS VOID AS $$
BEGIN
    UPDATE Company
    SET website = p_website
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update description
CREATE OR REPLACE FUNCTION update_description(p_user_id INT, p_description TEXT)
RETURNS VOID AS $$
BEGIN
    UPDATE Company
    SET description = p_description
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update company user first name
CREATE OR REPLACE FUNCTION update_company_first_name(p_user_id INT, p_first_name VARCHAR(50))
RETURNS VOID AS $$
BEGIN
    UPDATE Company
    SET first_name = p_first_name
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update company user last name
CREATE OR REPLACE FUNCTION update_company_last_name(p_user_id INT, p_last_name VARCHAR(50))
RETURNS VOID AS $$
BEGIN
    UPDATE Company
    SET last_name = p_last_name
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update company user email
CREATE OR REPLACE FUNCTION update_company_email(p_user_id INT, p_email VARCHAR(100))
RETURNS VOID AS $$
BEGIN
    UPDATE Company
    SET email = p_email
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update company user phone number
CREATE OR REPLACE FUNCTION update_company_phone_number(p_user_id INT, p_phone_number VARCHAR(20))
RETURNS VOID AS $$
BEGIN
    UPDATE Company
    SET phone_number = p_phone_number
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Update company user password
CREATE OR REPLACE FUNCTION update_company_password(p_user_id INT, p_password VARCHAR(255))
RETURNS VOID AS $$
BEGIN
    UPDATE Company
    SET password = p_password
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

--Admin: Approve, Suspend, or Delete Job Listings
CREATE OR REPLACE FUNCTION check_and_delete_job_seeker(job_seeker_id INT)
RETURNS VOID AS
$$
BEGIN
    -- Check if the job seeker's approval_status is 'rejected'
    IF (SELECT approval_status FROM Job_Seeker WHERE user_id = job_seeker_id) = 'rejected' THEN
        DELETE FROM Job_Seeker WHERE user_id = job_seeker_id;
    END IF;
END;
$$
LANGUAGE plpgsql;

