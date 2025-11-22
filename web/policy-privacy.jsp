<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Chính sách Bảo mật thông tin" scope="request"/>
<c:set var="pageDesc" value="LUXE INTERIORS cam kết bảo vệ tuyệt đối thông tin cá nhân của bạn. Sự riêng tư của bạn là ưu tiên hàng đầu của chúng tôi." scope="request"/>
<jsp:include page="/includes/header.jsp" />

<style>
    /* CSS cho layout dạng bài viết */
    .policy-article {
        max-width: 800px; /* Width hẹp hơn để dễ đọc */
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
    .policy-content h5 {
        font-family: 'Playfair Display', serif;
        margin-top: 3rem;
        margin-bottom: 1.25rem;
    }
    .policy-content p, .policy-content li {
        font-size: 1.05rem; /* Hơi lớn hơn mặc định */
        line-height: 1.8;
        color: #495057;
    }
    .policy-content ul {
        list-style-type: none;
        padding-left: 0;
    }
    .policy-content ul li {
        display: flex;
        gap: 15px;
        margin-bottom: 0.75rem;
    }
    .policy-content ul .fa-shield-alt {
        color: var(--gold5, #B48F2F);
        margin-top: 8px;
    }
    /* Khung trích dẫn cam kết */
    .policy-quote {
        margin: 3rem 0;
        padding: 2rem;
        background-color: #FFFBF0; /* Nền vàng nhạt */
        border-left: 5px solid var(--gold4, #E8B422);
        font-style: italic;
        font-size: 1.2rem;
        color: #333;
    }
</style>

<main class="container policy-article">
    <section class="policy-hero">
        <span class="kicker"><i class="fa-solid fa-user-shield"></i>&nbsp; PRIVACY FIRST</span>
        <h1 class="display-5 font-playfair">${pageTitle}</h1>
        <p class="lead text-muted">${pageDesc}</p>
    </section>

    <div class="policy-content">
        <h5>1. Dữ liệu chúng tôi thu thập</h5>
        <p>Để xử lý đơn hàng và nâng cao trải nghiệm dịch vụ, chúng tôi chỉ thu thập các thông tin cá nhân cần thiết bao gồm: họ tên, số điện thoại, địa chỉ giao hàng và email. Chúng tôi không thu thập các thông tin nhạy cảm khác.</p>

        <blockquote class="policy-quote">
            "Cam kết của chúng tôi: Thông tin thẻ thanh toán của bạn được xử lý qua các cổng bảo mật đạt chuẩn quốc tế và **không được lưu trữ** trên hệ thống của LUXE INTERIORS."
        </blockquote>

        <h5>2. Lưu trữ & Chia sẻ thông tin</h5>
        <p>Sự an toàn cho dữ liệu của bạn là trách nhiệm của chúng tôi.</p>
        <ul>
            <li><i class="fas fa-shield-alt"></i><div>Dữ liệu được lưu trữ an toàn trên hệ thống máy chủ được bảo vệ và chỉ được truy cập bởi nhân viên có thẩm quyền.</div></li>
            <li><i class="fas fa-shield-alt"></i><div>Chúng tôi chỉ chia sẻ thông tin của bạn cho các đối tác vận chuyển và thanh toán với mục đích duy nhất là hoàn tất đơn hàng.</div></li>
            <li><i class="fas fa-shield-alt"></i><div><b>Chúng tôi không bao giờ bán hoặc chia sẻ dữ liệu cá nhân của bạn cho bất kỳ bên thứ ba nào vì mục đích quảng cáo.</b></div></li>
        </ul>

        <h5>3. Quyền của bạn</h5>
        <p>Bạn toàn quyền kiểm soát thông tin cá nhân của mình.</p>
        <ul>
            <li><i class="fas fa-shield-alt"></i><div>Bạn có quyền yêu cầu xem, chỉnh sửa hoặc xóa toàn bộ dữ liệu cá nhân của mình khỏi hệ thống của chúng tôi.</div></li>
            <li><i class="fas fa-shield-alt"></i><div>Bạn có thể rút lại sự đồng ý nhận bản tin quảng cáo bất cứ lúc nào thông qua đường link ở cuối mỗi email.</div></li>
        </ul>
    </div>
</main>

<jsp:include page="/includes/footer.jsp" />