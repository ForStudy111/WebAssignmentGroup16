/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.counseling.dao;

/**
 *
 * @author wpy92
 */
import com.counseling.model.Counsellor;
import com.counseling.model.DBConnection;
import com.counseling.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class CounsellorDAO {

    // CREATE counsellor user account + counsellor profile together
    public boolean createCounsellor(User user, Counsellor counsellor) {
        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            String userSql = "INSERT INTO users "
                    + "(username, password, full_name, email, phone_number, role) "
                    + "VALUES (?, ?, ?, ?, ?, 'COUNSELOR')";

            try (PreparedStatement userPs = con.prepareStatement(
                    userSql, Statement.RETURN_GENERATED_KEYS)) {

                userPs.setString(1, user.getUsername());
                userPs.setString(2, user.getPassword());
                userPs.setString(3, user.getFullName());
                userPs.setString(4, user.getEmail());
                userPs.setString(5, user.getPhoneNumber());

                if (userPs.executeUpdate() == 0) {
                    con.rollback();
                    return false;
                }

                try (ResultSet generatedKeys = userPs.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        user.setUserId(generatedKeys.getInt(1));
                    } else {
                        con.rollback();
                        return false;
                    }
                }
            }

            String counsellorSql = "INSERT INTO counsellors "
                    + "(user_id, counsellor_name, specialization, email, "
                    + "phone_number, office_location) "
                    + "VALUES (?, ?, ?, ?, ?, ?)";

            try (PreparedStatement counsellorPs
                    = con.prepareStatement(counsellorSql)) {

                counsellorPs.setInt(1, user.getUserId());
                counsellorPs.setString(2, counsellor.getCounsellorName());
                counsellorPs.setString(3, counsellor.getSpecialization());
                counsellorPs.setString(4, counsellor.getEmail());
                counsellorPs.setString(5, counsellor.getPhoneNumber());
                counsellorPs.setString(6, counsellor.getOfficeLocation());

                if (counsellorPs.executeUpdate() == 0) {
                    con.rollback();
                    return false;
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

    // READ: all counsellors
    public List<Counsellor> getAllCounsellors() {
        List<Counsellor> counsellorList = new ArrayList<>();

        String sql = "SELECT * FROM counsellors ORDER BY counsellor_id DESC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                counsellorList.add(mapCounsellor(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return counsellorList;
    }

    // READ: one counsellor
    public Counsellor getCounsellorById(int counsellorId) {
        String sql = "SELECT * FROM counsellors WHERE counsellor_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, counsellorId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCounsellor(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // READ: counsellor profile by logged-in user ID
    public Counsellor getCounsellorByUserId(int userId) {
        String sql = "SELECT * FROM counsellors WHERE user_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCounsellor(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // UPDATE counsellor profile
    public boolean updateCounsellor(Counsellor counsellor) {
        String sql = "UPDATE counsellors SET "
                + "counsellor_name = ?, specialization = ?, email = ?, "
                + "phone_number = ?, office_location = ? "
                + "WHERE counsellor_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, counsellor.getCounsellorName());
            ps.setString(2, counsellor.getSpecialization());
            ps.setString(3, counsellor.getEmail());
            ps.setString(4, counsellor.getPhoneNumber());
            ps.setString(5, counsellor.getOfficeLocation());
            ps.setInt(6, counsellor.getCounsellorId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // DELETE profile only
    public boolean deleteCounsellor(int counsellorId) {
        String sql = "DELETE FROM counsellors WHERE counsellor_id = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, counsellorId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    private Counsellor mapCounsellor(ResultSet rs) throws SQLException {
        Counsellor counsellor = new Counsellor();

        counsellor.setCounsellorId(rs.getInt("counsellor_id"));
        counsellor.setUserId(rs.getInt("user_id"));
        counsellor.setCounsellorName(rs.getString("counsellor_name"));
        counsellor.setSpecialization(rs.getString("specialization"));
        counsellor.setEmail(rs.getString("email"));
        counsellor.setPhoneNumber(rs.getString("phone_number"));
        counsellor.setOfficeLocation(rs.getString("office_location"));

        return counsellor;
    }
}
