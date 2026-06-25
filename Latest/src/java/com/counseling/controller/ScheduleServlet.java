package com.counseling.controller;

import com.counseling.dao.CounsellorDAO;
import com.counseling.dao.ScheduleDAO;
import com.counseling.model.Counsellor;
import com.counseling.model.Schedule;
import com.counseling.model.User;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/ScheduleServlet")
public class ScheduleServlet extends HttpServlet {

    private final ScheduleDAO scheduleDAO = new ScheduleDAO();
    private final CounsellorDAO counsellorDAO = new CounsellorDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (!isCounselor(currentUser)) {
            redirectToLogin(request, response);
            return;
        }

        Counsellor counsellor = counsellorDAO.getCounsellorByUserId(
                currentUser.getUserId()
        );

        if (counsellor == null) {
            redirectWithMessage(request, response,
                    "/counselor/dashboard.jsp",
                    "Counsellor profile was not found.");
            return;
        }

        String action = getValue(request, "action");

        if (action.isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "list":
                showWeeklyAvailability(request, response, counsellor);
                break;

            case "details":
                showDayDetails(request, response, counsellor);
                break;

            case "new":
                showCreateForm(request, response, counsellor);
                break;

            case "edit":
                showEditForm(request, response, counsellor);
                break;

            case "delete":
                deleteSchedule(request, response, counsellor);
                break;

            default:
                response.sendRedirect(
                        request.getContextPath()
                        + "/ScheduleServlet?action=list"
                );
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (!isCounselor(currentUser)) {
            redirectToLogin(request, response);
            return;
        }

        Counsellor counsellor = counsellorDAO.getCounsellorByUserId(
                currentUser.getUserId()
        );

        if (counsellor == null) {
            redirectToLogin(request, response);
            return;
        }

        String action = getValue(request, "action");

        if ("create".equals(action)) {
            createSchedules(request, response, counsellor);

        } else if ("update".equals(action)) {
            updateSchedule(request, response, counsellor);

        } else {
            response.sendRedirect(
                    request.getContextPath()
                    + "/ScheduleServlet?action=list"
            );
        }
    }

    // Weekly card page: today plus the next six days.
    private void showWeeklyAvailability(HttpServletRequest request,
            HttpServletResponse response,
            Counsellor counsellor)
            throws ServletException, IOException {

        request.setAttribute("scheduleList",
                scheduleDAO.getSchedulesByCounsellorId(
                        counsellor.getCounsellorId()
                ));

        request.getRequestDispatcher("/counselor/availability.jsp")
                .forward(request, response);
    }

    // Daily detail page: only slots for the selected date.
    private void showDayDetails(HttpServletRequest request,
            HttpServletResponse response,
            Counsellor counsellor)
            throws ServletException, IOException {

        String dateValue = getValue(request, "date");

        if (!isValidDate(dateValue)) {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=list",
                    "Please select a valid availability date.");
            return;
        }

        Date selectedDate = Date.valueOf(dateValue);
        List<Schedule> allSchedules = scheduleDAO.getSchedulesByCounsellorId(
                counsellor.getCounsellorId()
        );
        List<Schedule> daySchedules = new ArrayList<>();

        for (Schedule schedule : allSchedules) {
            if (selectedDate.equals(schedule.getAvailableDate())) {
                daySchedules.add(schedule);
            }
        }

        request.setAttribute("selectedDate", dateValue);
        request.setAttribute("scheduleList", daySchedules);

