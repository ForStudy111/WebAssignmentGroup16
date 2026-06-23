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

    List<Schedule> scheduleList
            = (List<Schedule>) request.getAttribute("scheduleList");

    if (scheduleList == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/ScheduleServlet?action=list"
        );
        return;
    }

    String message = request.getParameter("msg");

    LocalDate today = LocalDate.now();
    DateTimeFormatter dayFormatter
            = DateTimeFormatter.ofPattern("EEE");
    DateTimeFormatter dateFormatter
            = DateTimeFormatter.ofPattern("dd MMM");
    DateTimeFormatter longDateFormatter
            = DateTimeFormatter.ofPattern("EEEE, dd MMMM yyyy");
    DateTimeFormatter timeFormatter
            = DateTimeFormatter.ofPattern("hh:mm a");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manage Availability | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/counselor.css">

        <style>
            .weekly-card-grid {
                display: grid;
                grid-template-columns: repeat(7, minmax(180px, 1fr));
                gap: 16px;
                overflow-x: auto;
                padding-bottom: 8px;
            }

            .day-card {
                min-width: 180px;
                padding: 18px;
                border: 1px solid #d9e8e6;
                border-top: 4px solid #14866d;
                border-radius: 12px;
                background: #ffffff;
                box-shadow: 0 5px 14px rgba(25, 77, 70, 0.08);
            }

            .day-card.is-today {
                background: #f2fffa;
                border-top-color: #00aa72;
            }

            .day-card-header {
                margin-bottom: 14px;
            }

            .day-card-day {
                margin: 0;
                color: #0a5e50;
                font-size: 19px;
                font-weight: 700;
            }

            .day-card-date {
                margin: 4px 0 0;
                color: #6a8380;
                font-size: 13px;
            }

            .slot-count {
                display: inline-block;
                margin: 0 0 12px;
                padding: 4px 8px;
                border-radius: 999px;
                color: #0a745f;
                background: #e6f7f1;
                font-size: 12px;
                font-weight: 700;
            }

            .slot-preview {
                display: flex;
                flex-direction: column;
                gap: 8px;
                min-height: 150px;
                margin-bottom: 16px;
            }

            .slot-preview-item {
                padding: 8px 9px;
                border-radius: 7px;
                color: #355f59;
                background: #f2f7f6;
                font-size: 12px;
                font-weight: 600;
            }

            .slot-preview-item.booked {
                color: #74520d;
                background: #fff4cf;
            }

            .no-slots {
                margin: 0;
                color: #7a8c89;
                font-size: 13px;
                line-height: 1.5;
            }

            .day-card .secondary-button {
                display: block;
                width: 100%;
                box-sizing: border-box;
                text-align: center;
            }
        </style>
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
                        <p>View your availability for today and the next six days.</p>
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
                <% }%>

                <section class="card">
                    <h2 class="card-title">Weekly Availability</h2>

                    <div class="weekly-card-grid">
                        <% for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
                                LocalDate cardDate = today.plusDays(dayOffset);
                                String dateValue = cardDate.toString();
                                int slotCount = 0;

                                for (Schedule schedule : scheduleList) {
                                    if (dateValue.equals(
                                            schedule.getAvailableDate().toString())) {
                                        slotCount++;
                                    }
                                }
                        %>

                        <article class="day-card <%= dayOffset == 0
                                ? "is-today"
                                : ""%>">

                            <div class="day-card-header">
                                <h3 class="day-card-day">
                                    <%= dayOffset == 0
                                            ? "Today"
                                            : cardDate.format(dayFormatter)%>
                                </h3>

                                <p class="day-card-date">
                                    <%= cardDate.format(dateFormatter)%>
                                </p>
                            </div>

                            <span class="slot-count">
                                <%= slotCount%>
                                <%= slotCount == 1 ? "slot" : "slots"%>
                            </span>

                            <div class="slot-preview">
                                <% if (slotCount == 0) {%>

                                <p class="no-slots">
                                    No availability created yet.
                                </p>

                                <% } else {
                                    for (Schedule schedule : scheduleList) {
                                        if (dateValue.equals(
                                                schedule.getAvailableDate()
                                                        .toString())) {

                                            LocalTime startTime
                                                    = schedule.getAvailableTime()
                                                            .toLocalTime();

                                            String statusClass
                                                    = "BOOKED".equalsIgnoreCase(
                                                            schedule.getAvailabilityStatus()
                                                    )
                                                    ? "booked"
                                                    : "";
                                %>

                                <div class="slot-preview-item <%= statusClass%>">
                                    <%= startTime.format(timeFormatter)%>
                                    -
                                    <%= startTime.plusHours(1)
                                                    .format(timeFormatter)%>
                                    <br>
                                    <small>
                                        <%= schedule.getAvailabilityStatus()%>
                                    </small>
                                </div>

                                <%      }
                                        }
                                    }%>
                            </div>

                            <a class="secondary-button"
                               href="<%= request.getContextPath()%>/ScheduleServlet?action=details&date=<%= dateValue%>"
                               title="<%= cardDate.format(longDateFormatter)%>">
                                Details
                            </a>
                        </article>

                        <% }%>
                    </div>
                </section>
            </main>
        </div>
    </body>
</html>
