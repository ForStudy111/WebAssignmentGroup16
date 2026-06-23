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

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/register.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = getValue(request, "fullName");
        String username = getValue(request, "username");
        String email = getValue(request, "email");
        String phoneNumber = getValue(request, "phoneNumber");
        String password = getValue(request, "password");
        String confirmPassword = getValue(request, "confirmPassword");

        if (fullName.isEmpty()
                || username.isEmpty()
                || email.isEmpty()
                || password.isEmpty()
                || confirmPassword.isEmpty()) {

            redirectWithMessage(request, response,
                    "All required fields must be completed.", "error");
            return;
        }

        if (!isValidPhoneNumber(phoneNumber)) {
            redirectWithMessage(request, response,
                    "Use Malaysian mobile format: 012-3456789 or 011-12345678.",
                    "error");
            return;
        }

        if (!isValidPassword(password)) {
            redirectWithMessage(request, response,
                    "Password must have at least 6 characters, including a letter and a number.",
                    "error");
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

        if (userDAO.addUser(student)) {
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

    private boolean isValidPhoneNumber(String phoneNumber) {
        return phoneNumber.isEmpty()
                || phoneNumber.matches("^01[0-9]-\\d{7,8}$");
    }

    private boolean isValidPassword(String password) {
        return password.matches("^(?=.*[A-Za-z])(?=.*\\d)\\S{6,}$");
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

    @Override
    public String getServletInfo() {
        return "Student registration servlet";
    }
}
