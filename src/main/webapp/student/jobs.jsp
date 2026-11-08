<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="com.placement.util.DBConnection" %>

<%
    // Ensure student is logged in
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

    // Student academic details
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

    // Search and filter parameters
    String searchKeyword = request.getParameter("search");
    if (searchKeyword != null) searchKeyword = searchKeyword.trim();

    String filterLocation = request.getParameter("location");
    if (filterLocation != null) filterLocation = filterLocation.trim();

    // Distinct locations for filter dropdown
    List<String> locationsList = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement("SELECT DISTINCT location FROM jobs WHERE location IS NOT NULL AND location != '' ORDER BY location");
         ResultSet rs = stmt.executeQuery()) {
        while (rs.next()) {
            locationsList.add(rs.getString("location"));
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Job Opportunities | CampusHire</title>
    <link rel="stylesheet" href="../css/style.css">
</head>

<body class="dashboard-body">

<div class="dashboard-layout">

<!-- SIDEBAR -->
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
        <a href="dashboard.jsp">
            ▦ Dashboard
        </a>
        <a href="profile.jsp">
            ◉ My Profile
        </a>
        <a href="jobs.jsp" class="active">
            💼 Job Opportunities
        </a>
        <a href="applications.jsp">
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

<!-- MAIN CONTENT -->
<main class="main-content">

    <div class="dashboard-header">
        <div>
            <h1>Job Opportunities</h1>
            <p>Find and apply for placement drives matching your qualifications.</p>
        </div>
    </div>

    <!-- DYNAMIC SEARCH BAR -->
    <form action="jobs.jsp" method="get" class="search-bar" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap; margin-bottom:25px;">
        <input type="text"
               name="search"
               value="<%= searchKeyword != null ? searchKeyword : "" %>"
               placeholder="Search jobs, company names or skills..."
               style="flex: 1; min-width: 220px; padding: 11px 16px; border: 1px solid #cbd5e1; border-radius: 6px;">

        <select name="location" style="padding: 11px 16px; border: 1px solid #cbd5e1; border-radius: 6px; background:white;">
            <option value="">All Locations</option>
            <% for (String loc : locationsList) { %>
                <option value="<%= loc %>" <%= loc.equalsIgnoreCase(filterLocation) ? "selected" : "" %>><%= loc %></option>
            <% } %>
        </select>

        <button type="submit" class="btn-primary" style="padding: 11px 20px;">
            Search
        </button>

        <% if ((searchKeyword != null && !searchKeyword.isEmpty()) || (filterLocation != null && !filterLocation.isEmpty())) { %>
            <a href="jobs.jsp" class="btn-outline" style="padding: 10px 16px;">Clear Filters</a>
        <% } %>
    </form>

    <!-- JOBS GRID -->
    <div class="jobs-grid">

<%
    StringBuilder sqlBuilder = new StringBuilder(
        "SELECT j.job_id, j.title, j.description, j.location, j.salary, j.job_type, "
        + "j.min_cgpa, j.max_backlogs, c.company_name "
        + "FROM jobs j "
        + "JOIN companies c ON j.company_id = c.company_id "
        + "WHERE 1=1 "
    );

    List<Object> queryParams = new ArrayList<>();

    if (searchKeyword != null && !searchKeyword.isEmpty()) {
        sqlBuilder.append("AND (j.title LIKE ? OR c.company_name LIKE ? OR j.description LIKE ?) ");
        String pattern = "%" + searchKeyword + "%";
        queryParams.add(pattern);
        queryParams.add(pattern);
        queryParams.add(pattern);
    }

    if (filterLocation != null && !filterLocation.isEmpty()) {
        sqlBuilder.append("AND j.location = ? ");
        queryParams.add(filterLocation);
    }

    sqlBuilder.append("ORDER BY j.job_id DESC");

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString())) {

        for (int i = 0; i < queryParams.size(); i++) {
            stmt.setObject(i + 1, queryParams.get(i));
        }

        try (ResultSet rs = stmt.executeQuery()) {
            boolean hasJobs = false;

            while (rs.next()) {
                hasJobs = true;
                int jobId = rs.getInt("job_id");
                String title = rs.getString("title");
                String companyName = rs.getString("company_name");
                String location = rs.getString("location");
                String salary = rs.getString("salary");
                String jobType = rs.getString("job_type");
                double minCgpa = rs.getDouble("min_cgpa");
                int maxBacklogs = rs.getInt("max_backlogs");

                boolean eligible = (studentCgpa >= minCgpa) && (studentBacklogs <= maxBacklogs);
                String companyInitial = companyName != null && !companyName.isEmpty()
                        ? companyName.substring(0, 1).toUpperCase()
                        : "C";
%>

        <div class="job-box">

            <div class="job-box-top">
                <div class="company-logo"><%= companyInitial %></div>
                <% if (eligible) { %>
                    <span class="job-status eligible">✓ Eligible</span>
                <% } else { %>
                    <span class="job-status not-eligible">Not Eligible</span>
                <% } %>
            </div>

            <h2><%= title %></h2>
            <p class="company-name"><%= companyName %></p>

            <div class="job-meta">
                📍 <%= location %>
                &nbsp; • &nbsp;
                💰 <%= salary %>
                &nbsp; • &nbsp;
                <%= jobType %>
            </div>

            <div class="skills">
                <span>Min CGPA: <%= minCgpa %></span>
                <span>Max Backlogs: <%= maxBacklogs %></span>
            </div>

            <hr>

            <div class="job-bottom">
                <small>Your CGPA: <%= studentCgpa %></small>
                <a href="job-details.jsp?job_id=<%= jobId %>" class="small-btn">
                    View Details
                </a>
            </div>

        </div>

<%
            }

            if (!hasJobs) {
%>
        <div style="text-align: center; width: 100%; grid-column: 1 / -1; padding: 40px 20px;">
            <h2>No job opportunities found</h2>
            <p style="color: #64748b; margin-top: 8px;">Try adjusting your search criteria or clearing filters.</p>
            <br>
            <a href="jobs.jsp" class="btn-primary">View All Jobs</a>
        </div>
<%
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
        <div style="text-align: center; width: 100%; grid-column: 1 / -1; color: red;">
            <h2>Error loading job opportunities.</h2>
            <p>Please check database connection.</p>
        </div>
<%
    }
%>

    </div>

</main>

</div>

</body>
</html>
