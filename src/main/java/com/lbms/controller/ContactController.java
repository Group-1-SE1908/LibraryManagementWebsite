package com.lbms.controller;

import com.lbms.dao.ContactMessageDAO;
import com.lbms.model.ContactMessage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/contact")
public class ContactController extends HttpServlet {
    private final ContactMessageDAO contactDao = new ContactMessageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/contact.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String feedbackType = request.getParameter("feedbackType"); // "Lời khen", "Lỗi", "Góp ý", "Khác"
        String message = request.getParameter("message");

        if (fullName == null || email == null || phone == null || feedbackType == null || message == null ||
            fullName.trim().isEmpty() || email.trim().isEmpty() || message.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ các trường bắt buộc!");
            request.getRequestDispatcher("/WEB-INF/views/contact.jsp").forward(request, response);
            return;
        }

        try {
            ContactMessage cm = new ContactMessage(fullName, email, phone, feedbackType, message);
            contactDao.create(cm);
            HttpSession session = request.getSession();
            session.setAttribute("toastMessage", "Gửi phản hồi thành công! Cảm ơn bạn đã đóng góp.");
            response.sendRedirect(request.getContextPath() + "/contact");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Đã có lỗi xảy ra. Vui lòng thử lại sau.");
            request.getRequestDispatcher("/WEB-INF/views/contact.jsp").forward(request, response);
        }
    }
}
