WITH student_score as (
SELECT 
    lr.student_id, 
    SUM(lw.weight) AS score
FROM "LearningAPI_learningrecord" AS lr
JOIN "LearningAPI_learningweight" as lw ON lr.weight_id = lw.id
WHERE lr.achieved = TRUE
GROUP BY lr.student_id
),

student_name as (
SELECT 
    nsu.user_id, 
    CONCAT(au.first_name, ' ', au.last_name) as name
FROM "LearningAPI_nssuser" as nsu
JOIN "auth_user" as au ON au.id = nsu.user_id
),
student_tag as (
SELECT 
    lst.student_id, 
    lst.tag_id, 
    lt.name
from "LearningAPI_studenttag" AS lst
JOIN "LearningAPI_tag" as lt ON lt.id = lst.tag_id
WHERE lst.tag_id IS NOT NULL
),
student_proposals as (
    SELECT
        u.id,
        cap.id as proposal_id,
        co.id as course_id,
        CASE
            WHEN ps.status = 'MVP' THEN 'mvp'
            WHEN ps.status = 'Approved' THEN 'approved'
            WHEN ps.status = 'In Review' THEN 'reviewed'
            WHEN ps.status IS NULL THEN 'submitted'
        END AS proposal_status
    FROM "LearningAPI_nssuser" as u
    LEFT JOIN "LearningAPI_capstone" as cap ON cap.student_id = u.id
    LEFT JOIN "LearningAPI_capstonetimeline" as tl
    on cap.id = tl.capstone_id
    and tl.id = (
        SELECT id
        FROM "LearningAPI_capstonetimeline"
        WHERE cap.id = capstone_id
        ORDER BY "date" DESC
        LIMIT 1
    )
    LEFT JOIN "LearningAPI_proposalstatus" as ps on ps.id = tl.status_id
    LEFT JOIN "LearningAPI_course" as co on co.id = cap.course_id
    Order by u.id
),
student_books as (
    SELECT
        spr.student_id as student_id,
        bk.id as book_id, 
        bk."name" as book_name,
        pr."name" as project_name
    FROM "LearningAPI_book" bk
    JOIN "LearningAPI_project" pr on pr.book_id = bk.id
    JOIN "LearningAPI_studentproject" spr on spr.project_id = pr.id
)
Select 
    nu.user_id,
    sn."name",
    ss.score,
    st.tag_id,
    st."name",
    sp.proposal_id,
    sp.course_id,
    sp.proposal_status,
    sb.book_id,
    sb.book_name,
    sb.project_name
FROM "LearningAPI_nssuser" nu
JOIN "LearningAPI_nssusercohort" nuc on nu.user_id = nuc.nss_user_id
LEFT JOIN student_score as ss on ss.student_id = nu.user_id
LEFT JOIN student_name as sn on sn.user_id = nu.user_id
LEFT JOIN student_tag as st on st.student_id = nu.user_id
LEFT JOIN student_proposals as sp on sp.id = nu.user_id
LEFT JOIN student_books as sb on sb.student_id = nu.id
WHERE nuc.cohort_id = 9;


-- book --> project --> student_project _ student (nss_user)