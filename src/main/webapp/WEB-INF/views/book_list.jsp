<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
      <!DOCTYPE html>
      <html lang="vi">

      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>LBMS Portal - Tìm kiếm sách</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
      </head>

      <body>
        <jsp:include page="header.jsp" />

        <!-- Search & Filter Section -->
        <div class="search-filter-section">
          <div class="search-container">
            <h3>Search Book</h3>
            <form method="get" action="${pageContext.request.contextPath}/books" class="search-filter-form">
              <div class="form-group">
                <input type="text" name="q" value="${q}" placeholder="Search by title, author, or ISBN..."
                  class="search-input" />
              </div>
              <div class="form-group">
                <label for="category">Filter by Category:</label>
                <select name="category" id="category" class="category-select">
                  <option value="0">All Categories</option>
                  <c:forEach items="${categories}" var="cat">
                    <option value="${cat.id}" <c:if test="${selectedCategory == cat.id}">selected</c:if>>${cat.name}
                    </option>
                  </c:forEach>
                </select>
              </div>
              <button type="submit" class="btn primary">Search</button>
              <a href="${pageContext.request.contextPath}/books" class="btn">Clear Filters</a>
            </form>
          </div>
        </div>

        <!-- Stats Section -->
        <c:set var="roleName" value="${sessionScope.currentUser.role.name}" />
        <c:if test="${sessionScope.currentUser != null}">
          <div class="stats-section">
            <div class="stats-container">
              <div class="stat-card">
                <div class="stat-icon">📖</div>
                <div class="stat-content">
                  <h3>Currently Borrowed</h3>
                  <p>3 Books</p>
                </div>
              </div>
              <div class="stat-card due-soon">
                <div class="stat-icon">⏰</div>
                <div class="stat-content">
                  <h3>Due Soon</h3>
                  <p>1 Item</p>
                </div>
              </div>
              <div class="stat-card reserved">
                <div class="stat-icon">⭐</div>
                <div class="stat-content">
                  <h3>Reserved</h3>
                  <p>2 Pending</p>
                </div>
              </div>
            </div>
          </div>
        </c:if>

        <!-- Main Content -->
        <div class="main-content">
          <!-- Admin Controls -->
          <c:if test="${roleName == 'ADMIN' || roleName == 'LIBRARIAN'}">
            <div class="admin-controls">
              <a class="btn primary" href="${pageContext.request.contextPath}/books/new">+ Add New Book</a>
              <a class="btn" href="${pageContext.request.contextPath}/admin/users">Manage Users</a>
              <a class="btn" href="${pageContext.request.contextPath}/shipping">Manage Shipping</a>
            </div>
          </c:if>

          <!-- Section Header -->
          <div class="section-header">
            <h2>Featured Books</h2>
            <div class="category-filter">
              <button class="active">All</button>
              <button>Computer Science</button>
              <button>Literature</button>
              <button>Business</button>
            </div>
          </div>

          <!-- Books Grid -->
          <c:choose>
            <c:when test="${empty books}">
              <div style="text-align: center; padding: 60px 20px; color: #999;">
                <p style="font-size: 18px; margin-bottom: 20px;">No books found</p>
                <a href="${pageContext.request.contextPath}/books" class="btn primary">Clear Search</a>
              </div>
            </c:when>
            <c:otherwise>
              <div class="books-grid">
                <c:forEach items="${books}" var="b">
                  <div class="book-card">
                    <div class="book-cover">
                      <c:if test="${b.quantity > 0}">
                        <span class="book-badge available">Available</span>
                      </c:if>
                      <c:if test="${b.quantity <= 0}">
                        <span class="book-badge waitlist">Waitlist</span>
                      </c:if>
                      <!-- Placeholder for book cover -->
                      <span style="font-size: 60px; opacity: 0.3;">📖</span>
                    </div>
                    <div class="book-info">
                      <div class="book-title">
                        <a href="${pageContext.request.contextPath}/books/detail?id=${b.id}"
                          style="text-decoration: none; color: inherit;">
                          ${b.title}
                        </a>
                      </div>
                      <div class="book-author">${b.author}</div>
                      <div class="book-rating">
                        <span class="stars">★★★★★</span>
                        <span class="rating-count">(42)</span>
                      </div>
                      <div class="book-actions">
                        <c:if test="${b.quantity > 0}">
                          <form method="post" action="${pageContext.request.contextPath}/cart/add"
                            style="flex: 2; display: flex; gap: 4px;">
                            <input type="hidden" name="bookId" value="${b.id}" />
                            <input type="hidden" name="quantity" value="1" />
                            <button type="submit" class="btn primary" style="flex: 1; margin: 0;">Borrow Now</button>
                          </form>
                        </c:if>
                        <c:if test="${b.quantity <= 0}">
                          <button class="btn secondary" onclick="alert('Currently unavailable')">Reserve</button>
                        </c:if>
                        <c:if test="${roleName == 'ADMIN' || roleName == 'LIBRARIAN'}">
                          <a href="${pageContext.request.contextPath}/books/edit?id=${b.id}" class="btn">Edit</a>
                          <a href="${pageContext.request.contextPath}/books/delete?id=${b.id}" class="btn danger"
                            onclick="return confirm('Delete this book?');">Delete</a>
                        </c:if>
                      </div>
                    </div>
                  </div>
                </c:forEach>
              </div>
            </c:otherwise>
          </c:choose>

          <!-- View All Link -->
          <div class="view-all">
            <a href="${pageContext.request.contextPath}/books">View all new arrivals →</a>
          </div>
        </div>

        <jsp:include page="footer.jsp" />
      </body>

      </html>