<%-- orders.jsp – Lịch sử đơn hàng (layout sáng, khoa học, đồng bộ LUXE INTERIORS) --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN"/>

<c:set var="pageTitle" value="Lịch sử đơn hàng - LUXE INTERIORS" scope="request"/>
<jsp:include page="/includes/header.jsp" />

<style>
    :root{
        --bg-page:#fdfcf9;
        --card:#ffffff;
        --muted:#6b7280;
        --ink:#1f2933;
        --gold:#d4af37;
        --border:#e5e7eb;
    }

    body{
        background:var(--bg-page);
        color:var(--ink);
    }

    .orders-page{
        padding:40px 0 56px;
        background:
          radial-gradient(900px 600px at top left, rgba(250,204,21,0.12), transparent 60%),
          var(--bg-page);
    }
    .orders-shell{
        max-width:1120px;
        margin:0 auto;
    }

    /* Header */
    .orders-header{
        display:flex;
        justify-content:space-between;
        align-items:flex-end;
        gap:12px;
        margin-bottom:18px;
    }
    .orders-header-title{
        font-family:'Playfair Display',serif;
        font-weight:700;
        font-size:1.9rem;
        color:var(--ink);
        margin-bottom:4px;
    }
    .orders-header-sub{
        color:var(--muted);
        font-size:0.95rem;
    }

    /* Legend trạng thái */
    .orders-legend{
        display:flex;
        flex-wrap:wrap;
        gap:8px;
        margin-bottom:20px;
        font-size:.78rem;
        color:var(--muted);
    }
    .orders-legend-item{
        display:inline-flex;
        align-items:center;
        gap:6px;
        padding:4px 10px;
        border-radius:999px;
        background:#fff;
        border:1px solid rgba(148,163,184,0.28);
    }
    .legend-dot{
        width:10px;
        height:10px;
        border-radius:999px;
    }
    .dot-pending{background:#facc15;}
    .dot-processing{background:#60a5fa;}
    .dot-shipped{background:#a5b4fc;}
    .dot-completed{background:#4ade80;}
    .dot-cancelled{background:#f97373;}

    /* Alert */
    .orders-alert{
        border-radius:14px;
        border:none;
        background:linear-gradient(120deg,#ecfdf3,#dcfce7);
        color:#166534;
        box-shadow:0 16px 40px rgba(22,163,74,0.16);
        font-size:.9rem;
    }

    /* Accordion / Card list */
    .order-accordion{
        background:transparent;
    }
    .order-accordion .accordion-item{
        background:transparent;
        border:none;
        margin-bottom:14px;
    }

    .order-card{
        background:var(--card);
        border-radius:20px;
        padding:0;
        box-shadow:0 22px 50px rgba(15,23,42,0.06);
        overflow:hidden;
        border:1px solid rgba(148,163,184,0.16);
    }

    .accordion-header{
        margin:0;
    }
    .accordion-button{
        background:transparent;
        box-shadow:none !important;
        border-radius:0 !important;
        padding:0;
    }
    .accordion-button::after{display:none;}

    /* Header grid cho từng đơn */
    .order-card-header{
        padding:14px 18px;
        display:grid;
        grid-template-columns: minmax(0,2fr) minmax(0,1.1fr) minmax(0,1.1fr) auto;
        gap:10px;
        align-items:center;
        cursor:pointer;
    }
    .order-code-block{
        min-width:0;
    }
    .order-code-label{
        font-size:.75rem;
        text-transform:uppercase;
        letter-spacing:.08em;
        color:var(--muted);
        margin-bottom:2px;
    }
    .order-code{
        font-weight:700;
        font-size:.98rem;
        color:var(--ink);
        white-space:nowrap;
        overflow:hidden;
        text-overflow:ellipsis;
    }

    .order-time-block,
    .order-total-block{
        font-size:.86rem;
        color:var(--muted);
    }
    .order-total-text{
        font-weight:600;
        color:var(--ink);
    }

    .order-status-pill{
        margin-left:auto;
        font-size:0.78rem;
        border-radius:999px;
        padding:5px 11px;
        display:inline-flex;
        align-items:center;
        gap:6px;
        border:1px solid transparent;
        background:#f3f4f6;
        color:#111827;
        white-space:nowrap;
    }
    .order-status-pill i{
        font-size:0.78rem;
    }
    .order-status-pending{
        background:#fffbeb;
        border-color:#f59e0b33;
        color:#92400e;
    }
    .order-status-processing{
        background:#eff6ff;
        border-color:#3b82f633;
        color:#1d4ed8;
    }
    .order-status-shipped{
        background:#eef2ff;
        border-color:#4f46e533;
        color:#3730a3;
    }
    .order-status-completed{
        background:#ecfdf3;
        border-color:#22c55e33;
        color:#166534;
    }
    .order-status-cancelled{
        background:#fef2f2;
        border-color:#ef444433;
        color:#991b1b;
    }

    .order-toggle-indicator{
        margin-left:10px;
        color:#9ca3af;
        transition:transform .2s ease;
    }
    .accordion-button.collapsed .order-toggle-indicator{
        transform:rotate(0deg);
    }
    .accordion-button:not(.collapsed) .order-toggle-indicator{
        transform:rotate(90deg);
    }

    .accordion-collapse{
        border-top:1px solid rgba(148,163,184,0.18);
    }
    .accordion-body{
        padding:16px 18px 20px;
        background:linear-gradient(180deg,#ffffff,#fdfcf9);
    }

    /* Summary left */
    .order-section-title{
        font-size:.9rem;
        font-weight:700;
        text-transform:uppercase;
        letter-spacing:.08em;
        color:var(--muted);
        margin-bottom:8px;
    }
    .order-summary-box{
        border-radius:16px;
        border:1px solid rgba(148,163,184,0.22);
        padding:12px 12px 10px;
        background:#fff;
        font-size:.9rem;
    }
    .summary-row{
        display:flex;
        gap:6px;
        align-items:flex-start;
        margin-bottom:5px;
    }
    .summary-label{
        min-width:110px;
        color:var(--muted);
    }
    .summary-value{
        font-weight:500;
        color:var(--ink);
    }
    .summary-total{
        margin-top:6px;
        padding-top:6px;
        border-top:1px dashed rgba(148,163,184,0.6);
    }
    .summary-total .summary-value{
        font-size:.98rem;
        color:#b91c1c;
        font-weight:700;
    }

    /* Items list – cột phải */
    .order-items-box{
        border-radius:16px;
        border:1px solid rgba(148,163,184,0.22);
        background:#fff;
        padding:4px 0;
    }
    .order-items-head{
        display:grid;
        grid-template-columns:minmax(0,3fr) minmax(0,1fr) minmax(0,1.4fr) minmax(0,1.4fr);
        padding:6px 12px;
        font-size:.76rem;
        text-transform:uppercase;
        letter-spacing:.08em;
        color:var(--muted);
        border-bottom:1px solid #f3f4f6;
    }
    .order-items-list{
        max-height:260px;
        overflow-y:auto;
    }
    .order-item-row{
        display:grid;
        grid-template-columns:minmax(0,3fr) minmax(0,1fr) minmax(0,1.4fr) minmax(0,1.4fr);
        align-items:center;
        padding:8px 12px;
        gap:8px;
    }
    .order-item-row + .order-item-row{
        border-top:1px solid #f3f4f6;
    }

    .order-item-main{
        display:flex;
        align-items:center;
        gap:8px;
        min-width:0;
    }
    .order-item-thumb img{
        width:52px;
        height:52px;
        object-fit:cover;
        border-radius:10px;
        border:1px solid #e5e7eb;
    }
    .order-item-text{
        min-width:0;
    }
    .order-item-name{
        font-size:0.9rem;
        font-weight:600;
        color:var(--ink);
        white-space:nowrap;
        overflow:hidden;
        text-overflow:ellipsis;
    }
    .order-item-sub{
        font-size:0.8rem;
        color:var(--muted);
    }
    .order-item-center{
        font-size:0.86rem;
        color:var(--ink);
        white-space:nowrap;
    }

    /* Empty state */
    .orders-empty{
        background:#fff;
        border-radius:20px;
        padding:40px 24px;
        text-align:center;
        box-shadow:0 22px 50px rgba(15,23,42,0.06);
        border:1px solid rgba(148,163,184,0.18);
    }

    @media (max-width: 991.98px){
        .order-card-header{
            grid-template-columns:minmax(0,2fr) minmax(0,1.4fr) auto;
        }
        .order-total-block{
            display:none;
        }
    }

    @media (max-width: 767.98px){
        .orders-header{
            flex-direction:column;
            align-items:flex-start;
        }
        .order-card-header{
            grid-template-columns:minmax(0,1.6fr) minmax(0,1.3fr) auto;
            row-gap:6px;
        }
    }

    @media (max-width: 575.98px){
        .order-card-header{
            grid-template-columns:minmax(0,1.8fr) auto;
        }
        .order-time-block{
            font-size:.8rem;
        }
        .order-items-head,
        .order-item-row{
            grid-template-columns:minmax(0,3fr) minmax(0,1fr) minmax(0,1.4fr);
        }
        .order-item-row div:last-child{
            display:none; /* ẩn cột Thành tiền trên màn nhỏ cho gọn */
        }
    }
</style>

<main class="orders-page">
    <div class="container orders-shell">

        <div class="orders-header">
            <div>
                <div class="orders-header-title">Lịch sử đơn hàng</div>
                <div class="orders-header-sub">
                    Theo dõi những đơn hàng bạn đã đặt tại <strong>LUXE INTERIORS</strong>, bao gồm trạng thái, tổng tiền và chi tiết sản phẩm.
                </div>
            </div>
        </div>

        <%-- Legend trạng thái --%>
        <div class="orders-legend">
            <div class="orders-legend-item">
                <span class="legend-dot dot-pending"></span> Chờ xác nhận
            </div>
            <div class="orders-legend-item">
                <span class="legend-dot dot-processing"></span> Đang xử lý
            </div>
            <div class="orders-legend-item">
                <span class="legend-dot dot-shipped"></span> Đang giao
            </div>
            <div class="orders-legend-item">
                <span class="legend-dot dot-completed"></span> Hoàn tất
            </div>
            <div class="orders-legend-item">
                <span class="legend-dot dot-cancelled"></span> Đã hủy
            </div>
        </div>

        <%-- Thông báo --%>
        <c:if test="${not empty message}">
            <div class="alert orders-alert py-3 px-4 mb-4">
                <i class="fa-solid fa-circle-check me-2"></i> ${message}
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty orderList}">
                <div class="orders-empty">
                    <div class="mb-3" style="font-size:60px;">📦</div>
                    <h3 class="mb-2" style="color:var(--ink);">Bạn chưa có đơn hàng nào</h3>
                    <p class="text-muted mb-4">Thêm vài món décor để không gian của bạn trở nên sang trọng và ấm cúng hơn.</p>
                    <a class="btn-luxury ripple px-5" href="<c:url value='/shop'/>">Bắt đầu mua sắm</a>
                </div>
            </c:when>

            <c:otherwise>
                <div class="accordion order-accordion" id="ordersAccordion">
                    <c:forEach items="${orderList}" var="order" varStatus="st">
                        <c:set var="panelId" value="order_${order.orderID}" />
                        <c:set var="isFirst" value="${st.index == 0}" />

                        <%-- xác định class trạng thái --%>
                        <c:set var="statusClass" value="order-status-pill" />
                        <c:set var="statusIcon"  value="fa-regular fa-circle" />
                        <c:set var="statusLabel" value="${order.status}" />

                        <c:choose>
                            <c:when test="${order.status eq 'Pending'}">
                                <c:set var="statusClass" value="order-status-pill order-status-pending"/>
                                <c:set var="statusIcon"  value="fa-regular fa-clock"/>
                                <c:set var="statusLabel" value="Chờ xác nhận"/>
                            </c:when>
                            <c:when test="${order.status eq 'Processing'}">
                                <c:set var="statusClass" value="order-status-pill order-status-processing"/>
                                <c:set var="statusIcon"  value="fa-solid fa-gears"/>
                                <c:set var="statusLabel" value="Đang xử lý"/>
                            </c:when>
                            <c:when test="${order.status eq 'Shipped'}">
                                <c:set var="statusClass" value="order-status-pill order-status-shipped"/>
                                <c:set var="statusIcon"  value="fa-solid fa-truck-fast"/>
                                <c:set var="statusLabel" value="Đang giao"/>
                            </c:when>
                            <c:when test="${order.status eq 'Completed' || order.status eq 'Done' || order.status eq 'Delivered'}">
                                <c:set var="statusClass" value="order-status-pill order-status-completed"/>
                                <c:set var="statusIcon"  value="fa-regular fa-circle-check"/>
                                <c:set var="statusLabel" value="Hoàn tất"/>
                            </c:when>
                            <c:when test="${order.status eq 'Cancelled'}">
                                <c:set var="statusClass" value="order-status-pill order-status-cancelled"/>
                                <c:set var="statusIcon"  value="fa-regular fa-circle-xmark"/>
                                <c:set var="statusLabel" value="Đã hủy"/>
                            </c:when>
                        </c:choose>

                        <div class="accordion-item">
                            <div class="order-card">
                                <h2 class="accordion-header" id="h_${panelId}">
                                    <button class="accordion-button ${!isFirst ? 'collapsed' : ''}" type="button"
                                            data-bs-toggle="collapse"
                                            data-bs-target="#c_${panelId}"
                                            aria-expanded="${isFirst}"
                                            aria-controls="c_${panelId}">
                                        <div class="order-card-header">
                                            <div class="order-code-block">
                                                <div class="order-code-label">Mã đơn</div>
                                                <div class="order-code">#${order.orderID}</div>
                                            </div>
                                            <div class="order-time-block">
                                                <div class="order-code-label">Thời gian</div>
                                                <div>
                                                    <fmt:formatDate value="${order.orderDate}" pattern="HH:mm dd/MM/yyyy"/>
                                                </div>
                                            </div>
                                            <div class="order-total-block">
                                                <div class="order-code-label">Tổng tiền</div>
                                                <div class="order-total-text">
                                                    <fmt:formatNumber value="${order.totalAmount}" type="currency" currencyCode="VND"/>
                                                </div>
                                            </div>
                                            <span class="${statusClass}">
                                                <i class="${statusIcon}"></i> ${statusLabel}
                                            </span>
                                            <span class="order-toggle-indicator">
                                                <i class="fa-solid fa-chevron-right"></i>
                                            </span>
                                        </div>
                                    </button>
                                </h2>

                                <div id="c_${panelId}"
                                     class="accordion-collapse collapse ${isFirst ? 'show' : ''}"
                                     aria-labelledby="h_${panelId}"
                                     data-bs-parent="#ordersAccordion">
                                    <div class="accordion-body">
                                        <div class="row g-4">
                                            <%-- Thông tin đơn hàng --%>
                                            <div class="col-lg-5">
                                                <div class="order-section-title">Thông tin đơn hàng</div>
                                                <div class="order-summary-box">
                                                    <div class="summary-row">
                                                        <div class="summary-label">Địa chỉ giao hàng</div>
                                                        <div class="summary-value">${order.shippingAddress}</div>
                                                    </div>
                                                    <div class="summary-row">
                                                        <div class="summary-label">Thanh toán</div>
                                                        <div class="summary-value">
                                                            <c:choose>
                                                                <c:when test="${order.paymentMethod eq 'COD'}">
                                                                    Thanh toán khi nhận hàng (COD)
                                                                </c:when>
                                                                <c:when test="${order.paymentMethod eq 'CARD'}">
                                                                    Thẻ / Chuyển khoản ngân hàng
                                                                </c:when>
                                                                <c:when test="${order.paymentMethod eq 'MOMO'}">
                                                                    Ví Momo
                                                                </c:when>
                                                                <c:when test="${order.paymentMethod eq 'VNPAY'}">
                                                                    Thanh toán online qua VNPAY
                                                                </c:when>
                                                                <c:otherwise>
                                                                    ${order.paymentMethod}
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </div>
                                                    <c:if test="${not empty order.note}">
                                                        <div class="summary-row">
                                                            <div class="summary-label">Ghi chú</div>
                                                            <div class="summary-value" style="white-space:pre-line;">
                                                                ${order.note}
                                                            </div>
                                                        </div>
                                                    </c:if>
                                                    <div class="summary-row summary-total">
                                                        <div class="summary-label">Tổng tiền</div>
                                                        <div class="summary-value">
                                                            <fmt:formatNumber value="${order.totalAmount}" type="currency" currencyCode="VND"/>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <%-- Danh sách sản phẩm --%>
                                            <div class="col-lg-7">
                                                <div class="order-section-title">Chi tiết sản phẩm</div>
                                                <div class="order-items-box">
                                                    <div class="order-items-head">
                                                        <div>Sản phẩm</div>
                                                        <div>SL</div>
                                                        <div>Đơn giá</div>
                                                        <div>Thành tiền</div>
                                                    </div>
                                                    <div class="order-items-list">
                                                        <c:forEach items="${order.items}" var="it">
                                                            <div class="order-item-row">
                                                                <div class="order-item-main">
                                                                    <div class="order-item-thumb">
                                                                        <img src="${it.product.imageURL}"
                                                                             alt="${it.product.productName}"
                                                                             onerror="this.src='<c:url value="/assets/images/placeholder.png"/>'" />
                                                                    </div>
                                                                    <div class="order-item-text">
                                                                        <div class="order-item-name">${it.product.productName}</div>
                                                                        <div class="order-item-sub">
                                                                            <c:if test="${not empty it.product.material}">
                                                                                Chất liệu: ${it.product.material}
                                                                            </c:if>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="order-item-center">
                                                                    ${it.quantity}
                                                                </div>
                                                                <div class="order-item-center">
                                                                    <fmt:formatNumber value="${it.unitPrice}" type="currency" currencyCode="VND"/>
                                                                </div>
                                                                <div class="order-item-center">
                                                                    <fmt:formatNumber value="${it.unitPrice * it.quantity}" type="currency" currencyCode="VND"/>
                                                                </div>
                                                            </div>
                                                        </c:forEach>
                                                    </div>
                                                </div>
                                            </div>

                                        </div> <!-- /row -->
                                    </div>
                                </div> <!-- /collapse -->
                            </div> <!-- /order-card -->
                        </div> <!-- /accordion-item -->
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</main>

<jsp:include page="/includes/footer.jsp" />
