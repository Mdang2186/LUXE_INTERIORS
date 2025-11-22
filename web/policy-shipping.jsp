<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />
<%-- Đặt tiêu đề và mô tả động --%>
<c:set var="pageTitle" value="Chính sách Giao hàng & Lắp đặt" scope="request"/>
<c:set var="pageDesc" value="Quy trình giao hàng, lắp đặt chuyên nghiệp, nhanh chóng và minh bạch tại LUXE INTERIORS." scope="request"/>
<jsp:include page="/includes/header.jsp" />

<style>
    /* CSS cho layout Timeline */
    .policy-container {
        max-width: 960px;
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
    .timeline {
        position: relative;
        padding: 2rem 0;
    }
    /* Đường kẻ dọc của timeline */
    .timeline::before {
        content: '';
        position: absolute;
        top: 0;
        left: 24px;
        height: 100%;
        width: 4px;
        background: #F7E8B5; /* Màu viền vàng nhạt */
        border-radius: 2px;
    }
    .timeline-item {
        position: relative;
        margin-bottom: 3rem;
        padding-left: 80px; /* Khoảng cách cho icon và đường kẻ */
    }
    .timeline-item:last-child {
        margin-bottom: 0;
    }
    /* Icon tròn trên timeline */
    .timeline-icon {
        position: absolute;
        left: 0;
        top: -5px;
        width: 50px;
        height: 50px;
        background-color: #FFFBF0; /* Nền vàng nhạt */
        border: 2px solid #F7E8B5;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        color: var(--gold5, #B48F2F);
        z-index: 1;
    }
    /* Nội dung (thẻ .card-luxury) */
    .timeline-content h5 {
        font-family: 'Playfair Display', serif;
        margin-bottom: 0.75rem;
    }
    .timeline-content ul {
        list-style-type: none;
        padding-left: 0;
    }
    .timeline-content ul li {
        position: relative;
        padding-left: 22px;
        margin-bottom: 0.5rem;
    }
    .timeline-content ul li::before {
        content: '✓';
        position: absolute;
        left: 0;
        color: var(--gold5, #B48F2F);
        font-weight: 600;
    }
</style>

<main class="container policy-container">
    <section class="policy-hero">
        <span class="kicker"><i class="fa-solid fa-truck-fast"></i>&nbsp; GIAO NHANH – CHUẨN HẸN</span>
        <h1 class="display-5 font-playfair">${pageTitle}</h1>
        <p class="lead text-muted">${pageDesc}</p>
    </section>

    <div class="timeline">
        <div class="timeline-item">
            <div class="timeline-icon"><i class="fa-solid fa-map-location-dot"></i></div>
            <div class="timeline-content card-luxury p-4">
                <h5>1. Phạm vi & Thời gian</h5>
                <p class="text-muted">Chúng tôi cam kết giao hàng đúng hẹn theo khu vực:</p>
                <ul>
                    <li><b>Nội thành HN/HCM:</b> 1–3 ngày làm việc.</li>
                    <li><b>Ngoại thành & tỉnh lân cận:</b> 3–7 ngày làm việc.</li>
                    <li><b>Hỏa tốc:</b> Hỗ trợ giao trong ngày (vui lòng liên hệ hotline).</li>
                </ul>
                <div class="hr-soft"></div>
                <span class="luxe-chip"><span class="dot"></span> Theo dõi đơn qua email/SMS</span>
            </div>
        </div>

        <div class="timeline-item">
            <div class="timeline-icon"><i class="fa-solid fa-dollar-sign"></i></div>
            <div class="timeline-content card-luxury p-4">
                <h5>2. Chi phí Vận chuyển</h5>
                <p class="text-muted">Mức phí được tối ưu và minh bạch:</p>
                <table class="luxe-table" style="margin:0;">
                    <tbody>
                        <tr class="luxe-row">
                            <td style="width:50%">Đơn từ <b>5.000.000đ</b> (nội thành)</td>
                            <td><span class="luxe-tag">Miễn phí</span></td>
                        </tr>
                        <tr class="luxe-row">
                            <td>Đơn cồng kềnh / khoảng cách xa</td>
                            <td>Phát sinh theo báo giá nhà vận chuyển</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="timeline-item">
            <div class="timeline-icon"><i class="fa-solid fa-tools"></i></div>
            <div class="timeline-content card-luxury p-4">
                <h5>3. Lắp đặt tại nhà</h5>
                <p class="text-muted">Đội ngũ kỹ thuật viên chuyên nghiệp sẽ hỗ trợ:</p>
                <ul>
                    <li>Miễn phí lắp đặt cơ bản cho các sản phẩm như sofa, giường, tủ, kệ.</li>
                    <li>Phụ phí có thể phát sinh cho các công việc phức tạp (khoan tường, đi dây ẩn...) và sẽ được báo trước.</li>
                    <li>Kỹ thuật viên mang đủ dụng cụ, vệ sinh gọn gàng sau khi lắp.</li>
                </ul>
            </div>
        </div>

        <div class="timeline-item">
            <div class="timeline-icon"><i class="fa-solid fa-clipboard-check"></i></div>
            <div class="timeline-content card-luxury p-4">
                <h5>4. Kiểm hàng & Bàn giao</h5>
                <p>Quý khách vui lòng đồng kiểm tra sản phẩm khi nhận hàng: kiểm tra ngoại quan, độ chắc chắn, phụ kiện kèm theo.</p>
                <p class="mb-0">Sau khi đồng ý, quý khách ký biên bản bàn giao để chính thức kích hoạt bảo hành điện tử.</p>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/includes/footer.jsp" />