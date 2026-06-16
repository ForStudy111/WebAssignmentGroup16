package com.counseling.servlets;

import com.counseling.data.DataStore;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ManageUserServlet")
public class ManageUserServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get Form Data
        String newUsername = request.getParameter("newUsername");
        String newPassword = request.getParameter("newPassword");
        String role = request.getParameter("role"); // ADMIN, COUNSELOR, or STUDENT
        String info = request.getParameter("info");

        // 2. Add to our Hashtables
        DataStore.userTable.put(newUsername, newPassword);
        DataStore.roleTable.put(newUsername, role);
        DataStore.profileTable.put(newUsername, info);

        // 3. Go back to Admin dashboard with a success message
        response.sendRedirect("admin/dashboard.jsp?msg=UserAdded");
    }
}