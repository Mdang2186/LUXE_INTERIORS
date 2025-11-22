<%-- account.jsp – Trang tài khoản (sáng, đồng bộ LUXE INTERIORS) --%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="pageTitle" value="Tài khoản của tôi - LUXE INTERIORS" scope="request"/>
<%-- nếu controller chưa set tab, mặc định = profile --%>
<c:set var="tab" value="${empty tab ? 'profile' : tab}"/>

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
        background-color:var(--bg-page);
        color:var(--ink);
    }

    .account-page{
        padding:40px 0 56px;
        background:
          radial-gradient(900px 600px at top left, rgba(250,204,21,0.12), transparent 60%),
          var(--bg-page);
    }
    .account-shell{
        max-width:1120px;
        margin:0 auto;
    }

    /* --- header text --- */
    .account-header-title{
        font-family:'Playfair Display',serif;
        font-weight:700;
        font-size:2rem;
        margin-bottom:4px;
        color:var(--ink);
    }
    .account-header-sub{
        font-size:.95rem;
        color:var(--muted);
        margin-bottom:22px;
    }

    /* --- sidebar --- */
    .account-sidebar{
        position:sticky;
        top:96px;
    }
    .account-card{
        background:var(--card);
        border-radius:20px;
        padding:18px 16px;
        box-shadow:0 22px 50px rgba(15,23,42,0.08);
        border:1px solid rgba(148,163,184,0.18);
    }
    .account-user-head{
        display:flex;
        gap:12px;
        align-items:center;
        margin-bottom:14px;
    }
    .account-avatar{
        width:46px;
        height:46px;
        border-radius:999px;
        background:radial-gradient(circle at 20% 0%, #fef3c7, #facc15);
        display:grid;
        place-items:center;
        color:#7c2d12;
        font-weight:800;
        font-size:1.1rem;
        box-shadow:0 8px 18px rgba(250,204,21,0.45);
    }
    .account-user-name{
        font-weight:600;
        font-size:.98rem;
        color:var(--ink);
    }
    .account-user-email{
        font-size:.82rem;
        color:var(--muted);
    }

    .account-nav{
        margin-top:10px;
        border-top:1px solid #f3f4f6;
        padding-top:10px;
    }
    .account-nav-link{
        display:flex;
        align-items:center;
        gap:8px;
        padding:9px 12px;
        border-radius:999px;
        font-size:.9rem;
        color:var(--muted);
        text-decoration:none;
        margin-bottom:4px;
        transition:background .18s ease, color .18s ease,
                   transform .12s ease, box-shadow .18s ease;
    }
    .account-nav-link i{
        width:18px;
        text-align:center;
        font-size:.95rem;
    }
    .account-nav-link:hover{
        background:#f9fafb;
        color:var(--ink);
        transform:translateY(-1px);
        box-shadow:0 9px 20px rgba(15,23,42,0.04);
    }
    .account-nav-link.active{
        background:linear-gradient(120deg,#fef3c7,#fde68a);
        color:#7c2d12;
        font-weight:600;
        box-shadow:0 12px 28px rgba(250,204,21,0.35);
    }
    .account-nav-link.text-danger{
        color:#b91c1c;
    }
    .account-nav-link.text-danger:hover{
        background:#fef2f2;
        color:#991b1b;
        box-shadow:0 8px 18px rgba(248,113,113,0.25);
    }

    /* --- main card --- */
    .account-card-main{
        background:var(--card);
        border-radius:20px;
        border:1px solid rgba(148,163,184,0.18);
        box-shadow:0 24px 60px rgba(15,23,42,0.09);
    }
    .account-card-main .card-body{
        padding:24px 22px 24px;
    }

    .account-section-title{
        font-family:'Playfair Display',serif;
        font-weight:700;
        font-size:1.6rem;
        color:var(--ink);
        margin-bottom:4px;
    }
    .account-section-sub{
        font-size:.95rem;
        color:var(--muted);
        margin-bottom:18px;
    }

    /* alerts giống home: sáng, dịu */
    .alert-account-success{
        border-radius:14px;
        border:none;
        background:linear-gradient(120deg,#ecfdf3,#dcfce7);
        color:#166534;
        box-shadow:0 16px 40px rgba(22,163,74,0.18);
        font-size:.9rem;
    }
    .alert-account-error{
        border-radius:14px;
        border:none;
        background:#fef2f2;
        color:#b91c1c;
        box-shadow:0 16px 40px rgba(239,68,68,0.18);
        font-size:.9rem;
    }

    /* form controls */
    .form-label{
        font-size:.9rem;
        color:var(--muted);
        margin-bottom:4px;
    }
    .form-control.rounded-pill{
        padding:.6rem 0.9rem;
        font-size:.9rem;
        border-radius:999px;
        border:1px solid var(--border);
        transition:border-color .18s ease, box-shadow .18s ease, background-color .18s ease;
    }
    .form-control.rounded-pill:focus{
        border-color:var(--gold);
        box-shadow:0 0 0 3px rgba(212,175,55,0.28);
    }
    textarea.form-control{
        border-radius:14px;
        font-size:.9rem;
        border:1px solid var(--border);
    }
    textarea.form-control:focus{
        border-color:var(--gold);
        box-shadow:0 0 0 3px rgba(212,175,55,0.22);
    }

    /* button vàng kiểu LUXE */
    .btn-account-primary{
        position:relative;
        overflow:hidden;
        background:linear-gradient(135deg,#facc15,#eab308);
        color:#422006;
        border:none;
        font-weight:600;
        letter-spacing:.02em;
        text-transform:uppercase;
        font-size:.8rem;
        box-shadow:0 15px 35px rgba(250,204,21,0.55);
        transition:transform .12s ease, box-shadow .18s ease, filter .18s ease;
    }
    .btn-account-primary:hover{
        filter:brightness(.97);
        transform:translateY(-1px);
        color:#422006;
        box-shadow:0 18px 40px rgba(250,204,21,0.7);
    }
    .btn-account-primary:active{
        transform:translateY(0);
        box-shadow:0 10px 24px rgba(250,204,21,0.4);
    }

    .badge-pill-soft{
        border-radius:999px;
        padding:.1rem .55rem;
        font-size:.7rem;
        background:#eef2ff;
        color:#4f46e5;
    }

    @media (max-width:991.98px){
        .account-sidebar{
            position:static;
            margin-bottom:20px;
        }
    }
    @media (max-width:575.98px){
        .account-header-title{
            font-size:1.6rem;
        }
    }
</style>

<main class="account-page">
    <div class="container account-shell">

        <div class="mb-3">
            <div class="account-header-title">Tài khoản của bạn</div>
            <div class="account-header-sub">
                Quản lý thông tin cá nhân và mật khẩu để việc mua sắm tại LUXE INTERIORS luôn nhanh chóng, tiện lợi.
            </div>
        </div>

        <div class="row g-4">
            <%-- SIDEBAR --%>
            <aside class="col-lg-3">
                <div class="account-sidebar">
                    <div class="account-card">
                        <div class="account-user-head">
                            <div class="account-avatar">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.account.fullName}">
                                        <c:out value="${fn:substring(sessionScope.account.fullName,0,1)}"/>
                                    </c:when>
                                    <c:otherwise>U</c:otherwise>
                                </c:choose>
                            </div>
                            <div>
                                <div class="account-user-name">
                                    <c:out value="${sessionScope.account.fullName != null ? sessionScope.account.fullName : 'Khách hàng'}"/>
                                </div>
                                <div class="account-user-email">
                                    <c:out value="${sessionScope.account.email}"/>
                                </div>
                            </div>
                        </div>

                        <nav class="account-nav">
                            <a href="<c:url value='/account'/>"
                               class="account-nav-link ${tab == 'profile' ? 'active' : ''}">
                                <i class="fas fa-user-gear"></i>
                                <span>Thông tin tài khoản</span>
                            </a>
                            <a href="<c:url value='/account?tab=password'/>"
                               class="account-nav-link ${tab == 'password' ? 'active' : ''}">
                                <i class="fas fa-key"></i>
                                <span>Đổi mật khẩu</span>
                            </a>
                            <a href="<c:url value='/orders'/>" class="account-nav-link">
                                <i class="fas fa-clipboard-list"></i>
                                <span>Lịch sử đơn hàng</span>
                            </a>
                            <a href="<c:url value='/logout'/>" class="account-nav-link text-danger">
                                <i class="fas fa-right-from-bracket"></i>
                                <span>Đăng xuất</span>
                            </a>
                        </nav>
                    </div>
                </div>
            </aside>

            <%-- MAIN CONTENT --%>
            <section class="col-lg-9">

                <%-- alerts --%>
                <c:if test="${not empty success}">
                    <div class="alert alert-account-success mb-3">
                        <i class="fa-solid fa-circle-check me-2"></i>${success}
                    </div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert alert-account-error mb-3">
                        <i class="fa-solid fa-circle-exclamation me-2"></i>${error}
                    </div>
                </c:if>

                <%-- PROFILE TAB --%>
                <div class="${tab == 'profile' ? '' : 'd-none'}">
                    <div class="account-section-title">Thông tin tài khoản</div>
                    <div class="account-section-sub">
                        Cập nhật họ tên, số điện thoại và địa chỉ giao hàng cho những đơn hàng tiếp theo.
                    </div>

                    <div class="card account-card-main border-0">
                        <div class="card-body">
                            <form action="<c:url value='/account'/>" method="post" class="row g-3">
                                <input type="hidden" name="_csrf" value="${csrf}"/>
                                <input type="hidden" name="action" value="update-profile"/>

                                <div class="col-12">
                                    <label class="form-label fw-semibold">Email</label>
                                    <div class="d-flex align-items-center gap-2">
                                        <input type="email"
                                               class="form-control rounded-pill"
                                               value="${sessionScope.account.email}"
                                               disabled readonly>
                                        <span class="badge-pill-soft">Không thể thay đổi</span>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Họ và tên</label>
                                    <input name="fullName"
                                           class="form-control rounded-pill"
                                           required
                                           value="${sessionScope.account.fullName}"
                                           placeholder="Nguyễn Văn A">
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Số điện thoại</label>
                                    <input name="phone"
                                           class="form-control rounded-pill"
                                           placeholder="0xxxxxxxxx"
                                           value="${sessionScope.account.phone}"
                                           pattern="^(0|\\+?84)\\d{8,10}$"
                                           title="Số điện thoại Việt Nam hợp lệ">
                                </div>

                                <div class="col-12">
                                    <label class="form-label fw-semibold">Địa chỉ giao hàng</label>
                                    <textarea name="address"
                                              rows="3"
                                              class="form-control"
                                              placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành"
                                              required>${sessionScope.account.address}</textarea>
                                </div>

                                <div class="col-12">
                                    <button class="btn btn-account-primary rounded-pill px-4">
                                        <i class="fas fa-save me-2"></i>Lưu thay đổi
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <%-- PASSWORD TAB --%>
                <div class="${tab == 'password' ? '' : 'd-none'}">
                    <div class="account-section-title">Đổi mật khẩu</div>
                    <div class="account-section-sub">
                        Mật khẩu nên có ít nhất 8 ký tự, kết hợp chữ hoa, chữ thường, số và ký tự đặc biệt.
                    </div>

                    <div class="card account-card-main border-0">
                        <div class="card-body">
                            <form action="<c:url value='/account'/>" method="post" class="row g-3">
                                <input type="hidden" name="_csrf" value="${csrf}"/>
                                <input type="hidden" name="action" value="change-password"/>

                                <div class="col-12">
                                    <label class="form-label fw-semibold">Mật khẩu hiện tại</label>
                                    <input type="password" name="oldPassword"
                                           class="form-control rounded-pill" required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Mật khẩu mới</label>
                                    <input type="password"
                                           name="newPassword"
                                           id="newPwd"
                                           class="form-control rounded-pill"
                                           minlength="6" required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Nhập lại mật khẩu mới</label>
                                    <input type="password"
                                           name="re_newPassword"
                                           id="rePwd"
                                           class="form-control rounded-pill"
                                           minlength="6" required>
                                </div>

                                <div class="col-12">
                                    <button class="btn btn-account-primary rounded-pill px-4">
                                        <i class="fas fa-key me-2"></i>Đổi mật khẩu
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

            </section>
        </div>
    </div>
</main>

<jsp:include page="/includes/footer.jsp" />

<script>
    // Kiểm tra khớp mật khẩu mới (client-side)
    (function () {
        const newPwd = document.getElementById('newPwd');
        const rePwd  = document.getElementById('rePwd');
        if (newPwd && rePwd) {
            const check = () => {
                if (rePwd.value && newPwd.value !== rePwd.value) {
                    rePwd.setCustomValidity('Mật khẩu xác nhận không khớp');
                } else {
                    rePwd.setCustomValidity('');
                }
            };
            newPwd.addEventListener('input', check);
            rePwd.addEventListener('input', check);
        }
    })();
</script>
