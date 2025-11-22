<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Chính sách Đổi trả & Bảo hành" scope="request"/>
<c:set var="pageDesc" value="An tâm mua sắm với chính sách đổi trả linh hoạt trong 7 ngày và bảo hành toàn diện lên đến 24 tháng." scope="request"/>
<jsp:include page="/includes/header.jsp" />

<style>
    /* CSS cho layout 2 cột */
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
    .policy-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 2rem;
        align-items: start;
    }
    .policy-card {
        text-align: center;
        /* Dùng thẻ .card-luxury có sẵn */
    }
    .policy-card .icon {
        font-size: 3rem;
        color: var(--gold4, #E8B422);
        margin-bottom: 1rem;
    }
    .policy-card h5 {
        font-family: 'Playfair Display', serif;
    }
    /* Căn chỉnh list bên trong card */
    .policy-list-clean {
        list-style-type: none;
        padding-left: 0;
        text-align: left;
    }
    .policy-list-clean li {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        margin-bottom: 0.75rem;
    }
    .policy-list-clean .fa-check-circle {
        color: #198754; /* Màu xanh success */
        margin-top: 5px;
    }
    /* Phần quy trình 3 bước */
    .process-section {
        margin-top: 4rem;
        padding: 3rem;
        background-color: #FFFBF0; /* Nền vàng nhạt */
        border-radius: 16px;
    }
    .process-steps {
        display: flex;
        gap: 1.5rem;
        text-align: center;
    }
    .step .step-number {
        width: 50px;
        height: 50px;
        border: 2px solid var(--gold4, #E8B422);
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        font-family: 'Playfair Display', serif;
        margin-bottom: 1rem;
        color: var(--gold5, #B48F2F);
    }
    /* Responsive */
    @media (max-width: 768px) {
        .policy-grid, .process-steps {
            grid-template-columns: 1fr;
            flex-direction: column;
        }
    }
    
    /* Tái định nghĩa table từ file gốc cho đẹp hơn */
    .luxe-table { width: 100%; border-collapse: collapse; margin-bottom: 1rem; text-align: left; }
    .luxe-table .luxe-row td { padding: 0.85rem 0.5rem; border-bottom: 1px solid #F7E8B5; }
    .luxe-table .luxe-row:last-child td { border-bottom: none; }
    .luxe-tag { display: inline-block; padding: 0.4em 0.75em; font-size: .8em; font-weight: 700; color: #212529; border-radius: 0.35rem; background-color: #f7e8b5; }
</style>

<main class="container policy-container">
    <section class="policy-hero">
        <span class="kicker"><i class="fa-solid fa-shield-heart"></i>&nbsp; BẢO VỆ QUYỀN LỢI</span>
        <h1 class="display-5 font-playfair">${pageTitle}</h1>
        <p class="lead text-muted">${pageDesc}</p>
    </section>

    <div class="policy-grid">
        <div class="policy-card card-luxury p-4 p-lg-5 h-100">
            <div class="icon"><i class="fa-solid fa-box-open"></i></div>
            <h5>Điều kiện đổi trả (7 ngày)</h5>
            <p class="text-muted">Linh hoạt đổi sản phẩm nếu bạn thay đổi ý định.</p>
            <hr class="my-4">
            <ul class="policy-list-clean">
                <li><i class="fa-solid fa-check-circle"></i><div>Sản phẩm còn nguyên tem, phiếu bảo hành, không trầy xước, bẩn.</div></li>
                <li><i class="fa-solid fa-check-circle"></i><div>Hỗ trợ đổi màu sắc/kích thước 1 lần (bạn chi trả phí vận chuyển/chênh lệch nếu có).</div></li>
                <li><i class="fa-solid fa-check-circle"></i><div>Sản phẩm dọn kho, giảm giá sâu không áp dụng đổi trả theo sở thích.</div></li>
            </ul>
        </div>

        <div class="policy-card card-luxury p-4 p-lg-5 h-100">
            <div class="icon"><i class="fa-solid fa-user-shield"></i></div>
            <h5>Thời hạn bảo hành</h5>
            <p class="text-muted">An tâm sử dụng với chính sách bảo hành dài hạn.</p>
            <hr class="my-4">
            <table class="luxe-table">
                <tbody>
                <tr class="luxe-row"><td style="width:55%">Khung gỗ/kim loại</td><td><span class="luxe-tag">24 tháng</span></td></tr>
                <tr class="luxe-row"><td>Nệm mút, bọc vải/da</td><td><span class="luxe-tag">12 tháng</span></td></tr>
                <tr class="luxe-row"><td>Hao mòn tự nhiên / sai cách</td><td>Không bảo hành</td></tr>
                </tbody>
            </table>
        </div>
    </div>

    <section class="process-section text-center">
        <h3 class="font-playfair mb-4">Quy trình xử lý đơn giản</h3>
        <div class="process-steps justify-content-center">
            <div class="step flex-fill">
                <div class="step-number">1</div>
                <h6>Liên hệ & Gửi thông tin</h6>
                <p class="text-muted">Gửi hình ảnh/video sản phẩm và mã đơn hàng cho bộ phận CSKH để xác minh.</p>
            </div>
            <div class="step flex-fill">
                <div class="step-number">2</div>
                <h6>Lên lịch hẹn</h6>
                <p class="text-muted">Kỹ thuật viên sẽ đến khảo sát tận nơi hoặc chúng tôi sẽ lên lịch đổi mới sản phẩm cho bạn.</p>
            </div>
            <div class="step flex-fill">
                <div class="step-number">3</div>
                <h6>Hoàn tất xử lý</h6>
                <p class="text-muted">Hoàn tiền trong 3-7 ngày nếu đủ điều kiện. Sản phẩm được đổi/bảo hành thành công.</p>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/includes/footer.jsp" />