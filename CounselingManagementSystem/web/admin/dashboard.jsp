<%@page import="com.counseling.data.DBConnection"%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Admin Dashboard | CounselingPro</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Inter', sans-serif; margin: 0; display: flex; background: #f7fafc; height: 100vh; }
            .sidebar { width: 260px; background: #2d3748; color: white; padding: 20px; display: flex; flex-direction: column; }
            .sidebar h2 { font-size: 18px; margin-bottom: 30px; color: #a0aec0; }
            .nav-item { padding: 12px; color: #edf2f7; text-decoration: none; border-radius: 8px; margin-bottom: 8px; transition: 0.2s; }
            .nav-item:hover { background: #4a5568; }
            .logout { margin-top: auto; color: #fc8181; }
            .main { flex: 1; padding: 40px; overflow-y: auto; }
            .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
            .card { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-bottom: 30px; }
            table { width: 100%; border-collapse: collapse; background: white; border-radius: 12px; overflow: hidden; }
            th, td { padding: 15px; text-align: left; border-bottom: 1px solid #edf2f7; }
            th { background: #f1f5f9; color: #4a5568; font-weight: 600; }
            .badge { padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; }
            .badge-admin { background: #fed7d7; color: #c53030; }
            .badge-counselor { background: #c6f6d5; color: #22543d; }
            .badge-student { background: #bee3f8; color: #2b6cb0; }
            input, select { padding: 10px; border: 1px solid #e2e8f0; border-radius: 6px; margin-right: 10px; }
            .btn-add { background: #48bb78; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; }
        </style>
    </head>
    <body>
        <div class="sidebar">
            <h2>COUNSELING PRO</h2>
            <a href="dashboard.jsp" class="nav-item">🏠 Dashboard</a>
            <a href="bookings.jsp" class="nav-item">📅 Monitor All Bookings</a>
            <a href="../login.jsp" class="nav-item logout">🚪 Logout</a>
        </div>

        <div class="main">
            <div class="header">
                <h1>Admin System Management</h1>
                <div>Identity Key: <b><%= session.getAttribute("user") != null ? session.getAttribute("user") : "Admin" %></b></div>
            </div>

            <div class="card">
                <h3>Quick Add System Profile</h3>
                <form action="../ManageUserServlet" method="POST">
                    <input type="text" name="newUsername" placeholder="Username ID" required>
                    <input type="password" name="newPassword" placeholder="Access Password" required>
                    <select name="role">
                        <option value="STUDENT">Student</option>
                        <option value="COUNSELOR">Counselor</option>
                        <option value="ADMIN">Admin</option>
                    </select>
                    <input type="text" name="info" placeholder="Full Registered Name" required>
                    <button type="submit" class="btn-add">Register User</button>
                </form>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Account Username</th>
                        <th>Classification Role</th>
                        <th>Associated Profile Name</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        String userQuery = "SELECT username, role, full_name FROM users";
                        try (Connection conn = DBConnection.getConnection();
                             Statement stmt = conn.createStatement();
                             ResultSet rs = stmt.executeQuery(userQuery)) {
                             
                             while (rs.next()) {
                                 String username = rs.getString("username");
                                 String role = rs.getString("role");
                                 String fullName = rs.getString("full_name");
                    %>
                    <tr>
                        <td><b><%= username %></b></td>
                        <td><span class="badge badge-<%= role.toLowerCase() %>"><%= role %></span></td>
                        <td><%= fullName %></td>
                    </tr>
                    <% 
                             }
                        } catch(Exception e) { 
                            out.println("<tr><td colspan='3' style='color:red;'>Connection Error: " + e.getMessage() + "</td></tr>"); 
                        }
                    %>
                </tbody>
            </table>
        </div>
    </body>
</html>