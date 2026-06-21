/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.counseling.controller;

import com.counseling.dao.CounsellorDAO;
import com.counseling.dao.ScheduleDAO;
import com.counseling.model.Counsellor;
import com.counseling.model.Schedule;
import com.counseling.model.User;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author wpy92
 */
@WebServlet("/ScheduleServlet")
public class ScheduleServlet extends HttpServlet {

    private final ScheduleDAO scheduleDAO = new ScheduleDAO();
    private final CounsellorDAO counsellorDAO = new CounsellorDAO();

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
            out.println("<title>Servlet ScheduleServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ScheduleServlet at " + request.getContextPath() + "</h1>");
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

        if (!isCounselor(currentUser)) {
            redirectToLogin(request, response);
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

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "list";
        }

        switch (action) {
            case "list":
                showScheduleList(request, response, counsellor);
                break;

            case "new":
                showCreateForm(request, response);
                break;

            case "edit":
                showEditForm(request, response, counsellor);
                break;

            case "delete":
                deleteSchedule(request, response, counsellor);
                break;

            default:
                response.sendRedirect(request.getContextPath()
                        + "/ScheduleServlet?action=list");
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

        if (!isCounselor(currentUser)) {
            redirectToLogin(request, response);
            return;
        }

        Counsellor counsellor
                = counsellorDAO.getCounsellorByUserId(currentUser.getUserId());

        if (counsellor == null) {
            redirectToLogin(request, response);
            return;
        }

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            createSchedule(request, response, counsellor);

        } else if ("update".equals(action)) {
            updateSchedule(request, response, counsellor);

        } else {
            response.sendRedirect(request.getContextPath()
                    + "/ScheduleServlet?action=list");
        }
    }

    private void showScheduleList(HttpServletRequest request,
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

    private void showCreateForm(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute("formMode", "create");

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

        request.setAttribute("formMode", "edit");
        request.setAttribute("selectedSchedule", schedule);

        request.getRequestDispatcher("/counselor/schedule-form.jsp")
                .forward(request, response);
    }

    private void createSchedule(HttpServletRequest request,
            HttpServletResponse response,
            Counsellor counsellor) throws IOException {

        Schedule schedule = createScheduleObject(request, counsellor);

        if (schedule == null) {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=new",
                    "Please enter a valid future date and time.");
            return;
        }

        if (scheduleDAO.addSchedule(schedule)) {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=list",
                    "Availability slot created successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=new",
                    "Schedule creation failed. This time slot may already exist.");
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

        if ("BOOKED".equalsIgnoreCase(
                existingSchedule.getAvailabilityStatus())) {

            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=list",
                    "Booked schedules cannot be edited.");
            return;
        }

        Schedule updatedSchedule
                = createScheduleObject(request, counsellor);

        if (updatedSchedule == null) {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=edit&id=" + scheduleId,
                    "Please enter a valid future date and time.");
            return;
        }

        updatedSchedule.setScheduleId(scheduleId);

        if (scheduleDAO.updateSchedule(updatedSchedule)) {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=list",
                    "Schedule updated successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=edit&id=" + scheduleId,
                    "Schedule update failed. This time slot may already exist.");
        }
    }

    private void deleteSchedule(HttpServletRequest request,
            HttpServletResponse response,
            Counsellor counsellor) throws IOException {

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
                    "Booked schedules cannot be deleted.");
            return;
        }

        if (scheduleDAO.deleteSchedule(scheduleId)) {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=list",
                    "Schedule deleted successfully.");
        } else {
            redirectWithMessage(request, response,
                    "/ScheduleServlet?action=list",
                    "Schedule deletion failed.");
        }
    }

    private Schedule createScheduleObject(HttpServletRequest request,
            Counsellor counsellor) {

        try {
            String dateValue = getValue(request, "availableDate");
            String timeValue = getValue(request, "availableTime");
            String status = getValue(request, "availabilityStatus")
                    .toUpperCase();

            if (dateValue.isEmpty() || timeValue.isEmpty()) {
                return null;
            }

            LocalDate localDate = LocalDate.parse(dateValue);

            if (localDate.isBefore(LocalDate.now())) {
                return null;
            }

            LocalTime localTime = LocalTime.parse(timeValue);

            if (!"AVAILABLE".equals(status)
                    && !"UNAVAILABLE".equals(status)) {
                status = "AVAILABLE";
            }

            return new Schedule(
                    counsellor.getCounsellorId(),
                    Date.valueOf(localDate),
                    Time.valueOf(localTime),
                    status
            );

        } catch (Exception e) {
            return null;
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

        response.sendRedirect(request.getContextPath()
                + "/login.jsp?error=true&msg="
                + URLEncoder.encode("Please log in as a counsellor first.",
                        "UTF-8"));
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
