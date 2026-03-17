package com.lbms.controller;

import com.lbms.dao.RoleDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.Role;
import com.lbms.model.User;
import com.lbms.service.EmailService;

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
import java.security.SecureRandom;

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
    private EmailService emailService;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
        roleDAO = new RoleDAO();
        emailService = new EmailService();
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
        String roleIdStr = request.getParameter("roleId");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        String randomPassword = generateRandomPassword();

        List<String> errors = validateUserInput(name, email, randomPassword, phone, address, randomPassword, roleIdStr,
                true, 0);

        if (errors.isEmpty()) {
            User user = new User();
            user.setFullName(name.trim());
            user.setEmail(email.trim());
            user.setPasswordHash(hashPassword(randomPassword));
            user.setPhone(phone.trim());
            user.setAddress(address.trim());

            Role role = new Role();
            role.setId(Integer.parseInt(roleIdStr));
            user.setRole(role);

            if (userDAO.createUserAccount(user)) {
                final String finalEmail = email.trim();
                final String finalPassword = randomPassword;
                final String finalName = name.trim();

                new Thread(() -> {
                    try {
                        String subject = "Tài khoản hệ thống LBMS của bạn đã sẵn sàng";
                        StringBuilder htmlBody = new StringBuilder();
                        htmlBody.append("<html><body style='font-family: Arial, sans-serif;'>");
                        htmlBody.append("<h2 style='color: #2c3e50;'>Chào mừng ").append(finalName).append("!</h2>");
                        htmlBody.append("<p>Tài khoản của bạn đã được khởi tạo tự động trên hệ thống <b>LBMS</b>.</p>");
                        htmlBody.append("<div style='background: #f8f9fa; padding: 15px; border-radius: 5px;'>");
                        htmlBody.append("<p><b>Thông tin đăng nhập của bạn:</b></p>");
                        htmlBody.append("<p>Email: <span style='color: #e74c3c;'>").append(finalEmail)
                                .append("</span></p>");
                        htmlBody.append("<p>Mật khẩu hệ thống cấp: <span style='color: #e74c3c; font-weight: bold;'>")
                                .append(finalPassword).append("</span></p>");
                        htmlBody.append("</div>");
                        htmlBody.append("<p><i>Vui lòng đăng nhập và đổi mật khẩu ngay để bảo mật tài khoản.</i></p>");
                        htmlBody.append("</body></html>");

                        emailService.send(finalEmail, subject, htmlBody.toString());
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }).start();

                request.getSession().setAttribute("flash",
                        "Thêm thành công! Mật khẩu đã được gửi tới email người dùng.");
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
            request.getSession().setAttribute("flash", "Lỗi: Không tìm thấy người dùng!");
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        String name = request.getParameter("name");
        String newEmail = request.getParameter("email").trim();
        String roleIdStr = request.getParameter("roleId");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        boolean isResetRequested = "true".equals(request.getParameter("resetPassword"));
        String oldEmail = existingUser.getEmail();
        String generatedPwd = null;
        List<String> errors = validateUserInput(name, newEmail, isResetRequested ? "PROTECTED" : null,
                phone, address, isResetRequested ? "PROTECTED" : null,
                roleIdStr, false, userId);

        if (errors.isEmpty()) {
            User user = new User();
            user.setId(userId);
            user.setFullName(name.trim());
            user.setEmail(newEmail);
            user.setPhone(phone.trim());
            user.setAddress(address.trim());

            if (isResetRequested) {
                generatedPwd = generateRandomPassword();
                user.setPasswordHash(hashPassword(generatedPwd));
            } else {
                user.setPasswordHash(existingUser.getPasswordHash());
            }

            Role role = new Role();
            role.setId(Integer.parseInt(roleIdStr));
            user.setRole(role);

            if (userDAO.updateUser(user)) {
                final String finalPwd = generatedPwd;
                final String finalName = name.trim();
                final boolean wasReset = isResetRequested;

                new Thread(() -> {
                    try {
                        sendUpdateEmail(newEmail, oldEmail, finalName, finalPwd, wasReset);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }).start();

                request.getSession().setAttribute("flash",
                        wasReset ? "Cập nhật thành công! Mật khẩu mới đã được gửi tới " + newEmail
                                : "Cập nhật thành công!");

                response.sendRedirect(request.getContextPath() + "/admin/users");
                return;
            }
        }

        request.setAttribute("user", existingUser);
        request.setAttribute("roleList", roleDAO.getAllRoles());
        request.setAttribute("errors", errors);
        request.getRequestDispatcher("/WEB-INF/views/admin/editUser.jsp").forward(request, response);
    }

    private void sendUpdateEmail(String newEmail, String oldEmail, String name, String newPwd, boolean wasReset) {
        String subject = "Thông báo cập nhật tài khoản LBMS";
        StringBuilder html = new StringBuilder();
        html.append("<html><body style='font-family: sans-serif;'>");
        html.append("<h2>Xin chào ").append(name).append(",</h2>");
        html.append("<p>Thông tin tài khoản của bạn trên hệ thống đã được quản trị viên cập nhật.</p>");

        if (wasReset) {
            html.append(
                    "<div style='background: #fff3cd; padding: 15px; border-radius: 5px; border: 1px solid #ffeeba;'>");
            html.append(
                    "<p><b>Mật khẩu đăng nhập mới của bạn là:</b> <span style='color: #d63384; font-size: 1.2rem;'>")
                    .append(newPwd).append("</span></p>");
            html.append("<p><i>Vui lòng đăng nhập và thay đổi mật khẩu ngay để bảo mật.</i></p>");
            html.append("</div>");
        }

        html.append("<p>Email đăng nhập hiện tại: <b>").append(newEmail).append("</b></p>");
        html.append("</body></html>");

        emailService.send(newEmail, subject, html.toString());

        if (!newEmail.equalsIgnoreCase(oldEmail)) {
            emailService.send(oldEmail, "Cảnh báo bảo mật LBMS",
                    "Email tài khoản của bạn đã được thay đổi sang: " + newEmail);
        }
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        long id = Long.parseLong(request.getParameter("id"));
        String status = request.getParameter("status");
        String p = request.getParameter("page");
        String k = request.getParameter("keyword");
        if (p == null || p.isEmpty()) {
            p = "1";
        }
        if (k == null) {
            k = "";
        }

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

    private List<String> validateUserInput(String name, String email, String password, String phone, String address,
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

        if (phone == null || phone.trim().isEmpty()) {
            errors.add("Số điện thoại không được để trống.");
        } else {
            phone = phone.trim();
            if (!phone.matches("^0\\d{9,10}$")) {
                errors.add("Số điện thoại không hợp lệ (phải bắt đầu bằng số 0, từ 10-11 chữ số).");
            } else if (userDAO.isPhoneExists(phone, excludeUserId)) {
                errors.add("Số điện thoại này đã được sử dụng bởi một tài khoản khác.");
            }
        }

        if (address == null || address.trim().isEmpty()) {
            errors.add("Địa chỉ không được để trống.");
        } else if (address.trim().length() > 255) {
            errors.add("Địa chỉ không được vượt quá 255 ký tự.");
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

    private String generateRandomPassword() {

        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%";
        StringBuilder sb = new StringBuilder();

        SecureRandom random = new SecureRandom();

        for (int i = 0; i < 10; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        return sb.toString();
    }

    @Override
    public String getServletInfo() {
        return "Admin User Controller Servlet";
    }
}
