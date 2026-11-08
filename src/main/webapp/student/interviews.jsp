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

    String sql = "SELECT i.interview_id, i.interview_date, i.interview_time, "
               + "i.interview_type, i.status, "
               + "j.job_id, j.title, "
               + "c.company_name "
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
    <title>My Interviews | CampusHire</title>
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
        <a href="applications.jsp">
            ▤ My Applications
        </a>
        <a href="interviews.jsp" class="active">
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
            <h1>My Interviews</h1>
            <p>Upcoming and completed placement interviews.</p>
        </div>
    </div>

<%
    boolean hasInterviews = false;

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setInt(1, studentId);

        try (ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                hasInterviews = true;

                java.sql.Date interviewDate = rs.getDate("interview_date");
                java.sql.Time interviewTime = rs.getTime("interview_time");
                String interviewType = rs.getString("interview_type");
                String status = rs.getString("status");
                String jobTitle = rs.getString("title");
                String companyName = rs.getString("company_name");

                // Date formatting
                java.text.SimpleDateFormat dayFormat = new java.text.SimpleDateFormat("dd");
                java.text.SimpleDateFormat monthFormat = new java.text.SimpleDateFormat("MMM");

                String day = interviewDate != null ? dayFormat.format(interviewDate) : "--";
                String month = interviewDate != null ? monthFormat.format(interviewDate).toUpperCase() : "TBD";

                // Format time
                String formattedTime = "Time not specified";
                if (interviewTime != null) {
                    java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("hh:mm a");
                    formattedTime = timeFormat.format(interviewTime);
                }

                // Status CSS class
                String statusClass = "applied";
                if ("Scheduled".equalsIgnoreCase(status)) {
                    statusClass = "shortlisted";
                } else if ("Cancelled".equalsIgnoreCase(status)) {
                    statusClass = "rejected";
                } else if ("Completed".equalsIgnoreCase(status)) {
                    statusClass = "applied";
                }
%>

    <!-- INTERVIEW CARD -->
    <div class="interview-card upcoming" style="background: white; border: 1px solid #e5e7eb; border-radius: 10px; padding: 22px; display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px;">

        <div style="display: flex; align-items: center; gap: 20px;">
            <div class="interview-date" style="background: #eff6ff; color: #2563eb; width: 60px; height: 60px; border-radius: 10px; display: flex; flex-direction: column; align-items: center; justify-content: center; font-weight: 700;">
                <strong style="font-size: 20px; line-height: 1;"><%= day %></strong>
                <span style="font-size: 11px;"><%= month %></span>
            </div>

            <div class="interview-info">
                <h2 style="font-size: 18px; margin-bottom: 4px;"><%= interviewType %></h2>
                <p style="font-size: 15px; color: #475569; margin-bottom: 4px;"><strong><%= companyName %></strong></p>
                <span style="color: #64748b; font-size: 13px;">
                    🕐 <%= formattedTime %> &nbsp; • &nbsp; <%= jobTitle %>
                </span>
            </div>
        </div>

        <span class="status <%= statusClass %>">
            <%= status %>
        </span>

    </div>

<%
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
    <div style="background: white; border: 1px solid #fee2e2; border-radius: 10px; padding: 25px; color: #b91c1c;">
        Error loading interview schedule. Please try again.
    </div>
<%
    }

    if (!hasInterviews) {
%>
    <div style="background: white; border: 1px solid #e5e7eb; border-radius: 10px; padding: 40px; text-align: center; color: #64748b;">
        <h2 style="margin-bottom: 8px;">No interviews scheduled yet</h2>
        <p>Once you are shortlisted for a drive, your interview schedule will appear here.</p>
        <br>
        <a href="jobs.jsp" class="btn-primary">Browse Job Openings</a>
    </div>
<%
    }
%>

</main>

</div>

</body>
</html>