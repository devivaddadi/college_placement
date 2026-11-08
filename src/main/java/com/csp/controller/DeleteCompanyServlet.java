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

@WebServlet("/DeleteCompanyServlet")
public class DeleteCompanyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String companyIdParam = request.getParameter("company_id");
        if (companyIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/officer/companies.jsp");
            return;
        }

        try {
            int companyId = Integer.parseInt(companyIdParam);

            try (Connection conn = DBConnection.getConnection()) {
                // Delete interviews for jobs in this company
                String delInterviews = "DELETE FROM interviews WHERE application_id IN "
                                     + "(SELECT application_id FROM applications WHERE job_id IN "
                                     + "(SELECT job_id FROM jobs WHERE company_id = ?))";
                try (PreparedStatement stmt = conn.prepareStatement(delInterviews)) {
                    stmt.setInt(1, companyId);
                    stmt.executeUpdate();
                }

                // Delete applications for jobs in this company
                String delApps = "DELETE FROM applications WHERE job_id IN "
                               + "(SELECT job_id FROM jobs WHERE company_id = ?)";
                try (PreparedStatement stmt = conn.prepareStatement(delApps)) {
                    stmt.setInt(1, companyId);
                    stmt.executeUpdate();
                }

                // Delete jobs for this company
                String delJobs = "DELETE FROM jobs WHERE company_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(delJobs)) {
                    stmt.setInt(1, companyId);
                    stmt.executeUpdate();
                }

                // Delete company
                String delComp = "DELETE FROM companies WHERE company_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(delComp)) {
                    stmt.setInt(1, companyId);
                    stmt.executeUpdate();
                }
            }

            response.sendRedirect(request.getContextPath() + "/officer/companies.jsp?deleted=true");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/officer/companies.jsp?error=delete");
        }
    }
}
