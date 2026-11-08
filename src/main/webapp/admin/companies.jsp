<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="com.placement.util.DBConnection"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Registered Companies | CampusHire Admin</title>
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
        <a href="dashboard.jsp">
            ▦ Dashboard
        </a>
        <a href="students.jsp">
            👥 Students
        </a>
        <a href="companies.jsp" class="active">
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
            <h1>Registered Companies</h1>
            <p>All recruiting partners participating in campus recruitment.</p>
        </div>
        <a href="../officer/add-company.jsp" class="btn-primary">+ Add New Company</a>
    </div>

    <div class="company-grid">

<%
    String sql = "SELECT c.company_id, c.company_name, c.location, c.website, "
               + "(SELECT COUNT(*) FROM jobs j WHERE j.company_id = c.company_id) AS job_count "
               + "FROM companies c ORDER BY c.company_id DESC";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql);
         ResultSet rs = stmt.executeQuery()) {

        boolean hasCompanies = false;

        while (rs.next()) {
            hasCompanies = true;
            String companyName = rs.getString("company_name");
            String location = rs.getString("location");
            String website = rs.getString("website");
            int jobCount = rs.getInt("job_count");

            String initial = companyName != null && !companyName.isEmpty()
                    ? companyName.substring(0, 1).toUpperCase()
                    : "C";
%>

        <div class="company-card">
            <div class="company-logo large"><%= initial %></div>
            <h2><%= companyName %></h2>
            <p>Corporate Recruiter</p>
            <span>📍 <%= location != null ? location : "Location not specified" %></span>
            <hr>
            <small>Job Drives: <strong><%= jobCount %></strong></small>
            <br>
            <% if (website != null && !website.isEmpty()) { %>
                <small style="color: #2563eb;">🌐 <%= website %></small>
            <% } %>
        </div>

<%
        }

        if (!hasCompanies) {
%>
        <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #64748b;">
            <h2>No companies registered yet</h2>
            <br>
            <a href="../officer/add-company.jsp" class="btn-primary">+ Register First Company</a>
        </div>
<%
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
        <p style="color: red;">Error loading company records.</p>
<%
    }
%>

    </div>

</main>

</div>

</body>
</html>
