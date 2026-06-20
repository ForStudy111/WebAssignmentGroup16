<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Session Record</title>

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
        }

        .form-group{
            margin-bottom:20px;
        }

        label{
            display:block;
            margin-bottom:6px;
            font-weight:600;
        }

        textarea{
            width:100%;
            min-height:140px;
            padding:10px;
            border:1px solid #cbd5e1;
            border-radius:8px;
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

        <h2>Edit Session Record</h2>

        <form action="SessionRecordServlet" method="post">

            <input type="hidden" name="action" value="update">

            <input type="hidden"
                   name="id"
                   value="${record.recordId}">

            <div class="form-group">
                <label>Notes</label>

                <textarea name="notes">${record.notes}</textarea>
            </div>

            <div class="form-group">
                <label>Feedback</label>

                <textarea name="feedback">${record.feedback}</textarea>
            </div>

            <button type="submit" class="btn">
                Update Record
            </button>

        </form>

    </div>

    <a href="viewSessionHistory.jsp" class="back">
        ← Back to Session History
    </a>

</div>

</body>
</html>