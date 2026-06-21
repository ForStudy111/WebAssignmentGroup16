/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.counseling.controller;

import com.counseling.dao.UserDAO;
import com.counseling.model.User;
import java.io.IOException;
import java.net.URLEncoder;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author wpy92
 */
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet RegisterServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet RegisterServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String fullName = getValue(request, "fullName");
        String username = getValue(request, "username");
        String email = getValue(request, "email");
        String phoneNumber = getValue(request, "phoneNumber");
        String password = getValue(request, "password");
        String confirmPassword = getValue(request, "confirmPassword");

        if (fullName.isEmpty() || username.isEmpty()
                || email.isEmpty() || password.isEmpty()
                || confirmPassword.isEmpty()) {

            redirectWithMessage(request, response,
                    "All required fields must be completed.", "error");
            return;
        }

        if (password.length() < 6) {
            redirectWithMessage(request, response,
                    "Password must contain at least 6 characters.", "error");
            return;
        }

        if (!password.equals(confirmPassword)) {
            redirectWithMessage(request, response,
                    "Password and confirm password do not match.", "error");
            return;
        }

        if (userDAO.isUsernameExists(username)) {
            redirectWithMessage(request, response,
                    "This username is already taken.", "error");
            return;
        }

        User student = new User(
                username,
                password,
                fullName,
                email,
                phoneNumber,
                "STUDENT"
        );

        boolean isCreated = userDAO.addUser(student);

        if (isCreated) {
            String successMessage = URLEncoder.encode(
                    "Registration successful. Please log in.",
                    "UTF-8"
            );

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp?success=true&msg="
                    + successMessage
            );
        } else {
            redirectWithMessage(request, response,
                    "Registration failed. The email may already be in use.",
                    "error");
        }
    }

    private String getValue(HttpServletRequest request, String parameter) {
        String value = request.getParameter(parameter);
        return value == null ? "" : value.trim();
    }

    private void redirectWithMessage(HttpServletRequest request,
            HttpServletResponse response,
            String message,
            String type) throws IOException {

        String encodedMessage = URLEncoder.encode(message, "UTF-8");

        response.sendRedirect(
                request.getContextPath()
                + "/register.jsp?"
                + type + "=true&msg="
                + encodedMessage
        );
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
