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

    String jobsSql = "SELECT j.job_id, j.title, j.description, j.location, j.salary, "
                   + "j.job_type, j.min_cgpa, j.max_backlogs, "
                   + "c.company_name, "
                   + "(SELECT COUNT(*) FROM applications a WHERE a.job_id = j.job_id) AS applicant_count "
                   + "FROM jobs j "
                   + "JOIN companies c ON j.company_id = c.company_id "
                   + "ORDER BY j.job_id DESC";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Job Drives | CampusHire</title>
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
        <a href="dashboard.jsp">▦ Dashboard</a>
        <a href="companies.jsp">🏢 Companies</a>
        <a href="jobs.jsp" class="active">💼 Job Drives</a>
        <a href="applicants.jsp">👥 Applicants</a>
        <a href="interviews.jsp">◷ Interviews</a>
    </nav>

    <a href="${pageContext.request.contextPath}/LogoutServlet" class="logout">← Logout</a>

</aside>

<main class="main-content">

    <div class="dashboard-header">
        <div>
            <h1>Job Drives</h1>
            <p>Create and manage placement opportunities across visiting companies.</p>
        </div>

        <a href="add-job.jsp" class="btn-primary">
            + Create Job Drive
        </a>
    </div>

    <% if ("added".equals(request.getParameter("success"))) { %>
        <div style="background: #dcfce7; border: 1px solid #86efac; color: #15803d; padding: 12px 18px; border-radius: 8px; margin-bottom: 20px; font-weight: 500;">
            ✓ New job drive created and published successfully!
        </div>
    <% } %>

    <% if ("true".equals(request.getParameter("deleted"))) { %>
        <div style="background: #fee2e2; border: 1px solid #f87171; color: #b91c1c; padding: 12px 18px; border-radius: 8px; margin-bottom: 20px; font-weight: 500;">
            ✓ Job drive and associated applications deleted successfully.
        </div>
    <% } %>

    <div class="table-card">

        <table>
            <thead>
                <tr>
                    <th>Company</th>
                    <th>Position</th>
                    <th>Package</th>
                    <th>Location</th>
                    <th>Eligibility</th>
                    <th>Applicants</th>
                    <th>Actions</th>
                </tr>
            </thead>

            <tbody>

<%
    boolean hasJobs = false;

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(jobsSql);
         ResultSet rs = stmt.executeQuery()) {

        while (rs.next()) {
            hasJobs = true;
            int jobId = rs.getInt("job_id");
            String companyName = rs.getString("company_name");
            String title = rs.getString("title");
            String salary = rs.getString("salary");
            String location = rs.getString("location");
            double minCgpa = rs.getDouble("min_cgpa");
            int maxBacklogs = rs.getInt("max_backlogs");
            int applicantCount = rs.getInt("applicant_count");
%>

                <tr>
                    <td><strong><%= companyName %></strong></td>
                    <td><%= title %></td>
                    <td><%= salary %></td>
                    <td><%= location %></td>
                    <td>
                        <small>CGPA ≥ <%= minCgpa %><br>Backlogs ≤ <%= maxBacklogs %></small>
                    </td>
                    <td>
                        <a href="applicants.jsp?job_id=<%= jobId %>" style="color: #2563eb; font-weight: 600;">
                            <%= applicantCount %> Applicants
                        </a>
                    </td>
                    <td>
                        <div style="display: flex; gap: 8px;">
                            <a href="applicants.jsp?job_id=<%= jobId %>" class="small-btn">View</a>
                            <form action="${pageContext.request.contextPath}/DeleteJobServlet" method="post" style="display:inline; margin:0;" onsubmit="return confirm('Are you sure you want to delete this job drive?');">
                                <input type="hidden" name="job_id" value="<%= jobId %>">
                                <button type="submit" class="small-btn" style="color: #dc2626; border-color: #fca5a5;">Delete</button>
                            </form>
                        </div>
                    </td>
                </tr>

<%
        }

        if (!hasJobs) {
%>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 35px; color: #64748b;">
                        No job drives active yet. Click "+ Create Job Drive" to add one.
                    </td>
                </tr>
<%
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 25px; color: red;">
                        Error loading job drives.
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