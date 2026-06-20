package com.counseling.servlets;

import com.counseling.data.DataStore;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/BookingServlet")
public class BookingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String currentUser = (String) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String bookingId = request.getParameter("bookingId");

        // --- STUDENT CRUD MODULE ACTIONS ---
        if ("book".equals(action)) {
            String counselor = request.getParameter("counselor");
            String date = request.getParameter("date");
            String nextId = String.valueOf(DataStore.bookingList.size() + 1); 
            
            DataStore.Booking newBooking = new DataStore.Booking(nextId, currentUser, counselor);
            newBooking.date = date;
            newBooking.status = "PENDING"; // Upper-case consistency
            
            DataStore.bookingList.add(newBooking);
            response.sendRedirect("student/dashboard.jsp");
        } 
        else if ("reschedule".equals(action)) {
            String newDate = request.getParameter("newDate");
            for (DataStore.Booking b : DataStore.bookingList) {
                if (b.id != null && b.id.equals(bookingId)) {
                    b.date = newDate; 
                    b.status = "RESCHEDULED";
                    break;
                }
            }
            response.sendRedirect("student/dashboard.jsp");
        } 
        else if ("cancel".equals(action)) {
            for (DataStore.Booking b : DataStore.bookingList) {
                if (b.id != null && b.id.equals(bookingId)) {
                    b.status = "CANCELLED"; 
                    break;
                }
            }
            response.sendRedirect("student/dashboard.jsp");
        }
        
        // --- COUNSELOR INTERACTION ACTIONS ---
        else if ("approve".equals(action)) {
            for (DataStore.Booking b : DataStore.bookingList) {
                if (b.id != null && b.id.equals(bookingId)) {
                    b.status = "APPROVED";
                    break;
                }
            }
            response.sendRedirect("counselor/manage.jsp");
        }
        else if ("reject".equals(action)) {
            for (DataStore.Booking b : DataStore.bookingList) {
                if (b.id != null && b.id.equals(bookingId)) {
                    b.status = "REJECTED";
                    break;
                }
            }
            response.sendRedirect("counselor/manage.jsp");
        }
        else if ("feedback".equals(action)) {
            String notes = request.getParameter("feedback");
            for (DataStore.Booking b : DataStore.bookingList) {
                if (b.id != null && b.id.equals(bookingId)) {
                    b.status = "COMPLETED";
                    // Assuming your object has or can hold status strings:
                    b.status = "COMPLETED - " + notes; 
                    break;
                }
            }
            response.sendRedirect("counselor/manage.jsp");
        }
    }
}