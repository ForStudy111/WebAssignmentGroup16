<%@page import="com.counseling.data.DataStore"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Set Availability</title>
        <style>
            body {
                font-family: sans-serif;
                background: #f8fafc;
                padding: 40px;
            }
            .card {
                background: white;
                padding: 25px;
                border-radius: 12px;
                max-width: 500px;
                margin-bottom: 20px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            }
            .slot {
                background: #e0e7ff;
                padding: 10px;
                margin: 5px 0;
                border-radius: 5px;
                color: #3730a3;
            }
        </style>
    </head>
    <body>
        <div class="card">
            <h2>Set Your Availability</h2>
            <form action="../CounselorServlet" method="POST">
                <input type="hidden" name="action" value="setAvailability">
                <input type="text" name="slot" placeholder="e.g. Friday 10:00 AM" required style="width:70%; padding:10px;">
                <button type="submit" style="padding:10px; background:#4338ca; color:white; border:none; border-radius:5px;">Add Slot</button>
            </form>
        </div>

        <div class="card">
            <h3>Current Active Slots</h3>
            <% for (String s : DataStore.availabilityList) {%>
            <div class="slot"><%= s%></div>
            <% }%>
        </div>
        <a href="dashboard.jsp">Back to Dashboard</a>
    </body>
</html>