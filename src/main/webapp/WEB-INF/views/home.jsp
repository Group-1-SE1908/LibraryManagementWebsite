<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>LBMS Portal - Library Management System</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                <style>
                    /* Hero Section */
                    .hero-section {
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        color: white;
                        padding: 100px 20px;
                        text-align: center;
                    }

                    .hero-content h1 {
                        font-size: 48px;
                        font-weight: 700;
                        margin-bottom: 20px;
                        line-height: 1.2;
                    }

                    .hero-content p {
                        font-size: 20px;
                        margin-bottom: 30px;
                        opacity: 0.95;
                    }

                    .hero-buttons {
                        display: flex;
                        gap: 15px;
                        justify-content: center;
                        flex-wrap: wrap;
                    }

                    .hero-buttons .btn {
                        padding: 14px 32px;
                        font-size: 16px;
                        font-weight: 600;
                    }

                    .btn.hero-primary {
                        background-color: white;
                        color: #667eea;
                    }

                    .btn.hero-primary:hover {
                        background-color: #f0f0f0;
                    }

                    .btn.hero-secondary {
                        background-color: rgba(255, 255, 255, 0.2);
                        color: white;
                        border: 2px solid white;
                    }

                    .btn.hero-secondary:hover {
                        background-color: rgba(255, 255, 255, 0.3);
                    }

                    /* Features Section */
                    .features-section {
                        background-color: #f9f9f9;
                        padding: 60px 20px;
                    }

                    .features-container {
                        max-width: 1200px;
                        margin: 0 auto;
                    }

                    .section-title {
                        text-align: center;
                        font-size: 36px;
                        font-weight: 700;
                        margin-bottom: 50px;
                        color: #333;
                    }

                    .features-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                        gap: 30px;
                        margin-bottom: 60px;
                    }

                    .feature-card {
                        background-color: white;
                        padding: 30px;
                        border-radius: 12px;
                        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
                        text-align: center;
                        transition: all 0.3s;
                    }

                    .feature-card:hover {
                        transform: translateY(-10px);
                        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
                    }

                    .feature-icon {
                        font-size: 48px;
                        margin-bottom: 15px;
                    }

                    .feature-card h3 {
                        font-size: 20px;
                        font-weight: 600;
                        margin-bottom: 10px;
                        color: #333;
                    }

                    .feature-card p {
                        color: #666;
                        line-height: 1.6;
                    }

                    /* Categories Section */
                    .categories-section {
                        background-color: white;
                        padding: 60px 20px;
                    }

                    .categories-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
                        gap: 20px;
                        max-width: 1200px;
                        margin: 0 auto;
                    }

                    .category-box {
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        color: white;
                        padding: 30px 20px;
                        border-radius: 12px;
                        text-align: center;
                        cursor: pointer;
                        transition: all 0.3s;
                        text-decoration: none;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        gap: 10px;
                    }

                    .category-box:nth-child(2n) {
                        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                    }

                    .category-box:nth-child(3n) {
                        background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
                    }

                    .category-box:nth-child(4n) {
                        background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
                    }

                    .category-box:hover {
                        transform: translateY(-5px);
                        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
                    }

                    .category-icon {
                        font-size: 32px;
                    }

                    .category-name {
                        font-weight: 600;
                    }

                    /* Featured Books Section */
                    .featured-books-section {
                        background-color: #f9f9f9;
                        padding: 60px 20px;
                    }

                    .featured-books-container {
                        max-width: 1200px;
                        margin: 0 auto;
                    }

                    .section-header-with-link {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        margin-bottom: 40px;
                    }

                    .section-header-with-link h2 {
                        font-size: 32px;
                        font-weight: 700;
                        color: #333;
                    }

                    .section-header-with-link a {
                        color: #667eea;
                        text-decoration: none;
                        font-weight: 600;
                        display: inline-flex;
                        align-items: center;
                        gap: 8px;
                        transition: gap 0.3s;
                    }

                    .section-header-with-link a:hover {
                        gap: 12px;
                    }

                    .featured-books-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
                        gap: 25px;
                    }

                    /* Stats Section */
                    .stats-section {
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        color: white;
                        padding: 60px 20px;
                    }

                    .stats-container {
                        max-width: 1200px;
                        margin: 0 auto;
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                        gap: 40px;
                        text-align: center;
                    }

                    .stat-item h3 {
                        font-size: 42px;
                        font-weight: 700;
                        margin-bottom: 10px;
                    }

                    .stat-item p {
                        font-size: 16px;
                        opacity: 0.9;
                    }

                    /* Testimonials Section */
                    .testimonials-section {
                        background-color: white;
                        padding: 60px 20px;
                    }

                    .testimonials-container {
                        max-width: 1200px;
                        margin: 0 auto;
                    }

                    .testimonials-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                        gap: 30px;
                    }

                    .testimonial-card {
                        background-color: #f9f9f9;
                        padding: 30px;
                        border-radius: 12px;
                        border-left: 4px solid #667eea;
                    }

                    .testimonial-stars {
                        color: #fbbf24;
                        font-size: 18px;
                        margin-bottom: 10px;
                    }

                    .testimonial-text {
                        color: #666;
                        font-size: 15px;
                        margin-bottom: 15px;
                        line-height: 1.6;
                    }

                    .testimonial-author {
                        font-weight: 600;
                        color: #333;
                    }

                    .testimonial-role {
                        font-size: 13px;
                        color: #999;
                    }

                    /* Call to Action */
                    .cta-section {
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        color: white;
                        padding: 60px 20px;
                        text-align: center;
                    }

                    .cta-content h2 {
                        font-size: 36px;
                        font-weight: 700;
                        margin-bottom: 15px;
                    }

                    .cta-content p {
                        font-size: 18px;
                        margin-bottom: 30px;
                        opacity: 0.95;
                    }

                    .cta-buttons {
                        display: flex;
                        gap: 15px;
                        justify-content: center;
                        flex-wrap: wrap;
                    }

                    .cta-btn {
                        padding: 14px 32px;
                        font-size: 16px;
                        font-weight: 600;
                        border: none;
                        border-radius: 6px;
                        cursor: pointer;
                        transition: all 0.3s;
                        text-decoration: none;
                    }

                    .cta-btn.primary {
                        background-color: white;
                        color: #667eea;
                    }

                    .cta-btn.primary:hover {
                        background-color: #f0f0f0;
                    }

                    .cta-btn.secondary {
                        background-color: rgba(255, 255, 255, 0.2);
                        color: white;
                        border: 2px solid white;
                    }

                    .cta-btn.secondary:hover {
                        background-color: rgba(255, 255, 255, 0.3);
                    }

                    @media (max-width: 768px) {
                        .hero-content h1 {
                            font-size: 32px;
                        }

                        .hero-content p {
                            font-size: 16px;
                        }

                        .section-title {
                            font-size: 28px;
                        }

                        .features-grid {
                            grid-template-columns: 1fr;
                        }

                        .section-header-with-link {
                            flex-direction: column;
                            align-items: flex-start;
                            gap: 15px;
                        }

                        .stat-item h3 {
                            font-size: 32px;
                        }
                    }
                </style>
            </head>

            <body>
                <c:choose>
                    <c:when test="${sessionScope.currentUser != null}">
                        <jsp:include page="header.jsp" />
                    </c:when>
                    <c:otherwise>
                        <!-- Navbar for non-logged in users -->
                        <header style="background-color: #fff; border-bottom: 1px solid #e0e0e0;">
                            <div class="container"
                                style="display: flex; align-items: center; justify-content: space-between; height: 70px;">
                                <a href="${pageContext.request.contextPath}/"
                                    style="font-size: 20px; font-weight: bold; color: #667eea; text-decoration: none;">📚
                                    LBMS.Portal</a>
                                <div style="display: flex; gap: 15px;">
                                    <a href="${pageContext.request.contextPath}/login"
                                        style="color: #666; text-decoration: none; font-weight: 500;">Đăng Nhập</a>
                                    <a href="${pageContext.request.contextPath}/register"
                                        style="background-color: #667eea; color: white; padding: 10px 20px; border-radius: 6px; text-decoration: none; font-weight: 600;">Đăng
                                        Ký</a>
                                </div>
                            </div>
                        </header>
                    </c:otherwise>
                </c:choose>

                <!-- Hero Section -->
                <div class="hero-section">
                    <div class="container">
                        <div class="hero-content">
                            <h1>Chào mừng đến thư viện kỹ thuật số</h1>
                            <p>Khám phá hàng ngàn quyển sách, tạp chí, và tài liệu học tập tuyệt vời</p>
                            <div class="hero-buttons">
                                <c:choose>
                                    <c:when test="${sessionScope.currentUser != null}">
                                        <a href="${pageContext.request.contextPath}/books" class="btn hero-primary">Khám
                                            Phá Sách 📖</a>
                                        <a href="${pageContext.request.contextPath}/borrow"
                                            class="btn hero-secondary">Sách Của Tôi 📚</a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/register"
                                            class="btn hero-primary">Bắt Đầu Miễn Phí</a>
                                        <a href="${pageContext.request.contextPath}/login"
                                            class="btn hero-secondary">Đăng Nhập</a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Features Section -->
                <div class="features-section">
                    <div class="features-container">
                        <h2 class="section-title">Tại Sao Chọn Chúng Tôi?</h2>
                        <div class="features-grid">
                            <div class="feature-card">
                                <div class="feature-icon">📚</div>
                                <h3>Thư Viện Phong Phú</h3>
                                <p>Truy cập 10,000+ quyển sách từ các lĩnh vực khác nhau, từ khoa học đến văn học.</p>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">🔍</div>
                                <h3>Tìm Kiếm Dễ Dàng</h3>
                                <p>Tìm sách theo tiêu đề, tác giả, hoặc danh mục với công cụ tìm kiếm mạnh mẽ.</p>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">⚡</div>
                                <h3>Truy Cập Nhanh</h3>
                                <p>Mượn và trả sách nhanh chóng, quản lý thư viện cá nhân của bạn dễ dàng.</p>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">🎯</div>
                                <h3>Khuyến Nghị Cá Nhân</h3>
                                <p>Nhận các gợi ý sách dựa trên sở thích và lịch sử đọc của bạn.</p>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">📱</div>
                                <h3>Truy Cập Mọi Nơi</h3>
                                <p>Sử dụng mọi thiết bị - máy tính, tablet, hoặc điện thoại di động.</p>
                            </div>
                            <div class="feature-card">
                                <div class="feature-icon">🔒</div>
                                <h3>An Toàn & Bảo Mật</h3>
                                <p>Dữ liệu của bạn được bảo vệ bằng công nghệ mã hóa hiện đại.</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Featured Categories Section -->
                <div class="categories-section">
                    <div class="features-container">
                        <h2 class="section-title">Khám Phá Danh Mục</h2>
                        <div class="categories-grid">
                            <c:forEach items="${categories}" var="cat">
                                <a href="${pageContext.request.contextPath}/books?category=${cat.id}"
                                    class="category-box">
                                    <div class="category-icon">📖</div>
                                    <div class="category-name">${cat.name}</div>
                                </a>
                            </c:forEach>
                        </div>
                    </div>
                </div>

                <!-- Featured Books Section -->
                <c:if test="${not empty featuredBooks}">
                    <div class="featured-books-section">
                        <div class="featured-books-container">
                            <div class="section-header-with-link">
                                <h2>Sách Nổi Bật Mới Nhất</h2>
                                <a href="${pageContext.request.contextPath}/books">Xem Tất Cả →</a>
                            </div>
                            <div class="featured-books-grid">
                                <c:forEach items="${featuredBooks}" var="book">
                                    <div class="book-card">
                                        <div class="book-cover">
                                            <c:if test="${book.availability}">
                                                <span class="book-badge available">Có Sẵn</span>
                                            </c:if>
                                            <c:if test="${!book.availability}">
                                                <span class="book-badge waitlist">Hết</span>
                                            </c:if>
                                            <span style="font-size: 60px; opacity: 0.3;">📖</span>
                                        </div>
                                        <div class="book-info">
                                            <div class="book-title">
                                                <a href="${pageContext.request.contextPath}/books/detail?id=${book.id}"
                                                    style="text-decoration: none; color: inherit;">
                                                    ${book.title}
                                                </a>
                                            </div>
                                            <div class="book-author">${book.author}</div>
                                            <div class="book-rating">
                                                <span class="stars">★★★★★</span>
                                                <span class="rating-count">(42)</span>
                                            </div>
                                            <div class="book-actions">
                                                <c:if test="${book.availability}">
                                                    <button class="btn primary" style="width: 100%; margin: 0;">Mượn
                                                        Ngay</button>
                                                </c:if>
                                                <c:if test="${!book.availability}">
                                                    <button class="btn secondary" style="width: 100%; margin: 0;">Đặt
                                                        Trước</button>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- Stats Section -->
                <div class="stats-section">
                    <div class="stats-container">
                        <div class="stat-item">
                            <h3>10,000+</h3>
                            <p>Quyển Sách</p>
                        </div>
                        <div class="stat-item">
                            <h3>50,000+</h3>
                            <p>Thành Viên hoạt động</p>
                        </div>
                        <div class="stat-item">
                            <h3>1M+</h3>
                            <p>Lượt Mượn Hàng Năm</p>
                        </div>
                        <div class="stat-item">
                            <h3>98%</h3>
                            <p>Mức Hài Lòng</p>
                        </div>
                    </div>
                </div>

                <!-- Testimonials Section -->
                <div class="testimonials-section">
                    <div class="testimonials-container">
                        <h2 class="section-title">Phản Hồi Từ Độc Giả</h2>
                        <div class="testimonials-grid">
                            <div class="testimonial-card">
                                <div class="testimonial-stars">★★★★★</div>
                                <div class="testimonial-text">"Thư viện kỹ thuật số này là tuyệt vời! Tôi có thể tìm
                                    thấy hầu hết những quyển sách mà tôi cần một cách rất dễ dàng."</div>
                                <div class="testimonial-author">Nguyễn Văn A</div>
                                <div class="testimonial-role">Sinh Viên Năm 2</div>
                            </div>
                            <div class="testimonial-card">
                                <div class="testimonial-stars">★★★★★</div>
                                <div class="testimonial-text">"Giao diện thân thiện và quá trình mượn sách chỉ mất vài
                                    giây. Tôi yêu thích ứng dụng này!"</div>
                                <div class="testimonial-author">Trần Thị B</div>
                                <div class="testimonial-role">Giảng Viên</div>
                            </div>
                            <div class="testimonial-card">
                                <div class="testimonial-stars">★★★★★</div>
                                <div class="testimonial-text">"Bộ sưu tập sách rất phong phú. Tôi luôn tìm thấy những
                                    tác phẩm mình muốn đọc ở đây."</div>
                                <div class="testimonial-author">Lê Minh C</div>
                                <div class="testimonial-role">Độc Giả Thường Xuyên</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- CTA Section -->
                <div class="cta-section">
                    <div class="container">
                        <div class="cta-content">
                            <h2>Bạn Đã Sẵn Sàng Khám Phá Thế Giới Sách Chưa?</h2>
                            <p>Tham gia hàng ngàn độc giả và bắt đầu hành trình đọc sách của bạn ngay hôm nay</p>
                            <div class="cta-buttons">
                                <c:choose>
                                    <c:when test="${sessionScope.currentUser != null}">
                                        <a href="${pageContext.request.contextPath}/books" class="cta-btn primary">Bắt
                                            Đầu Khám Phá</a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/register"
                                            class="cta-btn primary">Đăng Ký Miễn Phí</a>
                                        <a href="${pageContext.request.contextPath}/login" class="cta-btn secondary">Tôi
                                            Đã Có Tài Khoản</a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>

                <jsp:include page="footer.jsp" />
            </body>

            </html>