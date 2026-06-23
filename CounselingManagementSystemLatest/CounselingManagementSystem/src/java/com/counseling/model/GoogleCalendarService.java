package com.counseling.model;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.ServletContext;

public class GoogleCalendarService {

    private static final String TIME_ZONE = "Asia/Kuala_Lumpur";
    private static final int SESSION_DURATION_HOURS = 1;

    private final ServletContext servletContext;

    public GoogleCalendarService(ServletContext servletContext) {
        this.servletContext = servletContext;
    }

    public CalendarEventResult createCounsellingEvent(
            String refreshToken,
            Schedule schedule,
            Counsellor counsellor,
            User student,
            int bookingId) throws IOException {

        if (refreshToken == null || refreshToken.trim().isEmpty()) {
            throw new IOException("Google Calendar is not connected.");
        }

        if (schedule == null || counsellor == null || student == null) {
            throw new IOException("Booking details are incomplete.");
        }

        GoogleOAuthConfig config = GoogleOAuthConfig.load(servletContext);

        String accessToken = getAccessToken(config, refreshToken);

        LocalDate sessionDate = schedule.getAvailableDate().toLocalDate();
        LocalTime sessionTime = schedule.getAvailableTime().toLocalTime();

        ZonedDateTime startDateTime = ZonedDateTime.of(
                sessionDate,
                sessionTime,
                ZoneId.of(TIME_ZONE)
        );

        ZonedDateTime endDateTime = startDateTime.plusHours(
                SESSION_DURATION_HOURS
        );

        String start = startDateTime.format(
                DateTimeFormatter.ISO_OFFSET_DATE_TIME
        );

        String end = endDateTime.format(
                DateTimeFormatter.ISO_OFFSET_DATE_TIME
        );

        String eventJson = buildEventJson(
                student,
                counsellor,
                bookingId,
                start,
                end
        );

        String response = insertEvent(accessToken, eventJson);

        String eventId = getJsonValue(response, "id");
        String eventLink = getJsonValue(response, "htmlLink");

        if (eventId == null || eventId.trim().isEmpty()) {
            throw new IOException(
                    "Google Calendar created no event ID. Response: "
                    + response
            );
        }

        if (eventLink != null) {
            eventLink = eventLink.replace("\\/", "/");
        }

        return new CalendarEventResult(eventId, eventLink);
    }

    private String getAccessToken(GoogleOAuthConfig config,
            String refreshToken) throws IOException {

        String requestData
                = "client_id="
                + URLEncoder.encode(config.getClientId(), "UTF-8")
                + "&client_secret="
                + URLEncoder.encode(config.getClientSecret(), "UTF-8")
                + "&refresh_token="
                + URLEncoder.encode(refreshToken, "UTF-8")
                + "&grant_type=refresh_token";

        String response = sendPostRequest(
                "https://oauth2.googleapis.com/token",
                "application/x-www-form-urlencoded",
                requestData,
                null
        );

        String accessToken = getJsonValue(response, "access_token");

        if (accessToken == null || accessToken.trim().isEmpty()) {
            throw new IOException(
                    "Google did not return an access token."
            );
        }

        return accessToken;
    }

    private String insertEvent(String accessToken,
            String eventJson) throws IOException {

        return sendPostRequest(
                "https://www.googleapis.com/calendar/v3/calendars/"
                + "primary/events?sendUpdates=all",
                "application/json",
                eventJson,
                "Bearer " + accessToken
        );
    }

