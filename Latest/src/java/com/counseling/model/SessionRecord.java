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

public class SessionRecord implements Serializable {

    private int recordId;
    private int bookingId;
    private int counsellorId;
    private String sessionNotes;
    private String feedback;
    private Integer rating;
    private Date sessionDate;

    public SessionRecord() {
    }

    public SessionRecord(int recordId, int bookingId, int counsellorId,
            String sessionNotes, String feedback, Integer rating,
            Date sessionDate) {
        this.recordId = recordId;
        this.bookingId = bookingId;
        this.counsellorId = counsellorId;
        this.sessionNotes = sessionNotes;
        this.feedback = feedback;
        this.rating = rating;
        this.sessionDate = sessionDate;
    }

    public SessionRecord(int bookingId, int counsellorId,
            String sessionNotes, Date sessionDate) {
        this.bookingId = bookingId;
        this.counsellorId = counsellorId;
        this.sessionNotes = sessionNotes;
        this.sessionDate = sessionDate;
    }

    public int getRecordId() {
        return recordId;
    }

    public void setRecordId(int recordId) {
        this.recordId = recordId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getCounsellorId() {
        return counsellorId;
    }

    public void setCounsellorId(int counsellorId) {
        this.counsellorId = counsellorId;
    }

    public String getSessionNotes() {
        return sessionNotes;
    }

    public void setSessionNotes(String sessionNotes) {
        this.sessionNotes = sessionNotes;
    }

    public String getFeedback() {
        return feedback;
    }

    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(Integer rating) {
        this.rating = rating;
    }

    public Date getSessionDate() {
        return sessionDate;
    }

    public void setSessionDate(Date sessionDate) {
        this.sessionDate = sessionDate;
    }
}
