<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
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

    List<Schedule> scheduleList
            = (List<Schedule>) request.getAttribute("scheduleList");

    Map<Integer, Counsellor> counsellorMap
            = (Map<Integer, Counsellor>) request.getAttribute("counsellorMap");

    if (scheduleList == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/BookingServlet?action=available"
        );
        return;
    }

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Book Session | Counseling System</title>

        <link rel="stylesheet" href="<%= request.getContextPath()%>/css/student.css">
    </head>

    <body class="dashboard-page">
        <div class="dashboard-layout">

            <aside class="sidebar">
                <h2 class="sidebar-brand">Student Care</h2>

                <ul class="sidebar-menu">
                    <li>
                        <a href="<%= request.getContextPath()%>/student/dashboard.jsp">
                            Dashboard
                        </a>
                    </li>

                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/BookingServlet?action=available">
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
                        <h1>Book a Counselling Session</h1>
                        <p>Select an available time slot and submit your booking request.</p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success">
                    <%= message%>
                </div>
                <% } %>

                <section class="card">
                    <h2 class="card-title">Available Time Slots</h2>

                    <% if (scheduleList.isEmpty()) { %>

                    <div class="empty-state">
                        No available counselling slots at the moment.
                    </div>

                    <% } else { %>

                    <div class="slot-grid">
                        <% for (Schedule schedule : scheduleList) {
                                Counsellor counsellor = counsellorMap.get(
                                        schedule.getCounsellorId()
                                );
                        %>

                        <div class="slot-card">
                            <h3>
                                <%= counsellor != null
                                        ? counsellor.getCounsellorName()
                                        : "Counsellor"%>
                            </h3>

                            <p>
                                <span class="slot-label">Specialization:</span>
                                <%= counsellor != null
                                        ? counsellor.getSpecialization()
                                        : "-"%>
                            </p>

                            <p>
                                <span class="slot-label">Date:</span>
                                <%= schedule.getAvailableDate()%>
                            </p>

                            <p>
                                <span class="slot-label">Time:</span>
                                <%= schedule.getAvailableTime()%>
                            </p>

                            <p>
                                <span class="slot-label">Location:</span>
                                <%= counsellor != null
                                        && counsellor.getOfficeLocation() != null
                                        ? counsellor.getOfficeLocation()
                                        : "-"%>
                            </p>

                            <form action="<%= request.getContextPath()%>/BookingServlet"
                                  method="post"
                                  onsubmit="return confirm('Confirm this booking request?');">

                                <input type="hidden" name="action" value="create">

                                <input type="hidden"
                                       name="scheduleId"
                                       value="<%= schedule.getScheduleId()%>">

                                <button type="submit" class="primary-button">
                                    Book This Slot
                                </button>
                            </form>
                        </div>

                        <% } %>
                    </div>

                    <% }%>
                </section>
            </main>
        </div>
    </body>
</html>