<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Session Record | Counselor</title>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600&display=swap" rel="stylesheet">

    <style>
        body{
            font-family:'Inter',sans-serif;
            background:#f8fafc;
            padding:40px;
        }

        .container{
            max-width:800px;
            margin:auto;
        }

        .card{
            background:white;
            padding:30px;
            border-radius:12px;
            box-shadow:0 4px 6px rgba(0,0,0,0.05);
        }

        h2{
            color:#1e1b4b;
            margin-top:0;
        }

        .form-group{
            margin-bottom:18px;
        }

        label{
            display:block;
            margin-bottom:6px;
            font-weight:600;
        }

        input,
        textarea{
            width:100%;
            padding:10px;
            border:1px solid #cbd5e1;
            border-radius:8px;
            box-sizing:border-box;
        }

        textarea{
            min-height:120px;
            resize:vertical;
        }

        .btn{
            background:#4f46e5;
            color:white;
            border:none;
            padding:12px 20px;
            border-radius:8px;
            cursor:pointer;
            font-weight:600;
        }

        .btn:hover{
            background:#4338ca;
        }

        .back{
            display:inline-block;
            margin-top:20px;
            text-decoration:none;
            color:#4f46e5;
            font-weight:600;
        }
    </style>
</head>

<body>

<div class="container">

    <div class="card">

        <h2>Add Session Record</h2>

        <form action="SessionRecordServlet" method="post">

            <input type="hidden" name="action" value="insert">

            <div class="form-group">
                <label>Booking ID</label>
                <input type="number" name="booking_id" required>
            </div>

            <div class="form-group">
                <label>Counsellor ID</label>
                <input type="number" name="counsellor_id" required>
            </div>

            <div class="form-group">
                <label>Session Date</label>
                <input type="date" name="date" required>
            </div>

            <div class="form-group">
                <label>Session Notes</label>
                <textarea name="notes" required></textarea>
            </div>

            <div class="form-group">
                <label>Feedback</label>
                <textarea name="feedback"></textarea>
            </div>

            <button type="submit" class="btn">
                Save Session Record
            </button>

        </form>

    </div>

    <a href="viewSessionHistory.jsp" class="back">
        ← Back to Session History
    </a>

</div>

</body>
</html>