USE Faculty;

-- TEST STATEMENTS



-- Exercise 1 test: expected error
-- INSERT INTO subject (course, idSubject, name, semester, credits, type, coordinator)
-- VALUES (1, 'TST01', 'Test duplicated coordinator', '1', 6, 'mandatory', 'PR001');

-- Exercise 2 test: expected error if AL003 already has 10 enrollments
-- INSERT INTO enrollment (idStudent, idSubject, grade)
-- VALUES ('AL003', 'AS011', 5);

-- Exercise 3 test A: expected duplicate error
-- INSERT INTO teach (idProfessor, idSubject)
-- VALUES ('PR007', 'AS001');

-- Exercise 3 test B: expected limit error
-- INSERT INTO teach (idProfessor, idSubject)
-- VALUES ('PR001', 'AS002');

-- Exercise 4 test A: expected error, professor does not exist
-- CALL delete_professor('PR050');

-- Exercise 4 test B: expected error, professor has no supervisor
-- CALL delete_professor('PR001');

-- Exercise 4 test C: expected success
-- CALL delete_professor('PR002');

-- Exercise 5 test A: expected report
-- CALL course_teaching_report('First', @report);
-- SELECT @report;

-- Exercise 5 test B: expected no information
-- CALL course_teaching_report('NOCOURSE', @report);
-- SELECT @report;

-- Exercise 6 test A: expected summary
-- SELECT student_summary('AL034');

-- Exercise 6 test B: expected no subjects enrolled
-- SELECT student_summary('AL999');
