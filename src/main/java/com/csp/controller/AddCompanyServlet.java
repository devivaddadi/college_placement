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

@WebServlet("/AddCompanyServlet")
public class AddCompanyServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {

        String companyName =
            request.getParameter("company_name");

        String location =
            request.getParameter("location");

        String website =
            request.getParameter("website");

        String sql =
            "INSERT INTO companies " +
            "(company_name, location, website) " +
            "VALUES (?, ?, ?)";

        try (Connection conn =
                 DBConnection.getConnection();
             PreparedStatement stmt =
                 conn.prepareStatement(sql)) {

            stmt.setString(1, companyName);
            stmt.setString(2, location);
            stmt.setString(3, website);

            stmt.executeUpdate();

            response.sendRedirect(
                request.getContextPath()
                + "/officer/companies.jsp"
            );

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                request.getContextPath()
                + "/officer/add-company.jsp?error=true"
            );
        }
    }
}