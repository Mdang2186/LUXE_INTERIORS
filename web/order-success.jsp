<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="vi_VN"/>

<c:set var="pageTitle" value="Đặt hàng thành công - LUXE INTERIORS" scope="request"/>

<jsp:include page="/includes/header.jsp"/>

<%-- LẤY DỮ LIỆU TỪ request (đã set trong OrderSuccessController) --%>
<c:set var="order"          value="${requestScope.order}" />
<c:set var="items"          value="${requestScope.cartItems}" />
<c:set var="deposit"        value="${requestScope.deposit != null ? requestScope.deposit : 0}" />
<c:set var="remaining"      value="${requestScope.remaining != null ? requestScope.remaining : 0}" />
<c:set var="paymentMethod"  value="${requestScope.paymentMethod}" />
<c:set var="paymentAmount"  value="${requestScope.paymentAmount}" />
<c:set var="paymentNote"    value="${requestScope.paymentNote}" />
<c:set var="paymentQrUrl"   value="${requestScope.paymentQrUrl}" />
<c:set var="ordersQrImgUrl" value="${requestScope.ordersQrImgUrl}" />

<%-- Label phương thức thanh toán --%>
<c:set var="paymentLabel" value="${paymentMethod}" />
<c:choose>
    <c:when test="${paymentMethod eq 'COD'}">
        <c:set var="paymentLabel" value="Thanh toán khi nhận hàng (COD)"/>
    </c:when>
    <c:when test="${paymentMethod eq 'CARD'}">
        <c:set var="paymentLabel" value="Thẻ / Chuyển khoản ngân hàng"/>
    </c:when>
    <c:when test="${paymentMethod eq 'MOMO'}">
        <c:set var="paymentLabel" value="Ví Momo"/>
    </c:when>
    <c:when test="${paymentMethod eq 'VNPAY'}">
        <c:set var="paymentLabel" value="Thanh toán online qua VNPAY"/>
    </c:when>
</c:choose>

