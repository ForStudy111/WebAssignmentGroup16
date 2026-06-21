<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.dao.GoogleCalendarConnectionDAO"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null
            || !"COUNSELOR".equalsIgnoreCase(currentUser.getRole())) {

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg=Please+log+in+as+a+counsellor."
        );
        return;
    }

    String message = request.getParameter("msg");

    GoogleCalendarConnectionDAO calendarConnectionDAO
            = new GoogleCalendarConnectionDAO();

    boolean googleCalendarConnected
            = calendarConnectionDAO.isConnected(currentUser.getUserId());
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Counsellor Dashboard | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/counselor.css">
    </head>

    <body class="dashboard-page">
        <div class="dashboard-layout">

            <aside class="sidebar">
                <h2 class="sidebar-brand">Counsellor Portal</h2>

                <ul class="sidebar-menu">
                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/counselor/dashboard.jsp">
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
                        <p>
                            Manage your availability, booking requests,
                            and counselling session records.
                        </p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success">
                    <%= message%>
                </div>
                <% }%>

                <section class="card">
                    <h2 class="card-title">Manage Your Availability</h2>

                    <p>
                        Add available counselling time slots for students,
                        edit unbooked slots, or remove unavailable slots.
                    </p>

                    <div class="form-actions">
                        <a class="primary-button"
                           href="<%= request.getContextPath()%>/ScheduleServlet?action=list">
                            Manage Availability
                        </a>
                    </div>
                </section>

                <section class="card">
                    <h2 class="card-title">Appointment Requests</h2>

                    <p>
                        Review student bookings, approve pending requests,
                        or cancel appointments when necessary.
                    </p>

                    <div class="form-actions">
                        <a class="primary-button"
                           href="<%= request.getContextPath()%>/BookingServlet?action=counsellorList">
                            Manage Bookings
                        </a>
                    </div>
                </section>

                <section class="card">
                    <h2 class="card-title">Session Records</h2>

                    <p>
                        Record confidential session notes after an approved
                        counselling appointment has been completed.
                    </p>

                    <div class="form-actions">
                        <a class="primary-button"
                           href="<%= request.getContextPath()%>/SessionRecordServlet?action=counsellorList">
                            View Session Records
                        </a>
                    </div>
                </section>

                <section class="card">
                    <h2 class="card-title">Google Calendar Connection</h2>

                    <% if (googleCalendarConnected) {%>

                    <p>
                        Your Google Calendar is connected. Approved bookings
                        can be added to your calendar automatically.
                    </p>

                    <div class="form-actions">
                        <button type="button"
                                class="secondary-button"
                                disabled>
                            Google Calendar Connected
                        </button>

                        <form action="<%= request.getContextPath()%>/GoogleCalendarDisconnectServlet"
                              method="post"
                              onsubmit="return confirm('Disconnect Google Calendar from this system?');">

                            <button type="submit" class="danger-button">
                                Disconnect Google Calendar
                            </button>
                        </form>
                    </div>

                    <% } else {%>

                    <p>
                        Connect your Google Calendar so approved counselling
                        appointments can be added automatically.
                    </p>

                    <div class="form-actions">
                        <a class="primary-button"
                           href="<%= request.getContextPath()%>/GoogleCalendarConnectServlet">
                            Connect Google Calendar
                        </a>
                    </div>

                    <% }%>
                </section>

            </main>
        </div>
    </body>
</html>