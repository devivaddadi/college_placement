<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="com.placement.util.DBConnection"%>

<%
    int totalStudents = 0;
    int totalCompanies = 0;
    int totalJobs = 0;
    int studentsPlaced = 0;

    try (Connection conn = DBConnection.getConnection()) {
        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM students");
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) totalStudents = rs.getInt(1);
        }

        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM companies");
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) totalCompanies = rs.getInt(1);
        }

        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM jobs");
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) totalJobs = rs.getInt(1);
        }

        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(DISTINCT student_id) FROM applications WHERE status = 'Selected'");
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) studentsPlaced = rs.getInt(1);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard | CampusHire</title>
    <link rel="stylesheet" href="../css/style.css">
</head>

<body class="dashboard-body">

<div class="dashboard-layout">

<aside class="sidebar">

    <div class="logo">Campus<span>Hire</span></div>

    <div class="user-mini">
        <div class="avatar">A</div>
        <div>
            <strong>Administrator</strong>
            <small>Admin Portal</small>
        </div>
    </div>

    <nav class="side-nav">
        <a href="dashboard.jsp" class="active">
            ▦ Dashboard
        </a>
        <a href="students.jsp">
            👥 Students
        </a>
        <a href="companies.jsp">
            🏢 Companies
        </a>
        <a href="../officer/dashboard.jsp">
            👔 Officer View
        </a>
    </nav>

    <a href="${pageContext.request.contextPath}/LogoutServlet" class="logout">
        ← Logout
    </a>

</aside>

<main class="main-content">

    <div class="dashboard-header">
        <div>
            <h1>Admin Dashboard</h1>
            <p>Overall monitoring and analytics of the college placement management system.</p>
        </div>
    </div>

    <div class="stats-grid">

        <div class="stat-card">
            <span class="stat-icon blue">👥</span>
            <div>
                <small>Total Students</small>
                <h2><%= totalStudents %></h2>
            </div>
        </div>

        <div class="stat-card">
            <span class="stat-icon green">🏢</span>
            <div>
                <small>Registered Companies</small>
                <h2><%= totalCompanies %></h2>
            </div>
        </div>

        <div class="stat-card">
            <span class="stat-icon orange">💼</span>
            <div>
                <small>Active Job Drives</small>
                <h2><%= totalJobs %></h2>
            </div>
        </div>

        <div class="stat-card">
            <span class="stat-icon purple">★</span>
            <div>
                <small>Students Placed</small>
                <h2><%= studentsPlaced %></h2>
            </div>
        </div>

    </div>

    <div class="content-section">

        <div class="section-header">
            <div>
                <h2>Placement Overview</h2>
                <p>Real-time campus placement performance</p>
            </div>
        </div>

        <div class="overview-box" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; background: white; border: 1px solid #e5e7eb; border-radius: 12px; padding: 30px; text-align: center;">

            <div>
                <strong style="display:block; font-size: 32px; color: #2563eb;"><%= studentsPlaced %></strong>
                <span style="color: #64748b;">Students Selected</span>
            </div>

            <div>
                <strong style="display:block; font-size: 32px; color: #16a34a;"><%= totalCompanies %></strong>
                <span style="color: #64748b;">Companies Visited</span>
            </div>

            <div>
                <strong style="display:block; font-size: 32px; color: #ea580c;"><%= totalJobs %></strong>
                <span style="color: #64748b;">Job Drives Posted</span>
            </div>

            <div>
                <strong style="display:block; font-size: 32px; color: #9333ea;"><%= totalStudents > 0 ? (studentsPlaced * 100 / totalStudents) : 0 %>%</strong>
                <span style="color: #64748b;">Placement Rate</span>
            </div>

        </div>

    </div>

    <!-- RECENT REGISTERED STUDENTS -->
    <div class="content-section" style="margin-top: 30px;">
        <div class="section-header">
            <div>
                <h2>Recently Registered Students</h2>
                <p>Newest student registrations on the platform</p>
            </div>
            <a href="students.jsp">View All Students →</a>
        </div>

        <div class="table-card">
            <table>
                <thead>
                    <tr>
                        <th>Student ID</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Branch</th>
                        <th>CGPA</th>
                        <th>Graduation Year</th>
                    </tr>
                </thead>
                <tbody>
<%
    String recentStudentsSql = "SELECT student_id, name, email, branch, cgpa, graduation_year "
                             + "FROM students ORDER BY student_id DESC LIMIT 5";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(recentStudentsSql);
         ResultSet rs = stmt.executeQuery()) {

        boolean hasStudents = false;
        while (rs.next()) {
            hasStudents = true;
%>
                    <tr>
                        <td>#<%= rs.getInt("student_id") %></td>
                        <td><strong><%= rs.getString("name") %></strong></td>
                        <td><%= rs.getString("email") %></td>
                        <td><%= rs.getString("branch") %></td>
                        <td><%= rs.getDouble("cgpa") %></td>
                        <td><%= rs.getInt("graduation_year") %></td>
                    </tr>
<%
        }
        if (!hasStudents) {
%>
                    <tr>
                        <td colspan="6" style="text-align:center; padding: 20px;">No students registered yet.</td>
                    </tr>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
                </tbody>
            </table>
        </div>
    </div>

</main>

</div>

</body>
</html>