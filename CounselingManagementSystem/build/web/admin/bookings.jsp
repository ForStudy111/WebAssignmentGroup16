<%@page import="com.counseling.data.DBConnection"%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Master Monitor | CounselingPro</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Inter', sans-serif; background: #f7fafc; margin: 0; padding: 40px; }
            .card { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
            h2 { margin-top: 0; color: #2d3748; }
            table { width: 100%; border-collapse: collapse; margin-top: 20px; overflow: hidden; border-radius: 8px; }
            th, td { padding: 14px; text-align: left; border-bottom: 1px solid #edf2f7; }
            th { background: #f1f5f9; color: #4a5568; font-weight: 600; }
            .status-badge { padding: 4px 10px; border-radius: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; }
        </style>
    </head>
    <body>
        <div class="card">
            <h2>Master System Appointment Logs</h2>
            <table>
                <thead>
                    <tr>
                        <th>Booking ID</th>
                        <th>Student Account</th>
                        <th>Assigned Counselor</th>
                        <th>Scheduled Date</th>
                        <th>System Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        boolean dataFound = false;
                        String sql = "SELECT * FROM bookings";
                        try (Connection conn = DBConnection.getConnection();
                             Statement stmt = conn.createStatement();
                             ResultSet rs = stmt.executeQuery(sql)) {
                             
                             while(rs.next()) {
                                 dataFound = true;
                                 String id = rs.getString("id");
                                 String student = rs.getString("student");
                                 String counselor = rs.getString("counselor");
                                 String date = rs.getString("booking_date");
                                 String status = rs.getString("status");
                    %>
                    <tr>
                        <td><b>#<%= id %></b></td>
                        <td><%= student %></td>
                        <td><%= counselor %></td>
                        <td><%= date %></td>
                        <td>
                            <%
                                String color = "#718096";
                                String bg = "#e2e8f0";
                                if("PENDING".equalsIgnoreCase(status)) { bg = "#fef3c7"; color = "#d97706"; }
                                else if("APPROVED".equalsIgnoreCase(status)) { bg = "#dcfce7"; color = "#15803d"; }
                                else if("CANCELLED".equalsIgnoreCase(status)) { bg = "#fee2e2"; color = "#b91c1c"; }
                                else if("RESCHEDULED".equalsIgnoreCase(status)) { bg = "#e0e7ff"; color = "#4338ca"; }
                            %>
                            <span class="status-badge" style="background: <%= bg %>; color: <%= color %>;"><%= status %></span>
                        </td>
                    </tr>
                    <% 
                             }
                        } catch(Exception e) { 
                            out.println("<tr><td colspan='5' style='color:red;'>SQL Failure: " + e.getMessage() + "</td></tr>"); 
                        }
                        
                        if(!dataFound) {
                    %>
                    <tr>
                        <td colspan="5" style="text-align: center; color: #718096;">No operational records found inside active data tables.</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <br>
            <a href="dashboard.jsp" style="color: #4a5568; text-decoration: none; font-weight: 600;">← Return to Admin Panel</a>
        </div>
    </body>
</html>