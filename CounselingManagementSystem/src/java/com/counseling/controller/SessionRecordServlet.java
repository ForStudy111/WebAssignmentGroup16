/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.counseling.controller;

import com.counseling.dao.BookingDAO;
import com.counseling.dao.CounsellorDAO;
import com.counseling.dao.ScheduleDAO;
import com.counseling.dao.SessionRecordDAO;
import com.counseling.dao.UserDAO;
import com.counseling.model.Booking;
import com.counseling.model.Counsellor;
import com.counseling.model.Schedule;
import com.counseling.model.SessionRecord;
import com.counseling.model.User;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SessionRecordServlet")
public class SessionRecordServlet extends HttpServlet {

    private final SessionRecordDAO sessionRecordDAO = new SessionRecordDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final ScheduleDAO scheduleDAO = new ScheduleDAO();
    private final CounsellorDAO counsellorDAO = new CounsellorDAO();
    private final UserDAO userDAO = new UserDAO();

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet SessionRecordServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet SessionRecordServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            if (isCounselor(currentUser)) {
                action = "counsellorList";
            } else if (isStudent(currentUser)) {
                action = "studentHistory";
            } else {
                redirectToRoleDashboard(request, response, currentUser);
                return;
            }
        }

        switch (action) {
            case "counsellorList":
                showCounsellorRecords(request, response, currentUser);
                break;

            case "new":
                showCreateRecordForm(request, response, currentUser);
                break;

            case "edit":
                showEditRecordForm(request, response, currentUser);
                break;

            case "delete":
                deleteRecord(request, response, currentUser);
                break;

            case "studentHistory":
                showStudentHistory(request, response, currentUser);
                break;

            case "feedback":
                showFeedbackForm(request, response, currentUser);
                break;

            default:
                redirectToRoleDashboard(request, response, currentUser);
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        User currentUser = getCurrentUser(request);

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            createRecord(request, response, currentUser);

        } else if ("update".equals(action)) {
            updateRecord(request, response, currentUser);

        } else if ("submitFeedback".equals(action)) {
            submitFeedback(request, response, currentUser);

        } else {
            redirectToRoleDashboard(request, response, currentUser);
        }
    }

    private void showCounsellorRecords(HttpServletRequest request,
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

        List<SessionRecord> recordList
                = sessionRecordDAO.getRecordsByCounsellorId(
                        counsellor.getCounsellorId()
                );

        request.setAttribute("recordList", recordList);
        prepareRecordViewData(request, recordList);

        request.getRequestDispatcher("/counselor/records.jsp")
                .forward(request, response);
    }

    private void showCreateRecordForm(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser)
            throws ServletException, IOException {

        if (!isCounselor(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int bookingId = getIntParameter(request, "bookingId");

        if (!isBookingOwnedByCounsellor(bookingId, currentUser.getUserId())) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Booking was not found.");
            return;
        }

        Booking booking = bookingDAO.getBookingById(bookingId);

        if (!"APPROVED".equalsIgnoreCase(booking.getBookingStatus())) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Only approved bookings can have session records.");
            return;
        }

        if (sessionRecordDAO.getSessionRecordByBookingId(bookingId) != null) {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=counsellorList",
                    "A session record already exists for this booking.");
            return;
        }

        Schedule schedule = scheduleDAO.getScheduleById(booking.getScheduleId());
        User student = userDAO.getUserById(booking.getUserId());

        request.setAttribute("selectedBooking", booking);
        request.setAttribute("selectedSchedule", schedule);
        request.setAttribute("selectedStudent", student);
        request.setAttribute("formMode", "create");

        request.getRequestDispatcher("/counselor/session-record-form.jsp")
                .forward(request, response);
    }

    private void showEditRecordForm(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser)
            throws ServletException, IOException {

        if (!isCounselor(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int recordId = getIntParameter(request, "id");

        SessionRecord record
                = sessionRecordDAO.getSessionRecordById(recordId);

        if (!isRecordOwnedByCounsellor(record, currentUser.getUserId())) {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=counsellorList",
                    "Session record was not found.");
            return;
        }

        Booking booking = bookingDAO.getBookingById(record.getBookingId());
        Schedule schedule = booking == null
                ? null
                : scheduleDAO.getScheduleById(booking.getScheduleId());

        User student = booking == null
                ? null
                : userDAO.getUserById(booking.getUserId());

        request.setAttribute("selectedRecord", record);
        request.setAttribute("selectedBooking", booking);
        request.setAttribute("selectedSchedule", schedule);
        request.setAttribute("selectedStudent", student);
        request.setAttribute("formMode", "edit");

        request.getRequestDispatcher("/counselor/session-record-form.jsp")
                .forward(request, response);
    }

    private void createRecord(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser) throws IOException {

        if (!isCounselor(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int bookingId = getIntParameter(request, "bookingId");
        String sessionNotes = getValue(request, "sessionNotes");

        if (sessionNotes.isEmpty()) {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=new&bookingId=" + bookingId,
                    "Session notes cannot be empty.");
            return;
        }

        if (!isBookingOwnedByCounsellor(bookingId, currentUser.getUserId())) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Booking was not found.");
            return;
        }

        Booking booking = bookingDAO.getBookingById(bookingId);

        if (!"APPROVED".equalsIgnoreCase(booking.getBookingStatus())) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Only approved bookings can have session records.");
            return;
        }

        Counsellor counsellor
                = counsellorDAO.getCounsellorByUserId(currentUser.getUserId());

        Schedule schedule = scheduleDAO.getScheduleById(booking.getScheduleId());

        if (counsellor == null || schedule == null) {
            redirectWithMessage(request, response,
                    "/BookingServlet?action=counsellorList",
                    "Booking details could not be loaded.");
            return;
        }

        SessionRecord record = new SessionRecord(
                bookingId,
                counsellor.getCounsellorId(),
                sessionNotes,
                schedule.getAvailableDate()
        );

        if (sessionRecordDAO.addSessionRecord(record)) {
            bookingDAO.updateBookingStatus(bookingId, "COMPLETED");

            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=counsellorList",
                    "Session record saved successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=new&bookingId=" + bookingId,
                    "Session record creation failed.");
        }
    }

    private void updateRecord(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser) throws IOException {

        if (!isCounselor(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int recordId = getIntParameter(request, "recordId");
        String sessionNotes = getValue(request, "sessionNotes");

        SessionRecord record
                = sessionRecordDAO.getSessionRecordById(recordId);

        if (!isRecordOwnedByCounsellor(record, currentUser.getUserId())) {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=counsellorList",
                    "Session record was not found.");
            return;
        }

        if (sessionNotes.isEmpty()) {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=edit&id=" + recordId,
                    "Session notes cannot be empty.");
            return;
        }

        if (sessionRecordDAO.updateSessionNotes(recordId, sessionNotes)) {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=counsellorList",
                    "Session notes updated successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=edit&id=" + recordId,
                    "Session record update failed.");
        }
    }

    private void deleteRecord(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser) throws IOException {

        if (!isCounselor(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int recordId = getIntParameter(request, "id");

        SessionRecord record
                = sessionRecordDAO.getSessionRecordById(recordId);

        if (!isRecordOwnedByCounsellor(record, currentUser.getUserId())) {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=counsellorList",
                    "Session record was not found.");
            return;
        }

        if (sessionRecordDAO.deleteSessionRecord(recordId)) {
            bookingDAO.updateBookingStatus(record.getBookingId(), "APPROVED");

            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=counsellorList",
                    "Session record deleted successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=counsellorList",
                    "Session record deletion failed.");
        }
    }

    private void showStudentHistory(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser)
            throws ServletException, IOException {

        if (!isStudent(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        List<SessionRecord> recordList
                = sessionRecordDAO.getRecordsByUserId(currentUser.getUserId());

        request.setAttribute("recordList", recordList);
        prepareRecordViewData(request, recordList);

        request.getRequestDispatcher("/student/session-history.jsp")
                .forward(request, response);
    }

    private void showFeedbackForm(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser)
            throws ServletException, IOException {

        if (!isStudent(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int recordId = getIntParameter(request, "id");

        SessionRecord record
                = sessionRecordDAO.getSessionRecordById(recordId);

        if (!isRecordOwnedByStudent(record, currentUser.getUserId())) {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=studentHistory",
                    "Session record was not found.");
            return;
        }

        request.setAttribute("selectedRecord", record);

        request.getRequestDispatcher("/student/feedback-form.jsp")
                .forward(request, response);
    }

    private void submitFeedback(HttpServletRequest request,
            HttpServletResponse response,
            User currentUser) throws IOException {

        if (!isStudent(currentUser)) {
            redirectToRoleDashboard(request, response, currentUser);
            return;
        }

        int recordId = getIntParameter(request, "recordId");
        String feedback = getValue(request, "feedback");
        int rating = getIntParameter(request, "rating");

        SessionRecord record
                = sessionRecordDAO.getSessionRecordById(recordId);

        if (!isRecordOwnedByStudent(record, currentUser.getUserId())) {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=studentHistory",
                    "Session record was not found.");
            return;
        }

        if (feedback.isEmpty() || rating < 1 || rating > 5) {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=feedback&id=" + recordId,
                    "Please provide feedback and a rating from 1 to 5.");
            return;
        }

        if (sessionRecordDAO.updateFeedback(recordId, feedback, rating)) {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=studentHistory",
                    "Feedback submitted successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/SessionRecordServlet?action=feedback&id=" + recordId,
                    "Feedback submission failed.");
        }
    }

    private void prepareRecordViewData(HttpServletRequest request,
            List<SessionRecord> recordList) {

        Map<Integer, Booking> bookingMap = new HashMap<>();
        Map<Integer, Schedule> scheduleMap = new HashMap<>();
        Map<Integer, Counsellor> counsellorMap = new HashMap<>();
        Map<Integer, User> studentMap = new HashMap<>();

        for (SessionRecord record : recordList) {
            Booking booking = bookingDAO.getBookingById(record.getBookingId());

            if (booking == null) {
                continue;
            }

            bookingMap.put(booking.getBookingId(), booking);

            Schedule schedule = scheduleDAO.getScheduleById(
                    booking.getScheduleId()
            );

            if (schedule != null) {
                scheduleMap.put(schedule.getScheduleId(), schedule);
            }

            Counsellor counsellor = counsellorDAO.getCounsellorById(
                    record.getCounsellorId()
            );

            if (counsellor != null) {
                counsellorMap.put(
                        counsellor.getCounsellorId(),
                        counsellor
                );
            }

            User student = userDAO.getUserById(booking.getUserId());

            if (student != null) {
                studentMap.put(student.getUserId(), student);
            }
        }

        request.setAttribute("bookingMap", bookingMap);
        request.setAttribute("scheduleMap", scheduleMap);
        request.setAttribute("counsellorMap", counsellorMap);
        request.setAttribute("studentMap", studentMap);
    }

    private boolean isBookingOwnedByCounsellor(int bookingId, int userId) {
        Booking booking = bookingDAO.getBookingById(bookingId);

        if (booking == null) {
            return false;
        }

        Schedule schedule = scheduleDAO.getScheduleById(
                booking.getScheduleId()
        );

        Counsellor counsellor
                = counsellorDAO.getCounsellorByUserId(userId);

        return schedule != null
                && counsellor != null
                && schedule.getCounsellorId()
                == counsellor.getCounsellorId();
    }

    private boolean isRecordOwnedByCounsellor(SessionRecord record,
            int userId) {

        if (record == null) {
            return false;
        }

        Counsellor counsellor
                = counsellorDAO.getCounsellorByUserId(userId);

        return counsellor != null
                && record.getCounsellorId()
                == counsellor.getCounsellorId();
    }

    private boolean isRecordOwnedByStudent(SessionRecord record,
            int userId) {

        if (record == null) {
            return false;
        }

        Booking booking = bookingDAO.getBookingById(record.getBookingId());

        return booking != null && booking.getUserId() == userId;
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

    private boolean isStudent(User user) {
        return user != null
                && "STUDENT".equalsIgnoreCase(user.getRole());
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

    private void redirectToRoleDashboard(HttpServletRequest request,
            HttpServletResponse response,
            User user) throws IOException {

        if (isCounselor(user)) {
            response.sendRedirect(request.getContextPath()
                    + "/counselor/dashboard.jsp");
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/student/dashboard.jsp");
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

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
