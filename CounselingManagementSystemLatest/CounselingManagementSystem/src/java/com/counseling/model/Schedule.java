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
import java.sql.Date;
import java.sql.Time;

public class Schedule implements Serializable {

    private int scheduleId;
    private int counsellorId;
    private Date availableDate;
    private Time availableTime;
    private String availabilityStatus;

    public Schedule() {
    }

    public Schedule(int scheduleId, int counsellorId, Date availableDate,
            Time availableTime, String availabilityStatus) {
        this.scheduleId = scheduleId;
        this.counsellorId = counsellorId;
        this.availableDate = availableDate;
        this.availableTime = availableTime;
        this.availabilityStatus = availabilityStatus;
    }

    public Schedule(int counsellorId, Date availableDate,
            Time availableTime, String availabilityStatus) {
        this.counsellorId = counsellorId;
        this.availableDate = availableDate;
        this.availableTime = availableTime;
        this.availabilityStatus = availabilityStatus;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public int getCounsellorId() {
        return counsellorId;
    }

    public void setCounsellorId(int counsellorId) {
        this.counsellorId = counsellorId;
    }

    public Date getAvailableDate() {
        return availableDate;
    }

    public void setAvailableDate(Date availableDate) {
        this.availableDate = availableDate;
    }

    public Time getAvailableTime() {
        return availableTime;
    }

    public void setAvailableTime(Time availableTime) {
        this.availableTime = availableTime;
    }

    public String getAvailabilityStatus() {
        return availabilityStatus;
    }

    public void setAvailabilityStatus(String availabilityStatus) {
        this.availabilityStatus = availabilityStatus;
    }
}
