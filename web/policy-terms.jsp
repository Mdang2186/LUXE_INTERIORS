<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Điều khoản Dịch vụ" scope="request"/>
<c:set var="pageDesc" value="Các quy định và điều khoản chung khi sử dụng dịch vụ và mua sắm tại website LUXE INTERIORS." scope="request"/>
<jsp:include page="/includes/header.jsp" />

<style>
    /* CSS cho layout bài viết + FAQ */
    .policy-article {
        max-width: 800px;
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
        font-size: 1.05rem;
        line-height: 1.8;
        color: #495057;
    }
    .policy-content ul {
        list-style: none;
        padding-left: 0;
    }
    .policy-content ul li {
        position: relative;
        padding-left: 25px;
        margin-bottom: 0.75rem;
    }
    /* Dùng icon của FontAwesome thay cho dấu chấm */
    .policy-content ul li::before {
        content: '\f0da'; /* icon fa-chevron-right */
        font-family: "Font Awesome 5 Free";
        font-weight: 900;
        position: absolute;
        left: 0;
        top: 4px;
        color: var(--gold5, #B48F2F);
    }
    
    /* Thiết kế lại Accordion (FAQ) */
    .policy-faq {
        margin-top: 2rem;
        border-top: 1px solid #F7E8B5;
    }
    .policy-faq details {
        border-bottom: 1px solid #F7E8B5;
        padding: 1.5rem 0;
    }
    .policy-faq summary {
        font-weight: 600;
        font-size: 1.1rem;
        cursor: pointer;
        list-style: none; /* Bỏ mũi tên mặc định */
        position: relative;
        padding-right: 2rem;
        color: #333;
    }
    .policy-faq summary::after {
        /* Tạo dấu cộng/trừ tùy chỉnh */
        content: '+';
        position: absolute;
        right: 0;
        top: -2px;
        font-weight: 300;
        color: var(--gold5, #B48F2F);
        font-size: 1.8rem;
    }
    .policy-faq details[open] summary::after {
        content: '−';
    }
    .policy-faq .faq-body {
        padding-top: 1rem;
        padding-left: 0.5rem;
        color: #495057;
    }
</style>

<main class="container policy-article">
    <section class="policy-hero">
        <span class="kicker"><i class="fa-solid fa-scale-balanced"></i>&nbsp; FAIR USE</span>
        <h1 class="display-5 font-playfair">${pageTitle}</h1>
        <p class="lead text-muted">${pageDesc}</p>
    </section>

    <div class="policy-content">
        <h5>Điều khoản chung</h5>
        <ul>
            <li>Không sử dụng website vào bất kỳ mục đích nào trái pháp luật Việt Nam.</li>
            <li>Giá bán sản phẩm có thể thay đổi theo thời điểm. Hình ảnh sản phẩm có thể mang tính chất minh họa và khác biệt nhỏ so với thực tế.</li>
            <li>Chúng tôi có quyền từ chối hoặc huỷ đơn hàng trong các trường hợp bất thường (lỗi hệ thống, sai giá, hết hàng đột ngột) và sẽ thông báo cho khách hàng.</li>
        </ul>

        <h5>Trách nhiệm & Tranh chấp</h5>
        <p>Mọi tranh chấp phát sinh (nếu có) sẽ được ưu tiên giải quyết thông qua thương lượng và hoà giải. Trong trường hợp không đạt được thỏa thuận, tranh chấp sẽ được đưa ra giải quyết tại cơ quan tòa án có thẩm quyền và tuân theo pháp luật Việt Nam.</p>
        
        <h5>Câu hỏi thường gặp (FAQ)</h5>
        <div class="policy-faq">
            <details>
                <summary>Tôi có thể dùng nội dung website không?</summary>
                <div class="faq-body">
                    <p>Bạn không được phép sao chép, phân phối hoặc sử dụng nội dung (hình ảnh, văn bản) của website cho các mục đích thương mại khi chưa có sự chấp thuận bằng văn bản từ LUXE INTERIORS.</p>
                </div>
            </details>
            <details>
                <summary>Nếu có lỗi niêm yết giá thì sao?</summary>
                <div class="faq-body">
                    <p>Trong trường hợp hiếm gặp sản phẩm bị niêm yết sai giá, đơn hàng của bạn sẽ được thông báo để điều chỉnh lại giá hoặc huỷ đơn. Bạn có toàn quyền lựa chọn tiếp tục mua với giá đúng hoặc nhận lại toàn bộ tiền đã thanh toán (nếu có).</p>
                </div>
            </details>
        </div>
    </div>
</main>

<jsp:include page="/includes/footer.jsp" />