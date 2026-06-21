/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.counseling.controller;

import com.counseling.dao.UserDAO;
import com.counseling.model.User;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import javax.servlet.http.HttpSession;

@WebServlet("/ChangePasswordServlet")
public class ChangePasswordServlet extends HttpServlet {

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
            out.println("<title>Servlet ChangePasswordServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ChangePasswordServlet at " + request.getContextPath() + "</h1>");
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
        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        request.getRequestDispatcher("/change-password.jsp").forward(request, response);
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

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        String currentPassword = getValue(request, "currentPassword");
        String newPassword = getValue(request, "newPassword");
        String confirmPassword = getValue(request, "confirmPassword");

        if (currentPassword.isEmpty()
                || newPassword.isEmpty()
                || confirmPassword.isEmpty()) {

            redirectWithMessage(request, response,
                    "/ChangePasswordServlet",
                    "Please complete all password fields.");
            return;
        }

        String username = currentUser.getUsername();

        if (username == null || username.trim().isEmpty()) {
            username = (String) request.getSession().getAttribute("user");
        }

        User verifiedUser = userDAO.authenticate(
                username,
                currentPassword
        );

        if (verifiedUser == null) {
            redirectWithMessage(request, response,
                    "/ChangePasswordServlet",
                    "Your current password is incorrect.");
            return;
        }

        if (newPassword.length() < 6) {
            redirectWithMessage(request, response,
                    "/ChangePasswordServlet",
                    "Your new password must contain at least 6 characters.");
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            redirectWithMessage(request, response,
                    "/ChangePasswordServlet",
                    "New password and confirmation password do not match.");
            return;
        }

        if (userDAO.updatePassword(currentUser.getUserId(), newPassword)) {
            currentUser.setPassword(newPassword);

            request.getSession().setAttribute("currentUser", currentUser);

            redirectWithMessage(request, response,
                    "/UserServlet?action=profile",
                    "Password changed successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/ChangePasswordServlet",
                    "Password update failed.");
        }
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        return (User) session.getAttribute("currentUser");
    }

    private String getValue(HttpServletRequest request,
            String parameter) {

        String value = request.getParameter(parameter);
        return value == null ? "" : value.trim();
    }

    private void redirectToLogin(HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        response.sendRedirect(request.getContextPath()
                + "/login.jsp?error=true&msg="
                + URLEncoder.encode("Please log in first.", "UTF-8"));
    }

    private void redirectWithMessage(HttpServletRequest request,
            HttpServletResponse response,
            String destination,
            String message) throws IOException {

        String separator = destination.contains("?") ? "&" : "?";

        response.sendRedirect(request.getContextPath()
                + destination
                + separator
                + "msg="
                + URLEncoder.encode(message, "UTF-8"));
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
