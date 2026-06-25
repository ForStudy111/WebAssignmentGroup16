<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Booking"%>
<%@page import="com.counseling.model.Schedule"%>
<%@page import="com.counseling.model.Counsellor"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.LocalTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>

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

    Booking selectedBooking
            = (Booking) request.getAttribute("selectedBooking");

    List<Schedule> scheduleList
            = (List<Schedule>) request.getAttribute("scheduleList");

    Map<Integer, Counsellor> counsellorMap
            = (Map<Integer, Counsellor>) request.getAttribute("counsellorMap");

    if (selectedBooking == null || scheduleList == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/BookingServlet?action=myBookings"
        );
        return;
    }

    String message = request.getParameter("msg");

    DateTimeFormatter dateFormatter
            = DateTimeFormatter.ofPattern("EEE, MMM dd");

    DateTimeFormatter timeFormatter
            = DateTimeFormatter.ofPattern("hh:mm a");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Reschedule Booking | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/student.css">

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/validation.css">
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
                            Logout
                        </a>
                    </li>
                </ul>
            </aside>

            <main class="main-content">

                <div class="page-header">
                    <div>
                        <h1>Reschedule Booking</h1>
                        <p>Select a new available counselling session time slot.</p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-error">
                    <%= message%>
                </div>
                <% }%>

                <section class="card">
                    <h2 class="card-title">
                        Booking #<%= selectedBooking.getBookingId()%>
                    </h2>

                    <% if (scheduleList.isEmpty()) {%>

                    <div class="empty-state">
                        There are no other available slots to reschedule to.
                    </div>

                    <div class="form-actions">
                        <a class="secondary-button"
                           href="<%= request.getContextPath()%>/BookingServlet?action=myBookings">
                            Back to My Bookings
                        </a>
                    </div>

                    <% } else {%>

                    <form action="<%= request.getContextPath()%>/BookingServlet"
                          method="post"
                          class="validate-form"
                          novalidate>

                        <input type="hidden" name="action" value="reschedule">

                        <input type="hidden"
                               name="bookingId"
                               value="<%= selectedBooking.getBookingId()%>">

                        <div class="form-group">
                            <label for="newScheduleId">
                                Choose New Available Slot *
                            </label>

                            <select id="newScheduleId"
                                    name="newScheduleId"
                                    required
                                    data-label="New available slot">

                                <option value="">
                                    -- Select a new time slot --
                                </option>

                                <% for (Schedule schedule : scheduleList) {
                                        Counsellor counsellor = counsellorMap.get(
                                                schedule.getCounsellorId()
                                        );

                                        String displayOption = "";

                                        try {
                                            LocalDate date = LocalDate.parse(
                                                    schedule.getAvailableDate().toString()
                                            );

                                            LocalTime startTime = LocalTime.parse(
                                                    schedule.getAvailableTime().toString()
                                            );

                                            LocalTime endTime = startTime.plusHours(1);

                                            String counsellorName = counsellor != null
                                                    && counsellor.getCounsellorName() != null
                                                    ? counsellor.getCounsellorName()
                                                    : "Counsellor";

                                            String specialization = counsellor != null
                                                    && counsellor.getSpecialization() != null
                                                    ? counsellor.getSpecialization()
                                                    : "";

                                            displayOption = date.format(dateFormatter)
                                                    + " | "
                                                    + startTime.format(timeFormatter)
                                                    + " - "
                                                    + endTime.format(timeFormatter)
                                                    + " | "
                                                    + counsellorName;

                                            if (!specialization.trim().isEmpty()) {
                                                displayOption += " - " + specialization;
                                            }

                                        } catch (Exception e) {
                                            displayOption = schedule.getAvailableDate()
                                                    + " | "
                                                    + schedule.getAvailableTime()
                                                    + " | "
                                                    + (counsellor != null
                                                            ? counsellor.getCounsellorName()
                                                            : "Counsellor");
                                        }
                                %>

                                <option value="<%= schedule.getScheduleId()%>">
                                    <%= displayOption%>
                                </option>

                                <% }%>
                            </select>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="primary-button">
                                Confirm Reschedule
                            </button>

                            <a class="secondary-button"
                               href="<%= request.getContextPath()%>/BookingServlet?action=myBookings">
                                Cancel
                            </a>
                        </div>
                    </form>

                    <% }%>
                </section>
            </main>
        </div>

        <script src="<%= request.getContextPath()%>/js/validation.js"></script>
    </body>
</html>
