package com.csp.controller;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/test")
public class TestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");

        PrintWriter out = response.getWriter();

        out.println("<html>");
        out.println("<head>");
        out.println("<title>Test Servlet</title>");
        out.println("</head>");

        out.println("<body>");

        out.println("<h1>Servlet is Working!</h1>");
        out.println("<p>Welcome to CampusHire.</p>");
        out.println("<p>Java Servlet is successfully connected to Tomcat.</p>");

        out.println("</body>");
        out.println("</html>");
    }
}