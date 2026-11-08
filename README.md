# CampusHire - College Placement Management System

CampusHire is a web-based College Placement Management System developed in Java (Jakarta EE / Servlets & JSP) with MySQL. It streamlines the campus recruitment process by connecting students, placement officers, and recruiting companies in a centralized platform.

---

## 🚀 Features

### 🎓 Student Module
- **Registration & Authentication**: Student registration, login, and secure session management.
- **Profile Management**: Update academic details (CGPA, backlogs, branch, graduation year) and contact information.
- **Job Portal**: Browse available job postings with eligibility criteria (minimum CGPA, allowed backlogs).
- **Application Tracking**: Apply to eligible positions and track application status (Applied, Shortlisted, Rejected).
- **Interviews & Notifications**: View scheduled interviews (date, time, type) and recruitment updates.

### 🏢 Placement Officer Module
- **Officer Dashboard**: Overview of companies, jobs, student applicants, and scheduled interviews.
- **Company Management**: Add, update, and manage participating companies.
- **Job Management**: Post new job openings with role descriptions, CTC/salary, locations, and eligibility constraints.
- **Applicant Review**: Review applicants, filter candidates based on academic criteria, and shortlist or reject candidates.
- **Interview Scheduling**: Schedule interviews (Technical, HR, etc.) with specific date and time slots.

---

## 🛠️ Tech Stack

- **Backend**: Java 17, Jakarta EE (Servlets 5.0, JSP)
- **Database**: MySQL 8.0+
- **Database Connectivity**: JDBC (MySQL Connector/J)
- **Server**: Apache Tomcat 10.0+
- **Frontend**: HTML5, CSS3, JSP, JavaScript
- **IDE**: Eclipse IDE for Enterprise Java and Web Developers

---

## 📁 Project Structure

```text
csp/
├── build/                                # Build output directory
├── src/
│   └── main/
│       ├── java/
│       │   ├── com/csp/controller/       # Servlets handling requests
│       │   └── com/placement/util/       # Database connection utility (DBConnection)
│       └── webapp/
│           ├── admin/                    # Admin JSP views
│           ├── officer/                  # Placement officer JSP views
│           ├── student/                  # Student JSP views
│           ├── css/                      # Stylesheets
│           ├── WEB-INF/                  # web.xml deployment descriptor and libraries
│           │   ├── lib/                  # MySQL Connector JAR
│           │   └── web.xml
│           ├── index.jsp                 # Home page
│           ├── login.jsp                 # Student login page
│           └── register.jsp              # Student registration page
├── .gitignore                            # Git ignore rules
├── placement_db.sql                      # Database schema and initial data
└── README.md                             # Project documentation
```

---

## ⚙️ Database Setup

1. **Start MySQL Server**: Ensure MySQL server is running on your machine.
2. **Import Database Schema**:
   Import `placement_db.sql` into MySQL using MySQL Workbench, phpMyAdmin, or MySQL CLI:
   ```bash
   mysql -u root -p < placement_db.sql
   ```
3. **Configure Database Connection**:
   You can configure database credentials using environment variables:
   - `DB_URL`: JDBC connection URL (Default: `jdbc:mysql://localhost:3306/placement_db?useSSL=false&allowPublicKeyRetrieval=true&characterEncoding=UTF-8&serverTimezone=UTC`)
   - `DB_USER`: MySQL user (Default: `root`)
   - `DB_PASSWORD`: MySQL password (Default: `your_password`)

   Or update `src/main/java/com/placement/util/DBConnection.java` directly with your MySQL credentials.

---

## 🖥️ Running the Project in Eclipse

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/devivaddadi/college_placement.git
   ```
2. **Open Eclipse**:
   - Go to `File` > `Import...` > `Existing Projects into Workspace`.
   - Select the `csp` project folder and click `Finish`.
3. **Configure Server**:
   - Ensure **Apache Tomcat 10.0+** runtime is configured in Eclipse (`Window` > `Preferences` > `Server` > `Runtime Environments`).
   - Right-click the project > `Properties` > `Targeted Runtimes` > check `Apache Tomcat v10.0`.
4. **Deploy & Run**:
   - Right-click the project > `Run As` > `Run on Server`.
   - Select Apache Tomcat 10.0 and finish.
   - Access the application at: `http://localhost:8080/csp/`

---

## 🔑 Demo Credentials

| Role | Email | Password |
|---|---|---|
| **Placement Officer** | `officer@campushire.com` | `officer123` |
| **Student** | `student1@example.com` | `student123` |

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
