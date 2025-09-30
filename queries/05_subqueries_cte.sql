-- ЗАПРОС 5: Подзапросы / CTE
-- Задача: Найти студентов, чья доля событий с отрицательным valence
-- выше, чем средняя доля таких событий по курсу, на который они записаны.

WITH
-- Шаг 1: Для каждого студента считаем его личную долю "негативных" событий.
student_negative_share AS (
    SELECT
        student_id,
        -- Используем FILTER для элегантного подсчета событий, удовлетворяющих условию.
        -- Это более современный и читаемый способ, чем CASE.
        COUNT(*) FILTER (WHERE valence < 0) AS negative_events,
        COUNT(*) AS total_events,
        -- Рассчитываем долю. Умножение на 1.0 нужно для преобразования в тип с плавающей точкой.
        (COUNT(*) FILTER (WHERE valence < 0) * 1.0 / COUNT(*)) AS negative_share
    FROM
        emotion_events
    GROUP BY
        student_id
    -- Отсеиваем студентов без событий, чтобы избежать деления на ноль.
    HAVING COUNT(*) > 0
),

-- Шаг 2: Для каждого курса считаем СРЕДНЮЮ долю негативных событий по всем его студентам.
course_avg_share AS (
    SELECT
        e.course_id,
        AVG(sns.negative_share) AS avg_course_negative_share
    FROM
        student_negative_share AS sns
    JOIN
        enrollments AS e ON sns.student_id = e.student_id
    GROUP BY
        e.course_id
)

-- Шаг 3: Соединяем всё вместе и находим "отстающих" студентов.
SELECT
    s.full_name,
    c.title AS course_title,
    ROUND((sns.negative_share * 100)::numeric, 2) AS student_negative_percentage,
    ROUND((cas.avg_course_negative_share * 100)::numeric, 2) AS course_avg_negative_percentage
FROM
    student_negative_share AS sns
JOIN
    students AS s ON sns.student_id = s.student_id
JOIN
    enrollments AS e ON sns.student_id = e.student_id
JOIN
    courses AS c ON e.course_id = c.course_id
JOIN
    course_avg_share AS cas ON e.course_id = cas.course_id
WHERE
    -- Главное условие: личная доля студента > средней доли по курсу.
    sns.negative_share > cas.avg_course_negative_share
ORDER BY
    course_title, student_negative_percentage DESC;
