USE Faculty;
DROP TRIGGER IF EXISTS trg_professor_teach_limit;

DELIMITER //

CREATE TRIGGER trg_professor_teach_limit
BEFORE INSERT ON teach
FOR EACH ROW
BEGIN
    DECLARE subject_semester VARCHAR(1);

    -- 1. Avoid duplicate assignment
    IF EXISTS (
        SELECT 1
        FROM teach
        WHERE idProfessor = NEW.idProfessor
          AND idSubject = NEW.idSubject
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This professor is already assigned to teach this subject';
    END IF;

    -- Get the semester of the new subject
    SELECT semester
    INTO subject_semester
    FROM subject
    WHERE idSubject = NEW.idSubject;

    -- 2. Check the maximum of 3 subjects in the same semester
    IF (
        SELECT COUNT(DISTINCT t.idSubject)
        FROM teach t
        JOIN subject s ON t.idSubject = s.idSubject
        WHERE t.idProfessor = NEW.idProfessor
          AND s.semester = subject_semester
    ) >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A professor cannot teach more than 3 subjects in the same semester';
    END IF;
END //

DELIMITER ;
