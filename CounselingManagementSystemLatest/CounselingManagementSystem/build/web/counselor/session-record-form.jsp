<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Booking"%>
<%@page import="com.counseling.model.Schedule"%>
<%@page import="com.counseling.model.SessionRecord"%>

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

    Booking selectedBooking
            = (Booking) request.getAttribute("selectedBooking");

    Schedule selectedSchedule
            = (Schedule) request.getAttribute("selectedSchedule");

    User selectedStudent
            = (User) request.getAttribute("selectedStudent");

    SessionRecord selectedRecord
            = (SessionRecord) request.getAttribute("selectedRecord");

    boolean isEdit = "edit".equals(formMode);

    if (selectedBooking == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/SessionRecordServlet?action=counsellorList"
        );
        return;
    }

    String pageTitle = isEdit ? "Edit Session Record" : "Record Session";
    String formAction = isEdit ? "update" : "create";

    String notesValue = "";

    if (isEdit && selectedRecord != null
            && selectedRecord.getSessionNotes() != null) {
        notesValue = selectedRecord.getSessionNotes();
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
                        <h1><%= pageTitle%></h1>
                        <p>
                            <%= isEdit
                                    ? "Update the counselling session notes."
                                    : "Add confidential notes for this completed session."%>
                        </p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-error">
                    <%= message%>
                </div>
                <% }%>

                <section class="card">
                    <h2 class="card-title">Session Information</h2>

                    <div class="form-grid">

                        <div class="form-group">
                            <label>Student</label>
                            <input type="text"
                                   readonly
                                   value="<%= selectedStudent != null
                                           ? selectedStudent.getFullName()
                                           : "-"%>">
                        </div>

                        <div class="form-group">
                            <label>Student Email</label>
                            <input type="text"
                                   readonly
                                   value="<%= selectedStudent != null
                                           ? selectedStudent.getEmail()
                                           : "-"%>">
                        </div>

                        <div class="form-group">
                            <label>Session Date</label>
                            <input type="text"
                                   readonly
                                   value="<%= selectedSchedule != null
                                           ? selectedSchedule.getAvailableDate()
                                           : "-"%>">
                        </div>

                        <div class="form-group">
                            <label>Session Time</label>
                            <input type="text"
                                   readonly
                                   value="<%= selectedSchedule != null
                                           ? selectedSchedule.getAvailableTime()
                                           : "-"%>">
                        </div>

                    </div>
                </section>

                <section class="card">
                    <h2 class="card-title">Counsellor Notes</h2>

                    <form action="<%= request.getContextPath()%>/SessionRecordServlet"
                          method="post"
                          class="validate-form"
                          novalidate>

                        <input type="hidden"
                               name="action"
                               value="<%= formAction%>">

                        <% if (isEdit && selectedRecord != null) {%>
                        <input type="hidden"
                               name="recordId"
                               value="<%= selectedRecord.getRecordId()%>">
                        <% } else {%>
                        <input type="hidden"
                               name="bookingId"
                               value="<%= selectedBooking.getBookingId()%>">
                        <% }%>

                        <div class="form-group">
                            <label for="sessionNotes">Session Notes *</label>

                            <textarea id="sessionNotes"
                                      name="sessionNotes"
                                      rows="9"
                                      required
                                      data-label="Session notes"
                                      data-minlength="5"
                                      placeholder="Write the session summary, observations, recommendations, or follow-up plan..."><%= notesValue%></textarea>
                        </div>

                        <p class="form-help">
                            These notes are for counsellor records. Students will not see them.
                        </p>

                        <div class="form-actions">
                            <button type="submit" class="primary-button">
                                <%= isEdit ? "Update Notes" : "Save Session Record"%>
                            </button>

                            <a class="secondary-button"
                               href="<%= request.getContextPath()%>/SessionRecordServlet?action=counsellorList">
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
