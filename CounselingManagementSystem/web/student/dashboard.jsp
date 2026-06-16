<%@page import="com.counseling.data.DataStore"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Student Portal | CounselingPro</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Inter', sans-serif;
                margin: 0;
                display: flex;
                background: #f0fdf4;
                height: 100vh;
            }
            .sidebar {
                width: 260px;
                background: #065f46;
                color: white;
                padding: 20px;
                display: flex;
                flex-direction: column;
            }
            .sidebar h2 {
                font-size: 1.2rem;
                margin-bottom: 2rem;
                color: #a7f3d0;
            }
            .nav-item {
                padding: 12px;
                color: #d1fae5;
                text-decoration: none;
                border-radius: 8px;
                margin-bottom: 8px;
                transition: 0.2s;
            }
            .nav-item:hover {
                background: #047857;
            }
            .logout {
                margin-top: auto;
                color: #fecaca;
            }
            .main {
                flex: 1;
                padding: 40px;
            }
            .card {
                background: white;
                padding: 25px;
                border-radius: 16px;
                box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
                border-top: 5px solid #10b981;
            }
            .welcome-box {
                background: linear-gradient(to right, #10b981, #3b82f6);
                color: white;
                padding: 30px;
                border-radius: 16px;
                margin-bottom: 30px;
            }
            .btn-book {
                background: white;
                color: #065f46;
                padding: 12px 24px;
                border-radius: 8px;
                text-decoration: none;
                font-weight: bold;
                display: inline-block;
                margin-top: 15px;
            }
        </style>
    </head>
    <body>
        <div class="sidebar">
            <h2>STUDENT CARE</h2>
            <a href="dashboard.jsp" class="nav-item">🏠 My Dashboard</a>
            <a href="book.jsp" class="nav-item">📅 Book Session</a>
            <a href="#" class="nav-item">💬 My Feedback</a>
            <a href="../login.jsp" class="nav-item logout">Sign Out</a>
        </div>

        <div class="main">
            <div class="welcome-box">
                <h1>Hi, <%= session.getAttribute("user")%>!</h1>
                <p>Ready to talk? Our counselors are available to support you.</p>
                <a href="book.jsp" class="btn-book">Book New Appointment</a>
            </div>

            <div class="card">
                <h3>Recent Booking Status</h3>
                <%
                    boolean found = false;
                    for (DataStore.Booking b : DataStore.bookingList) {
                        if (b.student.equals(session.getAttribute("user"))) {
                            found = true;
                %>
                <p>Booking ID: <b><%= b.id%></b> | Status: <b style="color:#047857"><%= b.status%></b></p>
                    <%      }
                        }
                        if (!found) {
                    %>
                <p style="color: #6b7280;">You haven't booked any sessions yet.</p>
                <% }%>
            </div>
        </div>
    </body>
</html>