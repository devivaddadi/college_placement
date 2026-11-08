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

    String applicationParameter = request.getParameter("application_id");
    if (applicationParameter == null) {
        response.sendRedirect("applicants.jsp");
        return;
    }

    int applicationId = 0;
    try {
        applicationId = Integer.parseInt(applicationParameter);
    } catch (NumberFormatException nfe) {
        response.sendRedirect("applicants.jsp");
        return;
    }

    String sql = "SELECT a.application_id, a.status, a.applied_date, "
               + "s.student_id, s.name, s.email, s.phone, s.branch, "
               + "s.cgpa, s.backlogs, s.graduation_year, "
               + "j.job_id, j.title, j.salary, j.location, j.min_cgpa, j.max_backlogs, "
               + "c.company_name "
               + "FROM applications a "
               + "JOIN students s ON a.student_id = s.student_id "
               + "JOIN jobs j ON a.job_id = j.job_id "
               + "JOIN companies c ON j.company_id = c.company_id "
               + "WHERE a.application_id = ?";

    String studentName = null;
    String email = null;
    String phone = null;
    String branch = null;
    String jobTitle = null;
    String companyName = null;
    String salary = null;
    String location = null;
    String status = null;

    double cgpa = 0;
    int backlogs = 0;
    int graduationYear = 0;
    int studentId = 0;
    double minCgpa = 0;
    int maxBacklogs = 0;

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setInt(1, applicationId);

        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                studentId = rs.getInt("student_id");
                studentName = rs.getString("name");
                email = rs.getString("email");
                phone = rs.getString("phone");
                branch = rs.getString("branch");
                cgpa = rs.getDouble("cgpa");
                backlogs = rs.getInt("backlogs");
                graduationYear = rs.getInt("graduation_year");
                jobTitle = rs.getString("title");
                companyName = rs.getString("company_name");
                salary = rs.getString("salary");
                location = rs.getString("location");
                status = rs.getString("status");
                minCgpa = rs.getDouble("min_cgpa");
                maxBacklogs = rs.getInt("max_backlogs");
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    if (studentName == null) {
        response.sendRedirect("applicants.jsp");
        return;
    }

    boolean meetsCriteria = (cgpa >= minCgpa) && (backlogs <= maxBacklogs);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Review Applicant | CampusHire</title>
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
            <h1>Review Applicant</h1>
            <p>Application #<%= applicationId %> &bull; <%= studentName %> for <%= jobTitle %></p>
        </div>

        <a href="applicants.jsp" class="btn-outline">
            ← Back to Applicants
        </a>
    </div>

    <% if ("true".equals(request.getParameter("updated"))) { %>
        <div style="background: #dcfce7; border: 1px solid #86efac; color: #15803d; padding: 12px 18px; border-radius: 8px; margin-bottom: 20px; font-weight: 500;">
            ✓ Application status updated successfully!
        </div>
    <% } %>

    <% if ("true".equals(request.getParameter("scheduled"))) { %>
        <div style="background: #dcfce7; border: 1px solid #86efac; color: #15803d; padding: 12px 18px; border-radius: 8px; margin-bottom: 20px; font-weight: 500;">
            ✓ Interview scheduled successfully for this applicant!
        </div>
    <% } %>

    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 25px; margin-bottom: 25px;">

        <!-- STUDENT PROFILE CARD -->
        <div class="table-card" style="padding: 30px; background: white; border-radius: 12px; border: 1px solid #e5e7eb;">
            <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 15px;">
                <h2 style="font-size: 20px;">Candidate Profile</h2>
                <span class="status <%= meetsCriteria ? "shortlisted" : "rejected" %>">
                    <%= meetsCriteria ? "Eligible" : "Below Criteria" %>
                </span>
            </div>

            <p style="margin-bottom: 8px;"><strong>Full Name:</strong> <%= studentName %></p>
            <p style="margin-bottom: 8px;"><strong>Student ID:</strong> <%= studentId %></p>
            <p style="margin-bottom: 8px;"><strong>Email:</strong> <%= email %></p>
            <p style="margin-bottom: 8px;"><strong>Phone:</strong> <%= phone != null ? phone : "Not provided" %></p>
            <p style="margin-bottom: 8px;"><strong>Branch:</strong> <%= branch %></p>
            <p style="margin-bottom: 8px;"><strong>CGPA:</strong> <strong style="color: #2563eb;"><%= cgpa %></strong> (Required: <%= minCgpa %>)</p>
            <p style="margin-bottom: 8px;"><strong>Active Backlogs:</strong> <%= backlogs %> (Max allowed: <%= maxBacklogs %>)</p>
            <p style="margin-bottom: 8px;"><strong>Graduation Year:</strong> <%= graduationYear %></p>
        </div>

        <!-- JOB DETAILS & ACTION CARD -->
        <div class="table-card" style="padding: 30px; background: white; border-radius: 12px; border: 1px solid #e5e7eb;">
            <h2 style="font-size: 20px; margin-bottom: 15px;">Position Applied</h2>

            <p style="margin-bottom: 8px;"><strong>Company:</strong> <%= companyName %></p>
            <p style="margin-bottom: 8px;"><strong>Role:</strong> <%= jobTitle %></p>
            <p style="margin-bottom: 8px;"><strong>Package:</strong> <%= salary %></p>
            <p style="margin-bottom: 8px;"><strong>Location:</strong> <%= location %></p>

            <hr style="margin: 15px 0; border: none; border-top: 1px solid #e5e7eb;">

            <div style="margin-bottom: 15px;">
                <strong>Current Application Status:</strong>
                <span class="status <%= "Shortlisted".equalsIgnoreCase(status) || "Selected".equalsIgnoreCase(status) ? "shortlisted" : ("Rejected".equalsIgnoreCase(status) ? "rejected" : "applied") %>" style="margin-left: 10px;">
                    <%= status %>
                </span>
            </div>

            <div style="margin-top: 20px;">
                <label style="display:block; margin-bottom: 8px; font-weight: 600;">Update Status:</label>
                <div style="display: flex; gap: 10px; flex-wrap: wrap;">

                    <form action="${pageContext.request.contextPath}/UpdateApplicationServlet" method="post" style="margin:0;">
                        <input type="hidden" name="application_id" value="<%= applicationId %>">
                        <input type="hidden" name="status" value="Shortlisted">
                        <input type="hidden" name="redirect" value="/officer/review.jsp?application_id=<%= applicationId %>&updated=true">
                        <button type="submit" class="btn-primary" style="background: #2563eb;">
                            ✓ Shortlist
                        </button>
                    </form>

                    <form action="${pageContext.request.contextPath}/UpdateApplicationServlet" method="post" style="margin:0;">
                        <input type="hidden" name="application_id" value="<%= applicationId %>">
                        <input type="hidden" name="status" value="Selected">
                        <input type="hidden" name="redirect" value="/officer/review.jsp?application_id=<%= applicationId %>&updated=true">
                        <button type="submit" class="btn-primary" style="background: #16a34a;">
                            ★ Mark Selected
                        </button>
                    </form>

                    <form action="${pageContext.request.contextPath}/UpdateApplicationServlet" method="post" style="margin:0;">
                        <input type="hidden" name="application_id" value="<%= applicationId %>">
                        <input type="hidden" name="status" value="Rejected">
                        <input type="hidden" name="redirect" value="/officer/review.jsp?application_id=<%= applicationId %>&updated=true">
                        <button type="submit" class="btn-outline" style="color: #dc2626; border-color: #dc2626;">
                            ✕ Reject
                        </button>
                    </form>

                </div>
            </div>

        </div>

    </div>

    <!-- SCHEDULE INTERVIEW FOR THIS APPLICANT -->
    <div class="table-card" style="padding: 30px; background: white; border-radius: 12px; border: 1px solid #e5e7eb;">
        <h2 style="font-size: 20px; margin-bottom: 12px;">Schedule Interview for <%= studentName %></h2>
        <p style="color: #64748b; margin-bottom: 20px;">Directly book an interview slot for this student.</p>

        <form action="${pageContext.request.contextPath}/ScheduleInterviewServlet" method="post">
            <input type="hidden" name="application_id" value="<%= applicationId %>">
            <input type="hidden" name="redirect" value="/officer/review.jsp?application_id=<%= applicationId %>&scheduled=true">

            <div class="form-row">
                <div>
                    <label>Interview Date *</label>
                    <input type="date" name="interview_date" required style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 6px; margin-bottom: 15px;">
                </div>

                <div>
                    <label>Interview Time *</label>
                    <input type="time" name="interview_time" required style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 6px; margin-bottom: 15px;">
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label>Round / Interview Type *</label>
                    <select name="interview_type" required style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 6px; margin-bottom: 15px;">
                        <option value="Technical Interview">Technical Interview</option>
                        <option value="HR Interview">HR Interview</option>
                        <option value="Managerial Round">Managerial Round</option>
                        <option value="Online Assessment">Online Assessment</option>
                        <option value="Final Discussion">Final Discussion</option>
                    </select>
                </div>
            </div>

            <button type="submit" class="btn-primary" style="margin-top: 10px;">
                + Confirm & Schedule Interview
            </button>
        </form>
    </div>

</main>

</div>

</body>
</html>