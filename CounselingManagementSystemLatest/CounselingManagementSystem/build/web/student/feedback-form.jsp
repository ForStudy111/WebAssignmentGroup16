<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.counseling.model.User"%>
<%@page import="com.counseling.model.SessionRecord"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    if (currentUser == null
            || !"STUDENT".equalsIgnoreCase(currentUser.getRole())) {

        response.sendRedirect(
                request.getContextPath()
                + "/login.jsp?error=true&msg=Please+log+in+as+a+student."
        );
        return;
    }

    SessionRecord selectedRecord
            = (SessionRecord) request.getAttribute("selectedRecord");

    if (selectedRecord == null) {
        response.sendRedirect(
                request.getContextPath()
                + "/SessionRecordServlet?action=studentHistory"
        );
        return;
    }

    String feedbackValue = selectedRecord.getFeedback() == null
            ? ""
            : selectedRecord.getFeedback();

    Integer ratingValue = selectedRecord.getRating();

    String message = request.getParameter("msg");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Session Feedback | Counseling System</title>

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/student.css">

        <link rel="stylesheet"
              href="<%= request.getContextPath()%>/css/validation.css">
    </head>

    <body class="dashboard-page">
        <div class="dashboard-layout">

            <aside class="sidebar">
                <h2 class="sidebar-brand">Student Care</h2>

                <ul class="sidebar-menu">
                    <li>
                        <a href="<%= request.getContextPath()%>/student/dashboard.jsp">
                            Dashboard
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/BookingServlet?action=available">
                            Book Session
                        </a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath()%>/BookingServlet?action=myBookings">
                            My Bookings
                        </a>
                    </li>

                    <li>
                        <a class="active"
                           href="<%= request.getContextPath()%>/SessionRecordServlet?action=studentHistory">
                            Session History
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
                        <h1>Session Feedback</h1>
                        <p>
                            Share your experience for completed session record
                            #<%= selectedRecord.getRecordId()%>.
                        </p>
                    </div>
                </div>

                <% if (message != null && !message.trim().isEmpty()) {%>
                <div class="message-error">
                    <%= message%>
                </div>
                <% }%>

                <section class="card">
                    <h2 class="card-title">Your Feedback</h2>

                    <form action="<%= request.getContextPath()%>/SessionRecordServlet"
                          method="post"
                          class="validate-form"
                          novalidate>

                        <input type="hidden"
                               name="action"
                               value="submitFeedback">

                        <input type="hidden"
                               name="recordId"
                               value="<%= selectedRecord.getRecordId()%>">

                        <div class="form-group">
                            <label for="rating">Rating *</label>

                            <select id="rating"
                                    name="rating"
                                    required
                                    data-label="Rating"
                                    data-rating="true">

                                <option value="">Select rating</option>

                                <option value="1"
                                        <%= ratingValue != null && ratingValue == 1
                                            ? "selected" : ""%>>
                                    1 - Very Dissatisfied
                                </option>

                                <option value="2"
                                        <%= ratingValue != null && ratingValue == 2
                                            ? "selected" : ""%>>
                                    2 - Dissatisfied
                                </option>

                                <option value="3"
                                        <%= ratingValue != null && ratingValue == 3
                                            ? "selected" : ""%>>
                                    3 - Neutral
                                </option>

                                <option value="4"
                                        <%= ratingValue != null && ratingValue == 4
                                            ? "selected" : ""%>>
                                    4 - Satisfied
                                </option>

                                <option value="5"
                                        <%= ratingValue != null && ratingValue == 5
                                            ? "selected" : ""%>>
                                    5 - Very Satisfied
                                </option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="feedback">Comments *</label>

                            <textarea id="feedback"
                                      name="feedback"
                                      rows="7"
                                      required
                                      data-label="Comments"
                                      data-minlength="5"
                                      placeholder="Write your feedback about the counselling session..."><%= feedbackValue%></textarea>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="primary-button">
                                Submit Feedback
                            </button>

                            <a class="secondary-button"
                               href="<%= request.getContextPath()%>/SessionRecordServlet?action=studentHistory">
                                Cancel
                            </a>
                        </div>
                    </form>
                </section>
            </main>
        </div>

        <script src="<%= request.getContextPath()%>/js/validation.js"></script>
    </body>
</html>
