<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <!-- Quick Actions (Mobile friendly) -->
        <div
            style="background-color: white; padding: 20px; border-top: 1px solid #e0e0e0; display: flex; gap: 10px; flex-wrap: wrap; justify-content: center;">
            <a href="${pageContext.request.contextPath}/cart" class="btn primary">🛒 My Cart</a>
            <a href="${pageContext.request.contextPath}/profile" class="btn">👤 My Profile</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn">🚪 Logout</a>
        </div>

        <!-- Footer -->
        <footer>
            <div class="container">
                <div class="footer-content">
                    <div class="footer-section">
                        <h3>LBMS</h3>
                        <p>Empowering students with knowledge. Our digital library portal provides easy access to vast
                            resources, managing your academic journey with efficiency and ease.</p>
                    </div>
                    <div class="footer-section">
                        <h3>Quick Links</h3>
                        <a href="${pageContext.request.contextPath}/books">Search Catalog</a><br>
                        <a href="${pageContext.request.contextPath}/borrow">My Account</a><br>
                        <a href="#">Library Rules</a><br>
                        <a href="#">Help Center</a>
                    </div>
                    <div class="footer-section">
                        <h3>Contact Us</h3>
                        <p>📧 support@library.edu</p>
                        <p>📞 +1 (555) 123-4567</p>
                        <p>📍 Main Campus, Building A</p>
                    </div>
                </div>
                <div class="footer-bottom">
                    <p>&copy; 2025 LBMS Library Portal. All rights reserved.</p>
                </div>
            </div>
        </footer>