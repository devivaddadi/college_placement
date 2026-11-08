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

    String interviewsSql = "SELECT i.interview_id, i.interview_date, i.interview_time, "
                         + "i.interview_type, i.status, "
                         + "s.name AS student_name, s.branch, "
                         + "j.title AS job_title, "
                         + "c.company_name "
                         + "FROM interviews i "
                         + "JOIN applications a ON i.application_id = a.application_id "
                         + "JOIN students s ON a.student_id = s.student_id "
                         + "JOIN jobs j ON a.job_id = j.job_id "
                         + "JOIN companies c ON j.company_id = c.company_id "
                         + "ORDER BY i.interview_date DESC, i.interview_time DESC";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Interviews | CampusHire</title>
    <link rel="stylesheet" href="../css/style.css">
    <script>
        function toggleScheduleModal() {
            var modal = document.getElementById("schedule-section");
            if (modal.style.display === "none" || modal.style.display === "") {
                modal.style.display = "block";
            } else {
                modal.style.display = "none";
            }
        }
    </script>
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
        <a href="jobs.jsp">💼 Job Drives</a>
        <a href="applicants.jsp">👥 Applicants</a>
        <a href="interviews.jsp" class="active">◷ Interviews</a>
    </nav>

    <a href="${pageContext.request.contextPath}/LogoutServlet" class="logout">← Logout</a>

</aside>

<main class="main-content">

    <div class="dashboard-header">
        <div>
            <h1>Placement Interviews</h1>
            <p>Schedule, manage, and track interview progress across companies.</p>
        </div>

        <button class="btn-primary" onclick="toggleScheduleModal()">
            + Schedule New Interview
        </button>
    </div>

    <% if ("true".equals(request.getParameter("scheduled"))) { %>
        <div style="background: #dcfce7; border: 1px solid #86efac; color: #15803d; padding: 12px 18px; border-radius: 8px; margin-bottom: 20px; font-weight: 500;">
            ✓ Interview scheduled successfully!
        </div>
    <% } %>

    <% if ("true".equals(request.getParameter("updated"))) { %>
        <div style="background: #dcfce7; border: 1px solid #86efac; color: #15803d; padding: 12px 18px; border-radius: 8px; margin-bottom: 20px; font-weight: 500;">
            ✓ Interview status updated successfully!
        </div>
    <% } %>

    <!-- SCHEDULE INTERVIEW CARD (COLLAPSIBLE) -->
    <div id="schedule-section" style="display: none; background: white; border: 1px solid #cbd5e1; border-radius: 12px; padding: 30px; margin-bottom: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
            <h2 style="font-size: 20px;">Schedule Interview</h2>
            <button type="button" class="small-btn" onclick="toggleScheduleModal()">✕ Close</button>
        </div>

        <form action="${pageContext.request.contextPath}/ScheduleInterviewServlet" method="post">
            <div style="margin-bottom: 18px;">
                <label style="display:block; margin-bottom:6px; font-weight:600;">Select Applicant *</label>
                <select name="application_id" required style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 6px;">
                    <option value="">-- Choose Candidate --</option>
