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
import java.util.List;

@WebServlet({"/admin/contacts", "/staff/contacts"})
public class AdminContactController extends HttpServlet {
    private final ContactMessageDAO contactDao = new ContactMessageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String filter = request.getParameter("filter");
            if (filter == null || filter.trim().isEmpty()) {
                filter = "all";
            }
            List<ContactMessage> contacts = contactDao.findByFilter(filter);
            request.setAttribute("contacts", contacts);
            request.setAttribute("currentFilter", filter);
            request.getRequestDispatcher("/WEB-INF/views/admin/library/admin_contact_list.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "Không thể tải danh sách liên hệ.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String idParam = request.getParameter("id");

        if (action != null && idParam != null) {
            try {
                int id = Integer.parseInt(idParam);
                String newStatus = "PENDING";
                
                if ("resolve".equals(action)) {
                    newStatus = "RESOLVED";
                } else if ("ignore".equals(action)) {
                    newStatus = "IGNORED";
                } else if ("close".equals(action)) {
                    newStatus = "CLOSED";
                }

                contactDao.updateStatus(id, newStatus);
                HttpSession session = request.getSession();
                session.setAttribute("toastMessage", "Cập nhật trạng thái thành công!");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        String uri = request.getRequestURI();
        if (uri.contains("/admin/")) {
            response.sendRedirect(request.getContextPath() + "/admin/contacts");
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/contacts");
        }
    }
}
