<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="com.placement.util.DBConnection"%>

<%
    // Get logged-in student ID from session
    Integer studentId = (Integer) session.getAttribute("studentId");

    // If student is not logged in
    if (studentId == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String name = "";
    String email = "";
    String phone = "";
    String branch = "";
    double cgpa = 0.0;
    int backlogs = 0;
    int graduationYear = 0;

    String sql = "SELECT student_id, name, email, phone, branch, "
               + "cgpa, backlogs, graduation_year "
               + "FROM students WHERE student_id = ?";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setInt(1, studentId);

        try (ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                name = rs.getString("name");
                email = rs.getString("email");
                phone = rs.getString("phone");
                branch = rs.getString("branch");
                cgpa = rs.getDouble("cgpa");
                backlogs = rs.getInt("backlogs");
                graduationYear = rs.getInt("graduation_year");
            } else {
                response.sendRedirect("../login.jsp");
                return;
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    String firstLetter = !name.trim().isEmpty() 
            ? name.substring(0, 1).toUpperCase() 
            : "S";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Profile | CampusHire</title>
    <link rel="stylesheet" href="../css/style.css">
    <script>
        function toggleEditForm() {
            var viewSection = document.getElementById("profile-view-section");
            var editSection = document.getElementById("profile-edit-section");
            if (editSection.style.display === "none" || editSection.style.display === "") {
                editSection.style.display = "block";
                viewSection.style.display = "none";
            } else {
                editSection.style.display = "none";
                viewSection.style.display = "block";
            }
        }
    </script>
</head>

<body class="dashboard-body">

<div class="dashboard-layout">

<!-- ================= SIDEBAR ================= -->
<aside class="sidebar">

    <div class="logo">
        Campus<span>Hire</span>
    </div>

    <div class="user-mini">
        <div class="avatar"><%= firstLetter %></div>
        <div>
            <strong><%= name %></strong>
            <small><%= branch != null && !branch.isEmpty() ? branch : "Student" %></small>
        </div>
    </div>

    <nav class="side-nav">
        <a href="dashboard.jsp">
            ▦ Dashboard
        </a>
        <a href="profile.jsp" class="active">
            ◉ My Profile
        </a>
        <a href="jobs.jsp">
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

<!-- ================= MAIN CONTENT ================= -->
<main class="main-content">

    <div class="dashboard-header">
        <div>
            <h1>My Profile</h1>
            <p>Manage and update your personal and academic information.</p>
        </div>
    </div>

    <% if ("true".equals(request.getParameter("updated"))) { %>
        <div style="background: #dcfce7; border: 1px solid #86efac; color: #15803d; padding: 12px 18px; border-radius: 8px; margin-bottom: 25px; font-weight: 500;">
            ✓ Profile details updated successfully!
        </div>
    <% } %>

    <% if ("true".equals(request.getParameter("error"))) { %>
        <div style="background: #fee2e2; border: 1px solid #f87171; color: #b91c1c; padding: 12px 18px; border-radius: 8px; margin-bottom: 25px; font-weight: 500;">
            ✕ Failed to update profile. Please verify all inputs.
        </div>
    <% } %>

    <!-- ================= PROFILE VIEW CARD ================= -->
    <div class="profile-card" id="profile-view-section">

        <div class="profile-top">
            <div class="large-avatar" style="width: 70px; height: 70px; font-size: 28px; background: #dbeafe; color: #2563eb; display:flex; align-items:center; justify-content:center; border-radius: 50%; font-weight: bold;">
                <%= firstLetter %>
            </div>

            <div>
                <h2><%= name %></h2>
                <p style="color: #64748b;"><%= branch %></p>
                <span style="font-size: 13px; color: #94a3b8;">Student ID: <%= studentId %></span>
            </div>

            <button type="button" class="btn-primary" onclick="toggleEditForm()" style="margin-left: auto;">
                ✎ Edit Profile
            </button>
        </div>

        <div class="profile-section">
            <h3>Personal Information</h3>
            <div class="details-grid">
                <div>
                    <small>Full Name</small>
                    <strong><%= name %></strong>
                </div>

                <div>
                    <small>Email</small>
                    <strong><%= email %></strong>
                </div>

                <div>
                    <small>Phone</small>
                    <strong><%= phone != null && !phone.isEmpty() ? phone : "Not provided" %></strong>
                </div>

                <div>
                    <small>Student ID</small>
                    <strong><%= studentId %></strong>
                </div>
            </div>
        </div>

        <div class="profile-section">
            <h3>Academic Information</h3>
            <div class="details-grid">
                <div>
                    <small>Branch</small>
                    <strong><%= branch %></strong>
                </div>

                <div>
                    <small>CGPA</small>
                    <strong><%= cgpa %></strong>
                </div>

                <div>
                    <small>Graduation Year</small>
                    <strong><%= graduationYear %></strong>
                </div>

                <div>
                    <small>Active Backlogs</small>
                    <strong><%= backlogs %></strong>
                </div>
            </div>
        </div>

    </div>

    <!-- ================= EDIT PROFILE FORM ================= -->
    <div class="profile-card" id="profile-edit-section" style="display: none; padding: 35px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px;">
            <h2>Edit Profile Details</h2>
            <button type="button" class="btn-outline" onclick="toggleEditForm()">Cancel</button>
        </div>

        <form action="${pageContext.request.contextPath}/UpdateProfileServlet" method="post">

            <div class="form-row">
                <div>
                    <label>Full Name</label>
                    <input type="text" name="name" value="<%= name %>" required>
                </div>

                <div>
                    <label>Email (Cannot be modified)</label>
                    <input type="email" value="<%= email %>" disabled style="background: #f1f5f9; cursor: not-allowed;">
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label>Phone Number</label>
                    <input type="text" name="phone" value="<%= phone != null ? phone : "" %>" required>
                </div>

                <div>
                    <label>Branch</label>
                    <select name="branch" required>
                        <option value="Information Technology" <%= "Information Technology".equalsIgnoreCase(branch) ? "selected" : "" %>>Information Technology</option>
                        <option value="Computer Science" <%= "Computer Science".equalsIgnoreCase(branch) ? "selected" : "" %>>Computer Science</option>
                        <option value="Electronics & Communication" <%= "Electronics & Communication".equalsIgnoreCase(branch) ? "selected" : "" %>>Electronics & Communication</option>
                        <option value="Electrical & Electronics" <%= "Electrical & Electronics".equalsIgnoreCase(branch) ? "selected" : "" %>>Electrical & Electronics</option>
                        <option value="Mechanical" <%= "Mechanical".equalsIgnoreCase(branch) ? "selected" : "" %>>Mechanical</option>
                        <option value="Civil Engineering" <%= "Civil Engineering".equalsIgnoreCase(branch) ? "selected" : "" %>>Civil Engineering</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label>CGPA (Scale 10)</label>
                    <input type="number" step="0.01" min="0" max="10" name="cgpa" value="<%= cgpa %>" required>
                </div>

                <div>
                    <label>Active Backlogs</label>
                    <input type="number" min="0" name="backlogs" value="<%= backlogs %>" required>
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label>Graduation Year</label>
                    <select name="graduation_year" required>
                        <option value="2025" <%= graduationYear == 2025 ? "selected" : "" %>>2025</option>
                        <option value="2026" <%= graduationYear == 2026 ? "selected" : "" %>>2026</option>
                        <option value="2027" <%= graduationYear == 2027 ? "selected" : "" %>>2027</option>
                        <option value="2028" <%= graduationYear == 2028 ? "selected" : "" %>>2028</option>
                        <option value="2029" <%= graduationYear == 2029 ? "selected" : "" %>>2029</option>
                    </select>
                </div>
            </div>

            <div style="margin-top: 20px; display: flex; gap: 15px;">
                <button type="submit" class="btn-primary">Save Profile Changes</button>
                <button type="button" class="btn-outline" onclick="toggleEditForm()">Cancel</button>
            </div>

        </form>
    </div>

</main>

</div>

</body>
</html>