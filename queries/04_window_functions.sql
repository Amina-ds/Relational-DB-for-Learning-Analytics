-- ЗАПРОС 4.1: Оконные функции - Скользящее среднее
-- Задача: Для каждого студента рассчитать среднее значение valence
SELECT
    s.full_name,
    ee.ts,
    ee.valence,
    -- Применяем оконную функцию AVG
    AVG(ee.valence) OVER (
        -- PARTITION BY делит все данные на "окна" по каждому студенту.
        -- Расчет для одного студента не будет влиять на другого.
        PARTITION BY ee.student_id
        
        -- ORDER BY упорядочивает события внутри каждого "окна" по времени.
        ORDER BY ee.ts
        
        -- ROWS ... определяет рамку для вычисления: текущая строка и 4 предыдущие.
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) AS moving_average_valence_5
FROM
    emotion_events AS ee
JOIN
    students AS s ON ee.student_id = s.student_id
ORDER BY
    s.full_name, ee.ts;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- ЗАПРОС 4.2: Оконные функции - Ранжирование
-- Задача: Ранжировать все занятия по среднему значению confidence.

-- Используем CTE, чтобы сначала посчитать среднюю уверенность для каждого занятия.
WITH class_avg_confidence AS (
    SELECT
        class_id,
        AVG(confidence) AS avg_confidence
    FROM
        emotion_events
    GROUP BY
        class_id
)
SELECT
    c.title AS course_title,
    cl.topic AS class_topic,
    ROUND(cac.avg_confidence::numeric, 2) AS average_confidence,
    
    -- DENSE_RANK() присваивает ранг. В отличие от RANK(), он не оставляет "дыр" в нумерации.
    -- ORDER BY внутри OVER() определяет, по какому критерию ранжировать.
    DENSE_RANK() OVER (ORDER BY cac.avg_confidence DESC) AS class_rank
FROM
    class_avg_confidence AS cac
JOIN
    classes AS cl ON cac.class_id = cl.class_id
JOIN
    courses AS c ON cl.course_id = c.course_id
ORDER BY
    class_rank;
