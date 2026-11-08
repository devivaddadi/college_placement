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

@WebServlet("/ApplyJobServlet")
public class ApplyJobServlet extends HttpServlet {

private static final long serialVersionUID = 1L;

@Override
protected void doPost(HttpServletRequest request,
                       HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession(false);

    // Check login
    if (session == null ||
        session.getAttribute("studentId") == null) {

        response.sendRedirect("login.jsp");
        return;
    }

    Integer studentId =
        (Integer) session.getAttribute("studentId");

    String jobIdParameter =
        request.getParameter("job_id");

    if (jobIdParameter == null) {

        response.sendRedirect("student/jobs.jsp");
        return;
    }

    int jobId = Integer.parseInt(jobIdParameter);


    String checkSql =
        "SELECT application_id " +
        "FROM applications " +
        "WHERE student_id = ? AND job_id = ?";


    String insertSql =
        "INSERT INTO applications " +
        "(student_id, job_id, status) " +
        "VALUES (?, ?, 'Applied')";


    try (Connection conn = DBConnection.getConnection()) {


        // Check whether already applied

        try (PreparedStatement checkStmt =
                 conn.prepareStatement(checkSql)) {

            checkStmt.setInt(1, studentId);
            checkStmt.setInt(2, jobId);

            try (ResultSet rs =
                     checkStmt.executeQuery()) {

                if (rs.next()) {

                    response.sendRedirect(
                        "student/job-details.jsp?job_id="
                        + jobId
                    );

                    return;
                }
            }
        }


        // Insert application

        try (PreparedStatement insertStmt =
                 conn.prepareStatement(insertSql)) {

            insertStmt.setInt(1, studentId);
            insertStmt.setInt(2, jobId);

            insertStmt.executeUpdate();
        }


        // Return to job details

        response.sendRedirect(
            "student/job-details.jsp?job_id="
            + jobId
            + "&applied=true"
        );


    } catch (Exception e) {

        e.printStackTrace();

        response.sendRedirect(
            "student/job-details.jsp?job_id="
            + jobId
            + "&error=true"
        );
    }
}


}
