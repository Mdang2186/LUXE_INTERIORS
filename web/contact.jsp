<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="path" value="${pageContext.request.contextPath}" />

<c:set var="pageTitle" value="Liên hệ & Tư vấn - LUXE INTERIORS" scope="request"/>
<c:set var="pageDesc" value="Kết nối với LUXE INTERIORS để nhận tư vấn chuyên nghiệp về thiết kế nội thất và giải đáp mọi thắc mắc của bạn." scope="request"/>
<jsp:include page="/includes/header.jsp" />

<style>
    /* CSS cho trang liên hệ */
    .contact-hero {
        position: relative;
        padding: 6rem 0;
        background-color: #fdfcf9;
        text-align: center;
    }
    .contact-hero h1 {
        font-family: 'Playfair Display', serif;
        color: var(--gold5, #B48F2F);
    }
    .contact-grid {
        max-width: 1200px;
        margin: 4rem auto 5rem auto;
        display: grid;
        grid-template-columns: 1fr 1.2fr;
        gap: 3rem;
        align-items: flex-start;
    }
    .contact-info {
        position: sticky;
        top: 100px; /* Dưới header */
    }
    .contact-info h5 {
        font-family: 'Playfair Display', serif;
        font-weight: 700;
        margin-bottom: 1.5rem;
    }
    .info-item {
        display: flex;
        align-items: flex-start;
        gap: 1rem;
        margin-bottom: 1.5rem;
    }
    .info-item .icon {
        flex-shrink: 0;
        width: 44px;
        height: 44px;
        display: grid;
        place-items: center;
        border-radius: 12px;
        background-color: #FFFBF0;
        border: 1px solid #F7E8B5;
        color: var(--gold5, #B48F2F);
        font-size: 1.2rem;
    }
    .info-item p {
        margin-bottom: 0;
        color: #6c757d;
        line-height: 1.6;
    }
    .info-item .title {
        font-weight: 600;
        color: #333;
        margin-bottom: 0.25rem;
    }
    .contact-socials {
        display: flex;
        gap: 0.75rem;
        margin-top: 1.5rem;
    }
    .contact-socials a {
        width: 40px;
        height: 40px;
        display: grid;
        place-items: center;
        border: 1px solid #e0e0e0;
        border-radius: 50%;
        color: #555;
        text-decoration: none;
        transition: all 0.2s ease;
    }
    .contact-socials a:hover {
        background-color: var(--gold4, #E8B422);
        border-color: var(--gold4, #E8B422);
        color: #fff;
    }
    
    /* Form */
    .contact-form-wrap {
        background-color: #FFFBF0;
        border: 1px solid #F7E8B5;
        border-radius: 16px;
        box-shadow: 0 4px 20px rgba(218, 165, 32, 0.1);
        padding: 2.5rem;
    }
    
    /* Khu vực Đăng ký (Subscribe) */
    .subscribe-section {
        background-color: var(--bg, #0e0d0c);
        color: #e9e7e4;
        padding: 5rem 0;
        margin-top: 5rem;
    }
    .subscribe-box {
        max-width: 600px;
        margin: 0 auto;
        text-align: center;
    }
    .subscribe-box .icon {
        font-size: 3rem;
        color: var(--gold3, #d4af37);
        margin-bottom: 1rem;
    }
    .subscribe-box h3 {
        font-family: 'Playfair Display', serif;
        color: #fff;
    }
    .subscribe-box p {
        color: var(--muted, #9c9aa0);
    }
    .subscribe-form {
        display: flex;
        gap: 0.5rem;
        margin-top: 2rem;
    }
    .subscribe-form input {
        flex-grow: 1;
        background: #111;
        color: #eee;
        border: 1px solid rgba(255, 255, 255, 0.08);
        padding: 1rem;
        border-radius: 999px;
    }
    
    @media (max-width: 991px) {
        .contact-grid {
            grid-template-columns: 1fr;
        }
        .contact-info {
            position: static;
            text-align: center;
        }
        .info-item {
            flex-direction: column;
            align-items: center;
        }
        .contact-socials {
            justify-content: center;
        }
    }
    
    /* === CSS CHO FORM NHÃN NỔI === */
    .form-floating > .form-control {
        border-radius: 12px; /* Bo góc đồng bộ */
    }
    .form-floating > .form-control:focus {
        /* Đổi màu viền khi focus sang màu vàng */
        border-color: var(--gold4, #E8B422);
        box-shadow: 0 0 0 0.25rem rgba(232, 180, 34, 0.25);
    }
    .form-floating > label {
        color: #6c757d; /* Màu text-muted cho label */
        font-size: 0.95rem; /* Thu nhỏ label một chút */
    }
    .form-floating > .form-control:-webkit-autofill {
        border-radius: 12px; /* Fix bo góc khi trình duyệt tự điền */
    }
    .form-floating > textarea.form-control {
        min-height: 150px; /* Tăng chiều cao textarea */
    }
</style>

<!-- 1. HERO -->
<section class="contact-hero">
    <div class="container">
        <span class="kicker">KẾT NỐI</span>
        <h1 class="display-4">${pageTitle}</h1>
        <p class="lead text-muted col-lg-7 mx-auto">${pageDesc}</p>
    </div>
</section>

<!-- 2. GRID LIÊN HỆ -->
<main class="container">
    <div class="contact-grid">
        <!-- CỘT BÊN TRÁI: THÔNG TIN -->
        <aside class="contact-info">
            <h5>Thông tin liên hệ</h5>
            <p class="text-muted">Chúng tôi luôn sẵn sàng lắng nghe bạn. Liên hệ qua các kênh dưới đây để được hỗ trợ nhanh nhất.</p>
            
            <div class="info-item">
                <div class="icon"><i class="fa-solid fa-map-location-dot"></i></div>
                <div>
                    <div class="title">Địa chỉ Showroom</div>
                    <p>Số 1, Trịnh Văn Bô, Nam Từ Liêm, Hà Nội (FPT Polytechnic)</p>
                </div>
            </div>
            <div class="info-item">
                <div class="icon"><i class="fa-solid fa-phone-volume"></i></div>
                <div>
                    <div class="title">Hotline Tư vấn</div>
                    <p>0987.654.321 (Hỗ trợ 8:00 - 21:00)</p>
                </div>
            </div>
            <div class="info-item">
                <div class="icon"><i class="fa-solid fa-envelope-open-text"></i></div>
                <div>
                    <div class="title">Email Hỗ trợ</div>
                    <p>support@luxeinteriors.vn</p>
                </div>
            </div>
            
            <div class="contact-socials">
                <a href="#" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
                <a href="#" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
                <a href="#" aria-label="YouTube"><i class="fab fa-youtube"></i></a>
                <a href="#" aria-label="Pinterest"><i class="fab fa-pinterest-p"></i></a>
            </div>
        </aside>

        <!-- CỘT BÊN PHẢI: FORM LIÊN HỆ (ĐÃ THIẾT KẾ LẠI) -->
        <section class="contact-form-wrap">
            <h4 class="font-playfair mb-4">Gửi yêu cầu tư vấn</h4>
            
            <form action="<c:url value='/contact'/>" method="post" class="row g-3">
                
                <!-- Hiển thị thông báo (từ ContactController) -->
                <c:if test="${not empty success}">
                    <div class="col-12">
                        <div class="alert alert-success">${success}</div>
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="col-12">
                        <div class="alert alert-danger">${error}</div>
                    </div>
                </c:if>

                <!-- SỬ DỤNG FLOATING LABELS -->
                <div class="col-md-6">
                    <div class="form-floating">
                        <input name="fullName" id="floatingFullName" required class="form-control" placeholder="Họ và tên *" value="${param.fullName}"/>
                        <label for="floatingFullName">Họ và tên *</label>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="form-floating">
                        <input name="phone" id="floatingPhone" required class="form-control" placeholder="Số điện thoại *" value="${param.phone}"/>
                        <label for="floatingPhone">Số điện thoại *</label>
                    </div>
                </div>
                <div class="col-12">
                    <div class="form-floating">
                        <input name="email" id="floatingEmail" type="email" required class="form-control" placeholder="Email *" value="${param.email}"/>
                        <label for="floatingEmail">Email *</label>
                    </div>
                </div>
                <div class="col-12">
                    <div class="form-floating">
                        <input name="subject" id="floatingSubject" type="text" required class="form-control" placeholder="Chủ đề *" value="${param.subject}"/>
                        <label for="floatingSubject">Chủ đề *</label>
                    </div>
                </div>
                <div class="col-12">
                    <div class="form-floating">
                        <textarea name="message" id="floatingMessage" rows="5" required class="form-control" placeholder="Nhu cầu tư vấn *">${param.message}</textarea>
                        <label for="floatingMessage">Nhu cầu tư vấn *</label>
                    </div>
                </div>
                <div class="col-12">
                    <button class="btn-luxury ripple w-100 py-3" type="submit">Gửi yêu cầu ngay</button>
                </div>
            </form>
        </section>
    </div>
</main>
 

<jsp:include page="/includes/footer.jsp" />