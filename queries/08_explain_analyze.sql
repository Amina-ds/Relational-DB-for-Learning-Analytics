-- ЗАПРОС 8: Анализ планов и индексов

-- План ДО индекса
EXPLAIN ANALYZE
SELECT * FROM emotion_events 
WHERE ts >= '2025-09-10' AND ts < '2025-09-11';

-- Создание индекса
CREATE INDEX idx_emotion_events_ts ON emotion_events(ts);

-- План ПОСЛЕ индекса
EXPLAIN ANALYZE
SELECT * FROM emotion_events 
WHERE ts >= '2025-09-10' AND ts < '2025-09-11';
