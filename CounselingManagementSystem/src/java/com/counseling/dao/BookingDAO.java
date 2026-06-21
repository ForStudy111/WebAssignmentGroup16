/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.counseling.dao;

/**
 *
 * @author wpy92
 */
import java.sql.ResultSet;
import com.counseling.model.Booking;
import com.counseling.model.DBConnection;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {

    // CREATE: book an AVAILABLE schedule slot
    public boolean addBooking(Booking booking) {
        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // Only change the slot if it is still AVAILABLE.
            String updateScheduleSql = "UPDATE schedules "
                    + "SET availability_status = 'BOOKED' "
                    + "WHERE schedule_id = ? AND availability_status = 'AVAILABLE'";

            try (PreparedStatement updateSchedulePs
                    = con.prepareStatement(updateScheduleSql)) {

                updateSchedulePs.setInt(1, booking.getScheduleId());

                if (updateSchedulePs.executeUpdate() == 0) {
                    con.rollback();
                    return false;
                }
            }

            String insertBookingSql = "INSERT INTO bookings "
                    + "(user_id, schedule_id, booking_date, booking_status, "
                    + "calendar_sync_status) "
                    + "VALUES (?, ?, ?, ?, ?)";

            try (PreparedStatement insertBookingPs = con.prepareStatement(
                    insertBookingSql, Statement.RETURN_GENERATED_KEYS)) {

                insertBookingPs.setInt(1, booking.getUserId());
                insertBookingPs.setInt(2, booking.getScheduleId());
                insertBookingPs.setDate(3, booking.getBookingDate());
                insertBookingPs.setString(4, booking.getBookingStatus());
                insertBookingPs.setString(5, booking.getCalendarSyncStatus());

                if (insertBookingPs.executeUpdate() == 0) {
                    con.rollback();
                    return false;
                }

                try (ResultSet generatedKeys = insertBookingPs.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        booking.setBookingId(generatedKeys.getInt(1));
                    }
                }
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();

            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException rollbackError) {
                    rollbackError.printStackTrace();
                }
            }

            return false;

        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // READ: all bookings
    public List<Booking> getAllBookings() {
        List<Booking> bookingList = new ArrayList<>();

        String sql = "SELECT * FROM bookings ORDER BY booking_id DESC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                bookingList.add(mapBooking(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return bookingList;
    }

    // READ: one booking
    public Booking getBookingById(int bookingId) {
        String sql = "SELECT * FROM bookings WHERE booking_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapBooking(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // READ: bookings for one student
    public List<Booking> getBookingsByUserId(int userId) {
        List<Booking> bookingList = new ArrayList<>();

        String sql = "SELECT * FROM bookings "
                + "WHERE user_id = ? "
                + "ORDER BY booking_id DESC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bookingList.add(mapBooking(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return bookingList;
    }

    // READ: bookings assigned to one counsellor
    public List<Booking> getBookingsByCounsellorId(int counsellorId) {
        List<Booking> bookingList = new ArrayList<>();

        String sql = "SELECT b.* FROM bookings b "
                + "JOIN schedules s ON b.schedule_id = s.schedule_id "
                + "WHERE s.counsellor_id = ? "
                + "ORDER BY s.available_date ASC, s.available_time ASC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, counsellorId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    bookingList.add(mapBooking(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return bookingList;
    }

    // UPDATE: change booking status, for example PENDING -> APPROVED
    public boolean updateBookingStatus(int bookingId, String bookingStatus) {
        String sql = "UPDATE bookings SET booking_status = ? "
                + "WHERE booking_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, bookingStatus);
            ps.setInt(2, bookingId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // UPDATE: change the Google Calendar sync details later
    public boolean updateCalendarSync(int bookingId, String googleEventId,
            String googleEventLink, String syncStatus) {

        String sql = "UPDATE bookings SET "
                + "google_event_id = ?, google_event_link = ?, "
                + "calendar_sync_status = ? "
                + "WHERE booking_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, googleEventId);
            ps.setString(2, googleEventLink);
            ps.setString(3, syncStatus);
            ps.setInt(4, bookingId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // UPDATE: reschedule to another AVAILABLE slot
    public boolean rescheduleBooking(int bookingId, int newScheduleId) {
        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            int oldScheduleId = getScheduleIdByBookingId(con, bookingId);

            if (oldScheduleId == 0) {
                con.rollback();
                return false;
            }

            String bookNewSlotSql = "UPDATE schedules "
                    + "SET availability_status = 'BOOKED' "
                    + "WHERE schedule_id = ? AND availability_status = 'AVAILABLE'";

            try (PreparedStatement bookNewSlotPs
                    = con.prepareStatement(bookNewSlotSql)) {

                bookNewSlotPs.setInt(1, newScheduleId);

                if (bookNewSlotPs.executeUpdate() == 0) {
                    con.rollback();
                    return false;
                }
            }

            String updateBookingSql = "UPDATE bookings SET "
                    + "schedule_id = ?, booking_status = 'PENDING', "
                    + "google_event_id = NULL, google_event_link = NULL, "
                    + "calendar_sync_status = 'NOT_SYNCED' "
                    + "WHERE booking_id = ?";

            try (PreparedStatement updateBookingPs
                    = con.prepareStatement(updateBookingSql)) {

                updateBookingPs.setInt(1, newScheduleId);
                updateBookingPs.setInt(2, bookingId);

                if (updateBookingPs.executeUpdate() == 0) {
                    con.rollback();
                    return false;
                }
            }

            String releaseOldSlotSql = "UPDATE schedules "
                    + "SET availability_status = 'AVAILABLE' "
                    + "WHERE schedule_id = ?";

            try (PreparedStatement releaseOldSlotPs
                    = con.prepareStatement(releaseOldSlotSql)) {

                releaseOldSlotPs.setInt(1, oldScheduleId);
                releaseOldSlotPs.executeUpdate();
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();

            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException rollbackError) {
                    rollbackError.printStackTrace();
                }
            }

            return false;

        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // DELETE / CANCEL: remove booking and make its slot available again
    public boolean cancelBooking(int bookingId) {
        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            int scheduleId = getScheduleIdByBookingId(con, bookingId);

            if (scheduleId == 0) {
                con.rollback();
                return false;
            }

            String deleteBookingSql = "DELETE FROM bookings WHERE booking_id = ?";

            try (PreparedStatement deleteBookingPs
                    = con.prepareStatement(deleteBookingSql)) {

                deleteBookingPs.setInt(1, bookingId);

                if (deleteBookingPs.executeUpdate() == 0) {
                    con.rollback();
                    return false;
                }
            }

            String releaseScheduleSql = "UPDATE schedules "
                    + "SET availability_status = 'AVAILABLE' "
                    + "WHERE schedule_id = ?";

            try (PreparedStatement releaseSchedulePs
                    = con.prepareStatement(releaseScheduleSql)) {

                releaseSchedulePs.setInt(1, scheduleId);
                releaseSchedulePs.executeUpdate();
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            e.printStackTrace();

            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException rollbackError) {
                    rollbackError.printStackTrace();
                }
            }

            return false;

        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private int getScheduleIdByBookingId(Connection con, int bookingId)
            throws SQLException {

        String sql = "SELECT schedule_id FROM bookings WHERE booking_id = ?";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("schedule_id");
                }
            }
        }

        return 0;
    }

    private Booking mapBooking(ResultSet rs) throws SQLException {
        Booking booking = new Booking();

        booking.setBookingId(rs.getInt("booking_id"));
        booking.setUserId(rs.getInt("user_id"));
        booking.setScheduleId(rs.getInt("schedule_id"));
        booking.setBookingDate(rs.getDate("booking_date"));
        booking.setBookingStatus(rs.getString("booking_status"));
        booking.setCancelledBy(rs.getString("cancelled_by"));
        booking.setGoogleEventId(rs.getString("google_event_id"));
        booking.setGoogleEventLink(rs.getString("google_event_link"));
        booking.setCalendarSyncStatus(rs.getString("calendar_sync_status"));

        return booking;
    }

    public boolean updateGoogleCalendarInfo(int bookingId,
            String googleEventId,
            String googleEventLink,
            String calendarSyncStatus) {

        String sql = "UPDATE bookings "
                + "SET google_event_id = ?, "
                + "google_event_link = ?, "
                + "calendar_sync_status = ? "
                + "WHERE booking_id = ?";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setString(1, googleEventId);
            statement.setString(2, googleEventLink);
            statement.setString(3, calendarSyncStatus);
            statement.setInt(4, bookingId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean cancelBookingAndReleaseSchedule(int bookingId,
            String cancelledBy) {

        String findSql = "SELECT schedule_id FROM bookings "
                + "WHERE booking_id = ? "
                + "AND booking_status IN ('PENDING', 'APPROVED') "
                + "FOR UPDATE";

        String cancelSql = "UPDATE bookings "
                + "SET booking_status = 'CANCELLED', "
                + "cancelled_by = ? "
                + "WHERE booking_id = ? "
                + "AND booking_status IN ('PENDING', 'APPROVED')";

        String releaseSql = "UPDATE schedules "
                + "SET availability_status = 'AVAILABLE' "
                + "WHERE schedule_id = ?";

        Connection connection = null;

        try {
            connection = DBConnection.getConnection();
            connection.setAutoCommit(false);

            int scheduleId = 0;

            try (PreparedStatement findStatement
                    = connection.prepareStatement(findSql)) {

                findStatement.setInt(1, bookingId);

                try (ResultSet resultSet = findStatement.executeQuery()) {
                    if (resultSet.next()) {
                        scheduleId = resultSet.getInt("schedule_id");
                    }
                }
            }

            if (scheduleId == 0) {
                connection.rollback();
                return false;
            }

            try (PreparedStatement cancelStatement
                    = connection.prepareStatement(cancelSql); PreparedStatement releaseStatement
                    = connection.prepareStatement(releaseSql)) {

                cancelStatement.setString(1, cancelledBy);
                cancelStatement.setInt(2, bookingId);

                int cancelled = cancelStatement.executeUpdate();

                if (cancelled != 1) {
                    connection.rollback();
                    return false;
                }

                releaseStatement.setInt(1, scheduleId);
                releaseStatement.executeUpdate();

                connection.commit();
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();

            try {
                if (connection != null) {
                    connection.rollback();
                }
            } catch (SQLException rollbackError) {
                rollbackError.printStackTrace();
            }

            return false;

        } finally {
            try {
                if (connection != null) {
                    connection.setAutoCommit(true);
                    connection.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public boolean rejectBookingAndReleaseSchedule(int bookingId) {

        String findSql = "SELECT schedule_id FROM bookings "
                + "WHERE booking_id = ? "
                + "AND booking_status = 'PENDING' "
                + "FOR UPDATE";

        String rejectSql = "UPDATE bookings "
                + "SET booking_status = 'REJECTED', "
                + "cancelled_by = NULL "
                + "WHERE booking_id = ? "
                + "AND booking_status = 'PENDING'";

        String releaseSql = "UPDATE schedules "
                + "SET availability_status = 'AVAILABLE' "
                + "WHERE schedule_id = ?";

        Connection connection = null;

        try {
            connection = DBConnection.getConnection();
            connection.setAutoCommit(false);

            int scheduleId = 0;

            try (PreparedStatement findStatement
                    = connection.prepareStatement(findSql)) {

                findStatement.setInt(1, bookingId);

                try (ResultSet resultSet = findStatement.executeQuery()) {
                    if (resultSet.next()) {
                        scheduleId = resultSet.getInt("schedule_id");
                    }
                }
            }

            if (scheduleId == 0) {
                connection.rollback();
                return false;
            }

            try (PreparedStatement rejectStatement
                    = connection.prepareStatement(rejectSql); PreparedStatement releaseStatement
                    = connection.prepareStatement(releaseSql)) {

                rejectStatement.setInt(1, bookingId);

                int rejected = rejectStatement.executeUpdate();

                if (rejected != 1) {
                    connection.rollback();
                    return false;
                }

                releaseStatement.setInt(1, scheduleId);
                releaseStatement.executeUpdate();

                connection.commit();
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();

            try {
                if (connection != null) {
                    connection.rollback();
                }
            } catch (SQLException rollbackError) {
                rollbackError.printStackTrace();
            }

            return false;

        } finally {
            try {
                if (connection != null) {
                    connection.setAutoCommit(true);
                    connection.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
