package com.csp.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.placement.util.DBConnection;

@WebServlet("/OfficerLoginServlet")
public class OfficerLoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                           HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        String sql =
            "SELECT officer_id, name, email " +
            "FROM officers " +
            "WHERE email = ? AND password = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            stmt.setString(2, password);

            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {

                HttpSession session = request.getSession();

                session.setAttribute(
                    "officerId",
                    rs.getInt("officer_id")
                );

                session.setAttribute(
                    "officerName",
                    rs.getString("name")
                );

                session.setAttribute(
                    "officerEmail",
                    rs.getString("email")
                );

                response.sendRedirect(
                    request.getContextPath()
                    + "/officer/dashboard.jsp"
                );

            } else {

                request.setAttribute(
                    "errorMessage",
                    "Invalid officer email or password."
                );

                request.getRequestDispatcher(
                    "/officer/officer-login.jsp"
                ).forward(request, response);
            }

        } catch (Exception e) {

            e.printStackTrace();

            request.setAttribute(
                "errorMessage",
                "Database error occurred. Please try again."
            );

            request.getRequestDispatcher(
                "/officer/officer-login.jsp"
            ).forward(request, response);
        }
    }
}