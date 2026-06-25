<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null
            || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg=Please+log+in+as+an+admin.");
        return;
    }

    User selectedUser = (User) request.getAttribute("selectedUser");

    if (selectedUser == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/UserServlet?action=list");
        return;
    }

    String message = request.getParameter("msg");

    String studentId = selectedUser.getUsername() == null
            ? ""
            : selectedUser.getUsername().toUpperCase();

    String fullNameValue = selectedUser.getFullName() == null
            ? ""
            : selectedUser.getFullName();

    String emailValue = selectedUser.getEmail() == null
            ? ""
            : selectedUser.getEmail();

    String phoneValue = selectedUser.getPhoneNumber() == null
            ? ""
            : selectedUser.getPhoneNumber();
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Edit Student Phone Number | Counseling System</title>

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
                            Student List
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
                        <h1>Edit Student Phone Number</h1>
                        <p>
                            Student account details are maintained through the
                            university database. Only the phone number can be updated
                            in this system.
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
                          action="<%= request.getContextPath()%>/UserServlet">

                        <input type="hidden" name="action" value="update">
                        <input type="hidden"
                               name="userId"
                               value="<%= selectedUser.getUserId()%>">

                        <div class="form-group">
                            <label for="studentId">Student ID</label>
                            <input type="text"
                                   id="studentId"
                                   value="<%= studentId%>"
                                   readonly>
                        </div>

                        <div class="form-group">
                            <label for="fullName">Full Name</label>
                            <input type="text"
                                   id="fullName"
                                   value="<%= fullNameValue%>"
                                   readonly>
                        </div>

                        <div class="form-group">
                            <label for="email">Email</label>
                            <input type="email"
                                   id="email"
                                   value="<%= emailValue%>"
                                   readonly>
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

                        <div class="form-actions">
                            <button type="submit" class="primary-button">
                                Update Phone Number
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
