package com.lbms.controller;

import com.lbms.dao.LibrarianActivityLogDAO;
import com.lbms.dao.LibrarianBorrowDAO;
import com.lbms.dao.BookDAO;

import com.lbms.model.LibrarianActivityLog;
import com.lbms.model.BorrowRecord;
import com.lbms.model.Book;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "LibrarianActivityLogController", urlPatterns = { "/admin/librarianActivityLog" })
public class LibrarianActivityLogController extends HttpServlet {

    private LibrarianActivityLogDAO activityLogDAO;
    private LibrarianBorrowDAO borrowDAO;
    private BookDAO bookDAO;

    @Override
    public void init() {
        activityLogDAO = new LibrarianActivityLogDAO();
        borrowDAO = new LibrarianBorrowDAO();
        bookDAO = new BookDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String modal = request.getParameter("modal");
        String id = request.getParameter("id");
        String detailType = request.getParameter("detailType");

        // Load modal detail
        if ("true".equals(modal) && id != null) {

            try {

                if ("borrow".equalsIgnoreCase(detailType)) {

                    BorrowRecord record = borrowDAO.findById(Long.parseLong(id));
                    request.setAttribute("record", record);

                    RequestDispatcher rd = request.getRequestDispatcher(
                            "/WEB-INF/views/admin/modal/borrow-detail-modal.jsp");

                    rd.forward(request, response);
                    return;
                }

                if ("book".equalsIgnoreCase(detailType)) {

                    Book book = bookDAO.findById(Long.parseLong(id));
                    request.setAttribute("book", book);

                    RequestDispatcher rd = request.getRequestDispatcher(
                            "/WEB-INF/views/admin/modal/book-detail-modal.jsp");

                    rd.forward(request, response);
                    return;
                }

            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // Load activity log page

        String filterType = request.getParameter("filterType");

        List<LibrarianActivityLog> logs;

        if (filterType != null && !filterType.isEmpty()) {
            logs = activityLogDAO.getActivityLogsFiltered(filterType);
        } else {
            logs = activityLogDAO.getAllActivityLogs();
        }

        request.setAttribute("activityLogs", logs);
        request.setAttribute("filterType", filterType);

        RequestDispatcher dispatcher = request.getRequestDispatcher(
                "/WEB-INF/views/admin/librarianActivityLog.jsp");

        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {

            int userId = Integer.parseInt(request.getParameter("user_id"));
            String action = request.getParameter("action");

            activityLogDAO.addActivityLog(userId, action);

            response.sendRedirect("librarianActivityLog");

        } catch (Exception e) {

            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid data");

        }
    }

}
