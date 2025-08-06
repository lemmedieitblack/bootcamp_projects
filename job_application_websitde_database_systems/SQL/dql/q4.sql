--Q4
--Notifications
--Triggered on key events: application status changes, interview invites.
--This function inserts a notification about an interview invite and sends
--it to the applicant associated with the interview. The function is triggered
--automatically when a new interview invite is inserted.

CREATE OR REPLACE FUNCTION notify_applicant_on_interview_invite()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a notification about the interview invite
    INSERT INTO Notification (message)
    VALUES ('You have been invited for an interview. Please check the interview details.');

    -- Notify the applicant about the interview invite
    INSERT INTO Receives (user_id, notification_id)
    SELECT job_seeker_id, currval('notification_notification_id_seq')  -- Get the ID of the newly inserted notification
    FROM Interview
    WHERE interview_id = NEW.interview_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER interview_invite_trigger
AFTER INSERT ON Interview
FOR EACH ROW
EXECUTE FUNCTION notify_applicant_on_interview_invite();


--This function sends a notification to the applicant when the status of their application changes. The function is triggered automatically when the application status is updated in the Application table.
CREATE OR REPLACE FUNCTION notify_applicant_on_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert a notification about the application status change
    INSERT INTO Notification (message)
    VALUES ('Your application status has been updated. Please check the new status.');

    -- Notify the applicant who applied for the job
    INSERT INTO Receives (user_id, notification_id)
    SELECT job_seeker_id, currval('notification_notification_id_seq')  -- Get the ID of the newly inserted notification
    FROM Application
    WHERE application_id = NEW.application_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER application_status_change_trigger
AFTER UPDATE ON Application
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION notify_applicant_on_status_change();

