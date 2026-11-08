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
    <title>Create Job Drive | CampusHire</title>
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
        <a href="dashboard.jsp">
            ▦ Dashboard
        </a>
        <a href="companies.jsp">
            🏢 Companies
        </a>
        <a href="jobs.jsp" class="active">
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
            <h1>Create Job Drive</h1>
            <p>Publish a new recruitment drive for students.</p>
        </div>
        <a href="jobs.jsp" class="btn-outline">← Back to Job Drives</a>
    </div>

    <div class="table-card" style="padding: 35px; max-width: 800px; background: white; border-radius: 12px; border: 1px solid #e5e7eb;">

        <form action="${pageContext.request.contextPath}/AddJobServlet" method="post">

            <div class="form-row">
                <div>
                    <label>Select Company *</label>
                    <select name="company_id" required style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 6px; margin-bottom: 18px;">
                        <option value="">-- Choose Company --</option>
<%
    String compSql = "SELECT company_id, company_name FROM companies ORDER BY company_name";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(compSql);
         ResultSet rs = stmt.executeQuery()) {
        while (rs.next()) {
%>
                        <option value="<%= rs.getInt("company_id") %>">
                            <%= rs.getString("company_name") %>
                        </option>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
                    </select>
                </div>

                <div>
                    <label>Job Title / Designation *</label>
                    <input type="text" name="title" placeholder="e.g. Software Engineer" required>
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label>Location *</label>
                    <input type="text" name="location" placeholder="e.g. Hyderabad / Bengaluru" required>
                </div>

                <div>
                    <label>Salary / Package *</label>
                    <input type="text" name="salary" placeholder="e.g. ₹6.5 LPA" required>
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label>Job Type *</label>
                    <select name="job_type" required style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 6px; margin-bottom: 18px;">
                        <option value="Full Time">Full Time</option>
                        <option value="Internship">Internship</option>
                        <option value="Internship + Full Time">Internship + Full Time</option>
                    </select>
                </div>

                <div>
                    <label>Minimum Required CGPA *</label>
                    <input type="number" step="0.01" min="0" max="10" name="min_cgpa" placeholder="e.g. 7.0" required>
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label>Maximum Allowed Backlogs *</label>
                    <input type="number" min="0" name="max_backlogs" value="0" required>
                </div>
            </div>

            <div style="margin-bottom: 18px;">
                <label>Job Description & Requirements</label>
                <textarea name="description" rows="4" style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-family: inherit; outline: none;" placeholder="Describe job roles, responsibilities, and required qualifications..."></textarea>
            </div>

            <div style="display: flex; gap: 15px; margin-top: 20px;">
                <button type="submit" class="btn-primary">
                    Publish Job Drive
                </button>
                <a href="jobs.jsp" class="btn-outline">
                    Cancel
                </a>
            </div>

        </form>

    </div>

</main>

</div>

</body>
</html>
