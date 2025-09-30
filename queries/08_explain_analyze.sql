-- ЗАПРОС 8: Анализ планов и индексов

-- Наш "тяжелый" запрос для анализа
SELECT * FROM emotion_events WHERE ts::date = '2025-09-10';


-- План ДО индекса
EXPLAIN ANALYZE
SELECT * FROM emotion_events WHERE ts::date = '2025-09-10';

-- Создание индекса
CREATE INDEX idx_emotion_events_ts ON emotion_events(ts);

-- План ПОСЛЕ индекса
EXPLAIN ANALYZE
SELECT * FROM emotion_events WHERE ts::date = '2025-09-10';


