/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.counseling.dao;

/**
 *
 * @author wpy92
 */
import com.counseling.model.DBConnection;
import com.counseling.model.SessionRecord;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SessionRecordDAO {

    // CREATE: counsellor adds session notes
    public boolean addSessionRecord(SessionRecord record) {
        String sql = "INSERT INTO session_records "
                + "(booking_id, counsellor_id, session_notes, session_date) "
                + "VALUES (?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, record.getBookingId());
            ps.setInt(2, record.getCounsellorId());
            ps.setString(3, record.getSessionNotes());
            ps.setDate(4, record.getSessionDate());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // READ: all session records
    public List<SessionRecord> getAllSessionRecords() {
        List<SessionRecord> recordList = new ArrayList<>();

        String sql = "SELECT * FROM session_records ORDER BY session_date DESC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                recordList.add(mapSessionRecord(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return recordList;
    }

    // READ: one session record
    public SessionRecord getSessionRecordById(int recordId) {
        String sql = "SELECT * FROM session_records WHERE record_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, recordId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapSessionRecord(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // READ: record for one booking
    public SessionRecord getSessionRecordByBookingId(int bookingId) {
        String sql = "SELECT * FROM session_records WHERE booking_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, bookingId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapSessionRecord(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // READ: records belonging to one counsellor
    public List<SessionRecord> getRecordsByCounsellorId(int counsellorId) {
        List<SessionRecord> recordList = new ArrayList<>();

        String sql = "SELECT * FROM session_records "
                + "WHERE counsellor_id = ? "
                + "ORDER BY session_date DESC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, counsellorId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    recordList.add(mapSessionRecord(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return recordList;
    }

    // READ: session history for one student
    public List<SessionRecord> getRecordsByUserId(int userId) {
        List<SessionRecord> recordList = new ArrayList<>();

        String sql = "SELECT sr.* FROM session_records sr "
                + "JOIN bookings b ON sr.booking_id = b.booking_id "
                + "WHERE b.user_id = ? "
                + "ORDER BY sr.session_date DESC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    recordList.add(mapSessionRecord(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return recordList;
    }

    // UPDATE: counsellor edits notes
    public boolean updateSessionNotes(int recordId, String sessionNotes) {
        String sql = "UPDATE session_records SET session_notes = ? "
                + "WHERE record_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, sessionNotes);
            ps.setInt(2, recordId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // UPDATE: student submits feedback and rating
    public boolean updateFeedback(int recordId, String feedback, int rating) {
        String sql = "UPDATE session_records SET feedback = ?, rating = ? "
                + "WHERE record_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, feedback);
            ps.setInt(2, rating);
            ps.setInt(3, recordId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // DELETE
    public boolean deleteSessionRecord(int recordId) {
        String sql = "DELETE FROM session_records WHERE record_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, recordId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    private SessionRecord mapSessionRecord(ResultSet rs) throws SQLException {
        SessionRecord record = new SessionRecord();

        record.setRecordId(rs.getInt("record_id"));
        record.setBookingId(rs.getInt("booking_id"));
        record.setCounsellorId(rs.getInt("counsellor_id"));
        record.setSessionNotes(rs.getString("session_notes"));
        record.setFeedback(rs.getString("feedback"));

        int rating = rs.getInt("rating");
        if (rs.wasNull()) {
            record.setRating(null);
        } else {
            record.setRating(rating);
        }

        record.setSessionDate(rs.getDate("session_date"));

        return record;
    }
}
