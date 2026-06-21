<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Schedule"%>
<%@page import="java.util.List"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null || !"COUNSELOR".equalsIgnoreCase(currentUser.getRole())) {

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg=Please+log+in+as+a+counsellor."
        );
        return;
    }

    List<Schedule> scheduleList = (List<Schedule>) request.getAttribute("scheduleList");

    if (scheduleList == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/ScheduleServlet?action=list"
        );
        return;
    }

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manage Availability | Counseling System</title>

        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/counselor.css">
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
                        <h1>Manage Availability</h1>
                        <p>Create and manage the time slots students can book.</p>
                    </div>

                    <a class="primary-button"
                       href="<%= request.getContextPath()%>/ScheduleServlet?action=new">
                        + Add Availability
                    </a>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success">
                    <%= message%>
                </div>
                <% } %>

                <section class="card">
                    <h2 class="card-title">My Schedule Slots</h2>

                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Date</th>
                                    <th>Time</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>

                            <tbody>
                                <% if (!scheduleList.isEmpty()) {
                                        for (Schedule schedule : scheduleList) {%>

                                <tr>
                                    <td><%= schedule.getScheduleId()%></td>
                                    <td><%= schedule.getAvailableDate()%></td>
                                    <td><%= schedule.getAvailableTime()%></td>

                                    <td>
                                        <% if ("AVAILABLE".equalsIgnoreCase(
                                                    schedule.getAvailabilityStatus())) { %>

                                        <span class="badge badge-available">
                                            AVAILABLE
                                        </span>

                                        <% } else if ("BOOKED".equalsIgnoreCase(
                                                schedule.getAvailabilityStatus())) { %>

                                        <span class="badge badge-booked">
                                            BOOKED
                                        </span>

                                        <% } else { %>

                                        <span class="badge badge-unavailable">
                                            UNAVAILABLE
                                        </span>

                                        <% } %>
                                    </td>

                                    <td>
                                        <div class="action-group">
                                            <% if (!"BOOKED".equalsIgnoreCase(
                                                        schedule.getAvailabilityStatus())) {%>

                                            <a class="secondary-button"
                                               href="<%= request.getContextPath()%>/ScheduleServlet?action=edit&id=<%= schedule.getScheduleId()%>">
                                                Edit
                                            </a>

                                            <a class="danger-button"
                                               href="<%= request.getContextPath()%>/ScheduleServlet?action=delete&id=<%= schedule.getScheduleId()%>"
                                               onclick="return confirm('Delete this availability slot?');">
                                                Delete
                                            </a>

                                            <% } else { %>
                                            <span>-</span>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>

                                <%  }
                                } else { %>

                                <tr>
                                    <td colspan="5" class="empty-state">
                                        No availability slots have been created yet.
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