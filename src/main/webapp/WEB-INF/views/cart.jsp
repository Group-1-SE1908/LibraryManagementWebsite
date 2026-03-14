<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Giỏ hàng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp" />

<c:set var="itemCount" value="${empty cart || empty cart.items ? 0 : fn:length(cart.items)}" />
<c:set var="totalQuantity" value="0" />
<c:if test="${not empty cart && not empty cart.items}">
    <c:forEach var="cartItem" items="${cart.items}">
        <c:set var="totalQuantity" value="${totalQuantity + cartItem.quantity}" />
    </c:forEach>
</c:if>

    <c:set var="currentUser" value="${sessionScope.currentUser}" />
    <c:set var="userFullName" value="${currentUser.fullName}" />
    <c:set var="userPhone" value="${currentUser.phone}" />
    <c:set var="userEmail" value="${currentUser.email}" />
    <c:set var="userAddress" value="${currentUser.address}" />
    <c:set var="borrowDetailsVisible" value="${not empty param.cartError}" />
    <c:url value="/checkout" var="checkoutUrlValue" />

<main class="cart-page">
    <c:if test="${itemCount > 0}">
        <section class="cart-hero">
        <div class="hero-content">
            <p class="eyebrow">Giỏ hàng</p>
            <h1>Những cuốn sách bạn đang giữ</h1>
            <p class="hero-subtitle">Gửi yêu cầu mượn ngay khi bạn sẵn sàng. Chúng tôi sẽ giữ kho sách và hỗ trợ gia hạn nếu cần.</p>
            <div class="hero-actions">
                <a href="${pageContext.request.contextPath}/books" class="btn secondary">Tiếp tục khám phá</a>
            </div>
        </div>
        <div class="hero-summary">
            <div class="hero-card">
                <p class="label">Loại sách trong giỏ</p>
                <p class="value">${itemCount}</p>
                <small>nhóm sách đang chờ duyệt</small>
            </div>
            <div class="hero-card">
                <p class="label">Tổng số lượng</p>
                <p class="value">${totalQuantity}</p>
                <small>cuốn bạn vừa thêm</small>
            </div>
        </div>
        </section>
    </c:if>

    <c:if test="${not empty param.cartSuccess}">
        <div class="alert success">${param.cartSuccess}</div>
    </c:if>
    <c:if test="${not empty param.cartError}">
        <div class="alert error">${param.cartError}</div>
    </c:if>

    <c:if test="${itemCount == 0}">
        <section class="cart-empty">
            <div class="empty-card">
                <h2>Giỏ hàng trống</h2>
                <p>Bạn chưa thêm cuốn sách nào vào giỏ. Hãy khám phá thư viện và chọn vài cuốn bạn muốn mượn.</p>
                <a href="${pageContext.request.contextPath}/books" class="btn primary">Bắt đầu chọn sách</a>
            </div>
        </section>
    </c:if>

    <c:if test="${itemCount > 0}">
        <section class="cart-grid-section">
            <div class="cart-items-grid">
                <c:forEach items="${cart.items}" var="item">
                    <article class="cart-item-card">
                        <div class="cart-item-cover">
                            <c:choose>
                                <c:when test="${not empty item.book.image}">
                                    <img src="${pageContext.request.contextPath}/${item.book.image}" alt="${item.book.title}" loading="lazy" />
                                </c:when>
                                <c:otherwise>
                                    <span class="cover-placeholder">${fn:substring(item.book.title, 0, 1)}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="cart-item-body">
                            <div class="cart-item-head">
                                <h3>${item.book.title}</h3>
                                <p class="cart-item-author">Tác giả ${item.book.author}</p>
                            </div>
                            <div class="cart-item-meta">
                                <span class="availability ${item.book.availability ? 'in-stock' : 'out-of-stock'}">
                                    ${item.book.availability ? 'Còn hàng' : 'Hết hàng'}
                                </span>
                            </div>
                            <div class="cart-item-actions">
                                <form action="${pageContext.request.contextPath}/cart/update" method="post" class="quantity-form">
                                    <input type="hidden" name="bookId" value="${item.bookId}" />
                                    <input type="number" name="quantity" min="1" value="${item.quantity}" class="quantity-input" />
                                    <button type="submit" class="btn secondary">Cập nhật</button>
                                </form>
                                <form action="${pageContext.request.contextPath}/cart/remove" method="post" class="remove-form">
                                    <input type="hidden" name="bookId" value="${item.bookId}" />
                                    <button type="submit" class="btn danger">Xóa</button>
                                </form>
                            </div>
                        </div>
                    </article>
                </c:forEach>
            </div>
            <aside class="cart-summary-panel">
                <h3>Đơn hàng</h3>
                <div class="summary-row">
                    <span>Số loại sách</span>
                    <strong>${itemCount}</strong>
                </div>
                <div class="summary-row">
                    <span>Tổng số lượng</span>
                    <strong>${totalQuantity}</strong>
                </div>
                <form class="borrow-form" method="post" action="${pageContext.request.contextPath}/cart/checkout">
                    <input type="hidden" name="contactName" value="${userFullName}" />
                    <input type="hidden" name="contactPhone" value="${userPhone}" />
                    <input type="hidden" name="shippingRecipient" data-shipping-hidden="recipient" />
                    <input type="hidden" name="shippingPhone" data-shipping-hidden="phone" />
                    <input type="hidden" name="shippingStreet" data-shipping-hidden="street" />
                    <input type="hidden" name="shippingResidence" data-shipping-hidden="residence" />
                    <input type="hidden" name="shippingCity" data-shipping-hidden="city" />
                    <input type="hidden" name="shippingDistrict" data-shipping-hidden="district" />
                    <input type="hidden" name="shippingWard" data-shipping-hidden="ward" />
                    <div class="borrow-form-heading">
                        <p class="label">Chọn phương thức mượn</p>
                        <small>Mượn nhanh theo nhu cầu của bạn</small>
                    </div>
                    <div class="borrow-methods">
                        <label class="borrow-chip">
                            <input type="radio" name="borrowMethod" value="ONLINE" checked />
                            <div class="chip-content">
                                <span>Online</span>
                                <small>Lấy xác nhận từ xa, thư viện đang xử lý</small>
                            </div>
                        </label>
                        <label class="borrow-chip">
                            <input type="radio" name="borrowMethod" value="IN_PERSON" />
                            <div class="chip-content">
                                <span>Tại chỗ</span>
                                <small>Tới thư viện nhận sách trực tiếp</small>
                            </div>
                        </label>
                    </div>
                    <div class="borrow-details${borrowDetailsVisible ? ' borrow-details--visible' : ''}" data-borrow-details data-auto-show="${borrowDetailsVisible}">
                        <div class="borrow-details-heading">
                            <p class="label">Thông tin thủ thư cần kiểm tra</p>
                            <small>Điền đầy đủ để thủ thư có thể liên hệ và xác thực ngay.</small>
                        </div>
                        <div class="borrow-details-grid">
                            <label class="form-group">
                                <span>Email liên hệ</span>
                                <input type="email" name="contactEmail" placeholder="Ví dụ: ban@mail.com" disabled required value="${userEmail != null ? userEmail : ''}" />
                            </label>
                            <label class="form-group">
                                <span>Thời gian mượn</span>
                                <select name="borrowDuration" disabled required>
                                    <option value="7">7 ngày</option>
                                    <option value="14">14 ngày</option>
                                </select>
                            </label>
                            <label class="form-group pickup-row" data-pickup-dependent>
                                <span>Ngày đến lấy sách</span>
                                <input type="date" name="pickupDate" disabled required />
                                <small>Chỉ cần khi bạn chọn mượn tại chỗ.</small>
                            </label>
                        </div>
                    </div>
                    <button type="button" class="btn primary" data-open-confirm>Mượn ngay</button>
                </form>
                <a href="${pageContext.request.contextPath}/books" class="btn secondary">Tiếp tục xem sách</a>
            </aside>
        </section>
    </c:if>
