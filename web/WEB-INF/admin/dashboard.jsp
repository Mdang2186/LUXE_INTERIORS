<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="path" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FurniShop - Future Admin Dashboard</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap"
          rel="stylesheet"/>

    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['"Plus Jakarta Sans"', 'sans-serif'],
                        display: ['"Outfit"', 'sans-serif'],
                    },
                    colors: {
                        neon: {
                            blue: '#4361ee',
                            purple: '#7209b7',
                            pink: '#f72585',
                            cyan: '#4cc9f0'
                        }
                    },
                    boxShadow: {
                        'neon-blue': '0 0 10px rgba(67, 97, 238, 0.3), 0 0 20px rgba(67, 97, 238, 0.1)',
                        'neon-purple': '0 0 10px rgba(114, 9, 183, 0.3), 0 0 20px rgba(114, 9, 183, 0.1)',
                        'neon-pink': '0 0 10px rgba(247, 37, 133, 0.3), 0 0 20px rgba(247, 37, 133, 0.1)',
                        'glass': '0 8px 32px 0 rgba(31, 38, 135, 0.05)',
                    }
                }
            }
        }
    </script>

    <style>
        body {
            background-color: #f0f2f5;
            background-image:
                    radial-gradient(at 0% 0%, rgba(67, 97, 238, 0.05) 0, transparent 50%),
                    radial-gradient(at 100% 0%, rgba(247, 37, 133, 0.05) 0, transparent 50%),
                    radial-gradient(at 100% 100%, rgba(76, 201, 240, 0.05) 0, transparent 50%);
            color: #1e293b;
            overflow: hidden;
        }

        .glass-panel {
            background: rgba(255, 255, 255, 0.7);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.6);
        }

        .sidebar-link {
            transition: all .3s cubic-bezier(0.4, 0, 0.2, 1);
            border-left: 3px solid transparent;
        }

        .sidebar-link:hover {
            background: linear-gradient(90deg, rgba(67, 97, 238, 0.05) 0%, transparent 100%);
            color: #4361ee;
            padding-left: 1.25rem;
        }

        .sidebar-link.active {
            background: linear-gradient(90deg, rgba(67, 97, 238, 0.1) 0%, transparent 100%);
            color: #4361ee;
            border-left-color: #4361ee;
            font-weight: 600;
        }

        .sidebar-link.active i {
            filter: drop-shadow(0 0 5px rgba(67, 97, 238, 0.5));
        }

        .neon-card {
            background: rgba(255, 255, 255, .8);
            border-radius: 1.5rem;
            border: 1px solid rgba(255, 255, 255, .8);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
            transition: all .3s ease;
            overflow: hidden;
            position: relative;
        }

        .neon-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #4361ee, #f72585);
            opacity: 0;
            transition: opacity .3s ease;
        }

        .neon-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 0 15px rgba(67, 97, 238, 0.1);
        }

        .neon-card:hover::before {
            opacity: 1;
        }

        .custom-scroll::-webkit-scrollbar {
            width: 6px;
            height: 6px
        }

        .custom-scroll::-webkit-scrollbar-track {
            background: transparent
        }

        .custom-scroll::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 10px
        }

        .custom-scroll::-webkit-scrollbar-thumb:hover {
            background: #94a3b8
        }

        @keyframes float {
            0%, 100% {
                transform: translateY(0)
            }
            50% {
                transform: translateY(-5px)
            }
        }

        .animate-float {
            animation: float 3s ease-in-out infinite
        }
    </style>
</head>
<body class="flex h-screen w-full font-sans antialiased selection:bg-neon-blue selection:text-white">

