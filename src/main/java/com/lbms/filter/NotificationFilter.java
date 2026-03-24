package com.lbms.filter;

import com.lbms.model.User;
import com.lbms.service.NotificationService;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;

/**
 * Filter to provide unread notification count to all pages.
 */
@WebFilter("/*")
public class NotificationFilter implements Filter {
    private final NotificationService notificationService = new NotificationService();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        String path = req.getServletPath();

        // Skip static resources and internal forwards that don't need the header
        if (isStaticResource(path)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        if (session != null) {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser != null) {
                try {
                    // Fetch unread count and set it as a request attribute
                    int unreadCount = notificationService.countUnread(currentUser.getId());
                    req.setAttribute("unreadCount", unreadCount);
                } catch (SQLException e) {
                    req.getServletContext().log("Error fetching unread notification count for user " + currentUser.getId(), e);
                }
            }
        }
        
        chain.doFilter(request, response);
    }

    private boolean isStaticResource(String path) {
        return path.startsWith("/assets/") || 
               path.startsWith("/css/") || 
               path.startsWith("/js/") || 
               path.endsWith(".png") || 
               path.endsWith(".jpg") || 
               path.endsWith(".jpeg") || 
               path.endsWith(".gif") || 
               path.endsWith(".css") || 
               path.endsWith(".js") || 
               path.endsWith(".svg") || 
               path.endsWith(".ico");
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void destroy() {}
}