        request.getRequestDispatcher("/counselor/schedule-details.jsp")
                .forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request,
            HttpServletResponse response,
            Counsellor counsellor)
            throws ServletException, IOException {

        request.setAttribute("formMode", "create");
        request.setAttribute("returnDate", getValue(request, "returnDate"));
        request.setAttribute("existingSchedules",
                scheduleDAO.getSchedulesByCounsellorId(
                        counsellor.getCounsellorId()
                ));

        request.getRequestDispatcher("/counselor/schedule-form.jsp")
                .forward(request, response);
    }

    private void showEditForm(HttpServletRequest request,
            HttpServletResponse response,
            Counsellor counsellor)
            throws ServletException, IOException {

        int scheduleId = getIntParameter(request, "id");
        Schedule schedule = scheduleDAO.getScheduleById(scheduleId);

        if (schedule == null
                || schedule.getCounsellorId() != counsellor.getCounsellorId()) {

            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=list",
                    "Schedule was not found.");
            return;
        }

        if ("BOOKED".equalsIgnoreCase(schedule.getAvailabilityStatus())) {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=list",
                    "Booked schedules cannot be edited.");
            return;
        }

        String returnDate = getValue(request, "returnDate");

        if (!isValidDate(returnDate)) {
            returnDate = schedule.getAvailableDate().toString();
        }

        request.setAttribute("formMode", "edit");
        request.setAttribute("selectedSchedule", schedule);
        request.setAttribute("returnDate", returnDate);
        request.setAttribute("existingSchedules",
                scheduleDAO.getSchedulesByCounsellorId(
                        counsellor.getCounsellorId()
                ));

        request.getRequestDispatcher("/counselor/schedule-form.jsp")
                .forward(request, response);
    }

    /*
     * Creates selected preset slots and one optional custom one-hour slot.
     * The final DAO check prevents overlap even if JavaScript is bypassed.
     */
    private void createSchedules(HttpServletRequest request,
            HttpServletResponse response,
            Counsellor counsellor) throws IOException {

        String dateValue = getValue(request, "availableDate");
        String[] presetValues = request.getParameterValues("presetTime");
        String customTimeValue = getValue(request, "customTime");

        if (dateValue.isEmpty()) {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=new",
                    "Please select an available date.");
            return;
        }

        if ((presetValues == null || presetValues.length == 0)
                && customTimeValue.isEmpty()) {

            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=new",
                    "Please select a preset slot or enter a custom start time.");
            return;
        }

        try {
            LocalDate localDate = LocalDate.parse(dateValue);

            if (localDate.isBefore(LocalDate.now())) {
                redirectWithMessage(request, response,
                        "/ScheduleServlet?action=new",
                        "Please select today or a future date.");
                return;
            }

            Set<LocalTime> presetTimes = new LinkedHashSet<>();

            if (presetValues != null) {
                for (String presetValue : presetValues) {
                    presetTimes.add(LocalTime.parse(presetValue));
                }
            }

            LocalTime customTime = null;

            if (!customTimeValue.isEmpty()) {
                customTime = LocalTime.parse(customTimeValue);

                if (presetTimes.contains(customTime)) {
                    redirectWithMessage(request, response,
                            "/ScheduleServlet?action=new",
                            "Custom slot duplicates one of the selected preset slots.");
                    return;
                }
            }

            List<LocalTime> candidateTimes = new ArrayList<>(presetTimes);

            if (customTime != null) {
                candidateTimes.add(customTime);
            }

            String internalConflict = findInternalOverlap(candidateTimes);

            if (internalConflict != null) {
                redirectWithMessage(request, response,
                        "/ScheduleServlet?action=new",
                        internalConflict);
                return;
            }

            Date availableDate = Date.valueOf(localDate);

            for (LocalTime candidateTime : candidateTimes) {
                if (scheduleDAO.hasOverlappingSchedule(
                        counsellor.getCounsellorId(),
                        availableDate,
                        Time.valueOf(candidateTime),
                        0)) {

                    redirectWithMessage(request, response,
                            "/ScheduleServlet?action=new",
                            "A selected slot overlaps with an existing slot on "
                            + localDate + ".");
                    return;
                }
            }

            int successCount = 0;

            for (LocalTime candidateTime : candidateTimes) {
                Schedule schedule = new Schedule(
                        counsellor.getCounsellorId(),
                        availableDate,
                        Time.valueOf(candidateTime),
                        "AVAILABLE"
                );

                if (scheduleDAO.addSchedule(schedule)) {
                    successCount++;
                }
            }

            if (successCount == candidateTimes.size()) {
                redirectWithMessage(request, response,
                        "/ScheduleServlet?action=details&date=" + dateValue,
                        "Successfully created "
                        + successCount + " availability slot(s).");

            } else {
                redirectWithMessage(request, response,
                        "/ScheduleServlet?action=new",
                        "Some slots could not be created. Please try again.");
            }

        } catch (Exception e) {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=new",
                    "Please enter a valid date and time.");
        }
    }

    private void updateSchedule(HttpServletRequest request,
            HttpServletResponse response,
            Counsellor counsellor) throws IOException {

        int scheduleId = getIntParameter(request, "scheduleId");
        Schedule existingSchedule = scheduleDAO.getScheduleById(scheduleId);

        if (existingSchedule == null
                || existingSchedule.getCounsellorId()
                != counsellor.getCounsellorId()) {

            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=list",
                    "Schedule was not found.");
            return;
        }

        String returnDate = getValue(request, "returnDate");

        if (!isValidDate(returnDate)) {
            returnDate = existingSchedule.getAvailableDate().toString();
        }

        if ("BOOKED".equalsIgnoreCase(
                existingSchedule.getAvailabilityStatus())) {

            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=details&date=" + returnDate,
                    "Booked schedules cannot be edited.");
            return;
        }

        Schedule updatedSchedule = createUpdatedSchedule(
                request, counsellor, existingSchedule.getAvailabilityStatus()
        );

        if (updatedSchedule == null) {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=edit&id=" + scheduleId
                    + "&returnDate=" + returnDate,
                    "Please enter a valid date and time.");
            return;
        }

        if (scheduleDAO.hasOverlappingSchedule(
                counsellor.getCounsellorId(),
                updatedSchedule.getAvailableDate(),
                updatedSchedule.getAvailableTime(),
                scheduleId)) {

            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=edit&id=" + scheduleId
                    + "&returnDate=" + returnDate,
                    "This slot overlaps with another slot on the selected date.");
            return;
        }

        updatedSchedule.setScheduleId(scheduleId);

        if (scheduleDAO.updateSchedule(updatedSchedule)) {
            String updatedDate = updatedSchedule.getAvailableDate().toString();

            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=details&date=" + updatedDate,
                    "Schedule updated successfully.");

        } else {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=edit&id=" + scheduleId
                    + "&returnDate=" + returnDate,
                    "Schedule update failed.");
        }
    }

    private void deleteSchedule(HttpServletRequest request,
            HttpServletResponse response,
            Counsellor counsellor) throws IOException {

        int scheduleId = getIntParameter(request, "id");
        Schedule schedule = scheduleDAO.getScheduleById(scheduleId);
        String returnDate = getValue(request, "returnDate");

        if (!isValidDate(returnDate) && schedule != null) {
            returnDate = schedule.getAvailableDate().toString();
        }

        if (schedule == null
                || schedule.getCounsellorId() != counsellor.getCounsellorId()) {

            redirectWithMessage(request, response,
                    getDetailsOrListDestination(returnDate),
                    "Schedule was not found.");
            return;
        }

        if ("BOOKED".equalsIgnoreCase(
                schedule.getAvailabilityStatus())) {

            redirectWithMessage(request, response,
                    getDetailsOrListDestination(returnDate),
                    "Booked schedules cannot be deleted.");
            return;
        }

        if (scheduleDAO.deleteSchedule(scheduleId)) {
            redirectWithMessage(request, response,
                    getDetailsOrListDestination(returnDate),
                    "Schedule deleted successfully.");

        } else {
            redirectWithMessage(request, response,
                    getDetailsOrListDestination(returnDate),
                    "Schedule deletion failed.");
        }
    }

    private String getDetailsOrListDestination(String dateValue) {
        if (isValidDate(dateValue)) {
            return "/ScheduleServlet?action=details&date=" + dateValue;
        }

        return "/ScheduleServlet?action=list";
    }

    private Schedule createUpdatedSchedule(HttpServletRequest request,
            Counsellor counsellor,
            String existingStatus) {

        try {
            String dateValue = getValue(request, "availableDate");
            String timeValue = getValue(request, "availableTime");

            if (dateValue.isEmpty() || timeValue.isEmpty()) {
                return null;
            }

            LocalDate localDate = LocalDate.parse(dateValue);

            if (localDate.isBefore(LocalDate.now())) {
                return null;
            }

            LocalTime localTime = LocalTime.parse(timeValue);

            return new Schedule(
                    counsellor.getCounsellorId(),
                    Date.valueOf(localDate),
                    Time.valueOf(localTime),
                    existingStatus
            );

        } catch (Exception e) {
            return null;
        }
    }

    private String findInternalOverlap(List<LocalTime> candidateTimes) {
        for (int i = 0; i < candidateTimes.size(); i++) {
            for (int j = i + 1; j < candidateTimes.size(); j++) {
                if (timesOverlap(candidateTimes.get(i), candidateTimes.get(j))) {
                    return "The selected preset slot and custom slot overlap.";
                }
            }
        }

        return null;
    }

    private boolean timesOverlap(LocalTime firstStart,
            LocalTime secondStart) {

        LocalTime firstEnd = firstStart.plusHours(1);
        LocalTime secondEnd = secondStart.plusHours(1);

        return firstStart.isBefore(secondEnd)
                && firstEnd.isAfter(secondStart);
    }

    private boolean isValidDate(String dateValue) {
        try {
            LocalDate.parse(dateValue);
            return true;

        } catch (Exception e) {
            return false;
        }
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        return (User) session.getAttribute("currentUser");
    }

    private boolean isCounselor(User user) {
        return user != null
                && "COUNSELOR".equalsIgnoreCase(user.getRole());
    }

    private int getIntParameter(HttpServletRequest request,
            String parameter) {

        try {
            return Integer.parseInt(request.getParameter(parameter));

        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private String getValue(HttpServletRequest request,
            String parameter) {

        String value = request.getParameter(parameter);

        return value == null ? "" : value.trim();
    }

    private void redirectToLogin(HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg="
                + URLEncoder.encode(
                        "Please log in as a counsellor first.",
                        "UTF-8"
                )
        );
    }

    private void redirectWithMessage(HttpServletRequest request,
            HttpServletResponse response,
            String destination,
            String message) throws IOException {

        String separator = destination.contains("?") ? "&" : "?";

        response.sendRedirect(
                request.getContextPath()
                + destination
                + separator
                + "msg="
                + URLEncoder.encode(message, "UTF-8")
        );
    }

    @Override
    public String getServletInfo() {
        return "Schedule management servlet";
    }
}
