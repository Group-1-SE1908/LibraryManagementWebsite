package com.lbms.controller;

import com.lbms.dao.UserDAO;
import com.lbms.model.Cart;
import com.lbms.model.CartItem;
import com.lbms.model.User;
import com.lbms.service.BorrowService;
import com.lbms.service.CartService;
import com.lbms.service.EmailService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = { "/cart", "/cart/add", "/cart/update", "/cart/remove", "/cart/checkout" })
public class CartController extends HttpServlet {
    private CartService cartService;
    private BorrowService borrowService;
    private UserDAO userDAO;
    private EmailService emailService;
    private static final String METHOD_ONLINE = "ONLINE";
    private static final String METHOD_IN_PERSON = "IN_PERSON";
    private static final String ROLE_LIBRARIAN = "LIBRARIAN";
    private static final DateTimeFormatter DISPLAY_DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @Override
    public void init() {
        this.cartService = new CartService();
        this.borrowService = new BorrowService();
        this.userDAO = new UserDAO();
        this.emailService = new EmailService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!"/cart".equals(req.getServletPath())) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            Cart cart = cartService.getCart(currentUser.getId());
            req.setAttribute("cart", cart);
            req.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(req, resp);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/cart/add":
                    handleAdd(req, resp, currentUser);
                    break;
                case "/cart/update":
                    handleUpdate(req, resp, currentUser);
                    break;
                case "/cart/remove":
                    handleRemove(req, resp, currentUser);
                    break;
                case "/cart/checkout":
                    handleBorrowRequestFromCart(req, resp, currentUser);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            }
        } catch (IllegalArgumentException ex) {
            handlePostError(req, resp, path, ex.getMessage());
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp, User currentUser) throws Exception {
        long bookId = parseLongParam(req, "bookId");
        int quantity = parseIntParam(req, "quantity", 1);
        cartService.addBook(currentUser.getId(), bookId, quantity);
        redirectWithParam(req, resp, "/books", "cartSuccess", "Đã thêm sách vào giỏ hàng");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, User currentUser) throws Exception {
        long bookId = parseLongParam(req, "bookId");
        int quantity = parseIntParam(req, "quantity", null);
        cartService.updateQuantity(currentUser.getId(), bookId, quantity);
        String message = quantity <= 0 ? "Đã xóa sách khỏi giỏ hàng" : "Đã cập nhật số lượng trong giỏ hàng";
        redirectWithParam(req, resp, "/cart", "cartSuccess", message.toString());
    }

    private void handleRemove(HttpServletRequest req, HttpServletResponse resp, User currentUser) throws Exception {
        long bookId = parseLongParam(req, "bookId");
        cartService.removeBook(currentUser.getId(), bookId);
        redirectWithParam(req, resp, "/cart", "cartSuccess", "Đã xóa sách khỏi giỏ hàng");
    }

    private void handlePostError(HttpServletRequest req, HttpServletResponse resp, String path, String message)
            throws IOException {
        String target = "/books";
        if ("/cart/update".equals(path) || "/cart/remove".equals(path) || "/cart/checkout".equals(path)) {
            target = "/cart";
        }
        redirectWithParam(req, resp, target, "cartError", message);
    }

    private void handleBorrowRequestFromCart(HttpServletRequest req, HttpServletResponse resp, User currentUser)
            throws Exception {
        String method = parseBorrowMethod(req.getParameter("borrowMethod"));
        String contactName = requireTextParam(req, "contactName", "họ tên để thủ thư liên hệ");
        String contactPhone = requireTextParam(req, "contactPhone", "số điện thoại");
        String contactEmail = requireTextParam(req, "contactEmail", "email liên hệ");
        int borrowDays = parseIntParam(req, "borrowDuration", 7);
        LocalDate returnDate = LocalDate.now().plusDays(borrowDays);
        String formattedReturnDate = returnDate.format(DISPLAY_DATE_FORMAT);
        LocalDate pickupDate = null;
        String formattedPickupDate = null;
        String deliveryAddress = null;
        if (METHOD_IN_PERSON.equals(method)) {
            pickupDate = parsePickupDateParam(req, "pickupDate");
            formattedPickupDate = pickupDate.format(DISPLAY_DATE_FORMAT);
        } else if (METHOD_ONLINE.equals(method)) {
            deliveryAddress = requireTextParam(req, "deliveryAddress", "địa chỉ nhận sách");
        }
        Cart cart = cartService.getCart(currentUser.getId());
        if (cart == null || cart.getItems().isEmpty()) {
            redirectWithParam(req, resp, "/cart", "cartError", "Giỏ hàng trống");
            return;
        }

        List<CartItem> items = new ArrayList<>(cart.getItems());
        for (CartItem item : items) {
            borrowService.requestBorrow(currentUser.getId(), item.getBookId(), method);
        }

        cartService.clearCart(currentUser.getId());
        notifyLibrarians(currentUser, items, method, contactName, contactPhone, contactEmail, formattedReturnDate,
                formattedPickupDate, deliveryAddress);
        StringBuilder message = new StringBuilder();
        message.append("Gửi yêu cầu mượn ").append(toMethodLabel(method)).append(" thành công. ");
        message.append("Ngày trả dự kiến ").append(formattedReturnDate).append(". ");
        if (formattedPickupDate != null) {
            message.append("Ngày đến lấy: ").append(formattedPickupDate).append(". ");
        }
        if (deliveryAddress != null && !deliveryAddress.isBlank()) {
            message.append("Địa chỉ giao sách: ").append(deliveryAddress).append(". ");
        }
        message.append("Thủ thư sẽ phản hồi sớm.");
        redirectWithParam(req, resp, "/cart", "cartSuccess", message.toString());
    }

    private String parseBorrowMethod(String raw) {
        if (raw != null && raw.equalsIgnoreCase(METHOD_IN_PERSON)) {
            return METHOD_IN_PERSON;
        }
        return METHOD_ONLINE;
    }

    private String toMethodLabel(String method) {
        if (METHOD_IN_PERSON.equals(method)) {
            return "tại chỗ";
        }
        return "online";
    }

    private void notifyLibrarians(User currentUser, List<CartItem> items, String method,
            String contactName, String contactPhone, String contactEmail, String returnDateLabel,
            String pickupDateLabel, String deliveryAddress) {
        if (items == null || items.isEmpty()) {
            return;
        }
        try {
            List<User> librarians = userDAO.findByRoleName(ROLE_LIBRARIAN);
            if (librarians.isEmpty()) {
                return;
            }
            String emails = librarians.stream()
                    .map(User::getEmail)
                    .filter(Objects::nonNull)
                    .map(String::trim)
                    .filter(email -> !email.isBlank())
                    .distinct()
                    .collect(Collectors.joining(","));
            if (emails.isBlank()) {
                return;
            }
            String displayName = getDisplayName(currentUser);
            String userEmail = currentUser != null && currentUser.getEmail() != null ? currentUser.getEmail()
                    : "chưa cung cấp email";
            String subject = "LBMS - Yêu cầu mượn sách mới từ " + displayName;
            StringBuilder body = new StringBuilder();
            body.append("<h3>Yêu cầu mượn sách mới</h3>");
            body.append("<p>Người dùng ").append(displayName)
                    .append(" (").append(userEmail).append(") vừa gửi yêu cầu mượn sách.</p>");
            body.append("<p>Phương thức: <strong>").append(toMethodLabel(method)).append("</strong></p>");
            body.append("<h4>Thông tin liên hệ</h4>");
            body.append("<ul style=\"padding-left:16px; line-height:1.6;\">");
            body.append("<li><strong>Tên:</strong> ").append(contactName).append("</li>");
            body.append("<li><strong>Điện thoại:</strong> ").append(contactPhone).append("</li>");
            body.append("<li><strong>Email:</strong> ").append(contactEmail).append("</li>");
            body.append("<li><strong>Ngày trả dự kiến:</strong> ").append(returnDateLabel).append("</li>");
            if (pickupDateLabel != null && !pickupDateLabel.isBlank()) {
                body.append("<li><strong>Ngày đến lấy:</strong> ").append(pickupDateLabel).append("</li>");
            }
            if (deliveryAddress != null && !deliveryAddress.isBlank()) {
                body.append("<li><strong>Địa chỉ giao sách:</strong> ").append(deliveryAddress).append("</li>");
            }
            body.append("</ul>");
            body.append("<ul>");
            for (CartItem item : items) {
                body.append("<li>").append(getItemLabel(item)).append("</li>");
            }
            body.append("</ul>");
            body.append("<p>Hệ thống đang chờ thủ thư xử lý yêu cầu.</p>");
            emailService.send(emails, subject, body.toString());
        } catch (Exception ex) {
            System.err.println("Không gửi được thông báo tới thủ thư: " + ex.getMessage());
        }
    }

    private String requireTextParam(HttpServletRequest req, String name, String label) {
        String value = req.getParameter(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Vui lòng cung cấp " + label);
        }
        return value.trim();
    }

    private LocalDate parsePickupDateParam(HttpServletRequest req, String name) {
        String raw = requireTextParam(req, name, "ngày đến lấy sách");
        try {
            LocalDate date = LocalDate.parse(raw);
            if (date.isBefore(LocalDate.now())) {
                throw new IllegalArgumentException("Ngày đến lấy sách phải là hôm nay hoặc sau đó");
            }
            return date;
        } catch (DateTimeParseException ex) {
            throw new IllegalArgumentException("Ngày đến lấy sách không hợp lệ");
        }
    }

    private String getItemLabel(CartItem item) {
        if (item == null) {
            return "Sách chưa xác định";
        }
        String title = item.getBook() != null && item.getBook().getTitle() != null
                ? item.getBook().getTitle()
                : "Sách #" + item.getBookId();
        return title + " (" + item.getQuantity() + " cuốn)";
    }

    private String getDisplayName(User user) {
        if (user == null) {
            return "Người dùng";
        }
        if (user.getFullName() != null && !user.getFullName().isBlank()) {
            return user.getFullName();
        }
        if (user.getEmail() != null && !user.getEmail().isBlank()) {
            return user.getEmail();
        }
        return "Người dùng";
    }

    private long parseLongParam(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Thiếu tham số " + name);
        }
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Giá trị " + name + " không hợp lệ");
        }
    }

    private int parseIntParam(HttpServletRequest req, String name, Integer defaultValue) {
        String value = req.getParameter(name);
        if (value == null || value.isBlank()) {
            if (defaultValue == null) {
                throw new IllegalArgumentException("Thiếu tham số " + name);
            }
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Giá trị " + name + " không hợp lệ");
        }
    }

    private void redirectWithParam(HttpServletRequest req, HttpServletResponse resp, String path, String paramName,
            String message) throws IOException {
        StringBuilder target = new StringBuilder(req.getContextPath()).append(path);
        if (message != null && !message.isBlank()) {
            target.append("?").append(paramName).append("=")
                    .append(URLEncoder.encode(message, StandardCharsets.UTF_8));
        }
        resp.sendRedirect(target.toString());
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("currentUser");
    }
}
