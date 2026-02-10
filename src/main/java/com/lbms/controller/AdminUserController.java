package com.lbms.controller;

import com.lbms.dao.RoleDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.Role;
import com.lbms.model.User;
import org.mindrot.jbcrypt.BCrypt;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
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

    private UserDAO userDAO;
    private RoleDAO roleDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
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
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống: " + ex.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/admin/userList.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        request.setCharacterEncoding("UTF-8");

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
            ex.printStackTrace();
            request.setAttribute("errorMessage", "Đã xảy ra lỗi hệ thống: " + ex.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/admin/userList.jsp").forward(request, response);
        }
    }

    private void handleViewUserList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String keyword = request.getParameter("keyword");
        if (keyword != null) {
            keyword = keyword.trim();
        } else {
            keyword = "";
        }

        int page = 1;
        int pageSize = 5;
        String pageStr = request.getParameter("page");

        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        List<User> userList = userDAO.getAllUsers(page, pageSize, keyword);
        int totalUsers = userDAO.getTotalUserCount(keyword);

        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);

        request.setAttribute("userList", userList);
        request.setAttribute("keyword", keyword);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("pageSize", pageSize);

        Object flash = request.getSession().getAttribute("flash");
        if (flash != null) {
            request.setAttribute("flash", flash);
            request.getSession().removeAttribute("flash");
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/userList.jsp").forward(request, response);
    }

    private void handleCreateUserForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        List<Role> roleList = roleDAO.getAllRoles();
        request.setAttribute("roleList", roleList);
        request.getRequestDispatcher("/WEB-INF/views/admin/createUser.jsp").forward(request, response);
    }

    private void handleCreateUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String roleIdStr = request.getParameter("roleId");

        List<String> errors = validateUserInput(name, email, password, confirmPassword, roleIdStr, true, 0);
        if (errors.isEmpty()) {
            User user = new User();
            user.setFullName(name.trim());
            user.setEmail(email.trim());
            user.setPasswordHash(hashPassword(password)); // Hash the password
            Role role = new Role();
            role.setId(Integer.parseInt(roleIdStr));
            user.setRole(role);

            if (userDAO.createUserAccount(user)) {
                request.getSession().setAttribute("flash", "Thêm người dùng mới thành công!");
                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }
        }
        request.setAttribute("errors", errors);
        request.setAttribute("roleList", roleDAO.getAllRoles());
        request.getRequestDispatcher("/WEB-INF/views/admin/createUser.jsp").forward(request, response);
    }

    private void handleEditUserForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        String userIdStr = request.getParameter("id");
        int userId = Integer.parseInt(userIdStr);
        User user = userDAO.findById(userId);

        if (user != null) {
            List<Role> roleList = roleDAO.getAllRoles();
            request.setAttribute("user", user);
            request.setAttribute("roleList", roleList);
            request.getRequestDispatcher("/WEB-INF/views/admin/editUser.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/user/list?error=User not found");
        }
    }

    private void handleEditUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        int userId = Integer.parseInt(request.getParameter("id"));
        User existingUser = userDAO.findById(userId);

        if (existingUser == null) {
            request.getSession().setAttribute("flash", "Lỗi : Không tìm thấy người dùng!");
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String roleIdStr = request.getParameter("roleId");
        String p = request.getParameter("page");
        String k = request.getParameter("keyword");

        List<String> errors = validateUserInput(name, email, password, confirmPassword, roleIdStr, false, userId);

        if (errors.isEmpty()) {
            User user = new User();
            user.setId(userId);
            user.setFullName(name.trim());
            user.setEmail(email.trim());

            boolean isPasswordEmpty = (password == null || password.trim().isEmpty());
            user.setPasswordHash(isPasswordEmpty ? existingUser.getPasswordHash() : hashPassword(password));

            Role role = new Role();
            role.setId(Integer.parseInt(roleIdStr));
            user.setRole(role);

            if (userDAO.updateUser(user)) {
                request.getSession().setAttribute("flash", "Cập nhật thông tin người dùng thành công!");

                String target = request.getContextPath() + "/admin/users?page=" + p + "&keyword=" + k;

                response.sendRedirect(target);
                return;
            }
        }

        request.setAttribute("user", existingUser);
        request.setAttribute("roleList", roleDAO.getAllRoles());
        request.setAttribute("errors", errors);
        request.getRequestDispatcher("/WEB-INF/views/admin/editUser.jsp").forward(request, response);
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        long id = Long.parseLong(request.getParameter("id"));
        String status = request.getParameter("status");
        String p = request.getParameter("page");
        String k = request.getParameter("keyword");
        if (p == null || p.isEmpty())
            p = "1";
        if (k == null)
            k = "";

        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser != null && id == currentUser.getId()) {
            request.getSession().setAttribute("flash", "Lỗi : Bạn không thể tự khóa tài khoản của chính mình!");
        } else {

            if (userDAO.updateStatus(id, status)) {
                request.getSession().setAttribute("flash", "Cập nhật trạng thái thành " + status + " thành công!");
            } else {
                request.getSession().setAttribute("flash", "Cập nhật trạng thái thất bại!");
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/users?page=" + p + "&keyword=" + k);
    }

    private void handleViewUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        int userId = Integer.parseInt(request.getParameter("id"));
        User user = userDAO.findById(userId);
        if (user != null) {
            request.setAttribute("user", user);
            request.getRequestDispatcher("/WEB-INF/views/admin/viewUser.jsp").forward(request, response);
        } else {
            request.getSession().setAttribute("flash", "Lỗi : Không tìm thấy người dùng!");
            response.sendRedirect(request.getContextPath() + "/admin/users");
        }
    }

    private List<String> validateUserInput(String name, String email, String password,
            String confirmPassword, String roleIdStr,
            boolean isCreate, int excludeUserId) throws SQLException {
        List<String> errors = new ArrayList<>();

        if (name == null || name.trim().isEmpty()) {
            errors.add("Họ tên không được để trống.");
        } else if (name.trim().length() > 100) {
            errors.add("Họ tên không được vượt quá 100 ký tự.");
        }

        if (email == null || email.trim().isEmpty()) {
            errors.add("Email không được để trống.");
        } else if (!isValidEmail(email.trim())) {
            errors.add("Định dạng email không hợp lệ.");
        } else if (userDAO.isEmailExists(email.trim(), excludeUserId)) {
            errors.add("Email này đã tồn tại trong hệ thống.");
        }

        if (isCreate || (password != null && !password.trim().isEmpty())) {
            if (password == null || password.trim().isEmpty()) {
                errors.add("Mật khẩu không được để trống.");
            } else if (password.length() < 6) {
                errors.add("Mật khẩu phải có ít nhất 6 ký tự.");
            } else if (!password.equals(confirmPassword)) {
                errors.add("Mật khẩu xác nhận không khớp.");
            }
        }

        if (roleIdStr == null || roleIdStr.trim().isEmpty()) {
            errors.add("Vui lòng chọn vai trò.");
        } else {
            try {
                int roleId = Integer.parseInt(roleIdStr);
                Role role = roleDAO.getRoleById(roleId);
                if (role == null) {
                    errors.add("Vai trò không hợp lệ.");
                }
            } catch (NumberFormatException e) {
                errors.add("Vai trò không hợp lệ.");
            }
        }

        return errors;
    }

    private boolean isValidEmail(String email) {
        String emailRegex = "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$";
        return email.matches(emailRegex);
    }

    private String hashPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt());
    }

    @Override
    public String getServletInfo() {
        return "Admin User Controller Servlet";
    }
}
