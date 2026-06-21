<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Login | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/auth.css">
    </head>

    <body class="auth-page">
        <div class="auth-card">
            <h2>Welcome!</h2>
            <p class="subtitle">
                Sign in to manage your counselling sessions.
            </p>

            <form action="<%= request.getContextPath()%>/LoginServlet"
                  method="post">

                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username"
                           placeholder="Enter your username" required>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password"
                           placeholder="Enter your password" required>
                </div>

                <button type="submit" class="auth-button">
                    Sign In
                </button>
            </form>

            <% if (request.getParameter("error") != null) {
                    String errorMessage = request.getParameter("msg");

                    if (errorMessage == null) {
                        errorMessage = "Login failed. Please try again.";
                    }
            %>
            <div class="message-error">
                ❌ <%= errorMessage%>
            </div>
            <% } %>

            <% if (request.getParameter("success") != null) {
                    String successMessage = request.getParameter("msg");

                    if (successMessage == null) {
                        successMessage = "Registration successful. Please log in.";
                    }
            %>
            <div class="message-success">
                ✅ <%= successMessage%>
            </div>
            <% }%>

            <div class="auth-link">
                New student?
                <a href="<%= request.getContextPath()%>/RegisterServlet">
                    Create an account
                </a>
            </div>
        </div>
    </body>
</html>