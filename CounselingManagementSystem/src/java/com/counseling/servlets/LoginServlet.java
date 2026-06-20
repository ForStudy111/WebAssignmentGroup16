package com.counseling.servlets;

import com.counseling.data.DBConnection;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String userParam = request.getParameter("username");
        String passParam = request.getParameter("password");
        
        if (userParam == null || passParam == null || userParam.trim().isEmpty()) {
            response.sendRedirect("login.jsp?error=true&msg=" + URLEncoder.encode("Fields cannot be empty", "UTF-8"));
            return;
        }

        String query = "SELECT role FROM users WHERE username = ? AND password = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            
            ps.setString(1, userParam.trim());
            ps.setString(2, passParam.trim());
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String role = rs.getString("role");
                    
                    HttpSession session = request.getSession();
                    session.setAttribute("user", userParam.trim());
                    session.setAttribute("role", role);
                    
                    String contextPath = request.getContextPath();
                    if ("ADMIN".equalsIgnoreCase(role)) {
                        response.sendRedirect(contextPath + "/admin/dashboard.jsp");
                    } else if ("STUDENT".equalsIgnoreCase(role)) {
                        response.sendRedirect(contextPath + "/student/dashboard.jsp");
                    } else if ("COUNSELOR".equalsIgnoreCase(role)) {
                        response.sendRedirect(contextPath + "/counselor/dashboard.jsp");
                    } else {
                        response.sendRedirect(contextPath + "/login.jsp?error=true&msg=" + URLEncoder.encode("Role undefined", "UTF-8"));
                    }
                } else {
                    response.sendRedirect("login.jsp?error=true&msg=" + URLEncoder.encode("Invalid Username or Password.", "UTF-8"));
                }
            }
        } catch (Exception e) {
            // Forward the exact internal Tomcat/MySQL exception text message straight to the UI screen
            String message = e.getMessage() != null ? e.getMessage() : e.toString();
            response.sendRedirect("login.jsp?error=true&msg=" + URLEncoder.encode("DB Error: " + message, "UTF-8"));
        }
    }
}