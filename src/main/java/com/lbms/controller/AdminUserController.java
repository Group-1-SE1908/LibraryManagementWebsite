package com.lbms.controller;

import com.lbms.model.Role;
import com.lbms.model.User;
import com.lbms.service.UserManagementService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = { "/admin/users", "/admin/users/role", "/admin/users/status" })
public class AdminUserController extends HttpServlet {
    private UserManagementService userManagementService;

    @Override
    public void init() {
        this.userManagementService = new UserManagementService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if (!"/admin/users".equals(path)) {
            resp.sendError(404);
            return;
        }

        try {
            List<User> users = userManagementService.listAllUsers();
            List<Role> roles = userManagementService.listAllRoles();
            req.setAttribute("users", users);
            req.setAttribute("roles", roles);

            Object flash = req.getSession().getAttribute("flash");
            if (flash != null) {
                req.setAttribute("flash", flash);
                req.getSession().removeAttribute("flash");
            }

            req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        req.setCharacterEncoding("UTF-8");

        try {
            switch (path) {
                case "/admin/users/role":
                    long roleUserId = Long.parseLong(req.getParameter("userId"));
                    String roleName = req.getParameter("role");
                    userManagementService.setUserRole(roleUserId, roleName);
                    req.getSession().setAttribute("flash", "Cập nhật role thành công");
                    resp.sendRedirect(req.getContextPath() + "/admin/users");
                    break;
                case "/admin/users/status":
                    long statusUserId = Long.parseLong(req.getParameter("userId"));
                    String status = req.getParameter("status");
                    userManagementService.setUserStatus(statusUserId, status);
                    req.getSession().setAttribute("flash", "Cập nhật trạng thái thành công");
                    resp.sendRedirect(req.getContextPath() + "/admin/users");
                    break;
                default:
                    resp.sendError(405);
                    break;
            }
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/admin/users");
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }
}
