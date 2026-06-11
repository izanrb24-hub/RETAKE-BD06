USE Faculty;
DROP TRIGGER IF EXISTS trg_student_max_10_enrollments;

DELIMITER //

CREATE TRIGGER trg_student_max_10_enrollments
BEFORE INSERT ON enrollment
FOR EACH ROW
BEGIN
    IF (
        SELECT COUNT(*)
        FROM enrollment
        WHERE idStudent = NEW.idStudent
    ) >= 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A student cannot be enrolled in more than 10 subjects at the same time';
    END IF;
END //

DELIMITER ;
