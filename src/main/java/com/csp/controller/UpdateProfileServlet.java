package com.csp.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.placement.util.DBConnection;

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");

        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String branch = request.getParameter("branch");
        String cgpaStr = request.getParameter("cgpa");
        String backlogsStr = request.getParameter("backlogs");
        String gradYearStr = request.getParameter("graduation_year");

        try {
            double cgpa = Double.parseDouble(cgpaStr);
            int backlogs = Integer.parseInt(backlogsStr);
            int gradYear = Integer.parseInt(gradYearStr);

            String sql = "UPDATE students SET name = ?, phone = ?, branch = ?, cgpa = ?, backlogs = ?, graduation_year = ? "
                       + "WHERE student_id = ?";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {

                stmt.setString(1, name);
                stmt.setString(2, phone);
                stmt.setString(3, branch);
                stmt.setDouble(4, cgpa);
                stmt.setInt(5, backlogs);
                stmt.setInt(6, gradYear);
                stmt.setInt(7, studentId);

                stmt.executeUpdate();

                // Update session name if changed
                session.setAttribute("studentName", name);
            }

            response.sendRedirect(request.getContextPath() + "/student/profile.jsp?updated=true");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/student/profile.jsp?error=true");
        }
    }
}
