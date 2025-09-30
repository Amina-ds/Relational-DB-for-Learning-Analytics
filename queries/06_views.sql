-- ЗАПРОС 6: Создание и использование представления (VIEW)
-- Задача: Создать представление 'student_session_emotions' для анализа каждого занятия.

CREATE OR REPLACE VIEW student_session_emotions AS

-- Шаг 1: Используем CTE для подсчета частоты каждой эмоции в рамках каждого занятия.
WITH ranked_emotions AS (
    SELECT
        class_id,
        dominant_emotion_id,
        ROW_NUMBER() OVER(PARTITION BY class_id ORDER BY COUNT(*) DESC) as rn
    FROM
        emotion_events
    GROUP BY
        class_id, dominant_emotion_id
),
-- Шаг 2: CTE для выбора только самой частой эмоции (ранг = 1) для каждого занятия.
top_emotion AS (
    SELECT
        re.class_id,
        ed.emotion_name AS top_emotion_name
    FROM
        ranked_emotions re
    JOIN
        emotions_dictionary ed ON re.dominant_emotion_id = ed.emotion_id
    WHERE
        re.rn = 1
)
-- Шаг 3: Собираем финальное представление, объединяя общие агрегаты и топ-эмоцию.
SELECT
    co.course_id, -- ИСПРАВЛЕНО: было c.course_id
    co.title AS course_title,
    cl.class_id,
    cl.topic AS class_topic,
    cl.class_date,
    COUNT(ee.event_id) AS total_events,
    ROUND(AVG(ee.valence)::numeric, 2) AS avg_valence,
    ROUND(AVG(ee.arousal)::numeric, 2) AS avg_arousal,
    te.top_emotion_name
FROM
    emotion_events ee
JOIN
    classes cl ON ee.class_id = cl.class_id
JOIN
    courses co ON cl.course_id = co.course_id
JOIN
    top_emotion te ON ee.class_id = te.class_id
GROUP BY
    co.course_id, co.title, cl.class_id, cl.topic, cl.class_date, te.top_emotion_name;

-- ===================================================================================
-- ПРИМЕР ИСПОЛЬЗОВАНИЯ ПРЕДСТАВЛЕНИЯ
-- ===================================================================================
SELECT * FROM student_session_emotions
ORDER BY total_events DESC
LIMIT 10;
