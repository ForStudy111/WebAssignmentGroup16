<%@page import="com.counseling.data.DataStore"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head><title>Global Monitor</title></head>
    <body style="font-family:sans-serif;padding:40px;">
        <h2>Master Appointment List</h2>
        <table border="1" width="100%" cellpadding="10" style="border-collapse:collapse;">
            <tr style="background:#eee;"><th>ID</th><th>Student</th><th>Counselor</th><th>Date</th><th>Status</th></tr>
                    <% for (DataStore.Booking b : DataStore.bookingList) {%>
            <tr><td><%= b.id%></td><td><%= b.student%></td><td><%= b.counselor%></td><td><%= b.date%></td><td><%= b.status%></td></tr>
            <% }%>
        </table>
        <br><a href="dashboard.jsp">Back to Dashboard</a>
    </body>
</html>