<%-- shop.jsp - LUXE INTERIORS (nền sáng) --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="vi_VN"/>

<c:set var="pageTitle" value="Cửa hàng - LUXE INTERIORS" scope="request" />
<jsp:include page="/includes/header.jsp" />

<style>
    /* ÉP NỀN SÁNG TOÀN TRANG SHOP (đè mọi CSS tối khác) */
    body {
        background-color: #fbfaf8 !important;
        color: #1d1a16;
    }

    /* container */
    .container-shop {
        padding: 36px 0 48px;
    }

    /* SHOP HEADER */
    .shop-header{
        margin-bottom: 20px;
        display:flex;
        justify-content:space-between;
        align-items:flex-end;
        gap:16px;
    }
    .shop-title{
        font-family:'Playfair Display',serif;
        font-weight:700;
        font-size:2rem;
        margin:0 0 4px;
        color:#1d1a16;
    }
    .shop-subtitle{
        font-size:.95rem;
        color:#6c757d;
        margin:0;
    }
    .shop-meta{
        text-align:right;
        font-size:.85rem;
        color:#6c757d;
    }
    .shop-meta-pill{
        display:inline-flex;
        align-items:center;
        gap:6px;
        padding:6px 12px;
        border-radius:999px;
        background:#ffffff;
        box-shadow:0 8px 24px rgba(15,23,42,0.06);
    }
    .shop-meta-pill span:first-child{
        font-weight:600;
    }

    /* filter panel */
    .filter-panel {
        background:#ffffff;
        padding: 18px;
        border-radius: 12px;
        box-shadow: 0 8px 24px rgba(20,20,20,0.05);
    }
    .filter-panel .form-control,
    .filter-panel .form-select {
        border-radius: 999px;
    }

    /* brand scroller */
    .brand-scroller {
        display:flex;
        gap:10px;
        align-items:center;
        margin-bottom:18px;
    }
    .brand-track {
        display:flex;
        gap:12px;
        overflow-x:auto;
        padding:6px 4px;
        scrollbar-width:none;
        -webkit-overflow-scrolling:touch;
    }
    .brand-track::-webkit-scrollbar{
        display:none;
    }
    .brand-item {
        min-width:84px;
        text-align:center;
        text-decoration:none;
        color:#6c757d;
    }
    .brand-label{
        font-size:0.8rem;
        margin-top:4px;
    }
    .logo-box {
        width:60px;
        height:60px;
        border-radius:12px;
        display:grid;
        place-items:center;
        background:#ffffff;
        box-shadow:0 8px 20px rgba(0,0,0,0.05);
        font-weight:700;
    }
    .brand-item.active .logo-box {
        box-shadow:0 12px 30px rgba(212,175,55,0.12);
        border:2px solid #d4af37;
        color:#1d1a16;
    }
    .scroll-btn {
        width:40px;
        height:40px;
        border-radius:10px;
        border:none;
        background:#ffffff;
        box-shadow:0 8px 20px rgba(0,0,0,0.06);
        display:grid;
        place-items:center;
        cursor:pointer;
    }

    /* product grid */
    .products-grid {
        display:grid;
        gap:22px;
        grid-template-columns: repeat(12,1fr);
        align-items:start;
    }
    .large-card {
        grid-column: span 6;
    }
    .small-col {
        grid-column: span 6;
        display:grid;
        grid-template-columns: repeat(2,1fr);
        gap:18px;
    }

    .card-product {
        background:#ffffff;
        border-radius:12px;
        overflow:hidden;
        box-shadow:0 10px 30px rgba(0,0,0,0.04);
        transition:transform .14s ease, box-shadow .14s ease;
        display:flex;
        flex-direction:column;
        height:100%;
    }
    .card-product:hover {
        transform: translateY(-6px);
        box-shadow:0 16px 40px rgba(15,23,42,0.08);
    }
    .product-media {
        position:relative;
        overflow:hidden;
    }
    .product-media img {
        width:100%;
        height:320px;
        object-fit:cover;
        display:block;
        transition: transform .5s ease;
    }
    .card-product:hover .product-media img{
        transform: scale(1.04);
    }
    .quick-actions {
        position:absolute;
        right:12px;
        bottom:12px;
        display:flex;
        gap:8px;
    }
    .qa-btn {
        background:rgba(255,255,255,0.95);
        border-radius:10px;
        padding:8px;
        display:grid;
        place-items:center;
        box-shadow:0 6px 18px rgba(0,0,0,0.06);
        color:#1d1a16;
        text-decoration:none;
    }

    /* card body */
    .card-body {
        padding:16px;
        display:flex;
        flex-direction:column;
        gap:8px;
        flex:1;
    }
    .product-brand {
        color:#6c757d;
        font-weight:700;
        font-size:0.78rem;
        letter-spacing:0.06em;
        text-transform:uppercase;
    }
    .product-title {
        margin:0;
        font-weight:800;
        font-size:1.05rem;
        color:#1d1a16;
    }
    .product-desc {
        color:#6c757d;
        font-size:0.95rem;
        line-height:1.3;
        display:-webkit-box;
        -webkit-line-clamp:2;
        -webkit-box-orient:vertical;
        overflow:hidden;
    }

    /* price & stock */
    .price {
        color:#d4af37;
        font-weight:800;
        font-size:1.15rem;
    }
    .badge {
        font-weight:700;
    }

    /* pagination */
    .pagination {
        display:flex;
        gap:8px;
        justify-content:center;
        align-items:center;
        margin-top:22px;
        flex-wrap:wrap;
    }
    .page-link {
        padding:8px 12px;
        border-radius:10px;
        background:#ffffff;
        border:1px solid rgba(0,0,0,0.06);
        color:#1d1a16;
        text-decoration:none;
        cursor:pointer;
    }
    .page-item.active .page-link{
        background:linear-gradient(90deg,#d4af37, #c99b2a);
        color:#ffffff;
        box-shadow:0 12px 30px rgba(212,175,55,0.12);
    }
    .page-item.disabled .page-link{
        opacity:.4;
        cursor:default;
    }

    /* trust badges */
    .trust-row {
        margin-top:36px;
        display:grid;
        grid-template-columns:repeat(4,1fr);
        gap:18px;
    }
    .trust-card {
        background:#ffffff;
        border-radius:12px;
        padding:18px;
        text-align:center;
        box-shadow:0 10px 30px rgba(0,0,0,0.04);
    }
    .trust-icon {
        width:56px;
        height:56px;
        border-radius:8px;
        background:linear-gradient(180deg,#ffffff,#faf7f2);
        display:grid;
        place-items:center;
        color:#d4af37;
        font-size:1.4rem;
        margin:0 auto 8px;
    }

    /* responsive */
    @media (max-width:991px){
        .product-media img{
            height:220px;
        }
        .products-grid{
            grid-template-columns: repeat(6,1fr);
        }
        .large-card{
            grid-column: span 6;
        }
        .small-col{
            grid-column: span 6;
            grid-template-columns:repeat(2,1fr);
        }
        .trust-row{
            grid-template-columns:repeat(2,1fr);
        }
        .shop-header{
            flex-direction:column;
            align-items:flex-start;
        }
        .shop-meta{
            text-align:left;
        }
    }
    @media (max-width:576px){
        .product-media img{
            height:160px;
        }
        .products-grid{
            grid-template-columns: repeat(2,1fr);
            gap:14px;
        }
        .small-col{
            grid-template-columns: repeat(1,1fr);
        }
        .brand-track{
            gap:10px;
        }
        .logo-box{
            width:48px;
            height:48px;
        }
        .trust-row{
            grid-template-columns:repeat(1,1fr);
        }
    }
</style>

<main class="container-shop">
    <div class="container">

        <%-- Biến server cung cấp + giá trị mặc định an toàn --%>
        <c:set var="page"       value="${empty currentPage ? 1 : currentPage}" />
        <c:set var="pageSize"   value="${empty pageSize ? 12 : pageSize}" />
        <c:set var="totalPages" value="${empty totalPages ? 1 : totalPages}" />
        <c:set var="totalCount" value="${empty totalCount ? 0 : totalCount}" />
        <c:set var="visibleCount" value="${products != null ? fn:length(products) : 0}" />
        <c:set var="startIndex"
               value="${totalCount > 0 and visibleCount > 0 ? ((page-1) * pageSize + 1) : 0}" />
        <c:set var="endIndex"
               value="${totalCount > 0 and visibleCount > 0 ? (startIndex + visibleCount - 1) : 0}" />

        <%-- SHOP HEADER (Title + meta) --%>
        <header class="shop-header">
            <div>
                <h1 class="shop-title">Cửa hàng</h1>
                <p class="shop-subtitle">
                    Khám phá các thiết kế nội thất tinh tế, phù hợp cho từng không gian sống của bạn.
                </p>
            </div>
            <div class="shop-meta">
                <div class="shop-meta-pill">
                    <span>${totalCount}</span>
                    <span>sản phẩm hiện có</span>
                </div>
                <div class="mt-1">
                    <c:if test="${not empty selectedBrand && selectedBrand ne 'all'}">
                        Thương hiệu: <strong>${fn:escapeXml(selectedBrand)}</strong>
                    </c:if>
                    <c:if test="${not empty keywordValue}">
                        <c:if test="${not empty selectedBrand && selectedBrand ne 'all'}"> • </c:if>
                        Từ khoá: “${fn:escapeXml(keywordValue)}”
                    </c:if>
                </div>
            </div>
        </header>

        <%-- BRAND SCROLLER --%>
        <section class="mb-3">
            <div class="brand-scroller">
                <button class="scroll-btn" id="brandPrev" type="button">
                    <i class="fas fa-chevron-left"></i>
                </button>

                <div class="brand-track" id="brandTrack" role="list">
                    <a class="brand-item ${empty selectedBrand || selectedBrand == 'all' ? 'active' : ''}"
                       href="${pageContext.request.contextPath}/shop?cid=${selectedCid != null ? selectedCid : 'all'}&sort=${sortByValue}&min=${minValue}&max=${maxValue}">
                        <div class="logo-box">
                            <i class="fas fa-th-large"></i>
                        </div>
                        <div class="brand-label">Tất cả</div>
                    </a>

                    <c:forEach var="b" items="${brands}">
                        <a class="brand-item ${selectedBrand == b ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/shop?brandName=${fn:escapeXml(b)}&cid=${selectedCid != null ? selectedCid : 'all'}&sort=${sortByValue}&min=${minValue}&max=${maxValue}">
                            <div class="logo-box">
                                <span class="fw-bold">
                                    ${fn:toUpperCase(fn:substring(b,0, fn:length(b) > 2 ? 2 : fn:length(b)))}
                                </span>
                            </div>
                            <div class="brand-label">${fn:escapeXml(b)}</div>
                        </a>
                    </c:forEach>
                </div>

                <button class="scroll-btn" id="brandNext" type="button">
                    <i class="fas fa-chevron-right"></i>
                </button>
            </div>
        </section>

        <%-- FILTER PANEL --%>
        <section class="mb-4">
            <div class="filter-panel">
                <form id="filterForm"
                      action="${pageContext.request.contextPath}/shop"
                      method="get"
                      class="row g-3 align-items-center">
                    <input type="hidden" name="page" id="pageInput" value="${page}" />
                    <input type="hidden" name="brandName" value="${selectedBrand != null ? selectedBrand : 'all'}" />

                    <div class="col-md-3">
                        <label class="form-label small text-muted mb-1">Danh mục</label>
                        <select name="cid" class="form-select">
                            <option value="all"
                                    <c:if test="${selectedCid == null || selectedCid eq 'all'}">selected</c:if>>
                                Tất cả danh mục
                            </option>
                            <c:forEach var="c" items="${categories}">
                                <option value="${c.categoryID}"
                                        <c:if test="${selectedCidInt == c.categoryID}">selected</c:if>>
                                    ${fn:escapeXml(c.categoryName)}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label small text-muted mb-1">Sắp xếp</label>
                        <select name="sort" class="form-select">
                            <option value="newest"
                                    <c:if test="${sortByValue eq 'newest' || empty sortByValue}">selected</c:if>>
                                Mới nhất
                            </option>
                            <option value="price-asc"
                                    <c:if test="${sortByValue eq 'price-asc'}">selected</c:if>>
                                Giá: thấp → cao
                            </option>
                            <option value="price-desc"
                                    <c:if test="${sortByValue eq 'price-desc'}">selected</c:if>>
                                Giá: cao → thấp
                            </option>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label small text-muted mb-1">Khoảng giá & từ khoá</label>
                        <div class="d-flex gap-2">
                            <input type="number" name="min" class="form-control"
                                   placeholder="Giá từ" min="0"
                                   value="${minValue > 0 ? minValue : ''}" />
                            <input type="number" name="max" class="form-control"
                                   placeholder="Giá đến" min="0"
                                   value="${maxValue > 0 ? maxValue : ''}" />
                            <input type="text" name="keyword" class="form-control"
                                   placeholder="Tìm kiếm..."
                                   value="${fn:escapeXml(keywordValue != null ? keywordValue : '')}" />
                        </div>
                    </div>

                    <div class="col-md-2 d-flex justify-content-end gap-2">
                        <button type="button" id="resetBtn" class="btn btn-outline-secondary">
                            Xoá
                        </button>
                        <button type="submit" class="btn-luxury">
                            Áp dụng
                        </button>
                    </div>

                    <div class="col-12">
                        <div class="small text-muted">
                            <c:choose>
                                <c:when test="${totalCount > 0}">
                                    Hiển thị
                                    <strong>${startIndex}-${endIndex}</strong>
                                    trong
                                    <strong>${totalCount}</strong> sản phẩm
                                </c:when>
                                <c:otherwise>
                                    Không có sản phẩm nào trong bộ lọc hiện tại
                                </c:otherwise>
                            </c:choose>
                            <c:if test="${not empty keywordValue}">
                                • Từ khoá: “${fn:escapeXml(keywordValue)}”
                            </c:if>
                        </div>
                    </div>
                </form>
            </div>
        </section>

        <%-- PRODUCTS --%>
        <section>
            <c:choose>
                <c:when test="${not empty products}">
                    <div class="products-grid">
                        <c:forEach items="${products}" var="p" varStatus="st">
                            <c:choose>
                                <%-- Card lớn --%>
                                <c:when test="${st.index % 5 == 0}">
                                    <div class="large-card">
                                        <div class="card-product">
                                            <div class="product-media">
                                                <a href="${pageContext.request.contextPath}/product-detail?pid=${p.productID}">
                                                    <img loading="lazy"
                                                         src="${p.imageURL}"
                                                         alt="${fn:escapeXml(p.productName)}"
                                                         onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/placeholder.png';"/>
                                                </a>
                                                <div class="quick-actions">
                                                    <a class="qa-btn"
                                                       href="${pageContext.request.contextPath}/product-detail?pid=${p.productID}"
                                                       title="Xem">
                                                        <i class="fas fa-eye"></i>
                                                    </a>
                                                    <a class="qa-btn"
                                                       href="${pageContext.request.contextPath}/cart?action=add&amp;pid=${p.productID}"
                                                       title="Thêm vào giỏ">
                                                        <i class="fas fa-cart-plus"></i>
                                                    </a>
                                                </div>
                                            </div>
                                            <div class="card-body">
                                                <div class="product-brand">
                                                    ${fn:escapeXml(p.brand)}
                                                </div>
                                                <h3 class="product-title"
                                                    title="${fn:escapeXml(p.productName)}">
                                                    ${fn:escapeXml(p.productName)}
                                                </h3>
                                                <div class="product-desc">
                                                    ${fn:escapeXml(p.description)}
                                                </div>
                                                <div class="d-flex justify-content-between align-items-center mt-2">
                                                    <div class="price">
                                                        <fmt:formatNumber value="${p.price}"
                                                                          type="currency"
                                                                          currencyCode="VND"/>
                                                    </div>
                                                    <div>
                                                        <c:choose>
                                                            <c:when test="${p.stock > 0}">
                                                                <span class="badge bg-success">
                                                                    Còn ${p.stock}
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary">
                                                                    Hết hàng
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:when>

                                <%-- Card nhỏ --%>
                                <c:otherwise>
                                    <c:if test="${st.index % 5 == 1}">
                                        <div class="small-col">
                                    </c:if>

                                    <div class="card-product">
                                        <div class="product-media">
                                            <a href="${pageContext.request.contextPath}/product-detail?pid=${p.productID}">
                                                <img loading="lazy"
                                                     src="${p.imageURL}"
                                                     alt="${fn:escapeXml(p.productName)}"
                                                     onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/placeholder.png';"/>
                                            </a>
                                            <div class="quick-actions">
                                                <a class="qa-btn"
                                                   href="${pageContext.request.contextPath}/product-detail?pid=${p.productID}"
                                                   title="Xem">
                                                    <i class="fas fa-eye"></i>
                                                </a>
                                                <a class="qa-btn"
                                                   href="${pageContext.request.contextPath}/cart?action=add&amp;pid=${p.productID}"
                                                   title="Thêm vào giỏ">
                                                    <i class="fas fa-cart-plus"></i>
                                                </a>
                                            </div>
                                        </div>
                                        <div class="card-body">
                                            <div class="product-brand">
                                                ${fn:escapeXml(p.brand)}
                                            </div>
                                            <h5 class="product-title text-truncate"
                                                title="${fn:escapeXml(p.productName)}">
                                                ${fn:escapeXml(p.productName)}
                                            </h5>
                                            <div class="d-flex justify-content-between align-items-center mt-2">
                                                <div class="price">
                                                    <fmt:formatNumber value="${p.price}"
                                                                      type="currency"
                                                                      currencyCode="VND"/>
                                                </div>
                                                <div>
                                                    <c:choose>
                                                        <c:when test="${p.stock > 0}">
                                                            <span class="badge bg-success">
                                                                Còn ${p.stock}
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary">
                                                                Hết hàng
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <c:if test="${st.index % 5 == 4 || st.last}">
                                        </div><%-- close .small-col --%>
                                    </c:if>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>
                    </div>

                    <%-- PAGINATION: submit filterForm với page mới --%>
                    <c:if test="${totalPages > 1}">
                        <nav aria-label="Page navigation">
                            <ul class="pagination" role="navigation">
                                <li class="page-item ${page == 1 ? 'disabled' : ''}">
                                    <a class="page-link" data-page="1">&laquo;</a>
                                </li>
                                <li class="page-item ${page == 1 ? 'disabled' : ''}">
                                    <a class="page-link" data-page="${page-1}">Trước</a>
                                </li>

                                <c:forEach var="i"
                                           begin="${page-2 > 1 ? page-2 : 1}"
                                           end="${page+2 < totalPages ? page+2 : totalPages}">
                                    <li class="page-item ${i == page ? 'active' : ''}">
                                        <a class="page-link" data-page="${i}">${i}</a>
                                    </li>
                                </c:forEach>

                                <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" data-page="${page+1}">Sau</a>
                                </li>
                                <li class="page-item ${page == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" data-page="${totalPages}">&raquo;</a>
                                </li>
                            </ul>
                        </nav>
                    </c:if>

                </c:when>

                <c:otherwise>
                    <div class="text-center py-5">
                        <i class="fas fa-box-open fa-4x text-muted mb-3"></i>
                        <h3>Không tìm thấy sản phẩm</h3>
                        <p class="text-muted">
                            Thử từ khoá khác hoặc xoá bớt điều kiện lọc.
                        </p>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

        <%-- TRUST BADGES --%>
        <section class="trust-row">
            <div class="trust-card">
                <div class="trust-icon">
                    <i class="fas fa-shield-alt"></i>
                </div>
                <h6>Thương hiệu đảm bảo</h6>
                <p class="text-muted small mb-0">
                    Nhập khẩu, bảo hành chính hãng.
                </p>
            </div>
            <div class="trust-card">
                <div class="trust-icon">
                    <i class="fas fa-exchange-alt"></i>
                </div>
                <h6>Đổi trả dễ</h6>
                <p class="text-muted small mb-0">
                    Chính sách đổi trả linh hoạt, minh bạch.
                </p>
            </div>
            <div class="trust-card">
                <div class="trust-icon">
                    <i class="fas fa-truck"></i>
                </div>
                <h6>Giao &amp; lắp đặt</h6>
                <p class="text-muted small mb-0">
                    Toàn quốc, đội ngũ chuyên nghiệp.
                </p>
            </div>
            <div class="trust-card">
                <div class="trust-icon">
                    <i class="fas fa-gem"></i>
                </div>
                <h6>Sản phẩm cao cấp</h6>
                <p class="text-muted small mb-0">
                    Thiết kế tinh tế, bền bỉ theo thời gian.
                </p>
            </div>
        </section>

    </div><%-- /.container --%>
</main>

<jsp:include page="/includes/footer.jsp" />

<script>
    // Pagination: set page & submit filterForm
    (function () {
        const form = document.getElementById('filterForm');
        const pageInput = document.getElementById('pageInput');
        if (!form || !pageInput) return;

        document.querySelectorAll('.pagination .page-link').forEach(function (a) {
            a.addEventListener('click', function (e) {
                e.preventDefault();
                const page = this.dataset.page;
                if (!page || this.closest('.page-item').classList.contains('disabled')) {
                    return;
                }
                pageInput.value = page;
                form.submit();
            });
        });
    })();

    // Reset filters but preserve brandName
    (function () {
        const btn = document.getElementById('resetBtn');
        if (!btn) return;

        btn.addEventListener('click', function () {
            const urlParams = new URLSearchParams(window.location.search);
            const brand = urlParams.get('brandName') || 'all';
            const base = '<c:url value="/shop"/>';
            const target = base + (brand ? ('?brandName=' + encodeURIComponent(brand)) : '');
            window.location.href = target;
        });
    })();

    // Brand scroller controls
    (function () {
        const prev = document.getElementById('brandPrev');
        const next = document.getElementById('brandNext');
        const track = document.getElementById('brandTrack');
        if (!track) return;

        prev && prev.addEventListener('click', function () {
            track.scrollBy({left: -220, behavior: 'smooth'});
        });
        next && next.addEventListener('click', function () {
            track.scrollBy({left: 220, behavior: 'smooth'});
        });
    })();
</script>
