<%@page import="com.counseling.data.DataStore"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Book Appointment</title>
        <style>
        body{
        font-family:sans-serif;
        display:flex;
        justify-content:center;
        padding-top:100px;
        background:#f0fdf4;
        }
        </style>
    </head>
    <body>
        <div style="background:white;padding:40px;border-radius:15px;box-shadow:0 5px 15px rgba(0,0,0,0.1);">
            <h2>Book a Session</h2>
            <form action="../BookingServlet" method="POST">
                <input type="hidden" name="action" value="book">
                <label>Counselor:</label><br>
                <select name="counselor" style="width:100%;padding:10px;margin-bottom:10px;">
                    <option value="counselor1">Dr. Sarah Smith</option>
                </select><br>
                <label>Date:</label><br>
                <input type="date" name="date" required style="width:100%;padding:10px;margin-bottom:20px;"><br>
                <button type="submit" style="width:100%;padding:10px;background:#10b981;color:white;border:none;border-radius:5px;">Confirm</button>
            </form>
            <p align="center"><a href="dashboard.jsp">Cancel</a></p>
        </div>
    </body>
</html>