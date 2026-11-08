<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="com.placement.util.DBConnection" %>

<%
    // Check logged-in student
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

    // Get job ID from URL
    String jobIdParameter = request.getParameter("job_id");
    if (jobIdParameter == null) {
        response.sendRedirect("jobs.jsp");
        return;
    }

    int jobId = 0;
    try {
        jobId = Integer.parseInt(jobIdParameter);
    } catch (NumberFormatException nfe) {
        response.sendRedirect("jobs.jsp");
        return;
    }

    String title = "";
    String companyName = "";
    String location = "";
    String salary = "";
    String jobType = "";
    String description = "";
    double minCgpa = 0.0;
    int maxBacklogs = 0;
    boolean jobFound = false;

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

    // Get job details
    String jobSql = "SELECT j.title, j.description, j.location, j.salary, "
                  + "j.job_type, j.min_cgpa, j.max_backlogs, c.company_name "
                  + "FROM jobs j "
                  + "JOIN companies c ON j.company_id = c.company_id "
                  + "WHERE j.job_id = ?";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(jobSql)) {
        stmt.setInt(1, jobId);
        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                jobFound = true;
                title = rs.getString("title");
                description = rs.getString("description");
                location = rs.getString("location");
                salary = rs.getString("salary");
                jobType = rs.getString("job_type");
                minCgpa = rs.getDouble("min_cgpa");
                maxBacklogs = rs.getInt("max_backlogs");
                companyName = rs.getString("company_name");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (!jobFound) {
        response.sendRedirect("jobs.jsp");
        return;
    }

    // Check eligibility
    boolean eligible = (studentCgpa >= minCgpa) && (studentBacklogs <= maxBacklogs);

    // Check whether student already applied and what status
    boolean alreadyApplied = false;
    String applicationStatus = null;

    String appCheckSql = "SELECT application_id, status FROM applications WHERE student_id = ? AND job_id = ?";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(appCheckSql)) {
        stmt.setInt(1, studentId);
        stmt.setInt(2, jobId);
        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                alreadyApplied = true;
                applicationStatus = rs.getString("status");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    String companyInitial = companyName != null && !companyName.isEmpty()
            ? companyName.substring(0, 1).toUpperCase()
            : "C";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= title %> | CampusHire</title>
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

<main class="main-content">

    <a href="jobs.jsp" class="btn-outline" style="display:inline-block; margin-bottom:20px; padding: 7px 14px; font-size:13px;">
        ← Back to Jobs
    </a>

    <% if ("true".equals(request.getParameter("applied"))) { %>
        <div style="background: #dcfce7; border: 1px solid #86efac; color: #15803d; padding: 14px 20px; border-radius: 8px; margin-bottom: 25px; font-weight: 500;">
            ✓ Your application for <strong><%= title %></strong> at <strong><%= companyName %></strong> has been submitted successfully!
        </div>
    <% } %>

    <div class="job-detail-card" style="background: white; border: 1px solid #e5e7eb; border-radius: 12px; padding: 35px;">

        <div class="job-detail-header" style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 20px;">

            <div style="display: flex; align-items: center; gap: 20px;">
                <div class="company-logo large"><%= companyInitial %></div>
                <div>
                    <h1 style="font-size: 26px; margin-bottom: 6px;"><%= title %></h1>
                    <p style="font-size: 16px; color: #475569; margin-bottom: 8px;"><%= companyName %></p>
                    <span style="color: #64748b; font-size: 14px;">
                        📍 <%= location %> &nbsp; • &nbsp; 💼 <%= jobType %> &nbsp; • &nbsp; 💰 <%= salary %>
                    </span>
                </div>
            </div>

            <div>
                <% if (alreadyApplied) { %>
                    <span class="status shortlisted" style="font-size: 14px; padding: 8px 16px;">
                        Status: <%= applicationStatus %>
                    </span>
                <% } else if (eligible) { %>
                    <span class="job-status eligible" style="font-size: 14px; padding: 8px 16px;">
                        ✓ You are eligible
                    </span>
                <% } else { %>
                    <span class="job-status not-eligible" style="font-size: 14px; padding: 8px 16px;">
                        Not Eligible
                    </span>
                <% } %>
            </div>

        </div>

        <hr style="margin: 25px 0; border: none; border-top: 1px solid #e5e7eb;">

        <section style="margin-bottom: 25px;">
            <h2 style="font-size: 18px; margin-bottom: 10px;">Job Description</h2>
            <p style="color: #475569; line-height: 1.7; font-size: 15px;">
                <%= description != null && !description.isEmpty() ? description : "No description provided." %>
            </p>
        </section>

        <section style="margin-bottom: 25px;">
            <h2 style="font-size: 18px; margin-bottom: 12px;">Eligibility Criteria</h2>
            <ul class="criteria" style="list-style: none; padding: 0; display: flex; flex-direction: column; gap: 8px; font-size: 14px;">
                <li style="color: <%= studentCgpa >= minCgpa ? "#16a34a" : "#dc2626" %>;">
                    <%= studentCgpa >= minCgpa ? "✓" : "✕" %> Minimum CGPA: <%= minCgpa %> (Your CGPA: <%= studentCgpa %>)
                </li>
                <li style="color: <%= studentBacklogs <= maxBacklogs ? "#16a34a" : "#dc2626" %>;">
                    <%= studentBacklogs <= maxBacklogs ? "✓" : "✕" %> Maximum Backlogs Allowed: <%= maxBacklogs %> (Your Backlogs: <%= studentBacklogs %>)
                </li>
            </ul>
        </section>

        <section style="margin-bottom: 30px;">
            <h2 style="font-size: 18px; margin-bottom: 12px;">Selection Process</h2>
            <div class="selection-process" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px;">
                <div style="background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0;">
                    <strong style="color: #2563eb; display: block; font-size: 18px;">01</strong>
                    <span>Resume Screening</span>
                </div>
                <div style="background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0;">
                    <strong style="color: #2563eb; display: block; font-size: 18px;">02</strong>
                    <span>Technical Round</span>
                </div>
                <div style="background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0;">
                    <strong style="color: #2563eb; display: block; font-size: 18px;">03</strong>
                    <span>HR / Final Interview</span>
                </div>
            </div>
        </section>

        <div class="apply-area" style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">

            <div>
                <strong>Application Status</strong>
                <p style="color: #64748b; font-size: 14px; margin-top: 4px;">
                    <% if (alreadyApplied) { %>
                        You submitted an application for this position. Current status: <strong><%= applicationStatus %></strong>.
                    <% } else if (!eligible) { %>
                        You do not meet the minimum eligibility criteria for this job.
                    <% } else { %>
                        You meet all criteria and can apply for this drive.
                    <% } %>
                </p>
            </div>

            <div>
                <% if (alreadyApplied) { %>
                    <a href="applications.jsp" class="btn-outline">
                        View My Applications
                    </a>
                <% } else if (eligible) { %>
                    <form action="${pageContext.request.contextPath}/ApplyJobServlet" method="post" style="margin: 0;">
                        <input type="hidden" name="job_id" value="<%= jobId %>">
                        <button type="submit" class="btn-primary" style="cursor: pointer;">
                            Apply Now →
                        </button>
                    </form>
                <% } else { %>
                    <button class="btn-primary" style="background: #94a3b8; cursor: not-allowed;" disabled>
                        Not Eligible
                    </button>
                <% } %>
            </div>

        </div>

    </div>

</main>

</div>

</body>
</html>
