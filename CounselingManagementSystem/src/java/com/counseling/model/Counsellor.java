/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.counseling.model;

/**
 *
 * @author wpy92
 */
import java.io.Serializable;

public class Counsellor implements Serializable {

    private int counsellorId;
    private int userId;
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
