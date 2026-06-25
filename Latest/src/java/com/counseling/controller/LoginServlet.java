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

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null
                || username.trim().isEmpty()
                || password.trim().isEmpty()) {

            redirectWithError(request, response,
                    "User ID and password cannot be empty.");
            return;
        }

        /*
         * The users.username column is now used as the visible User ID:
         * student ID, counsellor ID, or the manually prepared admin ID.
         */
        String userIdInput = username.trim().toUpperCase();

        User user = userDAO.authenticate(userIdInput, password.trim());

        if (user == null) {
            redirectWithError(request, response,
                    "Invalid User ID or password.");
            return;
        }

        HttpSession session = request.getSession(true);
        session.setAttribute("currentUser", user);
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("user", user.getUsername());
        session.setAttribute("role", user.getRole());

        String contextPath = request.getContextPath();
        String role = user.getRole();

        if ("ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect(contextPath + "/admin/dashboard.jsp");

        } else if ("STUDENT".equalsIgnoreCase(role)) {
            response.sendRedirect(contextPath + "/student/dashboard.jsp");

        } else if ("COUNSELOR".equalsIgnoreCase(role)) {
            response.sendRedirect(contextPath + "/counselor/dashboard.jsp");

        } else {
            session.invalidate();
            redirectWithError(request, response, "Your account role is not recognised.");
        }
    }

    private void redirectWithError(HttpServletRequest request,
            HttpServletResponse response, String message)
            throws IOException {

        String encodedMessage = URLEncoder.encode(message, "UTF-8");

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg="
                + encodedMessage);
    }
}
