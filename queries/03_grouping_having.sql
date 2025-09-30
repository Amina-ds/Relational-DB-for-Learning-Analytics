-- ЗАПРОС 3: Группировки и HAVING
-- Задача: Найти ТОП-3 эмоции по частоте на курсе "Введение в SQL" (ID=4)

SELECT
    ed.emotion_name,
    COUNT(ee.event_id) AS emotion_count,
    -- Расчет процента для наглядности. Основная логика фильтрации - в HAVING.
    ROUND((COUNT(ee.event_id) * 100.0 / 
           (SELECT COUNT(*) 
            FROM emotion_events ee2
            JOIN classes cl2 ON ee2.class_id = cl2.class_id
            WHERE cl2.course_id = 4 AND ee2.ts BETWEEN '2025-09-04' AND '2025-09-11')), 2) AS percentage
FROM
    emotion_events AS ee
JOIN
    classes AS cl ON ee.class_id = cl.class_id
JOIN
    emotions_dictionary AS ed ON ee.dominant_emotion_id = ed.emotion_id
WHERE
    -- Шаг 1: Предварительная фильтрация данных по курсу и дате
    cl.course_id = 4
    AND ee.ts BETWEEN '2025-09-04' AND '2025-09-11'
GROUP BY
    -- Шаг 2: Группировка событий по названию эмоции
    ed.emotion_name
HAVING
    -- Шаг 3: Фильтрация самих групп на основе агрегированного значения (доли)
    -- Оставляем только те группы (эмоции), где доля событий > 20%
    (COUNT(ee.event_id) * 100.0 / 
     (SELECT COUNT(*) 
      FROM emotion_events ee2
      JOIN classes cl2 ON ee2.class_id = cl2.class_id
      WHERE cl2.course_id = 4 AND ee2.ts BETWEEN '2025-09-04' AND '2025-09-11')) > 20.0
ORDER BY
    -- Шаг 4: Сортировка результата для определения ТОП
    emotion_count DESC
LIMIT 3; -- Шаг 5: Ограничение вывода до 3-х записей
