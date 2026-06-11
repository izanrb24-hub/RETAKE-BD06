USE Faculty;
DROP TRIGGER IF EXISTS trg_subject_one_coordinator_per_course;

DELIMITER //

CREATE TRIGGER trg_subject_one_coordinator_per_course
BEFORE INSERT ON subject
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM subject
        WHERE course = NEW.course
          AND coordinator = NEW.coordinator
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A professor can only coordinate one subject per course';
    END IF;
END //

DELIMITER ;
