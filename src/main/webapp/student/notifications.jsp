<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="com.placement.util.DBConnection"%>

<%
    Integer studentId = (Integer) session.getAttribute("studentId");
    String studentName = (String) session.getAttribute("studentName");

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

    String applicationSql = "SELECT a.application_id, a.applied_date, a.status, "
                          + "j.title, c.company_name "
                          + "FROM applications a "
                          + "JOIN jobs j ON a.job_id = j.job_id "
                          + "JOIN companies c ON j.company_id = c.company_id "
                          + "WHERE a.student_id = ? "
                          + "ORDER BY a.applied_date DESC";

    String interviewSql = "SELECT i.interview_date, i.interview_time, "
                        + "i.interview_type, i.status, "
                        + "j.title, c.company_name "
                        + "FROM interviews i "
                        + "JOIN applications a ON i.application_id = a.application_id "
                        + "JOIN jobs j ON a.job_id = j.job_id "
                        + "JOIN companies c ON j.company_id = c.company_id "
                        + "WHERE a.student_id = ? "
                        + "ORDER BY i.interview_date DESC";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Notifications | CampusHire</title>
    <link rel="stylesheet" href="../css/style.css">
</head>

<body class="dashboard-body">

<div class="dashboard-layout">

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
        <a href="applications.jsp">
            ▤ My Applications
        </a>
        <a href="interviews.jsp">
            ◷ Interviews
        </a>
        <a href="notifications.jsp" class="active">
            🔔 Notifications
        </a>
    </nav>

    <a href="../LogoutServlet" class="logout">
        ← Logout
    </a>

</aside>

<main class="main-content">

    <div class="dashboard-header">
        <div>
            <h1>Notifications</h1>
            <p>Live status updates regarding applications and scheduled interviews.</p>
        </div>
    </div>

    <div class="notification-list">

<%
    boolean hasNotifications = false;

    // Interview notifications first
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(interviewSql)) {

        stmt.setInt(1, studentId);

        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                hasNotifications = true;
                String interviewType = rs.getString("interview_type");
                String interviewStatus = rs.getString("status");
                String jobTitle = rs.getString("title");
                String companyName = rs.getString("company_name");
                java.sql.Date interviewDate = rs.getDate("interview_date");
                java.sql.Time interviewTime = rs.getTime("interview_time");

                String formattedTime = "";
                if (interviewTime != null) {
                    java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("hh:mm a");
                    formattedTime = " at " + timeFormat.format(interviewTime);
                }
%>

        <div class="notification unread">
            <div class="notification-icon">◷</div>
            <div>
                <strong>Interview <%= interviewStatus %>: <%= interviewType %></strong>
                <p>
                    Your <%= interviewType %> interview with <strong><%= companyName %></strong> for <strong><%= jobTitle %></strong> is <%= interviewStatus.toLowerCase() %> for <%= interviewDate %><%= formattedTime %>.
                </p>
                <small>Interview Update</small>
            </div>
        </div>

<%
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Application notifications
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(applicationSql)) {

        stmt.setInt(1, studentId);

        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                hasNotifications = true;
                String status = rs.getString("status");
                String jobTitle = rs.getString("title");
                String companyName = rs.getString("company_name");
                java.sql.Timestamp appliedDate = rs.getTimestamp("applied_date");

                if ("Shortlisted".equalsIgnoreCase(status) || "Selected".equalsIgnoreCase(status)) {
%>

        <div class="notification unread">
            <div class="notification-icon">★</div>
            <div>
                <strong style="color: #16a34a;">Congratulations! Status: <%= status %></strong>
                <p>
                    <strong><%= companyName %></strong> has marked your application for <strong><%= jobTitle %></strong> as <strong><%= status %></strong>!
                </p>
                <small><%= appliedDate != null ? appliedDate.toString().substring(0, 16) : "" %></small>
            </div>
        </div>

<%
                } else if ("Rejected".equalsIgnoreCase(status)) {
%>

        <div class="notification">
            <div class="notification-icon">✕</div>
            <div>
                <strong>Application Update: Rejected</strong>
                <p>
                    Your application for <strong><%= jobTitle %></strong> at <strong><%= companyName %></strong> was not selected at this time.
                </p>
                <small><%= appliedDate != null ? appliedDate.toString().substring(0, 16) : "" %></small>
            </div>
        </div>

<%
                } else {
%>

        <div class="notification">
            <div class="notification-icon">✓</div>
            <div>
                <strong>Application Submitted</strong>
                <p>
                    Your application for <strong><%= jobTitle %></strong> at <strong><%= companyName %></strong> has been received and is under review.
                </p>
                <small><%= appliedDate != null ? appliedDate.toString().substring(0, 16) : "" %></small>
            </div>
        </div>

<%
                }
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    if (!hasNotifications) {
%>

        <div class="notification">
            <div class="notification-icon">🔔</div>
            <div>
                <strong>No notifications yet</strong>
                <p>You have no recent placement activity or notifications.</p>
            </div>
        </div>

<%
    }
%>

    </div>

</main>

</div>

</body>
</html>
