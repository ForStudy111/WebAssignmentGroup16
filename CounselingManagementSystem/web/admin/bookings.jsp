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
            || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg=Please+log+in+as+an+admin."
        );
        return;
    }

    List<Booking> bookingList
            = (List<Booking>) request.getAttribute("bookingList");

    Map<Integer, Schedule> scheduleMap
            = (Map<Integer, Schedule>) request.getAttribute("scheduleMap");

    Map<Integer, Counsellor> counsellorMap
            = (Map<Integer, Counsellor>) request.getAttribute("counsellorMap");

    Map<Integer, User> studentMap
            = (Map<Integer, User>) request.getAttribute("studentMap");

    if (bookingList == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/BookingServlet?action=adminList"
        );
        return;
    }

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>All Bookings | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/admin.css">
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
                        <a href="<%= request.getContextPath()%>/CounsellorServlet?action=list">
                            Manage Counsellors
                        </a>
                    </li>

                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/BookingServlet?action=adminList">
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
                        <h1>Booking Monitoring</h1>
                        <p>View all counselling bookings across the system.</p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success">
                    <%= message%>
                </div>
                <% } %>

                <section class="card">
                    <h2 class="card-title">All Counselling Bookings</h2>

                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Booking ID</th>
                                    <th>Student</th>
                                    <th>Counsellor</th>
                                    <th>Date</th>
                                    <th>Time</th>
                                    <th>Booking Date</th>
                                    <th>Status</th>
                                    <th>Action</th>
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

                                            Counsellor counsellor = schedule != null
                                                    ? counsellorMap.get(
                                                            schedule.getCounsellorId()
                                                    )
                                                    : null;

                                            String status = booking.getBookingStatus();
                                            String statusText = status;
                                            String statusClass = "badge-pending";

                                            if ("PENDING".equalsIgnoreCase(status)) {
                                                statusText = "Pending";

                                            } else if ("APPROVED".equalsIgnoreCase(status)) {
                                                statusText = "Approved";
                                                statusClass = "badge-approved";

                                            } else if ("REJECTED".equalsIgnoreCase(status)) {
                                                statusText = "Rejected";
                                                statusClass = "badge-rejected";

                                            } else if ("COMPLETED".equalsIgnoreCase(status)) {
                                                statusText = "Completed";
                                                statusClass = "badge-completed";

                                            } else if ("CANCELLED".equalsIgnoreCase(status)) {
                                                statusClass = "badge-cancelled";

                                                String cancelledBy = booking.getCancelledBy();

                                                if ("STUDENT".equalsIgnoreCase(cancelledBy)) {
                                                    cancelledBy = "Student";

                                                } else if ("COUNSELOR".equalsIgnoreCase(cancelledBy)) {
                                                    cancelledBy = "Counsellor";

                                                } else if ("ADMIN".equalsIgnoreCase(cancelledBy)) {
                                                    cancelledBy = "Admin";
                                                }

                                                statusText = cancelledBy != null
                                                        && !cancelledBy.trim().isEmpty()
                                                        ? "Cancelled by " + cancelledBy
                                                        : "Cancelled";
                                            }
                                %>

                                <tr>
                                    <td><%= booking.getBookingId()%></td>

                                    <td>
                                        <%= student != null
                                                ? student.getFullName()
                                                : "-"%>
                                    </td>

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

                                    <td><%= booking.getBookingDate()%></td>

                                    <td>
                                        <span class="badge <%= statusClass%>">
                                            <%= statusText%>
                                        </span>
                                    </td>

                                    <td>
                                        <% if ("PENDING".equalsIgnoreCase(status)
                                                    || "APPROVED".equalsIgnoreCase(status)) {%>

                                        <a class="danger-button"
                                           href="<%= request.getContextPath()%>/CancelBookingServlet?id=<%= booking.getBookingId()%>"
                                           onclick="return confirm('Cancel this booking as an administrator?');">
                                            Cancel Booking
                                        </a>

                                        <% } else { %>
                                        -
                                        <% } %>
                                    </td>
                                </tr>

                                <%  }
                            } else { %>

                                <tr>
                                    <td colspan="8" class="empty-state">
                                        No counselling bookings have been created yet.
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