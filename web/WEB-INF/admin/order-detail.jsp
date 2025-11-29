<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="path" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết đơn #${order != null ? order.orderID : 'N/A'} - FurniShop</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap"
          rel="stylesheet">

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
                        'glass': '0 8px 32px 0 rgba(31, 38, 135, 0.05)',
                    }
                }
            }
        }
    </script>

    <style>
        body{
            background-color:#f0f2f5;
            background-image:
                radial-gradient(at 0% 0%, rgba(67, 97, 238, 0.05) 0, transparent 50%),
                radial-gradient(at 100% 0%, rgba(247, 37, 133, 0.05) 0, transparent 50%),
                radial-gradient(at 100% 100%, rgba(76, 201, 240, 0.05) 0, transparent 50%);
            color:#1e293b;
            overflow:hidden;
        }
        .glass-panel{
            background:rgba(255,255,255,0.7);
            backdrop-filter:blur(20px);
            -webkit-backdrop-filter:blur(20px);
            border:1px solid rgba(255,255,255,0.6);
        }
        .sidebar-link{
            transition:all .3s cubic-bezier(0.4,0,0.2,1);
            border-left:3px solid transparent;
        }
        .sidebar-link:hover{
            background:linear-gradient(90deg,rgba(67,97,238,0.05) 0%,transparent 100%);
            color:#4361ee;
            padding-left:1.25rem;
        }
        .sidebar-link.active{
            background:linear-gradient(90deg,rgba(67,97,238,0.1) 0%,transparent 100%);
            color:#4361ee;
            border-left-color:#4361ee;
            font-weight:600;
        }
        .neon-card{
            background:rgba(255,255,255,.9);
            border-radius:1.5rem;
            border:1px solid rgba(255,255,255,.95);
            box-shadow:0 4px 6px -1px rgba(0,0,0,0.02);
            position:relative;
            overflow:hidden;
            transition:all .3s ease;
        }
        .neon-card::before{
            content:'';
            position:absolute;
            top:0;left:0;right:0;height:4px;
            background:linear-gradient(90deg,#4361ee,#f72585);
            opacity:0;
            transition:opacity .3s ease;
        }
        .neon-card:hover{
            transform:translateY(-4px);
            box-shadow:0 20px 25px -5px rgba(0,0,0,0.05),0 0 15px rgba(67,97,238,0.12);
        }
        .neon-card:hover::before{opacity:1;}
        .custom-scroll::-webkit-scrollbar{width:6px;height:6px}
        .custom-scroll::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:999px}
        .custom-scroll::-webkit-scrollbar-thumb:hover{background:#94a3b8}
    </style>
</head>

<body class="flex h-screen w-full font-sans antialiased selection:bg-neon-blue selection:text-white">

<!-- ========== SIDEBAR ========== -->
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
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl text-slate-500">
            <i class="fa-solid fa-chart-pie w-5 text-center"></i> <span>Dashboard</span>
        </a>

        <p class="px-4 text-[11px] font-bold text-slate-400 uppercase tracking-widest mb-3 mt-8">Quản lý</p>
        <a href="${path}/admin/products"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl text-slate-500">
            <i class="fa-solid fa-box-open w-5 text-center"></i> <span>Sản phẩm</span>
        </a>
        <a href="${path}/admin/orders"
           class="sidebar-link active flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl">
            <i class="fa-solid fa-receipt w-5 text-center"></i> <span>Đơn hàng</span>
        </a>
        <a href="${path}/admin/users"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl text-slate-500">
            <i class="fa-solid fa-users w-5 text-center"></i> <span>Người dùng</span>
        </a>
    </nav>

    <div class="p-6 border-t border-white/50">
        <div class="flex items-center gap-4 p-3 rounded-2xl bg-gradient-to-r from-white to-slate-50 border border-white shadow-sm">
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

<!-- ========== MAIN ========== -->
<main class="flex-1 flex flex-col h-full min-w-0 overflow-hidden relative">

    <!-- Khi không có order (controller set order = null hoặc redirect) -->
    <c:if test="${order == null}">
        <section class="flex-1 flex items-center justify-center px-10">
            <div class="neon-card max-w-md w-full p-8 text-center">
                <div class="w-12 h-12 rounded-2xl bg-rose-50 text-rose-500 flex items-center justify-center mx-auto mb-4">
                    <i class="fa-solid fa-circle-exclamation text-xl"></i>
                </div>
                <h2 class="text-lg font-bold mb-2 text-slate-800">Không tìm thấy đơn hàng</h2>
                <p class="text-sm text-slate-500 mb-4">
                    Đơn hàng bạn yêu cầu không tồn tại hoặc đã bị xóa khỏi hệ thống.
                </p>
                <a href="${path}/admin/orders"
                   class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-slate-900 text-white text-sm">
                    <i class="fa-solid fa-arrow-left text-xs"></i>
                    Quay lại danh sách đơn hàng
                </a>
            </div>
        </section>
    </c:if>

    <c:if test="${order != null}">

        <!-- ========== HEADER ========== -->
        <header class="h-24 flex items-center justify-between px-10 z-30 shrink-0">
            <div>
                <a href="${path}/admin/orders"
                   class="inline-flex items-center gap-2 text-xs text-slate-500 hover:text-neon-blue mb-1">
                    <i class="fa-solid fa-arrow-left text-[10px]"></i> Quay lại danh sách
                </a>
                <div class="flex items-center gap-3 flex-wrap">
                    <h2 class="text-2xl font-bold font-display text-slate-800 tracking-tight">
                        Đơn hàng #${order.orderID}
                    </h2>
                    <!-- Badge trạng thái hiện tại -->
                    <span class="inline-flex px-2.5 py-1 rounded-full text-[11px] font-semibold
                        ${order.status=='Pending'   ? 'bg-amber-50 text-amber-700' :
                          order.status=='Confirmed' ? 'bg-sky-50 text-sky-700' :
                          order.status=='Packing'   ? 'bg-blue-50 text-blue-700' :
                          order.status=='Shipping'  ? 'bg-indigo-50 text-indigo-700' :
                          order.status=='Done'      ? 'bg-emerald-50 text-emerald-700' :
                          'bg-rose-50 text-rose-700'}">
                        ${order.status}
                    </span>
                </div>
                <p class="text-sm text-slate-500 font-medium mt-1">
                    Đặt lúc
                    <fmt:formatDate value="${order.orderDate}" pattern="HH:mm dd/MM/yyyy"/>
                </p>
            </div>

            <!-- Tổng tiền quick view -->
            <div class="hidden md:flex flex-col items-end">
                <p class="text-xs text-slate-400 mb-1">Tổng thanh toán</p>
                <p class="text-2xl font-bold font-display text-slate-800">
                    <fmt:formatNumber value="${order.totalAmount}" type="number" pattern="#,##0"/> ₫
                </p>
            </div>
        </header>

        <!-- ========== SCROLL WRAPPER ========== -->
        <section class="flex-1 overflow-y-auto px-10 pb-10 custom-scroll">

            <!-- Flash message -->
            <c:if test="${not empty sessionScope.success}">
                <div class="mb-4 px-4 py-3 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-sm flex items-start gap-2">
                    <i class="fa-solid fa-circle-check mt-0.5"></i>
                    <span>${sessionScope.success}</span>
                </div>
                <c:remove var="success" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.error}">
                <div class="mb-4 px-4 py-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-700 text-sm flex items-start gap-2">
                    <i class="fa-solid fa-circle-exclamation mt-0.5"></i>
                    <span>${sessionScope.error}</span>
                </div>
                <c:remove var="error" scope="session"/>
            </c:if>

            <!-- ========== KHỐI TRÊN: THÔNG TIN + HÀNH ĐỘNG ========== -->
            <section class="grid grid-cols-1 xl:grid-cols-3 gap-6 mb-6">

                <!-- 2/3 trái: thông tin đơn + khách -->
                <div class="space-y-6 xl:col-span-2">

                    <!-- Thông tin đơn + timeline -->
                    <div class="neon-card p-6">
                        <div class="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-6">
                            <div class="flex-1">
                                <h3 class="text-lg font-bold font-display text-slate-800 mb-3">
                                    Thông tin đơn hàng
                                </h3>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-y-2 text-sm text-slate-600">
                                    <div>
                                        <span class="text-xs text-slate-400">Mã đơn</span><br/>
                                        <span class="font-semibold">#${order.orderID}</span>
                                    </div>
                                    <div>
                                        <span class="text-xs text-slate-400">Mã khách</span><br/>
                                        <span class="font-semibold">#${order.userID}</span>
                                    </div>
                                    <div>
                                        <span class="text-xs text-slate-400">Ngày đặt</span><br/>
                                        <fmt:formatDate value="${order.orderDate}" pattern="HH:mm dd/MM/yyyy"/>
                                    </div>
                                    <div>
                                        <span class="text-xs text-slate-400">Phương thức thanh toán</span><br/>
                                        <span class="inline-flex px-2 py-1 rounded-full bg-slate-100 text-xs font-semibold">
                                            ${order.paymentMethod}
                                        </span>
                                    </div>
                                    <div class="md:col-span-2 mt-2">
                                        <span class="text-xs text-slate-400">Địa chỉ giao hàng</span><br/>
                                        <span>${order.shippingAddress}</span>
                                    </div>
                                    <div class="md:col-span-2 mt-2">
                                        <span class="text-xs text-slate-400">Ghi chú</span><br/>
                                        <span>${empty order.note ? '—' : order.note}</span>
                                    </div>
                                </div>
                            </div>

                            <!-- Timeline flow 1 chiều -->
                            <div class="w-full lg:w-72">
                                <h3 class="text-xs font-bold text-slate-500 uppercase tracking-[0.18em] mb-3">
                                    Tiến trình đơn hàng
                                </h3>

                                <c:set var="shipStatus" value="${order.status}" />

                                <div class="flex items-center gap-3 text-xs">
                                    <!-- Pending -->
                                    <div class="flex items-center gap-2">
                                        <div class="w-7 h-7 rounded-full grid place-items-center text-[11px]
                                            bg-emerald-500 text-white">
                                            <i class="fa-solid fa-check"></i>
                                        </div>
                                        <span class="font-semibold text-slate-700">Pending</span>
                                    </div>
                                    <div class="flex-1 h-px bg-slate-200"></div>

                                    <!-- Confirmed -->
                                    <div class="flex items-center gap-2">
                                        <div class="w-7 h-7 rounded-full grid place-items-center text-[11px]
                                            ${shipStatus=='Confirmed' || shipStatus=='Packing' || shipStatus=='Shipping' || shipStatus=='Done'
                                                ? 'bg-emerald-500 text-white' : 'bg-slate-200 text-slate-600'}">
                                            <i class="fa-solid ${shipStatus=='Confirmed' || shipStatus=='Packing' || shipStatus=='Shipping' || shipStatus=='Done'
                                                ? 'fa-check' : 'fa-circle'}"></i>
                                        </div>
                                        <span class="font-semibold text-slate-700">Confirmed</span>
                                    </div>
                                    <div class="flex-1 h-px bg-slate-200"></div>

                                    <!-- Packing -->
                                    <div class="flex items-center gap-2">
                                        <div class="w-7 h-7 rounded-full grid place-items-center text-[11px]
                                            ${shipStatus=='Packing' || shipStatus=='Shipping' || shipStatus=='Done'
                                                ? 'bg-emerald-500 text-white' : 'bg-slate-200 text-slate-600'}">
                                            <i class="fa-solid ${shipStatus=='Packing' || shipStatus=='Shipping' || shipStatus=='Done'
                                                ? 'fa-check' : 'fa-circle'}"></i>
                                        </div>
                                        <span class="font-semibold text-slate-700">Packing</span>
                                    </div>
                                    <div class="flex-1 h-px bg-slate-200"></div>

                                    <!-- Shipping -->
                                    <div class="flex items-center gap-2">
                                        <div class="w-7 h-7 rounded-full grid place-items-center text-[11px]
                                            ${shipStatus=='Shipping' || shipStatus=='Done'
                                                ? 'bg-emerald-500 text-white' : 'bg-slate-200 text-slate-600'}">
                                            <i class="fa-solid ${shipStatus=='Shipping' || shipStatus=='Done'
                                                ? 'fa-check' : 'fa-circle'}"></i>
                                        </div>
                                        <span class="font-semibold text-slate-700">Shipping</span>
                                    </div>
                                    <div class="flex-1 h-px bg-slate-200"></div>

                                    <!-- Done -->
                                    <div class="flex items-center gap-2">
                                        <div class="w-7 h-7 rounded-full grid place-items-center text-[11px]
                                            ${shipStatus=='Done'
                                                ? 'bg-emerald-500 text-white' : 'bg-slate-200 text-slate-600'}">
                                            <i class="fa-solid ${shipStatus=='Done'
                                                ? 'fa-check' : 'fa-circle'}"></i>
                                        </div>
                                        <span class="font-semibold text-slate-700">Done</span>
                                    </div>
                                </div>

                                <!-- Nếu bị hủy thì show badge riêng -->
                                <c:if test="${order.status == 'Canceled'}">
                                    <div class="mt-4 text-xs text-rose-600 bg-rose-50 border border-rose-200 px-3 py-2 rounded-lg">
                                        Đơn hàng này đã <strong>canceled</strong> theo yêu cầu hoặc do hệ thống.
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <!-- Thông tin khách hàng -->
                    <div class="neon-card p-6">
                        <h3 class="text-sm font-bold text-slate-700 mb-3">
                            Thông tin khách hàng
                        </h3>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-y-2 text-sm text-slate-600">
                            <div>
                                <span class="text-xs text-slate-400">Họ tên</span><br/>
                                <span class="font-semibold">
                                    <c:choose>
                                        <c:when test="${user != null && not empty user.fullName}">
                                            ${user.fullName}
                                        </c:when>
                                        <c:otherwise>
                                            User #${order.userID}
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div>
                                <span class="text-xs text-slate-400">Email</span><br/>
                                <span>${user != null ? user.email : '—'}</span>
                            </div>
                            <div>
                                <span class="text-xs text-slate-400">SĐT</span><br/>
                                <span>${user != null ? user.phone : '—'}</span>
                            </div>
                            <div>
                                <span class="text-xs text-slate-400">Mã khách hàng</span><br/>
                                <span>#${order.userID}</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 1/3 phải: Hành động + tổng thanh toán -->
                <div class="space-y-6">

                    <!-- Hành động nhanh -->
                    <div class="neon-card p-6">
                        <h3 class="text-sm font-bold text-slate-700 mb-4">
                            Hành động nhanh
                        </h3>
                        <div class="space-y-3">

                            <!-- PDF hóa đơn -->
                            <a href="${path}/admin/order-invoice?id=${order.orderID}"
                               target="_blank"
                               class="w-full inline-flex items-center justify-between gap-2 text-xs px-4 py-3 rounded-xl bg-white border border-slate-200 hover:border-neon-blue hover:bg-slate-50 text-slate-700 transition-all">
                                <span class="flex items-center gap-2">
                                    <i class="fa-solid fa-file-pdf text-red-500"></i>
                                    Xuất hóa đơn PDF
                                </span>
                                <i class="fa-solid fa-arrow-up-right-from-square text-[10px]"></i>
                            </a>

                            <!-- Gửi email đơn hàng -->
                            <form action="${path}/admin/orders" method="post">
                                <input type="hidden" name="action" value="send-order-email"/>
                                <input type="hidden" name="id" value="${order.orderID}"/>
                                <button type="submit"
                                        class="w-full inline-flex items-center justify-between gap-2 text-xs px-4 py-3 rounded-xl bg-white border border-slate-200 hover:border-neon-blue hover:bg-slate-50 text-slate-700 transition-all">
                                    <span class="flex items-center gap-2">
                                        <i class="fa-solid fa-envelope-circle-check text-emerald-500"></i>
                                        Gửi email thông tin đơn
                                    </span>
                                    <i class="fa-solid fa-paper-plane text-[10px]"></i>
                                </button>
                            </form>

                            <!-- Cập nhật trạng thái 1 chiều -->
                            <c:if test="${not empty nextStatuses}">
                                <form action="${path}/admin/orders" method="post" class="pt-2">
                                    <input type="hidden" name="action" value="status"/>
                                    <input type="hidden" name="id" value="${order.orderID}"/>

                                    <p class="text-[11px] font-semibold text-slate-500 mb-2">
                                        Cập nhật trạng thái đơn hàng
                                    </p>
                                    <div class="flex items-center gap-2 bg-slate-900 text-white rounded-xl px-3 py-2.5 shadow-neon-blue">
                                        <select name="status"
                                                class="flex-1 bg-transparent border-none text-xs font-semibold focus:outline-none pr-1">
                                            <c:forEach items="${nextStatuses}" var="st">
                                                <option value="${st}">${st}</option>
                                            </c:forEach>
                                        </select>
                                        <button type="submit" class="text-[11px] font-semibold inline-flex items-center gap-1">
                                            <i class="fa-solid fa-rotate-right text-xs"></i>
                                            Cập nhật
                                        </button>
                                    </div>
                                    <p class="mt-1 text-[10px] text-slate-400">
                                        Chỉ cho phép chuyển tiếp theo luồng (Pending → Confirmed → Packing → Shipping → Done) hoặc hủy (Canceled).
                                    </p>
                                </form>
                            </c:if>

                            <c:if test="${empty nextStatuses}">
                                <p class="mt-2 text-[11px] text-slate-400">
                                    Đơn hàng đã ở trạng thái cuối cùng (<strong>${order.status}</strong>), không thể cập nhật thêm.
                                </p>
                            </c:if>
                        </div>
                    </div>

                    <!-- Tổng thanh toán -->
                    <div class="neon-card p-6">
                        <h3 class="text-sm font-bold text-slate-700 mb-3">
                            Tổng thanh toán
                        </h3>
                        <p class="text-xs text-slate-400 mb-1">Tổng tiền đơn hàng</p>
                        <p class="text-2xl font-bold font-display text-slate-800 mb-2">
                            <fmt:formatNumber value="${order.totalAmount}" type="number" pattern="#,##0"/> ₫
                        </p>
                        <p class="text-[11px] text-slate-400 italic">
                            Đã bao gồm tất cả sản phẩm trong đơn. Phí vận chuyển (nếu có) xử lý riêng theo cấu hình hệ thống.
                        </p>
                    </div>
                </div>
            </section>

            <!-- ========== DANH SÁCH SẢN PHẨM TRONG ĐƠN ========== -->
            <section class="neon-card p-6">
                <h3 class="text-sm font-bold text-slate-700 mb-4">
                    Sản phẩm trong đơn
                </h3>

                <div class="overflow-x-auto">
                    <table class="min-w-full text-sm">
                        <thead>
                        <tr class="bg-slate-50 text-xs font-bold text-slate-400 uppercase tracking-wider">
                            <th class="px-3 py-3 text-left">Sản phẩm</th>
                            <th class="px-3 py-3 text-right">Đơn giá</th>
                            <th class="px-3 py-3 text-center">SL</th>
                            <th class="px-3 py-3 text-right">Thành tiền</th>
                        </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-50">
                        <c:forEach items="${order.items}" var="it">
                            <tr class="hover:bg-indigo-50/30 transition-colors">
                                <td class="px-3 py-3">
                                    <div class="flex items-center gap-3">
                                        <c:set var="img" value="${it.product != null ? it.product.imageURL : ''}"/>
                                        <img src="${path}/${img}"
                                             onerror="this.src='${path}/assets/images/placeholder-product.jpg';"
                                             class="w-14 h-14 rounded-xl object-cover border border-slate-100">
                                        <div>
                                            <div class="font-semibold text-slate-800">
                                                <c:choose>
                                                    <c:when test="${it.product != null}">
                                                        ${it.product.productName}
                                                    </c:when>
                                                    <c:otherwise>
                                                        Sản phẩm #${it.productID}
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <p class="text-xs text-slate-400">
                                                Mã SP: #${it.productID}
                                            </p>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-3 py-3 text-right text-slate-700">
                                    <fmt:formatNumber value="${it.unitPrice}" type="number" pattern="#,##0"/> ₫
                                </td>
                                <td class="px-3 py-3 text-center text-slate-700">
                                    ${it.quantity}
                                </td>
                                <td class="px-3 py-3 text-right font-semibold">
                                    <fmt:formatNumber value="${it.unitPrice * it.quantity}" type="number" pattern="#,##0"/> ₫
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                        <tfoot>
                        <tr class="border-t border-slate-100">
                            <td colspan="3" class="px-3 py-3 text-right text-sm font-semibold text-slate-600">
                                Tổng cộng:
                            </td>
                            <td class="px-3 py-3 text-right font-bold text-slate-900">
                                <fmt:formatNumber value="${order.totalAmount}" type="number" pattern="#,##0"/> ₫
                            </td>
                        </tr>
                        </tfoot>
                    </table>
                </div>
            </section>

            <!-- ========== FOOTER ========== -->
            <div class="mt-8 pt-6 border-t border-slate-200 flex flex-col md:flex-row justify-between items-center text-xs text-slate-400 font-medium">
                <p>&copy; 2025 FurniShop Admin System. Design with
                    <i class="fa-solid fa-heart text-neon-pink mx-1"></i> by Nhom2.
                </p>
                <div class="flex gap-4 mt-2 md:mt-0">
                    <a href="#" class="hover:text-neon-blue transition-colors">Support</a>
                    <a href="#" class="hover:text-neon-blue transition-colors">Terms</a>
                </div>
            </div>
        </section>
    </c:if>
</main>

</body>
</html>
