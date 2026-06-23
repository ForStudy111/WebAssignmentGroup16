<%-- 
    Document   : change-password
    Created on : Jun 12, 2026
    Author     : wpy92
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg=Please+log+in+first."
        );
        return;
    }

    String cssFile = "student.css";
    String dashboardPath = "/student/dashboard.jsp";

    if ("ADMIN".equalsIgnoreCase(currentUser.getRole())) {
        cssFile = "admin.css";
        dashboardPath = "/admin/dashboard.jsp";

    } else if ("COUNSELOR".equalsIgnoreCase(currentUser.getRole())) {
        cssFile = "counselor.css";
        dashboardPath = "/counselor/dashboard.jsp";
    }

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Change Password | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/<%= cssFile%>">

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/validation.css">
    </head>

    <body class="dashboard-page">
        <div class="dashboard-layout">

            <aside class="sidebar">

                <% if ("ADMIN".equalsIgnoreCase(currentUser.getRole())) {%>

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
                        <a class="active"
                           href="<%= request.getContextPath()%>/ChangePasswordServlet">
                            Change Password
                        </a>
                    </li>

                    <li>
                        <a class="logout-link"
                           href="<%= request.getContextPath()%>/LogoutServlet">
                            Logout
                        </a>
                    </li>
                </ul>

                <% } else if ("COUNSELOR".equalsIgnoreCase(currentUser.getRole())) {%>

                <h2 class="sidebar-brand">Counsellor Portal</h2>

                <ul class="sidebar-menu">
                    <li>
                        <a href="<%= request.getContextPath()%>/counselor/dashboard.jsp">
                            Dashboard
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/ScheduleServlet?action=list">
                            Manage Availability
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/BookingServlet?action=counsellorList">
                            Manage Bookings
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/SessionRecordServlet?action=counsellorList">
                            Session Records
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/UserServlet?action=profile">
                            My Profile
                        </a>
                    </li>

                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/ChangePasswordServlet">
                            Change Password
                        </a>
                    </li>

                    <li>
                        <a class="logout-link"
                           href="<%= request.getContextPath()%>/LogoutServlet">
                            Logout
                        </a>
                    </li>
                </ul>

                <% } else {%>

                <h2 class="sidebar-brand">Student Care</h2>

                <ul class="sidebar-menu">
                    <li>
                        <a href="<%= request.getContextPath()%>/student/dashboard.jsp">
                            My Dashboard
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/BookingServlet?action=available">
                            Book Session
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/BookingServlet?action=myBookings">
                            My Bookings
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/SessionRecordServlet?action=studentHistory">
                            Session History
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/UserServlet?action=profile">
                            My Profile
                        </a>
                    </li>

                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/ChangePasswordServlet">
                            Change Password
                        </a>
                    </li>

                    <li>
                        <a class="logout-link"
                           href="<%= request.getContextPath()%>/LogoutServlet">
                            Sign Out
                        </a>
                    </li>
                </ul>

                <% } %>

            </aside>

            <main class="main-content">

                <div class="page-header">
                    <div>
                        <h1>Change Password</h1>
                        <p>
                            Use at least 6 characters, including one letter and one number.
                            Spaces are not allowed.
                        </p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-error">
                    <%= message%>
                </div>
                <% }%>

                <section class="card">
                    <h2 class="card-title">Password Information</h2>

                    <form action="<%= request.getContextPath()%>/ChangePasswordServlet"
                          method="post"
                          class="validate-form"
                          novalidate>

                        <div class="form-grid">

                            <div class="form-group full-width">
                                <label for="currentPassword">Current Password *</label>

                                <input type="password"
                                       id="currentPassword"
                                       name="currentPassword"
                                       required
                                       data-label="Current password">
                            </div>

                            <div class="form-group">
                                <label for="newPassword">New Password *</label>

                                <input type="password"
                                       id="newPassword"
                                       name="newPassword"
                                       required
                                       data-label="New password"
                                       data-password="true">
                            </div>

                            <div class="form-group">
                                <label for="confirmPassword">
                                    Confirm New Password *
                                </label>

                                <input type="password"
                                       id="confirmPassword"
                                       name="confirmPassword"
                                       required
                                       data-label="Confirm new password"
                                       data-match="newPassword">
                            </div>

                        </div>

                        <div class="form-actions">
                            <button type="submit" class="primary-button">
                                Update Password
                            </button>

                            <a class="secondary-button"
                               href="<%= request.getContextPath()%>/UserServlet?action=profile">
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
