<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register | CampusHire</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body class="auth-body">

<header class="topbar">
    <div class="logo">Campus<span>Hire</span></div>

    <nav>
        <a href="index.jsp">Home</a>
        <a href="login.jsp" class="nav-btn">Login</a>
    </nav>
</header>

<div class="auth-container">

    <div class="register-card">

        <div class="auth-heading">
            <div class="badge">STUDENT REGISTRATION</div>
            <h1>Create Account</h1>
            <p>Register to explore placement opportunities.</p>
        </div>

        <% if (request.getAttribute("errorMessage") != null) { %>
            <div style="background: #fee2e2; border: 1px solid #f87171; color: #b91c1c; padding: 10px 15px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; text-align: center;">
                <%= request.getAttribute("errorMessage") %>
            </div>
        <% } %>

        <!-- REGISTRATION FORM -->
        <form action="${pageContext.request.contextPath}/register" method="post">

            <div class="form-row">
                <div>
                    <label>Full Name</label>
                    <input type="text"
                           name="name"
                           placeholder="Enter your name"
                           required>
                </div>

                <div>
                    <label>Email Address</label>
                    <input type="email"
                           name="email"
                           placeholder="Enter your email"
                           required>
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label>Phone Number</label>
                    <input type="text"
                           name="phone"
                           placeholder="Enter phone number"
                           required>
                </div>

                <div>
                    <label>Branch</label>
                    <select name="branch" required>
                        <option value="">Select Branch</option>
                        <option value="Information Technology">Information Technology</option>
                        <option value="Computer Science">Computer Science</option>
                        <option value="Electronics & Communication">Electronics & Communication</option>
                        <option value="Electrical & Electronics">Electrical & Electronics</option>
                        <option value="Mechanical">Mechanical</option>
                        <option value="Civil Engineering">Civil Engineering</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label>CGPA (Scale 10)</label>
                    <input type="number"
                           name="cgpa"
                           step="0.01"
                           min="0"
                           max="10"
                           placeholder="Example: 8.25"
                           required>
                </div>

                <div>
                    <label>Graduation Year</label>
                    <select name="graduation_year" required>
                        <option value="">Select Year</option>
                        <option value="2025">2025</option>
                        <option value="2026">2026</option>
                        <option value="2027">2027</option>
                        <option value="2028">2028</option>
                        <option value="2029">2029</option>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div>
                    <label>Password</label>
                    <input type="password"
                           name="password"
                           placeholder="Create password"
                           required>
                </div>

                <div>
                    <label>Confirm Password</label>
                    <input type="password"
                           name="confirmPassword"
                           placeholder="Confirm password"
                           required>
                </div>
            </div>

            <button type="submit" class="btn-primary full-btn" style="margin-top: 10px;">
                Create Account
            </button>

        </form>

        <div class="auth-footer">
            Already have an account?
            <a href="login.jsp">Login</a>
        </div>

    </div>

</div>

</body>
</html>
