<%-- cart.jsp – Giỏ hàng (neon vàng, nền trắng, đồng bộ LUXE INTERIORS) --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="vi_VN"/>

<c:set var="pageTitle" value="Giỏ hàng - LUXE INTERIORS" scope="request"/>
<jsp:include page="/includes/header.jsp" />

<style>
  :root {
    --lux-bg:       #ffffff;
    --lux-bg-soft:  #fff9e6;
    --lux-ink:      #111827;
    --lux-muted:    #6b7280;
    --lux-gold:     #facc15;
    --lux-gold-strong: #eab308;
    --lux-gold-deep:   #b45309;
    --lux-border:   #e5e7eb;
  }

  /* ÉP NỀN TRẮNG + VÀNG NEON TOÀN TRANG GIỎ HÀNG */
  html,
  body,
  .page-wrapper,
  main,
  .cart-page {
    background:
      radial-gradient(circle at top, var(--lux-bg-soft) 0, #ffffff 45%, #ffffff 100%) !important;
    background-color: var(--lux-bg) !important;
    color: var(--lux-ink) !important;
  }
  body::before,
  body::after,
  .page-wrapper::before,
  .page-wrapper::after {
    content:none !important;
    background:none !important;
  }

  /* Trang giỏ hàng */
  .cart-page {
    padding: 40px 0 60px;
  }

  .cart-shell {
    max-width: 1180px;
    margin: 0 auto;
    display: grid;
    grid-template-columns: minmax(0, 2.1fr) minmax(320px, 1fr);
    gap: 24px;
    align-items: flex-start;
  }

  .cart-main {
    min-width: 0;
  }

  .cart-summary {
    position: sticky;
    top: 96px;
    height: fit-content;
  }

  /* Header giỏ hàng */
  .cart-title {
    font-family: "Playfair Display", serif;
    font-size: 2rem;
    font-weight: 700;
    margin-bottom: 4px;
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .cart-title-pill {
    width: 42px;
    height: 42px;
    border-radius: 999px;
    background: radial-gradient(circle at 30% 20%, #fff7d6, var(--lux-gold));
    display: grid;
    place-items: center;
    color: #422006;
    box-shadow: 0 0 0 2px #fef9c3, 0 10px 30px rgba(234, 179, 8, 0.5);
  }

  .cart-sub {
    font-size: 0.95rem;
    color: var(--lux-muted);
    margin-bottom: 18px;
  }

  /* Toolbar trên list sản phẩm */
  .cart-toolbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin-bottom: 14px;
    font-size: 0.9rem;
  }

  .cart-toolbar-left {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
  }

  .cart-toolbar label {
    display: flex;
    align-items: center;
    gap: 6px;
    cursor: pointer;
    color: var(--lux-muted);
  }

  .cart-toolbar input[type="checkbox"] {
    width: 18px;
    height: 18px;
    accent-color: var(--lux-gold-strong);
  }

  .cart-count-pill {
    padding: 4px 10px;
    border-radius: 999px;
    background-color: rgba(250, 204, 21, 0.08);
    border: 1px solid rgba(250, 204, 21, 0.5);
    font-size: 0.8rem;
    color: #854d0e;
  }

  .btn-ghost-light {
    border-radius: 999px;
    border: 1px solid var(--lux-border);
    background-color: #ffffff;
    padding: 0.4rem 0.9rem;
    font-size: 0.85rem;
    color: var(--lux-ink);
    display: inline-flex;
    align-items: center;
    gap: 6px;
    transition: all 0.18s ease;
  }

  .btn-ghost-light:hover {
    background: linear-gradient(135deg, #fff7d6, #fffbeb);
    border-color: rgba(250, 204, 21, 0.7);
    box-shadow: 0 10px 25px rgba(250, 204, 21, 0.35);
    transform: translateY(-1px);
  }

  /* Card danh sách sản phẩm */
  .cart-items-card {
    background-color: #ffffff;
    border-radius: 20px;
    border: 1px solid rgba(226, 232, 240, 0.9);
    box-shadow: 0 16px 48px rgba(15, 23, 42, 0.08);
    overflow: hidden;
    position: relative;
  }

  .cart-items-card::before {
    content: "";
    position: absolute;
    inset: 0;
    background: linear-gradient(135deg, rgba(250, 204, 21, 0.16), transparent 55%);
    opacity: 0.45;
    pointer-events: none;
  }

  #cartItems {
    position: relative;
    max-height: calc(75vh - 80px);
    overflow-y: auto;
    z-index: 1;
  }

  .cart-empty {
    padding: 40px 24px;
    text-align: center;
    color: var(--lux-muted);
  }

  /* Item trong giỏ */
  .cart-item {
    display: grid;
    grid-template-columns: auto 120px minmax(0, 1.6fr) auto;
    gap: 12px 16px;
    align-items: flex-start;
    padding: 14px 18px;
    border-bottom: 1px solid #f3f4f6;
    background-color: rgba(255, 255, 255, 0.9);
    transition: background-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease;
  }

  .cart-item:last-child {
    border-bottom: none;
  }

  .cart-item:hover {
    background-color: #fffbeb;
  }

  .cart-item.is-selected {
    background: radial-gradient(circle at top left, #fef9c3, #fffbeb);
    box-shadow: 0 14px 40px rgba(250, 204, 21, 0.45);
    transform: translateY(-1px);
  }

  .item-select {
    margin-top: 8px;
    cursor: pointer;
    accent-color: var(--lux-gold-strong);
  }

  .thumb {
    width: 120px;
    height: 90px;
    border-radius: 14px;
    overflow: hidden;
    background-color: #f3f4f6;
    box-shadow: 0 7px 20px rgba(15, 23, 42, 0.12);
  }

  .thumb img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
  }

  .info {
    min-width: 0;
  }

  .info h5 {
    margin: 0 0 4px 0;
    font-size: 1rem;
    font-weight: 600;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .info-meta {
    font-size: 0.85rem;
    color: var(--lux-muted);
  }

  .info-actions {
    margin-top: 10px;
    display: flex;
    flex-wrap: wrap;
    gap: 8px 12px;
    align-items: center;
  }

  /* Quantity */
  .qty-group {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 4px 8px;
    border-radius: 999px;
    background-color: #f3f4ff;
    border: 1px solid #e0e7ff;
    box-shadow: 0 6px 16px rgba(129, 140, 248, 0.2);
  }

  .qty-btn {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    border: none;
    background: radial-gradient(circle at 30% 20%, #fff7d6, var(--lux-gold));
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1rem;
    cursor: pointer;
    color: #422006;
    box-shadow: 0 8px 18px rgba(250, 204, 21, 0.5);
    transition: transform 0.12s ease, box-shadow 0.12s ease, filter 0.12s ease;
  }

  .qty-btn:hover {
    transform: translateY(-1px);
    filter: brightness(1.02);
    box-shadow: 0 10px 22px rgba(250, 204, 21, 0.6);
  }

  .qty-group input[type="number"] {
    width: 52px;
    border-radius: 999px;
    border: 1px solid transparent;
    background-color: transparent;
    text-align: center;
    font-size: 0.9rem;
    font-weight: 500;
    color: var(--lux-ink);
  }

  .line-actions form {
    display: inline-block;
  }

  /* Giá */
  .price-block {
    text-align: right;
    font-size: 0.9rem;
  }

  .price-block .price {
    font-weight: 700;
    font-size: 1rem;
    background: linear-gradient(135deg, #f97316, #facc15);
    -webkit-background-clip: text;
    color: transparent;
  }

  .price-block .line-total {
    margin-top: 2px;
    font-size: 0.8rem;
    color: var(--lux-muted);
  }

  /* Card tổng kết */
  .cart-summary-card {
    background-color: #ffffff;
    border-radius: 22px;
    border: 1px solid rgba(226, 232, 240, 0.9);
    box-shadow: 0 20px 60px rgba(15, 23, 42, 0.12);
    padding: 20px 20px 22px;
    position: relative;
    overflow: hidden;
  }

  .cart-summary-card::before {
    content: "";
    position: absolute;
    inset: -40%;
    background:
      radial-gradient(circle at 0 0, rgba(250, 204, 21, 0.2), transparent 55%),
      radial-gradient(circle at 100% 100%, rgba(56, 189, 248, 0.15), transparent 55%);
    opacity: 0.9;
    pointer-events: none;
  }

  .cart-summary-inner {
    position: relative;
    z-index: 2;
  }

  .cart-summary-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
  }

  .cart-summary-title {
    font-size: 1.1rem;
    font-weight: 700;
    margin: 0;
  }

  .summary-tag {
    font-size: 0.8rem;
    padding: 4px 10px;
    border-radius: 999px;
    background-color: rgba(15, 23, 42, 0.04);
    color: var(--lux-muted);
  }

  .summary-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 0.9rem;
    margin-bottom: 4px;
    color: var(--lux-muted);
  }

  .summary-row strong {
    color: var(--lux-ink);
  }

  .summary-total {
    font-size: 1.15rem;
    font-weight: 800;
    background: linear-gradient(135deg, #f97316, #facc15);
    -webkit-background-clip: text;
    color: transparent;
  }

  .summary-note {
    font-size: 0.8rem;
    color: var(--lux-muted);
    margin-top: 6px;
  }

  /* Nút chính: neon vàng đồng bộ */
  #checkoutSelectedBtn {
    border-radius: 999px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    padding: 0.7rem 1.4rem;
  }

  .btn-checkout {
    background: linear-gradient(135deg, #ffde9e, #facc15, #f97316);
    border: none;
    color: #2b1605;
    box-shadow: 0 18px 40px rgba(249, 115, 22, 0.4);
    transition: transform 0.15s ease, box-shadow 0.15s ease, filter 0.15s ease;
  }

  .btn-checkout:hover:not(:disabled) {
    transform: translateY(-1px);
    filter: brightness(1.03);
    box-shadow: 0 22px 55px rgba(249, 115, 22, 0.55);
  }

  .btn-checkout:disabled {
    opacity: 0.55;
    cursor: not-allowed;
    box-shadow: none;
  }

  .btn-outline-secondary {
    border-radius: 999px;
    border-color: rgba(148, 163, 184, 0.8);
    color: var(--lux-muted);
    background: #ffffff;
    transition: all 0.15s ease;
  }

  .btn-outline-secondary:hover {
    border-color: rgba(148, 163, 184, 1);
    background: #f9fafb;
    color: var(--lux-ink);
  }

  @media (max-width: 991.98px) {
    .cart-shell {
      grid-template-columns: minmax(0, 1fr);
      padding: 0 1rem;
    }
    .cart-summary {
      position: static;
      width: 100%;
    }
  }

  @media (max-width: 575.98px) {
    .cart-item {
      grid-template-columns: auto 90px minmax(0, 1fr);
      grid-template-rows: auto auto;
    }
    .price-block {
      grid-column: 3 / 4;
      text-align: left;
      margin-top: 4px;
    }
  }
</style>

<main class="cart-page">
  <div class="cart-shell">
    <!-- CỘT TRÁI: DANH SÁCH SẢN PHẨM -->
    <section class="cart-main">
      <h1 class="cart-title">
        <span class="cart-title-pill">
          <i class="fa-solid fa-bag-shopping"></i>
        </span>
        <span>Giỏ hàng của bạn</span>
      </h1>
      <p class="cart-sub">Chọn sản phẩm muốn đặt và điều chỉnh số lượng trước khi thanh toán.</p>

      <div class="cart-toolbar">
        <div class="cart-toolbar-left">
          <label>
            <input id="selectAll" type="checkbox" />
            <span>Chọn tất cả sản phẩm</span>
          </label>
          <span class="cart-count-pill">
            Đang chọn: <span id="selectedCount">0</span> sản phẩm
          </span>
        </div>
        <a class="btn-ghost-light" href="<c:url value='/shop'/>">
          <i class="fa-solid fa-plus"></i>
          <span>Tiếp tục mua sắm</span>
        </a>
      </div>

      <div class="cart-items-card">
        <div id="cartItems" role="list">
          <c:choose>
            <c:when test="${not empty sessionScope.cart}">
              <c:forEach var="ci" items="${sessionScope.cart}">
                <%-- ci: CartItem --%>
                <div class="cart-item" data-pid="${ci.product.productID}">
                  <input class="item-select" type="checkbox" aria-label="Chọn sản phẩm" />

                  <div class="thumb">
                    <a href="<c:url value='/product-detail?pid=${ci.product.productID}'/>">
                      <img src="${ci.product.imageURL}"
                           alt="${fn:escapeXml(ci.product.productName)}"
                           onerror="this.src='<c:url value="/assets/images/placeholder.png"/>'" />
                    </a>
                  </div>

                  <div class="info">
                    <h5 title="${ci.product.productName}">${ci.product.productName}</h5>
                    <div class="info-meta">
                      <c:if test="${not empty ci.product.brand}">
                        ${ci.product.brand}
                        <c:if test="${not empty ci.product.material}"> • </c:if>
                      </c:if>
                      <c:if test="${not empty ci.product.material}">
                        ${ci.product.material}
                      </c:if>
                    </div>

                    <div class="info-actions">
                      <div class="qty-group">
                        <button type="button" class="qty-btn btn-decrease" title="Giảm">−</button>
                        <input type="number" name="quantity" min="1" value="${ci.quantity}" />
                        <button type="button" class="qty-btn btn-increase" title="Tăng">+</button>
                      </div>

                      <div class="line-actions">
                        <form action="<c:url value='/cart'/>" method="post">
                          <input type="hidden" name="action" value="update" />
                          <input type="hidden" name="pid" value="${ci.product.productID}" />
                          <input type="hidden" name="quantityToUpdate" value="${ci.quantity}" class="hidden-qty" />
                        </form>

                        <form action="<c:url value='/cart'/>" method="post">
                          <input type="hidden" name="action" value="remove" />
                          <input type="hidden" name="pid" value="${ci.product.productID}" />
                          <button class="btn btn-sm btn-outline-danger ms-1" title="Xóa sản phẩm">
                            <i class="fa-regular fa-trash-can"></i>
                          </button>
                        </form>
                      </div>
                    </div>
                  </div>

                  <div class="price-block">
                    <div class="price price-value" data-price="${ci.product.price}">
                      <fmt:formatNumber value="${ci.product.price}" type="currency" currencyCode="VND" />
                    </div>
                    <div class="line-total">
                      (<fmt:formatNumber value="${ci.quantity}" type="number" /> ×
                      <fmt:formatNumber value="${ci.product.price}" type="currency" currencyCode="VND" />)
                    </div>
                  </div>
                </div>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <div class="cart-empty">
                <div class="mb-3" style="font-size: 48px;">📦</div>
                <h5 class="mb-2">Giỏ hàng của bạn đang trống</h5>
                <p class="mb-3">Thêm vài món nội thất để không gian sống trở nên ấn tượng hơn.</p>
                <a class="btn btn-checkout rounded-pill px-4" href="<c:url value='/shop'/>">
                  Bắt đầu mua sắm
                </a>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </section>

    <!-- CỘT PHẢI: TÓM TẮT ĐƠN HÀNG -->
    <aside class="cart-summary">
      <div class="cart-summary-card">
        <div class="cart-summary-inner">
          <div class="cart-summary-head">
            <h4 class="cart-summary-title">Tổng kết đơn hàng</h4>
            <span class="summary-tag">
              Đã chọn: <span id="summarySelectedCount">0</span> sp
            </span>
          </div>

          <div class="summary-row">
            <span>Tạm tính</span>
            <span id="selectedSubtotal">0 ₫</span>
          </div>

          <div class="summary-row">
            <span>Phí vận chuyển</span>
            <span><span class="badge bg-success">Miễn phí</span></span>
          </div>

          <hr class="my-2" />

          <div class="summary-row">
            <span><strong>Tổng cộng</strong></span>
            <span id="finalTotal" class="summary-total">0 ₫</span>
          </div>

          <p class="summary-note">
            Sau khi đặt hàng, đội ngũ LUXE INTERIORS sẽ liên hệ để xác nhận và sắp xếp thời gian giao &amp; lắp đặt.
          </p>

          <div class="mt-3 d-flex flex-column gap-2">
            <button id="checkoutSelectedBtn"
                    class="btn btn-checkout w-100"
                    disabled>
              TIẾN HÀNH ĐẶT HÀNG
            </button>
            <a class="btn btn-outline-secondary w-100" href="<c:url value='/shop'/>">
              Tiếp tục mua sắm
            </a>
          </div>
        </div>
      </div>
    </aside>
  </div>
</main>

<jsp:include page="/includes/footer.jsp" />

<script>
(function () {
  const ctx = '${pageContext.request.contextPath}';

  function setSizing() {
    try {
      const footerEl = document.querySelector('.footer-luxe') || document.querySelector('footer');
      const headerEl = document.querySelector('header');
      const cartItems = document.getElementById('cartItems');
      const headerH = headerEl ? headerEl.getBoundingClientRect().height : 0;
      const footerH = footerEl ? footerEl.getBoundingClientRect().height : 0;

      if (footerEl) {
        document.body.style.paddingBottom = (footerH + 12) + 'px';
      }
      if (cartItems) {
        const available = window.innerHeight - headerH - footerH - 200;
        cartItems.style.maxHeight = Math.max(260, available) + 'px';
      }
    } catch (e) {
      console.warn('setSizing error', e);
    }
  }

  function formatVND(num) {
    try {
      return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(num);
    } catch (e) {
      return num + ' ₫';
    }
  }

  function recalcSelection() {
    const rows = document.querySelectorAll('.cart-item');
    let subtotal = 0;
    const selected = [];

    rows.forEach(row => {
      const priceAttr = row.querySelector('.price-value')?.dataset?.price;
      const price = priceAttr ? parseFloat(priceAttr) : 0;
      const qtyInput = row.querySelector('input[name="quantity"]');
      const qty = qtyInput ? parseInt(qtyInput.value || '1', 10) : 1;
      const checkbox = row.querySelector('.item-select');

      if (checkbox && checkbox.checked) {
        subtotal += price * qty;
        selected.push(row.dataset.pid);
        row.classList.add('is-selected');
      } else {
        row.classList.remove('is-selected');
      }
    });

    document.getElementById('selectedSubtotal').innerText = formatVND(subtotal);
    document.getElementById('finalTotal').innerText = formatVND(subtotal);

    const count = selected.length;
    const selectedCount = document.getElementById('selectedCount');
    const summarySelectedCount = document.getElementById('summarySelectedCount');
    if (selectedCount) selectedCount.textContent = count;
    if (summarySelectedCount) summarySelectedCount.textContent = count;

    const btn = document.getElementById('checkoutSelectedBtn');
    btn.disabled = selected.length === 0;

    window._selectedPids = selected;
  }

  window.addEventListener('load', function () {
    setTimeout(setSizing, 80);
    setTimeout(setSizing, 300);
    recalcSelection();
  });
  window.addEventListener('resize', setSizing);

  document.addEventListener('change', function (e) {
    if (e.target.matches('.item-select') || e.target.matches('input[name="quantity"]')) {
      const row = e.target.closest('.cart-item');
      if (row) {
        const qtyInput = row.querySelector('input[name="quantity"]');
        const hidden = row.querySelector('.hidden-qty');
        if (qtyInput && hidden) {
          hidden.value = qtyInput.value;
        }
      }
      recalcSelection();
    }
  });

  document.addEventListener('click', function (e) {
    if (e.target.closest('.btn-increase')) {
      const btn = e.target.closest('.btn-increase');
      const row = btn.closest('.cart-item');
      const input = row.querySelector('input[name="quantity"]');
      if (input) {
        input.value = Math.max(1, parseInt(input.value || '1', 10) + 1);
      }
      const hidden = row.querySelector('.hidden-qty');
      if (hidden) {
        hidden.value = input.value;
      }
      recalcSelection();
    }

    if (e.target.closest('.btn-decrease')) {
      const btn = e.target.closest('.btn-decrease');
      const row = btn.closest('.cart-item');
      const input = row.querySelector('input[name="quantity"]');
      if (input) {
        input.value = Math.max(1, parseInt(input.value || '1', 10) - 1);
      }
      const hidden = row.querySelector('.hidden-qty');
      if (hidden) {
        hidden.value = input.value;
      }
      recalcSelection();
    }
  });

  // Chọn tất cả
  const selectAll = document.getElementById('selectAll');
  if (selectAll) {
    selectAll.addEventListener('change', function () {
      const checked = this.checked;
      document.querySelectorAll('.item-select').forEach(cb => cb.checked = checked);
      recalcSelection();
    });
  }

  // Đi tới trang checkout với danh sách pid đã chọn
  const checkoutBtn = document.getElementById('checkoutSelectedBtn');
  if (checkoutBtn) {
    checkoutBtn.addEventListener('click', function (e) {
      e.preventDefault();
      const selected = window._selectedPids || [];
      if (selected.length === 0) return;
      const selParam = selected.join(',');
      window.location.href = ctx + '/checkout?sel=' + encodeURIComponent(selParam);
    });
  }
})();
</script>
