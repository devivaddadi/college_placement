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
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Companies | CampusHire</title>
    <link rel="stylesheet" href="../css/style.css">
</head>

<body class="dashboard-body">

<div class="dashboard-layout">

<aside class="sidebar">

    <div class="logo">
        Campus<span>Hire</span>
    </div>

    <div class="user-mini">
        <div class="avatar">P</div>
        <div>
            <strong><%= officerName %></strong>
            <small>Placement Officer</small>
        </div>
    </div>

    <nav class="side-nav">
        <a href="dashboard.jsp">
            ▦ Dashboard
        </a>
        <a href="companies.jsp" class="active">
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
            <h1>Partner Companies</h1>
            <p>Manage visiting recruitment companies and their placement records.</p>
        </div>

        <a href="add-company.jsp" class="btn-primary">
            + Add Company
        </a>
    </div>

    <% if ("true".equals(request.getParameter("deleted"))) { %>
        <div style="background: #fee2e2; border: 1px solid #f87171; color: #b91c1c; padding: 12px 18px; border-radius: 8px; margin-bottom: 20px; font-weight: 500;">
            ✓ Company record deleted successfully.
        </div>
    <% } %>

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
            int companyId = rs.getInt("company_id");
            String companyName = rs.getString("company_name");
            String location = rs.getString("location");
            String website = rs.getString("website");
            int jobCount = rs.getInt("job_count");

            String initial = companyName != null && !companyName.isEmpty()
                    ? companyName.substring(0, 1).toUpperCase()
                    : "C";
%>

        <div class="company-card" style="position: relative;">

            <div class="company-logo large">
                <%= initial %>
            </div>

            <h2><%= companyName %></h2>
            <p>Campus Recruiter</p>

            <span>📍 <%= location != null ? location : "Location not specified" %></span>

            <hr>

            <small>Active Drives: <strong><%= jobCount %></strong></small>
            <br>
            <% if (website != null && !website.isEmpty()) { %>
                <small style="color: #2563eb;">🌐 <%= website %></small>
            <% } %>

            <br><br>

            <div style="display: flex; gap: 8px; justify-content: center;">
                <a href="jobs.jsp" class="small-btn">View Drives</a>
                <form action="${pageContext.request.contextPath}/DeleteCompanyServlet" method="post" style="display:inline; margin:0;" onsubmit="return confirm('Are you sure you want to delete this company and all its job drives?');">
                    <input type="hidden" name="company_id" value="<%= companyId %>">
                    <button type="submit" class="small-btn" style="color: #dc2626; border-color: #fca5a5;">Delete</button>
                </form>
            </div>

        </div>

<%
        }

        if (!hasCompanies) {
%>
        <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #64748b;">
            <h2>No companies registered yet</h2>
            <br>
            <a href="add-company.jsp" class="btn-primary">+ Add First Company</a>
        </div>
<%
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
        <p style="color: red;">Unable to load companies.</p>
<%
    }
%>

    </div>

</main>

</div>

</body>
</html>