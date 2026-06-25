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

@WebServlet("/UserServlet")
public class UserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String action = getValue(request, "action");

        if (action.isEmpty()) {
            action = "list";
        }

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        switch (action) {
            case "list":
                showStudentList(request, response, currentUser);
                break;

            case "edit":
                showEditStudentForm(request, response, currentUser);
                break;

            case "profile":
                showProfile(request, response);
                break;

            /*
             * There is deliberately no "new" or "delete" action.
             * Student accounts are prepared in the database.
             */
            default:
                response.sendRedirect(
                        request.getContextPath()
                        + "/UserServlet?action=list");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = getValue(request, "action");
        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if ("update".equals(action)) {
            updateStudentPhoneByAdmin(request, response, currentUser);

        } else if ("updateProfile".equals(action)) {
            updateOwnProfile(request, response, currentUser);

        } else {
            response.sendRedirect(
                    request.getContextPath()
                    + "/UserServlet?action=list");
        }
    }

    private void showStudentList(HttpServletRequest request,
            HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!isAdmin(currentUser)) {
            redirectToLogin(request, response);
            return;
        }

        request.setAttribute("userList", userDAO.getStudents());
        request.getRequestDispatcher("/admin/users.jsp")
                .forward(request, response);
    }

    private void showEditStudentForm(HttpServletRequest request,
            HttpServletResponse response, User currentUser)
            throws ServletException, IOException {

        if (!isAdmin(currentUser)) {
            redirectToLogin(request, response);
            return;
        }

        int userId = getIntParameter(request, "id");

        if (userId <= 0) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/UserServlet?action=list");
            return;
        }

        User user = userDAO.getUserById(userId);

        if (user == null || !"STUDENT".equalsIgnoreCase(user.getRole())) {
            redirectWithMessage(request, response,
                    "/UserServlet?action=list",
                    "Student record was not found.");
            return;
        }

        request.setAttribute("selectedUser", user);
        request.getRequestDispatcher("/admin/user-form.jsp")
                .forward(request, response);
    }

    private void updateStudentPhoneByAdmin(HttpServletRequest request,
            HttpServletResponse response, User currentUser)
            throws IOException {

        if (!isAdmin(currentUser)) {
            redirectToLogin(request, response);
            return;
        }

        int userId = getIntParameter(request, "userId");
        String phoneNumber = getValue(request, "phoneNumber");

        User student = userDAO.getUserById(userId);

        if (student == null
                || !"STUDENT".equalsIgnoreCase(student.getRole())) {
            redirectWithMessage(request, response,
                    "/UserServlet?action=list",
                    "Student record was not found.");
            return;
        }

        if (!isValidPhoneNumber(phoneNumber)) {
            redirectWithMessage(request, response,
                    "/UserServlet?action=edit&id=" + userId,
                    "Use Malaysian mobile format: "
                    + "012-3456789 or 011-12345678.");
            return;
        }

        if (userDAO.updateStudentPhone(userId, phoneNumber)) {
            redirectWithMessage(request, response,
                    "/UserServlet?action=list",
                    "Student phone number updated successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/UserServlet?action=edit&id=" + userId,
                    "Student phone number update failed.");
        }
    }

    private void showProfile(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);
        request.setAttribute("selectedUser", currentUser);

        request.getRequestDispatcher("/profile.jsp")
                .forward(request, response);
    }

    /*
     * This remains for each logged-in user's My Profile page.
     * The Admin Student List is separately restricted to phone-number updates.
     */
    private void updateOwnProfile(HttpServletRequest request,
            HttpServletResponse response, User currentUser)
            throws IOException {

        User savedUser = userDAO.getUserById(currentUser.getUserId());

        if (savedUser == null) {
            redirectWithMessage(request, response,
                    "/UserServlet?action=profile",
                    "Your user account could not be found.");
            return;
        }

        currentUser.setUsername(savedUser.getUsername());
        currentUser.setRole(savedUser.getRole());
        currentUser.setFullName(getValue(request, "fullName"));
        currentUser.setEmail(getValue(request, "email"));
        currentUser.setPhoneNumber(getValue(request, "phoneNumber"));

        if (currentUser.getFullName().isEmpty()
                || currentUser.getEmail().isEmpty()
                || currentUser.getPhoneNumber().isEmpty()) {

            redirectWithMessage(request, response,
                    "/UserServlet?action=profile",
                    "Please complete all required fields.");
            return;
        }

        if (!isValidPhoneNumber(currentUser.getPhoneNumber())) {
            redirectWithMessage(request, response,
                    "/UserServlet?action=profile",
                    "Use Malaysian mobile format: "
                    + "012-3456789 or 011-12345678.");
            return;
        }

        if (userDAO.updateUser(currentUser)) {
            HttpSession session = request.getSession();
            session.setAttribute("currentUser", currentUser);
            session.setAttribute("user", currentUser.getUsername());

            redirectWithMessage(request, response,
                    "/UserServlet?action=profile",
                    "Profile updated successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/UserServlet?action=profile",
                    "Profile update failed. Email may already exist.");
        }
    }

    private boolean isValidPhoneNumber(String phoneNumber) {
        return phoneNumber.isEmpty()
                || phoneNumber.matches("^01[0-9]-\\d{7,8}$");
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        return (User) session.getAttribute("currentUser");
    }

    private boolean isAdmin(User user) {
        return user != null
                && "ADMIN".equalsIgnoreCase(user.getRole());
    }

    private int getIntParameter(HttpServletRequest request,
            String parameter) {
        try {
            return Integer.parseInt(request.getParameter(parameter));
        } catch (NumberFormatException e) {
            return 0;
        }
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
                + URLEncoder.encode("Please log in first.", "UTF-8"));
    }

    private void redirectWithMessage(HttpServletRequest request,
            HttpServletResponse response, String destination,
            String message) throws IOException {

        String separator = destination.contains("?") ? "&" : "?";

        response.sendRedirect(
                request.getContextPath()
                + destination
                + separator
                + "msg="
                + URLEncoder.encode(message, "UTF-8"));
    }

    @Override
    public String getServletInfo() {
        return "Student list and profile servlet";
    }
}
