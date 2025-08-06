--Q6
--Data consistency and maintenance
--When deleting an account, the system cascades deletion to related applications, bookmarks, CVs, and work history
CREATE OR REPLACE FUNCTION notify_applicants_on_job_update()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Notification (message)
    VALUES (CONCAT('The job posting "', NEW.title, '" has been updated.'));

    INSERT INTO Receives (user_id, notification_id)
    SELECT a.job_seeker_id, currval('notification_notification_id_seq') 
    FROM Application a
    WHERE a.job_id = NEW.job_id;

    RETURN NULL; 
END;
$$ LANGUAGE plpgsql;

--creating the trigger
CREATE TRIGGER trigger_notify_applicants
AFTER UPDATE ON Job_Listings
FOR EACH ROW
WHEN (OLD.* IS DISTINCT FROM NEW.*)
EXECUTE FUNCTION notify_applicants_on_job_update();
