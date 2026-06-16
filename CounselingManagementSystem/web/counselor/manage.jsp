<%@page import="com.counseling.data.DataStore"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head><title>Manage</title></head>
    <body style="font-family:sans-serif; padding:40px;">
        <h2>Pending Requests</h2>
        <% for (DataStore.Booking b : DataStore.bookingList) {
            if (b.counselor.equals(session.getAttribute("user")) && b.status.equals("PENDING")) {%>
        <p><%= b.student%> - <%= b.date%> 
            <a href="../BookingServlet?action=approve&id=<%= b.id%>">[Approve]</a></p>
            <% }
        } %>
        <hr>
        <h2>Feedback for Students</h2>
        <% for (DataStore.Booking b : DataStore.bookingList) {
            if (b.counselor.equals(session.getAttribute("user")) && b.status.equals("APPROVED")) {%>
        <form action="../BookingServlet" method="POST">
            <input type="hidden" name="id" value="<%= b.id%>">
            <input type="hidden" name="action" value="feedback">
            Student: <%= b.student%> | Feedback: <input type="text" name="feedback">
            <button type="submit">Submit</button>
        </form>
        <% }
        }%>
        <br><a href="dashboard.jsp">Dashboard</a>
    </body>
</html>