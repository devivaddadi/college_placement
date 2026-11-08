<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

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
    <title>Add Company | CampusHire</title>
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
        <a href="dashboard.jsp">▦ Dashboard</a>
        <a href="companies.jsp" class="active">🏢 Companies</a>
        <a href="jobs.jsp">💼 Job Drives</a>
        <a href="applicants.jsp">👥 Applicants</a>
        <a href="interviews.jsp">◷ Interviews</a>
    </nav>

    <a href="${pageContext.request.contextPath}/LogoutServlet" class="logout">
        ← Logout
    </a>

</aside>

<main class="main-content">

    <div class="dashboard-header">
        <div>
            <h1>Add Company</h1>
            <p>Register a new recruiting company for campus placements.</p>
        </div>
        <a href="companies.jsp" class="btn-outline">
            ← Back to Companies
        </a>
    </div>

    <% if ("true".equals(request.getParameter("error"))) { %>
        <div style="background: #fee2e2; border: 1px solid #f87171; color: #b91c1c; padding: 12px 18px; border-radius: 8px; margin-bottom: 20px; font-weight: 500;">
            ✕ Failed to add company. Please verify the company details.
        </div>
    <% } %>

    <div class="content-section">

        <div class="table-card" style="padding: 35px; max-width: 650px; background:white; border-radius: 12px; border:1px solid #e5e7eb;">

            <form action="${pageContext.request.contextPath}/AddCompanyServlet" method="post">

                <div style="margin-bottom: 18px;">
                    <label style="display:block; margin-bottom: 6px; font-weight: 600;">Company Name *</label>
                    <input
                        type="text"
                        name="company_name"
                        placeholder="e.g. Google, Microsoft, Infosys"
                        required
                        style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 6px;"
                    >
                </div>

                <div style="margin-bottom: 18px;">
                    <label style="display:block; margin-bottom: 6px; font-weight: 600;">Headquarters / Location *</label>
                    <input
                        type="text"
                        name="location"
                        placeholder="e.g. Hyderabad, Bengaluru, Pune"
                        required
                        style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 6px;"
                    >
                </div>

                <div style="margin-bottom: 25px;">
                    <label style="display:block; margin-bottom: 6px; font-weight: 600;">Official Website</label>
                    <input
                        type="text"
                        name="website"
                        placeholder="https://www.company.com"
                        style="width: 100%; padding: 12px; border: 1px solid #cbd5e1; border-radius: 6px;"
                    >
                </div>

                <div style="display: flex; gap: 15px;">
                    <button type="submit" class="btn-primary">
                        Add Company
                    </button>
                    <a href="companies.jsp" class="btn-outline">
                        Cancel
                    </a>
                </div>

            </form>

        </div>

    </div>

</main>

</div>

</body>
</html>