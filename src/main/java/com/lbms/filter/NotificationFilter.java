/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Filter.java to edit this template
 */
package com.lbms.filter;

import com.lbms.model.User;
import com.lbms.service.NotificationService;
import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.sql.SQLException;

/**
 *
 * @author ASUS
 */
@WebFilter(filterName = "NotificationFilter", urlPatterns = { "/*" })

public class NotificationFilter implements Filter {
    private final NotificationService notificationService = new NotificationService();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpSession session = req.getSession(false);

        if (session != null && session.getAttribute("currentUser") != null) {
            User user = (User) session.getAttribute("currentUser");
            try {

                int unreadCount = notificationService.getUnreadCount((int) user.getId());
                req.setAttribute("globalUnreadCount", unreadCount);
            } catch (SQLException e) {
                java.util.logging.Logger.getLogger(NotificationFilter.class.getName())
                        .log(java.util.logging.Level.SEVERE, "Lỗi Filter Notification", e);
            }
        }
        chain.doFilter(request, response);
    }
}