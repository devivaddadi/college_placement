<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login | CampusHire</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body class="auth-body">

<header class="topbar">

    <div class="logo">Campus<span>Hire</span></div>

    <nav>
        <a href="index.jsp">Home</a>
        <a href="officer/officer-login.jsp">Officer Login</a>
        <a href="register.jsp" class="nav-btn">Register</a>
    </nav>

</header>

<div class="auth-container">

    <div class="auth-card">

        <div class="auth-heading">

            <div class="badge">STUDENT PORTAL</div>

            <h1>Welcome Back</h1>

            <p>
                Login to access your placement dashboard.
            </p>

        </div>

        <% if (request.getAttribute("errorMessage") != null) { %>
            <div style="background: #fee2e2; border: 1px solid #f87171; color: #b91c1c; padding: 10px 15px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; text-align: center;">
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>

        <% if ("true".equals(request.getParameter("registered"))) { %>
            <div style="background: #dcfce7; border: 1px solid #86efac; color: #15803d; padding: 10px 15px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; text-align: center;">
                ✓ Account created successfully! Please login.
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/LoginServlet" method="post">
            <label>Email Address</label>

            <input
                type="email" name="email"
                placeholder="Enter your email"
                required
            >

            <label>Password</label>

            <input
                type="password" name="password"
                placeholder="Enter your password"
                required
            >

            <button type="submit" class="btn-primary full-btn" style="margin-top: 10px;">
                Login
            </button>

        </form>

        <div class="auth-footer">

            Don't have an account?

            <a href="register.jsp">
                Create Account
            </a>
            
            <div style="margin-top: 12px; font-size: 13px;">
                Placement Officer? <a href="officer/officer-login.jsp">Officer Login</a>
            </div>

        </div>

    </div>

</div>

</body>
</html>