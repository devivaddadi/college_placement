<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="java.sql.SQLException"%>
<%@ page import="com.placement.util.DBConnection"%>

<%
    // Get logged-in student's session
    Integer studentId = (Integer) session.getAttribute("studentId");
    String studentName = (String) session.getAttribute("studentName");

    // If student is not logged in, go to login page
    if (studentId == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    if (studentName == null) {
        studentName = "Student";
    }

    String firstLetter = !studentName.trim().isEmpty() 
            ? studentName.substring(0, 1).toUpperCase() 
            : "S";

    String branch = "";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement("SELECT branch FROM students WHERE student_id = ?")) {
        stmt.setInt(1, studentId);
        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                branch = rs.getString("branch");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    String sql = "SELECT a.application_id, a.applied_date, a.status, "
               + "j.job_id, j.title, j.location, j.salary, "
               + "c.company_name "
               + "FROM applications a "
               + "JOIN jobs j ON a.job_id = j.job_id "
               + "JOIN companies c ON j.company_id = c.company_id "
               + "WHERE a.student_id = ? "
               + "ORDER BY a.applied_date DESC";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Applications | CampusHire</title>
    <link rel="stylesheet" href="../css/style.css">
</head>

<body class="dashboard-body">

<div class="dashboard-layout">

<!-- ================= SIDEBAR ================= -->
<aside class="sidebar">

    <div class="logo">
        Campus<span>Hire</span>
    </div>

    <div class="user-mini">
        <div class="avatar"><%= firstLetter %></div>
        <div>
            <strong><%= studentName %></strong>
            <small><%= branch != null && !branch.isEmpty() ? branch : "Student" %></small>
        </div>
    </div>

    <nav class="side-nav">
        <a href="dashboard.jsp">
            ▦ Dashboard
        </a>
        <a href="profile.jsp">
            ◉ My Profile
        </a>
        <a href="jobs.jsp">
            💼 Job Opportunities
        </a>
        <a href="applications.jsp" class="active">
            ▤ My Applications
        </a>
        <a href="interviews.jsp">
            ◷ Interviews
        </a>
        <a href="notifications.jsp">
            🔔 Notifications
        </a>
    </nav>

    <a href="../LogoutServlet" class="logout">
        ← Logout
    </a>

</aside>

<!-- ================= MAIN CONTENT ================= -->
<main class="main-content">

    <div class="dashboard-header">
        <div>
            <h1>My Applications</h1>
            <p>Track the status of all your campus job applications.</p>
        </div>
        <a href="jobs.jsp" class="btn-primary">+ Browse More Jobs</a>
    </div>

    <!-- ================= APPLICATION TABLE ================= -->
    <div class="table-card">

        <table>
            <thead>
                <tr>
                    <th>Company</th>
                    <th>Position</th>
                    <th>Salary</th>
                    <th>Applied Date</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>

            <tbody>

<%
    boolean hasApplications = false;

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setInt(1, studentId);

        try (ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                hasApplications = true;
                int jobId = rs.getInt("job_id");
                String companyName = rs.getString("company_name");
                String jobTitle = rs.getString("title");
                String salary = rs.getString("salary");
                String status = rs.getString("status");
                java.sql.Timestamp appliedDate = rs.getTimestamp("applied_date");

                String statusClass = "applied";
                if ("Shortlisted".equalsIgnoreCase(status) || "Selected".equalsIgnoreCase(status)) {
                    statusClass = "shortlisted";
                } else if ("Rejected".equalsIgnoreCase(status)) {
                    statusClass = "rejected";
                }
%>

                <tr>
                    <td><strong><%= companyName %></strong></td>
                    <td><%= jobTitle %></td>
                    <td><%= salary %></td>
                    <td><%= appliedDate != null ? appliedDate.toString().substring(0, 16) : "-" %></td>
                    <td>
                        <span class="status <%= statusClass %>">
                            <%= status %>
                        </span>
                    </td>
                    <td>
                        <a href="job-details.jsp?job_id=<%= jobId %>" class="small-btn">
                            View Job
                        </a>
                    </td>
                </tr>

<%
            }
        }

    } catch (SQLException e) {
        e.printStackTrace();
%>
                <tr>
                    <td colspan="6" style="text-align: center; color: red;">
                        Error loading applications.
                    </td>
                </tr>
<%
    }

    if (!hasApplications) {
%>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 40px; color: #64748b;">
                        You have not applied for any jobs yet.
                        <br><br>
                        <a href="jobs.jsp" class="btn-primary">Browse Available Jobs</a>
                    </td>
                </tr>
<%
    }
%>

            </tbody>
        </table>

    </div>

</main>

</div>

</body>
</html>