<!-- SIDEBAR -->
<aside class="w-72 glass-panel flex flex-col h-full flex-shrink-0 z-50 border-r border-white/50 relative">
    <div class="h-24 flex items-center px-8">
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-neon-blue to-neon-purple flex items-center justify-center text-white shadow-neon-blue">
                <i class="fa-solid fa-couch text-lg"></i>
            </div>
            <div>
                <h1 class="text-xl font-bold font-display tracking-tight text-slate-800">
                    Furni<span class="text-neon-blue">Shop</span>
                </h1>
                <p class="text-[10px] font-bold text-neon-purple tracking-widest uppercase">Admin v2.0</p>
            </div>
        </div>
    </div>

    <nav class="flex-1 px-4 py-4 space-y-1 overflow-y-auto custom-scroll">
        <p class="px-4 text-[11px] font-bold text-slate-400 uppercase tracking-widest mb-3 mt-2">Tổng quan</p>
        <a href="${path}/admin/dashboard"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl active">
            <i class="fa-solid fa-chart-pie w-5 text-center"></i><span>Dashboard</span>
        </a>

        <p class="px-4 text-[11px] font-bold text-slate-400 uppercase tracking-widest mb-3 mt-8">Quản lý</p>
        <a href="${path}/admin/products"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl text-slate-500">
            <i class="fa-solid fa-box-open w-5 text-center"></i><span>Sản phẩm</span>
        </a>
        <a href="${path}/admin/orders"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl text-slate-500">
            <i class="fa-solid fa-receipt w-5 text-center"></i><span>Đơn hàng</span>
        </a>
        <a href="${path}/admin/categories"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl text-slate-500">
            <i class="fa-solid fa-layer-group w-5 text-center"></i><span>Danh mục</span>
        </a>
        <a href="${path}/admin/users"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl text-slate-500">
            <i class="fa-solid fa-users w-5 text-center"></i><span>Người dùng</span>
        </a>

        <!-- Báo cáo & xuất file -->
        <p class="px-4 text-[11px] font-bold text-slate-400 uppercase tracking-widest mb-3 mt-8">
            Báo cáo &amp; Xuất file
        </p>

        

        <a href="${path}/admin/dashboard/export-pdf?from=${from}&to=${to}&year=${year}"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl text-slate-500">
            <i class="fa-solid fa-file-pdf w-5 text-center"></i>
            <span>Báo cáo Dashboard (PDF)</span>
        </a>
    </nav>

    <div class="p-6 border-t border-white/50">
        <div class="flex items-center gap-4 p-3 rounded-2xl bg-gradient-to-r from-white to-slate-50 border border-white shadow-sm cursor-pointer hover:shadow-md transition-all">
            <img src="https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=4361ee&color=fff"
                 class="w-10 h-10 rounded-full border-2 border-white shadow-sm">
            <div class="flex-1 min-w-0">
                <p class="text-sm font-bold text-slate-800 truncate">${sessionScope.account.fullName}</p>
                <p class="text-[10px] font-medium text-slate-400 truncate">Super Admin</p>
            </div>
            <a href="${path}/logout" class="text-slate-400 hover:text-neon-pink transition-colors">
                <i class="fa-solid fa-power-off"></i>
            </a>
        </div>
    </div>
</aside>

