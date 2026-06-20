<%@page import="java.util.*"%>
<%@page import="com.counseling.model.SessionRecord"%>

<%
    List<SessionRecord> list =
        (List<SessionRecord>) request.getAttribute("records");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Session History | Counselor</title>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">

    <style>

        body{
            font-family:'Inter',sans-serif;
            background:#f8fafc;
            padding:40px;
        }

        .container{
            max-width:1200px;
            margin:auto;
        }

        .card{
            background:white;
            padding:25px;
            border-radius:12px;
            box-shadow:0 4px 6px rgba(0,0,0,0.05);
        }

        h2{
            margin-top:0;
            color:#1e1b4b;
        }

        .top-bar{
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom:20px;
        }

        .btn-add{
            background:#4f46e5;
            color:white;
            text-decoration:none;
            padding:10px 18px;
            border-radius:8px;
            font-weight:600;
        }

        .btn-add:hover{
            background:#4338ca;
        }

        table{
            width:100%;
            border-collapse:collapse;
        }

        th{
            background:#eef2ff;
            color:#312e81;
        }

        th,td{
            padding:12px;
            border-bottom:1px solid #e2e8f0;
            text-align:left;
        }

        tr:hover{
            background:#f8fafc;
        }

        .btn-delete{
            background:#ef4444;
            color:white;
            text-decoration:none;
            padding:6px 12px;
            border-radius:6px;
            font-size:0.85rem;
        }

        .back{
            display:inline-block;
            margin-top:20px;
            color:#4f46e5;
            text-decoration:none;
            font-weight:600;
        }

        .empty{
            color:#64748b;
            text-align:center;
            padding:20px;
        }

    </style>
</head>

<body>

<div class="container">

    <div class="card">

        <div class="top-bar">
            <h2>Session History</h2>

            <a href="addSessionRecord.jsp"
               class="btn-add">
                + Add Record
            </a>
        </div>

        <table>

            <thead>
                <tr>
                    <th>ID</th>
                    <th>Booking ID</th>
                    <th>Counsellor ID</th>
                    <th>Date</th>
                    <th>Notes</th>
                    <th>Feedback</th>
                    <th>Action</th>
                </tr>
            </thead>

            <tbody>

            <%
                if(list != null && !list.isEmpty()){

                    for(SessionRecord r : list){
            %>

                <tr>

                    <td><%= r.getRecordId() %></td>

                    <td><%= r.getBookingId() %></td>

                    <td><%= r.getCounsellorId() %></td>

                    <td><%= r.getSessionDate() %></td>

                    <td><%= r.getNotes() %></td>

                    <td><%= r.getFeedback() %></td>

                    <td>
                        <a href="SessionRecordServlet?action=delete&id=<%= r.getRecordId() %>"
                           class="btn-delete"
                           onclick="return confirm('Delete this session record?')">
                            Delete
                        </a>
                    </td>

                </tr>

            <%
                    }
                }else{
            %>

                <tr>
                    <td colspan="7" class="empty">
                        No session records found.
                    </td>
                </tr>

            <%
                }
            %>

            </tbody>

        </table>

    </div>

    <a href="dashboard.jsp" class="back">
        ? Back to Dashboard
    </a>

</div>

</body>
</html>