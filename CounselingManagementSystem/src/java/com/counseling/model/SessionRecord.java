/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.counseling.model;

/**
 *
 * @author DELL
 */
public class SessionRecord {

    private int recordId;
    private int bookingId;
    private int counsellorId;
    private String sessionDate;
    private String notes;
    private String feedback;


    public SessionRecord() {
    }


    public SessionRecord(int bookingId, int counsellorId,
                         String sessionDate,
                         String notes,
                         String feedback) {

        this.bookingId = bookingId;
        this.counsellorId = counsellorId;
        this.sessionDate = sessionDate;
        this.notes = notes;
        this.feedback = feedback;
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


    public String getSessionDate() {
        return sessionDate;
    }


    public void setSessionDate(String sessionDate) {
        this.sessionDate = sessionDate;
    }


    public String getNotes() {
        return notes;
    }


    public void setNotes(String notes) {
        this.notes = notes;
    }


    public String getFeedback() {
        return feedback;
    }


    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }
}
