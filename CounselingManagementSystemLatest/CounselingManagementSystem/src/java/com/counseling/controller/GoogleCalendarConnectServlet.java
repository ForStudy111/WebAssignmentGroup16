package com.counseling.controller;

import com.counseling.model.GoogleOAuthConfig;
import com.counseling.model.User;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.UUID;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/GoogleCalendarConnectServlet")
public class GoogleCalendarConnectServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
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

        try {
            GoogleOAuthConfig config
                    = GoogleOAuthConfig.load(getServletContext());

            String state = UUID.randomUUID().toString();

            session.setAttribute("googleOAuthState", state);

            String authorizationUrl
                    = "https://accounts.google.com/o/oauth2/v2/auth"
                    + "?client_id="
                    + URLEncoder.encode(config.getClientId(), "UTF-8")
                    + "&redirect_uri="
                    + URLEncoder.encode(config.getRedirectUri(), "UTF-8")
                    + "&response_type=code"
                    + "&scope="
                    + URLEncoder.encode(
                            "https://www.googleapis.com/auth/calendar.events",
                            "UTF-8"
                    )
                    + "&access_type=offline"
                    + "&prompt=consent"
                    + "&state="
                    + URLEncoder.encode(state, "UTF-8");

            response.sendRedirect(authorizationUrl);

        } catch (IOException e) {
            e.printStackTrace();

            response.sendRedirect(request.getContextPath()
                    + "/counselor/dashboard.jsp?error=true&msg="
                    + URLEncoder.encode(
                            "Google Calendar settings error: " + e.getMessage(),
                            "UTF-8"
                    ));
        }
    }
}
