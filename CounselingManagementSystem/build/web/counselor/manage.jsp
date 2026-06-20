<%@page import="com.counseling.data.DataStore"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Manage Appointments | Counselor</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Inter', sans-serif; background: #f8fafc; margin: 0; padding: 40px; display: flex; justify-content: center; }
            .container { width: 100%; max-width: 800px; }
            .card { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-bottom: 25px; }
            h2, h3 { margin-top: 0; color: #1e1b4b; }
            .item-row { border-bottom: 1px solid #e2e8f0; padding: 15px 0; display: flex; justify-content: space-between; align-items: center; }
            .item-row:last-child { border-bottom: none; }
            .btn { padding: 6px 14px; border-radius: 6px; border: none; cursor: pointer; font-weight: 600; font-size: 0.85rem; text-decoration: none; }
            .btn-approve { background: #10b981; color: white; }
            .btn-reject { background: #ef4444; color: white; margin-left: 5px; }
            .btn-submit { background: #4f46e5; color: white; }
            input[type="text"] { padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; width: 250px; margin-right: 8px; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="card">
                <h2>Pending Requests</h2>
                <% 
                    boolean standardFound = false;
                    for (DataStore.Booking b : DataStore.bookingList) {
                        if (b.counselor != null && b.counselor.equals(session.getAttribute("user")) && "PENDING".equals(b.status)) {
                            standardFound = true;
                %>
                <div class="item-row">
                    <div>
                        <strong>Student:</strong> <%= b.student %> <br>
                        <small style="color: #64748b;">Requested Date: <%= b.date %></small>
                    </div>
                    <div style="display: flex;">
                        <form action="../BookingServlet" method="POST" style="margin:0;">
                            <input type="hidden" name="action" value="approve">
                            <input type="hidden" name="bookingId" value="<%= b.id %>">
                            <button type="submit" class="btn btn-approve">Approve</button>
                        </form>
                        <form action="../BookingServlet" method="POST" style="margin:0;">
                            <input type="hidden" name="action" value="reject">
                            <input type="hidden" name="bookingId" value="<%= b.id %>">
                            <button type="submit" class="btn btn-reject">Reject</button>
                        </form>
                    </div>
                </div>
                <% 
                        }
                    } 
                    if (!standardFound) { 
                %>
                <p style="color: #64748b; font-size: 0.9rem;">No pending session requests at this time.</p>
                <% } %>
            </div>

            <div class="card">
                <h3>Add Session Record & Feedback</h3>
                <% 
                    boolean activeFound = false;
                    for (DataStore.Booking b : DataStore.bookingList) {
                        if (b.counselor != null && b.counselor.equals(session.getAttribute("user")) && "APPROVED".equals(b.status)) {
                            activeFound = true;
                %>
                <div class="item-row">
                    <form action="../BookingServlet" method="POST" style="display: flex; align-items: center; width: 100%; justify-content: space-between; margin: 0;">
                        <input type="hidden" name="bookingId" value="<%= b.id %>">
                        <input type="hidden" name="action" value="feedback">
                        <div>
                            <strong><%= b.student %></strong><br>
                            <small style="color:#64748b">Date: <%= b.date %></small>
                        </div>
                        <div>
                            <input type="text" name="feedback" placeholder="Enter patient notes / case feedback..." required>
                            <button type="submit" class="btn btn-submit">Submit Notes</button>
                        </div>
                    </form>
                </div>
                <% 
                        }
                    } 
                    if (!activeFound) { 
                %>
                <p style="color: #64748b; font-size: 0.9rem;">No approved/active appointments require records right now.</p>
                <% } %>
            </div>
            <p><a href="dashboard.jsp" style="color:#4f46e5; text-decoration:none; font-weight:600;">← Back to Hub Dashboard</a></p>
        </div>
    </body>
</html>