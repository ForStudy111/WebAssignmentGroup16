<%-- 
    Document   : schedule-form
    Created on : Jun 21, 2026
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Schedule"%>
<%@page import="java.time.LocalDate"%>
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

    String formMode = (String) request.getAttribute("formMode");
    Schedule selectedSchedule
            = (Schedule) request.getAttribute("selectedSchedule");

    boolean isEdit = "edit".equals(formMode);

    String pageTitle = isEdit ? "Edit Availability" : "Add Availability";
    String formAction = isEdit ? "update" : "create";

    String dateValue = "";
    String timeValue = "";
    String statusValue = "AVAILABLE";

    if (isEdit && selectedSchedule != null) {
        dateValue = selectedSchedule.getAvailableDate().toString();

        timeValue = selectedSchedule.getAvailableTime()
                .toLocalTime()
                .format(DateTimeFormatter.ofPattern("HH:mm"));

        statusValue = selectedSchedule.getAvailabilityStatus();
    }

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title><%= pageTitle%> | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/counselor.css">

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/validation.css">
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
                        <h1><%= pageTitle%></h1>
                        <p>
                            <%= isEdit
                                    ? "Update this availability slot."
                                    : "Create a new time slot for student bookings."%>
                        </p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-error">
                    <%= message%>
                </div>
                <% }%>

                <section class="card">
                    <form action="<%= request.getContextPath()%>/ScheduleServlet"
                          method="post"
                          class="validate-form"
                          novalidate>

                        <input type="hidden"
                               name="action"
                               value="<%= formAction%>">

                        <% if (isEdit && selectedSchedule != null) {%>
                        <input type="hidden"
                               name="scheduleId"
                               value="<%= selectedSchedule.getScheduleId()%>">
                        <% }%>

                        <div class="form-grid">

                            <div class="form-group">
                                <label for="availableDate">Available Date *</label>

                                <input type="date"
                                       id="availableDate"
                                       name="availableDate"
                                       min="<%= LocalDate.now()%>"
                                       required
                                       data-label="Available date"
                                       data-future-date="true"
                                       value="<%= dateValue%>">
                            </div>

                            <div class="form-group">
                                <label for="availableTime">Available Time *</label>

                                <input type="time"
                                       id="availableTime"
                                       name="availableTime"
                                       required
                                       data-label="Available time"
                                       value="<%= timeValue%>">
                            </div>

                            <div class="form-group full-width">
                                <label for="availabilityStatus">
                                    Availability Status *
                                </label>

                                <select id="availabilityStatus"
                                        name="availabilityStatus"
                                        required
                                        data-label="Availability status">

                                    <option value="AVAILABLE"
                                            <%= "AVAILABLE".equalsIgnoreCase(statusValue)
                                                ? "selected" : ""%>>
                                        Available for Booking
                                    </option>

                                    <option value="UNAVAILABLE"
                                            <%= "UNAVAILABLE".equalsIgnoreCase(statusValue)
                                                ? "selected" : ""%>>
                                        Unavailable
                                    </option>
                                </select>
                            </div>

                        </div>

                        <p class="form-help">
                            Booked slots cannot be edited or deleted.
                        </p>

                        <div class="form-actions">
                            <button type="submit" class="primary-button">
                                <%= isEdit
                                        ? "Update Availability"
                                        : "Create Availability"%>
                            </button>

                            <a class="secondary-button"
                               href="<%= request.getContextPath()%>/ScheduleServlet?action=list">
                                Cancel
                            </a>
                        </div>
                    </form>
                </section>
            </main>
        </div>

        <script src="<%= request.getContextPath()%>/js/validation.js"></script>
    </body>
</html>
