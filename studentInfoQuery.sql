-- Active: 1725496082556@@127.0.0.1@5432@learnopsdev
SELECT * FROM get_students_by_cohortId (15)

DROP FUNCTION IF EXISTS get_students_by_cohortId (INTEGER);

CREATE FUNCTION get_students_by_cohortId(user_cohort_id INTEGER)
RETURNS TABLE (
    user_id INTEGER,
    student_name TEXT,
    score INTEGER,
    tags TEXT,
    proposals TEXT,
    book_id INTEGER,
    book_name TEXT,
    project_name TEXT,
    book_index TEXT,
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
        json_agg(
            json_build_object(
                'tag_id', lst.tag_id,
                'tag_name', lt.name
            )
        )::text AS tags
    FROM "LearningAPI_studenttag" AS lst
    JOIN "LearningAPI_tag" AS lt ON lt.id = lst.tag_id
    WHERE lst.tag_id IS NOT NULL
    GROUP BY lst.student_id
),
student_proposals AS (
    SELECT
        u.id,
        COALESCE(
            json_agg(
                json_build_object(
                    'proposal_id', cap.id,
                    'course_id', co.id,
                    'proposal_status', 
                    CASE
                        WHEN ps.status = 'MVP' THEN 'mvp'
                        WHEN ps.status = 'Approved' THEN 'approved'
                        WHEN ps.status = 'In Review' THEN 'reviewed'
                        WHEN ps.status IS NULL THEN 'submitted'
                    END
                )
            )
        , '[]')::text AS proposals
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
    GROUP BY u.id
    ORDER BY u.id
),
student_books AS (
    SELECT
        spr.student_id AS student_id,
        bk.id AS book_id, 
        bk."name" AS book_name,
        pr."name" AS project_name,
        bk.index as book_index
    FROM "LearningAPI_book" bk
    JOIN "LearningAPI_project" pr ON pr.book_id = bk.id
    JOIN "LearningAPI_studentproject" spr ON spr.project_id = pr.id
    AND spr.id = (
        SELECT id
        FROM "LearningAPI_studentproject"
        WHERE student_id = spr.student_id
        ORDER BY "id" DESC
        LIMIT 1
    )
),
student_assessment_status AS (
    SELECT
        sa.student_id,
        sa.status_id
    FROM "LearningAPI_studentassessment" sa

    WHERE sa."id" = (
        SELECT MAX(id)
        FROM "LearningAPI_studentassessment"
        WHERE student_id = sa.student_id
    )
)
SELECT 
    nu.user_id::int,
    sn."name"::text AS student_name,
    ss.score::int,
    COALESCE(st.tags, '[]'::text) as tags,
    sp.proposals::text,
    sb.book_id::int,
    sb.book_name::text,
    sb.project_name::text,
    sb.book_index::text,
    sa.status_id::int,
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
JOIN student_assessment_status AS sa ON sa.student_id = nu.id
WHERE nuc.cohort_id = user_cohort_id 
ORDER BY nu.user_id;
END;
$$ LANGUAGE plpgsql;
