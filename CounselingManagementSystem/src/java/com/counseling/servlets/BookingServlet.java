package com.counseling.servlets;

import com.counseling.data.DataStore;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/BookingServlet")
public class BookingServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        String user = (String) session.getAttribute("user");

        if ("book".equals(action)) {
            String counselor = request.getParameter("counselor");
            String date = request.getParameter("date");
            DataStore.bookingList.add(new DataStore.Booking(user, counselor, date));
            response.sendRedirect("student/dashboard.jsp");

        } else if ("approve".equals(action)) {
            String id = request.getParameter("id");
            for (DataStore.Booking b : DataStore.bookingList) {
                if (b.id.equals(id)) b.status = "APPROVED";
            }
            response.sendRedirect("counselor/manage.jsp");

        } else if ("feedback".equals(action)) {
            String id = request.getParameter("id");
            String text = request.getParameter("feedback");
            String role = (String) session.getAttribute("role");
            for (DataStore.Booking b : DataStore.bookingList) {
                if (b.id.equals(id)) {
                    if ("STUDENT".equals(role)) b.studentFeedback = text;
                    else b.counselorFeedback = text;
                }
            }
            response.sendRedirect(role.toLowerCase() + "/dashboard.jsp");
        }
    }
}