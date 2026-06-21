package com.counseling.controller;

import com.counseling.dao.GoogleCalendarConnectionDAO;
import com.counseling.model.GoogleCalendarService;
import com.counseling.dao.BookingDAO;
import com.counseling.dao.CounsellorDAO;
import com.counseling.dao.ScheduleDAO;
import com.counseling.dao.UserDAO;
import com.counseling.model.Booking;
import com.counseling.model.Counsellor;
import com.counseling.model.Schedule;
import com.counseling.model.User;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/BookingServlet")
public class BookingServlet extends HttpServlet {

    private final GoogleCalendarConnectionDAO googleCalendarConnectionDAO
            = new GoogleCalendarConnectionDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final ScheduleDAO scheduleDAO = new ScheduleDAO();
    private final CounsellorDAO counsellorDAO = new CounsellorDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "available";
        }

        switch (action) {
            case "available":
                showAvailableSchedules(request, response, currentUser);
                break;

            case "myBookings":
                showStudentBookings(request, response, currentUser);
                break;

            case "reschedule":
                showRescheduleForm(request, response, currentUser);
                break;

            case "cancel":
                cancelStudentBooking(request, response, currentUser);
                break;

            case "counsellorList":
                showCounsellorBookings(request, response, currentUser);
                break;

            case "approve":
                approveBooking(request, response, currentUser);
                break;

            case "counsellorCancel":
                cancelCounsellorBooking(request, response, currentUser);
                break;

            case "adminList":
                showAdminBookings(request, response, currentUser);
                break;

            case "adminCancel":
                cancelAdminBooking(request, response, currentUser);
                break;

            default:
                redirectToRoleDashboard(request, response, currentUser);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            createBooking(request, response, currentUser);

        } else if ("reschedule".equals(action)) {
            rescheduleBooking(request, response, currentUser);

        } else {
            redirectToRoleDashboard(request, response, currentUser);
        }
    }

    private void showAvailableSchedules(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser)
            throws ServletException, IOException {

        if (!isStudent(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        List<Schedule> allAvailableSchedules
                = scheduleDAO.getAvailableSchedules();

        List<Schedule> futureSchedules = new ArrayList<>();

        for (Schedule schedule : allAvailableSchedules) {
            if (!schedule.getAvailableDate()
                    .before(Date.valueOf(LocalDate.now()))) {

                futureSchedules.add(schedule);
            }
        }

        request.setAttribute("scheduleList", futureSchedules);
        request.setAttribute("counsellorMap",
                createCounsellorMapFromSchedules(futureSchedules));

        request.getRequestDispatcher("/student/book.jsp")
                .forward(request, response);
    }

    private void showStudentBookings(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser)
            throws ServletException, IOException {

        if (!isStudent(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        List<Booking> bookingList
                = bookingDAO.getBookingsByUserId(currentUser.getUserId());

        request.setAttribute("bookingList", bookingList);
        prepareBookingViewData(request, bookingList);

        request.getRequestDispatcher("/student/history.jsp")
                .forward(request, response);
    }

    private void showRescheduleForm(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser)
            throws ServletException, IOException {

        if (!isStudent(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int bookingId = getIntParameter(request, "id");

        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null
                || booking.getUserId() != currentUser.getUserId()) {

            redirectWithMessage(request, response,
                    "/BookingServlet?action=myBookings",
                    "Booking was not found.");
            return;
        }

        if (!"PENDING".equalsIgnoreCase(booking.getBookingStatus())) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=myBookings",
                    "Only pending bookings can be rescheduled.");
            return;
        }

        List<Schedule> availableSchedules
                = scheduleDAO.getAvailableSchedules();

        request.setAttribute("selectedBooking", booking);
        request.setAttribute("scheduleList", availableSchedules);
        request.setAttribute("counsellorMap",
                createCounsellorMapFromSchedules(availableSchedules));

        request.getRequestDispatcher("/student/reschedule.jsp")
                .forward(request, response);
    }

    private void createBooking(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser) throws IOException {

        if (!isStudent(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int scheduleId = getIntParameter(request, "scheduleId");

        Schedule schedule = scheduleDAO.getScheduleById(scheduleId);

        if (schedule == null
                || !"AVAILABLE".equalsIgnoreCase(
                        schedule.getAvailabilityStatus())) {

            redirectWithMessage(request, response,
                    "/BookingServlet?action=available",
                    "This schedule slot is no longer available.");
            return;
        }

        Booking booking = new Booking(
                currentUser.getUserId(),
                scheduleId,
                Date.valueOf(LocalDate.now()),
                "PENDING"
        );

        if (bookingDAO.addBooking(booking)) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=myBookings",
                    "Booking created successfully. Waiting for counsellor approval.");
        } else {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=available",
                    "Booking failed. The slot may have just been booked by another student.");
        }
    }

    private void rescheduleBooking(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser) throws IOException {

        if (!isStudent(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int bookingId = getIntParameter(request, "bookingId");
        int newScheduleId = getIntParameter(request, "newScheduleId");

        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null
                || booking.getUserId() != currentUser.getUserId()) {

            redirectWithMessage(request, response,
                    "/BookingServlet?action=myBookings",
                    "Booking was not found.");
            return;
        }

        if (!"PENDING".equalsIgnoreCase(booking.getBookingStatus())) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=myBookings",
                    "Only pending bookings can be rescheduled.");
            return;
        }

        if (bookingDAO.rescheduleBooking(bookingId, newScheduleId)) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=myBookings",
                    "Booking rescheduled successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=reschedule&id=" + bookingId,
                    "Rescheduling failed. Please choose another available slot.");
        }
    }

    private void cancelStudentBooking(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser) throws IOException {

        if (!isStudent(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int bookingId = getIntParameter(request, "id");

        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null
                || booking.getUserId() != currentUser.getUserId()) {

            redirectWithMessage(request, response,
                    "/BookingServlet?action=myBookings",
                    "Booking was not found.");
            return;
        }

        if (!"PENDING".equalsIgnoreCase(booking.getBookingStatus())) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=myBookings",
                    "Only pending bookings can be cancelled.");
            return;
        }

        if (bookingDAO.cancelBooking(bookingId)) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=myBookings",
                    "Booking cancelled successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=myBookings",
                    "Booking cancellation failed.");
        }
    }

    private void showCounsellorBookings(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser)
            throws ServletException, IOException {

        if (!isCounselor(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        Counsellor counsellor
                = counsellorDAO.getCounsellorByUserId(currentUser.getUserId());

        if (counsellor == null) {
            redirectWithMessage(request, response,
                    "/counselor/dashboard.jsp",
                    "Counsellor profile was not found.");
            return;
        }

        List<Booking> bookingList
                = bookingDAO.getBookingsByCounsellorId(
                        counsellor.getCounsellorId()
                );

        request.setAttribute("bookingList", bookingList);
        prepareBookingViewData(request, bookingList);

        request.getRequestDispatcher("/counselor/manage.jsp")
                .forward(request, response);
    }

    private void approveBooking(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser) throws IOException {

        if (!isCounselor(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int bookingId = getIntParameter(request, "id");

        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Booking was not found.");
            return;
        }

        Counsellor counsellor
                = counsellorDAO.getCounsellorByUserId(currentUser.getUserId());

        Schedule schedule
                = scheduleDAO.getScheduleById(booking.getScheduleId());

        if (counsellor == null
                || schedule == null
                || schedule.getCounsellorId()
                != counsellor.getCounsellorId()) {

            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "You cannot approve this booking.");
            return;
        }

        if (!"PENDING".equalsIgnoreCase(booking.getBookingStatus())) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Only pending bookings can be approved.");
            return;
        }

        boolean approved = bookingDAO.updateBookingStatus(
                bookingId,
                "APPROVED"
        );

        if (!approved) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Booking approval failed.");
            return;
        }

        User student = userDAO.getUserById(booking.getUserId());

        if (student == null) {
            bookingDAO.updateGoogleCalendarInfo(
                    bookingId,
                    null,
                    null,
                    "FAILED"
            );

            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Booking approved, but student details could not be loaded.");
            return;
        }

        if (!googleCalendarConnectionDAO.isConnected(
                currentUser.getUserId())) {

            bookingDAO.updateGoogleCalendarInfo(
                    bookingId,
                    null,
                    null,
                    "NOT_CONNECTED"
            );

            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Booking approved. Google Calendar is not connected.");
            return;
        }

        try {
            String refreshToken
                    = googleCalendarConnectionDAO.getRefreshToken(
                            currentUser.getUserId()
                    );

            GoogleCalendarService calendarService
                    = new GoogleCalendarService(getServletContext());

            GoogleCalendarService.CalendarEventResult eventResult
                    = calendarService.createCounsellingEvent(
                            refreshToken,
                            schedule,
                            counsellor,
                            student,
                            bookingId
                    );

            boolean calendarSaved
                    = bookingDAO.updateGoogleCalendarInfo(
                            bookingId,
                            eventResult.getEventId(),
                            eventResult.getEventLink(),
                            "SYNCED"
                    );

            if (calendarSaved) {
                redirectWithMessage(request, response,
                        "/BookingServlet?action=counsellorList",
                        "Booking approved and Google Calendar invitation sent.");
            } else {
                redirectWithMessage(request, response,
                        "/BookingServlet?action=counsellorList",
                        "Booking approved and calendar event created, "
                        + "but its link could not be saved.");
            }

        } catch (IOException e) {
            e.printStackTrace();

            bookingDAO.updateGoogleCalendarInfo(
                    bookingId,
                    null,
                    null,
                    "FAILED"
            );

            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Booking approved, but Google Calendar event creation failed.");
        }
    }

    private void cancelCounsellorBooking(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser) throws IOException {

        if (!isCounselor(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int bookingId = getIntParameter(request, "id");

        if (!isBookingOwnedByCounsellor(bookingId, currentUser.getUserId())) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Booking was not found.");
            return;
        }

        if (bookingDAO.cancelBooking(bookingId)) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Booking cancelled and slot reopened.");
        } else {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Booking cancellation failed.");
        }
    }

    private void showAdminBookings(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser)
            throws ServletException, IOException {

        if (!isAdmin(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        List<Booking> bookingList = bookingDAO.getAllBookings();

        request.setAttribute("bookingList", bookingList);
        prepareBookingViewData(request, bookingList);

        request.getRequestDispatcher("/admin/bookings.jsp")
                .forward(request, response);
    }

    private void cancelAdminBooking(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser) throws IOException {

        if (!isAdmin(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int bookingId = getIntParameter(request, "id");

        if (bookingDAO.cancelBooking(bookingId)) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=adminList",
                    "Booking cancelled and slot reopened.");
        } else {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=adminList",
                    "Booking cancellation failed.");
        }
    }

    private void prepareBookingViewData(HttpServletRequest request,
            List<Booking> bookingList) {

        Map<Integer, Schedule> scheduleMap = new HashMap<>();
        Map<Integer, Counsellor> counsellorMap = new HashMap<>();
        Map<Integer, User> studentMap = new HashMap<>();

        for (Booking booking : bookingList) {
            Schedule schedule
                    = scheduleDAO.getScheduleById(booking.getScheduleId());

            if (schedule != null) {
                scheduleMap.put(schedule.getScheduleId(), schedule);

                if (!counsellorMap.containsKey(
                        schedule.getCounsellorId())) {

                    Counsellor counsellor = counsellorDAO
                            .getCounsellorById(
                                    schedule.getCounsellorId()
                            );

                    if (counsellor != null) {
                        counsellorMap.put(
                                counsellor.getCounsellorId(),
                                counsellor
                        );
                    }
                }
            }

            if (!studentMap.containsKey(booking.getUserId())) {
                User student = userDAO.getUserById(booking.getUserId());

                if (student != null) {
                    studentMap.put(student.getUserId(), student);
                }
            }
        }

        request.setAttribute("scheduleMap", scheduleMap);
        request.setAttribute("counsellorMap", counsellorMap);
        request.setAttribute("studentMap", studentMap);
    }

    private Map<Integer, Counsellor> createCounsellorMapFromSchedules(
            List<Schedule> scheduleList) {

        Map<Integer, Counsellor> counsellorMap = new HashMap<>();

        for (Schedule schedule : scheduleList) {
            int counsellorId = schedule.getCounsellorId();

            if (!counsellorMap.containsKey(counsellorId)) {
                Counsellor counsellor
                        = counsellorDAO.getCounsellorById(counsellorId);

                if (counsellor != null) {
                    counsellorMap.put(counsellorId, counsellor);
                }
            }
        }

        return counsellorMap;
    }

    private boolean isBookingOwnedByCounsellor(int bookingId, int userId) {
        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null) {
            return false;
        }

        Schedule schedule
                = scheduleDAO.getScheduleById(booking.getScheduleId());

        if (schedule == null) {
            return false;
        }

        Counsellor counsellor
                = counsellorDAO.getCounsellorByUserId(userId);

        return counsellor != null
                && schedule.getCounsellorId()
                == counsellor.getCounsellorId();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return null;
        }

        return (User) session.getAttribute("currentUser");
    }

    private boolean isStudent(User user) {
        return user != null
                && "STUDENT".equalsIgnoreCase(user.getRole());
    }

    private boolean isCounselor(User user) {
        return user != null
                && "COUNSELOR".equalsIgnoreCase(user.getRole());
    }

    private boolean isAdmin(User user) {
        return user != null
                && "ADMIN".equalsIgnoreCase(user.getRole());
    }

    private int getIntParameter(HttpServletRequest request,
            String parameter) {

        try {
            return Integer.parseInt(request.getParameter(parameter));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private void redirectToRoleDashboard(HttpServletRequest request,
            HttpServletResponse response,
            User user) throws IOException {

        String contextPath = request.getContextPath();

        if (isAdmin(user)) {
            response.sendRedirect(contextPath + "/admin/dashboard.jsp");

        } else if (isCounselor(user)) {
            response.sendRedirect(contextPath + "/counselor/dashboard.jsp");

        } else {
            response.sendRedirect(contextPath + "/student/dashboard.jsp");
        }
    }

    private void redirectToLogin(HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        response.sendRedirect(request.getContextPath()
                + "/login.jsp?error=true&msg="
                + URLEncoder.encode("Please log in first.", "UTF-8"));
    }

    private void redirectWithMessage(HttpServletRequest request,
            HttpServletResponse response,
            String destination,
            String message) throws IOException {

        String separator = destination.contains("?") ? "&" : "?";

        response.sendRedirect(request.getContextPath()
                + destination
                + separator
                + "msg="
                + URLEncoder.encode(message, "UTF-8"));
    }
}
