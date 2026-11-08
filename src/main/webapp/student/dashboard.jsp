<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.placement.util.DBConnection" %>

<%
    // Ensure student is logged in first!
    Integer studentId = (Integer) session.getAttribute("studentId");
    String studentName = (String) session.getAttribute("studentName");
    String studentEmail = (String) session.getAttribute("studentEmail");

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

    // Fetch student profile details (CGPA, backlogs)
    double studentCgpa = 0.0;
    int studentBacklogs = 0;
    String branch = "";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement("SELECT cgpa, backlogs, branch FROM students WHERE student_id = ?")) {
        stmt.setInt(1, studentId);
        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                studentCgpa = rs.getDouble("cgpa");
                studentBacklogs = rs.getInt("backlogs");
                branch = rs.getString("branch");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    // Dynamic stats
    int totalAvailableJobs = 0;
    int applicationCount = 0;
    int interviewCount = 0;
    int shortlistedCount = 0;

    try (Connection conn = DBConnection.getConnection()) {
        // Total available jobs
        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM jobs");
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                totalAvailableJobs = rs.getInt(1);
            }
        }

        // Total applications by student
        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM applications WHERE student_id = ?")) {
            stmt.setInt(1, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    applicationCount = rs.getInt(1);
                }
            }
        }

        // Total interviews for student
        String interviewSql = "SELECT COUNT(*) FROM interviews i "
                            + "JOIN applications a ON i.application_id = a.application_id "
                            + "WHERE a.student_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(interviewSql)) {
            stmt.setInt(1, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    interviewCount = rs.getInt(1);
                }
            }
        }

        // Shortlisted or Selected count
        String shortlistedSql = "SELECT COUNT(*) FROM applications "
                              + "WHERE student_id = ? AND status IN ('Shortlisted', 'Selected')";
        try (PreparedStatement stmt = conn.prepareStatement(shortlistedSql)) {
            stmt.setInt(1, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    shortlistedCount = rs.getInt(1);
                }
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student Dashboard | CampusHire</title>
    <link rel="stylesheet" href="../css/style.css">
</head>

<body class="dashboard-body">

<div class="dashboard-layout">

<aside class="sidebar">

    <div class="logo">Campus<span>Hire</span></div>

    <div class="user-mini">
        <div class="avatar"><%= firstLetter %></div>
        <div>
            <strong><%= studentName %></strong>
            <small><%= branch != null && !branch.isEmpty() ? branch : "Student" %></small>
        </div>
    </div>

    <nav class="side-nav">
        <a href="dashboard.jsp" class="active">
            <span>▦</span> Dashboard
        </a>
        <a href="profile.jsp">
            <span>◉</span> My Profile
        </a>
        <a href="jobs.jsp">
            <span>💼</span> Job Opportunities
        </a>
        <a href="applications.jsp">
            <span>▤</span> My Applications
        </a>
        <a href="interviews.jsp">
            <span>◷</span> Interviews
        </a>
        <a href="notifications.jsp">
            <span>🔔</span> Notifications
        </a>
    </nav>

    <a href="../LogoutServlet" class="logout">
        ← Logout
    </a>

</aside>

<main class="main-content">

    <div class="dashboard-header">
        <div>
            <h1>Good morning, <%= studentName %> 👋</h1>
            <p>Here's what's happening with your campus placements.</p>
        </div>

        <div class="header-profile">
            <a href="notifications.jsp" title="Notifications" style="font-size: 20px;">🔔</a>
            <a href="profile.jsp"><div class="avatar small"><%= firstLetter %></div></a>
        </div>
    </div>

    <!-- STATS -->
    <div class="stats-grid">

        <div class="stat-card">
            <span class="stat-icon blue">💼</span>
            <div>
                <small>Available Jobs</small>
                <h2><%= totalAvailableJobs %></h2>
            </div>
        </div>

        <div class="stat-card">
            <span class="stat-icon green">✓</span>
            <div>
                <small>My Applications</small>
                <h2><%= applicationCount %></h2>
            </div>
        </div>

        <div class="stat-card">
            <span class="stat-icon orange">◷</span>
            <div>
                <small>Interviews</small>
                <h2><%= interviewCount %></h2>
            </div>
        </div>

        <div class="stat-card">
            <span class="stat-icon purple">★</span>
            <div>
                <small>Shortlisted / Selected</small>
                <h2><%= shortlistedCount %></h2>
            </div>
        </div>

    </div>

    <!-- RECOMMENDED JOBS -->
    <div class="content-section">

        <div class="section-header">
            <div>
                <h2>Recommended Jobs</h2>
                <p>Opportunities matching your profile</p>
            </div>
            <a href="jobs.jsp">View All Jobs →</a>
        </div>

        <div class="job-list">

<%
    String recJobsSql = "SELECT j.job_id, j.title, j.salary, j.location, j.job_type, "
                      + "j.min_cgpa, j.max_backlogs, c.company_name "
                      + "FROM jobs j "
                      + "JOIN companies c ON j.company_id = c.company_id "
                      + "ORDER BY j.job_id DESC LIMIT 3";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(recJobsSql);
         ResultSet rs = stmt.executeQuery()) {

        boolean hasRecJobs = false;

        while (rs.next()) {
            hasRecJobs = true;
            int jobId = rs.getInt("job_id");
            String title = rs.getString("title");
            String compName = rs.getString("company_name");
            String location = rs.getString("location");
            String salary = rs.getString("salary");
            String jobType = rs.getString("job_type");
            double minCgpa = rs.getDouble("min_cgpa");
            int maxBacklogs = rs.getInt("max_backlogs");

            boolean eligible = (studentCgpa >= minCgpa) && (studentBacklogs <= maxBacklogs);
            String initial = compName != null && !compName.isEmpty() ? compName.substring(0, 1).toUpperCase() : "C";
%>

            <div class="job-item">
                <div class="company-logo"><%= initial %></div>
                <div class="job-info">
                    <h3><%= title %></h3>
                    <p><%= compName %></p>
                    <span>
                        <%= location %> • <%= salary %> • <%= jobType %>
                    </span>
                </div>

                <% if (eligible) { %>
                    <div class="job-status eligible">✓ Eligible</div>
                <% } else { %>
                    <div class="job-status not-eligible">Not Eligible</div>
                <% } %>

                <a href="job-details.jsp?job_id=<%= jobId %>" class="small-btn">
                    View Job
                </a>
            </div>

<%
        }

        if (!hasRecJobs) {
%>
            <div style="padding: 20px; text-align: center; color: #64748b;">
                No jobs currently posted. Please check back later.
            </div>
<%
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
        <div style="padding: 20px; color: red;">Error loading job opportunities.</div>
<%
    }
%>

        </div>

    </div>

    <!-- RECENT APPLICATIONS -->
    <div class="content-section">

        <div class="section-header">
            <div>
                <h2>Recent Applications</h2>
                <p>Track your latest application statuses</p>
            </div>
            <a href="applications.jsp">View All Applications →</a>
        </div>

        <div class="table-card">
            <table>
                <thead>
                    <tr>
                        <th>Company</th>
                        <th>Position</th>
                        <th>Applied On</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody>

<%
    String recentAppSql = "SELECT a.application_id, a.applied_date, a.status, "
                        + "j.job_id, j.title, c.company_name "
                        + "FROM applications a "
                        + "JOIN jobs j ON a.job_id = j.job_id "
                        + "JOIN companies c ON j.company_id = c.company_id "
                        + "WHERE a.student_id = ? "
                        + "ORDER BY a.applied_date DESC LIMIT 5";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(recentAppSql)) {

        stmt.setInt(1, studentId);
        try (ResultSet rs = stmt.executeQuery()) {
            boolean hasApps = false;

            while (rs.next()) {
                hasApps = true;
                int jobId = rs.getInt("job_id");
                String compName = rs.getString("company_name");
                String jobTitle = rs.getString("title");
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
                        <td><strong><%= compName %></strong></td>
                        <td><%= jobTitle %></td>
                        <td><%= appliedDate != null ? appliedDate.toString().substring(0, 16) : "-" %></td>
                        <td>
                            <span class="status <%= statusClass %>"><%= status %></span>
                        </td>
                        <td>
                            <a href="job-details.jsp?job_id=<%= jobId %>" class="small-btn">View</a>
                        </td>
                    </tr>

<%
            }

            if (!hasApps) {
%>
                    <tr>
                        <td colspan="5" style="text-align: center; padding: 25px; color: #64748b;">
                            You have not submitted any applications yet. <a href="jobs.jsp" style="color: #2563eb; text-decoration: underline;">Explore Jobs</a>
                        </td>
                    </tr>
<%
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
                    <tr>
                        <td colspan="5" style="text-align:center; color: red;">Error loading applications.</td>
                    </tr>
<%
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
