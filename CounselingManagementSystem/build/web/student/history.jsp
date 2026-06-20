<%@page import="com.counseling.data.DataStore"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Appointment History | CounselingPro</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Inter', sans-serif; background: #f0fdf4; margin: 0; padding: 40px; }
            .card { background: white; padding: 25px; border-radius: 16px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); max-width: 700px; margin: 0 auto; }
            h2 { color: #065f46; margin-top: 0; }
            .history-item { padding: 15px 0; border-bottom: 1px solid #e5e7eb; }
            .history-item:last-child { border-bottom: none; }
        </style>
    </head>
    <body>
        <div class="card">
            <h2>My Past & Archived Sessions</h2>
            <%
                String currentStudent = (String) session.getAttribute("user");
                boolean historicalEntries = false;
                for (DataStore.Booking b : DataStore.bookingList) {
                    if (b.student != null && b.student.equals(currentStudent)) {
                        historicalEntries = true;
            %>
            <div class="history-item">
                <p style="margin: 0;">Booking Ref: <b>#<%= b.id %></b> | Counselor: <%= b.counselor %></p>
                <p style="margin: 5px 0 0 0; font-size: 0.9rem; color: #6b7280;">
                    Date: <%= b.date %> | Status: <b style="color:#4b5563;"><%= b.status %></b>
                </p>
            </div>
            <%
                    }
                }
                if (!historicalEntries) {
            %>
            <p style="color: #6b7280;">No completed, cancelled, or archived histories logged.</p>
            <% } %>
            <br>
            <a href="dashboard.jsp" style="color: #065f46; text-decoration: none; font-weight: bold;">← Back to Student Dashboard</a>
        </div>
    </body>
</html>