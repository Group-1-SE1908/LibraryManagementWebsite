<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

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
                    <p>&copy; 2026 LBMS Library Portal. All rights reserved.</p>
                </div>
            </div>
        </footer>

        <script>
            function toggleUserDropdown(event) {
                event.stopPropagation();
                const dropdown = document.getElementById('userDropdown');
                dropdown.classList.toggle('active');
            }

            // Close dropdown when clicking outside
            document.addEventListener('click', function (event) {
                const dropdown = document.getElementById('userDropdown');
                const userProfile = document.querySelector('.user-profile');
                if (!userProfile.contains(event.target)) {
                    dropdown.classList.remove('active');
                }
            });
        </script>