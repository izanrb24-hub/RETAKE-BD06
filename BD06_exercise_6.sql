USE Faculty;
DROP FUNCTION IF EXISTS student_summary;

DELIMITER //

CREATE FUNCTION student_summary(p_idStudent CHAR(5))
RETURNS VARCHAR(200)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_subjects INT DEFAULT 0;
    DECLARE total_courses INT DEFAULT 0;

    SELECT COUNT(*),
           COUNT(DISTINCT s.course)
    INTO total_subjects, total_courses
    FROM enrollment e
    JOIN subject s ON e.idSubject = s.idSubject
    WHERE e.idStudent = p_idStudent;

    IF total_subjects = 0 THEN
        RETURN 'No subjects enrolled';
    END IF;

    RETURN CONCAT(total_subjects, ' subject(s) in ', total_courses, ' course(s)');
END //

DELIMITER ;
