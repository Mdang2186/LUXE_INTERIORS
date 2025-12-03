<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<c:set var="path" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>FurniShop - Quản lý đơn hàng</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
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
            background: rgba(255, 255, 255, 0.9);
            border-radius: 1.5rem;
            border: 1px solid rgba(255, 255, 255, 0.9);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
            transition: all 0.3s ease;
            overflow: hidden;
            position: relative;
        }
        .neon-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; height: 4px;
            background: linear-gradient(90deg, #4361ee, #f72585);
            opacity: 0;
            transition: opacity 0.3s ease;
        }
        .neon-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 0 15px rgba(67, 97, 238, 0.1);
        }
        .neon-card:hover::before { opacity: 1; }
        .custom-scroll::-webkit-scrollbar { width: 6px; height: 6px; }
        .custom-scroll::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 999px; }
        .custom-scroll::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
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
        <a href="${path}/admin/categories"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl text-slate-500">
            <i class="fa-solid fa-layer-group w-5 text-center"></i> <span>Danh mục</span>
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

<!-- MAIN -->
<main class="flex-1 flex flex-col h-full min-w-0 overflow-hidden relative">

    <!-- HEADER -->
    <header class="h-24 flex items-center justify-between px-10 z-30 shrink-0">
        <div>
            <h2 class="text-2xl font-bold font-display text-slate-800 tracking-tight">Đơn hàng</h2>
            <p class="text-sm text-slate-500 font-medium mt-1">
                Quản lý, lọc và theo dõi toàn bộ đơn hàng trên hệ thống.
            </p>
        </div>

        <div class="flex items-center gap-4">
            <!-- Form lọc (search + filter) -->
            <form action="${path}/admin/orders" method="get" class="flex items-center gap-3">
                <input type="hidden" name="action" value="list"/>

                <div class="relative group">
                    <input type="text" name="q" value="${q}"
                           placeholder="Mã đơn / mã KH / địa chỉ..."
                           class="pl-10 pr-3 py-3 rounded-2xl bg-white/80 border-0 shadow-sm ring-1 ring-slate-200
                                  focus:ring-2 focus:ring-neon-blue w-72 transition-all outline-none text-sm font-medium">
                    <i class="fa-solid fa-magnifying-glass absolute left-3 top-1/2 -translate-y-1/2 text-slate-400
                               group-focus-within:text-neon-blue transition-colors text-xs"></i>
                </div>

                <select name="status"
                        class="text-xs px-3 py-2 rounded-xl bg-white/80 border border-slate-200 focus:outline-none focus:ring-1 focus:ring-neon-blue">
                    <option value="" ${empty status ? 'selected' : ''}>Tất cả trạng thái</option>
                    <c:forEach items="${allStatuses}" var="st">
                        <option value="${st}" ${st == status ? 'selected' : ''}>${st}</option>
                    </c:forEach>
                </select>

                <select name="payment"
                        class="text-xs px-3 py-2 rounded-xl bg-white/80 border border-slate-200 focus:outline-none focus:ring-1 focus:ring-neon-blue">
                    <option value="" ${empty payment ? 'selected' : ''}>Thanh toán (tất cả)</option>
                    <option value="COD" ${payment == 'COD' ? 'selected' : ''}>COD</option>
                    <option value="BankTransfer" ${payment == 'BankTransfer' ? 'selected' : ''}>Chuyển khoản</option>
                    <option value="VNPay" ${payment == 'VNPay' ? 'selected' : ''}>VNPay</option>
                </select>

                <div class="flex flex-col text-[10px] text-slate-400">
                    <span>Từ ngày</span>
                    <input type="date" name="fromDate" value="${fromDate}"
                           class="text-xs border border-slate-200 rounded-lg px-2 py-1 bg-white/80">
                </div>
                <div class="flex flex-col text-[10px] text-slate-400">
                    <span>Đến ngày</span>
                    <input type="date" name="toDate" value="${toDate}"
                           class="text-xs border border-slate-200 rounded-lg px-2 py-1 bg-white/80">
                </div>

                <div class="flex flex-col text-[10px] text-slate-400 w-24">
                    <span>Min total</span>
                    <input type="text" name="minTotal" value="${minTotal}"
                           class="text-xs border border-slate-200 rounded-lg px-2 py-1 bg-white/80"
                           placeholder="500000">
                </div>
                <div class="flex flex-col text-[10px] text-slate-400 w-24">
                    <span>Max total</span>
                    <input type="text" name="maxTotal" value="${maxTotal}"
                           class="text-xs border border-slate-200 rounded-lg px-2 py-1 bg-white/80">
                </div>

                <button type="submit"
                        class="text-[11px] font-bold px-4 py-2 rounded-2xl bg-slate-900 text-white hover:bg-neon-blue transition-colors">
                    Lọc
                </button>
            </form>

            <!-- Export buttons -->
            <c:url var="exportExcelUrl" value="/admin/orders">
                <c:param name="action" value="export-orders"/>
                <c:if test="${not empty q}"><c:param name="q" value="${q}"/></c:if>
                <c:if test="${not empty status}"><c:param name="status" value="${status}"/></c:if>
                <c:if test="${not empty payment}"><c:param name="payment" value="${payment}"/></c:if>
                <c:if test="${not empty fromDate}"><c:param name="fromDate" value="${fromDate}"/></c:if>
                <c:if test="${not empty toDate}"><c:param name="toDate" value="${toDate}"/></c:if>
                <c:if test="${not empty minTotal}"><c:param name="minTotal" value="${minTotal}"/></c:if>
                <c:if test="${not empty maxTotal}"><c:param name="maxTotal" value="${maxTotal}"/></c:if>
            </c:url>

            <c:url var="exportPdfUrl" value="/admin/orders">
                <c:param name="action" value="export-orders-pdf"/>
                <c:if test="${not empty q}"><c:param name="q" value="${q}"/></c:if>
                <c:if test="${not empty status}"><c:param name="status" value="${status}"/></c:if>
                <c:if test="${not empty payment}"><c:param name="payment" value="${payment}"/></c:if>
                <c:if test="${not empty fromDate}"><c:param name="fromDate" value="${fromDate}"/></c:if>
                <c:if test="${not empty toDate}"><c:param name="toDate" value="${toDate}"/></c:if>
                <c:if test="${not empty minTotal}"><c:param name="minTotal" value="${minTotal}"/></c:if>
                <c:if test="${not empty maxTotal}"><c:param name="maxTotal" value="${maxTotal}"/></c:if>
            </c:url>

            <div class="flex items-center gap-2">
                <a href="${exportExcelUrl}"
                   class="inline-flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-semibold
                          bg-emerald-500 text-white shadow-sm hover:bg-emerald-600 transition-colors">
                    <i class="fa-solid fa-file-excel text-sm"></i>
                    <span>Xuất Excel</span>
                </a>
                <a href="${exportPdfUrl}"
                   class="inline-flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-semibold
                          bg-rose-500 text-white shadow-sm hover:bg-rose-600 transition-colors">
                    <i class="fa-solid fa-file-pdf text-sm"></i>
                    <span>Xuất PDF</span>
                </a>
            </div>
        </div>
    </header>

    <!-- CONTENT -->
    <section class="flex-1 overflow-y-auto px-10 pb-10 custom-scroll">

        <!-- Alert -->
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

        <!-- CARD LIST -->
        <div class="neon-card p-6 mb-6">
            <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3 mb-4">
                <div>
                    <h3 class="text-lg font-bold text-slate-800 font-display">Danh sách đơn hàng</h3>
                    <p class="text-xs text-slate-500 mt-1">
                        Tổng: <span class="font-semibold">${totalOrders}</span> đơn •
                        Trang <span class="font-semibold">${currentPage}</span>/<span class="font-semibold">${totalPages}</span>
                    </p>
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="min-w-full text-sm">
                    <thead>
                    <tr class="text-xs uppercase tracking-wide text-slate-400 bg-slate-50">
                        <th class="px-3 py-2 text-left">#</th>
                        <th class="px-3 py-2 text-left">Mã đơn</th>
                        <th class="px-3 py-2 text-left">Khách hàng</th>
                        <th class="px-3 py-2 text-left">Ngày đặt</th>
                        <th class="px-3 py-2 text-right">Tổng tiền</th>
                        <th class="px-3 py-2 text-center">Thanh toán</th>
                        <th class="px-3 py-2 text-center">Trạng thái</th>
                        <th class="px-3 py-2 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-50">
                    <c:choose>
                        <c:when test="${empty orders}">
                            <tr>
                                <td colspan="8" class="text-center text-sm text-slate-400 py-6">
                                    Không có đơn hàng nào phù hợp với bộ lọc hiện tại.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:set var="stt" value="${(currentPage-1)*pageSize}"/>
                            <c:forEach items="${orders}" var="o">
                                <c:set var="stt" value="${stt+1}"/>
                                <tr class="hover:bg-indigo-50/30 transition-colors">
                                    <td class="px-3 py-2 text-xs text-slate-400 font-mono">${stt}</td>
                                    <td class="px-3 py-2 font-semibold text-slate-800">#${o.orderID}</td>
                                    <td class="px-3 py-2 text-xs text-slate-600">User #${o.userID}</td>
                                    <td class="px-3 py-2 text-xs text-slate-500">
                                        <fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td class="px-3 py-2 text-right font-semibold text-slate-800">
                                        <fmt:formatNumber value="${o.totalAmount}" type="number" pattern="#,##0"/> ₫
                                    </td>
                                    <td class="px-3 py-2 text-center text-xs">
                                        <span class="inline-flex px-2 py-1 rounded-full bg-slate-100 text-slate-600">
                                            ${o.paymentMethod}
                                        </span>
                                    </td>
                                    <td class="px-3 py-2 text-center text-xs">
                                        <c:set var="st" value="${o.status}"/>
                                        <span class="inline-flex px-2 py-1 rounded-full
                                               ${st=='Pending' ? 'bg-amber-50 text-amber-700' :
                                                 st=='Confirmed' ? 'bg-sky-50 text-sky-700' :
                                                 st=='Packing' ? 'bg-blue-50 text-blue-700' :
                                                 st=='Shipping' ? 'bg-indigo-50 text-indigo-700' :
                                                 st=='Done' ? 'bg-emerald-50 text-emerald-700' :
                                                              'bg-rose-50 text-rose-700'}">
                                            ${st}
                                        </span>
                                    </td>
                                    <td class="px-3 py-2 text-right">
                                        <a href="${path}/admin/orders?action=detail&id=${o.orderID}"
                                           class="inline-flex items-center justify-center w-8 h-8 rounded-full bg-slate-900 text-white text-xs hover:bg-neon-blue transition-all"
                                           title="Xem chi tiết">
                                            <i class="fa-solid fa-eye"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="mt-5 flex items-center justify-between text-xs text-slate-500">
                    <p>
                        Hiển thị
                        <span class="font-semibold">
                        <c:choose>
                            <c:when test="${totalOrders == 0}">0</c:when>
                            <c:otherwise>
                                ${ (currentPage-1)*pageSize + 1 } -
                                <c:choose>
                                    <c:when test="${currentPage*pageSize > totalOrders}">
                                        ${totalOrders}
                                    </c:when>
                                    <c:otherwise>${currentPage*pageSize}</c:otherwise>
                                </c:choose>
                            </c:otherwise>
                        </c:choose>
                        </span>
                        trên <span class="font-semibold">${totalOrders}</span> đơn.
                    </p>

                    <div class="flex gap-1">
                        <c:forEach var="p" begin="1" end="${totalPages}">
                            <c:url var="pageUrl" value="/admin/orders">
                                <c:param name="action" value="list"/>
                                <c:param name="page" value="${p}"/>
                                <c:if test="${not empty q}"><c:param name="q" value="${q}"/></c:if>
                                <c:if test="${not empty status}"><c:param name="status" value="${status}"/></c:if>
                                <c:if test="${not empty payment}"><c:param name="payment" value="${payment}"/></c:if>
                                <c:if test="${not empty fromDate}"><c:param name="fromDate" value="${fromDate}"/></c:if>
                                <c:if test="${not empty toDate}"><c:param name="toDate" value="${toDate}"/></c:if>
                                <c:if test="${not empty minTotal}"><c:param name="minTotal" value="${minTotal}"/></c:if>
                                <c:if test="${not empty maxTotal}"><c:param name="maxTotal" value="${maxTotal}"/></c:if>
                            </c:url>
                            <a href="${pageUrl}"
                               class="px-3 py-1 rounded-lg border text-[11px] font-semibold
                                      ${p == currentPage
                                          ? 'bg-slate-900 text-white border-slate-900'
                                          : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'}">
                                ${p}
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
        </div>
    </section>
</main>
</body>
</html>
