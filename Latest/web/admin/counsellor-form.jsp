<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Counsellor"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null
            || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg=Please+log+in+as+an+admin.");
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

    String counsellorIdValue = isEdit && selectedUser != null
            && selectedUser.getUsername() != null
            ? selectedUser.getUsername().toUpperCase() : "";

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
                            Student List
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
                                    ? "Update the counsellor profile. The Counsellor ID follows the email address."
                                    : "Create a counsellor account and profile. The Counsellor ID is generated from the email address."%>
                        </p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success"><%= message%></div>
                <% }%>

                <section class="card form-card">
                    <form class="validate-form"
                          novalidate
                          method="post"
                          action="<%= request.getContextPath()%>/CounsellorServlet">

                        <input type="hidden" name="action" value="<%= formAction%>">

                        <% if (isEdit && selectedCounsellor != null) {%>
                        <input type="hidden"
                               name="counsellorId"
                               value="<%= selectedCounsellor.getCounsellorId()%>">
                        <% }%>

                        <div class="form-group">
                            <label for="counsellorIdPreview">Counsellor ID</label>
                            <input type="text"
                                   id="counsellorIdPreview"
                                   value="<%= counsellorIdValue%>"
                                   placeholder="Generated from email"
                                   readonly>
                        </div>

                        <div class="form-group">
                            <label for="fullName">Full Name *</label>
                            <input type="text"
                                   id="fullName"
                                   name="fullName"
                                   value="<%= fullNameValue%>"
                                   required
                                   data-label="Full name">
                        </div>

                        <div class="form-group">
                            <label for="email">Email *</label>
                            <input type="email"
                                   id="email"
                                   name="email"
                                   value="<%= emailValue%>"
                                   required
                                   data-label="Email"
                                   oninput="updateCounsellorId()">
                        </div>

                        <div class="form-group">
                            <label for="phoneNumber">Phone Number</label>
                            <input type="text"
                                   id="phoneNumber"
                                   name="phoneNumber"
                                   value="<%= phoneValue%>"
                                   placeholder="012-3456789"
                                   data-validation="phone"
                                   data-label="Phone number">
                        </div>

                        <% if (!isEdit) { %>
                        <div class="form-group">
                            <label for="password">Password *</label>
                            <input type="password"
                                   id="password"
                                   name="password"
                                   required
                                   data-password="true"
                                   data-label="Password">
                        </div>
                        <% }%>

                        <div class="form-group">
                            <label for="specialization">Specialization *</label>
                            <input type="text"
                                   id="specialization"
                                   name="specialization"
                                   value="<%= specializationValue%>"
                                   required
                                   data-label="Specialization">
                        </div>

                        <div class="form-group">
                            <label for="officeLocation">Office Location</label>
                            <input type="text"
                                   id="officeLocation"
                                   name="officeLocation"
                                   value="<%= officeLocationValue%>">
                        </div>

                        <% if (isEdit) { %>
                        <p class="form-help">
                            Password changes are handled separately.
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

        <script>
            function updateCounsellorId() {
                var emailInput = document.getElementById("email");
                var idPreview = document.getElementById("counsellorIdPreview");

                if (!emailInput || !idPreview) {
                    return;
                }

                var email = emailInput.value.trim();
                var atIndex = email.indexOf("@");

                if (atIndex > 0) {
                    idPreview.value = email.substring(0, atIndex).toUpperCase();
                } else {
                    idPreview.value = "";
                }
            }

            document.addEventListener("DOMContentLoaded", updateCounsellorId);
        </script>

        <script src="<%= request.getContextPath()%>/js/validation.js"></script>
    </body>
</html>
