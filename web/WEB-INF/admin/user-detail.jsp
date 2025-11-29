<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>   <!-- THÊM DÒNG NÀY -->

<c:set var="path" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0" />
    <title>FurniShop - Chi tiết người dùng</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">

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
                        'glass': '0 8px 32px 0 rgba(15, 23, 42, 0.08)'
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
        }
        .glass-panel {
            background: rgba(255, 255, 255, 0.82);
            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);
            border: 1px solid rgba(255, 255, 255, 0.9);
        }
        .sidebar-link {
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
            border-left: 3px solid transparent;
        }
        .sidebar-link:hover {
            background: linear-gradient(90deg, rgba(67, 97, 238, 0.06) 0%, transparent 100%);
            color: #4361ee;
            padding-left: 1.25rem;
        }
        .sidebar-link.active {
            background: linear-gradient(90deg, rgba(67, 97, 238, 0.12) 0%, transparent 100%);
            color: #4361ee;
            border-left-color: #4361ee;
            font-weight: 600;
        }
        .neon-card {
            background: rgba(255, 255, 255, 0.96);
            border-radius: 1.5rem;
            border: 1px solid rgba(255, 255, 255, 0.95);
            box-shadow: 0 10px 30px rgba(15,23,42,0.08);
            transition: all 0.22s ease;
            position: relative;
            overflow: hidden;
        }
        .neon-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; height: 4px;
            background: linear-gradient(90deg, #4361ee, #f72585);
            opacity: 0;
            transition: opacity 0.25s ease;
        }
        .neon-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 18px 40px rgba(15,23,42,0.16);
        }
        .neon-card:hover::before { opacity: 1; }

        .custom-scroll::-webkit-scrollbar { width: 6px; height: 6px; }
        .custom-scroll::-webkit-scrollbar-track { background: transparent; }
        .custom-scroll::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
        .custom-scroll::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
    </style>
</head>
<body class="flex h-screen w-full font-sans antialiased">

