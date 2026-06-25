package com.counseling.model;

import java.io.Serializable;

public class Counsellor implements Serializable {

    private int counsellorId;
    private int userId;

    /*
     * This value comes from users.username.
     * It is used as the visible Counsellor ID, for example C001.
     * It is not another database column in the counsellors table.
     */
    private String username;

    private String counsellorName;
    private String specialization;
    private String email;
    private String phoneNumber;
    private String officeLocation;

    public Counsellor() {
    }

    public Counsellor(int counsellorId, int userId, String counsellorName,
            String specialization, String email, String phoneNumber,
            String officeLocation) {
        this.counsellorId = counsellorId;
        this.userId = userId;
        this.counsellorName = counsellorName;
        this.specialization = specialization;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.officeLocation = officeLocation;
    }

    public Counsellor(int userId, String counsellorName,
            String specialization, String email, String phoneNumber,
            String officeLocation) {
        this.userId = userId;
        this.counsellorName = counsellorName;
        this.specialization = specialization;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.officeLocation = officeLocation;
    }

    public int getCounsellorId() {
        return counsellorId;
    }

    public void setCounsellorId(int counsellorId) {
        this.counsellorId = counsellorId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getCounsellorName() {
        return counsellorName;
    }

    public void setCounsellorName(String counsellorName) {
        this.counsellorName = counsellorName;
    }

    public String getSpecialization() {
        return specialization;
    }

    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getOfficeLocation() {
        return officeLocation;
    }

    public void setOfficeLocation(String officeLocation) {
        this.officeLocation = officeLocation;
    }
}
