<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="path" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin Dashboard - FurniShop</title>

        <link href="${pageContext.request.contextPath}/assets/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/all.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/admin-luxe.css?v=1.3" rel="stylesheet">

        <style>
            .admin-layout-wrapper {
                display: flex;
                min-height: 100vh;
            }
            .admin-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 0 1.5rem;
                height: 65px;
                background: var(--panel);
                border-bottom: 1px solid var(--line);
                position: sticky;
                top: 0;
                z-index: 1020;
            }
            .admin-header .header-left {
                display: flex;
                align-items: center;
                gap: 1rem;
            }
            .admin-header .header-actions {
                display: flex;
                align-items: center;
                gap: 1rem;
            }
            .btn-ghost {
                background: transparent;
                border: none;
                color: var(--muted);
                font-size: 1.2rem;
            }
            .btn-ghost:hover {
                color: var(--ink);
            }

            .admin-sidebar {
                width: 260px;
                flex-shrink: 0;
                background: var(--panel);
                border-right: 1px solid var(--line);
                padding: 1.5rem 1rem;
                min-height: calc(100vh - 65px);
                transition: margin-left 0.3s ease;
            }
            .admin-content-main {
                flex-grow: 1;
                padding: 2.5rem;
                overflow-y: auto;
                background: var(--bg);
            }

            @media (max-width: 768px) {
                .admin-sidebar {
                    position: fixed;
                    z-index: 1000;
                    height: 100%;
                    margin-left: -260px;
                }
                .admin-sidebar.open {
                    margin-left: 0;
                }
            }
        </style>
    </head>
    <body class="admin">

        <div class="admin-header">
            <div class="header-left">
                <button id="btn-toggle-sidebar" class="btn btn-ghost d-md-none">
                    <i class="fas fa-bars"></i>
                </button>
                <div class="luxe-title text-gold" style="font-size:1.4rem;">FurniShop Admin</div>
            </div>
            <div class="header-actions">
                <div style="color:var(--muted); margin-right:1rem;">
                    Xin chào, <strong><c:out value="${sessionScope.account.fullName}" default="Admin"/></strong>
                </div>
                <a href="${path}/logout" class="btn btn-ghost" title="Đăng xuất">
                    <i class="fas fa-sign-out-alt"></i>
                </a>
            </div>
        </div>

        <div class="admin-layout-wrapper">