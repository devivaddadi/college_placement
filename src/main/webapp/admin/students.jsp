<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List"%>
<%@ page import="com.placement.util.DBConnection"%>

<%
    String searchKeyword = request.getParameter("search");
    if (searchKeyword != null) searchKeyword = searchKeyword.trim();

    String branchFilter = request.getParameter("branch");
    if (branchFilter != null) branchFilter = branchFilter.trim();

    // Distinct branches for filter dropdown
    List<String> branchesList = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement("SELECT DISTINCT branch FROM students WHERE branch IS NOT NULL AND branch != '' ORDER BY branch");
         ResultSet rs = stmt.executeQuery()) {
        while (rs.next()) {
            branchesList.add(rs.getString("branch"));
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    StringBuilder sqlBuilder = new StringBuilder(
        "SELECT s.student_id, s.name, s.email, s.phone, s.branch, s.cgpa, s.backlogs, s.graduation_year, "
        + "(SELECT COUNT(*) FROM applications a WHERE a.student_id = s.student_id) AS app_count "
        + "FROM students s "
        + "WHERE 1=1 "
    );

    List<Object> queryParams = new ArrayList<>();

    if (searchKeyword != null && !searchKeyword.isEmpty()) {
        sqlBuilder.append("AND (s.name LIKE ? OR s.email LIKE ? OR s.phone LIKE ?) ");
        String pattern = "%" + searchKeyword + "%";
        queryParams.add(pattern);
        queryParams.add(pattern);
        queryParams.add(pattern);
    }

    if (branchFilter != null && !branchFilter.isEmpty()) {
        sqlBuilder.append("AND s.branch = ? ");
        queryParams.add(branchFilter);
    }

    sqlBuilder.append("ORDER BY s.student_id DESC");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Students | CampusHire Admin</title>
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
        <a href="students.jsp" class="active">
            👥 Students
        </a>
        <a href="companies.jsp">
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
            <h1>Registered Students</h1>
            <p>View student academic profiles and placement applications.</p>
        </div>
    </div>

    <!-- FILTER BAR -->
    <form action="students.jsp" method="get" class="search-bar" style="display:flex; gap:12px; align-items:center; flex-wrap:wrap; margin-bottom:25px;">
        <input type="text"
               name="search"
               value="<%= searchKeyword != null ? searchKeyword : "" %>"
               placeholder="Search by student name, email, or phone..."
               style="flex: 1; min-width: 220px; padding: 11px 16px; border: 1px solid #cbd5e1; border-radius: 6px;">

        <select name="branch" style="padding: 11px 16px; border: 1px solid #cbd5e1; border-radius: 6px; background:white;">
            <option value="">All Branches</option>
            <% for (String br : branchesList) { %>
                <option value="<%= br %>" <%= br.equalsIgnoreCase(branchFilter) ? "selected" : "" %>><%= br %></option>
            <% } %>
        </select>

        <button type="submit" class="btn-primary" style="padding: 11px 20px;">
            Filter
        </button>

        <% if ((searchKeyword != null && !searchKeyword.isEmpty()) || (branchFilter != null && !branchFilter.isEmpty())) { %>
            <a href="students.jsp" class="btn-outline" style="padding: 10px 16px;">Clear</a>
        <% } %>
    </form>

    <div class="table-card">

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>Branch</th>
                    <th>CGPA</th>
                    <th>Backlogs</th>
                    <th>Grad Year</th>
                    <th>Applications</th>
                </tr>
            </thead>

            <tbody>

<%
    boolean hasStudents = false;

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sqlBuilder.toString())) {

        for (int i = 0; i < queryParams.size(); i++) {
            stmt.setObject(i + 1, queryParams.get(i));
        }

        try (ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                hasStudents = true;
                int studentId = rs.getInt("student_id");
                String name = rs.getString("name");
                String email = rs.getString("email");
                String phone = rs.getString("phone");
                String branch = rs.getString("branch");
                double cgpa = rs.getDouble("cgpa");
                int backlogs = rs.getInt("backlogs");
                int gradYear = rs.getInt("graduation_year");
                int appCount = rs.getInt("app_count");
%>

                <tr>
                    <td>#<%= studentId %></td>
                    <td><strong><%= name %></strong></td>
                    <td><%= email %></td>
                    <td><%= phone != null ? phone : "-" %></td>
                    <td><%= branch %></td>
                    <td><strong><%= cgpa %></strong></td>
                    <td>
                        <span style="color: <%= backlogs > 0 ? "#dc2626" : "#16a34a" %>; font-weight: 600;">
                            <%= backlogs %>
                        </span>
                    </td>
                    <td><%= gradYear %></td>
                    <td>
                        <span class="status shortlisted">
                            <%= appCount %> Applied
                        </span>
                    </td>
                </tr>

<%
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
                <tr>
                    <td colspan="9" style="text-align:center; padding: 25px; color: red;">
                        Error loading student records.
                    </td>
                </tr>
<%
    }

    if (!hasStudents) {
%>
                <tr>
                    <td colspan="9" style="text-align:center; padding: 35px; color: #64748b;">
                        No student records found matching the query.
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