<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.Counsellor"%>
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

    List<Counsellor> counsellorList
            = (List<Counsellor>) request.getAttribute("counsellorList");

    if (counsellorList == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/CounsellorServlet?action=list");
        return;
    }

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manage Counsellors | Counseling System</title>
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
                        <a href="<%= request.getContextPath()%>/UserServlet?action=list">
                            Student List
                        </a>
                    </li>
                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/CounsellorServlet?action=list">
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
                        <h1>Manage Counsellors</h1>
                        <p>
                            Create, update, and remove counsellor accounts.
                            The Counsellor ID is generated automatically from
                            the email text before the @ symbol.
                        </p>
                    </div>

                    <a class="primary-button"
                       href="<%= request.getContextPath()%>/CounsellorServlet?action=new">
                        + Add Counsellor
                    </a>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-success"><%= message%></div>
                <% } %>

                <section class="card">
                    <h2 class="card-title">Counsellor Profiles</h2>

                    <div class="table-container">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>No.</th>
                                    <th>Counsellor ID</th>
                                    <th>Full Name</th>
                                    <th>Specialization</th>
                                    <th>Email</th>
                                    <th>Phone Number</th>
                                    <th>Office Location</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>

                            <tbody>
                                <% if (!counsellorList.isEmpty()) {
                                int rowNumber = 1;
                                for (Counsellor counsellor : counsellorList) {%>
                                <tr>
                                    <td><%= rowNumber++%></td>
                                    <td><%= counsellor.getUsername() == null
                                            ? "-"
                                            : counsellor.getUsername().toUpperCase()%></td>
                                    <td><%= counsellor.getCounsellorName()%></td>
                                    <td><%= counsellor.getSpecialization()%></td>
                                    <td><%= counsellor.getEmail()%></td>
                                    <td><%= counsellor.getPhoneNumber() == null
                                            || counsellor.getPhoneNumber().trim().isEmpty()
                                            ? "-"
                                            : counsellor.getPhoneNumber()%></td>
                                    <td><%= counsellor.getOfficeLocation() == null
                                            || counsellor.getOfficeLocation().trim().isEmpty()
                                            ? "-"
                                            : counsellor.getOfficeLocation()%></td>
                                    <td>
                                        <a class="secondary-button"
                                           href="<%= request.getContextPath()%>/CounsellorServlet?action=edit&id=<%= counsellor.getCounsellorId()%>">
                                            Edit
                                        </a>

                                        <a class="danger-button"
                                           href="<%= request.getContextPath()%>/CounsellorServlet?action=delete&id=<%= counsellor.getCounsellorId()%>"
                                           onclick="return confirm('Delete this counsellor account?');">
                                            Delete
                                        </a>
                                    </td>
                                </tr>
                                <% }
                            } else { %>
                                <tr>
                                    <td colspan="8">No counsellor records found.</td>
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
