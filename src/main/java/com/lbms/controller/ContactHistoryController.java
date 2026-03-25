package com.lbms.controller;

import com.lbms.dao.ContactMessageDAO;
import com.lbms.model.ContactMessage;
import com.lbms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/contact-history")
public class ContactHistoryController extends HttpServlet {
    private ContactMessageDAO contactMessageDAO;

    @Override
    public void init() throws ServletException {
        contactMessageDAO = new ContactMessageDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String filter = request.getParameter("filter");
        if (filter == null || filter.isEmpty()) {
            filter = "all";
        }
        
        try {
            List<ContactMessage> messages = contactMessageDAO.findByEmailAndFilter(user.getEmail(), filter);
            request.setAttribute("messages", messages);
            request.setAttribute("currentFilter", filter);
            request.getRequestDispatcher("/WEB-INF/views/contact_history.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Đã xảy ra lỗi khi tải lịch sử liên hệ.");
            request.getRequestDispatcher("/WEB-INF/views/contact_history.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("cancel".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                ContactMessage msg = contactMessageDAO.findById(id);
                // Ensure the current user owns this message and it's PENDING
                if (msg != null && msg.getEmail().equals(user.getEmail()) && "PENDING".equals(msg.getStatus())) {
                    contactMessageDAO.updateStatus(id, "CANCELLED");
                    session.setAttribute("toastMessage", "Đã hủy yêu cầu liên hệ thành công.");
                } else {
                    session.setAttribute("error", "Không thể hủy yêu cầu này (có thể đã được xử lý hoặc bạn không có quyền).");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("error", "Đã xảy ra lỗi khi hủy yêu cầu.");
            }
        } else if ("edit".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                String feedbackType = request.getParameter("feedbackType");
                String message = request.getParameter("message");
                ContactMessage msg = contactMessageDAO.findById(id);
                if (msg != null && msg.getEmail().equals(user.getEmail()) && "PENDING".equals(msg.getStatus())) {
                    contactMessageDAO.updateMessage(id, feedbackType, message);
                    session.setAttribute("toastMessage", "Đã cập nhật yêu cầu liên hệ thành công.");
                } else {
                    session.setAttribute("error", "Không thể cập nhật yêu cầu này.");
                }
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("error", "Đã xảy ra lỗi khi cập nhật yêu cầu.");
            }
        }
        
        String filter = request.getParameter("filter");
        String redirectUrl = request.getContextPath() + "/contact-history";
        if (filter != null && !filter.isEmpty()) {
            redirectUrl += "?filter=" + filter;
        }
        response.sendRedirect(redirectUrl);
    }
}
