<%@page import="com.counseling.data.DBConnection"%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Student Portal | CounselingPro</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Inter', sans-serif; margin: 0; display: flex; background: #f0fdf4; height: 100vh; }
            .sidebar { width: 260px; background: #065f46; color: white; padding: 20px; display: flex; flex-direction: column; }
            .sidebar h2 { font-size: 1.2rem; margin-bottom: 2rem; color: #a7f3d0; }
            .nav-item { padding: 12px; color: #d1fae5; text-decoration: none; border-radius: 8px; margin-bottom: 8px; transition: 0.2s; }
            .nav-item:hover { background: #047857; }
            .logout { margin-top: auto; color: #fecaca; }
            .main { flex: 1; padding: 40px; overflow-y: auto; }
            .card { background: white; padding: 25px; border-radius: 16px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); border-top: 5px solid #10b981; }
            .welcome-box { background: linear-gradient(to right, #10b981, #3b82f6); color: white; padding: 30px; border-radius: 16px; margin-bottom: 30px; }
            .btn-book { background: white; color: #065f46; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: bold; display: inline-block; margin-top: 15px; }
            .booking-row { border-bottom: 1px solid #e5e7eb; padding: 12px 0; display: flex; justify-content: space-between; align-items: center; }
            .booking-row:last-of-type { border-bottom: none; }
            .btn-action-reschedule { background: #3b82f6; color: white; border: none; padding: 6px 12px; border-radius: 6px; cursor: pointer; font-weight: 600; }
            .btn-action-cancel { background: #ef4444; color: white; border: none; padding: 6px 12px; border-radius: 6px; cursor: pointer; font-weight: 600; }
        </style>
    </head>
    <body>
        <div class="sidebar">
            <h2>STUDENT CARE</h2>
            <a href="dashboard.jsp" class="nav-item">🏠 My Dashboard</a>
            <a href="book.jsp" class="nav-item">📅 Book Session</a>
            <a href="history.jsp" class="nav-item">💬 History & Feedback</a>
            <a href="../login.jsp" class="nav-item logout">Sign Out</a>
        </div>

        <div class="main">
            <div class="welcome-box">
                <h1>Hi, <%= session.getAttribute("user") != null ? session.getAttribute("user") : "Student" %>!</h1>
                <p>Ready to talk? Our system counselors are active and available.</p>
                <a href="book.jsp" class="btn-book">Book New Appointment</a>
            </div>

            <div class="card">
                <h3>Your Running Bookings Status</h3>
                <%
                    String currentStudent = (String) session.getAttribute("user");
                    boolean found = false;
                    
                    String query = "SELECT id, counselor, booking_date, status FROM bookings WHERE student = ?";
                    try (Connection conn = DBConnection.getConnection();
                         PreparedStatement ps = conn.prepareStatement(query)) {
                         
                        ps.setString(1, currentStudent);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                found = true;
                                String bId = rs.getString("id");
                                String bCounselor = rs.getString("counselor");
                                String bDate = rs.getString("booking_date");
                                String bStatus = rs.getString("status");
                %>
                <div class="booking-row">
                    <div>
                        <p style="margin: 0; font-size: 0.95rem;">
                            Booking Reference: <b>#<%= bId %></b> | Staff: <b><%= bCounselor %></b>
                        </p>
                        <p style="margin: 4px 0 0 0; color: #6b7280; font-size: 0.85rem;">
                            Date: <b><%= bDate %></b> | Status: 
                            <b style="color: <%= "Cancelled".equalsIgnoreCase(bStatus) ? "#ef4444" : "#047857" %>">
                                <%= bStatus %>
                            </b>
                        </p>
                    </div>

                    <% if (!"Cancelled".equalsIgnoreCase(bStatus)) { %>
                    <div style="display: flex; gap: 8px; align-items: center;">
                        <form action="../BookingServlet" method="POST" style="display: flex; gap: 4px; margin: 0;">
                            <input type="hidden" name="action" value="reschedule">
                            <input type="hidden" name="bookingId" value="<%= bId %>">
                            <input type="date" name="newDate" required style="padding: 5px; border: 1px solid #d1d5db; border-radius: 6px;">
                            <button type="submit" class="btn-action-reschedule">Reschedule</button>
                        </form>

                        <form action="../BookingServlet" method="POST" onsubmit="return confirm('Cancel this selection?');" style="margin: 0;">
                            <input type="hidden" name="action" value="cancel">
                            <input type="hidden" name="bookingId" value="<%= bId %>">
                            <button type="submit" class="btn-action-cancel">Cancel</button>
                        </form>
                    </div>
                    <% } %>
                </div>
                <%      
                            }
                        }
                    } catch(Exception e) { 
                        out.println("<p style='color:red;'>SQL Fetch Exception: " + e.getMessage() + "</p>"); 
                    }
                    if (!found) {
                %>
                <p style="color: #6b7280;">No ongoing appointments linked to your account.</p>
                <% } %>
            </div>
        </div>
    </body>
</html>