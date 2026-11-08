<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.PreparedStatement"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="com.placement.util.DBConnection"%>

<%
    int totalJobs = 0;
    int totalCompanies = 0;
    int placedStudents = 0;

    try (Connection conn = DBConnection.getConnection()) {
        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM jobs");
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) totalJobs = rs.getInt(1);
        }

        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM companies");
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) totalCompanies = rs.getInt(1);
        }

        try (PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(DISTINCT student_id) FROM applications WHERE status = 'Selected'");
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) placedStudents = rs.getInt(1);
        }
    } catch (Exception e) {
        // Fallbacks if DB not initialized yet
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CampusHire | College Placement Platform</title>
    <link rel="stylesheet" href="css/style.css">
</head>

<body>

<header class="topbar">
    <div class="logo">Campus<span>Hire</span></div>

    <nav>
        <a href="index.jsp">Home</a>
        <a href="#features">Features</a>
        <a href="#about">About</a>
        <a href="admin/dashboard.jsp">Admin</a>
        <a href="officer/officer-login.jsp">Officer</a>
        <a href="login.jsp">Student Login</a>
        <a href="register.jsp" class="nav-btn">Register</a>
    </nav>
</header>

<section class="hero">

    <div class="hero-content">

        <div class="badge">COLLEGE PLACEMENT MANAGEMENT SYSTEM</div>

        <h1>
            Your Career.<br>
            <span>Your Future.</span>
        </h1>

        <p>
            CampusHire bridges the gap between ambitious students, top recruiting companies,
            and college placement coordinators seamlessly in one dynamic platform.
        </p>

        <div class="hero-buttons">
            <a href="login.jsp" class="btn-primary">Student Login</a>
            <a href="officer/officer-login.jsp" class="btn-outline">
                Officer Login
            </a>
            <a href="admin/dashboard.jsp" class="btn-outline" style="border-color:#64748b; color:#334155;">
                Admin Portal
            </a>
        </div>

        <!-- DYNAMIC STATS PILL -->
        <div style="display: flex; justify-content: center; gap: 30px; margin-top: 40px; flex-wrap: wrap;">
            <div style="background: white; border: 1px solid #e2e8f0; padding: 12px 24px; border-radius: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.04);">
                💼 <strong style="color: #2563eb; font-size: 16px;"><%= totalJobs %></strong> <span style="color:#64748b; font-size: 14px;">Active Drives</span>
            </div>
            <div style="background: white; border: 1px solid #e2e8f0; padding: 12px 24px; border-radius: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.04);">
                🏢 <strong style="color: #16a34a; font-size: 16px;"><%= totalCompanies %></strong> <span style="color:#64748b; font-size: 14px;">Companies</span>
            </div>
            <div style="background: white; border: 1px solid #e2e8f0; padding: 12px 24px; border-radius: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.04);">
                ★ <strong style="color: #9333ea; font-size: 16px;"><%= placedStudents %></strong> <span style="color:#64748b; font-size: 14px;">Students Selected</span>
            </div>
        </div>

    </div>

</section>

<section class="features" id="features">

    <div class="section-title">
        <div class="small-title">FEATURES</div>
        <h2>Everything you need for placements</h2>
        <p>Manage your complete placement journey from one centralized platform.</p>
    </div>

    <div class="feature-grid">

        <div class="feature-card">
            <div class="icon">💼</div>
            <h3>Job Opportunities</h3>
            <p>
                Explore real-time placement opportunities and open positions posted by participating companies.
            </p>
        </div>

        <div class="feature-card">
            <div class="icon">✓</div>
            <h3>Eligibility Check</h3>
            <p>
                Instantly check your eligibility based on minimum CGPA and allowed backlog criteria.
            </p>
        </div>

        <div class="feature-card">
            <div class="icon">📋</div>
            <h3>Easy Applications</h3>
            <p>
                Apply with one click and track application progress from shortlist to final offer.
            </p>
        </div>

        <div class="feature-card">
            <div class="icon">◷</div>
            <h3>Interview Scheduling</h3>
            <p>
                Stay updated with interview schedules, rounds (Technical, HR), and real-time statuses.
            </p>
        </div>

    </div>

</section>

<section class="about" id="about">

    <div class="about-box">

        <div>
            <div class="small-title">ABOUT CAMPUSHIRE</div>

            <h2>
                One platform for the complete placement journey.
            </h2>
        </div>

        <p>
            CampusHire is designed to modernize campus recruitment operations by providing
            dynamic management of companies, student qualifications, application shortlisting,
            and interview workflows. Built on robust Java EE Servlets and dynamic JSP architecture.
        </p>

    </div>

</section>

<section class="cta">

    <h2>Ready to start your career journey?</h2>

    <p>
        Create your student account or login to explore active campus drives today.
    </p>

    <a href="register.jsp" class="btn-primary">
        Get Started Now
    </a>

</section>

<footer>

    <div class="logo">Campus<span>Hire</span></div>

    <p>College Placement Management System</p>

    <small>© 2026 CampusHire. Dynamic Java Web Application.</small>

</footer>

</body>
</html>