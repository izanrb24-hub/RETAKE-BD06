USE Faculty;

DROP PROCEDURE IF EXISTS delete_professor;

DELIMITER //

CREATE PROCEDURE delete_professor(IN p_idProfessor CHAR(5))
BEGIN
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_supervisor CHAR(5);
    DECLARE v_professor_name VARCHAR(200);
    DECLARE v_supervisor_name VARCHAR(200);
    DECLARE v_subjects_count INT DEFAULT 0;
    DECLARE v_teach_count INT DEFAULT 0;
    DECLARE v_supervised_count INT DEFAULT 0;
    DECLARE v_phone_count INT DEFAULT 0;
    DECLARE v_result LONGTEXT DEFAULT '';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT COUNT(*)
    INTO v_exists
    FROM professor
    WHERE idProfessor = p_idProfessor;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Professor ID does not exist';
    END IF;

    SELECT SupervisorId,
           CONCAT(name, ' ', surname1, ' ', IFNULL(surname2, ''))
    INTO v_supervisor, v_professor_name
    FROM professor
    WHERE idProfessor = p_idProfessor;

    IF v_supervisor IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The professor has no supervisor and cannot be deleted';
    END IF;

    SELECT CONCAT(name, ' ', surname1, ' ', IFNULL(surname2, ''))
    INTO v_supervisor_name
    FROM professor
    WHERE idProfessor = v_supervisor;

    START TRANSACTION;

    SELECT COUNT(*)
    INTO v_subjects_count
    FROM subject
    WHERE coordinator = p_idProfessor;

    SELECT COUNT(*)
    INTO v_teach_count
    FROM teach
    WHERE idProfessor = p_idProfessor;

    SELECT COUNT(*)
    INTO v_supervised_count
    FROM professor
    WHERE SupervisorId = p_idProfessor;

    SELECT COUNT(*)
    INTO v_phone_count
    FROM profContactPhone
    WHERE idProfessor = p_idProfessor;

    -- Reassign coordinated subjects to the supervisor
    UPDATE subject
    SET coordinator = v_supervisor
    WHERE coordinator = p_idProfessor;

    -- Avoid duplicated teaching assignments before reassigning
    DELETE t_deleted
    FROM teach t_deleted
    JOIN teach t_supervisor
      ON t_deleted.idSubject = t_supervisor.idSubject
     AND t_supervisor.idProfessor = v_supervisor
    WHERE t_deleted.idProfessor = p_idProfessor;

    -- Reassign remaining teaching assignments to the supervisor
    UPDATE teach
    SET idProfessor = v_supervisor
    WHERE idProfessor = p_idProfessor;

    -- Reassign professors supervised by the deleted professor
    UPDATE professor
    SET SupervisorId = v_supervisor
    WHERE SupervisorId = p_idProfessor;

    -- Delete phone numbers
    DELETE FROM profContactPhone
    WHERE idProfessor = p_idProfessor;

    -- Delete professor
    DELETE FROM professor
    WHERE idProfessor = p_idProfessor;

    COMMIT;

    SET v_result = CONCAT(
        'Subjects coordinated by ', v_professor_name, ' (', p_idProfessor, ') are now coordinated by ', v_supervisor_name, ' (', v_supervisor, ').', CHAR(10),
        'Teaching assignments of ', v_professor_name, ' (', p_idProfessor, ') are now assigned to ', v_supervisor_name, ' (', v_supervisor, ').', CHAR(10),
        'Supervised professors of ', v_professor_name, ' (', p_idProfessor, ') are now supervised by ', v_supervisor_name, ' (', v_supervisor, ').', CHAR(10),
        'Phone numbers of ', v_professor_name, ' (', p_idProfessor, ') deleted.', CHAR(10),
        '--> ', v_professor_name, ' (', p_idProfessor, ') deleted successfully.'
    );

    SELECT v_result AS result;
END //

DELIMITER ;
