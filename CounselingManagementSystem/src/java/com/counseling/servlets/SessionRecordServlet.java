/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.counseling.servlets;

import com.counseling.dao.SessionRecordDAO;
import com.counseling.model.SessionRecord;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.RequestDispatcher;



@WebServlet("/SessionRecordServlet")
public class SessionRecordServlet extends HttpServlet {


    private SessionRecordDAO dao;


    @Override
    public void init() {

        dao = new SessionRecordDAO();

    }



    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)

            throws ServletException, IOException {


        String action =
                request.getParameter("action");


        if(action == null){

            action = "list";

        }



        try {


            switch(action){


                // SHOW ADD PAGE
                case "new":


                    RequestDispatcher add =
                            request.getRequestDispatcher(
                                    "addSessionRecord.jsp");


                    add.forward(
                            request,
                            response);

                    break;




                // DELETE RECORD
                case "delete":


                    int deleteId =
                            Integer.parseInt(
                            request.getParameter("id"));


                    dao.deleteRecord(deleteId);


                    response.sendRedirect(
                            "SessionRecordServlet");


                    break;




                // EDIT PAGE
                case "edit":


                    int editId =
                            Integer.parseInt(
                            request.getParameter("id"));



                    SessionRecord record =
                            dao.selectRecord(editId);



                    request.setAttribute(
                            "record",
                            record);



                    RequestDispatcher edit =
                            request.getRequestDispatcher(
                            "editSessionRecord.jsp");



                    edit.forward(
                            request,
                            response);


                    break;




                // DISPLAY ALL RECORDS
                default:


                    List<SessionRecord> list =
                            dao.selectAllRecords();



                    request.setAttribute(
                            "records",
                            list);



                    RequestDispatcher view =
                            request.getRequestDispatcher(
                            "viewSessionHistory.jsp");



                    view.forward(
                            request,
                            response);


                    break;

            }



        } catch(SQLException e){


            throw new ServletException(e);

        }


    }






    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)

            throws ServletException, IOException {



        String action =
                request.getParameter("action");



        try {



            // ADD RECORD
            if(action.equals("insert")) {



                SessionRecord record =
                        new SessionRecord();



                record.setBookingId(
                        Integer.parseInt(
                        request.getParameter(
                        "booking_id")));



                record.setCounsellorId(
                        Integer.parseInt(
                        request.getParameter(
                        "counsellor_id")));



                record.setSessionDate(
                        request.getParameter(
                        "date"));



                record.setNotes(
                        request.getParameter(
                        "notes"));



                record.setFeedback(
                        request.getParameter(
                        "feedback"));



                dao.insertRecord(record);



                response.sendRedirect(
                        "SessionRecordServlet");

            }





            // UPDATE RECORD
            else if(action.equals("update")) {



                SessionRecord record =
                        new SessionRecord();



                record.setRecordId(
                        Integer.parseInt(
                        request.getParameter(
                        "id")));




                record.setNotes(
                        request.getParameter(
                        "notes"));



                record.setFeedback(
                        request.getParameter(
                        "feedback"));



                dao.updateRecord(record);



                response.sendRedirect(
                        "SessionRecordServlet");

            }



        } catch(SQLException e){


            throw new ServletException(e);

        }



    }


}