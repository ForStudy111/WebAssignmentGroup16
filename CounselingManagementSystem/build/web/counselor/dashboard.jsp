<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Counselor Portal | CounselingPro</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Inter', sans-serif;
                margin: 0;
                display: flex;
                background: #f8fafc;
                height: 100vh;
            }
            .sidebar {
                width: 260px;
                background: #312e81;
                color: white;
                padding: 20px;
                display: flex;
                flex-direction: column;
            }
            .sidebar h2 {
                font-size: 1.2rem;
                margin-bottom: 2rem;
                color: #c7d2fe;
            }
            .nav-item {
                padding: 12px;
                color: #e0e7ff;
                text-decoration: none;
                border-radius: 8px;
                margin-bottom: 8px;
                transition: 0.2s;
            }
            .nav-item:hover {
                background: #4338ca;
            }
            .logout {
                margin-top: auto;
                color: #fca5a5;
            }
            .main {
                flex: 1;
                padding: 40px;
                overflow-y: auto;
            }
            .card {
                background: white;
                padding: 25px;
                border-radius: 12px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
                margin-bottom: 20px;
            }
            .header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 30px;
            }
            .btn-primary {
                background: #4f46e5;
                color: white;
                padding: 12px 24px;
                border-radius: 8px;
                text-decoration: none;
                font-weight: 600;
                display: inline-block;
                transition: 0.3s;
                border: none;
            }
            .btn-primary:hover {
                background: #4338ca;
            }
            .status-pill {
                background: #dcfce7;
                color: #166534;
                padding: 4px 12px;
                border-radius: 20px;
                font-size: 0.8rem;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="sidebar">
            <h2>COUNSELOR HUB</h2>
            <a href="manage.jsp" class="nav-item">📅 Manage Appointments</a>
            <a href="#" class="nav-item">⏰ Set Availability</a>
            <a href="#" class="nav-item">📂 Patient Records</a>
            <a href="../login.jsp" class="nav-item logout">Logout</a>
        </div>

        <div class="main">
            <div class="header">
                <h1>Counselor Dashboard</h1>
                <span class="status-pill">Active Session</span>
            </div>

            <div class="card">
                <h3>Welcome, <%= session.getAttribute("user")%></h3>
                <p style="color: #64748b;">Profile: <b><%= session.getAttribute("details")%></b></p>
            </div>

            <div class="card">
                <h3>Next Tasks</h3>
                <p>Check your pending requests to approve new sessions.</p>
                <div style="margin-top: 20px;">
                    <a href="manage.jsp" class="btn-primary">Approve Appointments</a>
                    <a href="#" class="btn-primary" style="background:#0ea5e9">Add Session Record</a>
                </div>
            </div>
        </div>
    </body>
</html>