<!-- MAIN -->
<main class="flex-1 flex flex-col h-full min-w-0 overflow-hidden relative">

    <!-- HEADER -->
    <header class="h-24 flex items-center justify-between px-10 z-30 shrink-0">
        <div>
            <h2 class="text-2xl font-bold font-display text-slate-800 tracking-tight">Tổng quan</h2>
            <p class="text-sm text-slate-500 font-medium mt-1">
                Chào mừng trở lại! Hệ thống đã cập nhật số liệu mới nhất.
            </p>
        </div>

        <div class="flex items-center gap-4">
            <!-- Tìm kiếm nhanh -->
            <form action="${path}/admin/orders" method="get" class="relative group">
                <input type="text" name="q" value="${param.q}"
                       placeholder="Tìm kiếm đơn / user / sản phẩm..."
                       class="pl-11 pr-20 py-3 rounded-2xl bg-white/80 border-0 shadow-sm ring-1 ring-slate-200
                              focus:ring-2 focus:ring-neon-blue w-80 transition-all outline-none text-sm font-medium">
                <i class="fa-solid fa-magnifying-glass absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-neon-blue transition-colors"></i>
                <button type="submit"
                        class="absolute right-2 top-1/2 -translate-y-1/2 text-[11px] font-bold px-3 py-1 rounded-xl
                               bg-slate-900 text-white hover:bg-neon-blue transition-colors">
                    Tìm
                </button>
            </form>

            <!-- Dropdown export nhanh -->
            <div class="relative">
                <button id="btn-report-menu"
                        class="w-11 h-11 rounded-full bg-white border border-slate-100 shadow-sm flex items-center justify-center
                               text-slate-400 hover:text-neon-blue hover:shadow-neon-blue transition-all">
                    <i class="fa-regular fa-bell text-lg"></i>
                    <span class="absolute top-2.5 right-3 w-2 h-2 bg-neon-pink rounded-full border border-white"></span>
                </button>

                <div id="report-menu"
                     class="hidden absolute right-0 mt-3 w-64 rounded-2xl bg-white shadow-xl border border-slate-100 py-2 text-xs font-medium text-slate-600 z-50">
                    <p class="px-4 py-2 text-[10px] uppercase tracking-widest text-slate-400 font-bold">
                        Xuất nhanh
                    </p>
                  
                    <a href="${path}/admin/dashboard/export-pdf?from=${from}&to=${to}&year=${year}" class="flex items-center gap-2 px-4 py-2 hover:bg-slate-50">
                        <i class="fa-solid fa-file-pdf text-red-500 w-4 text-center"></i> Báo cáo Dashboard (PDF)
                    </a>
                    <div class="border-t border-slate-100 my-2"></div>
                    <p class="px-4 py-2 text-[10px] uppercase tracking-widest text-slate-400 font-bold">
                        Email báo cáo
                    </p>
                    <a href="${path}/admin/report-email-excel" class="flex items-center gap-2 px-4 py-2 hover:bg-slate-50">
                        <i class="fa-solid fa-envelope-open-text text-rose-500 w-4 text-center"></i> Gửi Excel KH VIP
                    </a>
                    <a href="${path}/admin/report-monthly-email" class="flex items-center gap-2 px-4 py-2 hover:bg-slate-50">
                        <i class="fa-solid fa-file-pdf text-red-500 w-4 text-center"></i> Gửi báo cáo tháng (PDF + Excel)
                    </a>
                </div>
            </div>
        </div>
    </header>

    <!-- CONTENT -->
    <div class="flex-1 overflow-y-auto px-10 pb-10 custom-scroll">

        <!-- KPI CARDS -->
        <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6 mb-8">
            <!-- Doanh thu -->
            <div class="neon-card p-6 group">
                <div class="flex justify-between items-start">
                    <div>
                        <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">Doanh thu</p>
                        <h3 class="text-2xl font-bold text-slate-800 mt-2 font-display">
                            <fmt:formatNumber value="${sumRevenueDone}" type="currency" currencyCode="VND"/>
                        </h3>
                        <p class="mt-2 text-xs text-slate-400">
                            Tổng doanh thu các đơn đã hoàn tất.
                        </p>
                    </div>
                    <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-neon-blue to-blue-600 flex items-center justify-center text-white shadow-neon-blue animate-float">
                        <i class="fa-solid fa-sack-dollar text-xl"></i>
                    </div>
                </div>
            </div>

            <!-- Đơn hàng -->
            <div class="neon-card p-6 group">
                <div class="flex justify-between items-start">
                    <div>
                        <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">Đơn hàng</p>
                        <h3 class="text-2xl font-bold text-slate-800 mt-2 font-display">${countOrders}</h3>
                        <p class="text-xs text-slate-400 mt-2 font-medium">
                            Tổng số đơn trong hệ thống.
                        </p>
                    </div>
                    <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-neon-cyan to-teal-400 flex items-center justify-center text-white shadow-lg animate-float" style="animation-delay:.5s;">
                        <i class="fa-solid fa-cart-shopping text-xl"></i>
                    </div>
                </div>
            </div>

            <!-- Sản phẩm + tồn kho -->
            <div class="neon-card p-6 group">
                <div class="flex justify-between items-start">
                    <div>
                        <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">Sản phẩm</p>
                        <h3 class="text-2xl font-bold text-slate-800 mt-2 font-display">${countProducts}</h3>
                        <p class="text-[11px] text-amber-600 mt-2 font-semibold">
                            <i class="fa-solid fa-triangle-exclamation mr-1"></i>
                            Thấp: ${countLowStock} | Hết: ${countOutOfStock}
                        </p>
                    </div>
                    <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-neon-purple to-violet-600 flex items-center justify-center text-white shadow-neon-purple animate-float" style="animation-delay:1s;">
                        <i class="fa-solid fa-couch text-xl"></i>
                    </div>
                </div>
            </div>

            <!-- User + review + contact -->
            <div class="neon-card p-6 group">
                <div class="flex justify-between items-start">
                    <div>
                        <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">Khách hàng</p>
                        <h3 class="text-2xl font-bold text-slate-800 mt-2 font-display">${countUsers}</h3>
                        <p class="text-[11px] text-slate-500 mt-2">
                            Review: <span class="font-semibold text-emerald-600">${countReviews}</span> ·
                            Liên hệ: <span class="font-semibold text-sky-600">${countContacts}</span>
                        </p>
                    </div>
                    <div class="w-12 h-12 rounded-2xl bg-gradient-to-br from-neon-pink to-rose-500 flex items-center justify-center text-white shadow-neon-pink animate-float" style="animation-delay:1.5s;">
                        <i class="fa-solid fa-users text-xl"></i>
                    </div>
                </div>
            </div>
        </div>

        <!-- CHARTS HÀNG 1 -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
            <!-- Revenue line -->
            <div class="neon-card p-6 lg:col-span-2 bg-white">
                <div class="flex justify-between items-center mb-6">
                    <h3 class="font-bold text-lg text-slate-800 font-display">Biểu đồ doanh thu theo ngày</h3>
                    <form action="${path}/admin/dashboard" method="GET"
                          class="flex flex-wrap gap-2 bg-slate-50 p-1 rounded-xl border border-slate-100 text-xs">
                        <input type="date" name="from" value="${from}"
                               class="bg-transparent font-bold text-slate-600 px-2 py-1 outline-none">
                        <span class="text-slate-300">→</span>
                        <input type="date" name="to" value="${to}"
                               class="bg-transparent font-bold text-slate-600 px-2 py-1 outline-none">
                        <button class="bg-white text-neon-blue shadow-sm px-3 py-1 rounded-lg font-bold hover:text-neon-purple transition-colors">
                            <i class="fa-solid fa-filter"></i>
                        </button>
                    </form>
                </div>
                <div class="relative h-72 w-full">
                    <canvas id="revenueChart"></canvas>
                </div>
            </div>

            <!-- Status doughnut -->
            <div class="neon-card p-6 bg-white flex flex-col justify-center">
                <h3 class="font-bold text-lg text-slate-800 font-display mb-4 text-center">Trạng thái đơn hàng</h3>
                <div class="relative h-64 w-full flex items-center justify-center">
                    <canvas id="statusChart"></canvas>
                    <div class="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                        <span class="text-3xl font-bold text-slate-800 font-display">${countOrders}</span>
                        <span class="text-[10px] uppercase font-bold text-slate-400 tracking-wider">Tổng đơn</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- CHARTS HÀNG 2: Category + User Month -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
            <!-- Revenue by category -->
            <div class="neon-card p-6 bg-white">
                <div class="flex justify-between items-center mb-4">
                    <h3 class="font-bold text-lg text-slate-800 font-display">
                        Doanh thu theo danh mục
                    </h3>
                </div>
                <div class="relative h-64 w-full">
                    <canvas id="catChart"></canvas>
                </div>
            </div>

            <!-- New users by month -->
            <div class="neon-card p-6 bg-white">
                <div class="flex justify-between items-center mb-4">
                    <h3 class="font-bold text-lg text-slate-800 font-display">
                        User mới theo tháng
                    </h3>
                    <form action="${path}/admin/dashboard" method="GET"
                          class="flex items-center gap-2 text-xs">
                        <label class="text-slate-400">Năm</label>
                        <input type="number" name="year" value="${year}"
                               class="w-20 bg-slate-50 border border-slate-200 rounded-lg px-2 py-1 text-center text-sm outline-none">
                        <button class="bg-slate-900 text-white px-3 py-1 rounded-lg font-bold hover:bg-neon-blue transition-colors">
                            Xem
                        </button>
                    </form>
                </div>
                <div class="relative h-64 w-full">
                    <canvas id="userMonthChart"></canvas>
                </div>
            </div>
        </div>

        <!-- XUẤT BÁO CÁO NHANH: PDF DASHBOARD + EMAIL + CSV -->
        <div class="mb-8">
            <div class="neon-card p-6 bg-white">
                <div class="flex items-center justify-between mb-4">
                    <h3 class="font-bold text-lg text-slate-800 font-display">
                        Xuất báo cáo nhanh
                    </h3>
                    <span class="text-[11px] text-slate-400">
                        PDF tổng quan Dashboard · CSV khách hàng
                    </span>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
                    

                    

                    <a href="${path}/admin/dashboard/export-pdf?from=${from}&to=${to}&year=${year}"
                       class="inline-flex items-center justify-between px-4 py-3 rounded-xl bg-slate-50 hover:bg-white hover:shadow-md border border-slate-100 hover:border-neon-purple transition-all text-sm font-semibold text-slate-700">
                        <span>Báo cáo Dashboard (PDF)</span>
                        <i class="fa-solid fa-file-pdf"></i>
                    </a>

                    <!-- Form gửi báo cáo Dashboard qua email -->
                    <form action="${path}/admin/dashboard/email-pdf"
                          method="post"
                          class="inline-flex items-center gap-2 px-4 py-3 rounded-xl bg-slate-50 hover:bg-white hover:shadow-md border border-slate-100 transition-all text-sm font-semibold text-slate-700 md:col-span-2">
                        <input type="email" name="email"
                               placeholder="Nhập email để gửi báo cáo Dashboard (PDF)..."
                               required
                               class="flex-1 bg-transparent outline-none text-sm text-slate-700 placeholder:text-slate-400">
                        <input type="hidden" name="from" value="${from}">
                        <input type="hidden" name="to" value="${to}">
                        <input type="hidden" name="year" value="${year}">
                        <button type="submit"
                                class="px-3 py-1.5 rounded-lg bg-slate-900 text-white text-xs font-bold hover:bg-neon-blue transition-colors">
                            Gửi báo cáo PDF
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- CÔNG CỤ HÓA ĐƠN / PDF -->
        <div class="mb-8">
            <div class="neon-card p-6 bg-white">
                <div class="flex items-center justify-between mb-4">
                    <h3 class="font-bold text-lg text-slate-800 font-display">
                        Công cụ hóa đơn (PDF & Email)
                    </h3>
                    <span class="text-[11px] text-slate-400">
                        Nhập mã đơn để thao tác nhanh
                    </span>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 items-center">
                    <div>
                        <label for="invoiceOrderId" class="block text-xs font-bold text-slate-500 mb-1">
                            Mã đơn hàng
                        </label>
                        <input id="invoiceOrderId" type="number" min="1"
                               class="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-neon-blue focus:border-neon-blue"
                               placeholder="Nhập mã đơn, ví dụ: 101">
                        <p class="mt-1 text-[11px] text-slate-400">
                            Sử dụng: /admin/order-invoice, /admin/orders/invoice/download, /admin/orders/invoice-email
                        </p>
                    </div>
                    <div class="flex flex-wrap gap-2 md:justify-end">
                        <button type="button"
                                onclick="openInvoiceView()"
                                class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-900 text-white text-xs font-semibold hover:bg-neon-blue transition-colors">
                            <i class="fa-solid fa-eye"></i> Xem hóa đơn PDF
                        </button>
                        <button type="button"
                                onclick="openInvoiceDownload()"
                                class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-50 text-slate-700 text-xs font-semibold border border-slate-200 hover:border-neon-blue hover:bg-white transition-colors">
                            <i class="fa-solid fa-download"></i> Tải hóa đơn PDF
                        </button>
                        <button type="button"
                                onclick="sendInvoiceEmail()"
                                class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-emerald-500 text-white text-xs font-semibold hover:bg-emerald-600 transition-colors">
                            <i class="fa-solid fa-paper-plane"></i> Gửi email hóa đơn
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- TOP PRODUCTS + LOW STOCK -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <!-- TOP PRODUCTS -->
            <div class="neon-card p-6 bg-white">
                <div class="flex justify-between items-center mb-6">
                    <h3 class="font-bold text-lg text-slate-800 font-display">Sản phẩm bán chạy</h3>
                    <span class="text-[10px] font-bold text-white bg-gradient-to-r from-neon-blue to-neon-purple px-2.5 py-1 rounded-full shadow-sm">
                        Top ${fn:length(topProducts)}
                    </span>
                </div>
                <div class="space-y-4">
                    <c:choose>
                        <c:when test="${empty topProducts}">
                            <p class="text-sm text-slate-400">Chưa có dữ liệu bán hàng.</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${topProducts}" var="tp" varStatus="loop">
                                <div class="flex items-center gap-4 p-3 rounded-2xl bg-slate-50 hover:bg-white hover:shadow-md hover:shadow-indigo-500/10 border border-transparent hover:border-indigo-100 transition-all cursor-pointer group">
                                    <div class="w-10 h-10 rounded-xl flex-shrink-0 flex items-center justify-center font-bold text-white shadow-sm
                                        ${loop.index == 0 ? 'bg-gradient-to-br from-amber-300 to-orange-500' :
                                          loop.index == 1 ? 'bg-gradient-to-br from-slate-300 to-slate-500' :
                                          loop.index == 2 ? 'bg-gradient-to-br from-orange-300 to-amber-600' :
                                          'bg-slate-200 text-slate-500'}">
                                        ${loop.index + 1}
                                    </div>
                                    <div class="flex-1 min-w-0">
                                        <h4 class="text-sm font-bold text-slate-700 truncate group-hover:text-neon-blue transition-colors">
                                            ${tp.productName}
                                        </h4>
                                        <p class="text-xs text-slate-400 font-medium">
                                            Đã bán: <span class="text-slate-600">${tp.quantity}</span>
                                        </p>
                                    </div>
                                    <div class="w-8 h-8 rounded-full bg-white flex items-center justify-center text-slate-300 group-hover:text-neon-blue group-hover:shadow-sm transition-all">
                                        <i class="fa-solid fa-chevron-right text-xs"></i>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- LOW STOCK TABLE -->
            <div class="neon-card p-0 lg:col-span-2 overflow-hidden bg-white">
                <div class="p-6 border-b border-slate-100 flex justify-between items-center bg-white/60 backdrop-blur-sm">
                    <h3 class="font-bold text-lg text-slate-800 font-display flex items-center gap-2">
                        <span class="w-2 h-6 rounded-full bg-neon-pink"></span>
                        Cảnh báo tồn kho
                    </h3>
                    <a href="${path}/admin/products"
                       class="text-xs font-bold text-neon-blue hover:text-neon-purple transition-colors bg-blue-50 px-3 py-1.5 rounded-lg">
                        Xem tất cả <i class="fa-solid fa-arrow-right ml-1"></i>
                    </a>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm">
                        <thead>
                        <tr class="bg-slate-50/80 text-xs font-bold text-slate-400 uppercase tracking-wider">
                            <th class="px-6 py-4">ID</th>
                            <th class="px-6 py-4">Tên sản phẩm</th>
                            <th class="px-6 py-4 text-center">Trạng thái</th>
                            <th class="px-6 py-4 text-right">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-50">
                        <c:choose>
                            <c:when test="${empty lowStockProducts}">
                                <tr>
                                    <td colspan="4" class="px-6 py-6 text-center text-sm text-slate-400">
                                        Kho đang ổn định, chưa có sản phẩm nào dưới ngưỡng cảnh báo.
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${lowStockProducts}" var="p">
                                    <tr class="hover:bg-indigo-50/30 transition-colors">
                                        <td class="px-6 py-4 font-mono text-slate-400 text-xs">#${p.productID}</td>
                                        <td class="px-6 py-4">
                                            <span class="font-bold text-slate-700">${p.productName}</span>
                                        </td>
                                        <td class="px-6 py-4 text-center">
                                            <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[10px] font-bold border
                                                ${p.stock == 0 ? 'bg-red-50 text-red-600 border-red-100' : 'bg-amber-50 text-amber-600 border-amber-100'}">
                                                <span class="w-1.5 h-1.5 rounded-full
                                                    ${p.stock == 0 ? 'bg-red-500' : 'bg-amber-500'} animate-pulse"></span>
                                                <c:choose>
                                                    <c:when test="${p.stock == 0}">Hết hàng</c:when>
                                                    <c:otherwise>${p.stock} còn lại</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </td>
                                        <td class="px-6 py-4 text-right">
                                            <a href="${path}/admin/products?action=edit&id=${p.productID}"
                                               class="text-xs font-bold text-slate-500 hover:text-neon-blue bg-white border border-slate-200 hover:border-neon-blue px-3 py-1.5 rounded-lg transition-all shadow-sm">
                                                Nhập hàng
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- FOOTER -->
        <div class="mt-8 pt-6 border-t border-slate-200 flex flex-col md:flex-row justify-between items-center text-xs text-slate-400 font-medium">
            <p>&copy; 2025 FurniShop Admin System. Design with
                <i class="fa-solid fa-heart text-neon-pink mx-1"></i> by Nhom2.
            </p>
            <div class="flex gap-4 mt-2 md:mt-0">
                <a href="#" class="hover:text-neon-blue transition-colors">Support</a>
                <a href="#" class="hover:text-neon-blue transition-colors">Terms</a>
            </div>
        </div>

    </div>
