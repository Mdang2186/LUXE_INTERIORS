<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Chính sách Thanh toán & Trả góp" scope="request"/>
<c:set var="pageDesc" value="Cung cấp đa dạng phương thức thanh toán an toàn, tiện lợi cùng chương trình trả góp 0% linh hoạt." scope="request"/>
<jsp:include page="/includes/header.jsp" />

<style>
    /* CSS cho layout dạng card */
    .policy-container {
        max-width: 1100px;
        margin: 4rem auto 5rem auto;
    }
    .policy-hero {
        text-align: center;
        margin-bottom: 4rem;
    }
    .policy-hero .kicker {
        font-size: 0.9rem;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        color: var(--gold5, #B48F2F);
    }
    .policy-hero h1 {
        font-family: 'Playfair Display', serif;
    }
    .payment-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        gap: 1.5rem;
    }
    /* Tái sử dụng .card-luxury */
    .payment-card {
        transition: all 0.3s ease;
    }
    .payment-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 30px rgba(218, 165, 32, 0.15); /* Thêm shadow khi hover */
    }
    .payment-card .icon {
        font-size: 2.5rem;
        color: var(--gold4, #E8B422);
        margin-bottom: 1rem;
    }
    .payment-card h5 {
        font-family: 'Playfair Display', serif;
    }
    .payment-card ul {
        list-style-type: none;
        padding-left: 0;
        margin-top: 1.5rem;
        text-align: left;
    }
    .payment-card li {
        margin-bottom: 0.5rem;
        color: #495057;
        display: flex;
        gap: 10px;
    }
    .payment-card .fa-check {
        color: var(--gold5, #B48F2F);
        margin-top: 5px;
    }
    /* Khu vực hóa đơn */
    .invoice-section {
        border-radius: 16px;
        margin-top: 3rem;
        padding: 2.5rem;
        text-align: center;
        /* Dùng thẻ .card-luxury */
    }
</style>

<main class="container policy-container">
    <section class="policy-hero">
        <span class="kicker"><i class="fa-solid fa-credit-card"></i>&nbsp; AN TOÀN – LINH HOẠT</span>
        <h1 class="display-5 font-playfair">${pageTitle}</h1>
        <p class="lead text-muted">${pageDesc}</p>
    </section>

    <div class="payment-grid">
        <div class="payment-card card-luxury p-4">
            <div class="icon"><i class="fa-solid fa-hand-holding-dollar"></i></div>
            <h5>Thanh toán trực tiếp</h5>
            <p class="text-muted small">Đơn giản, truyền thống và an toàn.</p>
            <ul>
                <li><i class="fas fa-check"></i> <div>Tiền mặt khi nhận hàng (COD).</div></li>
                <li><i class="fas fa-check"></i> <div>Cà thẻ Visa/Master/JCB tại showroom.</div></li>
            </ul>
        </div>
        <div class="payment-card card-luxury p-4">
            <div class="icon"><i class="fa-solid fa-qrcode"></i></div>
            <h5>Thanh toán Online</h5>
            <p class="text-muted small">Nhanh chóng, tiện lợi và bảo mật.</p>
            <ul>
                <li><i class="fas fa-check"></i> <div>Ví điện tử MoMo, VNPay QR.</div></li>
                <li><i class="fas fa-check"></i> <div>Chuyển khoản ngân hàng (VCB, TCB...).</div></li>
                <li><i class="fas fa-check"></i> <div>Cổng thanh toán trực tuyến an toàn.</div></li>
            </ul>
        </div>
        <div class="payment-card card-luxury p-4">
            <div class="icon"><i class="fa-solid fa-calendar-alt"></i></div>
            <h5>Trả góp 0%</h5>
            <p class="text-muted small">Sở hữu ngay, thanh toán nhẹ nhàng.</p>
            <ul>
                <li><i class="fas fa-check"></i> <div>Áp dụng qua thẻ tín dụng (đối tác).</div></li>
                <li><i class="fas fa-check"></i> <div>Kỳ hạn linh hoạt từ 3 đến 12 tháng.</div></li>
                <li><i class="fas fa-check"></i> <div>Duyệt hồ sơ online nhanh chóng.</li>
            </ul>
        </div>
    </div>

    <section class="invoice-section card-luxury">
        <h4 class="font-playfair">Hóa đơn & Thuế VAT</h4>
        <p class="text-muted col-lg-8 mx-auto mb-0">Chúng tôi hỗ trợ xuất hóa đơn VAT theo yêu cầu trong vòng 7 ngày kể từ ngày giao hàng thành công. Vui lòng cung cấp chính xác thông tin công ty và mã số thuế khi đặt hàng.</p>
    </section>
</main>

<jsp:include page="/includes/footer.jsp" />