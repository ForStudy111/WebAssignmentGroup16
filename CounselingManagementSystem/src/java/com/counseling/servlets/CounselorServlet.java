package com.counseling.servlets; // Must match the folder now

import com.counseling.data.DataStore;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CounselorServlet") // This defines the URL used in your JSP forms
public class CounselorServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String cp = request.getContextPath();

        if ("setAvailability".equals(action)) {
            String slot = request.getParameter("slot");
            if (slot != null && !slot.trim().isEmpty()) {
                DataStore.availabilityList.add(slot);
            }
            response.sendRedirect(cp + "/counselor/availability.jsp");

        } else if ("updateRecord".equals(action)) {
            String student = request.getParameter("studentName");
            String note = request.getParameter("note");
            if (student != null && note != null) {
                DataStore.patientRecords.put(student, note);
            }
            response.sendRedirect(cp + "/counselor/records.jsp");
        }
    }
}