    private String sendPostRequest(String urlText,
            String contentType,
            String requestData,
            String authorizationHeader) throws IOException {

        HttpURLConnection connection = null;

        try {
            URL url = new URL(urlText);

            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setRequestProperty(
                    "Content-Type",
                    contentType + "; charset=UTF-8"
            );

            if (authorizationHeader != null) {
                connection.setRequestProperty(
                        "Authorization",
                        authorizationHeader
                );
            }

            byte[] requestBytes
                    = requestData.getBytes(StandardCharsets.UTF_8);

            connection.setRequestProperty(
                    "Content-Length",
                    String.valueOf(requestBytes.length)
            );

            try (OutputStream output = connection.getOutputStream()) {
                output.write(requestBytes);
            }

            int responseCode = connection.getResponseCode();

            InputStream input = responseCode >= 200
                    && responseCode < 300
                            ? connection.getInputStream()
                            : connection.getErrorStream();

            String responseText = readResponse(input);

            if (responseCode < 200 || responseCode >= 300) {
                throw new IOException(
                        "Google request failed: " + responseText
                );
            }

            return responseText;

        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    private String buildEventJson(User student,
            Counsellor counsellor,
            int bookingId,
            String start,
            String end) {

        String studentName = safeText(student.getFullName());
        String studentEmail = safeText(student.getEmail());
        String counsellorName = safeText(
                counsellor.getCounsellorName()
        );
        String officeLocation = safeText(
                counsellor.getOfficeLocation()
        );

        String summary = "Counselling Session - " + studentName;

        String description = "Counselling appointment booking #"
                + bookingId
                + ".\nCounsellor: " + counsellorName
                + ".\nPlease contact the counsellor if you need to reschedule.";

        return "{"
                + "\"summary\":\"" + escapeJson(summary) + "\","
                + "\"location\":\"" + escapeJson(officeLocation) + "\","
                + "\"description\":\"" + escapeJson(description) + "\","
                + "\"start\":{"
                + "\"dateTime\":\"" + escapeJson(start) + "\","
                + "\"timeZone\":\"" + TIME_ZONE + "\""
                + "},"
                + "\"end\":{"
                + "\"dateTime\":\"" + escapeJson(end) + "\","
                + "\"timeZone\":\"" + TIME_ZONE + "\""
                + "},"
                + "\"attendees\":[{"
                + "\"email\":\"" + escapeJson(studentEmail) + "\""
                + "}],"
                + "\"guestsCanModify\":false,"
                + "\"guestsCanInviteOthers\":false"
                + "}";
    }

    public void deleteCounsellingEvent(String refreshToken,
            String eventId) throws IOException {

        if (refreshToken == null || refreshToken.trim().isEmpty()) {
            throw new IOException("Google Calendar is not connected.");
        }

        if (eventId == null || eventId.trim().isEmpty()) {
            throw new IOException("Google Calendar event ID is missing.");
        }

        GoogleOAuthConfig config = GoogleOAuthConfig.load(servletContext);

        String accessToken = getAccessToken(config, refreshToken);

        String eventUrl
                = "https://www.googleapis.com/calendar/v3/calendars/"
                + "primary/events/"
                + URLEncoder.encode(eventId, "UTF-8")
                + "?sendUpdates=all";

        sendDeleteRequest(eventUrl, "Bearer " + accessToken);
    }

    private void sendDeleteRequest(String urlText,
            String authorizationHeader) throws IOException {

        HttpURLConnection connection = null;

        try {
            URL url = new URL(urlText);

            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("DELETE");

            connection.setRequestProperty(
                    "Authorization",
                    authorizationHeader
            );

            int responseCode = connection.getResponseCode();

            InputStream input = responseCode >= 200
                    && responseCode < 300
                            ? connection.getInputStream()
                            : connection.getErrorStream();

            String responseText = readResponse(input);

            if (responseCode < 200 || responseCode >= 300) {
                throw new IOException(
                        "Google Calendar delete request failed: "
                        + responseText
                );
            }

        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    private String readResponse(InputStream input) throws IOException {

        if (input == null) {
            return "";
        }

        StringBuilder responseText = new StringBuilder();

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(
                        input,
                        StandardCharsets.UTF_8
                ))) {

            String line;

            while ((line = reader.readLine()) != null) {
                responseText.append(line);
            }
        }

        return responseText.toString();
    }

    private String getJsonValue(String json,
            String fieldName) {

        Pattern pattern = Pattern.compile(
                "\"" + fieldName + "\"\\s*:\\s*\"([^\"]*)\""
        );

        Matcher matcher = pattern.matcher(json);

        if (matcher.find()) {
            return matcher.group(1);
        }

        return null;
    }

    private String escapeJson(String value) {
        return safeText(value)
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private String safeText(String value) {
        return value == null ? "" : value.trim();
    }

    public static class CalendarEventResult {

        private final String eventId;
        private final String eventLink;

        public CalendarEventResult(String eventId,
                String eventLink) {

            this.eventId = eventId;
            this.eventLink = eventLink;
        }

        public String getEventId() {
            return eventId;
        }

        public String getEventLink() {
            return eventLink;
        }
    }
}
