<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="java.util.List"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null
            || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg=Please+log+in+as+an+admin.");
        return;
    }

    List<User> userList = (List<User>) request.getAttribute("userList");
    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Student List | Counseling System</title>
        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/admin.css">
    </head>

    <body class="dashboard-page">
        <div class="dashboard-layout">

            <aside class="sidebar">
                <h2 class="sidebar-brand">Admin Portal</h2>

                <ul class="sidebar-menu">
                    <li>
                        <a href="<%= request.getContextPath()%>/admin/dashboard.jsp">
                            Dashboard
                        </a>
                    </li>
                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/UserServlet?action=list">
                            Student List
                        </a>
                    </li>
                    <li>
                        <a href="<%= request.getContextPath()%>/CounsellorServlet?action=list">
                            Manage Counsellors
                        </a>
                    </li>
                    <li>
                        <a href="<%= request.getContextPath()%>/BookingServlet?action=adminList">
                            View Bookings
                        </a>
                    </li>
                    <li>
                        <a href="<%= request.getContextPath()%>/UserServlet?action=profile">
                            My Profile
                        </a>
                    </li>
                    <li>
                        <a class="logout-link"
                           href="<%= request.getContextPath()%>/LogoutServlet">
                            Logout
                        </a>
                    </li>
                </ul>
            </aside>

            <main class="main-content">
                <div class="page-header">
                    <div>
                        <h1>Student List</h1>
                        <p>
                            View existing student accounts and update phone numbers
                            when necessary. Student accounts are prepared through
                            database dummy data.
                        </p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success"><%= message%></div>
                <% } %>

                <section class="card">
                    <h2 class="card-title">Student Accounts</h2>

                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>No.</th>
                                    <th>Student ID</th>
                                    <th>Full Name</th>
                                    <th>Email</th>
                                    <th>Phone Number</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>

                            <tbody>
                                <% if (userList != null && !userList.isEmpty()) {
                                int rowNumber = 1;

                                for (User user : userList) {%>
                                <tr>
                                    <td><%= rowNumber++%></td>
                                    <td><%= user.getUsername() == null
                                            ? "-"
                                            : user.getUsername().toUpperCase()%></td>
                                    <td><%= user.getFullName()%></td>
                                    <td><%= user.getEmail()%></td>
                                    <td><%= user.getPhoneNumber() == null
                                            || user.getPhoneNumber().trim().isEmpty()
                                            ? "-"
                                            : user.getPhoneNumber()%></td>
                                    <td>
                                        <a class="secondary-button"
                                           href="<%= request.getContextPath()%>/UserServlet?action=edit&id=<%= user.getUserId()%>">
                                            Edit Phone
                                        </a>
                                    </td>
                                </tr>
                                <% }
                            } else { %>
                                <tr>
                                    <td colspan="6">No student records found.</td>
                                </tr>
                                <% }%>
                            </tbody>
                        </table>
                    </div>
                </section>
            </main>
        </div>
    </body>
</html>
