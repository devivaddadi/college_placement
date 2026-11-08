package com.csp.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.placement.util.DBConnection;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String branch = request.getParameter("branch");
        String cgpaText = request.getParameter("cgpa");
        String graduationYearText = request.getParameter("graduation_year");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        try {
            double cgpa = Double.parseDouble(cgpaText);
            int graduationYear = Integer.parseInt(graduationYearText);

            String sql = "INSERT INTO students (name, email, password, phone, branch, cgpa, graduation_year, backlogs) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, 0)";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, password);
                ps.setString(4, phone);
                ps.setString(5, branch);
                ps.setDouble(6, cgpa);
                ps.setInt(7, graduationYear);

                int rows = ps.executeUpdate();

                if (rows > 0) {
                    response.sendRedirect(request.getContextPath() + "/login.jsp?registered=true");
                } else {
                    request.setAttribute("errorMessage", "Registration failed. Please try again.");
                    request.getRequestDispatcher("register.jsp").forward(request, response);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            String errorMsg = "Database error during registration.";
            if (e.getMessage() != null && e.getMessage().toLowerCase().contains("duplicate")) {
                errorMsg = "An account with this email address already exists. Please login.";
            }
            request.setAttribute("errorMessage", errorMsg);
            request.getRequestDispatcher("register.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Invalid input data: " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}