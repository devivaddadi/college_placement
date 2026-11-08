<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Officer Login | CampusHire</title>
    <link rel="stylesheet" href="../css/style.css">
</head>

<body class="auth-body">

<header class="topbar">
    <div class="logo">Campus<span>Hire</span></div>

    <nav>
        <a href="../index.jsp">Home</a>
        <a href="../login.jsp">Student Login</a>
    </nav>
</header>

<div class="auth-container">

    <div class="auth-card">

        <div class="auth-heading">
            <div class="badge">PLACEMENT OFFICER PORTAL</div>
            <h1>Officer Login</h1>
            <p>Login to manage campus recruitment activities.</p>
        </div>

        <% if (request.getAttribute("errorMessage") != null) { %>
            <div style="background: #fee2e2; border: 1px solid #f87171; color: #b91c1c; padding: 10px 15px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; text-align: center;">
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/OfficerLoginServlet" method="post">

            <label>Email Address</label>
            <input
                type="email"
                name="email"
                placeholder="officer@campushire.com"
                required
            >

            <label>Password</label>
            <input
                type="password"
                name="password"
                placeholder="Enter password"
                required
            >

            <button type="submit" class="btn-primary full-btn" style="margin-top: 10px;">
                Login as Officer
            </button>

        </form>

        <div class="auth-footer">
            Are you a student?
            <a href="../login.jsp">Student Login</a>
        </div>

    </div>

</div>

</body>
</html>