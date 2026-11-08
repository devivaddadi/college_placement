package com.csp.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.placement.util.DBConnection;

@WebServlet("/registerStudent")
public class StudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String course = request.getParameter("course");

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String sql = "INSERT INTO students (name, email, branch) VALUES (?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, name);
            stmt.setString(2, email);
            stmt.setString(3, course);
            
            int rowsInserted = stmt.executeUpdate();
            
            out.println("<!DOCTYPE html><html><head><title>Registration Result</title>");
            out.println("<link rel='stylesheet' href='css/style.css'></head>");
            out.println("<body style='padding:50px; text-align:center;'>");
            if (rowsInserted > 0) {
                out.println("<h2 style='color:#16a34a;'>Student registered successfully!</h2>");
                out.println("<br><a href='student/dashboard.jsp' class='btn-primary'>Go to Student Dashboard</a>");
            } else {
                out.println("<h2 style='color:#dc2626;'>Failed to register student.</h2>");
                out.println("<br><a href='register.jsp' class='btn-outline'>Try Again</a>");
            }
            out.println("</body></html>");

        } catch (SQLException e) {
            out.println("<h3>Database Error: " + e.getMessage() + "</h3>");
            e.printStackTrace(out);
        }
    }
}