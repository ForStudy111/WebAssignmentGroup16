<%-- 
    Document   : schedule-form
    Created on : Jun 21, 2026, 4:49:55 AM
    Author     : wpy92
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Schedule"%>
<%@page import="java.time.LocalDate"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null || !"COUNSELOR".equalsIgnoreCase(currentUser.getRole())) {

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
                .toString();
        statusValue = selectedSchedule.getAvailabilityStatus();
    }

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title><%= pageTitle%> | Counseling System</title>

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
                        <a href="#">
                            Manage Bookings
                        </a>
                    </li>

                    <li>
                        <a href="#">
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
                          onsubmit="return validateScheduleForm();">

                        <input type="hidden"
                               name="action"
                               value="<%= formAction%>">

                        <% if (isEdit) {%>
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
                                       value="<%= dateValue%>">
                            </div>

                            <div class="form-group">
                                <label for="availableTime">Available Time *</label>

                                <input type="time"
                                       id="availableTime"
                                       name="availableTime"
                                       required
                                       value="<%= timeValue%>">
                            </div>

                            <div class="form-group full-width">
                                <label for="availabilityStatus">Availability Status *</label>

                                <select id="availabilityStatus"
                                        name="availabilityStatus"
                                        required>

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
                                <%= isEdit ? "Update Availability" : "Create Availability"%>
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

        <script>
            function validateScheduleForm() {
                const dateValue =
                        document.getElementById("availableDate").value;

                const timeValue =
                        document.getElementById("availableTime").value;

                if (!dateValue || !timeValue) {
                    alert("Please select both an available date and time.");
                    return false;
                }

                return true;
            }
        </script>
    </body>
</html>
