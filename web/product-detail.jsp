<%-- product-detail.jsp - LUXE INTERIORS --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<fmt:setLocale value="vi_VN"/>

<c:set var="pageTitle"
       value="${product != null ? product.productName : 'Chi tiết sản phẩm'} - LUXE INTERIORS"
       scope="request"/>

<jsp:include page="/includes/header.jsp" />

<style>
  /* Nhãn thương hiệu nhỏ giống các site nội thất cao cấp */
  .product-brand {
    font-size: 0.8rem;
    font-weight: 600;
    color: #9ca3af;
    text-transform: uppercase;
    letter-spacing: 0.08em;
  }

  .product-meta-list li + li {
    margin-top: 2px;
  }

  .pd-badge-group .badge + .badge {
    margin-left: .5rem;
  }

  .pd-description {
    white-space: pre-line; /* xuống dòng theo \n trong description */
  }

  .pd-thumbnail {
    width: 92px;
    height: 92px;
    object-fit: cover;
    cursor: pointer;
    transition: transform .18s ease, box-shadow .18s ease, border-color .18s ease;
  }

  .pd-thumbnail:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(0,0,0,.08);
    border-color: #e5b35c;
  }

  .pd-thumbnail.active {
    border: 2px solid #e5b35c;
  }
</style>

