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
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Admin Dashboard | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/admin.css">
    </head>

    <body class="dashboard-page">
        <div class="dashboard-layout">

            <aside class="sidebar">
                <h2 class="sidebar-brand">Admin Portal</h2>

                <ul class="sidebar-menu">
                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/admin/dashboard.jsp">
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
                        <h1>Welcome, <%= currentUser.getFullName()%></h1>
                        <p>Manage system users, counsellors, and counselling bookings.</p>
                    </div>
                </div>

                <section class="card">
                    <h2 class="card-title">User Management</h2>
                    <p>
                        Create, update, and remove student or administrator accounts.
                    </p>

                    <div class="form-actions">
                        <a class="primary-button"
                           href="<%= request.getContextPath()%>/UserServlet?action=list">
                            Manage Users
                        </a>

                        <a class="secondary-button"
                           href="<%= request.getContextPath()%>/UserServlet?action=new">
                            Add User
                        </a>
                    </div>
                </section>

                <section class="card">
                    <h2 class="card-title">Counsellor Management</h2>
                    <p>
                        Add counsellor accounts, maintain professional details,
                        and update their specialization or office location.
                    </p>

                    <div class="form-actions">
                        <a class="primary-button"
                           href="<%= request.getContextPath()%>/CounsellorServlet?action=list">
                            Manage Counsellors
                        </a>

                        <a class="secondary-button"
                           href="<%= request.getContextPath()%>/CounsellorServlet?action=new">
                            Add Counsellor
                        </a>
                    </div>
                </section>

                <section class="card">
                    <h2 class="card-title">Booking Monitoring</h2>
                    <p>
                        Review all student counselling bookings and cancel a booking
                        if required by the administration.
                    </p>

                    <div class="form-actions">
                        <a class="primary-button"
                           href="<%= request.getContextPath()%>/BookingServlet?action=adminList">
                            View All Bookings
                        </a>
                    </div>
                </section>

            </main>
        </div>
    </body>
</html>