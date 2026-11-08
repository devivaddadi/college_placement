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

@WebServlet("/DeleteJobServlet")
public class DeleteJobServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String jobIdParam = request.getParameter("job_id");
        if (jobIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/officer/jobs.jsp");
            return;
        }

        try {
            int jobId = Integer.parseInt(jobIdParam);

            try (Connection conn = DBConnection.getConnection()) {
                // Delete interviews associated with applications for this job
                String deleteInterviewsSql = "DELETE FROM interviews WHERE application_id IN "
                                           + "(SELECT application_id FROM applications WHERE job_id = ?)";
                try (PreparedStatement stmt = conn.prepareStatement(deleteInterviewsSql)) {
                    stmt.setInt(1, jobId);
                    stmt.executeUpdate();
                }

                // Delete applications for this job
                String deleteApplicationsSql = "DELETE FROM applications WHERE job_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(deleteApplicationsSql)) {
                    stmt.setInt(1, jobId);
                    stmt.executeUpdate();
                }

                // Delete job
                String deleteJobSql = "DELETE FROM jobs WHERE job_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(deleteJobSql)) {
                    stmt.setInt(1, jobId);
                    stmt.executeUpdate();
                }
            }

            response.sendRedirect(request.getContextPath() + "/officer/jobs.jsp?deleted=true");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/officer/jobs.jsp?error=delete");
        }
    }
}
