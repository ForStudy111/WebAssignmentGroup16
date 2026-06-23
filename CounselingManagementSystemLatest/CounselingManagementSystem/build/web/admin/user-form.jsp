<%-- 
    Document   : user-form
    Created on : Jun 21, 2026
    Author     : wpy92
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null
            || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg=Please+log+in+as+an+admin."
        );
        return;
    }

    String formMode = (String) request.getAttribute("formMode");
    User selectedUser = (User) request.getAttribute("selectedUser");

    boolean isEdit = "edit".equals(formMode);

    String pageTitle = isEdit ? "Edit User" : "Add User";
    String action = isEdit ? "update" : "create";

    String message = request.getParameter("msg");

    String fullNameValue = isEdit && selectedUser.getFullName() != null
            ? selectedUser.getFullName() : "";

    String usernameValue = isEdit && selectedUser.getUsername() != null
            ? selectedUser.getUsername() : "";

    String emailValue = isEdit && selectedUser.getEmail() != null
            ? selectedUser.getEmail() : "";

    String phoneValue = isEdit && selectedUser.getPhoneNumber() != null
            ? selectedUser.getPhoneNumber() : "";
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title><%= pageTitle%> | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/admin.css">

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/validation.css">
    </head>

    <body class="dashboard-page">
        <div class="dashboard-layout">

            <aside class="sidebar">
                <h2 class="sidebar-brand">Admin Portal</h2>

                <ul class="sidebar-menu">
                    <li>
                        <a href="<%= request.getContextPath()%>/admin/dashboard.jsp">
                            Dashboard
                        </a>
                    </li>

                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/UserServlet?action=list">
                            Manage Users
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/CounsellorServlet?action=list">
                            Manage Counsellors
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/BookingServlet?action=adminList">
                            View Bookings
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/UserServlet?action=profile">
                            My Profile
                        </a>
                    </li>

                    <li>
                        <a class="logout-link"
                           href="<%= request.getContextPath()%>/LogoutServlet">
                            Logout
                        </a>
                    </li>
                </ul>
            </aside>

            <main class="main-content">

                <div class="page-header">
                    <div>
                        <h1><%= pageTitle%></h1>
                        <p>
                            <%= isEdit
                                    ? "Update the selected user account."
                                    : "Create a new student or administrator account."%>
                        </p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-error">
                    <%= message%>
                </div>
                <% }%>

                <section class="card">
                    <form action="<%= request.getContextPath()%>/UserServlet"
                          method="post"
                          class="validate-form"
                          novalidate>

                        <input type="hidden" name="action" value="<%= action%>">

                        <% if (isEdit) {%>
                        <input type="hidden" name="userId"
                               value="<%= selectedUser.getUserId()%>">
                        <% }%>

                        <div class="form-grid">

                            <div class="form-group">
                                <label for="fullName">Full Name *</label>

                                <input type="text"
                                       id="fullName"
                                       name="fullName"
                                       required
                                       data-label="Full name"
                                       value="<%= fullNameValue%>">
                            </div>

                            <div class="form-group">
                                <label for="username">Username *</label>

                                <input type="text"
                                       id="username"
                                       name="username"
                                       required
                                       data-label="Username"
                                       value="<%= usernameValue%>">
                            </div>

                            <div class="form-group">
                                <label for="email">Email *</label>

                                <input type="email"
                                       id="email"
                                       name="email"
                                       required
                                       data-label="Email address"
                                       value="<%= emailValue%>">
                            </div>

                            <div class="form-group">
                                <label for="phoneNumber">Phone Number</label>

                                <input type="tel"
                                       id="phoneNumber"
                                       name="phoneNumber"
                                       data-label="Phone number"
                                       data-validation="phone"
                                       value="<%= phoneValue%>">
                            </div>

                            <% if (!isEdit) { %>
                            <div class="form-group">
                                <label for="password">Password *</label>

                                <input type="password"
                                       id="password"
                                       name="password"
                                       required
                                       data-label="Password"
                                       data-password="true">
                            </div>
                            <% }%>

                            <input type="hidden" id="role" name="role" value="STUDENT">

                        </div>

                        <% if (isEdit) { %>
                        <p style="margin-top: 16px; color: #718096; font-size: 13px;">
                            Password changes are handled separately.
                        </p>
                        <% }%>

                        <div class="form-actions">
                            <button type="submit" class="primary-button">
                                <%= isEdit ? "Update User" : "Create User"%>
                            </button>

                            <a class="secondary-button"
                               href="<%= request.getContextPath()%>/UserServlet?action=list">
                                Cancel
                            </a>
                        </div>
                    </form>
                </section>
            </main>
        </div>

        <script src="<%= request.getContextPath()%>/js/validation.js"></script>
    </body>
</html>
