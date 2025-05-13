-- Student Records Management System Database
-- A comprehensive database for managing university student data

-- Drop database if it exists to avoid conflicts
DROP DATABASE IF EXISTS student_records_system;

-- Create database
CREATE DATABASE student_records_system;

-- Use the database
USE student_records_system;

-- ============================================================
-- CORE ENTITY TABLES
-- ============================================================

-- Departments table
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    building VARCHAR(50),
    budget DECIMAL(12,2),
    head_faculty_id INT NULL, -- Will be updated after faculty table creation
    creation_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Faculty members
CREATE TABLE faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    department_id INT NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_faculty_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE RESTRICT
);

-- Add foreign key for department head after faculty table exists
ALTER TABLE departments
ADD CONSTRAINT fk_department_head 
FOREIGN KEY (head_faculty_id) REFERENCES faculty(faculty_id) ON DELETE SET NULL;

-- Students
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Non-binary', 'Prefer not to say') NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address_line1 VARCHAR(100) NOT NULL,
    address_line2 VARCHAR(100),
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'USA',
    enrollment_date DATE NOT NULL,
    expected_graduation DATE,
    major_department_id INT,
    academic_status ENUM('Active', 'Probation', 'Suspended', 'Graduated', 'Withdrawn') DEFAULT 'Active',
    CONSTRAINT fk_student_major FOREIGN KEY (major_department_id) 
        REFERENCES departments(department_id) ON DELETE SET NULL
);

-- Courses table
CREATE TABLE courses (
    course_id VARCHAR(10) PRIMARY KEY, -- e.g., CS101, MATH201
    title VARCHAR(100) NOT NULL,
    description TEXT,
    department_id INT NOT NULL,
    credit_hours INT NOT NULL,
    course_level ENUM('Undergraduate', 'Graduate') NOT NULL,
    prerequisites TEXT,
    CONSTRAINT fk_course_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE RESTRICT
);

-- Course sections (specific offerings of courses)
CREATE TABLE course_sections (
    section_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id VARCHAR(10) NOT NULL,
    section_number VARCHAR(5) NOT NULL, -- e.g., '001', 'A', etc.
    semester ENUM('Fall', 'Spring', 'Summer') NOT NULL,
    academic_year YEAR NOT NULL,
    faculty_id INT,
    room VARCHAR(20),
    schedule VARCHAR(100), -- e.g., 'MWF 10:00-10:50'
    max_enrollment INT NOT NULL DEFAULT 30,
    current_enrollment INT NOT NULL DEFAULT 0,
    status ENUM('Open', 'Closed', 'Cancelled') DEFAULT 'Open',
    CONSTRAINT fk_section_course FOREIGN KEY (course_id) 
        REFERENCES courses(course_id) ON DELETE CASCADE,
    CONSTRAINT fk_section_faculty FOREIGN KEY (faculty_id) 
        REFERENCES faculty(faculty_id) ON DELETE SET NULL,
    CONSTRAINT unique_section UNIQUE (course_id, section_number, semester, academic_year)
);

-- ============================================================
-- RELATIONSHIP TABLES (MANY-TO-MANY)
-- ============================================================

-- Student enrollment in course sections
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    section_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    grade VARCHAR(2), -- NULL until grade is assigned
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_enrollment_section FOREIGN KEY (section_id) 
        REFERENCES course_sections(section_id) ON DELETE CASCADE,
    CONSTRAINT unique_enrollment UNIQUE (student_id, section_id)
);

-- Student advisors (Many-to-Many: students can have multiple advisors)
CREATE TABLE student_advisors (
    student_id INT NOT NULL,
    faculty_id INT NOT NULL,
    start_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    end_date DATE,
    is_primary BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (student_id, faculty_id),
    CONSTRAINT fk_advisor_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_advisor_faculty FOREIGN KEY (faculty_id) 
        REFERENCES faculty(faculty_id) ON DELETE CASCADE
);

-- Secondary/minor departments for students
CREATE TABLE student_minors (
    student_id INT NOT NULL,
    department_id INT NOT NULL,
    declaration_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (student_id, department_id),
    CONSTRAINT fk_minor_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_minor_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE CASCADE
);

