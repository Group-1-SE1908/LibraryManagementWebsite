package com.lbms.controller;

import com.lbms.model.User;
import com.lbms.service.ProfileService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(urlPatterns = {"/profile", "/change-password"})
public class ProfileController extends HttpServlet {
    private ProfileService profileService;

    @Override
    public void init() {
        this.profileService = new ProfileService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if (!"/profile".equals(path)) {
            resp.sendError(404);
            return;
        }

        try {
            User currentUser = (User) req.getSession().getAttribute("currentUser");
            User fresh = profileService.refreshUser(currentUser.getId());
            req.getSession().setAttribute("currentUser", fresh);
            req.setAttribute("user", fresh);

            Object flash = req.getSession().getAttribute("flash");
            if (flash != null) {
                req.setAttribute("flash", flash);
                req.getSession().removeAttribute("flash");
            }

            req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        req.setCharacterEncoding("UTF-8");

        try {
            if ("/profile".equals(path)) {
                handleUpdateProfile(req, resp);
            } else if ("/change-password".equals(path)) {
                handleChangePassword(req, resp);
            } else {
                resp.sendError(405);
            }
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/profile");
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleUpdateProfile(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        String fullName = req.getParameter("fullName");
        profileService.updateFullName(currentUser.getId(), fullName);
        req.getSession().setAttribute("flash", "Cập nhật hồ sơ thành công");
        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    private void handleChangePassword(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        String oldPassword = req.getParameter("oldPassword");
        String newPassword = req.getParameter("newPassword");
        String confirm = req.getParameter("confirm");

        if (newPassword == null || confirm == null || !newPassword.equals(confirm)) {
            throw new IllegalArgumentException("Xác nhận mật khẩu không khớp");
        }

        profileService.changePassword(currentUser.getId(), oldPassword, newPassword);
        req.getSession().setAttribute("flash", "Đổi mật khẩu thành công. Vui lòng đăng nhập lại.");
        // logout
        req.getSession().invalidate();
        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
