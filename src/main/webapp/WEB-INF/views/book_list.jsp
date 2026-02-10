<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

      <!DOCTYPE html>
      <html lang="en">

      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Book Catalog - LBMS Library Portal</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
        <style>
          .page-header {
            background: linear-gradient(135deg, #0b57d0 0%, #3366cc 100%);
            color: white;
            padding: 40px 0;
            margin-bottom: 40px;
            text-align: center;
          }

          .page-header h1 {
            font-size: 36px;
            margin-bottom: 10px;
            font-weight: 700;
          }

          .page-header p {
            font-size: 18px;
            opacity: 0.95;
          }

          .filter-group {
            display: flex;
            gap: 12px;
            align-items: flex-end;
            flex-wrap: wrap;
          }

          .filter-group label {
            margin-bottom: 0;
          }

          .filter-group select {
            min-width: 150px;
          }

          .results-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
            padding: 16px;
            background-color: #f3f4f6;
            border-radius: 8px;
            flex-wrap: wrap;
            gap: 12px;
          }

          .results-count {
            font-size: 14px;
            color: #6b7280;
          }

          .sort-by {
            display: flex;
            gap: 8px;
            align-items: center;
          }

          .sort-by select {
            min-width: 200px;
            padding: 8px 12px;
            font-size: 14px;
          }
        </style>
      </head>

      <body>
        <jsp:include page="header.jsp" />

        <!-- Page Header -->
        <div class="page-header">
          <div class="container">
            <h1>📚 Book Catalog</h1>
            <p>Explore our extensive collection of books and resources</p>
          </div>
        </div>

        <!-- Main Content -->
        <div class="container">
          <!-- Search & Filter Section -->
          <div class="search-container">
            <form method="get" action="${pageContext.request.contextPath}/books" id="searchForm">
              <div class="search-box">
                <div style="flex: 1; min-width: 200px;">
                  <label for="searchInput">Search by book title or author</label>
                  <input type="text" id="searchInput" name="search" placeholder="Enter book title, author..."
                    value="${param.search}" />
                </div>

                <div class="filter-group">
                  <div>
                    <label for="categoryFilter">Category</label>
                    <select id="categoryFilter" name="category">
                      <option value="">All Categories</option>
                      <c:forEach var="cat" items="${categories}">
                        <option value="${cat.id}" ${param.category==cat.id ? 'selected' : '' }>${cat.name}</option>
                      </c:forEach>
                    </select>
                  </div>

                  <div>
                    <label for="statusFilter">Status</label>
                    <select id="statusFilter" name="status">
                      <option value="">All</option>
                      <option value="available" ${param.status=='available' ? 'selected' : '' }>Available</option>
                      <option value="borrowed" ${param.status=='borrowed' ? 'selected' : '' }>Borrowed</option>
                    </select>
                  </div>

                  <button type="submit" class="btn primary">🔍 Search</button>
                  <a href="${pageContext.request.contextPath}/books" class="btn" style="text-decoration: none;">↺
                    Reset</a>
                </div>
              </div>
            </form>
          </div>

          <!-- Results Info -->
          <div class="results-info">
            <div class="results-count">
              Found <strong>${totalBooks > 0 ? totalBooks : 0}</strong> book(s)
              <c:if test="${not empty param.search}">
                for "<strong>${param.search}</strong>"
              </c:if>
            </div>
            <div class="sort-by">
              <label for="sortBy">Sort by:</label>
              <select id="sortBy" name="sort" onchange="updateSort(this.value)">
                <option value="newest" ${param.sort=='newest' ? 'selected' : '' }>Newest</option>
                <option value="popular" ${param.sort=='popular' ? 'selected' : '' }>Most Popular</option>
                <option value="rating" ${param.sort=='rating' ? 'selected' : '' }>Top Rated</option>
                <option value="title_asc" ${param.sort=='title_asc' ? 'selected' : '' }>Title A-Z</option>
              </select>
            </div>
          </div>

          <!-- Books Grid -->
          <c:choose>
            <c:when test="${not empty books}">
              <div class="books-grid">
                <c:forEach var="book" items="${books}">
                  <div class="book-card">
                    <!-- Book Image -->
                    <div class="book-image">
                      📖
                      <c:if test="${book.quantity > 0}">
                        <span class="book-badge">Available</span>
                      </c:if>
                      <c:if test="${book.quantity <= 0}">
                        <span class="book-badge unavailable">Out of Stock</span>
                      </c:if>
                    </div>

                    <!-- Book Info -->
                    <div class="book-info">
                      <h3 class="book-title">${book.title}</h3>
                      <p class="book-author">by ${book.author}</p>

                      <div class="book-meta">
                        <div>
                          <c:if test="${not empty book.publishYear}">
                            <span>${book.publishYear}</span>
                          </c:if>
                        </div>
                        <div class="book-rating">
                          📖 ISBN: ${book.isbn}
                        </div>
                      </div>

                      <p style="font-size: 13px; color: #6b7280; margin-bottom: 12px; line-height: 1.4;">
                        <c:if test="${not empty book.publisher}">
                          <strong>Publisher:</strong> ${book.publisher}
                        </c:if>
                        <c:if test="${empty book.publisher}">
                          <em>No publisher information</em>
                        </c:if>
                      </p>

                      <!-- Stock Info -->
                      <p
                        style="font-size: 12px; margin-bottom: 12px; padding-bottom: 12px; border-bottom: 1px solid #e5e7eb;">
                        <c:choose>
                          <c:when test="${book.quantity > 0}">
                            <span style="color: #0d9488; font-weight: 600;">📚 ${book.quantity} copy(ies)
                              available</span>
                          </c:when>
                          <c:otherwise>
                            <span style="color: #dc2626; font-weight: 600;">❌ Out of Stock</span>
                          </c:otherwise>
                        </c:choose>
                      </p>

                      <!-- Actions -->
                      <div class="book-actions">
                        <a href="${pageContext.request.contextPath}/books/detail?id=${book.id}" class="btn small"
                          style="text-decoration: none; justify-content: center;">
                          👁️ View Details
                        </a>
                        <c:if test="${book.quantity > 0}">
                          <a href="${pageContext.request.contextPath}/cart/add/${book.id}" class="btn small primary"
                            style="text-decoration: none; justify-content: center;">
                            🛒 Borrow
                          </a>
                        </c:if>
                      </div>
                    </div>
                  </div>
                </c:forEach>
              </div>

              <!-- Pagination (if needed) -->
              <c:if test="${totalBooks > 12}">
                <div class="pagination">
                  <a href="#" class="btn small">← Previous</a>
                  <span class="current">1</span>
                  <a href="#" class="btn small">2</a>
                  <a href="#" class="btn small">3</a>
                  <a href="#" class="btn small">Next →</a>
                </div>
              </c:if>
            </c:when>

            <c:otherwise>
              <!-- Empty State -->
              <div class="empty-state">
                <div class="empty-state-icon">🔍</div>
                <h3>No books found</h3>
                <p>Try adjusting your search criteria</p>
                <a href="${pageContext.request.contextPath}/books" class="btn primary mt-20"
                  style="text-decoration: none;">← Back to List</a>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <jsp:include page="footer.jsp" />

        <script>
          function updateSort(sortValue) {
            const form = document.getElementById('searchForm');
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'sort';
            input.value = sortValue;
            form.appendChild(input);
            form.submit();
          }

          // Add smooth scroll behavior
          document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
              e.preventDefault();
              const target = document.querySelector(this.getAttribute('href'));
              if (target) {
                target.scrollIntoView({ behavior: 'smooth' });
              }
            });
          });
        </script>
      </body>

      </html>