</main>

<div class="shipping-overlay" hidden data-shipping-overlay
    data-profile-recipient="${not empty userFullName ? fn:escapeXml(userFullName) : ''}"
    data-profile-phone="${not empty userPhone ? fn:escapeXml(userPhone) : ''}"
    data-profile-street="${not empty userAddress ? fn:escapeXml(userAddress) : ''}">
    <div class="shipping-dialog">
        <div class="shipping-header">
            <p class="label">Thông tin giao sách</p>
            <h3>Checkout cùng Giao Hàng Tiết Kiệm</h3>
            <p>Điền đầy đủ tỉnh/thành, quận/huyện, phường/xã để hệ thống có thể lập đơn tự động.</p>
        </div>
        <div class="shipping-form-grid">
            <label class="form-group">
                <span>Tên người nhận</span>
                <input type="text" data-shipping-field="recipient" placeholder="Ví dụ: Nguyễn Thị Hoa" required />
            </label>
            <label class="form-group">
                <span>Số điện thoại</span>
                <input type="tel" inputmode="tel" data-shipping-field="phone" placeholder="0901234567" required pattern="[0-9]{10,11}" title="Nhập 10 hoặc 11 chữ số" />
            </label>
            <label class="form-group">
                <span>Tên đường / số nhà</span>
                <input type="text" data-shipping-field="street" placeholder="118/2/14 Lê Văn Thọ" required />
            </label>
            <label class="form-group">
                <span>Khối / căn hộ <span class="optional-label">(Tùy chọn)</span></span>
                <input type="text" data-shipping-field="residence" placeholder="Tầng 4, Chung cư Phúc Nguyên" />
            </label>
            <label class="form-group">
                <span>Tỉnh / Thành phố</span>
                <select id="province" data-shipping-field="city" required>
                    <option value="">Chọn tỉnh/thành</option>
                </select>
            </label>
            <label class="form-group">
                <span>Quận / Huyện</span>
                <select id="district" data-shipping-field="district" required>
                    <option value="">Chọn quận/huyện</option>
                </select>
            </label>
            <label class="form-group">
                <span>Phường / Xã</span>
                <select id="ward" data-shipping-field="ward" required>
                    <option value="">Chọn phường/xã</option>
                </select>
            </label>
        </div>
        <p class="shipping-note">Thông tin này sẽ được gửi tới đội vận chuyển để đồng bộ với API Giao Hàng Tiết Kiệm.</p>
        <div class="shipping-actions">
            <button type="button" class="btn secondary" data-shipping-cancel>Hủy</button>
            <button type="button" class="btn primary" data-shipping-submit>Checkout</button>
        </div>
    </div>
