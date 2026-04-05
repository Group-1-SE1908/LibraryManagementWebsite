package com.lbms.controller;

import com.lbms.dao.RoleDAO;
import com.lbms.model.User;
import com.lbms.service.UserService;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {
        "/admin/users",
        "/admin/users/create",
        "/admin/users/edit",
        "/admin/users/status",
        "/admin/users/view"
})
public class AdminUserController extends HttpServlet {

    private UserService userService;
    private RoleDAO roleDAO;

    @Override
    public void init() throws ServletException {
        userService = new UserService();
        roleDAO = new RoleDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        try {
            switch (path) {
                case "/admin/users":
                    handleViewUserList(request, response);
                    break;
                case "/admin/users/create":
                    handleCreateUserForm(request, response);
                    break;
                case "/admin/users/edit":
                    handleEditUserForm(request, response);
                    break;
                case "/admin/users/view":
                    handleViewUser(request, response);
                    break;
                default:
                    handleViewUserList(request, response);
                    break;
            }
        } catch (Exception ex) {
            handleSystemError(request, response, ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        try {
            switch (path) {
                case "/admin/users/create":
                    handleCreateUser(request, response);
                    break;
                case "/admin/users/edit":
                    handleEditUser(request, response);
                    break;
                case "/admin/users/status":
                    handleUpdateStatus(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/admin/users");
                    break;
            }
        } catch (Exception ex) {
            handleSystemError(request, response, ex);
        }
    }

    private void handleViewUserList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String keyword = request.getParameter("keyword");
        int page = 1;
        int pageSize = 5;

        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null && !pageStr.isEmpty()) {
                page = Integer.parseInt(pageStr);
            }
        } catch (NumberFormatException e) {
            page = 1;
        }

        request.setAttribute("userList", userService.listUsers(page, pageSize, keyword));
        int totalUsers = userService.getTotalCount(keyword);
        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);

        request.setAttribute("keyword", keyword);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalUsers", totalUsers);

        Object flash = request.getSession().getAttribute("flash");
        if (flash != null) {
            request.setAttribute("flash", flash);
            request.getSession().removeAttribute("flash");
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/userList.jsp").forward(request, response);
    }

    private void handleCreateUserForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        request.setAttribute("roleList", roleDAO.getAllRoles());
        request.getRequestDispatcher("/WEB-INF/views/admin/createUser.jsp").forward(request, response);
    }

    private void handleCreateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        User user = new User();
        user.setFullName(request.getParameter("name"));
        user.setEmail(request.getParameter("email"));
        user.setPhone(request.getParameter("phone"));
        user.setAddress(request.getParameter("address"));
        String roleIdStr = request.getParameter("roleId");

        List<String> errors = userService.createUser(user, roleIdStr);

        if (errors.isEmpty()) {
            request.getSession().setAttribute("flash", "Thêm thành công! Mật khẩu đã được gửi tới email người dùng.");
            response.sendRedirect(request.getContextPath() + "/admin/users");
        } else {
            request.setAttribute("errors", errors);
            request.setAttribute("roleList", roleDAO.getAllRoles());
            request.getRequestDispatcher("/WEB-INF/views/admin/createUser.jsp").forward(request, response);
        }
    }

    private void handleEditUserForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        int userId = Integer.parseInt(request.getParameter("id"));
        User user = userService.getUserById(userId);

        if (user != null) {
            request.setAttribute("user", user);
            request.setAttribute("roleList", roleDAO.getAllRoles());
            request.getRequestDispatcher("/WEB-INF/views/admin/editUser.jsp").forward(request, response);
        } else {
            request.getSession().setAttribute("flash", "Lỗi: Không tìm thấy người dùng!");
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    private void handleEditUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        int userId = Integer.parseInt(request.getParameter("id"));
        User user = new User();
        user.setId(userId);
        user.setFullName(request.getParameter("name"));
        user.setEmail(request.getParameter("email"));
        user.setPhone(request.getParameter("phone"));
        user.setAddress(request.getParameter("address"));

        String roleIdStr = request.getParameter("roleId");
        boolean isResetRequested = "true".equals(request.getParameter("resetPassword"));

        List<String> errors = userService.updateUser(user, roleIdStr, isResetRequested);

        if (errors.isEmpty()) {
            String successMsg = isResetRequested ? "Cập nhật thành công và đã cấp lại mật khẩu!"
                    : "Cập nhật thành công!";
            request.getSession().setAttribute("flash", successMsg);
            response.sendRedirect(request.getContextPath() + "/admin/users");
        } else {
            request.setAttribute("user", userService.getUserById(userId));
            request.setAttribute("roleList", roleDAO.getAllRoles());
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/WEB-INF/views/admin/editUser.jsp").forward(request, response);
        }
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        long id = Long.parseLong(request.getParameter("id"));
        String status = request.getParameter("status");
        User currentUser = (User) request.getSession().getAttribute("currentUser");

        String result = userService.updateStatus(id, status, currentUser);

        if ("SUCCESS".equals(result)) {
            request.getSession().setAttribute("flash", "Cập nhật trạng thái thành " + status + " thành công!");
        } else {
            request.getSession().setAttribute("flash", result);
        }

        String p = request.getParameter("page");
        String k = request.getParameter("keyword");
        response.sendRedirect(request.getContextPath() + "/admin/users?page=" + (p != null ? p : "1") + "&keyword="
                + (k != null ? k : ""));
    }

    private void handleViewUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        int userId = Integer.parseInt(request.getParameter("id"));
        User user = userService.getUserById(userId);
        if (user != null) {
            request.setAttribute("user", user);
            request.getRequestDispatcher("/WEB-INF/views/admin/viewUser.jsp").forward(request, response);
        } else {
            request.getSession().setAttribute("flash", "Lỗi: Không tìm thấy người dùng!");
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    private void handleSystemError(HttpServletRequest request, HttpServletResponse response, Exception ex)
            throws ServletException, IOException {
        ex.printStackTrace();
        request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống: " + ex.getMessage());
        request.getRequestDispatcher("/WEB-INF/views/admin/userList.jsp").forward(request, response);
    }
}