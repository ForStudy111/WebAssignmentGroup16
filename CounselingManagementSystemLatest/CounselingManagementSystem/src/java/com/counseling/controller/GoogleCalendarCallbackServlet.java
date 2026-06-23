package com.counseling.controller;

import com.counseling.dao.GoogleCalendarConnectionDAO;
import com.counseling.model.GoogleOAuthConfig;
import com.counseling.model.User;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/GoogleCalendarCallbackServlet")
public class GoogleCalendarCallbackServlet extends HttpServlet {

    private final GoogleCalendarConnectionDAO connectionDAO
            = new GoogleCalendarConnectionDAO();

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);

        User currentUser = session == null
                ? null
                : (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            redirectToLogin(request, response);
            return;
        }

        if (!"COUNSELOR".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath()
                    + "/counselor/dashboard.jsp");
            return;
        }

        String googleError = request.getParameter("error");

        if (googleError != null) {
            redirectWithMessage(request, response,
                    "/counselor/dashboard.jsp",
                    "Google Calendar connection was cancelled or denied.");
            return;
        }

        String receivedState = request.getParameter("state");
        String savedState = (String) session.getAttribute("googleOAuthState");

        if (savedState == null || !savedState.equals(receivedState)) {
            redirectWithMessage(request, response,
                    "/counselor/dashboard.jsp",
                    "Google Calendar connection could not be verified.");
            return;
        }

        String authorizationCode = request.getParameter("code");

        if (authorizationCode == null || authorizationCode.trim().isEmpty()) {
            redirectWithMessage(request, response,
                    "/counselor/dashboard.jsp",
                    "Google did not return an authorization code.");
            return;
        }

        try {
            GoogleOAuthConfig config
                    = GoogleOAuthConfig.load(getServletContext());

            String tokenResponse = exchangeCodeForToken(
                    config,
                    authorizationCode
            );

            String refreshToken = getJsonValue(
                    tokenResponse,
                    "refresh_token"
            );

            if (refreshToken == null || refreshToken.trim().isEmpty()) {
                redirectWithMessage(request, response,
                        "/counselor/dashboard.jsp",
                        "No Google refresh token was received. "
                        + "Please try connecting again.");
                return;
            }

            boolean saved = connectionDAO.saveOrUpdateConnection(
                    currentUser.getUserId(),
                    refreshToken
            );

            if (saved) {
                session.removeAttribute("googleOAuthState");

                redirectWithMessage(request, response,
                        "/counselor/dashboard.jsp",
                        "Google Calendar connected successfully.");
            } else {
                redirectWithMessage(request, response,
                        "/counselor/dashboard.jsp",
                        "Google Calendar connection could not be saved.");
            }

        } catch (Exception e) {
            e.printStackTrace();

            redirectWithMessage(request, response,
                    "/counselor/dashboard.jsp",
                    "Google Calendar connection failed. Please check your settings.");
        }
    }

    private String exchangeCodeForToken(GoogleOAuthConfig config,
            String authorizationCode) throws IOException {

        String requestData
                = "code=" + URLEncoder.encode(authorizationCode, "UTF-8")
                + "&client_id="
                + URLEncoder.encode(config.getClientId(), "UTF-8")
                + "&client_secret="
                + URLEncoder.encode(config.getClientSecret(), "UTF-8")
                + "&redirect_uri="
                + URLEncoder.encode(config.getRedirectUri(), "UTF-8")
                + "&grant_type=authorization_code";

        URL url = new URL("https://oauth2.googleapis.com/token");

        HttpURLConnection connection
                = (HttpURLConnection) url.openConnection();

        connection.setRequestMethod("POST");
        connection.setDoOutput(true);
        connection.setRequestProperty(
                "Content-Type",
                "application/x-www-form-urlencoded"
        );

        connection.getOutputStream()
                .write(requestData.getBytes("UTF-8"));

        int responseCode = connection.getResponseCode();

        InputStream input = responseCode >= 200 && responseCode < 300
                ? connection.getInputStream()
                : connection.getErrorStream();

        String responseText = readResponse(input);

        if (responseCode < 200 || responseCode >= 300) {
            throw new IOException(
                    "Google token request failed: " + responseText
            );
        }

        return responseText;
    }

    private String readResponse(InputStream input) throws IOException {

        if (input == null) {
            return "";
        }

        StringBuilder responseText = new StringBuilder();

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(input, "UTF-8"))) {

            String line;

            while ((line = reader.readLine()) != null) {
                responseText.append(line);
            }
        }

        return responseText.toString();
    }

    private String getJsonValue(String json, String fieldName) {

        Pattern pattern = Pattern.compile(
                "\"" + fieldName + "\"\\s*:\\s*\"([^\"]*)\""
        );

        Matcher matcher = pattern.matcher(json);

        if (matcher.find()) {
            return matcher.group(1);
        }

        return null;
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
}
