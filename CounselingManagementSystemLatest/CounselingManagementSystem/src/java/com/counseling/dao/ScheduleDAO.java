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
import com.counseling.model.Schedule;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

public class ScheduleDAO {

    // CREATE
    public boolean addSchedule(Schedule schedule) {
        String sql = "INSERT INTO schedules "
                + "(counsellor_id, available_date, available_time, availability_status) "
                + "VALUES (?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, schedule.getCounsellorId());
            ps.setDate(2, schedule.getAvailableDate());
            ps.setTime(3, schedule.getAvailableTime());
            ps.setString(4, schedule.getAvailabilityStatus());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // READ: all schedules
    public List<Schedule> getAllSchedules() {
        List<Schedule> scheduleList = new ArrayList<>();

        String sql = "SELECT * FROM schedules "
                + "ORDER BY available_date ASC, available_time ASC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                scheduleList.add(mapSchedule(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return scheduleList;
    }

    // READ: available schedules for student booking
    public List<Schedule> getAvailableSchedules() {
        List<Schedule> scheduleList = new ArrayList<>();

        String sql = "SELECT * FROM schedules "
                + "WHERE availability_status = 'AVAILABLE' "
                + "ORDER BY available_date ASC, available_time ASC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                scheduleList.add(mapSchedule(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return scheduleList;
    }

    // READ: schedules belonging to one counsellor
    public List<Schedule> getSchedulesByCounsellorId(int counsellorId) {
        List<Schedule> scheduleList = new ArrayList<>();

        String sql = "SELECT * FROM schedules "
                + "WHERE counsellor_id = ? "
                + "ORDER BY available_date ASC, available_time ASC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, counsellorId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    scheduleList.add(mapSchedule(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return scheduleList;
    }

    // READ: one schedule
    public Schedule getScheduleById(int scheduleId) {
        String sql = "SELECT * FROM schedules WHERE schedule_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, scheduleId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapSchedule(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // UPDATE date, time, or status
    public boolean updateSchedule(Schedule schedule) {
        String sql = "UPDATE schedules SET "
                + "available_date = ?, available_time = ?, availability_status = ? "
                + "WHERE schedule_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setDate(1, schedule.getAvailableDate());
            ps.setTime(2, schedule.getAvailableTime());
            ps.setString(3, schedule.getAvailabilityStatus());
            ps.setInt(4, schedule.getScheduleId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Used by BookingDAO when a student books or cancels a slot
    public boolean updateScheduleStatus(int scheduleId, String status) {
        String sql = "UPDATE schedules SET availability_status = ? "
                + "WHERE schedule_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, scheduleId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // DELETE
    public boolean deleteSchedule(int scheduleId) {
        String sql = "DELETE FROM schedules WHERE schedule_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, scheduleId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    private Schedule mapSchedule(ResultSet rs) throws SQLException {
        Schedule schedule = new Schedule();

        schedule.setScheduleId(rs.getInt("schedule_id"));
        schedule.setCounsellorId(rs.getInt("counsellor_id"));
        schedule.setAvailableDate(rs.getDate("available_date"));
        schedule.setAvailableTime(rs.getTime("available_time"));
        schedule.setAvailabilityStatus(rs.getString("availability_status"));

        return schedule;
    }
}
