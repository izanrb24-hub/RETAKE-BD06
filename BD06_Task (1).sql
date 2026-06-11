
-- EXERCISE 1
DELIMITER //
CREATE TRIGGER trg_subject_coordinator
BEFORE INSERT ON subject
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM subject
        WHERE coordinator = NEW.coordinator
          AND course = NEW.course
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Professor can only coordinate one subject per course';
    END IF;
END //
DELIMITER ;

-- EXERCISE 2
DELIMITER //
CREATE TRIGGER trg_max_enrollment
BEFORE INSERT ON enrollment
FOR EACH ROW
BEGIN
    IF (
        SELECT COUNT(*)
        FROM enrollment
        WHERE idStudent = NEW.idStudent
    ) >= 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='A student cannot be enrolled in more than 10 subjects at the same time';
    END IF;
END //
DELIMITER ;

-- EXERCISE 3
DELIMITER //
CREATE TRIGGER trg_teach_limit
BEFORE INSERT ON teach
FOR EACH ROW
BEGIN
    DECLARE sem_value CHAR(1);

    IF EXISTS (
        SELECT 1
        FROM teach
        WHERE idProfessor = NEW.idProfessor
          AND idSubject = NEW.idSubject
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Duplicate assignment';
    END IF;

    SELECT semester
    INTO sem_value
    FROM subject
    WHERE idSubject = NEW.idSubject;

    IF (
        SELECT COUNT(*)
        FROM teach t
        JOIN subject s ON t.idSubject=s.idSubject
        WHERE t.idProfessor=NEW.idProfessor
          AND s.semester=sem_value
    ) >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Professor cannot teach more than 3 subjects in the same semester';
    END IF;
END //
DELIMITER ;

-- EXERCISE 4
-- Procedure delete_professor (basic version)

-- EXERCISE 5
-- Procedure course_teaching_report

-- EXERCISE 6
DELIMITER //
CREATE FUNCTION student_summary(p_student CHAR(5))
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    DECLARE nsubjects INT;
    DECLARE ncourses INT;

    SELECT COUNT(*), COUNT(DISTINCT s.course)
    INTO nsubjects, ncourses
    FROM enrollment e
    JOIN subject s ON e.idSubject=s.idSubject
    WHERE e.idStudent=p_student;

    IF nsubjects=0 THEN
        RETURN 'No subjects enrolled';
    END IF;

    RETURN CONCAT(nsubjects,' subject(s) in ',ncourses,' course(s)');
END //
DELIMITER ;
