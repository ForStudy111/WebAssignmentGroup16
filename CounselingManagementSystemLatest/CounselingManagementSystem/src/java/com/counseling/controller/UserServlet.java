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
import javax.servlet.http.HttpSession;

/**
 *
 * @author wpy92
 */
@WebServlet("/UserServlet")
public class UserServlet extends HttpServlet {

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
            out.println("<title>Servlet UserServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet UserServlet at " + request.getContextPath() + "</h1>");
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

        String action = request.getParameter("action");

        if (action == null || action.isEmpty()) {
            action = "list";
        }
        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }
        switch (action) {
            case "list":
                showUserList(request, response, currentUser);
                break;
            case "new":
                showCreateUserForm(request, response, currentUser);
                break;
            case "edit":
                showEditUserForm(request, response, currentUser);
                break;
            case "profile":
                showProfile(request, response, currentUser);
                break;
            case "delete":
                deleteUser(request, response, currentUser);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/UserServlet?action=list");
        }
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

        String action = request.getParameter("action");

        User currentUser = getCurrentUser(request);
        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if ("create".equals(action)) {
            createUser(request, response, currentUser);

        } else if ("update".equals(action)) {
            updateUserByAdmin(request, response, currentUser);

        } else if ("updateProfile".equals(action)) {
            updateOwnProfile(request, response, currentUser);

        } else {
            response.sendRedirect(request.getContextPath() + "/UserServlet?action=list");

        }
    }

    private void showUserList(HttpServletRequest request, HttpServletResponse response, User currentUser) throws ServletException, IOException {
        if (!"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            redirectToLogin(request, response);
            return;
        }
        request.setAttribute("userList", userDAO.getAllUsers());
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    private void showCreateUserForm(HttpServletRequest request, HttpServletResponse response, User currentUser) throws ServletException, IOException {
        if (!"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            redirectToLogin(request, response);
            return;
        }
        request.setAttribute("formMode", "create");
        request.getRequestDispatcher("/admin/user-form.jsp").forward(request, response);
    }

    private void showEditUserForm(HttpServletRequest request, HttpServletResponse response, User currentUser) throws ServletException, IOException {
        if (!"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            redirectToLogin(request, response);
            return;
        }
        int userId = getIntParameter(request, "id");
        if (userId <= 0) {
            response.sendRedirect(request.getContextPath() + "/UserServlet?action=list");
            return;
        }
        User user = userDAO.getUserById(userId);
        if (user == null) {
            redirectWithMessage(request, response, "/UserServlet?action=list", "User was not found.");
            return;
        }
        request.setAttribute("selectedUser", user);
        request.setAttribute("formMode", "edit");
        request.getRequestDispatcher("/admin/user-form.jsp").forward(request, response);
    }

    private void showProfile(HttpServletRequest request, HttpServletResponse response, User currentUser) throws ServletException, IOException {
        request.setAttribute("selectedUser", currentUser);
        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }

    private void createUser(HttpServletRequest request, HttpServletResponse response, User currentUser) throws IOException {
        if (!"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            redirectToLogin(request, response);
            return;
        }
        String username = getValue(request, "username");
        String password = getValue(request, "password");
        String fullName = getValue(request, "fullName");
        String email = getValue(request, "email");
        String phoneNumber = getValue(request, "phoneNumber");
        String role = getValue(request, "role");
        if (username.isEmpty() || password.isEmpty() || fullName.isEmpty() || email.isEmpty() || role.isEmpty()) {
            redirectWithMessage(request, response, "/UserServlet?action=new", "Please complete all required fields.");
            return;
        }
        if (password.length() < 6) {
            redirectWithMessage(request, response, "/UserServlet?action=new", "Password must contain at least 6 characters.");
            return;
        }
        if (userDAO.isUsernameExists(username)) {
            redirectWithMessage(request, response, "/UserServlet?action=new", "This username already exists.");
            return;
        }
        User user = new User(username, password, fullName, email, phoneNumber, role);
        if (userDAO.addUser(user)) {
            redirectWithMessage(request, response, "/UserServlet?action=list", "User created successfully.");
        } else {
            redirectWithMessage(request, response, "/UserServlet?action=new", "User creation failed. The email may already exist.");
        }
    }

    private void updateUserByAdmin(HttpServletRequest request, HttpServletResponse response, User currentUser) throws IOException {
        if (!"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            redirectToLogin(request, response);
            return;
        }
        int userId = getIntParameter(request, "userId");
        User user = new User();
        user.setUserId(userId);
        user.setUsername(getValue(request, "username"));
        user.setFullName(getValue(request, "fullName"));
        user.setEmail(getValue(request, "email"));
        user.setPhoneNumber(getValue(request, "phoneNumber"));
        user.setRole(getValue(request, "role"));
        if (userId <= 0 || user.getUsername().isEmpty() || user.getFullName().isEmpty() || user.getEmail().isEmpty() || user.getRole().isEmpty()) {
            redirectWithMessage(request, response, "/UserServlet?action=edit&id=" + userId, "Please complete all required fields.");
            return;
        }
        if (userDAO.updateUser(user)) {
            redirectWithMessage(request, response, "/UserServlet?action=list", "User updated successfully.");
        } else {
            redirectWithMessage(request, response, "/UserServlet?action=edit&id=" + userId, "User update failed. Username or email may already exist.");
        }
    }

    private void updateOwnProfile(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser) throws IOException {

        User savedUser = userDAO.getUserById(currentUser.getUserId());

        if (savedUser == null) {
            redirectWithMessage(request, response,
                    "/UserServlet?action=profile",
                    "Your user account could not be found.");
            return;
        }

        /*
     Keep username and role from the database.
     A user may update only their own personal details.
         */
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

    private void deleteUser(HttpServletRequest request, HttpServletResponse response, User currentUser) throws IOException {
        if (!"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            redirectToLogin(request, response);
            return;
        }
        int userId = getIntParameter(request, "id");
        if (userId == currentUser.getUserId()) {
            redirectWithMessage(request, response, "/UserServlet?action=list", "You cannot delete your own admin account.");
            return;
        }
        if (userId > 0 && userDAO.deleteUser(userId)) {
            redirectWithMessage(request, response, "/UserServlet?action=list", "User deleted successfully.");
        } else {
            redirectWithMessage(request, response, "/UserServlet?action=list", "User deletion failed.");
        }
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute("currentUser");
    }

    private int getIntParameter(HttpServletRequest request, String parameter) {
        try {
            return Integer.parseInt(request.getParameter(parameter));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String getValue(HttpServletRequest request, String parameter) {
        String value = request.getParameter(parameter);
        return value == null ? "" : value.trim();
    }

    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=true&msg=" + URLEncoder.encode("Please log in first.", "UTF-8"));
    }

    private void redirectWithMessage(HttpServletRequest request, HttpServletResponse response, String destination, String message) throws IOException {
        String separator = destination.contains("?") ? "&" : "?";
        response.sendRedirect(request.getContextPath() + destination + separator + "msg=" + URLEncoder.encode(message, "UTF-8"));
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
