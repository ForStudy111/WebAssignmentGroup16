<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login | Counseling System</title>

    <link rel="stylesheet" href="<%= request.getContextPath()%>/css/auth.css">
</head>

<body class="auth-page">
    <div class="auth-card">
        <h2>Welcome to Counseling System!</h2>
        <p class="subtitle">Sign in to manage your counselling sessions.</p>

        <form method="post"
              action="<%= request.getContextPath()%>/LoginServlet">

            <div class="form-group">
                <label for="username">User ID *</label>
                <input type="text"
                       id="username"
                       name="username"
                       autocomplete="username"
                       placeholder="Example: UK12345, C001 or ADMIN001"
                       oninput="this.value = this.value.toUpperCase()"
                       required>
            </div>

            <div class="form-group">
                <label for="password">Password *</label>
                <input type="password"
                       id="password"
                       name="password"
                       autocomplete="current-password"
                       required>
            </div>

            <button type="submit" class="auth-button">
                Sign In
            </button>
        </form>

        <% if (request.getParameter("error") != null) {
            String errorMessage = request.getParameter("msg");

            if (errorMessage == null || errorMessage.trim().isEmpty()) {
                errorMessage = "Login failed. Please try again.";
            }
        %>
            <div class="message-error"><%= errorMessage %></div>
        <% } %>
    </div>
</body>
</html>
