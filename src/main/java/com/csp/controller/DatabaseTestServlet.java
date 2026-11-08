package com.csp.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.placement.util.DBConnection;

@WebServlet("/database-test")
public class DatabaseTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");

        PrintWriter out = response.getWriter();

        Connection connection = DBConnection.getConnection();

        out.println("<html>");
        out.println("<head>");
        out.println("<title>Database Test</title>");
        out.println("</head>");

        out.println("<body>");

        if (connection != null) {

            out.println("<h1>Database Connected Successfully!</h1>");
            out.println("<p>Java Servlet is connected to MySQL.</p>");

        } else {

            out.println("<h1>Database Connection Failed!</h1>");
            out.println("<p>Please check the Eclipse Console.</p>");
        }

        out.println("</body>");
        out.println("</html>");
    }
}