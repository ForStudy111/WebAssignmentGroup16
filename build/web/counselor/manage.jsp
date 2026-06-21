<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Booking"%>
<%@page import="com.counseling.model.Schedule"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>

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

    List<Booking> bookingList
            = (List<Booking>) request.getAttribute("bookingList");

    Map<Integer, Schedule> scheduleMap
            = (Map<Integer, Schedule>) request.getAttribute("scheduleMap");

    Map<Integer, User> studentMap
            = (Map<Integer, User>) request.getAttribute("studentMap");

    if (bookingList == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/BookingServlet?action=counsellorList"
        );
        return;
    }

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manage Bookings | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/counselor.css">
    </head>

    <body class="dashboard-page">
        <div class="dashboard-layout">

            <aside class="sidebar">
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
                        <a class="active"
                           href="<%= request.getContextPath()%>/BookingServlet?action=counsellorList">
                            Manage Bookings
                        </a>
                    </li>

                    <li>
                        <a href="#">
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
                        <h1>Manage Bookings</h1>
                        <p>Review and manage counselling session requests.</p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success">
                    <%= message%>
                </div>
                <% } %>

                <section class="card">
                    <h2 class="card-title">Student Appointment Requests</h2>

                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Booking ID</th>
                                    <th>Student</th>
                                    <th>Email</th>
                                    <th>Date</th>
                                    <th>Time</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>

                            <tbody>
                                <% if (!bookingList.isEmpty()) {
                                        for (Booking booking : bookingList) {

                                            Schedule schedule = scheduleMap.get(
                                                    booking.getScheduleId()
                                            );

                                            User student = studentMap.get(
                                                    booking.getUserId()
                                            );
                                %>

                                <tr>
                                    <td><%= booking.getBookingId()%></td>

                                    <td>
                                        <%= student != null
                                                ? student.getFullName()
                                                : "-"%>
                                    </td>

                                    <td>
                                        <%= student != null
                                                ? student.getEmail()
                                                : "-"%>
                                    </td>

                                    <td>
                                        <%= schedule != null
                                                ? schedule.getAvailableDate()
                                                : "-"%>
                                    </td>

                                    <td>
                                        <%= schedule != null
                                                ? schedule.getAvailableTime()
                                                : "-"%>
                                    </td>

                                    <td>
                                        <% if ("APPROVED".equalsIgnoreCase(
                                                    booking.getBookingStatus())) { %>

                                        <span class="badge badge-approved">
                                            APPROVED
                                        </span>

                                        <% } else { %>

                                        <span class="badge badge-pending">
                                            PENDING
                                        </span>

                                        <% } %>
                                    </td>

                                    <td>
                                        <div class="action-group">

                                            <% if ("PENDING".equalsIgnoreCase(booking.getBookingStatus())) {%>

                                            <a class="primary-button"
                                               href="<%= request.getContextPath()%>/BookingServlet?action=approve&id=<%= booking.getBookingId()%>"
                                               onclick="return confirm('Approve this booking?');">
                                                Approve
                                            </a>

                                            <% } %>

                                            <% if ("APPROVED".equalsIgnoreCase(booking.getBookingStatus())) {%>

                                            <a class="primary-button"
                                               href="<%= request.getContextPath()%>/SessionRecordServlet?action=new&bookingId=<%= booking.getBookingId()%>">
                                                Record Session
                                            </a>

                                            <% }%>

                                            <% if (booking.getGoogleEventLink() != null
                                                        && !booking.getGoogleEventLink().trim().isEmpty()
                                                        && !"CANCELLED".equalsIgnoreCase(booking.getBookingStatus())
                                                        && "SYNCED".equalsIgnoreCase(
                                                                booking.getCalendarSyncStatus())) {%>

                                            <a class="secondary-button"
                                               href="<%= booking.getGoogleEventLink()%>"
                                               target="_blank">
                                                Open Calendar Event
                                            </a>

                                            <% }%>

                                            <a class="danger-button"
                                               href="<%= request.getContextPath()%>/CancelBookingServlet?id=<%= booking.getBookingId()%>"
                                               onclick="return confirm('Cancel this booking and reopen the slot?');">
                                                Cancel
                                            </a>

                                        </div>
                                    </td>
                                </tr>

                                <%  }
                                } else { %>

                                <tr>
                                    <td colspan="7" class="empty-state">
                                        No booking requests have been assigned to you.
                                    </td>
                                </tr>

                                <% }%>
                            </tbody>
                        </table>
                    </div>
                </section>
            </main>
        </div>
    </body>
</html>