<%@page import="com.counseling.data.DataStore"%>
<%@page import="java.util.Enumeration"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Patient Records</title>
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
                margin-bottom: 20px;
                box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            }
            textarea {
                width: 100%;
                height: 80px;
                margin-top: 10px;
                border-radius: 8px;
                border: 1px solid #ddd;
                padding: 10px;
            }
            .btn {
                background: #0ea5e9;
                color: white;
                border: none;
                padding: 10px;
                border-radius: 5px;
                cursor: pointer;
                margin-top: 5px;
            }
        </style>
    </head>
    <body>
        <h2>Clinical Patient Records</h2>

        <div class="card">
            <h3>Add/Update Clinical Note</h3>
            <form action="../CounselorServlet" method="POST">
                <input type="hidden" name="action" value="updateRecord">
                <select name="studentName" style="padding:10px; width:100%;">
                    <% Enumeration<String> users = DataStore.userTable.keys();
                        while (users.hasMoreElements()) {
                            String u = users.nextElement();
                        if ("STUDENT".equals(DataStore.roleTable.get(u))) {%>
                    <option value="<%= u%>"><%= u%> (<%= DataStore.profileTable.get(u)%>)</option>
                    <% }
                    } %>
                </select>
                <textarea name="note" placeholder="Enter session progress notes here..."></textarea>
                <button type="submit" class="btn">Save Record</button>
            </form>
        </div>

        <div class="card">
            <h3>History</h3>
            <% for (String student : DataStore.patientRecords.keySet()) {%>
            <div style="border-left: 4px solid #0ea5e9; padding-left: 15px; margin-bottom: 15px;">
                <strong>Student: <%= student%></strong>
                <p><%= DataStore.patientRecords.get(student)%></p>
            </div>
            <% }%>
        </div>
        <a href="dashboard.jsp">Back to Dashboard</a>
    </body>
</html>