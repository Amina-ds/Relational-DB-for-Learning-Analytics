-- =================================================================================
-- Таблица 1: Справочник эмоций
-- =================================================================================
CREATE TABLE emotions_dictionary (
    emotion_id SERIAL PRIMARY KEY,
    emotion_name VARCHAR(50) NOT NULL UNIQUE
);
COMMENT ON TABLE emotions_dictionary IS 'Справочник доминантных эмоций';

-- =================================================================================
-- Таблица 2: Курсы
-- =================================================================================
CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL UNIQUE,
    instructor VARCHAR(150) NOT NULL,
    ects SMALLINT NOT NULL,
    
    CONSTRAINT chk_courses_ects CHECK (ects > 0)
);
COMMENT ON TABLE courses IS 'Учебные курсы';
COMMENT ON COLUMN courses.ects IS 'European Credit Transfer and Accumulation System';

-- =================================================================================
-- Таблица 3: Студенты
-- =================================================================================
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    birthdate DATE NOT NULL,
    gender VARCHAR(10),
    group_code VARCHAR(20),
    
    CONSTRAINT chk_students_birthdate CHECK (birthdate < CURRENT_DATE),
    CONSTRAINT chk_students_gender CHECK (gender IN ('male', 'female', 'other'))
);
COMMENT ON TABLE students IS 'Информация о студентах';

-- =================================================================================
-- Таблица 4: Занятия (сессии по курсам)
-- =================================================================================
CREATE TABLE classes (
    class_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL,
    class_date TIMESTAMPTZ NOT NULL, -- TIMESTAMPTZ для учета часовых поясов
    topic TEXT,
    modality VARCHAR(10) NOT NULL,
    
    CONSTRAINT fk_classes_course_id FOREIGN KEY(course_id) REFERENCES courses(course_id) ON DELETE RESTRICT,
    CONSTRAINT chk_classes_modality CHECK (modality IN ('online', 'offline'))
);
COMMENT ON TABLE classes IS 'Конкретные занятия в рамках курсов';

-- =================================================================================
-- Таблица 5: Записи на курс (связь "многие ко многим")
-- =================================================================================
CREATE TABLE enrollments (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enroll_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'enrolled',
    
    CONSTRAINT pk_enrollments PRIMARY KEY (student_id, course_id),
    CONSTRAINT fk_enrollments_student_id FOREIGN KEY(student_id) REFERENCES students(student_id) ON DELETE CASCADE, -- Если удаляем студента, удаляем и его записи на курсы
    CONSTRAINT fk_enrollments_course_id FOREIGN KEY(course_id) REFERENCES courses(course_id) ON DELETE CASCADE, -- Если удаляем курс, удаляем и записи на него
    CONSTRAINT chk_enrollments_status CHECK (status IN ('enrolled', 'completed', 'dropped'))
);
COMMENT ON TABLE enrollments IS 'Запись студентов на курсы';

-- =================================================================================
-- Таблица 6: Эмоциональные события
-- =================================================================================
CREATE TABLE emotion_events (
    event_id BIGSERIAL PRIMARY KEY, -
    class_id INT NOT NULL,
    student_id INT NOT NULL,
    ts TIMESTAMPTZ NOT NULL,
    source VARCHAR(10) NOT NULL,
    dominant_emotion_id INT NOT NULL,
    valence NUMERIC(4, 3) NOT NULL,
    arousal NUMERIC(4, 3) NOT NULL,
    confidence NUMERIC(3, 2) NOT NULL,
    
    CONSTRAINT fk_emotions_class_id FOREIGN KEY(class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    CONSTRAINT fk_emotions_student_id FOREIGN KEY(student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_emotions_emotion_id FOREIGN KEY(dominant_emotion_id) REFERENCES emotions_dictionary(emotion_id) ON DELETE RESTRICT,
    CONSTRAINT chk_emotions_source CHECK (source IN ('video', 'audio', 'text')),
    CONSTRAINT chk_emotions_valence CHECK (valence BETWEEN -1 AND 1),
    CONSTRAINT chk_emotions_arousal CHECK (arousal BETWEEN -1 AND 1),
    CONSTRAINT chk_emotions_confidence CHECK (confidence BETWEEN 0 AND 1)
);
COMMENT ON TABLE emotion_events IS 'События, связанные с эмоциями студентов на занятиях';
COMMENT ON COLUMN emotion_events.valence IS 'Оценка эмоциональной окраски (-1: негативная, +1: позитивная)';
COMMENT ON COLUMN emotion_events.arousal IS 'Оценка уровня возбуждения (-1: спокойное, +1: возбужденное)';
COMMENT ON COLUMN emotion_events.confidence IS 'Уверенность модели в оценке эмоции (от 0 до 1)';
