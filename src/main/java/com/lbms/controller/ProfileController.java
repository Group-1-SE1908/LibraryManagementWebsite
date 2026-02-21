package com.lbms.controller;

import com.lbms.model.User;
import com.lbms.service.ProfileService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;

@WebServlet(urlPatterns = {
    "/profile",
    "/change-password",
    "/upload-avatar"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 1024 * 1024 * 5,
        maxRequestSize = 1024 * 1024 * 10
)
public class ProfileController extends HttpServlet {

    private ProfileService profileService;

    @Override
    public void init() {
        profileService = new ProfileService();
    }

    // =========================
    // GET PROFILE
    // =========================
    @Override
    protected void doGet(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            User currentUser
                    = (User) req.getSession().getAttribute("currentUser");

            if (currentUser == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            // 🔥 LUÔN refresh từ DB
            User freshUser
                    = profileService.refreshUser(currentUser.getId());

            req.getSession().setAttribute("currentUser", freshUser);
            req.setAttribute("user", freshUser);

            // Flash message
            Object flash
                    = req.getSession().getAttribute("flash");
            Object flashType
                    = req.getSession().getAttribute("flashType");

            if (flash != null) {
                req.setAttribute("flash", flash);
                req.setAttribute("flashType", flashType);

                req.getSession().removeAttribute("flash");
                req.getSession().removeAttribute("flashType");
            }
            req.setAttribute("timestamp", System.currentTimeMillis());
            req.getRequestDispatcher("/WEB-INF/views/profile.jsp")
                    .forward(req, resp);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // =========================
    // POST
    // =========================
    @Override
    protected void doPost(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        try {
            String path = req.getServletPath();

            switch (path) {

                case "/profile":
                    handleUpdateProfile(req, resp);
                    break;

                case "/change-password":
                    handleChangePassword(req, resp);
                    break;

                case "/upload-avatar":
                    handleAvatarUpload(req, resp);
                    break;

                default:
                    resp.sendError(405);
            }

        } catch (IllegalArgumentException ex) {

            req.getSession().setAttribute("flash",
                    ex.getMessage());
            req.getSession().setAttribute("flashType",
                    "error");

            resp.sendRedirect(req.getContextPath() + "/profile");

        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    // =========================
    // UPDATE PROFILE
    // =========================
    private void handleUpdateProfile(HttpServletRequest req,
            HttpServletResponse resp)
            throws Exception {

        User currentUser
                = (User) req.getSession().getAttribute("currentUser");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");

        profileService.updateProfile(
                currentUser.getId(),
                fullName,
                phone,
                address
        );

        //  refresh session
        User updatedUser
                = profileService.refreshUser(currentUser.getId());
        req.getSession().setAttribute("currentUser", updatedUser);

        req.getSession().setAttribute("flash",
                "Cập nhật hồ sơ thành công.");
        req.getSession().setAttribute("flashType",
                "success");

        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    // =========================
    // CHANGE PASSWORD
    // =========================
    private void handleChangePassword(HttpServletRequest req,
            HttpServletResponse resp)
            throws Exception {

        User currentUser
                = (User) req.getSession().getAttribute("currentUser");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String oldPassword = req.getParameter("oldPassword");
        String newPassword = req.getParameter("newPassword");
        String confirm = req.getParameter("confirm");

        if (!newPassword.equals(confirm)) {
            throw new IllegalArgumentException(
                    "Xác nhận mật khẩu không khớp.");
        }

        profileService.changePassword(
                currentUser.getId(),
                oldPassword,
                newPassword
        );

        req.getSession().setAttribute("flash",
                "Đổi mật khẩu thành công.");
        req.getSession().setAttribute("flashType",
                "success");

        resp.sendRedirect(req.getContextPath() + "/profile");
    }

    // =========================
    // UPLOAD AVATAR
    // =========================
    private void handleAvatarUpload(HttpServletRequest req,
            HttpServletResponse resp)
            throws Exception {

        User currentUser
                = (User) req.getSession().getAttribute("currentUser");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Part filePart = req.getPart("avatar");

        if (filePart == null || filePart.getSize() == 0) {
            throw new IllegalArgumentException("Vui lòng chọn ảnh.");
        }

        String originalName = filePart.getSubmittedFileName();
        String fileName = System.currentTimeMillis() + "_" + originalName;

        String uploadPath
                = getServletContext().getRealPath("/uploads");

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }

        filePart.write(uploadPath + File.separator + fileName);

        // ✅ Update DB
        profileService.updateAvatar(currentUser.getId(), fileName);

        // 🔥🔥🔥 QUAN TRỌNG: update luôn object trong session
        currentUser.setAvatar(fileName);
        req.getSession().setAttribute("currentUser", currentUser);

        req.getSession().setAttribute("flash",
                "Cập nhật avatar thành công.");
        req.getSession().setAttribute("flashType",
                "success");

        resp.sendRedirect(req.getContextPath() + "/profile");
    }
}
