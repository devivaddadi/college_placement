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

    String jobIdParam = request.getParameter("job_id");
    Integer filterJobId = null;
    String filterJobTitle = null;

    if (jobIdParam != null && !jobIdParam.trim().isEmpty()) {
        try {
            filterJobId = Integer.parseInt(jobIdParam);
        } catch (NumberFormatException ignored) {}
    }

    StringBuilder sqlBuilder = new StringBuilder(
        "SELECT a.application_id, a.status, a.applied_date, "
        + "s.student_id, s.name, s.branch, s.cgpa, s.email, s.phone, "
        + "j.job_id, j.title, "
        + "c.company_name "
        + "FROM applications a "
        + "JOIN students s ON a.student_id = s.student_id "
        + "JOIN jobs j ON a.job_id = j.job_id "
        + "JOIN companies c ON j.company_id = c.company_id "
    );

    if (filterJobId != null) {
        sqlBuilder.append("WHERE a.job_id = ? ");
    }

    sqlBuilder.append("ORDER BY a.applied_date DESC");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Applicants | CampusHire</title>
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
        <a href="jobs.jsp">
            💼 Job Drives
        </a>
        <a href="applicants.jsp" class="active">
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
            <h1>Student Applicants</h1>
            <p>Review student qualifications, shortlist candidates, and schedule interviews.</p>
        </div>

        <% if (filterJobId != null) { %>
            <a href="applicants.jsp" class="btn-outline">
                ✕ Clear Filter (Show All)
            </a>
        <% } %>
    </div>

    <div class="table-card">

        <table>
            <thead>
                <tr>
                    <th>Student Name</th>
                    <th>Branch</th>
                    <th>CGPA</th>
                    <th>Company & Role</th>
                    <th>Applied Date</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>

            <tbody>

<%
    boolean hasApplicants = false;

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString())) {

        if (filterJobId != null) {
            stmt.setInt(1, filterJobId);
        }

        try (ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                hasApplicants = true;
                int applicationId = rs.getInt("application_id");
                String studentName = rs.getString("name");
                String branch = rs.getString("branch");
                double cgpa = rs.getDouble("cgpa");
                String jobTitle = rs.getString("title");
                String companyName = rs.getString("company_name");
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
                    <td>
                        <strong><%= studentName %></strong>
                    </td>
                    <td><%= branch %></td>
                    <td><strong><%= cgpa %></strong></td>
                    <td>
                        <%= jobTitle %>
                        <br>
                        <small style="color: #64748b;"><%= companyName %></small>
                    </td>
                    <td><%= appliedDate != null ? appliedDate.toString().substring(0, 10) : "-" %></td>
                    <td>
                        <span class="status <%= statusClass %>">
                            <%= status %>
                        </span>
                    </td>
                    <td>
                        <a href="review.jsp?application_id=<%= applicationId %>" class="small-btn">
                            Review Applicant
                        </a>
                    </td>
                </tr>

<%
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
                <tr>
                    <td colspan="7" style="text-align:center; padding: 25px; color: red;">
                        Unable to load applicants.
                    </td>
                </tr>
<%
    }

    if (!hasApplicants) {
%>
                <tr>
                    <td colspan="7" style="text-align:center; padding: 35px; color: #64748b;">
                        No applications found <%= filterJobId != null ? "for this job drive." : "yet." %>
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