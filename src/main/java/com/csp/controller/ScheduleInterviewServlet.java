package com.csp.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.placement.util.DBConnection;

@WebServlet("/ScheduleInterviewServlet")
public class ScheduleInterviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            int applicationId = Integer.parseInt(request.getParameter("application_id"));
            String interviewDate = request.getParameter("interview_date");
            String interviewTime = request.getParameter("interview_time");
            String interviewType = request.getParameter("interview_type");

            if (interviewTime != null && interviewTime.length() == 5) {
                interviewTime = interviewTime + ":00";
            }

            String sql = "INSERT INTO interviews (application_id, interview_date, interview_time, interview_type, status) "
                       + "VALUES (?, ?, ?, ?, 'Scheduled')";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {

                stmt.setInt(1, applicationId);
                stmt.setString(2, interviewDate);
                stmt.setString(3, interviewTime);
                stmt.setString(4, interviewType);

                stmt.executeUpdate();
            }

            // Also ensure application status is at least Shortlisted
            String updateAppSql = "UPDATE applications SET status = 'Shortlisted' WHERE application_id = ? AND status = 'Applied'";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(updateAppSql)) {
                stmt.setInt(1, applicationId);
                stmt.executeUpdate();
            }

            String redirect = request.getParameter("redirect");
            if (redirect != null && !redirect.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + redirect);
            } else {
                response.sendRedirect(request.getContextPath() + "/officer/interviews.jsp?scheduled=true");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/officer/interviews.jsp?error=true");
        }
    }
}
