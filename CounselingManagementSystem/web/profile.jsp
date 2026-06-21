<%-- 
    Document   : profile
    Created on : Jun 12, 2026, 5:43:15 AM
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
    String roleLabel = "Student";

    if ("ADMIN".equalsIgnoreCase(currentUser.getRole())) {
        cssFile = "admin.css";
        dashboardPath = "/admin/dashboard.jsp";
        roleLabel = "Administrator";

    } else if ("COUNSELOR".equalsIgnoreCase(currentUser.getRole())) {
        cssFile = "counselor.css";
        dashboardPath = "/counselor/dashboard.jsp";
        roleLabel = "Counsellor";
    }

    String message = request.getParameter("msg");

    String displayUsername = currentUser.getUsername();

    if (displayUsername == null || displayUsername.trim().isEmpty()) {
        displayUsername = (String) session.getAttribute("user");
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>My Profile | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/<%= cssFile%>">
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
                        <a class="active"
                           href="<%= request.getContextPath()%>/UserServlet?action=profile">
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
                        <a class="active"
                           href="<%= request.getContextPath()%>/UserServlet?action=profile">
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
                        <a class="active"
                           href="<%= request.getContextPath()%>/UserServlet?action=profile">
                            My Profile
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
                        <h1>My Profile</h1>
                        <p>Update your personal account details.</p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success">
                    <%= message%>
                </div>
                <% }%>

                <section class="card">
                    <h2 class="card-title">Account Information</h2>

                    <form action="<%= request.getContextPath()%>/UserServlet"
                          method="post"
                          onsubmit="return validateProfile();">

                        <input type="hidden" name="action" value="updateProfile">

                        <input type="hidden"
                               name="userId"
                               value="<%= currentUser.getUserId()%>">

                        <div class="form-grid">

                            <div class="form-group">
                                <label>Username</label>
                                <input type="text"
                                       value="<%= displayUsername != null ? displayUsername : ""%>"
                                       readonly>
                            </div>

                            <div class="form-group">
                                <label>Account Role</label>
                                <input type="text"
                                       value="<%= roleLabel%>"
                                       readonly>
                            </div>

                            <div class="form-group">
                                <label for="fullName">Full Name *</label>
                                <input type="text"
                                       id="fullName"
                                       name="fullName"
                                       value="<%= currentUser.getFullName()%>"
                                       required>
                            </div>

                            <div class="form-group">
                                <label for="email">Email *</label>
                                <input type="email"
                                       id="email"
                                       name="email"
                                       value="<%= currentUser.getEmail()%>"
                                       required>
                            </div>

                            <div class="form-group">
                                <label for="phoneNumber">Phone Number *</label>
                                <input type="text"
                                       id="phoneNumber"
                                       name="phoneNumber"
                                       value="<%= currentUser.getPhoneNumber()%>"
                                       required>
                            </div>

                        </div>

                        <div class="form-actions">
                            <button type="submit" class="primary-button">
                                Save Changes
                            </button>

                            <a class="secondary-button"
                               href="<%= request.getContextPath()%>/ChangePasswordServlet">
                                Change Password
                            </a>

                            <a class="secondary-button"
                               href="<%= request.getContextPath()%><%= dashboardPath%>">
                                Cancel
                            </a>
                        </div>
                    </form>
                </section>

            </main>
        </div>

        <script>
            function validateProfile() {
                const fullName = document.getElementById("fullName").value.trim();
                const email = document.getElementById("email").value.trim();
                const phoneNumber = document.getElementById("phoneNumber").value.trim();

                if (fullName.length < 3) {
                    alert("Please enter your full name.");
                    return false;
                }

                if (!email.includes("@")) {
                    alert("Please enter a valid email address.");
                    return false;
                }

                if (phoneNumber.length < 8) {
                    alert("Please enter a valid phone number.");
                    return false;
                }

                return true;
            }
        </script>
    </body>
</html>
