<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Booking"%>
<%@page import="com.counseling.model.Schedule"%>
<%@page import="com.counseling.model.Counsellor"%>
<%@page import="com.counseling.model.SessionRecord"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null || !"STUDENT".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=true&msg=Please+log+in+as+a+student.");
        return;
    }

    List<SessionRecord> recordList
            = (List<SessionRecord>) request.getAttribute("recordList");
    Map<Integer, Booking> bookingMap
            = (Map<Integer, Booking>) request.getAttribute("bookingMap");
    Map<Integer, Schedule> scheduleMap
            = (Map<Integer, Schedule>) request.getAttribute("scheduleMap");
    Map<Integer, Counsellor> counsellorMap
            = (Map<Integer, Counsellor>) request.getAttribute("counsellorMap");

    if (recordList == null) {
        response.sendRedirect(request.getContextPath()
                + "/SessionRecordServlet?action=studentHistory");
        return;
    }

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Session History | Counseling System</title>
        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/student.css">
    </head>

    <body class="dashboard-page">
        <div class="dashboard-layout">
            <aside class="sidebar">
                <h2 class="sidebar-brand">Student Care</h2>
                <ul class="sidebar-menu">
                    <li><a href="<%= request.getContextPath()%>/student/dashboard.jsp">My Dashboard</a></li>
                    <li><a href="<%= request.getContextPath()%>/BookingServlet?action=available">Book Session</a></li>
                    <li><a href="<%= request.getContextPath()%>/BookingServlet?action=myBookings">My Bookings</a></li>
                    <li><a class="active" href="<%= request.getContextPath()%>/SessionRecordServlet?action=studentHistory">Session History</a></li>
                    <li><a href="<%= request.getContextPath()%>/UserServlet?action=profile">My Profile</a></li>
                    <li><a class="logout-link" href="<%= request.getContextPath()%>/LogoutServlet">Logout</a></li>
                </ul>
            </aside>

            <main class="main-content">
                <div class="page-header">
                    <div>
                        <h1>Session History</h1>
                        <p>View completed counselling sessions and submit feedback.</p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success"><%= message%></div>
                <% } %>

                <section class="card">
                    <h2 class="card-title">Completed Sessions</h2>
                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>No.</th>
                                    <th>Counsellor</th>
                                    <th>Date</th>
                                    <th>Time</th>
                                    <th>Feedback</th>
                                    <th>Rating</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (!recordList.isEmpty()) {
                                        int rowNumber = 1;
                                        for (SessionRecord record : recordList) {
                                            Booking booking = bookingMap.get(record.getBookingId());
                                            Schedule schedule = booking != null
                                                    ? scheduleMap.get(booking.getScheduleId()) : null;
                                            Counsellor counsellor
                                                    = counsellorMap.get(record.getCounsellorId());
                                            boolean hasFeedback = record.getFeedback() != null
                                                    && !record.getFeedback().trim().isEmpty();
                                %>
                                <tr>
                                    <td><%= rowNumber++%></td>
                                    <td><%= counsellor != null ? counsellor.getCounsellorName() : "-"%></td>
                                    <td><%= schedule != null ? schedule.getAvailableDate() : record.getSessionDate()%></td>
                                    <td><%= schedule != null ? schedule.getAvailableTime() : "-"%></td>
                                    <td><%= hasFeedback ? record.getFeedback() : "No feedback submitted"%></td>
                                    <td><%= record.getRating() != null ? record.getRating() + " / 5" : "-"%></td>
                                    <td>
                                        <a class="secondary-button"
                                           href="<%= request.getContextPath()%>/SessionRecordServlet?action=feedback&id=<%= record.getRecordId()%>">
                                            <%= hasFeedback ? "View / Edit Feedback" : "Submit Feedback"%>
                                        </a>
                                    </td>
                                </tr>
                                <%  }
                                } else { %>
                                <tr>
                                    <td colspan="7" class="empty-state">
                                        You do not have any completed counselling sessions yet.
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
