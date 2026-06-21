<%-- 
    Document   : users
    Created on : Jun 21, 2026, 4:25:18 AM
    Author     : wpy92
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="java.util.List"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null
            || !"ADMIN".equalsIgnoreCase(currentUser.getRole())) {

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg=Please+log+in+as+an+admin."
        );
        return;
    }

    List<User> userList = (List<User>) request.getAttribute("userList");

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manage Users | Counseling System</title>

        <link rel="stylesheet" href="<%= request.getContextPath() %>/css/admin.css">
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
                            Manage Users
                        </a>
                    </li>

                    <li>
                        <a href="#">
                            Manage Counsellors
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/admin/bookings.jsp">
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
                        <h1>Manage Users</h1>
                        <p>Create, update, and remove system accounts.</p>
                    </div>

                    <a class="primary-button"
                       href="<%= request.getContextPath()%>/UserServlet?action=new">
                        + Add User
                    </a>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success">
                    <%= message%>
                </div>
                <% } %>

                <section class="card">
                    <h2 class="card-title">User Accounts</h2>

                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Full Name</th>
                                    <th>Username</th>
                                    <th>Email</th>
                                    <th>Phone Number</th>
                                    <th>Role</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>

                            <tbody>
                                <% if (userList != null && !userList.isEmpty()) {
                                    for (User user : userList) {%>

                                <tr>
                                    <td><%= user.getUserId()%></td>
                                    <td><%= user.getFullName()%></td>
                                    <td><%= user.getUsername()%></td>
                                    <td><%= user.getEmail()%></td>
                                    <td>
                                        <%= user.getPhoneNumber() == null
                                                ? "-"
                                                : user.getPhoneNumber()%>
                                    </td>

                                    <td>
                                        <% if ("ADMIN".equalsIgnoreCase(user.getRole())) { %>
                                        <span class="badge badge-admin">ADMIN</span>

                                        <% } else if ("COUNSELOR".equalsIgnoreCase(user.getRole())) { %>
                                        <span class="badge badge-counselor">COUNSELOR</span>

                                        <% } else { %>
                                        <span class="badge badge-student">STUDENT</span>
                                        <% }%>
                                    </td>

                                    <td>
                                        <a class="secondary-button"
                                           href="<%= request.getContextPath()%>/UserServlet?action=edit&id=<%= user.getUserId()%>">
                                            Edit
                                        </a>

                                        <% if (user.getUserId() != currentUser.getUserId()) {%>
                                        <a class="danger-button"
                                           href="<%= request.getContextPath()%>/UserServlet?action=delete&id=<%= user.getUserId()%>"
                                           onclick="return confirm('Delete this user account?');">
                                            Delete
                                        </a>
                                        <% } %>
                                    </td>
                                </tr>

                                <%  }
                            } else { %>

                                <tr>
                                    <td colspan="7">
                                        No user records found.
                                    </td>
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
