package com.csp.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.placement.util.DBConnection;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

private static final long serialVersionUID = 1L;

@Override
protected void doPost(HttpServletRequest request,
                       HttpServletResponse response)
        throws ServletException, IOException {

    String email = request.getParameter("email");
    String password = request.getParameter("password");

    String sql = "SELECT student_id, name, email FROM students "
               + "WHERE email = ? AND password = ?";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setString(1, email);
        stmt.setString(2, password);

        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {

            // Create session
            HttpSession session = request.getSession();

            session.setAttribute("studentId",
                                 rs.getInt("student_id"));

            session.setAttribute("studentName",
                                 rs.getString("name"));

            session.setAttribute("studentEmail",
                                 rs.getString("email"));

            // Login successful
            response.sendRedirect(
                request.getContextPath()
                + "/student/dashboard.jsp"
            );

        } else {

            // Login failed
            request.setAttribute(
                "errorMessage",
                "Invalid email or password."
            );

            request.getRequestDispatcher(
                "/login.jsp"
            ).forward(request, response);
        }

    } catch (SQLException e) {

        e.printStackTrace();

        request.setAttribute(
            "errorMessage",
            "Database error occurred. Please try again."
        );

        request.getRequestDispatcher(
            "/login.jsp"
        ).forward(request, response);
    }
}


}
