package com.counseling.controller;

import com.counseling.dao.CounsellorDAO;
import com.counseling.dao.UserDAO;
import com.counseling.model.Counsellor;
import com.counseling.model.User;
import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/CounsellorServlet")
public class CounsellorServlet extends HttpServlet {

    private final CounsellorDAO counsellorDAO = new CounsellorDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (!isAdmin(currentUser)) {
            redirectToLogin(request, response);
            return;
        }

        String action = getValue(request, "action");

        if (action.isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "list":
                showCounsellorList(request, response);
                break;

            case "new":
                showCreateForm(request, response);
                break;

            case "edit":
                showEditForm(request, response);
                break;

            case "delete":
                deleteCounsellor(request, response);
                break;

            default:
                response.sendRedirect(
                        request.getContextPath()
                        + "/CounsellorServlet?action=list");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (!isAdmin(currentUser)) {
            redirectToLogin(request, response);
            return;
        }

        String action = getValue(request, "action");

        if ("create".equals(action)) {
            createCounsellor(request, response);

        } else if ("update".equals(action)) {
            updateCounsellor(request, response);

        } else {
            response.sendRedirect(
                    request.getContextPath()
                    + "/CounsellorServlet?action=list");
        }
    }

    private void showCounsellorList(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("counsellorList",
                counsellorDAO.getAllCounsellors());

        request.getRequestDispatcher("/admin/counsellors.jsp")
                .forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("formMode", "create");

        request.getRequestDispatcher("/admin/counsellor-form.jsp")
                .forward(request, response);
    }

    private void showEditForm(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        int counsellorId = getIntParameter(request, "id");
        Counsellor counsellor = counsellorDAO.getCounsellorById(counsellorId);

        if (counsellor == null) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=list",
                    "Counsellor was not found.");
            return;
        }

        User linkedUser = userDAO.getUserById(counsellor.getUserId());

        if (linkedUser == null) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=list",
                    "Linked counsellor account was not found.");
            return;
        }

        request.setAttribute("formMode", "edit");
        request.setAttribute("selectedCounsellor", counsellor);
        request.setAttribute("selectedUser", linkedUser);

        request.getRequestDispatcher("/admin/counsellor-form.jsp")
                .forward(request, response);
    }

    private void createCounsellor(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String fullName = getValue(request, "fullName");
        String password = getValue(request, "password");
        String email = getValue(request, "email");
        String phoneNumber = getValue(request, "phoneNumber");
        String specialization = getValue(request, "specialization");
        String officeLocation = getValue(request, "officeLocation");

        String generatedUsername = generateUsernameFromEmail(email);

        if (fullName.isEmpty() || password.isEmpty()
                || email.isEmpty() || specialization.isEmpty()) {

            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=new",
                    "Please complete all required fields.");
            return;
        }

        if (!isValidEmail(email) || generatedUsername.isEmpty()) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=new",
                    "Enter a valid email address.");
            return;
        }

        if (!isValidPhoneNumber(phoneNumber)) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=new",
                    "Use Malaysian mobile format: "
                    + "012-3456789 or 011-12345678.");
            return;
        }

        if (!isValidPassword(password)) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=new",
                    "Password must have at least 6 characters, "
                    + "including a letter and a number.");
            return;
        }

        if (userDAO.isUsernameExists(generatedUsername)) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=new",
                    "Counsellor ID " + generatedUsername
                    + " already exists. Use a different email address.");
            return;
        }

        User user = new User(
                generatedUsername,
                password,
                fullName,
                email,
                phoneNumber,
                "COUNSELOR"
        );

        Counsellor counsellor = new Counsellor(
                0,
                fullName,
                specialization,
                email,
                phoneNumber,
                officeLocation
        );

        if (counsellorDAO.createCounsellor(user, counsellor)) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=list",
                    "Counsellor created successfully. "
                    + "Counsellor ID: " + generatedUsername);
        } else {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=new",
                    "Counsellor creation failed. "
                    + "Email may already exist.");
        }
    }

    private void updateCounsellor(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        int counsellorId = getIntParameter(request, "counsellorId");
        Counsellor counsellor = counsellorDAO.getCounsellorById(counsellorId);

        if (counsellor == null) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=list",
                    "Counsellor was not found.");
            return;
        }

        User user = userDAO.getUserById(counsellor.getUserId());

        if (user == null) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=list",
                    "Linked counsellor account was not found.");
            return;
        }

        String fullName = getValue(request, "fullName");
        String email = getValue(request, "email");
        String phoneNumber = getValue(request, "phoneNumber");
        String specialization = getValue(request, "specialization");
        String officeLocation = getValue(request, "officeLocation");

        String generatedUsername = generateUsernameFromEmail(email);

        if (fullName.isEmpty() || email.isEmpty()
                || specialization.isEmpty()) {

            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=edit&id=" + counsellorId,
                    "Please complete all required fields.");
            return;
        }

        if (!isValidEmail(email) || generatedUsername.isEmpty()) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=edit&id=" + counsellorId,
                    "Enter a valid email address.");
            return;
        }

        if (!isValidPhoneNumber(phoneNumber)) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=edit&id=" + counsellorId,
                    "Use Malaysian mobile format: "
                    + "012-3456789 or 011-12345678.");
            return;
        }

        if (userDAO.isUsernameExistsForAnotherUser(
                generatedUsername, user.getUserId())) {

            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=edit&id=" + counsellorId,
                    "Counsellor ID " + generatedUsername
                    + " already belongs to another account.");
            return;
        }

        user.setUsername(generatedUsername);
        user.setFullName(fullName);
        user.setEmail(email);
        user.setPhoneNumber(phoneNumber);
        user.setRole("COUNSELOR");

        counsellor.setCounsellorName(fullName);
        counsellor.setEmail(email);
        counsellor.setPhoneNumber(phoneNumber);
        counsellor.setSpecialization(specialization);
        counsellor.setOfficeLocation(officeLocation);

        boolean userUpdated = userDAO.updateUser(user);
        boolean counsellorUpdated = counsellorDAO.updateCounsellor(counsellor);

        if (userUpdated && counsellorUpdated) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=list",
                    "Counsellor updated successfully. "
                    + "Counsellor ID: " + generatedUsername);
        } else {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=edit&id=" + counsellorId,
                    "Counsellor update failed. "
                    + "Email may already exist.");
        }
    }

    private void deleteCounsellor(HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        int counsellorId = getIntParameter(request, "id");
        Counsellor counsellor = counsellorDAO.getCounsellorById(counsellorId);

        if (counsellor == null) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=list",
                    "Counsellor was not found.");
            return;
        }

        /*
         * Deleting the linked user cascades to the counsellor record
         * because the database foreign key uses ON DELETE CASCADE.
         */
        if (userDAO.deleteUser(counsellor.getUserId())) {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=list",
                    "Counsellor deleted successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/CounsellorServlet?action=list",
                    "Counsellor deletion failed.");
        }
    }

    private String generateUsernameFromEmail(String email) {
        if (email == null) {
            return "";
        }

        int atIndex = email.indexOf("@");

        if (atIndex <= 0) {
            return "";
        }

        return email.substring(0, atIndex).trim().toUpperCase();
    }

    private boolean isValidEmail(String email) {
        return email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    }

    private boolean isValidPhoneNumber(String phoneNumber) {
        return phoneNumber.isEmpty()
                || phoneNumber.matches("^01[0-9]-\\d{7,8}$");
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
                + URLEncoder.encode(
                        "Please log in as an admin first.", "UTF-8"));
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
        return "Counsellor management servlet";
    }
}
