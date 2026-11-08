<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="com.placement.util.DBConnection"%>

<%
    Integer officerId = (Integer) session.getAttribute("officerId");
    String officerName = (String) session.getAttribute("officerName");

    if (officerId == null) {
        response.sendRedirect("officer-login.jsp");
        return;
    }

    if (officerName == null) {
        officerName = "Placement Officer";
    }

    int totalCompanies = 0;
    int totalJobs = 0;
    int totalApplicants = 0;
    int selectedStudents = 0;

    String companySql = "SELECT COUNT(*) FROM companies";
    String jobsSql = "SELECT COUNT(*) FROM jobs";
    String applicantsSql = "SELECT COUNT(*) FROM applications";
    String selectedSql = "SELECT COUNT(*) FROM applications WHERE status = 'Selected'";

    try (Connection conn = DBConnection.getConnection()) {

        try (PreparedStatement stmt = conn.prepareStatement(companySql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) totalCompanies = rs.getInt(1);
        }

        try (PreparedStatement stmt = conn.prepareStatement(jobsSql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) totalJobs = rs.getInt(1);
        }

        try (PreparedStatement stmt = conn.prepareStatement(applicantsSql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) totalApplicants = rs.getInt(1);
        }

        try (PreparedStatement stmt = conn.prepareStatement(selectedSql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) selectedStudents = rs.getInt(1);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Placement Officer | CampusHire</title>
    <link rel="stylesheet" href="../css/style.css">
</head>

<body class="dashboard-body">

<div class="dashboard-layout">

<aside class="sidebar">

    <div class="logo">Campus<span>Hire</span></div>

    <div class="user-mini">
        <div class="avatar">P</div>
        <div>
            <strong><%= officerName %></strong>
            <small>Placement Officer</small>
        </div>
    </div>

    <nav class="side-nav">
        <a href="dashboard.jsp" class="active">
            ▦ Dashboard
        </a>
        <a href="companies.jsp">
            🏢 Companies
        </a>
        <a href="jobs.jsp">
            💼 Job Drives
        </a>
        <a href="applicants.jsp">
            👥 Applicants
        </a>
        <a href="interviews.jsp">
            ◷ Interviews
        </a>
    </nav>

    <a href="${pageContext.request.contextPath}/LogoutServlet" class="logout">
        ← Logout
    </a>

</aside>

<main class="main-content">

    <div class="dashboard-header">
        <div>
            <h1>Placement Officer Dashboard</h1>
            <p>Welcome back, <%= officerName %>. Manage company drives and applicant selections.</p>
        </div>

        <a href="add-job.jsp" class="btn-primary">
            + Create Job Drive
        </a>
    </div>

    <div class="stats-grid">

        <div class="stat-card">
            <span class="stat-icon blue">🏢</span>
            <div>
                <small>Total Companies</small>
                <h2><%= totalCompanies %></h2>
            </div>
        </div>

        <div class="stat-card">
            <span class="stat-icon green">💼</span>
            <div>
                <small>Active Job Drives</small>
                <h2><%= totalJobs %></h2>
            </div>
        </div>

        <div class="stat-card">
            <span class="stat-icon orange">👥</span>
            <div>
                <small>Total Applicants</small>
                <h2><%= totalApplicants %></h2>
            </div>
        </div>

        <div class="stat-card">
            <span class="stat-icon purple">★</span>
            <div>
                <small>Selected Students</small>
                <h2><%= selectedStudents %></h2>
            </div>
        </div>

    </div>

    <div class="content-section">

        <div class="section-header">
            <div>
                <h2>Recent Job Drives</h2>
                <p>Recently created placement opportunities</p>
            </div>
            <a href="jobs.jsp">View All Drives →</a>
        </div>

        <div class="table-card">
            <table>
                <thead>
                    <tr>
                        <th>Company</th>
                        <th>Position</th>
                        <th>Location</th>
                        <th>Package</th>
                        <th>Applicants</th>
                        <th>Min CGPA</th>
                        <th>Action</th>
                    </tr>
                </thead>

                <tbody>

<%
    String recentJobsSql = "SELECT j.job_id, j.title, j.salary, j.location, j.min_cgpa, "
                         + "c.company_name, "
                         + "(SELECT COUNT(*) FROM applications a WHERE a.job_id = j.job_id) AS applicant_count "
                         + "FROM jobs j "
                         + "JOIN companies c ON j.company_id = c.company_id "
                         + "ORDER BY j.job_id DESC "
                         + "LIMIT 5";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(recentJobsSql);
         ResultSet rs = stmt.executeQuery()) {

        boolean hasJobs = false;

        while (rs.next()) {
            hasJobs = true;
            int jobId = rs.getInt("job_id");
            String companyName = rs.getString("company_name");
            String title = rs.getString("title");
            String location = rs.getString("location");
            String salary = rs.getString("salary");
            double minCgpa = rs.getDouble("min_cgpa");
            int applicantCount = rs.getInt("applicant_count");
%>

                    <tr>
                        <td><strong><%= companyName %></strong></td>
                        <td><%= title %></td>
                        <td><%= location %></td>
                        <td><%= salary %></td>
                        <td>
                            <a href="applicants.jsp?job_id=<%= jobId %>" style="color: #2563eb; font-weight: 600;">
                                <%= applicantCount %> applicants
                            </a>
                        </td>
                        <td>CGPA ≥ <%= minCgpa %></td>
                        <td>
                            <a href="applicants.jsp?job_id=<%= jobId %>" class="small-btn">View Applicants</a>
                        </td>
                    </tr>

<%
        }

        if (!hasJobs) {
%>
                    <tr>
                        <td colspan="7" style="text-align:center; padding: 25px; color: #64748b;">
                            No job drives available. <a href="add-job.jsp" style="color: #2563eb;">Create one now</a>
                        </td>
                    </tr>
<%
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
                    <tr>
                        <td colspan="7" style="text-align:center; color: red;">
                            Unable to load job drives.
                        </td>
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