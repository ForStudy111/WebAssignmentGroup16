package com.counseling.model;

import java.util.*;

public class DataStore {

    public static Hashtable<String, String> userTable = new Hashtable<>();
    public static Hashtable<String, String> roleTable = new Hashtable<>();
    public static Hashtable<String, String> profileTable = new Hashtable<>();

    public static List<Booking> bookingList = new ArrayList<>();
    public static List<String> availabilityList = new ArrayList<>();
    public static Hashtable<String, String> patientRecords = new Hashtable<>();

    static {
        userTable.put("admin", "admin123");
        roleTable.put("admin", "ADMIN");
        profileTable.put("admin", "System Director");

        userTable.put("counselor1", "pass123");
        roleTable.put("counselor1", "COUNSELOR");
        profileTable.put("counselor1", "Dr. Sarah Smith");

        userTable.put("student1", "stud123");
        roleTable.put("student1", "STUDENT");
        profileTable.put("student1", "Alex Johnson");
    }

    public static class Booking {

        public String id, student, counselor, date, status;
        public String studentFeedback = "None";
        public String counselorFeedback = "None";

        public Booking(String student, String counselor, String date) {
            this.id = "BK" + (bookingList.size() + 101);
            this.student = student;
            this.counselor = counselor;
            this.date = date;
            this.status = "PENDING";
        }
    }
}
