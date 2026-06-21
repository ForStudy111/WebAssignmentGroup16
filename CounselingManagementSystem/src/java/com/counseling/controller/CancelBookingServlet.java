package com.counseling.controller;

import com.counseling.dao.BookingDAO;
import com.counseling.dao.CounsellorDAO;
import com.counseling.dao.GoogleCalendarConnectionDAO;
import com.counseling.dao.ScheduleDAO;
import com.counseling.model.Booking;
import com.counseling.model.Counsellor;
import com.counseling.model.GoogleCalendarService;
import com.counseling.model.Schedule;
import com.counseling.model.User;
import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/CancelBookingServlet")
public class CancelBookingServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final ScheduleDAO scheduleDAO = new ScheduleDAO();
    private final CounsellorDAO counsellorDAO = new CounsellorDAO();

    private final GoogleCalendarConnectionDAO googleConnectionDAO
            = new GoogleCalendarConnectionDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        cancelBooking(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        cancelBooking(request, response);
    }

    private void cancelBooking(HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        int bookingId = getIntParameter(request, "id");

        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null) {
            redirectWithMessage(request, response, currentUser,
                    "Booking was not found.");
            return;
        }

        Schedule schedule = scheduleDAO.getScheduleById(
                booking.getScheduleId()
        );

        if (!canCancelBooking(currentUser, booking, schedule)) {
            redirectWithMessage(request, response, currentUser,
                    "You do not have permission to cancel this booking.");
            return;
        }

        String cancelledBy = currentUser.getRole().toUpperCase();

        boolean cancelled = bookingDAO.cancelBookingAndReleaseSchedule(
                bookingId,
                cancelledBy
        );

        if (!cancelled) {
            redirectWithMessage(request, response, currentUser,
                    "Booking cancellation failed.");
            return;
        }

        boolean hasGoogleEvent
                = "SYNCED".equalsIgnoreCase(
                        booking.getCalendarSyncStatus())
                && booking.getGoogleEventId() != null
                && !booking.getGoogleEventId().trim().isEmpty();

        if (!hasGoogleEvent) {
            redirectWithMessage(request, response, currentUser,
                    "Booking cancelled successfully.");
            return;
        }

        Counsellor appointmentCounsellor = schedule == null
                ? null
                : counsellorDAO.getCounsellorById(
                        schedule.getCounsellorId()
                );

        if (appointmentCounsellor == null
                || !googleConnectionDAO.isConnected(
                        appointmentCounsellor.getUserId())) {

            bookingDAO.updateGoogleCalendarInfo(
                    bookingId,
                    booking.getGoogleEventId(),
                    booking.getGoogleEventLink(),
                    "CANCEL_SYNC_FAILED"
            );

            redirectWithMessage(request, response, currentUser,
                    "Booking cancelled, but the Google Calendar event "
                    + "could not be removed.");
            return;
        }

        try {
            String refreshToken
                    = googleConnectionDAO.getRefreshToken(
                            appointmentCounsellor.getUserId()
                    );

            GoogleCalendarService calendarService
                    = new GoogleCalendarService(getServletContext());

            calendarService.deleteCounsellingEvent(
                    refreshToken,
                    booking.getGoogleEventId()
            );

            bookingDAO.updateGoogleCalendarInfo(
                    bookingId,
                    null,
                    null,
                    "EVENT_CANCELLED"
            );

            redirectWithMessage(request, response, currentUser,
                    "Booking cancelled and Google Calendar event removed.");

        } catch (IOException e) {
            e.printStackTrace();

            bookingDAO.updateGoogleCalendarInfo(
                    bookingId,
                    booking.getGoogleEventId(),
                    booking.getGoogleEventLink(),
                    "CANCEL_SYNC_FAILED"
            );

            redirectWithMessage(request, response, currentUser,
                    "Booking cancelled, but Google Calendar deletion failed.");
        }
    }

    private boolean canCancelBooking(User currentUser,
            Booking booking,
            Schedule schedule) {

        String status = booking.getBookingStatus();

        if (!"PENDING".equalsIgnoreCase(status)
                && !"APPROVED".equalsIgnoreCase(status)) {
            return false;
        }

        if ("STUDENT".equalsIgnoreCase(currentUser.getRole())) {
            return booking.getUserId() == currentUser.getUserId();
        }

        if ("COUNSELOR".equalsIgnoreCase(currentUser.getRole())) {
            Counsellor counsellor
                    = counsellorDAO.getCounsellorByUserId(
                            currentUser.getUserId()
                    );

            return "APPROVED".equalsIgnoreCase(status)
                    && counsellor != null
                    && schedule != null
                    && schedule.getCounsellorId()
                    == counsellor.getCounsellorId();
        }

        return "ADMIN".equalsIgnoreCase(currentUser.getRole());
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        return session == null
                ? null
                : (User) session.getAttribute("currentUser");
    }

    private int getIntParameter(HttpServletRequest request,
            String parameter) {

        try {
            return Integer.parseInt(request.getParameter(parameter));
        } catch (NumberFormatException e) {
            return 0;
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
            User currentUser,
            String message) throws IOException {

        String destination;

        if ("ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            destination = "/BookingServlet?action=adminList";

        } else if ("COUNSELOR".equalsIgnoreCase(
                currentUser.getRole())) {
            destination = "/BookingServlet?action=counsellorList";

        } else {
            destination = "/BookingServlet?action=myBookings";
        }

        response.sendRedirect(request.getContextPath()
                + destination
                + "&msg="
                + URLEncoder.encode(message, "UTF-8"));
    }
}
