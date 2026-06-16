<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Login | Counseling System</title>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;500;700&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Inter', sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0;
            }
            .login-card {
                background: white;
                padding: 40px;
                border-radius: 16px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.2);
                width: 100%;
                max-width: 350px;
                text-align: center;
            }
            h2 {
                color: #2d3748;
                margin-bottom: 8px;
            }
            p {
                color: #718096;
                font-size: 14px;
                margin-bottom: 24px;
            }
            input {
                width: 100%;
                padding: 12px;
                margin-bottom: 16px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                box-sizing: border-box;
                outline: none;
                transition: 0.2s;
            }
            input:focus {
                border-color: #667eea;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            }
            button {
                width: 100%;
                padding: 12px;
                background: #667eea;
                color: white;
                border: none;
                border-radius: 8px;
                font-weight: 600;
                cursor: pointer;
                transition: 0.3s;
            }
            button:hover {
                background: #5a67d8;
                transform: translateY(-1px);
            }
            .error {
                color: #e53e3e;
                font-size: 13px;
                margin-top: 12px;
            }
        </style>
    </head>
    <body>
        <div class="login-card">
            <h2>Welcome Back</h2>
            <p>Please enter your details to login</p>
            <form action="LoginServlet" method="POST">
                <input type="text" name="username" placeholder="Username" required>
                <input type="password" name="password" placeholder="Password" required>
                <button type="submit">Sign In</button>
            </form>
            <% if (request.getParameter("error") != null) { %>
                <div class="error">Invalid username or password.</div>
            <% }%>
        </div>
    </body>
</html>