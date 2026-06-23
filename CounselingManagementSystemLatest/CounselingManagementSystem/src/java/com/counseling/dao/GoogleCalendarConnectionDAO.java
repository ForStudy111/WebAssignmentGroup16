package com.counseling.dao;

import com.counseling.model.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class GoogleCalendarConnectionDAO {

    public boolean saveOrUpdateConnection(int userId, String refreshToken) {

        String sql = "INSERT INTO google_calendar_connections "
                + "(user_id, google_calendar_id, refresh_token, "
                + "sync_enabled, last_synced_at) "
                + "VALUES (?, 'primary', ?, 1, NOW()) "
                + "ON DUPLICATE KEY UPDATE "
                + "google_calendar_id = 'primary', "
                + "refresh_token = ?, "
                + "sync_enabled = 1, "
                + "last_synced_at = NOW()";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);
            statement.setString(2, refreshToken);
            statement.setString(3, refreshToken);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean isConnected(int userId) {

        String sql = "SELECT refresh_token "
                + "FROM google_calendar_connections "
                + "WHERE user_id = ? "
                + "AND refresh_token IS NOT NULL "
                + "AND refresh_token <> '' "
                + "AND sync_enabled = 1";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public String getRefreshToken(int userId) {

        String sql = "SELECT refresh_token "
                + "FROM google_calendar_connections "
                + "WHERE user_id = ? "
                + "AND sync_enabled = 1";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {

                if (resultSet.next()) {
                    return resultSet.getString("refresh_token");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean disconnectCalendar(int userId) {

        String sql = "DELETE FROM google_calendar_connections "
                + "WHERE user_id = ?";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement
                = connection.prepareStatement(sql)) {

            statement.setInt(1, userId);

            return statement.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
