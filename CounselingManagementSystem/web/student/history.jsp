<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Booking"%>
<%@page import="com.counseling.model.Schedule"%>
<%@page import="com.counseling.model.Counsellor"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>

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

    List<Booking> bookingList
            = (List<Booking>) request.getAttribute("bookingList");

    Map<Integer, Schedule> scheduleMap
            = (Map<Integer, Schedule>) request.getAttribute("scheduleMap");

    Map<Integer, Counsellor> counsellorMap
            = (Map<Integer, Counsellor>) request.getAttribute("counsellorMap");

    if (bookingList == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/BookingServlet?action=myBookings"
        );
        return;
    }

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>My Bookings | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/student.css">
    </head>

    <body class="dashboard-page">
        <div class="dashboard-layout">

            <aside class="sidebar">
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
                        <a class="active"
                           href="<%= request.getContextPath()%>/BookingServlet?action=myBookings">
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
                            Sign Out
                        </a>
                    </li>
                </ul>
            </aside>

            <main class="main-content">

                <div class="page-header">
                    <div>
                        <h1>My Bookings</h1>
                        <p>View, cancel, or open your counselling appointment.</p>
                    </div>

                    <a class="primary-button"
                       href="<%= request.getContextPath()%>/BookingServlet?action=available">
                        Book New Session
                    </a>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success">
                    <%= message%>
                </div>
                <% } %>

                <section class="card">
                    <h2 class="card-title">Counselling Appointments</h2>

                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Booking ID</th>
                                    <th>Counsellor</th>
                                    <th>Date</th>
                                    <th>Time</th>
                                    <th>Status</th>
                                    <th>Calendar</th>
                                    <th>Action</th>
                                </tr>
                            </thead>

                            <tbody>
                                <% if (!bookingList.isEmpty()) {
                                        for (Booking booking : bookingList) {

                                            Schedule schedule = scheduleMap.get(
                                                    booking.getScheduleId()
                                            );

                                            Counsellor counsellor = schedule != null
                                                    ? counsellorMap.get(
                                                            schedule.getCounsellorId()
                                                    )
                                                    : null;

                                            String status = booking.getBookingStatus();
                                            String statusClass = "badge-pending";

                                            if ("APPROVED".equalsIgnoreCase(status)) {
                                                statusClass = "badge-approved";

                                            } else if ("COMPLETED".equalsIgnoreCase(status)) {
                                                statusClass = "badge-completed";

                                            } else if ("CANCELLED".equalsIgnoreCase(status)) {
                                                statusClass = "badge-cancelled";
                                            }
                                %>

                                <tr>
                                    <td><%= booking.getBookingId()%></td>

                                    <td>
                                        <%= counsellor != null
                                                ? counsellor.getCounsellorName()
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
                                        <span class="badge <%= statusClass%>">
                                            <%= status%>
                                        </span>
                                    </td>

                                    <td>
                                        <% if (booking.getGoogleEventLink() != null
                                                    && !booking.getGoogleEventLink().trim().isEmpty()
                                                    && "SYNCED".equalsIgnoreCase(
                                                            booking.getCalendarSyncStatus())
                                                    && !"CANCELLED".equalsIgnoreCase(status)) {%>

                                        <a class="secondary-button"
                                           href="<%= booking.getGoogleEventLink()%>"
                                           target="_blank"
                                           rel="noopener">
                                            Open Event
                                        </a>

                                        <% } else { %>

                                        <span>-</span>

                                        <% } %>
                                    </td>

                                    <td>
                                        <% if ("PENDING".equalsIgnoreCase(status)
                                                    || "APPROVED".equalsIgnoreCase(status)) {%>

                                        <a class="danger-button"
                                           href="<%= request.getContextPath()%>/CancelBookingServlet?id=<%= booking.getBookingId()%>"
                                           onclick="return confirm('Cancel this booking? The schedule slot will become available again.');">
                                            Cancel Booking
                                        </a>

                                        <% } else { %>

                                        <span>-</span>

                                        <% } %>
                                    </td>
                                </tr>

                                <%  }
                            } else { %>

                                <tr>
                                    <td colspan="7" class="empty-state">
                                        You have not made any counselling bookings yet.
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