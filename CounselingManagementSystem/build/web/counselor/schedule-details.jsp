<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Schedule"%>
<%@page import="java.util.List"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.LocalTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>

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

    String selectedDate = (String) request.getAttribute("selectedDate");
    List<Schedule> scheduleList
            = (List<Schedule>) request.getAttribute("scheduleList");

    if (selectedDate == null || scheduleList == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/ScheduleServlet?action=list"
        );
        return;
    }

    LocalDate detailDate = LocalDate.parse(selectedDate);
    DateTimeFormatter titleFormatter
            = DateTimeFormatter.ofPattern("EEEE, dd MMMM yyyy");
    DateTimeFormatter timeFormatter
            = DateTimeFormatter.ofPattern("hh:mm a");

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Availability Details | Counseling System</title>

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
                        <a class="active"
                           href="<%= request.getContextPath()%>/ScheduleServlet?action=list">
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
                        <h1>Availability Details</h1>
                        <p><%= detailDate.format(titleFormatter)%></p>
                    </div>

                    <a class="secondary-button"
                       href="<%= request.getContextPath()%>/ScheduleServlet?action=list">
                        Back to Weekly Availability
                    </a>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success">
                    <%= message%>
                </div>
                <% }%>

                <section class="card">
                    <div class="card-header-row">
                        <h2 class="card-title">Time Slots</h2>

                        <a class="primary-button"
                           href="<%= request.getContextPath()%>/ScheduleServlet?action=new&returnDate=<%= selectedDate%>">
                            + Add Availability
                        </a>
                    </div>

                    <% if (scheduleList.isEmpty()) {%>

                    <div class="empty-state">
                        No availability slots have been created for this date.
                    </div>

                    <% } else {%>

                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Start Time</th>
                                    <th>End Time</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>

                            <tbody>
                                <% for (Schedule schedule : scheduleList) {
                                        LocalTime startTime
                                                = schedule.getAvailableTime()
                                                        .toLocalTime();

                                        boolean isBooked
                                                = "BOOKED".equalsIgnoreCase(
                                                        schedule.getAvailabilityStatus()
                                                );
                                %>

                                <tr>
                                    <td>
                                        <%= startTime.format(timeFormatter)%>
                                    </td>

                                    <td>
                                        <%= startTime.plusHours(1)
                                                    .format(timeFormatter)%>
                                    </td>

                                    <td>
                                        <span class="badge <%= isBooked
                                                ? "badge-pending"
                                                : "badge-completed"%>">
                                            <%= schedule.getAvailabilityStatus()%>
                                        </span>
                                    </td>

                                    <td>
                                        <% if (isBooked) {%>
                                        -
                                        <% } else {%>

                                        <a class="secondary-button"
                                           href="<%= request.getContextPath()%>/ScheduleServlet?action=edit&id=<%= schedule.getScheduleId()%>&returnDate=<%= selectedDate%>">
                                            Edit
                                        </a>

                                        <a class="danger-button"
                                           href="<%= request.getContextPath()%>/ScheduleServlet?action=delete&id=<%= schedule.getScheduleId()%>&returnDate=<%= selectedDate%>"
                                           onclick="return confirm('Delete this availability slot?');">
                                            Delete
                                        </a>

                                        <% }%>
                                    </td>
                                </tr>

                                <% }%>
                            </tbody>
                        </table>
                    </div>

                    <% }%>
                </section>
            </main>
        </div>
    </body>
</html>
