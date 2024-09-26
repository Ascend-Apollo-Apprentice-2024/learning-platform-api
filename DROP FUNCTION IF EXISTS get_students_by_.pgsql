DROP FUNCTION IF EXISTS get_students_by_cohortId (INTEGER);

CREATE FUNCTION get_students_by_cohortId(user_cohort_id INTEGER)
RETURNS TABLE (
    user_id INTEGER,
    student_name TEXT,
    score INTEGER,
    tag_id INTEGER,
    tag_name TEXT,
    proposal_id INTEGER,
    course_id INTEGER,
    proposal_status TEXT,
    book_id INTEGER,
    book_name TEXT,
    project_name TEXT,
    status_id INTEGER,
    github_handle TEXT,
    cohort_id INTEGER,
    cohort_name TEXT,
    break_start_date TEXT,
    end_date TEXT,
    briggs_myers_type TEXT
) AS $$
BEGIN
    RETURN QUERY
    WITH student_score AS (
        SELECT 
            lr.student_id, 
            SUM(lw.weight) AS score
        FROM "LearningAPI_learningrecord" AS lr
        JOIN "LearningAPI_learningweight" AS lw ON lr.weight_id = lw.id
        WHERE lr.achieved = TRUE
        GROUP BY lr.student_id
    ),
    student_name AS (
        SELECT 
            nsu.user_id, 
            CONCAT(au.first_name, ' ', au.last_name) AS name,
            nsu.github_handle
        FROM "LearningAPI_nssuser" AS nsu
        JOIN "auth_user" AS au ON au.id = nsu.user_id
    ),
    student_tag AS (
        SELECT 
            lst.student_id, 
            lst.tag_id, 
            lt.name
        FROM "LearningAPI_studenttag" AS lst
        JOIN "LearningAPI_tag" AS lt ON lt.id = lst.tag_id
        WHERE lst.tag_id IS NOT NULL
    ),
    student_proposals AS (
        SELECT
            u.id,
            cap.id AS proposal_id,
            co.id AS course_id,
            CASE
                WHEN ps.status = 'MVP' THEN 'mvp'
                WHEN ps.status = 'Approved' THEN 'approved'
                WHEN ps.status = 'In Review' THEN 'reviewed'
                WHEN ps.status IS NULL THEN 'submitted'
            END AS proposal_status
        FROM "LearningAPI_nssuser" AS u
        LEFT JOIN "LearningAPI_capstone" AS cap ON cap.student_id = u.id
        LEFT JOIN "LearningAPI_capstonetimeline" AS tl
        ON cap.id = tl.capstone_id
        AND tl.id = (
            SELECT id
            FROM "LearningAPI_capstonetimeline"
            WHERE cap.id = capstone_id
            ORDER BY "date" DESC
            LIMIT 1
        )
        LEFT JOIN "LearningAPI_proposalstatus" AS ps ON ps.id = tl.status_id
        LEFT JOIN "LearningAPI_course" AS co ON co.id = cap.course_id
        ORDER BY u.id
    ),
    student_books AS (
        SELECT
            spr.student_id AS student_id,
            bk.id AS book_id, 
            bk."name" AS book_name,
            pr."name" AS project_name
        FROM "LearningAPI_book" bk
        JOIN "LearningAPI_project" pr ON pr.book_id = bk.id
        JOIN "LearningAPI_studentproject" spr ON spr.project_id = pr.id
    ),
    student_assessment_status AS (
        SELECT
            sa.student_id,
            sa.status_id,
            sas.status
        FROM "LearningAPI_studentassessment" sa
        JOIN "LearningAPI_studentassessmentstatus" sas ON sas.id = sa.assessment_id
    )
    SELECT 
        nu.user_id::int,
        sn."name"::text AS student_name,
        ss.score::int,
        st.tag_id::int,
        st."name"::text AS tag_name,
        sp.proposal_id::int,
        sp.course_id::int,
        sp.proposal_status::text,
        sb.book_id::int,
        sb.book_name::text,
        sb.project_name::text,
        sas.status_id::int,
        nu.github_handle::text,
        co.id::int AS cohort_id,
        co."name"::text AS cohort_name,
        co.break_start_date::text,
        co.end_date::text,
        stp.briggs_myers_type::text
    FROM "LearningAPI_nssuser" nu
    JOIN "LearningAPI_nssusercohort" nuc ON nu.user_id = nuc.nss_user_id
    JOIN "LearningAPI_cohort" co ON co.id = nuc.cohort_id
    JOIN "LearningAPI_studentpersonality" stp ON stp.student_id = nuc.nss_user_id
    LEFT JOIN student_score AS ss ON ss.student_id = nu.user_id
    LEFT JOIN student_name AS sn ON sn.user_id = nu.user_id
    LEFT JOIN student_tag AS st ON st.student_id = nu.user_id
    LEFT JOIN student_proposals AS sp ON sp.id = nu.user_id
    LEFT JOIN student_books AS sb ON sb.student_id = nu.id
    LEFT JOIN student_assessment_status AS sas ON sas.student_id = nu.id
    WHERE nuc.cohort_id = user_cohort_id
    ORDER BY nu.user_id;
END;
$$ LANGUAGE plpgsql; 

select * FRom get_students_by_cohortId(9)