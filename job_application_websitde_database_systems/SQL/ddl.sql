CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    password VARCHAR(255)
);

CREATE TABLE Admin (
    user_id INT PRIMARY KEY REFERENCES Users(user_id)
) INHERITS (Users);

CREATE TABLE Job_Seeker (
    user_id INT PRIMARY KEY REFERENCES Users(user_id),
    city VARCHAR(100),
    street VARCHAR(100),
    desired_position VARCHAR(100),
    CV_url VARCHAR(255),
    approval_status VARCHAR(20) DEFAULT 'pending',
    admin_id INT REFERENCES Admin(user_id)
) INHERITS (Users);

CREATE TABLE Skills (
    skill_id SERIAL PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL
);

CREATE TABLE JobSeeker_Skills (
    seeker_id INT,
    skill_id INT,
    proficiency_level VARCHAR(20),
    PRIMARY KEY (seeker_id, skill_id),
    FOREIGN KEY (seeker_id) REFERENCES Job_Seeker(user_id),
    FOREIGN KEY (skill_id) REFERENCES Skills(skill_id)
);

CREATE TABLE Company (
    user_id INT PRIMARY KEY REFERENCES Users(user_id),
    company_name VARCHAR(100),
    industry VARCHAR(100),
    company_size INT,
    office_location VARCHAR(100),
    website VARCHAR(255),
    description TEXT
) INHERITS (Users);


CREATE TYPE job_status AS ENUM ('Open', 'Closed', 'Paused', 'Filled');

CREATE TABLE Job_Listings (
    job_id SERIAL PRIMARY KEY,
    company_id INT NOT NULL,
    admin_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    posting_date DATE DEFAULT CURRENT_DATE,
    expiration_date DATE,
    required_experience INT,
    salary_range VARCHAR(100),
    contract_type VARCHAR(100),
    status job_status DEFAULT 'Open',
    approval_status VARCHAR(20) DEFAULT 'pending',
    FOREIGN KEY (company_id) REFERENCES Company(user_id),
    FOREIGN KEY (admin_id) REFERENCES Admin(user_id)
);

CREATE TYPE application_status AS ENUM ('pending', 'hired', 'rejected');

CREATE TABLE Application (
    application_id SERIAL PRIMARY KEY,
    job_id INT,
    job_seeker_id INT,
    status application_status,
    submission_date DATE,
    FOREIGN KEY (job_id) REFERENCES Job_Listings(job_id),
    FOREIGN KEY (job_seeker_id) REFERENCES Job_Seeker(user_id)
);

CREATE TYPE mode AS ENUM ('Online', 'Offline');

CREATE TABLE Interview (
    interview_id SERIAL PRIMARY KEY,
    application_id INT,
    job_seeker_id INT,
    company_id INT,
    interview_date DATE,
    interview_time TIME,
    interview_mode mode,
    feedback TEXT,
    FOREIGN KEY (application_id) REFERENCES Application(application_id),
    FOREIGN KEY (job_seeker_id) REFERENCES Job_Seeker(user_id),
    FOREIGN KEY (company_id) REFERENCES Company(user_id)
);

CREATE TABLE Work_History (
    job_seeker_id INT NOT NULL,
    work_id INT NOT NULL,
    company_name VARCHAR(255),
    job_title VARCHAR(255),
    start_date DATE,
    end_date DATE,
    experience_years INT,  -- normal column
    PRIMARY KEY (job_seeker_id, work_id),
    FOREIGN KEY (job_seeker_id) REFERENCES Job_Seeker(user_id)
);

SELECT 
    job_seeker_id,
    work_id,
    company_name,
    job_title,
    start_date,
    end_date,
    EXTRACT(YEAR FROM AGE(COALESCE(end_date, CURRENT_DATE), start_date)) AS experience_years
FROM Work_History;

CREATE TABLE Notification (
    notification_id SERIAL PRIMARY KEY,
    message TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    job_seeker_id INT,
    FOREIGN KEY (job_seeker_id) REFERENCES Job_Seeker(user_id)
);

 CREATE TABLE Job_Bookmarks (
    bookmark_id SERIAL PRIMARY KEY, 
    user_id INT NOT NULL,  
    job_id INT NOT NULL,  
    bookmark_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  
    FOREIGN KEY (user_id) REFERENCES Job_Seeker (user_id) ON DELETE CASCADE, --Ensures that user deletion removes bookmarks
    FOREIGN KEY (job_id) REFERENCES Job_Listings(job_id) ON DELETE CASCADE  -- Ensures that job deletion removes bookmarks
);


