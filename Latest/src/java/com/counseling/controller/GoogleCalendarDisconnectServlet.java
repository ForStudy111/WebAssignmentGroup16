package com.counseling.controller;

import com.counseling.dao.GoogleCalendarConnectionDAO;
import com.counseling.model.User;
import java.io.IOException;
import java.net.URLEncoder;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/GoogleCalendarDisconnectServlet")
public class GoogleCalendarDisconnectServlet extends HttpServlet {

    private final GoogleCalendarConnectionDAO connectionDAO
            = new GoogleCalendarConnectionDAO();

    @Override
    protected void doPost(HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);

        User currentUser = session == null
                ? null
                : (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath()
                    + "/login.jsp?error=true&msg="
                    + URLEncoder.encode("Please log in first.", "UTF-8"));
            return;
        }

        if (!"COUNSELOR".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath()
                    + "/student/dashboard.jsp");
            return;
        }

        boolean disconnected = connectionDAO.disconnectCalendar(
                currentUser.getUserId()
        );

        if (disconnected) {
            redirectWithMessage(request, response,
                    "Google Calendar was disconnected from this system.");
        } else {
            redirectWithMessage(request, response,
                    "No connected Google Calendar was found.");
        }
    }

    private void redirectWithMessage(HttpServletRequest request,
            HttpServletResponse response,
            String message) throws IOException {

        response.sendRedirect(request.getContextPath()
                + "/counselor/dashboard.jsp?msg="
                + URLEncoder.encode(message, "UTF-8"));
    }
}