-- Faculty teaching history
CREATE TABLE teaching_history (
    faculty_id INT NOT NULL,
    course_id VARCHAR(10) NOT NULL,
    semester ENUM('Fall', 'Spring', 'Summer') NOT NULL,
    academic_year YEAR NOT NULL,
    evaluation_score DECIMAL(3,2),
    PRIMARY KEY (faculty_id, course_id, semester, academic_year),
    CONSTRAINT fk_teaching_faculty FOREIGN KEY (faculty_id) 
        REFERENCES faculty(faculty_id) ON DELETE CASCADE,
    CONSTRAINT fk_teaching_course FOREIGN KEY (course_id) 
        REFERENCES courses(course_id) ON DELETE CASCADE
);

-- ============================================================
-- SUPPORTING TABLES
-- ============================================================

-- Financial transactions/tuition payments
CREATE TABLE financial_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    transaction_type ENUM('Tuition Payment', 'Financial Aid', 'Scholarship', 'Fee', 'Refund') NOT NULL,
    payment_method ENUM('Credit Card', 'Bank Transfer', 'Cash', 'Check', 'Internal') NOT NULL,
    description VARCHAR(255),
    semester ENUM('Fall', 'Spring', 'Summer'),
    academic_year YEAR,
    is_verified BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_transaction_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id) ON DELETE CASCADE
);

-- Scholarships and financial aid
CREATE TABLE scholarships (
    scholarship_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    amount DECIMAL(10,2) NOT NULL,
    is_recurring BOOLEAN DEFAULT FALSE,
    department_id INT, -- NULL if university-wide
    criteria TEXT,
    CONSTRAINT fk_scholarship_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE SET NULL
);

-- Student scholarship awards
CREATE TABLE scholarship_awards (
    award_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    scholarship_id INT NOT NULL,
    academic_year YEAR NOT NULL,
    semester ENUM('Fall', 'Spring', 'Summer', 'Full Year') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    award_date DATE NOT NULL,
    status ENUM('Pending', 'Awarded', 'Rejected', 'Cancelled') DEFAULT 'Pending',
    CONSTRAINT fk_award_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_award_scholarship FOREIGN KEY (scholarship_id) 
        REFERENCES scholarships(scholarship_id) ON DELETE CASCADE,
    CONSTRAINT unique_award UNIQUE (student_id, scholarship_id, academic_year, semester)
);

-- Student documents (transcripts, letters, etc.)
CREATE TABLE student_documents (
    document_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    document_type ENUM('Transcript', 'Letter of Recommendation', 'ID Card', 'Visa Document', 'Other') NOT NULL,
    issue_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    expiry_date DATE,
    document_status ENUM('Pending', 'Issued', 'Revoked', 'Expired') DEFAULT 'Pending',
    issued_by INT, -- Faculty ID if applicable
    notes TEXT,
    CONSTRAINT fk_document_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_document_issuer FOREIGN KEY (issued_by) 
        REFERENCES faculty(faculty_id) ON DELETE SET NULL
);

-- Student attendance
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    section_id INT NOT NULL,
    student_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Excused', 'Late') NOT NULL DEFAULT 'Present',
    notes VARCHAR(255),
    CONSTRAINT fk_attendance_section FOREIGN KEY (section_id) 
        REFERENCES course_sections(section_id) ON DELETE CASCADE,
    CONSTRAINT fk_attendance_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT unique_attendance UNIQUE (section_id, student_id, attendance_date)
);

-- Academic calendar
CREATE TABLE academic_calendar (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    event_type ENUM('Class Start', 'Class End', 'Registration', 'Holiday', 'Exam Period', 'Graduation', 'Other') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    academic_year YEAR NOT NULL,
    semester ENUM('Fall', 'Spring', 'Summer', 'All') NOT NULL,
    description TEXT,
    CONSTRAINT check_dates CHECK (end_date >= start_date)
);

-- ============================================================
-- AUDIT AND LOGGING TABLES
-- ============================================================

-- Grade change log for auditing purposes
CREATE TABLE grade_change_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    previous_grade VARCHAR(2),
    new_grade VARCHAR(2) NOT NULL,
    changed_by INT NOT NULL, -- faculty_id
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason VARCHAR(255) NOT NULL,
    CONSTRAINT fk_grade_change_enrollment FOREIGN KEY (enrollment_id) 
        REFERENCES enrollments(enrollment_id) ON DELETE CASCADE,
    CONSTRAINT fk_grade_change_faculty FOREIGN KEY (changed_by) 
        REFERENCES faculty(faculty_id) ON DELETE NO ACTION
);

