<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Booking"%>
<%@page import="com.counseling.model.Schedule"%>
<%@page import="com.counseling.model.SessionRecord"%>
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

    List<SessionRecord> recordList
            = (List<SessionRecord>) request.getAttribute("recordList");

    Map<Integer, Booking> bookingMap
            = (Map<Integer, Booking>) request.getAttribute("bookingMap");

    Map<Integer, Schedule> scheduleMap
            = (Map<Integer, Schedule>) request.getAttribute("scheduleMap");

    Map<Integer, User> studentMap
            = (Map<Integer, User>) request.getAttribute("studentMap");

    if (recordList == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/SessionRecordServlet?action=counsellorList"
        );
        return;
    }

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Session Records | Counseling System</title>

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
                        <a href="<%= request.getContextPath()%>/BookingServlet?action=counsellorList">
                            Manage Bookings
                        </a>
                    </li>

                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/SessionRecordServlet?action=counsellorList">
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
                        <h1>Session Records</h1>
                        <p>Review, update, or remove completed counselling session notes.</p>
                    </div>

                    <a class="primary-button"
                       href="<%= request.getContextPath()%>/BookingServlet?action=counsellorList">
                        View Approved Bookings
                    </a>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success">
                    <%= message%>
                </div>
                <% } %>

                <section class="card">
                    <h2 class="card-title">Completed Session Records</h2>

                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Record ID</th>
                                    <th>Student</th>
                                    <th>Session Date</th>
                                    <th>Session Time</th>
                                    <th>Notes</th>
                                    <th>Feedback</th>
                                    <th>Rating</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>

                            <tbody>
                                <% if (!recordList.isEmpty()) {
                                        for (SessionRecord record : recordList) {

                                            Booking booking = bookingMap.get(
                                                    record.getBookingId()
                                            );

                                            Schedule schedule = booking != null
                                                    ? scheduleMap.get(
                                                            booking.getScheduleId()
                                                    )
                                                    : null;

                                            User student = booking != null
                                                    ? studentMap.get(
                                                            booking.getUserId()
                                                    )
                                                    : null;
                                %>

                                <tr>
                                    <td><%= record.getRecordId()%></td>

                                    <td>
                                        <%= student != null
                                                ? student.getFullName()
                                                : "-"%>
                                    </td>

                                    <td>
                                        <%= schedule != null
                                                ? schedule.getAvailableDate()
                                                : record.getSessionDate()%>
                                    </td>

                                    <td>
                                        <%= schedule != null
                                                ? schedule.getAvailableTime()
                                                : "-"%>
                                    </td>

                                    <td>
                                        <%= record.getSessionNotes()%>
                                    </td>

                                    <td>
                                        <%= record.getFeedback() != null
                                                && !record.getFeedback().trim().isEmpty()
                                                ? record.getFeedback()
                                                : "No feedback yet"%>
                                    </td>

                                    <td>
                                        <%= record.getRating() != null
                                                ? record.getRating() + " / 5"
                                                : "-"%>
                                    </td>

                                    <td>
                                        <div class="action-group">
                                            <a class="secondary-button"
                                               href="<%= request.getContextPath()%>/SessionRecordServlet?action=edit&id=<%= record.getRecordId()%>">
                                                Edit Notes
                                            </a>

                                            <a class="danger-button"
                                               href="<%= request.getContextPath()%>/SessionRecordServlet?action=delete&id=<%= record.getRecordId()%>"
                                               onclick="return confirm('Delete this session record?');">
                                                Delete
                                            </a>
                                        </div>
                                    </td>
                                </tr>

                                <%  }
                            } else { %>

                                <tr>
                                    <td colspan="8" class="empty-state">
                                        No session records have been created yet.
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