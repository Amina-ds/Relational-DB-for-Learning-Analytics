-- ЗАПРОС 7: Изменение данных + Транзакция
-- =================================================================================
-- Шаг 1: Подготовка. Создаём таблицы для хранения сводных данных и логов.
-- IF NOT EXISTS позволяет безопасно выполнять скрипт несколько раз.
-- =================================================================================

CREATE TABLE IF NOT EXISTS class_emotion_rollup (
    class_id INT PRIMARY KEY,
    total_events INT NOT NULL,
    avg_valence NUMERIC(4, 3) NOT NULL,
    last_updated TIMESTAMPTZ NOT NULL,
    CONSTRAINT fk_rollup_class_id FOREIGN KEY(class_id) REFERENCES classes(class_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS audit_log (
    log_id SERIAL PRIMARY KEY,
    event_description TEXT NOT NULL,
    event_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =================================================================================
-- Шаг 2: Демонстрация успешной транзакции (COMMIT)
-- Обновляем статистику для class_id = 1 и логируем это действие.
-- =================================================================================

-- Начинаем транзакцию
BEGIN;

-- Операция 1: Обновляем или вставляем (UPSERT) сводные данные
INSERT INTO class_emotion_rollup (class_id, total_events, avg_valence, last_updated)
SELECT
    class_id,
    COUNT(*) AS total_events,
    AVG(valence) AS avg_valence,
    NOW() AS last_updated
FROM
    emotion_events
WHERE
    class_id = 1
GROUP BY
    class_id
ON CONFLICT (class_id) DO UPDATE SET
    total_events = EXCLUDED.total_events,
    avg_valence = EXCLUDED.avg_valence,
    last_updated = EXCLUDED.last_updated;

-- Операция 2: Вставляем запись в лог об успешном обновлении
INSERT INTO audit_log (event_description)
VALUES ('Successfully updated rollup for class_id = 1');

-- Завершаем транзакцию и сохраняем все изменения
COMMIT;


-- =================================================================================
-- Шаг 3: Демонстрация отката транзакции (ROLLBACK)
-- Обновляем статистику для class_id = 2, но затем имитируем ошибку.
-- Вся транзакция (включая первое обновление) будет отменена.
-- =================================================================================

-- Начинаем вторую транзакцию
BEGIN;

-- Операция 1 (успешная): Обновляем данные для class_id = 2
INSERT INTO class_emotion_rollup (class_id, total_events, avg_valence, last_updated)
SELECT
    class_id,
    COUNT(*) AS total_events,
    AVG(valence) AS avg_valence,
    NOW() AS last_updated
FROM
    emotion_events
WHERE
    class_id = 2
GROUP BY
    class_id
ON CONFLICT (class_id) DO UPDATE SET
    total_events = EXCLUDED.total_events,
    avg_valence = EXCLUDED.avg_valence,
    last_updated = EXCLUDED.last_updated;

-- Операция 2 (неуспешная): Имитируем критическую ошибку
SELECT 1 / 0; -- Эта строка вызовет ошибку "division by zero"

-- СУБД не дойдет до COMMIT. Из-за ошибки произойдет автоматический ROLLBACK,
-- и все изменения внутри этого блока BEGIN/COMMIT будут отменены.
COMMIT;
