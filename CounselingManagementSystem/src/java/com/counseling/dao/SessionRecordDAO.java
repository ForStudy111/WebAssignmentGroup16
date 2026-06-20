/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.counseling.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.counseling.model.SessionRecord;

public class SessionRecordDAO {

    private String jdbcURL
            = "jdbc:mysql://localhost:3306/counselling";

    private String jdbcUsername = "root";
    private String jdbcPassword = "";

    private static final String INSERT
            = "INSERT INTO session_record "
            + "(booking_id,counsellor_id,session_date,notes,feedback) "
            + "VALUES(?,?,?,?,?)";

    private static final String SELECT_ALL
            = "SELECT * FROM session_record";

    private static final String SELECT_BY_ID
            = "SELECT * FROM session_record WHERE record_id=?";

    private static final String UPDATE
            = "UPDATE session_record SET notes=?, feedback=? WHERE record_id=?";

    private static final String DELETE
            = "DELETE FROM session_record WHERE record_id=?";

    protected Connection getConnection()
            throws SQLException {

        return DriverManager.getConnection(
                jdbcURL,
                jdbcUsername,
                jdbcPassword);
    }

    // CREATE
    public void insertRecord(SessionRecord record)
            throws SQLException {

        Connection con = getConnection();

        PreparedStatement ps
                = con.prepareStatement(INSERT);

        ps.setInt(1, record.getBookingId());
        ps.setInt(2, record.getCounsellorId());
        ps.setString(3, record.getSessionDate());
        ps.setString(4, record.getNotes());
        ps.setString(5, record.getFeedback());

        ps.executeUpdate();

    }

    // VIEW
    public List<SessionRecord> selectAllRecords()
            throws SQLException {

        List<SessionRecord> list
                = new ArrayList<>();

        Connection con = getConnection();

        PreparedStatement ps
                = con.prepareStatement(SELECT_ALL);

        ResultSet rs = ps.executeQuery();

        while (rs.next()) {

            SessionRecord record
                    = new SessionRecord();

            record.setRecordId(
                    rs.getInt("record_id"));

            record.setBookingId(
                    rs.getInt("booking_id"));

            record.setCounsellorId(
                    rs.getInt("counsellor_id"));

            record.setSessionDate(
                    rs.getString("session_date"));

            record.setNotes(
                    rs.getString("notes"));

            record.setFeedback(
                    rs.getString("feedback"));

            list.add(record);
        }

        return list;
    }

    // UPDATE
    public boolean updateRecord(SessionRecord record)
            throws SQLException {

        Connection con = getConnection();

        PreparedStatement ps
                = con.prepareStatement(UPDATE);

        ps.setString(1, record.getNotes());
        ps.setString(2, record.getFeedback());
        ps.setInt(3, record.getRecordId());

        return ps.executeUpdate() > 0;

    }

    // DELETE
    public boolean deleteRecord(int id)
            throws SQLException {

        Connection con = getConnection();

        PreparedStatement ps
                = con.prepareStatement(DELETE);

        ps.setInt(1, id);

        return ps.executeUpdate() > 0;

    }

    public SessionRecord selectRecord(int id) throws SQLException {

        SessionRecord record = null;

        String sql
                = "SELECT * FROM session_record WHERE record_id=?";

        Connection con = getConnection();

        PreparedStatement ps
                = con.prepareStatement(sql);

        ps.setInt(1, id);

        ResultSet rs
                = ps.executeQuery();

        if (rs.next()) {

            record = new SessionRecord();

            record.setRecordId(
                    rs.getInt("record_id")
            );

            record.setBookingId(
                    rs.getInt("booking_id")
            );

            record.setCounsellorId(
                    rs.getInt("counsellor_id")
            );

            record.setSessionDate(
                    rs.getString("session_date")
            );

            record.setNotes(
                    rs.getString("notes")
            );

            record.setFeedback(
                    rs.getString("feedback")
            );
        }

        return record;
    }

}
