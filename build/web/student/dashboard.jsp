<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null
            || !"STUDENT".equalsIgnoreCase(currentUser.getRole())) {

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg=Please+log+in+as+a+student."
        );
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Student Dashboard | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/student.css">
    </head>

    <body class="dashboard-page">
        <div class="dashboard-layout">

            <aside class="sidebar">
                <h2 class="sidebar-brand">Student Care</h2>

                <ul class="sidebar-menu">
                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/student/dashboard.jsp">
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
                        <h1>Hi, <%= currentUser.getFullName()%>!</h1>
                        <p>
                            Welcome to the counselling session booking system.
                        </p>
                    </div>
                </div>

                <section class="card">
                    <h2 class="card-title">Need someone to talk to?</h2>

                    <p>
                        View counsellor availability, book a suitable session,
                        manage your appointments and submit feedback after a
                        completed session.
                    </p>

                    <div class="form-actions">
                        <a class="primary-button"
                           href="<%= request.getContextPath()%>/BookingServlet?action=available">
                            Book New Session
                        </a>

                        <a class="secondary-button"
                           href="<%= request.getContextPath()%>/BookingServlet?action=myBookings">
                            View My Bookings
                        </a>
                    </div>
                </section>

                <section class="card">
                    <h2 class="card-title">Quick Actions</h2>

                    <div class="form-actions">
                        <a class="secondary-button"
                           href="<%= request.getContextPath()%>/BookingServlet?action=available">
                            View Available Slots
                        </a>

                        <a class="secondary-button"
                           href="<%= request.getContextPath()%>/SessionRecordServlet?action=studentHistory">
                            View Session History
                        </a>
                    </div>
                </section>

            </main>
        </div>
    </body>
</html>