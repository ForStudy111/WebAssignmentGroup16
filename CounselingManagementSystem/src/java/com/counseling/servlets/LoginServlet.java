package com.counseling.servlets;

import com.counseling.data.DataStore;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        String cp = request.getContextPath(); // Results in "/CounselingManagementSystem"

        // Validate credentials
        if (DataStore.userTable.containsKey(user) && DataStore.userTable.get(user).equals(pass)) {
            
            HttpSession session = request.getSession();
            String role = DataStore.roleTable.get(user);
            
            session.setAttribute("user", user);
            session.setAttribute("role", role);
            session.setAttribute("details", DataStore.profileTable.get(user));

            if (role != null) {
                switch (role) {
                    case "ADMIN":
                        response.sendRedirect(cp + "/admin/dashboard.jsp");
                        break;
                    case "COUNSELOR":
                        // Renaming the file to dashboard.jsp makes this work!
                        response.sendRedirect(cp + "/counselor/dashboard.jsp"); 
                        break;
                    case "STUDENT":
                        response.sendRedirect(cp + "/student/dashboard.jsp");
                        break;
                    default:
                        response.sendRedirect(cp + "/login.jsp?error=1");
                        break;
                }
            }
        } else {
            response.sendRedirect(cp + "/login.jsp?error=1");
        }
    }
}