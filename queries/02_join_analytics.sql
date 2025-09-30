SELECT
    c.title AS course_title,
    AVG(ee.valence) AS average_valence,
    AVG(ee.arousal) AS average_arousal
FROM
    courses AS c
JOIN
    classes AS cl ON c.course_id = cl.course_id
JOIN
    emotion_events AS ee ON cl.class_id = ee.class_id
GROUP BY
    c.course_id, c.title
ORDER BY
    course_title;