<style>
    :root{
        --page-bg:       #ffffff;
        --page-bg-soft:  #fff9e6;
        --card:#ffffff;
        --muted:#6b7280;
        --ink:#1d1a16;
        --gold:#d4af37;
        --gold-soft:#fef7d9;
    }

    /* ÉP TOÀN TRANG ORDER SUCCESS SÁNG, TRẮNG – THẮNG MỌI THEME TỐI */
    html,
    body,
    .page-wrapper,
    main,
    .success-wrap {
        background: radial-gradient(circle at top,
                    var(--page-bg-soft) 0,
                    var(--page-bg) 45%,
                    #ffffff 100%) !important;
        background-color: var(--page-bg) !important;
        color: var(--ink) !important;
    }
    body::before,
    body::after,
    .page-wrapper::before,
    .page-wrapper::after {
        content:none !important;
        background:none !important;
    }

    .success-wrap{
        padding:40px 0 56px;
    }
    .success-layout{
        max-width:1120px;
        margin:0 auto;
    }

    .success-header{
        margin-bottom:22px;
    }
    .success-title{
        font-family:'Playfair Display',serif;
        font-weight:700;
        font-size:2rem;
        color:var(--ink);
        display:flex;
        align-items:center;
        gap:12px;
    }
    .success-pill{
        width:42px;
        height:42px;
        border-radius:999px;
        background:radial-gradient(circle at 30% 20%,#fff7d6,#facc15);
        display:grid;
        place-items:center;
        color:#422006;
        box-shadow:0 0 0 2px #fef9c3,0 10px 30px rgba(234,179,8,0.45);
    }
    .success-sub{
        font-size:.95rem;
        color:var(--muted);
        margin-top:6px;
    }

    .card-main{
        background:var(--card) !important;
        border-radius:22px;
        box-shadow:0 24px 55px rgba(15,23,42,0.08);
        border:1px solid rgba(148,163,184,0.12);
        padding:24px 22px;
    }

    .badge-soft{
        border-radius:999px;
        padding:4px 12px;
        font-size:.78rem;
        background:rgba(15,23,42,0.03);
        color:#4b5563;
    }
    .badge-soft-gold{
        background:rgba(250,204,21,0.12);
        color:#92400e;
        box-shadow:0 0 0 1px rgba(251,191,36,0.4);
    }

    .order-head{
        display:flex;
        flex-wrap:wrap;
        justify-content:space-between;
        gap:10px;
        margin-bottom:16px;
    }
    .order-head-main{
        display:flex;
        flex-direction:column;
        gap:4px;
    }
    .order-code{
        font-weight:600;
        font-size:1rem;
        color:var(--ink);
    }
    .order-meta{
        display:flex;
        flex-wrap:wrap;
        gap:10px;
        font-size:.85rem;
        color:var(--muted);
    }

    .section-title{
        font-weight:600;
        font-size:1rem;
        color:var(--ink);
        margin-bottom:8px;
    }

    .info-block{
        border-radius:16px;
        padding:14px 16px;
        background:linear-gradient(145deg,#ffffff,#fdfaf3);
        border:1px solid rgba(148,163,184,0.16);
        font-size:.9rem;
    }
    .info-row{
        display:flex;
        gap:8px;
        align-items:flex-start;
        margin-bottom:6px;
    }
    .info-label{
        min-width:120px;
        color:var(--muted);
    }
    .info-value{
        color:var(--ink);
        font-weight:500;
    }

    .money-block{
        border-radius:16px;
        padding:14px 16px;
        background:var(--gold-soft);
        border:1px solid rgba(250,204,21,0.45);
        font-size:.9rem;
        color:#78350f;
        box-shadow:0 18px 45px rgba(234,179,8,0.30);
    }
    .money-row{
        display:flex;
        justify-content:space-between;
        margin-bottom:4px;
    }
    .money-row strong{
        font-weight:700;
    }
    .money-row.total{
        margin-top:6px;
        font-size:1rem;
    }

    /* QR CARD – chuyển sang nền sáng vàng nhẹ */
    .qr-card{
        border-radius:18px;
        padding:16px 18px;
        background:linear-gradient(145deg,#ffffff,#fff9e6);
        color:#1f2933;
        position:relative;
        overflow:hidden;
        border:1px solid rgba(212,175,55,0.45);
        box-shadow:0 18px 45px rgba(212,175,55,0.25);
    }
    .qr-card::before{
        content:'';
        position:absolute;
        inset:-40%;
        background:radial-gradient(circle at 0 0,rgba(250,204,21,0.22),transparent 55%),
                   radial-gradient(circle at 100% 100%,rgba(244,244,245,0.5),transparent 55%);
        opacity:0.9;
        pointer-events:none;
    }
    .qr-inner{
        position:relative;
        display:flex;
        flex-wrap:wrap;
        gap:16px;
        align-items:center;
        z-index:2;
    }
    .qr-text-title{
        font-weight:600;
        font-size:1rem;
        margin-bottom:4px;
    }
    .qr-text-sub{
        font-size:.85rem;
        color:#4b5563;
    }
    .qr-note{
        font-size:.8rem;
        color:#6b7280;
        margin-top:8px;
    }
    .qr-img-wrap{
        padding:8px;
        border-radius:18px;
        background:radial-gradient(circle at 30% 10%,#facc15,#f97316);
        box-shadow:0 18px 55px rgba(250,204,21,0.45);
    }
    .qr-img-wrap img{
        display:block;
        border-radius:14px;
        background:#fff;
    }

    .product-list{
        border-radius:16px;
        border:1px solid rgba(148,163,184,0.18);
        background:#fff;
        padding:10px 12px;
        max-height:260px;
        overflow-y:auto;
    }
    .product-row{
        display:flex;
        justify-content:space-between;
        align-items:flex-start;
        font-size:.9rem;
        padding:6px 0;
    }
    .product-row + .product-row{
        border-top:1px solid #f3f4f6;
    }

    .btn-soft{
        border-radius:999px;
        padding:.6rem 1.4rem;
        font-size:.9rem;
    }

    @media (max-width:767.98px){
        .card-main{
            padding:18px 16px;
        }
    }
</style>

<main class="success-wrap">
    <div class="success-layout">

        <c:if test="${order == null}">
            <div class="text-center py-5">
                <div class="mb-3" style="font-size:60px;">🤔</div>
                <h3>Không tìm thấy thông tin đơn hàng</h3>
                <p class="text-muted">
                    Có thể bạn đã tải lại trang hoặc phiên làm việc đã hết hạn.
                </p>
                <a href="<c:url value='/shop'/>" class="btn btn-outline-dark rounded-pill px-4">
                    Quay lại cửa hàng
                </a>
            </div>
        </c:if>

        <c:if test="${order != null}">

            <div class="success-header">
                <div class="success-title">
                    <div class="success-pill">
                        <i class="fa-solid fa-check"></i>
                    </div>
                    <span>Đặt hàng thành công</span>
                </div>
                <div class="success-sub">
                    Cảm ơn bạn đã chọn <strong>LUXE INTERIORS</strong>. Chúng tôi đã ghi nhận đơn hàng và sẽ sớm liên hệ để xác nhận &amp; sắp xếp giao hàng.
                </div>
            </div>

            <div class="card-main">
                <div class="order-head">
                    <div class="order-head-main">
                        <div class="order-code">
                            Mã đơn: #${order.orderID}
                        </div>
                        <div class="order-meta">
                            <span>
                                <i class="fa-regular fa-clock me-1"></i>
                                <fmt:formatDate value="${order.orderDate}" pattern="HH:mm dd/MM/yyyy"/>
                            </span>
                            <span>
                                <i class="fa-solid fa-wallet me-1"></i>
                                <fmt:formatNumber value="${order.totalAmount}" type="currency" currencyCode="VND"/>
                            </span>
                        </div>
                    </div>
                    <div class="d-flex flex-column align-items-end gap-1">
                        <span class="badge-soft badge-soft-gold">
                            ${paymentLabel}
                        </span>
                        <span class="badge-soft">
                            Trạng thái:
                            <strong class="ms-1">${empty order.status ? 'Đang xử lý' : order.status}</strong>
                        </span>
                    </div>
                </div>

                <div class="row g-4 mt-1">
                    <%-- CỘT TRÁI: thông tin giao hàng + tổng tiền + sản phẩm --%>
                    <div class="col-lg-6">
                        <div class="mb-3">
                            <div class="section-title">Thông tin giao hàng</div>
                            <div class="info-block">
                                <div class="info-row">
                                    <div class="info-label">Khách hàng</div>
                                    <div class="info-value">
                                        ${fn:escapeXml(order.shippingAddress)}
                                    </div>
                                </div>
                                <div class="info-row">
                                    <div class="info-label">Thanh toán</div>
                                    <div class="info-value">${paymentLabel}</div>
                                </div>
                                <c:if test="${not empty order.note}">
                                    <div class="info-row">
                                        <div class="info-label">Ghi chú</div>
                                        <div class="info-value" style="white-space:pre-line;">
                                            ${order.note}
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </div>

                        <div class="mb-3">
                            <div class="section-title">Tổng quan thanh toán</div>
                            <div class="money-block">
                                <div class="money-row">
                                    <span>Tổng giá trị đơn hàng</span>
                                    <strong>
                                        <fmt:formatNumber value="${order.totalAmount}" type="currency" currencyCode="VND"/>
                                    </strong>
                                </div>
                                <div class="money-row">
                                    <span>
                                        Số tiền cần thanh toán
                                        <c:if test="${deposit gt 0 && remaining gt 0}">(đặt cọc)</c:if>
                                    </span>
                                    <strong>
                                        <fmt:formatNumber value="${deposit}" type="currency" currencyCode="VND"/>
                                    </strong>
                                </div>
                                <div class="money-row total">
                                    <span>Còn lại thanh toán sau</span>
                                    <strong>
                                        <fmt:formatNumber value="${remaining}" type="currency" currencyCode="VND"/>
                                    </strong>
                                </div>

                                <c:choose>
                                    <c:when test="${deposit gt 0 && remaining gt 0}">
                                        <div class="mt-2" style="font-size:.82rem;">
                                            Vui lòng hoàn tất <strong>số tiền đặt cọc</strong> theo QR / thông tin thanh toán
                                            bên cạnh. Phần còn lại bạn thanh toán khi giao hàng hoặc sau khi lắp đặt xong.
                                        </div>
                                    </c:when>
                                    <c:when test="${remaining le 0}">
                                        <div class="mt-2" style="font-size:.82rem;">
                                            Đơn hàng của bạn đã được <strong>thanh toán 100% online</strong>. Bạn không
                                            cần thanh toán thêm khi nhận hàng, chỉ cần kiểm tra và ký biên bản bàn giao.
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="mt-2" style="font-size:.82rem;">
                                            Bạn sẽ thanh toán toàn bộ cho nhân viên giao hàng theo đúng giá trị đơn hàng.
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div>
                            <div class="section-title">Sản phẩm trong đơn</div>
                            <div class="product-list">
                                <c:forEach items="${items}" var="it">
                                    <div class="product-row">
                                        <div>
                                            <div class="fw-semibold small">
                                                ${fn:escapeXml(it.product.productName)}
                                            </div>
                                            <div class="text-muted small">
                                                SL: ${it.quantity}
                                            </div>
                                        </div>
                                        <div class="fw-semibold small">
                                            <fmt:formatNumber value="${it.totalPrice}" type="currency" currencyCode="VND"/>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>

                    <%-- CỘT PHẢI: QR thanh toán + QR tra cứu đơn + nút hành động --%>
                    <div class="col-lg-6">

                        <c:if test="${not empty paymentQrUrl}">
                            <div class="section-title mb-2">Thanh toán nhanh bằng mã QR</div>
                            <div class="qr-card mb-3">
                                <div class="qr-inner">
                                    <div class="flex-grow-1">
                                        <div class="qr-text-title">
                                            Quét mã bằng ứng dụng ngân hàng / ví điện tử
                                        </div>
                                        <div class="qr-text-sub mb-2">
                                            Số tiền cần chuyển:
                                            <strong>
                                                <fmt:formatNumber value="${paymentAmount}" type="currency" currencyCode="VND"/>
                                            </strong>
                                            <br/>
                                            Nội dung chuyển khoản:
                                            <code>${paymentNote}</code>
                                        </div>

                                        <div class="qr-note">
                                            - Thông tin trên đã được tạo tự động theo <strong>mã đơn #${order.orderID}</strong>.<br/>
                                            - Bạn vẫn nên kiểm tra lại <strong>số tiền</strong> và
                                            <strong>nội dung chuyển khoản</strong> trước khi xác nhận thanh toán.
                                        </div>
                                    </div>
                                    <div class="qr-img-wrap">
                                        <img src="${paymentQrUrl}"
                                             alt="QR thanh toán"
                                             width="220" height="220"/>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <c:if test="${not empty ordersQrImgUrl}">
                            <div class="section-title mb-2">QR tra cứu đơn hàng</div>
                            <div class="qr-card mb-3" style="background:linear-gradient(145deg,#ffffff,#f3f4ff);border-color:rgba(59,130,246,0.35);box-shadow:0 18px 45px rgba(59,130,246,0.18);">
                                <div class="qr-inner">
                                    <div class="flex-grow-1">
                                        <div class="qr-text-title">
                                            Mở nhanh trang lịch sử đơn hàng
                                        </div>
                                        <div class="qr-text-sub">
                                            Quét mã để xem toàn bộ đơn hàng tại LUXE INTERIORS trên điện thoại.
                                        </div>
                                    </div>
                                    <div class="qr-img-wrap" style="background:radial-gradient(circle at 30% 10%,#60a5fa,#4f46e5);">
                                        <img src="${ordersQrImgUrl}"
                                             alt="QR tra cứu đơn hàng"
                                             width="160" height="160"/>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <div class="d-flex flex-wrap gap-2">
                            <a href="<c:url value='/shop'/>" class="btn btn-outline-dark btn-soft">
                                Tiếp tục mua sắm
                            </a>
                            <a href="<c:url value='/orders'/>" class="btn-luxury btn-soft">
                                Xem lịch sử đơn hàng
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>

    </div>
</main>

<jsp:include page="/includes/footer.jsp"/>
