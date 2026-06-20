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
        <div style="background:white;padding:40px;border-radius:15px;box-shadow:0 5px 15px rgba(0,0,0,0.1); width: 350px;">
            <h2>Book a Session</h2>
            <form action="../BookingServlet" method="POST">
                <input type="hidden" name="action" value="book">
                
                <label>Counselor:</label><br>
                <select name="counselor" style="width:100%;padding:10px;margin-bottom:15px;border-radius:5px;border:1px solid #ccc;">
                    <option value="Dr. Sarah Smith">Dr. Sarah Smith</option>
                    <option value="Dr. John Doe">Dr. John Doe</option>
                </select><br>
                
                <label>Date:</label><br>
                <input type="date" name="date" required style="width:100%;padding:10px;margin-bottom:20px;border-radius:5px;border:1px solid #ccc;box-sizing:border-box;"><br>
                
                <button type="submit" style="width:100%;padding:10px;background:#10b981;color:white;border:none;border-radius:5px;cursor:pointer;font-weight:bold;">Confirm</button>
            </form>
            <p align="center" style="margin-top:15px;"><a href="dashboard.jsp" style="color:#6b7280;text-decoration:none;">Cancel</a></p>
        </div>
    </body>
</html>