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

@WebServlet("/UpdateApplicationServlet")
public class UpdateApplicationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {

        String applicationIdParameter =
            request.getParameter("application_id");

        String status =
            request.getParameter("status");

        if (applicationIdParameter == null ||
            status == null) {

            response.sendRedirect(
                request.getContextPath()
                + "/officer/applicants.jsp"
            );

            return;
        }

        int applicationId =
            Integer.parseInt(applicationIdParameter);

        // Allow valid status values
        if (!status.equals("Shortlisted") &&
            !status.equals("Rejected") &&
            !status.equals("Selected") &&
            !status.equals("Applied")) {

            response.sendRedirect(
                request.getContextPath()
                + "/officer/applicants.jsp"
            );

            return;
        }

        String sql =
            "UPDATE applications " +
            "SET status = ? " +
            "WHERE application_id = ?";

        try (Connection conn =
                 DBConnection.getConnection();
             PreparedStatement stmt =
                 conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, applicationId);

            stmt.executeUpdate();

            String redirect = request.getParameter("redirect");
            if (redirect != null && !redirect.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + redirect);
            } else {
                response.sendRedirect(
                    request.getContextPath()
                    + "/officer/applicants.jsp"
                );
            }

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                request.getContextPath()
                + "/officer/applicants.jsp"
            );
        }
    }
}