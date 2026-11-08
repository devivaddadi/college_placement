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

@WebServlet("/AddJobServlet")
public class AddJobServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            int companyId = Integer.parseInt(request.getParameter("company_id"));
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String location = request.getParameter("location");
            String salary = request.getParameter("salary");
            String jobType = request.getParameter("job_type");
            double minCgpa = Double.parseDouble(request.getParameter("min_cgpa"));
            int maxBacklogs = Integer.parseInt(request.getParameter("max_backlogs"));

            String sql = "INSERT INTO jobs (company_id, title, description, location, salary, job_type, min_cgpa, max_backlogs) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {

                stmt.setInt(1, companyId);
                stmt.setString(2, title);
                stmt.setString(3, description);
                stmt.setString(4, location);
                stmt.setString(5, salary);
                stmt.setString(6, jobType != null && !jobType.trim().isEmpty() ? jobType : "Full Time");
                stmt.setDouble(7, minCgpa);
                stmt.setInt(8, maxBacklogs);

                stmt.executeUpdate();

                response.sendRedirect(request.getContextPath() + "/officer/jobs.jsp?success=added");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/officer/jobs.jsp?error=true");
        }
    }
}
