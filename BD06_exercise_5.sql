USE Faculty;
DROP PROCEDURE IF EXISTS course_teaching_report;

DELIMITER //

CREATE PROCEDURE course_teaching_report(
    IN p_course_name VARCHAR(50),
    OUT report_text LONGTEXT
)
BEGIN
    SELECT GROUP_CONCAT(
        CONCAT(
            '** Subject: ', s.name,
            ' | Coordinator: ', p_coord.name, ' ', p_coord.surname1, ' ', IFNULL(p_coord.surname2, ''),
            ' | Teachers: ', COALESCE(t.teacher_names, 'No teachers assigned'),
            ' | Semester: ', s.semester,
            ' | CourseId: ', s.course,
            ' | CourseName: ', c.descriptiveName,
            ' | Total Enrolled: ', COALESCE(e.total_enrolled, 0)
        )
        ORDER BY s.idSubject
        SEPARATOR '\n'
    )
    INTO report_text
    FROM course c
    JOIN subject s ON c.idCourse = s.course
    JOIN professor p_coord ON s.coordinator = p_coord.idProfessor
    LEFT JOIN (
        SELECT te.idSubject,
               GROUP_CONCAT(
                   CONCAT(p.name, ' ', p.surname1, ' ', IFNULL(p.surname2, ''))
                   ORDER BY p.surname1, p.name
                   SEPARATOR ', '
               ) AS teacher_names
        FROM teach te
        JOIN professor p ON te.idProfessor = p.idProfessor
        GROUP BY te.idSubject
    ) t ON s.idSubject = t.idSubject
    LEFT JOIN (
        SELECT idSubject,
               COUNT(*) AS total_enrolled
        FROM enrollment
        GROUP BY idSubject
    ) e ON s.idSubject = e.idSubject
    WHERE c.descriptiveName = p_course_name;

    IF report_text IS NULL THEN
        SET report_text = CONCAT('No information available for course "', p_course_name, '".');
    END IF;
END //

DELIMITER ;
