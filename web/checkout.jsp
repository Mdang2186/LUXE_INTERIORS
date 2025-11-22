<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="vi_VN"/>

<c:set var="pageTitle" value="Thanh toán - LUXE INTERIORS" scope="request" />
<jsp:include page="/includes/header.jsp"/>

<c:set var="orderTotal" value="${grandTotal != null ? grandTotal : 0}" />

<style>
    /* ==== NỀN SÁNG RIÊNG CHO TRANG CHECKOUT (KHÔNG PHỤ THUỘC --bg TOÀN SITE) ==== */

    :root{
        /* mấy biến này chỉ dùng cho text, card */
        --card:#ffffff;
        --muted:#6b7280;
        --ink:#1d1a16;
        --gold:#d4af37;
    }

    /* ÉP NỀN SÁNG CHO TOÀN VIEWPORT */
    html,
    body{
        background-color:#fdfcf9 !important;  /* màu nền sáng cố định */
        background-image:none !important;
        color:#1d1a16 !important;
    }

    /* Nếu có wrapper thì cũng ép nền sáng luôn */
    .page-wrapper,
    main,
    .checkout-wrap{
        background-color:#fdfcf9 !important;
    }

    .checkout-wrap{
        padding:40px 0 48px;
    }
    .checkout-header{
        max-width:1120px;
        margin:0 auto 18px;
    }
    .checkout-title-main{
        font-family:'Playfair Display',serif;
        font-weight:700;
        font-size:1.8rem;
        color:#1d1a16;
        margin-bottom:4px;
    }
    .checkout-sub{
        font-size:.95rem;
        color:var(--muted);
    }

    /* Stepper */
    .checkout-steps{
        display:flex;
        align-items:center;
        gap:10px;
        font-size:.85rem;
        color:var(--muted);
        margin-top:12px;
    }
    .step-item{
        display:flex;
        align-items:center;
        gap:6px;
    }
    .step-circle{
        width:22px;
        height:22px;
        border-radius:999px;
        display:grid;
        place-items:center;
        font-size:.75rem;
        border:1px solid #e5e7eb;
        background:#f9fafb;
        color:var(--muted);
    }
    .step-item.active .step-circle{
        background:linear-gradient(135deg,#facc15,#eab308);
        border-color:#d97706;
        color:#422006;
        font-weight:700;
    }
    .step-item.active span{
        color:#1f2937;
        font-weight:600;
    }
    .step-divider{
        flex:1;
        height:1px;
        background:linear-gradient(90deg,#e5e7eb,#facc15,#e5e7eb);
        opacity:.7;
    }

    .checkout-body{
        max-width:1120px;
        margin:0 auto;
    }

    .checkout-card{
        background:#ffffff;
        border-radius:18px;
        box-shadow:0 18px 44px rgba(15,23,42,0.06);
        padding:22px 20px;
        border:1px solid rgba(148,163,184,0.16);
    }
    .checkout-section-title{
        font-family:'Playfair Display',serif;
        font-weight:600;
        font-size:1.25rem;
        color:#1d1a16;
    }

    .summary-row{
        display:flex;
        justify-content:space-between;
        align-items:center;
        font-size:0.95rem;
    }
    .summary-row + .summary-row{margin-top:6px;}
    .summary-row.muted{color:var(--muted);}
    .summary-row.total{
        margin-top:12px;
        font-weight:700;
        font-size:1.05rem;
    }

    .payment-method-card{
        border-radius:14px;
        border:1px solid #e5e7eb;
        padding:12px 14px;
        display:flex;
        align-items:flex-start;
        gap:10px;
        cursor:pointer;
        margin-bottom:10px;
        background:#fff;
        transition:border-color .15s ease,box-shadow .15s ease,background .15s ease,transform .12s ease;
    }
    .payment-method-card:hover{
        transform:translateY(-1px);
        box-shadow:0 12px 32px rgba(15,23,42,0.06);
    }
    .payment-method-card.active{
        border-color:var(--gold);
        box-shadow:0 16px 40px rgba(212,175,55,0.18);
        background:linear-gradient(145deg,#ffffff,#fffaf1);
    }
    .payment-radio{
        margin-top:4px;
    }
    .payment-meta{
        font-size:0.8rem;
        color:var(--muted);
    }
    .payment-extra{
        border-left:3px solid #fbbf24;
        padding-left:12px;
        margin-top:8px;
        display:none;
        animation:fadeIn .18s ease-out;
    }
    .payment-extra.active{display:block;}
    .payment-extra .form-label{
        font-size:0.8rem;
        color:#4b5563;
    }

    .deposit-box{
        border-radius:12px;
        background:#fef9c3;
        padding:10px 12px;
        font-size:0.85rem;
        margin-top:8px;
        color:#854d0e;
    }
    .deposit-box strong{color:#854d0e;}

    .badge-soft{
        border-radius:999px;
        padding:4px 10px;
        font-size:0.75rem;
        background:#f3f4f6;
        color:#374151;
    }

    .mini-note{
        font-size:.78rem;
        color:var(--muted);
        margin-top:4px;
    }

    /* QR preview (dùng ảnh local) */
    .checkout-qr-box{
        margin-top:16px;
        padding:12px 14px;
        border-radius:16px;
        border:1px dashed rgba(148,163,184,0.55);
        background:radial-gradient(circle at top left,#fefce8,#ffffff);
        display:flex;
        gap:12px;
        align-items:center;
    }
    .checkout-qr-img{
        width:120px;
        height:120px;
        border-radius:12px;
        background:#fff;
        padding:6px;
        box-shadow:0 10px 28px rgba(15,23,42,0.16);
        object-fit:contain;
    }
    .checkout-qr-info-title{
        font-size:0.95rem;
        font-weight:600;
        color:#1d1a16;
        margin-bottom:4px;
    }
    .checkout-qr-info p{
        font-size:0.8rem;
        margin-bottom:2px;
        color:var(--muted);
    }
    .checkout-qr-note{
        font-size:0.8rem;
        font-weight:500;
        color:#92400e;
    }

    @keyframes fadeIn{
        from{opacity:0;transform:translateY(4px);}
        to{opacity:1;transform:translateY(0);}
    }

    @media (max-width:991.98px){
        .checkout-card{
            padding:20px 16px;
        }
        .checkout-qr-box{
            flex-direction:column;
            align-items:flex-start;
        }
    }
</style>

<main class="checkout-wrap">
    <div class="checkout-header">
        <div class="checkout-title-main">Thanh toán</div>
        <div class="checkout-sub">
            Hoàn tất thông tin để chúng tôi giao &amp; lắp đặt nội thất cho bạn một cách thuận tiện nhất.
        </div>

        <div class="checkout-steps">
            <div class="step-item">
                <div class="step-circle">1</div>
                <span>Giỏ hàng</span>
            </div>
            <div class="step-divider"></div>
            <div class="step-item active">
                <div class="step-circle">2</div>
                <span>Thanh toán</span>
            </div>
            <div class="step-divider"></div>
            <div class="step-item">
                <div class="step-circle">3</div>
                <span>Hoàn tất</span>
            </div>
        </div>
    </div>

    <div class="checkout-body container">

        <c:if test="${not empty error}">
            <div class="alert alert-danger mb-3 rounded-3 shadow-sm">
                <i class="fa-solid fa-circle-exclamation me-2"></i>${error}
            </div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="alert alert-success mb-3 rounded-3 shadow-sm">
                <i class="fa-solid fa-circle-check me-2"></i>${success}
            </div>
        </c:if>

        <c:if test="${empty items}">
            <div class="text-center py-5">
                <div class="mb-3" style="font-size:60px;">🛒</div>
                <h3>Giỏ hàng trống</h3>
                <p class="text-muted">Vui lòng chọn sản phẩm trước khi thanh toán.</p>
                <a href="<c:url value='/shop'/>" class="btn btn-outline-dark rounded-pill px-4">
                    Quay lại cửa hàng
                </a>
            </div>
        </c:if>

        <c:if test="${not empty items}">
            <%-- Payment hiện tại (từ Controller khi lỗi) --%>
            <c:set var="pay" value="${empty selectedPayment ? 'COD' : selectedPayment}" />

            <form action="<c:url value='/checkout'/>" method="post">
                <input type="hidden" name="sel" value="${sel}" />

                <div class="row g-4">
                    <%-- Cột trái: thông tin nhận hàng + phương thức thanh toán --%>
                    <div class="col-lg-7">
                        <div class="checkout-card mb-3">
                            <div class="mb-3">
                                <div class="checkout-section-title mb-1">Thông tin giao hàng</div>
                                <div class="text-muted small">
                                    Vui lòng điền chính xác để chúng tôi giao &amp; lắp đặt đúng hẹn.
                                </div>
                            </div>

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label small text-muted">Họ và tên *</label>
                                    <input type="text"
                                           name="fullName"
                                           class="form-control rounded-pill"
                                           value="${fn:escapeXml(fullName)}"
                                           required />
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small text-muted">Số điện thoại *</label>
                                    <input type="text"
                                           name="phone"
                                           class="form-control rounded-pill"
                                           value="${fn:escapeXml(phone)}"
                                           required />
                                </div>
                                <div class="col-12">
                                    <label class="form-label small text-muted">Địa chỉ giao hàng *</label>
                                    <input type="text"
                                           name="address"
                                           class="form-control"
                                           value="${fn:escapeXml(address)}"
                                           required />
                                </div>
                                <div class="col-12">
                                    <label class="form-label small text-muted">Ghi chú cho đơn hàng</label>
                                    <textarea name="note"
                                              rows="3"
                                              class="form-control"
                                              placeholder="Ví dụ: thời gian nhận hàng, lưu ý khi giao, lắp đặt...">${fn:escapeXml(param.note)}</textarea>
                                    <div class="mini-note">
                                        Bạn có thể ghi chú thêm về thời gian giao, vị trí lắp đặt, yêu cầu liên hệ trước,...
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="checkout-card">
                            <div class="mb-3">
                                <div class="checkout-section-title mb-1">Phương thức thanh toán</div>
                                <div class="text-muted small">
                                    Chính sách đặt cọc và cách thanh toán sẽ khác nhau theo từng phương thức.
                                </div>
                            </div>

                            <%-- COD: ĐẶT CỌC 50% --%>
                            <label class="payment-method-card ${pay eq 'COD' ? 'active' : ''}">
                                <div class="payment-radio">
                                    <input type="radio"
                                           class="form-check-input payment-method-input"
                                           name="paymentMethod"
                                           value="COD"
                                           ${pay eq 'COD' ? 'checked="checked"' : ''}/>
                                </div>
                                <div>
                                    <div class="d-flex align-items-center gap-2">
                                        <span class="fw-semibold">Thanh toán khi nhận hàng (COD)</span>
                                        <span class="badge-soft">Đặt cọc 50%</span>
                                    </div>
                                    <div class="payment-meta">
                                        Bạn đặt cọc 50% giá trị đơn qua chuyển khoản, phần còn lại thanh toán tiền mặt
                                        cho nhân viên giao hàng sau khi kiểm tra sản phẩm.
                                    </div>
                                    <div class="payment-extra" data-method="COD">
                                        <div class="deposit-box">
                                            <strong>Chính sách:</strong> Đặt cọc trước 50% tổng giá trị đơn hàng.
                                            50% còn lại thanh toán khi giao hàng / hoàn tất lắp đặt.
                                            Sau khi đặt hàng thành công, hệ thống sẽ tạo mã QR thanh toán với
                                            <strong>số tiền đặt cọc</strong> và nội dung theo <strong>mã đơn hàng</strong>.
                                        </div>
                                    </div>
                                </div>
                            </label>

                            <%-- CARD: THANH TOÁN 100% --%>
                            <label class="payment-method-card ${pay eq 'CARD' ? 'active' : ''}">
                                <div class="payment-radio">
                                    <input type="radio"
                                           class="form-check-input payment-method-input"
                                           name="paymentMethod"
                                           value="CARD"
                                           ${pay eq 'CARD' ? 'checked="checked"' : ''}/>
                                </div>
                                <div class="w-100">
                                    <div class="d-flex align-items-center gap-2">
                                        <span class="fw-semibold">Thẻ / Chuyển khoản ngân hàng</span>
                                        <span class="badge-soft">Thanh toán 100%</span>
                                    </div>
                                    <div class="payment-meta">
                                        Thanh toán toàn bộ đơn hàng bằng chuyển khoản ngân hàng trước khi giao.
                                    </div>
                                    <div class="payment-extra" data-method="CARD">
                                        <div class="row g-2">
                                            <div class="col-md-6">
                                                <label class="form-label small">Số thẻ / Số tài khoản *</label>
                                                <input type="text"
                                                       name="cardNumber"
                                                       class="form-control"
                                                       value="${fn:escapeXml(param.cardNumber)}" />
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label small">Ngân hàng *</label>
                                                <input type="text"
                                                       name="bankName"
                                                       class="form-control"
                                                       value="${fn:escapeXml(param.bankName)}" />
                                            </div>
                                        </div>
                                        <div class="deposit-box mt-2">
                                            <strong>Chính sách:</strong> Thanh toán online 100% giá trị đơn hàng.
                                            Sau khi đặt hàng, bạn sẽ nhận email kèm mã QR / thông tin chuyển khoản
                                            chi tiết theo mã đơn.
                                        </div>
                                    </div>
                                </div>
                            </label>

                            <%-- MOMO: THANH TOÁN 100% --%>
                            <label class="payment-method-card ${pay eq 'MOMO' ? 'active' : ''}">
                                <div class="payment-radio">
                                    <input type="radio"
                                           class="form-check-input payment-method-input"
                                           name="paymentMethod"
                                           value="MOMO"
                                           ${pay eq 'MOMO' ? 'checked="checked"' : ''}/>
                                </div>
                                <div class="w-100">
                                    <div class="d-flex align-items-center gap-2">
                                        <span class="fw-semibold">Ví Momo</span>
                                        <span class="badge-soft">Thanh toán 100%</span>
                                    </div>
                                    <div class="payment-meta">
                                        Thanh toán nhanh toàn bộ đơn hàng qua ví Momo.
                                    </div>
                                    <div class="payment-extra" data-method="MOMO">
                                        <div class="row g-2">
                                            <div class="col-md-6">
                                                <label class="form-label small">Số điện thoại Momo *</label>
                                                <input type="text"
                                                       name="momoPhone"
                                                       class="form-control"
                                                       value="${fn:escapeXml(param.momoPhone)}" />
                                            </div>
                                        </div>
                                        <div class="deposit-box mt-2">
                                            <strong>Chính sách:</strong> Thanh toán 100% qua ví Momo.
                                            Chúng tôi sẽ xác nhận và tiến hành giao hàng sau khi hệ thống ghi nhận giao dịch.
                                        </div>
                                    </div>
                                </div>
                            </label>

                            <%-- VNPAY: THANH TOÁN 100% --%>
                            <label class="payment-method-card ${pay eq 'VNPAY' ? 'active' : ''}">
                                <div class="payment-radio">
                                    <input type="radio"
                                           class="form-check-input payment-method-input"
                                           name="paymentMethod"
                                           value="VNPAY"
                                           ${pay eq 'VNPAY' ? 'checked="checked"' : ''}/>
                                </div>
                                <div class="w-100">
                                    <div class="d-flex align-items-center gap-2">
                                        <span class="fw-semibold">Thanh toán online qua VNPAY</span>
                                        <span class="badge-soft">Thanh toán 100%</span>
                                    </div>
                                    <div class="payment-meta">
                                        Thanh toán toàn bộ giá trị đơn hàng qua cổng VNPAY một cách an toàn &amp; nhanh chóng.
                                    </div>
                                    <div class="payment-extra" data-method="VNPAY">
                                        <div class="row g-2">
                                            <div class="col-md-8">
                                                <label class="form-label small">
                                                    Mã giao dịch VNPAY (nếu đã có, có thể bỏ trống)
                                                </label>
                                                <input type="text"
                                                       name="vnpayTxn"
                                                       class="form-control"
                                                       value="${fn:escapeXml(param.vnpayTxn)}" />
                                            </div>
                                        </div>
                                        <div class="deposit-box mt-2">
                                            <strong>Chính sách:</strong> Thanh toán 100% online.
                                            Đơn hàng sẽ được xử lý ngay sau khi VNPAY xác nhận giao dịch thành công.
                                        </div>
                                    </div>
                                </div>
                            </label>
                        </div>
                    </div>

                    <%-- Cột phải: tóm tắt đơn hàng & QR preview --%>
                    <div class="col-lg-5">
                        <div class="checkout-card">
                            <div class="mb-3 d-flex justify-content-between align-items-center">
                                <div class="checkout-section-title mb-0">Đơn hàng của bạn</div>
                                <span class="badge-soft">${fn:length(items)} sản phẩm</span>
                            </div>

                            <div class="mb-3" style="max-height:260px;overflow-y:auto;">
                                <c:forEach items="${items}" var="it" varStatus="st">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <div>
                                            <div class="small fw-semibold">
                                                ${fn:escapeXml(it.product.productName)}
                                            </div>
                                            <div class="small text-muted">
                                                SL: ${it.quantity}
                                            </div>
                                        </div>
                                        <div class="small fw-semibold">
                                            <fmt:formatNumber value="${it.totalPrice}" type="currency" currencyCode="VND"/>
                                        </div>
                                    </div>
                                    <c:if test="${!st.last}">
                                        <hr class="my-2" />
                                    </c:if>
                                </c:forEach>
                            </div>

                            <div class="summary-row muted">
                                <span>Tạm tính</span>
                                <span>
                                    <fmt:formatNumber value="${orderTotal}" type="currency" currencyCode="VND"/>
                                </span>
                            </div>
                            <div class="summary-row muted">
                                <span>Phí vận chuyển</span>
                                <span>Miễn phí</span>
                            </div>
                            <div class="summary-row total">
                                <span>Tổng tiền</span>
                                <span>
                                    <fmt:formatNumber value="${orderTotal}" type="currency" currencyCode="VND"/>
                                </span>
                            </div>

                            <hr class="my-3" />

                            <div class="summary-row">
                                <span>Đặt cọc (theo phương thức)</span>
                                <strong id="depositAmount">0 ₫</strong>
                            </div>
                            <div class="summary-row muted">
                                <span>Còn lại thanh toán sau</span>
                                <strong id="remainingAmount">
                                    <fmt:formatNumber value="${orderTotal}" type="currency" currencyCode="VND"/>
                                </strong>
                            </div>

                            <%-- QR preview: dùng ảnh local, text động --%>
                            <div id="qrPreviewBox" class="checkout-qr-box d-none">
                                <img id="qrPreviewImg"
                                     src="<c:url value='/assets/images/QRthanhtoan/QRthanhtoan.png'/>"
                                     alt="QR thanh toán"
                                     class="checkout-qr-img" />
                                <div class="checkout-qr-info">
                                    <div class="checkout-qr-info-title">
                                        Mã QR thanh toán chuyển khoản (minh họa)
                                    </div>
                                    <p>Ngân hàng: <strong>MB Bank (Napas)</strong></p>
                                    <p>STK: <strong>0123456789</strong> — Chủ TK: <strong>LUXE INTERIORS CO., LTD</strong></p>
                                    <p class="checkout-qr-note">
                                        Số tiền dự kiến: <span id="qrAmountText"></span> • Nội dung: <span id="qrNoteText"></span>
                                    </p>
                                    <p class="small text-muted mb-0">
                                        Đây là ảnh QR minh hoạ. Sau khi đặt hàng, hệ thống sẽ tạo mã QR thanh toán
                                        chính xác theo số tiền &amp; mã đơn hàng của bạn.
                                    </p>
                                </div>
                            </div>

                            <button type="submit"
                                    class="btn-luxury w-100 mt-3">
                                Xác nhận đặt hàng
                            </button>

                            <div class="mt-2 small text-muted">
                                Sau khi đặt hàng thành công, bạn sẽ nhận email xác nhận kèm
                                <strong>mã QR thanh toán</strong> và chi tiết đơn hàng.
                            </div>
                            <div class="mt-1 small text-muted">
                                Bằng cách đặt hàng, bạn đồng ý với
                                <a href="<c:url value='/policy/terms'/>" class="text-decoration-none">
                                    Điều khoản &amp; chính sách
                                </a>
                                của LUXE INTERIORS.
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </c:if>

    </div>
</main>

<jsp:include page="/includes/footer.jsp"/>

<script>
  (function () {
    const TOTAL = parseFloat('${orderTotal}');
    const DEPOSIT_CONFIG = {
      'COD':   0.5,
      'CARD':  1.0,
      'MOMO':  1.0,
      'VNPAY': 1.0
    };

    const radios = document.querySelectorAll('.payment-method-input');
    const cards  = document.querySelectorAll('.payment-method-card');
    const extras = document.querySelectorAll('.payment-extra');
    const depEl  = document.getElementById('depositAmount');
    const remEl  = document.getElementById('remainingAmount');

    const qrBox       = document.getElementById('qrPreviewBox');
    const qrAmountTxt = document.getElementById('qrAmountText');
    const qrNoteTxt   = document.getElementById('qrNoteText');

    const fullNameInput = document.querySelector('input[name="fullName"]');
    const phoneInput    = document.querySelector('input[name="phone"]');

    function formatVnd(v) {
      if (isNaN(v)) return '0 ₫';
      return v.toLocaleString('vi-VN') + ' ₫';
    }

    function calcDeposit(method) {
      const rate = DEPOSIT_CONFIG[method] ?? 0;
      return Math.round(TOTAL * rate);
    }

    function updateDeposit(method) {
      const deposit   = calcDeposit(method);
      const remaining = Math.round(TOTAL - deposit);
      depEl.textContent = formatVnd(deposit);
      remEl.textContent = formatVnd(remaining);
      return { deposit, remaining };
    }

    // Bỏ dấu tiếng Việt + ký tự lạ
    function normalizeName(str) {
      if (!str) return '';
      return str
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/[^0-9A-Za-z ]/g, '')
        .toUpperCase()
        .trim();
    }

    // Chuỗi nội dung chuyển khoản minh hoạ
    function buildPreviewNote(method, deposit) {
      let methodCode;
      switch ((method || '').toUpperCase()) {
        case 'COD':
          methodCode = (deposit < TOTAL) ? 'COD50' : 'COD';
          break;
        case 'CARD':
          methodCode = 'CARD100';
          break;
        case 'MOMO':
          methodCode = 'MOMO100';
          break;
        case 'VNPAY':
          methodCode = 'VNPAY100';
          break;
        default:
          methodCode = 'PAY';
      }

      const rawPhone = phoneInput ? phoneInput.value : '';
      const phone    = rawPhone ? rawPhone.replace(/\D+/g, '') : '';

      let name = fullNameInput ? normalizeName(fullNameInput.value) : '';
      if (name.length > 18) {
        name = name.substring(0, 18);
      }

      let note = 'LUXE ' + methodCode;
      if (phone) note += ' ' + phone;
      if (name)  note += ' ' + name;

      if (note.length > 60) {
        note = note.substring(0, 60);
      }
      return note;
    }

    function updateQr(method) {
      if (!qrBox) return;

      // Chỉ minh hoạ cho COD & CARD (chuyển khoản ngân hàng)
      if (method !== 'COD' && method !== 'CARD') {
        qrBox.classList.add('d-none');
        return;
      }

      const deposit = calcDeposit(method);
      if (!deposit || deposit <= 0) {
        qrBox.classList.add('d-none');
        return;
      }

      const notePlain = buildPreviewNote(method, deposit);
      qrAmountTxt.textContent = formatVnd(deposit);
      qrNoteTxt.textContent   = notePlain;
      qrBox.classList.remove('d-none');
    }

    function syncUI(method) {
      cards.forEach(card => {
        const input = card.querySelector('.payment-method-input');
        if (!input) return;
        if (input.value === method) {
          card.classList.add('active');
        } else {
          card.classList.remove('active');
        }
      });

      extras.forEach(block => {
        if (block.dataset.method === method) {
          block.classList.add('active');
        } else {
          block.classList.remove('active');
        }
      });

      updateDeposit(method);
      updateQr(method);
    }

    let currentMethod;
    const checked = document.querySelector('.payment-method-input:checked');
    currentMethod = checked ? checked.value : 'COD';
    syncUI(currentMethod);

    radios.forEach(r => {
      r.addEventListener('change', function () {
        currentMethod = this.value;
        syncUI(currentMethod);
      });
    });

    if (fullNameInput) {
      fullNameInput.addEventListener('input', function () {
        updateQr(currentMethod);
      });
    }
    if (phoneInput) {
      phoneInput.addEventListener('input', function () {
        updateQr(currentMethod);
      });
    }
  })();
</script>
