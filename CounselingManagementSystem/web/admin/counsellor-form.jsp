<%-- 
    Document   : counsellor-form
    Created on : Jun 21, 2026, 4:41:33 AM
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
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title><%= pageTitle%> | Counseling System</title>

        <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin.css">

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
                        <a href="<%= request.getContextPath()%>/admin/bookings.jsp">
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
                          onsubmit="return validateCounsellorForm();">

                        <input type="hidden"
                               name="action"
                               value="<%= formAction%>">

                        <% if (isEdit) {%>
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
                                       value="<%= isEdit ? selectedUser.getFullName() : ""%>">
                            </div>

                            <div class="form-group">
                                <label for="username">Username *</label>
                                <input type="text"
                                       id="username"
                                       name="username"
                                       required
                                       value="<%= isEdit ? selectedUser.getUsername() : ""%>">
                            </div>

                            <div class="form-group">
                                <label for="email">Email *</label>
                                <input type="email"
                                       id="email"
                                       name="email"
                                       required
                                       value="<%= isEdit ? selectedUser.getEmail() : ""%>">
                            </div>

                            <div class="form-group">
                                <label for="phoneNumber">Phone Number</label>
                                <input type="tel"
                                       id="phoneNumber"
                                       name="phoneNumber"
                                       value="<%= isEdit && selectedUser.getPhoneNumber() != null
                                               ? selectedUser.getPhoneNumber()
                                               : ""%>">
                            </div>

                            <% if (!isEdit) { %>
                            <div class="form-group">
                                <label for="password">Password *</label>
                                <input type="password"
                                       id="password"
                                       name="password"
                                       minlength="6"
                                       required>
                            </div>
                            <% }%>

                            <div class="form-group">
                                <label for="specialization">Specialization *</label>
                                <input type="text"
                                       id="specialization"
                                       name="specialization"
                                       placeholder="Example: Academic Stress"
                                       required
                                       value="<%= isEdit
                                               ? selectedCounsellor.getSpecialization()
                                               : ""%>">
                            </div>

                            <div class="form-group full-width">
                                <label for="officeLocation">Office Location</label>
                                <input type="text"
                                       id="officeLocation"
                                       name="officeLocation"
                                       placeholder="Example: Block C, Room 203"
                                       value="<%= isEdit
                                               && selectedCounsellor.getOfficeLocation() != null
                                               ? selectedCounsellor.getOfficeLocation()
                                               : ""%>">
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

        <script>
            function validateCounsellorForm() {
                const email = document.getElementById("email").value.trim();

                if (!email.includes("@")) {
                    alert("Please enter a valid email address.");
                    return false;
                }

                return true;
            }
        </script>
    </body>
</html>
