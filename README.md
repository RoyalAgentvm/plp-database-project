# Student Records Management System

## Project Overview

The Student Records Management System is a comprehensive MySQL database designed to manage all aspects of a university's student information. This system tracks everything from student enrollment and faculty assignments to financial transactions and academic performance.

## Key Features

- **Complete Student Lifecycle Management**: From enrollment to graduation
- **Course and Faculty Management**: Track course offerings, sections, and faculty assignments
- **Financial Transaction Tracking**: Record tuition payments, scholarships, and financial aid
- **Academic Performance Monitoring**: Record grades, attendance, and academic status
- **Comprehensive Relationship Modeling**: Properly designed relationships between entities
- **Automated Data Integrity**: Triggers maintain data consistency for enrollment counts and course statuses
- **Audit Logging**: Track important changes to grades and student statuses

## Entity Relationship Diagram (ERD)


*Note: This ERD shows the major entities and their relationships in the Student Records Management System.*

## Database Structure

### Core Tables

| Table Name | Description |
|------------|-------------|
| `students` | Stores all student personal and academic information |
| `faculty` | Manages professor and staff data |
| `departments` | Organizes the academic structure of the university |
| `courses` | Defines all available courses |
| `course_sections` | Specific offerings of courses for each semester |

### Relationship Tables

| Table Name | Description |
|------------|-------------|
| `enrollments` | Tracks student enrollment in specific course sections |
| `student_advisors` | Maps the advisory relationship between students and faculty |
| `student_minors` | Records students' minor departments |
| `teaching_history` | Documents courses taught by faculty members |

### Supporting Tables

| Table Name | Description |
|------------|-------------|
| `financial_transactions` | Records all student financial activities |
| `scholarships` | Defines available scholarship programs |
| `scholarship_awards` | Tracks scholarships awarded to students |
| `student_documents` | Manages official student documents |
| `attendance` | Records student attendance for course sections |
| `academic_calendar` | Tracks important university dates and events |

### Audit Tables

| Table Name | Description |
|------------|-------------|
| `grade_change_log` | Audit trail for all grade modifications |
| `student_status_log` | Tracks changes to student academic status |

## Setup Instructions

### Prerequisites

- MySQL Server 8.0 or higher
- MySQL Command Line Client or MySQL Workbench

### Installation Steps

1. **Clone or download** this repository to your local machine
2. **Open MySQL Command Line Client** or MySQL Workbench
3. **Execute the SQL script** using one of the following methods:

#### Using MySQL Command Line:

```bash
mysql -u username -p < student_records_system.sql
```

Replace `username` with your MySQL username.

#### Using MySQL Workbench:

1. Open MySQL Workbench
2. Connect to your MySQL server
3. Go to File > Open SQL Script
4. Select the `student_records_system.sql` file
5. Click the Execute button (lightning bolt icon)

### Verification

After running the script, you should see the `student_records_system` database created with all tables. You can verify with:

```sql
USE student_records_system;
SHOW TABLES;
```

## Database Relationships

The database implements the following relationship types:

### One-to-One Relationships
- Each department has one department head (faculty member)

### One-to-Many Relationships
- One department has many faculty members
- One department offers many courses
- One faculty member can teach many course sections
- One student can have many financial transactions

### Many-to-Many Relationships
- Students can enroll in multiple course sections, and each section can have multiple students
- Students can have multiple faculty advisors, and faculty can advise multiple students
- Students can minor in multiple departments

## Database Triggers

The system includes several triggers to maintain data integrity:

1. **Enrollment Counter**: Automatically updates the current enrollment count for course sections
2. **Course Status Manager**: Automatically closes courses when they reach maximum enrollment
3. **Audit Trail Generators**: Records all grade changes and student status changes

## Security Features

- Password fields are designed to store hashed values only (not implemented in this version)
- Separation of personal data from academic and financial data
- Change logs for sensitive data like grades and student status

## Next Steps

- Add sample data to populate the database
- Implement views for common queries
- Create stored procedures for common operations
- Set up user roles and permissions

## License

This project is released under the MIT License - see the LICENSE file for details.

## Author

Created by Roy Muraya - murayaroy64@gmail.com

---

*This database is designed for educational purposes and can be adapted for use in real university environments with appropriate security considerations.*