</div>

<div class="confirm-overlay" hidden data-confirm-overlay>
    <div class="confirm-dialog">
        <h3>Xác nhận mượn sách</h3>
        <p>Bạn đang chọn phương thức <strong data-confirm-method></strong>. Hãy xác nhận trước khi gửi yêu cầu.</p>
        <div class="confirm-actions">
            <button type="button" class="btn secondary" data-confirm-cancel>Hủy</button>
            <button type="button" class="btn primary" data-confirm-submit>Mượn</button>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/footer.jsp" />

<script>
    (function() {
        const detailPanel = document.querySelector('[data-borrow-details]');
        if (!detailPanel) {
            return;
        }
        const detailInputs = Array.from(detailPanel.querySelectorAll('input'));
        const pickupDependents = detailPanel.querySelectorAll('[data-pickup-dependent]');
        const pickupInputs = detailPanel.querySelectorAll('input[name="pickupDate"]');
        const confirmOverlay = document.querySelector('[data-confirm-overlay]');
        const confirmMethodLabel = confirmOverlay?.querySelector('[data-confirm-method]');
        const confirmSubmit = confirmOverlay?.querySelector('[data-confirm-submit]');
        const confirmCancel = confirmOverlay?.querySelector('[data-confirm-cancel]');
        const openBorrowButton = document.querySelector('[data-open-confirm]');
        const borrowForm = document.querySelector('.borrow-form');
        const shippingOverlay = document.querySelector('[data-shipping-overlay]');
        const shippingFields = shippingOverlay ? Array.from(shippingOverlay.querySelectorAll('[data-shipping-field]')) : [];
        const shippingHiddenInputs = borrowForm ? Array.from(borrowForm.querySelectorAll('[data-shipping-hidden]')) : [];
        const shippingFieldMap = shippingFields.reduce((map, field) => {
            map[field.dataset.shippingField] = field;
            return map;
        }, {});
        const shippingHiddenMap = shippingHiddenInputs.reduce((map, hidden) => {
            map[hidden.dataset.shippingHidden] = hidden;
            return map;
        }, {});
        const shippingSubmitButton = shippingOverlay?.querySelector('[data-shipping-submit]');
        const shippingCancelButton = shippingOverlay?.querySelector('[data-shipping-cancel]');
        const shippingCitySelect = shippingFieldMap.city;
        const shippingDistrictSelect = shippingFieldMap.district;
        const shippingWardSelect = shippingFieldMap.ward;

        const profileDefaults = {
            recipient: (shippingOverlay?.dataset.profileRecipient || '').trim(),
            phone: (shippingOverlay?.dataset.profilePhone || '').trim(),
            street: (shippingOverlay?.dataset.profileStreet || '').trim()
        };

        const applyProfileDefaults = () => {
            Object.entries(profileDefaults).forEach(([key, value]) => {
                if (!value) return;
                const field = shippingFieldMap[key];
                if (!field) return;
                // Chỉ điền nếu ô đó đang trống
                if (!field.value.trim()) {
                    field.value = value;
                }
            });
        };

        if (shippingOverlay && shippingOverlay.parentElement !== document.body) {
            document.body.appendChild(shippingOverlay);
        }
        if (shippingOverlay) {
            shippingOverlay.hidden = true;
        }

        const PROVINCE_API_URL = 'https://provinces.open-api.vn/api/?depth=3';
        const locationCatalog = new Map();
        let locationDataReady = false;
        let locationDataPromise;

        const resetSelect = (select, placeholder) => {
            if (!select) {
                return;
            }
            select.innerHTML = `<option value="">${placeholder}</option>`;
        };

        const buildLocationCatalog = (provinces = []) => {
            locationCatalog.clear();
            if (!Array.isArray(provinces)) {
                return;
            }
            provinces.forEach(province => {
                if (!province || !province.name) {
                    return;
                }
                const districts = new Map();
                (province.districts || []).forEach(district => {
                    if (!district || !district.name) {
                        return;
                    }
                    const wards = Array.isArray(district.wards)
                            ? district.wards.map(ward => ward.name).filter(Boolean)
                            : [];
                    districts.set(district.name, wards);
                });
                locationCatalog.set(province.name, { districts });
            });
            locationDataReady = locationCatalog.size > 0;
        };

        const populateCities = () => {
            if (!shippingCitySelect) {
                return;
            }
            resetSelect(shippingCitySelect, 'Chọn tỉnh/thành');
            if (!locationDataReady) {
                return;
            }
            locationCatalog.forEach((value, name) => {
                const option = document.createElement('option');
                option.value = name;
                option.textContent = name;
                shippingCitySelect.appendChild(option);
            });
            renderDistricts('');
            renderWards('', '');
        };

        const renderDistricts = (city) => {
            if (!shippingDistrictSelect) {
                return;
            }
            resetSelect(shippingDistrictSelect, 'Chọn quận/huyện');
            resetSelect(shippingWardSelect, 'Chọn phường/xã');
            if (!locationDataReady || !city) {
                return;
            }
            const province = locationCatalog.get(city);
            if (!province) {
                return;
            }
            province.districts.forEach((wards, districtName) => {
                const option = document.createElement('option');
                option.value = districtName;
                option.textContent = districtName;
                shippingDistrictSelect.appendChild(option);
            });
        };

        const renderWards = (city, district) => {
            if (!shippingWardSelect) {
                return;
            }
            resetSelect(shippingWardSelect, 'Chọn phường/xã');
            if (!locationDataReady || !city || !district) {
                return;
            }
            const province = locationCatalog.get(city);
            const wardList = province?.districts.get(district);
            if (!Array.isArray(wardList)) {
                return;
            }
            wardList.forEach(ward => {
                const option = document.createElement('option');
                option.value = ward;
                option.textContent = ward;
                shippingWardSelect.appendChild(option);
            });
        };

        const fetchLocationCatalog = () => {
            if (locationDataPromise) {
                return locationDataPromise;
            }
            locationDataPromise = fetch(PROVINCE_API_URL)
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('Không thể tải dữ liệu tỉnh thành');
                        }
                        return response.json();
                    })
                    .then(data => {
                        buildLocationCatalog(data);
                        if (locationDataReady) {
                            populateCities();
                        }
                    })
                    .catch(error => {
                        console.error('Không tải được danh sách tỉnh/thành:', error);
                    });
            return locationDataPromise;
        };

        const ensureLocationData = () => {
            if (locationDataReady) {
                return Promise.resolve();
            }
            return fetchLocationCatalog();
        };

        const fillShippingOverlay = () => {
            Object.entries(shippingHiddenMap).forEach(([key, hidden]) => {
                const field = shippingFieldMap[key];
                if (field) {
                    field.value = hidden.value;
                }
            });
            
            // Áp dụng thông tin từ profile cho các ô còn trống
            applyProfileDefaults();

            ensureLocationData().then(() => {
                if (!shippingCitySelect) {
                    return;
                }
                const storedCity = shippingHiddenMap.city?.value;
                if (storedCity) {
                    shippingCitySelect.value = storedCity;
                    renderDistricts(storedCity);
                    const storedDistrict = shippingHiddenMap.district?.value;
                    if (storedDistrict && shippingDistrictSelect) {
                        shippingDistrictSelect.value = storedDistrict;
                        renderWards(storedCity, storedDistrict);
                        const storedWard = shippingHiddenMap.ward?.value;
                        if (storedWard && shippingWardSelect) {
                            shippingWardSelect.value = storedWard;
                        }
                    } else {
                        renderWards(storedCity, '');
                    }
                } else {
                    renderDistricts('');
                    renderWards('', '');
                }
            });
        };

        const syncShippingHidden = () => {
            Object.entries(shippingFieldMap).forEach(([key, field]) => {
                const hidden = shippingHiddenMap[key];
                if (hidden) {
                    hidden.value = field.value.trim();
                }
            });
        };

        const closeShippingOverlay = () => {
            if (!shippingOverlay || shippingOverlay.hidden) {
                return;
            }
            shippingOverlay.hidden = true;
            document.body.classList.remove('modal-open');
        };

        const showShippingOverlay = () => {
            if (!shippingOverlay) {
                openConfirmOverlay();
                return;
            }
            fillShippingOverlay();
            shippingOverlay.hidden = false;
            document.body.classList.add('modal-open');
        };

        const handleShippingSubmit = () => {
            let valid = true;
            shippingFields.forEach(field => {
                if (!field.checkValidity()) {
                    field.reportValidity();
                    valid = false;
                }
            });
            if (!valid) {
                return;
            }
            syncShippingHidden();
            closeShippingOverlay();
            borrowForm?.submit();
        };

        shippingOverlay?.addEventListener('click', event => {
            if (event.target === shippingOverlay) {
                closeShippingOverlay();
            }
        });
        shippingCancelButton?.addEventListener('click', closeShippingOverlay);
        shippingSubmitButton?.addEventListener('click', handleShippingSubmit);
        shippingCitySelect?.addEventListener('change', () => {
            renderDistricts(shippingCitySelect.value);
            renderWards(shippingCitySelect.value, '');
        });
        shippingDistrictSelect?.addEventListener('change', () => {
            renderWards(shippingCitySelect.value, shippingDistrictSelect.value);
        });

        const updateMethodDependents = () => {
            const selected = document.querySelector('input[name="borrowMethod"]:checked');
            const isInPerson = selected && selected.value === 'IN_PERSON';
            pickupDependents.forEach(node => node.classList.toggle('pickup-row--visible', isInPerson));
            if (!detailPanel.classList.contains('borrow-details--visible')) {
                return;
            }
            pickupInputs.forEach(input => {
                input.required = isInPerson;
                input.disabled = !isInPerson;
            });
        };
        const showDetails = () => {
            detailPanel.classList.add('borrow-details--visible');
            detailInputs.forEach(input => {
                input.disabled = false;
            });
            updateMethodDependents();
        };
        const radios = document.querySelectorAll('input[name="borrowMethod"]');
        radios.forEach(radio => {
            const handler = () => showDetails();
            radio.addEventListener('change', handler);
            radio.addEventListener('focus', handler);
        });
        updateMethodDependents();
        if (detailPanel.dataset.autoShow === 'true') {
            showDetails();
        }

        const closeConfirmOverlay = () => {
            if (!confirmOverlay || confirmOverlay.hidden) {
                return;
            }
            confirmOverlay.hidden = true;
            document.body.classList.remove('modal-open');
        };

        const openConfirmOverlay = () => {
            if (!confirmOverlay) {
                return;
            }
            const selected = document.querySelector('input[name="borrowMethod"]:checked');
            const methodLabel = selected && selected.value === 'IN_PERSON' ? 'Tại chỗ' : 'Online';
            if (confirmMethodLabel) {
                confirmMethodLabel.textContent = methodLabel;
            }
            confirmOverlay.hidden = false;
            document.body.classList.add('modal-open');
        };

        const openBorrowModal = () => {
            const selected = document.querySelector('input[name="borrowMethod"]:checked');
            if (selected && selected.value === 'ONLINE' && shippingOverlay) {
                showShippingOverlay();
                return;
            }
            openConfirmOverlay();
        };

        openBorrowButton?.addEventListener('click', event => {
            event.preventDefault();
            openBorrowModal();
        });

        confirmSubmit?.addEventListener('click', () => {
            closeConfirmOverlay();
            borrowForm?.submit();
        });

        confirmCancel?.addEventListener('click', closeConfirmOverlay);
        confirmOverlay?.addEventListener('click', event => {
            if (event.target === confirmOverlay) {
                closeConfirmOverlay();
            }
        });
        document.addEventListener('keydown', event => {
            if (event.key === 'Escape') {
                if (shippingOverlay && !shippingOverlay.hidden) {
                    closeShippingOverlay();
                } else {
                    closeConfirmOverlay();
                }
            }
        });

        fetchLocationCatalog();
    })();
</script>

</body>
</html>