<%-- 
    Document   : register
    Created on : Jun 21, 2026, 3:40:57 AM
    Author     : wpy92
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Register | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/auth.css">
    </head>

    <body class="auth-page">
        <div class="auth-card">
            <h2>Create Account</h2>
            <p class="subtitle">
                Register as a student to book counselling sessions.
            </p>

            <form action="<%= request.getContextPath()%>/RegisterServlet"
                  method="post"
                  onsubmit="return validateRegisterForm();">

                <div class="form-group">
                    <label for="fullName">Full Name *</label>
                    <input type="text" id="fullName" name="fullName"
                           placeholder="Enter your full name" required>
                </div>

                <div class="form-group">
                    <label for="username">Username *</label>
                    <input type="text" id="username" name="username"
                           placeholder="Choose a username" required>
                </div>

                <div class="form-group">
                    <label for="email">Email *</label>
                    <input type="email" id="email" name="email"
                           placeholder="Enter your email" required>
                </div>

                <div class="form-group">
                    <label for="phoneNumber">Phone Number</label>
                    <input type="tel" id="phoneNumber" name="phoneNumber"
                           placeholder="Example: 0123456789">
                </div>

                <div class="form-group">
                    <label for="password">Password *</label>
                    <input type="password" id="password" name="password"
                           placeholder="At least 6 characters" required>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm Password *</label>
                    <input type="password" id="confirmPassword"
                           name="confirmPassword"
                           placeholder="Re-enter your password" required>
                </div>

                <button type="submit" class="auth-button">
                    Create Account
                </button>
            </form>

            <% if (request.getParameter("error") != null) {
                    String errorMessage = request.getParameter("msg");
                    if (errorMessage == null) {
                        errorMessage = "Registration failed. Please try again.";
                    }
            %>
            <div class="message-error">
                ❌ <%= errorMessage%>
            </div>
            <% }%>

            <div class="auth-link">
                Already have an account?
                <a href="<%= request.getContextPath()%>/login.jsp">
                    Sign in
                </a>
            </div>
        </div>

        <script>
            function validateRegisterForm() {
                const password = document.getElementById("password").value;
                const confirmPassword =
                        document.getElementById("confirmPassword").value;

                if (password.length < 6) {
                    alert("Password must contain at least 6 characters.");
                    return false;
                }

                if (password !== confirmPassword) {
                    alert("Password and confirm password do not match.");
                    return false;
                }

                return true;
            }
        </script>
    </body>
</html>