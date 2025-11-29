<%@ page contentType="text/html;charset=UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="path" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Báo cáo tháng - FurniShop Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-100 min-h-screen flex flex-col">

<div class="max-w-6xl mx-auto mt-8 mb-10 bg-white rounded-2xl shadow-lg p-8">
    <div class="flex items-center justify-between mb-6">
        <div>
            <h1 class="text-2xl font-bold text-slate-800">
                Báo cáo tháng ${month}/${year}
            </h1>
            <p class="text-sm text-slate-500 mt-1">
                Khoảng thời gian: ${fromDate} → ${toDate}
            </p>
        </div>
        <a href="${path}/admin/dashboard"
           class="inline-flex items-center gap-2 text-xs font-semibold text-slate-500 hover:text-blue-600">
            <i class="fa-solid fa-arrow-left"></i> Quay lại Dashboard
        </a>
    </div>

    <!-- Form chọn tháng + email -->
    <form method="post" action="${path}/admin/report-monthly-email"
          class="bg-slate-50 border border-slate-200 rounded-xl p-4 mb-6 flex flex-wrap gap-4 items-end">
        <div>
            <label class="block text-xs font-semibold text-slate-500 mb-1">Năm</label>
            <input type="number" name="year" value="${year}"
                   class="w-24 px-3 py-2 rounded-lg border border-slate-300 text-sm text-center focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"/>
        </div>
        <div>
            <label class="block text-xs font-semibold text-slate-500 mb-1">Tháng</label>
            <input type="number" name="month" value="${month}"
                   class="w-20 px-3 py-2 rounded-lg border border-slate-300 text-sm text-center focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none" />
        </div>
        <div class="flex-1 min-w-[220px]">
            <label class="block text-xs font-semibold text-slate-500 mb-1">Email người nhận báo cáo</label>
            <input type="email" name="emailTo" value="${emailTo}"
                   required
                   class="w-full px-3 py-2 rounded-lg border border-slate-300 text-sm focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"/>
        </div>
        <button type="submit"
                class="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 shadow">
            <i class="fa-solid fa-paper-plane"></i> Gửi email báo cáo
        </button>

        <c:if test="${not empty error}">
            <div class="w-full mt-2 text-sm text-red-600 font-medium">${error}</div>
        </c:if>
        <c:if test="${sent == true}">
            <div class="w-full mt-2 text-sm text-emerald-600 font-medium">
                Đã gửi báo cáo tháng thành công tới <b>${emailTo}</b>.
            </div>
        </c:if>
        <c:if test="${sent == false}">
            <div class="w-full mt-2 text-sm text-red-600 font-medium">
                Gửi email thất bại. Vui lòng kiểm tra cấu hình SMTP hoặc thử lại.
            </div>
        </c:if>
    </form>

    <!-- TÓM TẮT CHỈ SỐ -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div class="p-4 rounded-xl bg-slate-50 border border-slate-200">
            <p class="text-xs font-semibold text-slate-500 uppercase">Doanh thu tháng</p>
            <p class="text-xl font-bold text-slate-800 mt-1">
                <fmt:formatNumber value="${revenueMonth}" type="number" groupingUsed="true"/> đ
            </p>
        </div>
        <div class="p-4 rounded-xl bg-slate-50 border border-slate-200">
            <p class="text-xs font-semibold text-slate-500 uppercase">Lợi nhuận ước tính</p>
            <p class="text-xl font-bold text-slate-800 mt-1">
                <fmt:formatNumber value="${profitMonth}" type="number" groupingUsed="true"/> đ
            </p>
        </div>
        <div class="p-4 rounded-xl bg-slate-50 border border-slate-200">
            <p class="text-xs font-semibold text-slate-500 uppercase">KH VIP / KH mới</p>
            <p class="text-xl font-bold text-slate-800 mt-1">
                <c:set var="vipCount" value="${vipTop != null ? fn:length(vipTop) : 0}" />
                <c:set var="newCount" value="${newCustomers != null ? fn:length(newCustomers) : 0}" />
                ${vipCount} VIP · ${newCount} mới
            </p>
        </div>
    </div>

    <!-- Bảng VIP + KH mới (preview ngắn) -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- VIP -->
        <div>
            <h2 class="text-sm font-bold text-slate-700 mb-2">Top KH VIP trong tháng</h2>
            <div class="border border-slate-200 rounded-xl overflow-hidden bg-white">
                <table class="w-full text-xs">
                    <thead class="bg-slate-50 text-slate-500">
                    <tr>
                        <th class="px-3 py-2 text-left">Họ tên</th>
                        <th class="px-3 py-2 text-left">Email</th>
                        <th class="px-3 py-2 text-center">Số đơn</th>
                        <th class="px-3 py-2 text-right">Chi tiêu</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                    <c:choose>
                        <c:when test="${empty vipTop}">
                            <tr>
                                <td colspan="4" class="px-3 py-3 text-center text-slate-400">
                                    Chưa có dữ liệu.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${vipTop}" var="v">
                                <tr class="hover:bg-slate-50">
                                    <td class="px-3 py-2 font-semibold text-slate-700">${v.fullName}</td>
                                    <td class="px-3 py-2 text-slate-600">${v.email}</td>
                                    <td class="px-3 py-2 text-center">${v.orderCount}</td>
                                    <td class="px-3 py-2 text-right text-slate-700">
                                        <fmt:formatNumber value="${v.totalSpent}" type="number" groupingUsed="true"/> đ
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- NEW CUSTOMERS -->
        <div>
            <h2 class="text-sm font-bold text-slate-700 mb-2">Khách hàng mới trong tháng</h2>
            <div class="border border-slate-200 rounded-xl overflow-hidden bg-white">
                <table class="w-full text-xs">
                    <thead class="bg-slate-50 text-slate-500">
                    <tr>
                        <th class="px-3 py-2 text-left">UserID</th>
                        <th class="px-3 py-2 text-left">Họ tên</th>
                        <th class="px-3 py-2 text-left">Email</th>
                        <th class="px-3 py-2 text-left">Ngày tạo</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                    <c:choose>
                        <c:when test="${empty newCustomers}">
                            <tr>
                                <td colspan="4" class="px-3 py-3 text-center text-slate-400">
                                    Chưa có dữ liệu.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${newCustomers}" var="u">
                                <tr class="hover:bg-slate-50">
                                    <td class="px-3 py-2 font-mono text-xs text-slate-500">#${u.userId}</td>
                                    <td class="px-3 py-2 font-semibold text-slate-700">${u.fullName}</td>
                                    <td class="px-3 py-2 text-slate-600">${u.email}</td>
                                    <td class="px-3 py-2 text-slate-500">
                                        ${u.createdAt}
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
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/js/all.min.js"></script>
</body>
</html>
