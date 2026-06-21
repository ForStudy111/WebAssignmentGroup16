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

public class Booking implements Serializable {

    private int bookingId;
    private int userId;
    private int scheduleId;
    private Date bookingDate;
    private String bookingStatus;
    private String cancelledBy;

    // Google Calendar fields
    private String googleEventId;
    private String googleEventLink;
    private String calendarSyncStatus;

    public Booking() {
    }

    public Booking(int bookingId, int userId, int scheduleId,
            Date bookingDate, String bookingStatus,
            String googleEventId, String googleEventLink,
            String calendarSyncStatus) {

        this.bookingId = bookingId;
        this.userId = userId;
        this.scheduleId = scheduleId;
        this.bookingDate = bookingDate;
        this.bookingStatus = bookingStatus;
        this.googleEventId = googleEventId;
        this.googleEventLink = googleEventLink;
        this.calendarSyncStatus = calendarSyncStatus;
    }

    public Booking(int userId, int scheduleId,
            Date bookingDate, String bookingStatus) {

        this.userId = userId;
        this.scheduleId = scheduleId;
        this.bookingDate = bookingDate;
        this.bookingStatus = bookingStatus;
        this.calendarSyncStatus = "NOT_SYNCED";
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getScheduleId() {
        return scheduleId;
    }

    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }

    public Date getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(Date bookingDate) {
        this.bookingDate = bookingDate;
    }

    public String getBookingStatus() {
        return bookingStatus;
    }

    public void setBookingStatus(String bookingStatus) {
        this.bookingStatus = bookingStatus;
    }

    public String getGoogleEventId() {
        return googleEventId;
    }

    public void setGoogleEventId(String googleEventId) {
        this.googleEventId = googleEventId;
    }

    public String getGoogleEventLink() {
        return googleEventLink;
    }

    public void setGoogleEventLink(String googleEventLink) {
        this.googleEventLink = googleEventLink;
    }

    public String getCalendarSyncStatus() {
        return calendarSyncStatus;
    }

    public void setCalendarSyncStatus(String calendarSyncStatus) {
        this.calendarSyncStatus = calendarSyncStatus;
    }

    public String getCancelledBy() {
        return cancelledBy;
    }

    public void setCancelledBy(String cancelledBy) {
        this.cancelledBy = cancelledBy;
    }
}
