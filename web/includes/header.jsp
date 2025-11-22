<%-- Thay thế toàn bộ file: includes/header.jsp (Header nền sáng) --%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="path" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <c:set var="pageTitle" value="${empty pageTitle ? 'LUXE INTERIORS - Tinh hoa Nội thất' : pageTitle}" scope="request"/>
    <title>${pageTitle}</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Cormorant+Garamond:wght@300;400;600&family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet"/>
    <link href="${path}/assets/css/luxe-style.css" rel="stylesheet">

    <%-- CSS HEADER NỀN SÁNG --%>
    <style>
        /* 1. Palette sáng */
        :root {
            --ink: #1d1a16;
            --bg: #fbfaf8;
            --muted: #6c757d;
            --gold1: #f9e9b0;
            --gold2: #f4ce54;
            --gold3: #d4af37;
            --gold4: #b68d16;
            --ring: rgba(212,175,55,.22);
        }

        /* Toàn site nền sáng, tránh bị theme tối đè */
        html, body {
            background-color: #fbfaf8;
            color: var(--ink);
        }

        /* 2. Header sáng */
        .header-luxe {
            color: var(--ink);
            background: linear-gradient(135deg, #ffffff, #fbf7f2);
            border-bottom: 1px solid rgba(0, 0, 0, .06);
        }

        /* 3. Navbar link trên nền sáng */
        .navbar-dark .navbar-brand,
        .navbar-dark .nav-link {
            color: var(--ink);
            transition: color 0.2s ease;
        }
        .navbar-dark .navbar-brand:hover,
        .navbar-dark .nav-link:hover,
        .navbar-dark .nav-link:focus {
            color: var(--gold3);
        }
        .navbar-dark .navbar-toggler {
            border-color: rgba(0,0,0,.15);
        }
        .navbar-dark .navbar-toggler-icon {
            filter: invert(20%); /* icon đen trên nền sáng */
        }

        /* 4. Ô tìm kiếm (sáng) */
        .form-control-luxe {
            background: #ffffff;
            color: var(--ink);
            border: 1px solid rgba(0, 0, 0, .08);
            outline: none;
            transition: all 0.2s ease;
        }
        .form-control-luxe::placeholder {
            color: var(--muted);
        }
        .form-control-luxe:focus {
            background: #ffffff;
            color: var(--ink);
            border-color: var(--gold3);
            box-shadow: 0 0 0 3px var(--ring);
        }

        /* 5. Nút viền (icon user, cart, đăng ký) nền sáng */
        .btn-outline-luxe {
            background: #ffffff;
            border: 1px solid rgba(0, 0, 0, .08);
            color: var(--ink);
            transition: all 0.2s ease;
            border-radius: 999px;
            padding-inline: 1rem;
        }
        .btn-outline-luxe:hover,
        .btn-outline-luxe:focus {
            background: linear-gradient(135deg, var(--gold2), var(--gold3));
            border-color: var(--gold3);
            color: #1b1304;
            transform: translateY(-1px);
            box-shadow: 0 8px 20px rgba(212,175,55,.25);
        }

        /* 6. Badge cart */
        [data-cart-badge] {
            font-size: 0.7rem;
        }

        /* 7. TRUST BADGES (dùng chung nhiều trang) */
        .trust-badge-section {
            background-color: #f8f9fa;
        }
        .trust-badge {
            text-align: center;
        }
        .trust-badge .badge-icon {
            width: 70px; height: 70px;
            margin: 0 auto 1rem auto;
            border-radius: 50%;
            background: #fff;
            display: grid;
            place-items: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            font-size: 1.75rem;
            color: var(--gold3);
        }
        .trust-badge h6 {
            font-weight: 700;
            color: var(--ink);
        }
        .trust-badge p {
            font-size: 0.9rem;
            color: #6c757d;
        }

        /* 8. Logo */
        .navbar-brand-logo-svg {
            height: 38px;
            width: auto;
        }
        .navbar-brand {
            padding-top: 0.5rem;
            padding-bottom: 0.5rem;
        }
    </style>
</head>

<body class="d-flex flex-column min-vh-100">
<header class="sticky-top header-luxe shadow-sm">
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container">
            <a class="navbar-brand" href="${path}/home">
                <img src="${path}/assets/images/logo/name.svg"
                     alt="LUXE INTERIORS"
                     class="navbar-brand-logo-svg">
            </a>

            <button class="navbar-toggler" type="button"
                    data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav mx-auto">
                    <li class="nav-item"><a class="nav-link" href="${path}/home">Trang Chủ</a></li>
                    <li class="nav-item"><a class="nav-link" href="${path}/shop">Sản Phẩm</a></li>
                    <li class="nav-item"><a class="nav-link" href="${path}/contact">Liên Hệ</a></li>
                </ul>

                <form class="d-flex me-3" action="${path}/shop" method="get" role="search">
                    <input class="form-control form-control-luxe me-2 rounded-pill"
                           type="search" name="keyword" value="${keywordValue}"
                           placeholder="Tìm sản phẩm..." aria-label="Search">
                    <button class="btn btn-outline-luxe rounded-pill" type="submit">
                        <i class="fas fa-search"></i>
                    </button>
                </form>

                <div class="d-flex align-items-center gap-3">
                    <a href="${path}/cart" class="btn btn-outline-luxe position-relative">
                        <i class="fas fa-shopping-bag"></i>
                        <c:if test="${not empty sessionScope.cartSize && sessionScope.cartSize > 0}">
                            <span data-cart-badge
                                  class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                                ${sessionScope.cartSize}
                            </span>
                        </c:if>
                        <c:if test="${empty sessionScope.cartSize || sessionScope.cartSize == 0}">
                            <span data-cart-badge
                                  class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none">
                                0
                            </span>
                        </c:if>
                    </a>

                    <c:if test="${not empty sessionScope.account}">
                        <div class="dropdown">
                            <button class="btn btn-outline-luxe dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                <i class="fas fa-user"></i>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><span class="dropdown-item-text">${sessionScope.account.fullName}</span></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="${path}/account">Tài khoản</a></li>
                                <li><a class="dropdown-item" href="${path}/orders">Đơn hàng</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="${path}/logout">Đăng xuất</a></li>
                            </ul>
                        </div>
                    </c:if>

                    <c:if test="${empty sessionScope.account}">
                        <a href="${path}/register" class="btn btn-outline-luxe btn-sm"
                           style="padding: 0.5rem 1rem;">Đăng ký</a>
                        <a href="${path}/login" class="btn-luxury ripple btn-sm"
                           style="padding: 0.5rem 1rem;">Đăng nhập</a>
                    </c:if>
                </div>
            </div>
        </div>
    </nav>
</header>
