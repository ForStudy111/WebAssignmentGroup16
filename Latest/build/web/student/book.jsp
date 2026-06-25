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
                            My Dashboard
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
                    <h2 class="card-title">Available Time Slots by Counsellor</h2>

                    <% if (scheduleList.isEmpty()) { %>

                    <div class="empty-state">
                        No available counselling slots at the moment.
                    </div>

                    <%
                    } else {
                        // Group schedules by Counsellor ID in memory
                        java.util.Map<Integer, List<Schedule>> groupedSchedules = new java.util.HashMap<>();
                        for (Schedule s : scheduleList) {
                            groupedSchedules.computeIfAbsent(s.getCounsellorId(), k -> new java.util.ArrayList<>()).add(s);
                        }
                    %>

                    <div class="slot-grid">
                        <%
                            for (Map.Entry<Integer, List<Schedule>> entry : groupedSchedules.entrySet()) {
                                Integer counselorId = entry.getKey();
                                List<Schedule> slots = entry.getValue();
                                Counsellor counsellor = counsellorMap.get(counselorId);
                        %>

                        <div class="slot-card" style="padding: 20px; margin-bottom: 20px; border: 1px solid #e0e0e0; border-radius: 8px;">
                            <h3>
                                <%= counsellor != null ? counsellor.getCounsellorName() : "Counsellor"%>
                            </h3>

                            <p style="margin: 5px 0 15px 0; color: #666;">
                                <span class="slot-label" style="font-weight: bold;">Specialization:</span>
                                <%= counsellor != null ? counsellor.getSpecialization() : "-"%>
                                <br>
                                <span class="slot-label" style="font-weight: bold;">Location:</span>
                                <%= counsellor != null && counsellor.getOfficeLocation() != null ? counsellor.getOfficeLocation() : "-"%>
                            </p>

                            <form action="<%= request.getContextPath()%>/BookingServlet"
                                  method="post"
                                  onsubmit="return confirm('Confirm this booking request?');">

                                <input type="hidden" name="action" value="create">

                                <div class="form-group" style="margin-bottom: 15px;">
                                    <label for="scheduleId_<%= counselorId%>" style="display: block; margin-bottom: 5px; font-weight: bold;">
                                        Choose an Available Session:
                                    </label>
                                    <select id="scheduleId_<%= counselorId%>" name="scheduleId" required style="width: 100%; padding: 8px; border-radius: 4px; border: 1px solid #ccc;">
                                        <option value="">-- Select Date & Time --</option>
                                        <%
                                            // Formatters to make times highly readable inside the select drop-down box
                                            java.time.format.DateTimeFormatter dtfDate = java.time.format.DateTimeFormatter.ofPattern("EEE, MMM dd");
                                            java.time.format.DateTimeFormatter dtfTime = java.time.format.DateTimeFormatter.ofPattern("hh:mm a");

                                            for (Schedule slot : slots) {
                                                String displayOption = slot.getAvailableDate().toString() + " @ " + slot.getAvailableTime().toString();
                                                try {
                                                    java.time.LocalDate d = java.time.LocalDate.parse(slot.getAvailableDate().toString());
                                                    java.time.LocalTime t = java.time.LocalTime.parse(slot.getAvailableTime().toString());
                                                    displayOption = d.format(dtfDate) + " at " + t.format(dtfTime) + " - " + t.plusHours(1).format(dtfTime);
                                                } catch (Exception e) {
                                                    /* fallback if parsing strings error out */ }
                                        %>
                                        <option value="<%= slot.getScheduleId()%>">
                                            <%= displayOption%>
                                        </option>
                                        <% } %>
                                    </select>
                                </div>

                                <button type="submit" class="primary-button" style="width: 100%;">
                                    Book Selected Slot
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