<%
    String appQuery = "SELECT a.application_id, s.name, s.branch, j.title, c.company_name "
                    + "FROM applications a "
                    + "JOIN students s ON a.student_id = s.student_id "
                    + "JOIN jobs j ON a.job_id = j.job_id "
                    + "JOIN companies c ON j.company_id = c.company_id "
                    + "WHERE a.status IN ('Applied', 'Shortlisted') "
                    + "ORDER BY a.application_id DESC";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(appQuery);
         ResultSet rs = stmt.executeQuery()) {
        while (rs.next()) {
%>
                    <option value="<%= rs.getInt("application_id") %>">
                        <%= rs.getString("name") %> (<%= rs.getString("branch") %>) - <%= rs.getString("title") %> at <%= rs.getString("company_name") %>
                    </option>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
                </select>
            </div>

            <div class="form-row">
                <div>
                    <label>Interview Date *</label>
                    <input type="date" name="interview_date" required>
                </div>
                <div>
                    <label>Interview Time *</label>
                    <input type="time" name="interview_time" required>
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label>Round / Interview Type *</label>
                    <select name="interview_type" required>
                        <option value="Technical Interview">Technical Interview</option>
                        <option value="HR Interview">HR Interview</option>
                        <option value="Managerial Round">Managerial Round</option>
                        <option value="Online Assessment">Online Assessment</option>
                        <option value="Final Discussion">Final Discussion</option>
                    </select>
                </div>
            </div>

            <button type="submit" class="btn-primary" style="margin-top: 10px;">
                Confirm Schedule
            </button>
        </form>
    </div>

    <!-- INTERVIEWS TABLE -->
    <div class="table-card">

        <table>
            <thead>
                <tr>
                    <th>Student Name</th>
                    <th>Company</th>
                    <th>Position</th>
                    <th>Round</th>
                    <th>Date & Time</th>
                    <th>Status</th>
                    <th>Change Status</th>
                </tr>
            </thead>

            <tbody>

<%
    boolean hasInterviews = false;

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(interviewsSql);
         ResultSet rs = stmt.executeQuery()) {

        while (rs.next()) {
            hasInterviews = true;
            int interviewId = rs.getInt("interview_id");
            String studentName = rs.getString("student_name");
            String companyName = rs.getString("company_name");
            String jobTitle = rs.getString("job_title");
            String interviewType = rs.getString("interview_type");
            String status = rs.getString("status");
            java.sql.Date interviewDate = rs.getDate("interview_date");
            java.sql.Time interviewTime = rs.getTime("interview_time");

            String timeStr = "";
            if (interviewTime != null) {
                java.text.SimpleDateFormat timeFormat = new java.text.SimpleDateFormat("hh:mm a");
                timeStr = " at " + timeFormat.format(interviewTime);
            }

            String statusClass = "shortlisted";
            if ("Completed".equalsIgnoreCase(status)) {
                statusClass = "applied";
            } else if ("Cancelled".equalsIgnoreCase(status)) {
                statusClass = "rejected";
            }
%>

                <tr>
                    <td><strong><%= studentName %></strong></td>
                    <td><%= companyName %></td>
                    <td><%= jobTitle %></td>
                    <td><%= interviewType %></td>
                    <td><%= interviewDate != null ? interviewDate.toString() : "" %><%= timeStr %></td>
                    <td>
                        <span class="status <%= statusClass %>"><%= status %></span>
                    </td>
                    <td>
                        <div style="display: flex; gap: 6px;">
                            <% if (!"Completed".equalsIgnoreCase(status)) { %>
                                <form action="${pageContext.request.contextPath}/UpdateInterviewServlet" method="post" style="display:inline; margin:0;">
                                    <input type="hidden" name="interview_id" value="<%= interviewId %>">
                                    <input type="hidden" name="status" value="Completed">
                                    <button type="submit" class="small-btn" style="color: #16a34a; border-color: #86efac;" title="Mark Completed">✓ Done</button>
                                </form>
                            <% } %>

                            <% if (!"Cancelled".equalsIgnoreCase(status)) { %>
                                <form action="${pageContext.request.contextPath}/UpdateInterviewServlet" method="post" style="display:inline; margin:0;">
                                    <input type="hidden" name="interview_id" value="<%= interviewId %>">
                                    <input type="hidden" name="status" value="Cancelled">
                                    <button type="submit" class="small-btn" style="color: #dc2626; border-color: #fca5a5;" title="Cancel Interview">✕ Cancel</button>
                                </form>
                            <% } %>
                        </div>
                    </td>
                </tr>

<%
        }

        if (!hasInterviews) {
%>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 35px; color: #64748b;">
                        No interviews scheduled yet. Click "+ Schedule New Interview" to schedule one.
                    </td>
                </tr>
<%
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 25px; color: red;">
                        Unable to load interviews.
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