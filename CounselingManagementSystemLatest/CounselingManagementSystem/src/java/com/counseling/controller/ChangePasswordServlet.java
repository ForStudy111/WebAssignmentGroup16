package com.counseling.controller;

import com.counseling.dao.UserDAO;
import com.counseling.model.User;
import java.io.IOException;
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

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        request.getRequestDispatcher("/change-password.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
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

        User verifiedUser = userDAO.authenticate(username, currentPassword);

        if (verifiedUser == null) {
            redirectWithMessage(request, response,
                    "/ChangePasswordServlet",
                    "Your current password is incorrect.");
            return;
        }

        if (!isValidPassword(newPassword)) {
            redirectWithMessage(request, response,
                    "/ChangePasswordServlet",
                    "New password must have at least 6 characters, including a letter and a number.");
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

    private boolean isValidPassword(String password) {
        return password.matches("^(?=.*[A-Za-z])(?=.*\\d)\\S{6,}$");
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

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg="
                + URLEncoder.encode("Please log in first.", "UTF-8")
        );
    }

    private void redirectWithMessage(HttpServletRequest request,
            HttpServletResponse response,
            String destination,
            String message) throws IOException {

        String separator = destination.contains("?") ? "&" : "?";

        response.sendRedirect(
                request.getContextPath()
                + destination
                + separator
                + "msg="
                + URLEncoder.encode(message, "UTF-8")
        );
    }

    @Override
    public String getServletInfo() {
        return "Change password servlet";
    }
}
