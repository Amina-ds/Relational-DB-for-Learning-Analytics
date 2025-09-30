SELECT
    ee.event_id,
    s.full_name,
    c.topic,
    ee.ts,
    ed.emotion_name,
    ee.confidence
FROM
    emotion_events AS ee
JOIN
    emotions_dictionary AS ed ON ee.dominant_emotion_id = ed.emotion_id
JOIN
    students AS s ON ee.student_id = s.student_id
JOIN
    classes AS c ON ee.class_id = c.class_id
WHERE
    ed.emotion_name = 'happy'
    AND ee.confidence >= 0.8
    AND ee.ts >= (CURRENT_DATE - INTERVAL '7 day');