</main>

<script>
    // Toggle menu báo cáo
    const btnReport = document.getElementById('btn-report-menu');
    const reportMenu = document.getElementById('report-menu');
    if (btnReport && reportMenu) {
        btnReport.addEventListener('click', function (e) {
            e.stopPropagation();
            reportMenu.classList.toggle('hidden');
        });
        document.addEventListener('click', function () {
            reportMenu.classList.add('hidden');
        });
    }

    const ctxPath = '${path}';

    function getInvoiceOrderId() {
        const input = document.getElementById('invoiceOrderId');
        const id = input.value.trim();
        if (!id) {
            alert('Vui lòng nhập mã đơn hàng');
            input.focus();
            return null;
        }
        if (isNaN(id) || parseInt(id) <= 0) {
            alert('Mã đơn không hợp lệ');
            input.focus();
            return null;
        }
        return id;
    }

    function openInvoiceView() {
        const id = getInvoiceOrderId();
        if (!id) return;
        const url = ctxPath + '/admin/order-invoice?id=' + encodeURIComponent(id);
        window.open(url, '_blank');
    }

    function openInvoiceDownload() {
        const id = getInvoiceOrderId();
        if (!id) return;
        const url = ctxPath + '/admin/orders/invoice/download?id=' + encodeURIComponent(id);
        window.location.href = url;
    }

    function sendInvoiceEmail() {
        const id = getInvoiceOrderId();
        if (!id) return;

        fetch(ctxPath + '/admin/orders/invoice-email', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: 'id=' + encodeURIComponent(id)
        })
            .then(res => res.text())
            .then(text => {
                alert(text || 'Đã gửi hóa đơn (nếu không có lỗi từ server).');
            })
            .catch(err => {
                console.error(err);
                alert('Lỗi khi gửi email hóa đơn.');
            });
    }

    // Chart.js defaults
    Chart.defaults.font.family = "'Plus Jakarta Sans', sans-serif";
    Chart.defaults.color = '#94a3b8';

    // ===== Revenue line =====
    const revCanvas = document.getElementById('revenueChart');
    const revLabels = [
        <c:forEach items="${revLabels}" var="l" varStatus="st">
            "${l}"<c:if test="${!st.last}">,</c:if>
        </c:forEach>
    ];
    const revValues = [
        <c:forEach items="${revValues}" var="v" varStatus="st">
            ${v}<c:if test="${!st.last}">,</c:if>
        </c:forEach>
    ];

    if (revCanvas && revLabels.length > 0) {
        const ctxRev = revCanvas.getContext('2d');
        const gradientRev = ctxRev.createLinearGradient(0, 0, 0, 300);
        gradientRev.addColorStop(0, 'rgba(67, 97, 238, 0.4)');
        gradientRev.addColorStop(1, 'rgba(67, 97, 238, 0.0)');

        new Chart(ctxRev, {
            type: 'line',
            data: {
                labels: revLabels,
                datasets: [{
                    label: 'Doanh thu',
                    data: revValues,
                    backgroundColor: gradientRev,
                    borderColor: '#4361ee',
                    borderWidth: 3,
                    pointBackgroundColor: '#fff',
                    pointBorderColor: '#4361ee',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    pointHoverRadius: 6,
                    pointHoverBackgroundColor: '#4361ee',
                    pointHoverBorderColor: '#fff',
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {legend: {display: false}},
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {borderDash: [5, 5], color: '#f1f5f9'},
                        ticks: {
                            font: {size: 11, weight: '500'},
                            callback: value => value >= 1000000 ? (value / 1000000) + 'M' : value
                        }
                    },
                    x: {
                        grid: {display: false},
                        ticks: {font: {size: 11}}
                    }
                }
            }
        });
    }

    // ===== Status doughnut =====
    const statusCanvas = document.getElementById('statusChart');
    const statusLabels = [
        <c:forEach items="${statusLabels}" var="l" varStatus="st">
            "${l}"<c:if test="${!st.last}">,</c:if>
        </c:forEach>
    ];
    const statusValues = [
        <c:forEach items="${statusValues}" var="v" varStatus="st">
            ${v}<c:if test="${!st.last}">,</c:if>
        </c:forEach>
    ];

    if (statusCanvas && statusLabels.length > 0) {
        new Chart(statusCanvas, {
            type: 'doughnut',
            data: {
                labels: statusLabels,
                datasets: [{
                    data: statusValues,
                    backgroundColor: [
                        '#f72585',
                        '#4361ee',
                        '#4cc9f0',
                        '#7209b7',
                        '#3a0ca3',
                        '#fb8500'
                    ],
                    borderWidth: 0,
                    hoverOffset: 5
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '78%',
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            usePointStyle: true,
                            padding: 20,
                            font: {size: 11, weight: '600'}
                        }
                    }
                }
            }
        });
    }

    // ===== Category revenue bar =====
    const catCanvas = document.getElementById('catChart');
    const catLabels = [
        <c:forEach items="${catLabels}" var="l" varStatus="st">
            "${l}"<c:if test="${!st.last}">,</c:if>
        </c:forEach>
    ];
    const catValues = [
        <c:forEach items="${catValues}" var="v" varStatus="st">
            ${v}<c:if test="${!st.last}">,</c:if>
        </c:forEach>
    ];

    if (catCanvas && catLabels.length > 0) {
        new Chart(catCanvas.getContext('2d'), {
            type: 'bar',
            data: {
                labels: catLabels,
                datasets: [{
                    label: 'Doanh thu',
                    data: catValues,
                    backgroundColor: '#4361ee',
                    borderRadius: 10,
                    maxBarThickness: 28
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {legend: {display: false}},
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {borderDash: [4, 4], color: '#e2e8f0'},
                        ticks: {font: {size: 11}}
                    },
                    x: {
                        grid: {display: false},
                        ticks: {font: {size: 11}}
                    }
                }
            }
        });
    }

    // ===== New users by month bar =====
    const userMonthCanvas = document.getElementById('userMonthChart');
    const userMonthLabels = [
        <c:forEach items="${userMonthLabels}" var="l" varStatus="st">
            "${l}"<c:if test="${!st.last}">,</c:if>
        </c:forEach>
    ];
    const userMonthValues = [
        <c:forEach items="${userMonthValues}" var="v" varStatus="st">
            ${v}<c:if test="${!st.last}">,</c:if>
        </c:forEach>
    ];

    if (userMonthCanvas && userMonthLabels.length > 0) {
        new Chart(userMonthCanvas.getContext('2d'), {
            type: 'bar',
            data: {
                labels: userMonthLabels,
                datasets: [{
                    label: 'User mới',
                    data: userMonthValues,
                    backgroundColor: '#f72585',
                    borderRadius: 10,
                    maxBarThickness: 24
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {legend: {display: false}},
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {borderDash: [4, 4], color: '#e2e8f0'},
                        ticks: {font: {size: 11}}
                    },
                    x: {
                        grid: {display: false},
                        ticks: {font: {size: 10, maxRotation: 0, minRotation: 0}}
                    }
                }
            }
        });
    }
</script>
</body>
</html>
