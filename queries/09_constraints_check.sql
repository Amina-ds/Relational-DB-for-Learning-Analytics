-- Демонстрация нарушения ссылочной целостности
INSERT INTO emotion_events (class_id, student_id, ts, source, dominant_emotion_id, valence, arousal, confidence)
VALUES (1, 9999, NOW(), 'video', 1, 0.5, 0.5, 0.9); -- ОШИБКА: student_id = 9999 не существует
