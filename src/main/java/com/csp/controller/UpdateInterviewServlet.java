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

@WebServlet("/UpdateInterviewServlet")
public class UpdateInterviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String interviewIdParam = request.getParameter("interview_id");
        String status = request.getParameter("status");

        if (interviewIdParam == null || status == null) {
            response.sendRedirect(request.getContextPath() + "/officer/interviews.jsp");
            return;
        }

        try {
            int interviewId = Integer.parseInt(interviewIdParam);

            String sql = "UPDATE interviews SET status = ? WHERE interview_id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, status);
                stmt.setInt(2, interviewId);
                stmt.executeUpdate();
            }

            response.sendRedirect(request.getContextPath() + "/officer/interviews.jsp?updated=true");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/officer/interviews.jsp?error=true");
        }
    }
}
