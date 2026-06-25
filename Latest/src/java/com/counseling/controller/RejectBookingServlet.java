package com.counseling.controller;

import com.counseling.dao.BookingDAO;
import com.counseling.dao.CounsellorDAO;
import com.counseling.dao.ScheduleDAO;
import com.counseling.model.Booking;
import com.counseling.model.Counsellor;
import com.counseling.model.Schedule;
import com.counseling.model.User;
import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/RejectBookingServlet")
public class RejectBookingServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final ScheduleDAO scheduleDAO = new ScheduleDAO();
    private final CounsellorDAO counsellorDAO = new CounsellorDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (!"COUNSELOR".equalsIgnoreCase(currentUser.getRole())) {
            redirectToCounsellorBookings(request, response,
                    "Only counsellors can reject bookings.");
            return;
        }

        int bookingId = getIntParameter(request, "id");

        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null
                || !"PENDING".equalsIgnoreCase(
                        booking.getBookingStatus())) {

            redirectToCounsellorBookings(request, response,
                    "Only pending bookings can be rejected.");
            return;
        }

        Schedule schedule = scheduleDAO.getScheduleById(
                booking.getScheduleId()
        );

        Counsellor counsellor
                = counsellorDAO.getCounsellorByUserId(
                        currentUser.getUserId()
                );

        if (schedule == null
                || counsellor == null
                || schedule.getCounsellorId()
                != counsellor.getCounsellorId()) {

            redirectToCounsellorBookings(request, response,
                    "You cannot reject this booking.");
            return;
        }

        boolean rejected = bookingDAO.rejectBookingAndReleaseSchedule(
                bookingId
        );

        if (rejected) {
            redirectToCounsellorBookings(request, response,
                    "Booking rejected. The schedule slot is available again.");
        } else {
            redirectToCounsellorBookings(request, response,
                    "Booking rejection failed.");
        }
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

    private void redirectToCounsellorBookings(
            HttpServletRequest request,
            HttpServletResponse response,
            String message) throws IOException {

        response.sendRedirect(request.getContextPath()
                + "/BookingServlet?action=counsellorList&msg="
                + URLEncoder.encode(message, "UTF-8"));
    }
}