-- Student status change log
CREATE TABLE student_status_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    previous_status ENUM('Active', 'Probation', 'Suspended', 'Graduated', 'Withdrawn'),
    new_status ENUM('Active', 'Probation', 'Suspended', 'Graduated', 'Withdrawn') NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by INT, -- faculty_id or NULL if system-generated
    reason TEXT,
    CONSTRAINT fk_status_change_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_status_change_faculty FOREIGN KEY (changed_by) 
        REFERENCES faculty(faculty_id) ON DELETE SET NULL
);

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Trigger to update current_enrollment count when a student enrolls
DELIMITER //
CREATE TRIGGER after_enrollment_insert
AFTER INSERT ON enrollments
FOR EACH ROW
BEGIN
    IF NEW.is_active = TRUE THEN
        UPDATE course_sections
        SET current_enrollment = current_enrollment + 1
        WHERE section_id = NEW.section_id;
    END IF;
END//
DELIMITER ;

-- Trigger to update current_enrollment count when a student drops a course
DELIMITER //
CREATE TRIGGER after_enrollment_update
AFTER UPDATE ON enrollments
FOR EACH ROW
BEGIN
    IF NEW.is_active = FALSE AND OLD.is_active = TRUE THEN
        UPDATE course_sections
        SET current_enrollment = current_enrollment - 1
        WHERE section_id = NEW.section_id;
    ELSEIF NEW.is_active = TRUE AND OLD.is_active = FALSE THEN
        UPDATE course_sections
        SET current_enrollment = current_enrollment + 1
        WHERE section_id = NEW.section_id;
    END IF;
END//
DELIMITER ;

-- Trigger to update current_enrollment count when a student enrollment is deleted
DELIMITER //
CREATE TRIGGER after_enrollment_delete
AFTER DELETE ON enrollments
FOR EACH ROW
BEGIN
    IF OLD.is_active = TRUE THEN
        UPDATE course_sections
        SET current_enrollment = current_enrollment - 1
        WHERE section_id = OLD.section_id;
    END IF;
END//
DELIMITER ;

-- Trigger to update course section status when it reaches max enrollment
DELIMITER //
CREATE TRIGGER after_section_enrollment_update
AFTER UPDATE ON course_sections
FOR EACH ROW
BEGIN
    IF NEW.current_enrollment >= NEW.max_enrollment AND NEW.status = 'Open' THEN
        -- Course is now full
        UPDATE course_sections
        SET status = 'Closed'
        WHERE section_id = NEW.section_id;
    ELSEIF NEW.current_enrollment < NEW.max_enrollment AND NEW.status = 'Closed' THEN
        -- Course has space available again
        UPDATE course_sections
        SET status = 'Open'
        WHERE section_id = NEW.section_id;
    END IF;
END//
DELIMITER ;

-- Trigger to log student status changes
DELIMITER //
CREATE TRIGGER before_student_status_update
BEFORE UPDATE ON students
FOR EACH ROW
BEGIN
    IF OLD.academic_status != NEW.academic_status THEN
        INSERT INTO student_status_log (
            student_id, 
            previous_status, 
            new_status, 
            changed_by,
            reason
        ) VALUES (
            NEW.student_id, 
            OLD.academic_status, 
            NEW.academic_status, 
            NULL, -- This would ideally come from a session variable in a real application
            'Status updated via system'
        );
    END IF;
END//
DELIMITER ;

-- Trigger to log grade changes
DELIMITER //
CREATE TRIGGER before_grade_update
BEFORE UPDATE ON enrollments
FOR EACH ROW
BEGIN
    IF (OLD.grade IS NULL AND NEW.grade IS NOT NULL) OR 
       (OLD.grade IS NOT NULL AND NEW.grade IS NOT NULL AND OLD.grade != NEW.grade) THEN
        INSERT INTO grade_change_log (
            enrollment_id,
            previous_grade,
            new_grade,
            changed_by,
            reason
        ) VALUES (
            NEW.enrollment_id,
            OLD.grade,
            NEW.grade,
            NULL, -- This would ideally come from a session variable in a real application
            'Grade updated via system'
        );
    END IF;
END//
DELIMITER ;