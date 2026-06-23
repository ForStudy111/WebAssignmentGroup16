<%-- 
    Document   : counsellor-form
    Created on : Jun 21, 2026
    Author     : wpy92
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Counsellor"%>

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
    Counsellor selectedCounsellor
            = (Counsellor) request.getAttribute("selectedCounsellor");
    User selectedUser = (User) request.getAttribute("selectedUser");

    boolean isEdit = "edit".equals(formMode);

    String pageTitle = isEdit ? "Edit Counsellor" : "Add Counsellor";
    String formAction = isEdit ? "update" : "create";

    String message = request.getParameter("msg");

    String fullNameValue = isEdit && selectedUser != null
            && selectedUser.getFullName() != null
            ? selectedUser.getFullName() : "";

    String usernameValue = isEdit && selectedUser != null
            && selectedUser.getUsername() != null
            ? selectedUser.getUsername() : "";

    String emailValue = isEdit && selectedUser != null
            && selectedUser.getEmail() != null
            ? selectedUser.getEmail() : "";

    String phoneValue = isEdit && selectedUser != null
            && selectedUser.getPhoneNumber() != null
            ? selectedUser.getPhoneNumber() : "";

    String specializationValue = isEdit && selectedCounsellor != null
            && selectedCounsellor.getSpecialization() != null
            ? selectedCounsellor.getSpecialization() : "";

    String officeLocationValue = isEdit && selectedCounsellor != null
            && selectedCounsellor.getOfficeLocation() != null
            ? selectedCounsellor.getOfficeLocation() : "";
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
                        <a href="<%= request.getContextPath()%>/UserServlet?action=list">
                            Manage Users
                        </a>
                    </li>

                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/CounsellorServlet?action=list">
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
                                    ? "Update the counsellor account and profile."
                                    : "Create a counsellor login account and professional profile."%>
                        </p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-error">
                    <%= message%>
                </div>
                <% }%>

                <section class="card">
                    <form action="<%= request.getContextPath()%>/CounsellorServlet"
                          method="post"
                          class="validate-form"
                          novalidate>

                        <input type="hidden"
                               name="action"
                               value="<%= formAction%>">

                        <% if (isEdit && selectedCounsellor != null) {%>
                        <input type="hidden"
                               name="counsellorId"
                               value="<%= selectedCounsellor.getCounsellorId()%>">
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

                            <div class="form-group">
                                <label for="specialization">Specialization *</label>

                                <input type="text"
                                       id="specialization"
                                       name="specialization"
                                       placeholder="Example: Academic Stress"
                                       required
                                       data-label="Specialization"
                                       value="<%= specializationValue%>">
                            </div>

                            <div class="form-group full-width">
                                <label for="officeLocation">Office Location</label>

                                <input type="text"
                                       id="officeLocation"
                                       name="officeLocation"
                                       placeholder="Example: Block C, Room 203"
                                       data-label="Office location"
                                       value="<%= officeLocationValue%>">
                            </div>

                        </div>

                        <% if (isEdit) { %>
                        <p class="form-help">
                            Password changes are not included on this form.
                        </p>
                        <% }%>

                        <div class="form-actions">
                            <button type="submit" class="primary-button">
                                <%= isEdit ? "Update Counsellor" : "Create Counsellor"%>
                            </button>

                            <a class="secondary-button"
                               href="<%= request.getContextPath()%>/CounsellorServlet?action=list">
                                Cancel
                            </a>
                        </div>
                    </form>
                </section>
            </main>
        </div>

        <script src="<%= request.getContextPath()%>/js/validation.js?v=phone-password-v2"></script>
    </body>
</html>