<!-- SIDEBAR (giống trang list) -->
<aside class="w-72 glass-panel flex flex-col h-full flex-shrink-0 z-20 border-r border-white/60">
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
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl text-slate-500">
            <i class="fa-solid fa-receipt w-5 text-center"></i> <span>Đơn hàng</span>
        </a>

        <a href="${path}/admin/categories"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl text-slate-500">
            <i class="fa-solid fa-layer-group w-5 text-center"></i> <span>Danh mục</span>
        </a>

        <a href="${path}/admin/users"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl
                  text-slate-500 ${adminActive eq 'users' ? 'active' : ''}">
            <i class="fa-solid fa-users w-5 text-center"></i> <span>Người dùng</span>
        </a>
    </nav>

    <div class="p-6 border-t border-white/60">
        <div class="flex items-center gap-4 p-3 rounded-2xl bg-gradient-to-r from-white to-slate-50 border border-white shadow-sm">
            <img src="https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=4361ee&color=fff"
                 class="w-10 h-10 rounded-full border-2 border-white shadow-sm" />
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
<main class="flex-1 flex flex-col h-full min-w-0 overflow-hidden">

    <!-- HEADER -->
    <header class="h-24 flex items-center justify-between px-10 shrink-0">
        <div class="flex items-center gap-3">
            <a href="${path}/admin/users"
               class="inline-flex items-center justify-center w-8 h-8 rounded-full bg-white border border-slate-200 text-slate-500 hover:bg-slate-50 mr-2">
                <i class="fa-solid fa-arrow-left text-xs"></i>
            </a>
            <div>
                <h2 class="text-2xl font-bold font-display text-slate-800 tracking-tight">
                    Hồ sơ người dùng
                </h2>
                <p class="text-sm text-slate-500 font-medium mt-1">
                    Quản lý thông tin & lịch sử đơn hàng của khách.
                </p>
            </div>
        </div>

        <div class="flex items-center gap-3">
            <c:url var="exportOrdersUrl" value="/admin/users">
                <c:param name="action" value="export-user-orders"/>
                <c:param name="id" value="${user.userID}"/>
            </c:url>

            <form action="${path}/admin/users" method="post">
                <input type="hidden" name="action" value="send-user-report" />
                <input type="hidden" name="id" value="${user.userID}" />
                <button type="submit"
                        class="inline-flex items-center gap-2 text-xs font-bold px-3 py-2 rounded-xl
                               bg-white text-slate-700 border border-slate-200 hover:border-neon-blue hover:text-neon-blue transition-colors">
                    <i class="fa-solid fa-paper-plane"></i> Gửi báo cáo email
                </button>
            </form>

            <a href="${exportOrdersUrl}"
               class="inline-flex items-center gap-2 text-xs font-bold px-3 py-2 rounded-xl
                      bg-gradient-to-r from-neon-blue to-neon-purple text-white shadow-neon-blue hover:opacity-90">
                <i class="fa-solid fa-file-excel"></i> Export đơn hàng
            </a>
        </div>
    </header>

    <!-- CONTENT -->
    <div class="flex-1 overflow-y-auto px-10 pb-10 custom-scroll">

        <!-- THÔNG BÁO -->
        <c:if test="${not empty sessionScope.success}">
            <div class="mb-4 rounded-xl border border-emerald-200 bg-emerald-50 text-emerald-700 px-4 py-3 text-sm flex items-start gap-2">
                <i class="fa-solid fa-circle-check mt-0.5"></i>
                <span>${sessionScope.success}</span>
            </div>
            <c:remove var="success" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.error}">
            <div class="mb-4 rounded-xl border border-rose-200 bg-rose-50 text-rose-700 px-4 py-3 text-sm flex items-start gap-2">
                <i class="fa-solid fa-circle-exclamation mt-0.5"></i>
                <span>${sessionScope.error}</span>
            </div>
            <c:remove var="error" scope="session"/>
        </c:if>

        <!-- HÀNG 1: HỒ SƠ + KPI -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
            <!-- Profile -->
            <div class="neon-card p-6 lg:col-span-1">
                <div class="flex items-start gap-4">
                    <div class="w-14 h-14 rounded-2xl bg-slate-900 flex items-center justify-center text-white text-xl font-semibold shadow-lg">
                        <c:choose>
                            <c:when test="${not empty user.fullName}">
                                ${fn:substring(user.fullName,0,1)}
                            </c:when>
                            <c:otherwise>U</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="flex-1">
                        <p class="text-xs font-semibold uppercase tracking-widest text-slate-400">Khách hàng</p>
                        <h3 class="text-xl font-bold text-slate-800 mt-1">
                            <c:out value="${empty user.fullName ? 'Chưa cập nhật' : user.fullName}" />
                        </h3>
                        <p class="text-xs mt-1 text-slate-500">
                            ID: <span class="font-mono text-[11px] bg-slate-100 px-1.5 py-0.5 rounded">${user.userID}</span>
                        </p>
                    </div>
                </div>

                <div class="mt-5 space-y-2 text-sm text-slate-600">
                    <div class="flex items-center gap-2">
                        <i class="fa-solid fa-envelope text-slate-400 w-4"></i>
                        <span>${empty user.email ? 'Chưa cập nhật email' : user.email}</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <i class="fa-solid fa-phone text-slate-400 w-4"></i>
                        <span>${empty user.phone ? 'Chưa cập nhật SĐT' : user.phone}</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <i class="fa-solid fa-location-dot text-slate-400 w-4"></i>
                        <span>${empty user.address ? 'Chưa cập nhật địa chỉ' : user.address}</span>
                    </div>
                    <div class="flex items-center gap-2">
                        <i class="fa-solid fa-calendar-plus text-slate-400 w-4"></i>
                        <span>
                            Tạo lúc:
                            <c:if test="${not empty user.createdAt}">
                                <fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                            </c:if>
                        </span>
                    </div>
                </div>

                <!-- Vai trò -->
                <div class="mt-6 border-t border-slate-100 pt-4">
                    <p class="text-xs font-semibold text-slate-500 mb-2">Vai trò hệ thống</p>
                    <form action="${path}/admin/users" method="post" class="flex items-center gap-2">
                        <input type="hidden" name="action" value="update-role" />
                        <input type="hidden" name="id" value="${user.userID}" />
                        <select name="role"
                                class="text-xs bg-white border border-slate-200 rounded-xl px-3 py-2 text-slate-700 flex-1">
                            <option value="Customer" <c:if test="${user.role eq 'Customer'}">selected</c:if>>Customer</option>
                            <option value="Staff"    <c:if test="${user.role eq 'Staff'}">selected</c:if>>Staff</option>
                            <option value="Admin"    <c:if test="${user.role eq 'Admin'}">selected</c:if>>Admin</option>
                        </select>
                        <button type="submit"
                                class="inline-flex items-center gap-1 text-[11px] font-bold px-3 py-2 rounded-xl
                                       bg-slate-900 text-white hover:bg-neon-blue transition-colors">
                            <i class="fa-solid fa-floppy-disk"></i> Lưu
                        </button>
                    </form>
                </div>
            </div>

            <!-- KPI đơn hàng -->
            <div class="lg:col-span-2 grid grid-cols-1 sm:grid-cols-3 gap-4">
                <!-- Tổng đơn -->
                <div class="neon-card p-5">
                    <p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Tổng số đơn</p>
                    <h3 class="text-2xl font-bold text-slate-800 mt-2 font-display">
                        ${empty orders ? 0 : fn:length(orders)}
                    </h3>
                    <p class="text-xs text-slate-400 mt-1">
                        Số đơn hàng đã tạo bởi khách.
                    </p>
                </div>
                <!-- Tổng chi tiêu -->
                <div class="neon-card p-5">
                    <p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Tổng chi tiêu</p>
                    <h3 class="text-2xl font-bold text-slate-800 mt-2 font-display">
                        <c:choose>
                            <c:when test="${empty totalSpent}">
                                0 ₫
                            </c:when>
                            <c:otherwise>
                                <fmt:formatNumber value="${totalSpent}" type="number" pattern="#,##0"/> ₫
                            </c:otherwise>
                        </c:choose>
                    </h3>
                    <p class="text-xs text-slate-400 mt-1">Đơn đã hoàn tất (theo logic DAO).</p>
                </div>
                <!-- Đơn gần nhất -->
                <div class="neon-card p-5">
                    <p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Đơn gần nhất</p>
                    <h3 class="text-sm font-bold text-slate-800 mt-2">
                        <c:choose>
                            <c:when test="${empty lastOrderDate}">
                                Chưa có đơn hàng
                            </c:when>
                            <c:otherwise>
                                <fmt:formatDate value="${lastOrderDate}" pattern="dd/MM/yyyy HH:mm" />
                            </c:otherwise>
                        </c:choose>
                    </h3>
                    <p class="text-xs text-slate-400 mt-1">Mốc thời gian hoạt động cuối.</p>
                </div>
            </div>
        </div>

        <!-- HÀNG 2: BẢNG ĐƠN HÀNG -->
        <div class="neon-card p-0">
            <div class="px-6 pt-5 pb-3 border-b border-slate-100 flex justify-between items-center">
                <div>
                    <h3 class="font-bold text-lg text-slate-800 font-display">Lịch sử đơn hàng</h3>
                    <p class="text-xs text-slate-400 mt-1">
                        Danh sách đơn hàng của khách, gồm trạng thái và tổng tiền.
                    </p>
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="min-w-full text-sm">
                    <thead>
                    <tr class="bg-slate-50 text-xs font-bold text-slate-400 uppercase tracking-wider">
                        <th class="px-4 py-3 text-left">Mã đơn</th>
                        <th class="px-4 py-3 text-left">Ngày đặt</th>
                        <th class="px-4 py-3 text-left">Trạng thái</th>
                        <th class="px-4 py-3 text-right">Tổng tiền</th>
                        <th class="px-4 py-3 text-left">Địa chỉ giao</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-50">
                    <c:choose>
                        <c:when test="${empty orders}">
                            <tr>
                                <td colspan="5" class="px-4 py-6 text-center text-sm text-slate-400">
                                    Khách hàng này chưa có đơn hàng nào.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="o" items="${orders}">
                                <tr class="hover:bg-indigo-50/40 transition-colors">
                                    <td class="px-4 py-3 text-sm font-mono text-slate-700">#${o.orderID}</td>
                                    <td class="px-4 py-3 text-sm text-slate-600">
                                        <c:if test="${not empty o.orderDate}">
                                            <fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy HH:mm" />
                                        </c:if>
                                    </td>
                                    <td class="px-4 py-3 text-sm">
                                        <c:choose>
                                            <c:when test="${o.status eq 'Completed' || o.status eq 'Hoàn tất'}">
                                                <span class="inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-100">
                                                    <i class="fa-solid fa-circle-check mr-1"></i>${o.status}
                                                </span>
                                            </c:when>
                                            <c:when test="${o.status eq 'Pending' || o.status eq 'Đang xử lý'}">
                                                <span class="inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-100">
                                                    <i class="fa-solid fa-clock mr-1"></i>${o.status}
                                                </span>
                                            </c:when>
                                            <c:when test="${o.status eq 'Cancelled' || o.status eq 'Đã hủy'}">
                                                <span class="inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold bg-rose-50 text-rose-700 border border-rose-100">
                                                    <i class="fa-solid fa-circle-xmark mr-1"></i>${o.status}
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold bg-slate-100 text-slate-600 border border-slate-200">
                                                    ${o.status}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-4 py-3 text-right text-sm text-slate-800 font-semibold">
                                        <fmt:formatNumber value="${o.totalAmount}" type="number" pattern="#,##0"/> ₫
                                    </td>
                                    <td class="px-4 py-3 text-sm text-slate-600">
                                        <span class="line-clamp-2">${o.shippingAddress}</span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- FOOTER -->
        <div class="mt-8 pt-6 border-t border-slate-200 flex flex-col md:flex-row justify-between items-center text-xs text-slate-400 font-medium">
            <p>&copy; 2025 FurniShop Admin System. Nhom2.</p>
            <div class="flex gap-4 mt-2 md:mt-0">
                <a href="#" class="hover:text-neon-blue transition-colors">Support</a>
                <a href="#" class="hover:text-neon-blue transition-colors">Terms</a>
            </div>
        </div>

    </div>
</main>

</body>
</html>