<main class="container my-5">

  <c:choose>
    <c:when test="${empty product}">
      <div class="text-center py-5">
        <h1 class="h4 mb-3">Sản phẩm không tồn tại</h1>
        <p class="text-muted mb-4">Rất tiếc, chúng tôi không tìm thấy sản phẩm bạn yêu cầu.</p>
        <a href="<c:url value='/shop'/>" class="btn btn-outline-dark rounded-pill px-4">
          Quay lại cửa hàng
        </a>
      </div>
    </c:when>

    <c:otherwise>
      <%-- Breadcrumb --%>
      <nav class="mb-3 small text-muted">
        <a href="<c:url value='/home'/>" class="text-decoration-none text-muted">Trang chủ</a>
        <span class="mx-2">/</span>
        <a href="<c:url value='/shop'/>" class="text-decoration-none text-muted">Sản phẩm</a>
        <span class="mx-2">/</span>
        <span class="text-dark">${product.productName}</span>
      </nav>

      <div class="row g-4">
        <%-- Cột ảnh sản phẩm --%>
        <div class="col-lg-6">
          <div class="p-3 p-lg-4 bg-white rounded-4 shadow-sm h-100">
            <div class="product-image-wrap shine mb-3" id="pd-main">
              <img id="mainImg"
                   src="<c:out value='${empty gallery ? product.imageURL : gallery[0]}'/>"
                   onerror="this.src='<c:url value="/assets/images/placeholder.png"/>'"
                   alt="${fn:escapeXml(product.productName)}"
                   style="width:100%;height:520px;object-fit:cover;border-radius:18px;">

              <div class="quick-actions">
                <a href="<c:url value='/cart?action=add&amp;pid=${product.productID}'/>"
                   class="qa-btn"
                   title="Thêm vào giỏ">
                  <i class="fas fa-cart-plus"></i>
                </a>
              </div>
            </div>

            <c:if test="${not empty gallery and fn:length(gallery) > 1}">
              <div class="d-flex gap-2 flex-wrap">
                <c:forEach items="${gallery}" var="img" varStatus="st">
                  <img src="${img}"
                       onerror="this.src='<c:url value="/assets/images/placeholder.png"/>'"
                       class="border rounded pd-thumbnail <c:if test='${st.index == 0}'>active</c:if>"
                       data-big="${img}"
                       alt="Thumbnail ${st.index + 1}">
                </c:forEach>
              </div>
            </c:if>
          </div>
        </div>

        <%-- Cột thông tin sản phẩm --%>
        <div class="col-lg-6">
          <div class="p-3 p-lg-4 bg-white rounded-4 shadow-sm h-100 d-flex flex-column">
            <c:if test="${not empty product.brand}">
              <p class="product-brand mb-2">${product.brand}</p>
            </c:if>

            <h1 class="h3 font-playfair mb-3">${product.productName}</h1>

            <div class="d-flex flex-wrap align-items-center gap-3 mb-3 pd-badge-group">
              <div class="fw-normal text-muted fs-5">
                <fmt:formatNumber value="${product.price}"
                                  type="currency"
                                  currencyCode="VND"/>
              </div>

              <c:choose>
                <c:when test="${product.stock > 5}">
                  <span class="badge text-bg-success rounded-pill">
                    Còn hàng: ${product.stock}
                  </span>
                </c:when>
                <c:when test="${product.stock > 0}">
                  <span class="badge text-bg-warning rounded-pill text-dark">
                    Chỉ còn: ${product.stock} sản phẩm
                  </span>
                </c:when>
                <c:otherwise>
                  <span class="badge text-bg-secondary rounded-pill">
                    Hết hàng
                  </span>
                </c:otherwise>
              </c:choose>
            </div>

            <ul class="list-unstyled small text-muted mb-3 product-meta-list">
              <c:if test="${not empty product.material}">
                <li><strong>Chất liệu:</strong> ${product.material}</li>
              </c:if>
              <c:if test="${not empty product.dimensions}">
                <li><strong>Kích thước:</strong> ${product.dimensions}</li>
              </c:if>
            </ul>

            <c:if test="${not empty product.description}">
              <p class="text-secondary pd-description mb-3">
                ${product.description}
              </p>
            </c:if>

            <c:if test="${not empty product.features}">
              <div class="mb-3">
                <div class="fw-semibold mb-2">Nổi bật</div>
                <ul class="small text-secondary ps-3 mb-0">
                  <c:forEach items="${fn:split(product.features, ',')}" var="f">
                    <c:if test="${not empty fn:trim(f)}">
                      <li>${fn:trim(f)}</li>
                    </c:if>
                  </c:forEach>
                </ul>
              </div>
            </c:if>

            <form action="<c:url value='/cart'/>" method="post" class="mt-auto">
              <input type="hidden" name="action" value="add">
              <input type="hidden" name="pid" value="${product.productID}">

              <div class="d-flex align-items-center gap-3 mb-3">
                <label class="small text-muted mb-0">Số lượng</label>
                <input type="number"
                       name="quantity"
                       min="1"
                       value="1"
                       class="form-control rounded-pill"
                       style="width:120px"
                       <c:if test="${product.stock <= 0}">disabled="disabled"</c:if>>
              </div>

              <div class="d-flex gap-3 flex-wrap">
                <button type="submit"
                        class="btn-luxury ripple flex-grow-1"
                        <c:if test="${product.stock <= 0}">disabled="disabled"</c:if>>
                  Thêm vào giỏ
                </button>

                <a href="<c:url value='/cart?action=add&amp;pid=${product.productID}&amp;quantity=1'/>"
                   class="btn btn-outline-secondary rounded-pill px-4 py-3
                   <c:if test='${product.stock <= 0}'> disabled</c:if>">
                  Mua ngay
                </a>
              </div>
            </form>

            <div class="mt-3 small text-muted">
              <i class="fa-solid fa-shield-heart me-1"></i> Bảo hành 24 tháng
              • <i class="fa-solid fa-rotate me-1"></i> Đổi trả 7 ngày
              • <i class="fa-solid fa-truck-fast me-1"></i> Giao nhanh 48h
            </div>
          </div>
        </div>
      </div>

      <%-- Sản phẩm liên quan --%>
      <c:if test="${not empty related}">
        <section class="mt-5">
          <h3 class="h4 font-playfair mb-3">Sản phẩm liên quan</h3>
          <div class="row row-cols-1 row-cols-sm-2 row-cols-md-4 g-4">
            <c:forEach items="${related}" var="p">
              <div class="col">
                <div class="bg-transparent h-100 d-flex flex-column">
                  <div class="product-image-wrap shine mb-2">
                    <a href="<c:url value='/product-detail?pid=${p.productID}'/>"
                       class="d-block rounded-4 overflow-hidden">
                      <img src="${p.imageURL}"
                           onerror="this.src='<c:url value="/assets/images/placeholder.png"/>'"
                           alt="${fn:escapeXml(p.productName)}"
                           class="product-image">
                    </a>
                    <div class="quick-actions">
                      <a href="<c:url value='/product-detail?pid=${p.productID}'/>"
                         class="qa-btn"
                         title="Xem">
                        <i class="fas fa-eye"></i>
                      </a>
                      <a href="<c:url value='/cart?action=add&amp;pid=${p.productID}'/>"
                         class="qa-btn"
                         title="Thêm vào giỏ">
                        <i class="fas fa-cart-plus"></i>
                      </a>
                    </div>
                  </div>
                  <c:if test="${not empty p.brand}">
                    <p class="product-brand mb-1">${p.brand}</p>
                  </c:if>
                  <h6 class="fw-normal text-truncate mb-2" title="${p.productName}">
                    ${p.productName}
                  </h6>
                  <div class="mt-auto">
                    <h5 class="fw-normal small text-muted mb-0">
                      <fmt:formatNumber value="${p.price}"
                                        type="currency"
                                        currencyCode="VND"/>
                    </h5>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </section>
      </c:if>
    </c:otherwise>
  </c:choose>
</main>

<jsp:include page="/includes/footer.jsp" />

<script>
  // Đổi ảnh chính khi click thumbnail
  (function() {
    const mainImg = document.getElementById('mainImg');
    if (!mainImg) return;

    const thumbs = document.querySelectorAll('.pd-thumbnail[data-big]');
    thumbs.forEach(function (img) {
      img.addEventListener('click', function () {
        const big = this.getAttribute('data-big');
        if (big) {
          mainImg.src = big;
        }
        // active border
        thumbs.forEach(t => t.classList.remove('active'));
        this.classList.add('active');
      });
    });
  })();
</script>
