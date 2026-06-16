<%@page import="com.counseling.data.DataStore"%>
<%@page import="java.util.Enumeration"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Admin Panel</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Inter', sans-serif;
                margin: 0;
                display: flex;
                background: #f7fafc;
                height: 100vh;
            }
            .sidebar {
                width: 260px;
                background: #2d3748;
                color: white;
                padding: 20px;
                display: flex;
                flex-direction: column;
            }
            .sidebar h2 {
                font-size: 18px;
                margin-bottom: 30px;
                color: #a0aec0;
            }
            .nav-item {
                padding: 12px;
                color: #edf2f7;
                text-decoration: none;
                border-radius: 8px;
                margin-bottom: 8px;
                transition: 0.2s;
            }
            .nav-item:hover {
                background: #4a5568;
            }
            .logout {
                margin-top: auto;
                color: #fc8181;
            }
            .main {
                flex: 1;
                padding: 40px;
                overflow-y: auto;
            }
            .header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 30px;
            }
            .card {
                background: white;
                padding: 25px;
                border-radius: 12px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
                margin-bottom: 30px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                background: white;
                border-radius: 12px;
                overflow: hidden;
            }
            th, td {
                padding: 15px;
                text-align: left;
                border-bottom: 1px solid #edf2f7;
            }
            th {
                background: #f1f5f9;
                color: #4a5568;
                font-weight: 600;
            }
            .badge {
                padding: 4px 10px;
                border-radius: 12px;
                font-size: 12px;
                font-weight: bold;
            }
            .badge-admin {
                background: #fed7d7;
                color: #c53030;
            }
            .badge-counselor {
                background: #c6f6d5;
                color: #22543d;
            }
            .badge-student {
                background: #bee3f8;
                color: #2b6cb0;
            }
            input, select {
                padding: 10px;
                border: 1px solid #e2e8f0;
                border-radius: 6px;
                margin-right: 10px;
            }
            .btn-add {
                background: #48bb78;
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 6px;
                cursor: pointer;
            }
        </style>
    </head>
    <body>
        <div class="sidebar">
            <h2>COUNSELING PRO</h2>
            <a href="dashboard.jsp" class="nav-item">🏠 Dashboard</a>
            <a href="#" class="nav-item">👥 User Management</a>
            <a href="bookings.jsp" class="nav-item">📅 Monitor All Bookings</a>
            <a href="../login.jsp" class="nav-item logout">🚪 Logout</a>
        </div>

        <div class="main">
            <div class="header">
                <h1>Admin Management</h1>
                <div>Logged in as: <b><%= session.getAttribute("user")%></b></div>
            </div>

            <div class="card">
                <h3>Quick Add User</h3>
                <form action="../ManageUserServlet" method="POST">
                    <input type="text" name="newUsername" placeholder="Username" required>
                    <input type="password" name="newPassword" placeholder="Password" required>
                    <select name="role">
                        <option value="STUDENT">Student</option>
                        <option value="COUNSELOR">Counselor</option>
                        <option value="ADMIN">Admin</option>
                    </select>
                    <input type="text" name="info" placeholder="Full Name" required>
                    <button type="submit" class="btn-add">Add User</button>
                </form>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Username</th>
                        <th>Role</th>
                        <th>Full Name / Info</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Enumeration<String> keys = DataStore.userTable.keys();
                        while (keys.hasMoreElements()) {
                            String key = keys.nextElement();
                            String role = DataStore.roleTable.get(key);
                    %>
                    <tr>
                        <td><b><%= key%></b></td>
                        <td><span class="badge badge-<%= role.toLowerCase()%>"><%= role%></span></td>
                        <td><%= DataStore.profileTable.get(key)%></td>
                    </tr>
                    <% }%>
                </tbody>
            </table>
        </div>
    </body>
</html>