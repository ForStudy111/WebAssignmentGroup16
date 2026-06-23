<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Schedule"%>
<%@page import="java.time.LocalDate"%>
<%@page import="java.time.LocalTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Collections"%>

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
    Schedule selectedSchedule = (Schedule) request.getAttribute("selectedSchedule");
    String returnDate = (String) request.getAttribute("returnDate");

    if (returnDate == null) {
        returnDate = "";
    }

    boolean isEdit = "edit".equals(formMode);

    String pageTitle = isEdit
            ? "Edit Availability"
            : "Add Availability";

    String dateValue = "";
    String timeValue = "";

    if (isEdit && selectedSchedule != null) {
        dateValue = selectedSchedule.getAvailableDate().toString();
        timeValue = selectedSchedule.getAvailableTime()
                .toLocalTime()
                .format(DateTimeFormatter.ofPattern("HH:mm"));
    }

    List<Schedule> existingSchedules
            = (List<Schedule>) request.getAttribute("existingSchedules");

    if (existingSchedules == null) {
        existingSchedules = Collections.emptyList();
    }

    String message = request.getParameter("msg");

    String[] fixedSlots = {
        "09:00", "10:00", "11:00",
        "14:00", "15:00", "16:00"
    };

    DateTimeFormatter displayTimeFormatter
            = DateTimeFormatter.ofPattern("hh:mm a");

    DateTimeFormatter dateLabelFormatter
            = DateTimeFormatter.ofPattern("EEE, MMM dd, yyyy");

    String cancelLink = isEdit && !returnDate.trim().isEmpty()
            ? request.getContextPath()
            + "/ScheduleServlet?action=details&date=" + returnDate
            : request.getContextPath()
            + "/ScheduleServlet?action=list";
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

        <style>
            .slot-toolbar {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 12px;
                margin: 6px 0 12px;
            }

            .slot-toolbar p {
                margin: 0;
                color: #607d7a;
                font-size: 13px;
            }

            .preset-slot-grid {
                display: grid;
                grid-template-columns: repeat(3, minmax(180px, 1fr));
                gap: 12px;
            }

            .preset-slot {
                display: flex;
                align-items: center;
                gap: 9px;
                min-height: 48px;
                padding: 10px 12px;
                border: 1px solid #cfe2df;
                border-radius: 8px;
                color: #315b57;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
            }

            .preset-slot input {
                width: auto;
                margin: 0;
            }

            .overlap-warning {
                display: none;
                margin-top: 14px;
                padding: 11px 13px;
                border: 1px solid #f1c2c2;
                border-radius: 8px;
                color: #a12f2f;
                background: #fff3f3;
                font-size: 13px;
                font-weight: 600;
            }

            .custom-help {
                margin: 0;
                color: #607d7a;
                font-size: 12px;
            }

            @media (max-width: 900px) {
                .preset-slot-grid {
                    grid-template-columns: repeat(2, minmax(0, 1fr));
                }
            }

            @media (max-width: 560px) {
                .preset-slot-grid {
                    grid-template-columns: 1fr;
                }

                .slot-toolbar {
                    align-items: flex-start;
                    flex-direction: column;
                }
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
                        <h1><%= pageTitle%></h1>
                        <p>
                            <%= isEdit
                                    ? "Update this unused one-hour availability slot."
                                    : "Create preset slots and one optional custom one-hour slot."%>
                        </p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-error">
                    <%= message%>
                </div>
                <% }%>

                <section class="card">
                    <form id="availabilityForm"
                          action="<%= request.getContextPath()%>/ScheduleServlet"
                          method="post"
                          class="validate-form"
                          novalidate>

                        <input type="hidden"
                               name="action"
                               value="<%= isEdit ? "update" : "create"%>" />

                        <% if (isEdit && selectedSchedule != null) {%>
                        <input type="hidden"
                               name="scheduleId"
                               value="<%= selectedSchedule.getScheduleId()%>" />
                        <% }%>

                        <% if (isEdit && !returnDate.trim().isEmpty()) {%>
                        <input type="hidden"
                               name="returnDate"
                               value="<%= returnDate%>" />
                        <% }%>

                        <div class="form-grid">
                            <div class="form-group full-width">
                                <label for="availableDate">Available Date *</label>

                                <select id="availableDate"
                                        name="availableDate"
                                        required
                                        data-label="Available date">

                                    <option value="">-- Select a Date --</option>

                                    <%
                                        LocalDate today = LocalDate.now();

                                        for (int i = 0; i < 7; i++) {
                                            LocalDate targetDate = today.plusDays(i);
                                            String dateString = targetDate.toString();

                                            String selectedAttribute
                                                    = dateString.equals(dateValue)
                                                    ? "selected"
                                                    : "";
                                    %>

                                    <option value="<%= dateString%>"
                                            <%= selectedAttribute%>>
                                        <%= targetDate.format(dateLabelFormatter)%>
                                    </option>

                                    <% }%>
                                </select>
                            </div>

                            <% if (isEdit) {%>

                            <div class="form-group full-width">
                                <label for="availableTime">Start Time *</label>

                                <input id="availableTime"
                                       name="availableTime"
                                       type="time"
                                       value="<%= timeValue%>"
                                       required
                                       data-label="Start time" />

                                <p class="custom-help">
                                    Every appointment slot lasts one hour.
                                </p>
                            </div>

                            <% } else {%>

                            <div class="form-group full-width">
                                <label>Preset One-Hour Slots</label>

                                <div class="slot-toolbar">
                                    <p>
                                        Choose common slots, then optionally add
                                        one custom one-hour slot below.
                                    </p>

                                    <button id="selectAllButton"
                                            type="button"
                                            class="secondary-button">
                                        Select All
                                    </button>
                                </div>

                                <div class="preset-slot-grid">
                                    <% for (String slot : fixedSlots) {
                                            LocalTime start = LocalTime.parse(slot);
                                            String displayText
                                                    = start.format(displayTimeFormatter)
                                                    + " - "
                                                    + start.plusHours(1)
                                                            .format(displayTimeFormatter);
                                    %>

                                    <label class="preset-slot">
                                        <input type="checkbox"
                                               name="presetTime"
                                               value="<%= slot%>" />
                                        <span><%= displayText%></span>
                                    </label>

                                    <% }%>
                                </div>
                            </div>

                            <div class="form-group full-width">
                                <label for="customTime">
                                    Custom One-Hour Slot (Optional)
                                </label>

                                <input id="customTime"
                                       name="customTime"
                                       type="time"
                                       data-label="Custom start time" />

                                <p class="custom-help">
                                    Example: choosing 10:30 AM creates
                                    10:30 AM - 11:30 AM.
                                </p>
                            </div>

                            <% }%>
                        </div>

                        <div id="overlapWarning" class="overlap-warning"></div>

                        <p class="form-help">
                            A slot is automatically available for booking after it is created.
                            Booked slots cannot be edited or deleted.
                        </p>

                        <div class="form-actions">
                            <button id="submitAvailability"
                                    type="submit"
                                    class="primary-button">
                                <%= isEdit
                                        ? "Update Availability"
                                        : "Create Availability"%>
                            </button>

                            <a class="secondary-button"
                               href="<%= cancelLink%>">
                                Cancel
                            </a>
                        </div>
                    </form>
                </section>
            </main>
        </div>

        <script src="<%= request.getContextPath()%>/js/validation.js"></script>

        <script>
            (function () {
                "use strict";

                const isEdit = <%= isEdit%>;
                const editingScheduleId =
            <%= selectedSchedule != null
                                ? selectedSchedule.getScheduleId()
                                : 0%>;

                const existingSlots = [
            <%
                        for (int i = 0; i < existingSchedules.size(); i++) {
                            Schedule schedule = existingSchedules.get(i);

                            String comma = i < existingSchedules.size() - 1
                                    ? ","
                                    : "";
            %>
                {
                id: <%= schedule.getScheduleId()%>,
                    date: "<%= schedule.getAvailableDate()%>",
                    time: "<%= schedule.getAvailableTime()
                                    .toLocalTime()
                                    .format(DateTimeFormatter.ofPattern("HH:mm"))%>"
                }<%= comma%>
            <% }%>
                ];

                const form = document.getElementById("availabilityForm");
                const dateField = document.getElementById("availableDate");
                const customTimeField = document.getElementById("customTime");
                const editTimeField = document.getElementById("availableTime");
                const presetCheckboxes = Array.from(
                        document.querySelectorAll('input[name="presetTime"]')
                        );

                const selectAllButton = document.getElementById("selectAllButton");
                const warning = document.getElementById("overlapWarning");
                const submitButton = document.getElementById("submitAvailability");

                function toMinutes(timeValue) {
                    if (!timeValue) {
                        return null;
                    }

                    const parts = timeValue.split(":");

                    return (Number(parts[0]) * 60) + Number(parts[1]);
                }

                function formatTime(minutes) {
                    const hour24 = Math.floor(minutes / 60) % 24;
                    const minute = minutes % 60;
                    const suffix = hour24 >= 12 ? "PM" : "AM";
                    const hour12 = hour24 % 12 || 12;

                    return String(hour12).padStart(2, "0")
                            + ":"
                            + String(minute).padStart(2, "0")
                            + " "
                            + suffix;
                }

                function slotsOverlap(firstStart, secondStart) {
                    const firstEnd = firstStart + 60;
                    const secondEnd = secondStart + 60;

                    return firstStart < secondEnd && firstEnd > secondStart;
                }

                function getCandidateTimes() {
                    const times = [];

                    if (isEdit) {
                        if (editTimeField && editTimeField.value) {
                            times.push({
                                time: editTimeField.value,
                                label: "edited slot"
                            });
                        }

                        return times;
                    }

                    presetCheckboxes.forEach(function (checkbox) {
                        if (checkbox.checked) {
                            times.push({
                                time: checkbox.value,
                                label: "selected preset slot"
                            });
                        }
                    });

                    if (customTimeField && customTimeField.value) {
                        times.push({
                            time: customTimeField.value,
                            label: "custom slot"
                        });
                    }

                    return times;
                }

                function showConflict(message) {
                    warning.textContent = message;
                    warning.style.display = "block";
                    submitButton.disabled = true;
                    submitButton.title = message;
                }

                function clearConflict() {
                    warning.textContent = "";
                    warning.style.display = "none";
                    submitButton.disabled = false;
                    submitButton.title = "";
                }

                function checkOverlap() {
                    clearConflict();

                    const selectedDate = dateField.value;
                    const candidates = getCandidateTimes();

                    if (!selectedDate || candidates.length === 0) {
                        return true;
                    }

                    for (let i = 0; i < candidates.length; i++) {
                        for (let j = i + 1; j < candidates.length; j++) {
                            const first = toMinutes(candidates[i].time);
                            const second = toMinutes(candidates[j].time);

                            if (first === second) {
                                showConflict(
                                        "The custom slot duplicates a selected preset slot."
                                        );
                                return false;
                            }

                            if (slotsOverlap(first, second)) {
                                showConflict(
                                        "The custom one-hour slot overlaps with a selected preset slot."
                                        );
                                return false;
                            }
                        }
                    }

                    for (const candidate of candidates) {
                        const candidateStart = toMinutes(candidate.time);
                        for (const existing of existingSlots) {
                            if (existing.id === editingScheduleId
                                    || existing.date !== selectedDate) {
                                continue;
                            }

                            if (slotsOverlap(
                                    candidateStart,
                                    toMinutes(existing.time))) {

                                showConflict(
                                        "This selection overlaps with an existing slot: "
                                        + formatTime(toMinutes(existing.time))
                                        + " - "
                                        + formatTime(toMinutes(existing.time) + 60)
                                        + "."
                                        );

                                return false;
                            }
                        }
                    }

                    return true;
                }

                if (selectAllButton) {
                    selectAllButton.addEventListener("click", function () {
                        const shouldSelectAll = presetCheckboxes.some(
                                function (checkbox) {
                                    return !checkbox.checked;
                                }
                        );

                        presetCheckboxes.forEach(function (checkbox) {
                            checkbox.checked = shouldSelectAll;
                        });

                        selectAllButton.textContent = shouldSelectAll
                                ? "Clear All"
                                : "Select All";

                        checkOverlap();
                    });
                }

                presetCheckboxes.forEach(function (checkbox) {
                    checkbox.addEventListener("change", checkOverlap);
                });

                if (customTimeField) {
                    customTimeField.addEventListener("input", checkOverlap);
                    customTimeField.addEventListener("change", checkOverlap);
                }

                if (editTimeField) {
                    editTimeField.addEventListener("input", checkOverlap);
                    editTimeField.addEventListener("change", checkOverlap);
                }

                dateField.addEventListener("change", checkOverlap);

                form.addEventListener("submit", function (event) {
                    if (!isEdit) {
                        const hasPreset = presetCheckboxes.some(
                                function (checkbox) {
                                    return checkbox.checked;
                                }
                        );

                        const hasCustom = customTimeField
                                && customTimeField.value;

                        if (!hasPreset && !hasCustom) {
                            event.preventDefault();
                            showConflict(
                                    "Select at least one preset slot or enter a custom start time."
                                    );
                            return;
                        }
                    }

                    if (!checkOverlap()) {
                        event.preventDefault();
                    }
                });

                checkOverlap();
            })();
        </script>
    </body>
</html>
