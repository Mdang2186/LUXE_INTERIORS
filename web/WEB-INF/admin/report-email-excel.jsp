<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<c:set var="path" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Gửi Excel KH VIP - FurniShop Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-100 min-h-screen flex flex-col">

<div class="max-w-6xl mx-auto mt-8 mb-10 bg-white rounded-2xl shadow-lg p-8">
    <div class="flex items-center justify-between mb-6">
        <div>
            <h1 class="text-2xl font-bold text-slate-800">Gửi email Excel khách hàng VIP</h1>
            <p class="text-sm text-slate-500 mt-1">
                Hệ thống sẽ tạo file Excel danh sách KH VIP và gửi tới email bạn nhập bên dưới.
            </p>
        </div>
        <a href="${path}/admin/dashboard"
           class="inline-flex items-center gap-2 text-xs font-semibold text-slate-500 hover:text-blue-600">
            <i class="fa-solid fa-arrow-left"></i> Quay lại Dashboard
        </a>
    </div>

    <form method="post" action="${path}/admin/report-email-excel"
          class="bg-slate-50 border border-slate-200 rounded-xl p-4 mb-6 flex flex-wrap gap-4 items-end">
        <div>
            <label class="block text-xs font-semibold text-slate-500 mb-1">Email người nhận</label>
            <input type="email" name="emailTo" value="${emailTo}"
                   required
                   class="px-3 py-2 rounded-lg border border-slate-300 text-sm w-72 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"/>
        </div>
        <div>
            <label class="block text-xs font-semibold text-slate-500 mb-1">Số KH VIP tối đa</label>
            <input type="number" name="limit" value="${limit}"
                   class="px-3 py-2 rounded-lg border border-slate-300 text-sm w-24 text-center focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none"/>
        </div>
        <button type="submit"
                class="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 shadow">
            <i class="fa-solid fa-paper-plane"></i> Gửi email
        </button>

        <div class="flex-1"></div>

        <c:if test="${not empty error}">
            <div class="w-full mt-2 text-sm text-red-600 font-medium">${error}</div>
        </c:if>
        <c:if test="${sent == true}">
            <div class="w-full mt-2 text-sm text-emerald-600 font-medium">
                Đã gửi email thành công tới <b>${emailTo}</b>.
            </div>
        </c:if>
        <c:if test="${sent == false}">
            <div class="w-full mt-2 text-sm text-red-600 font-medium">
                Gửi email thất bại. Vui lòng kiểm tra cấu hình SMTP hoặc thử lại.
            </div>
        </c:if>
    </form>

    <h2 class="text-lg font-bold text-slate-800 mb-3">
        Preview danh sách KH VIP (Top ${limit})
    </h2>
    <div class="overflow-x-auto border border-slate-200 rounded-xl">
        <table class="min-w-full text-sm">
            <thead class="bg-slate-50 text-slate-500 text-xs uppercase tracking-wide">
            <tr>
                <th class="px-4 py-3 text-left">UserID</th>
                <th class="px-4 py-3 text-left">Họ tên</th>
                <th class="px-4 py-3 text-left">Email</th>
                <th class="px-4 py-3 text-center">Số đơn</th>
                <th class="px-4 py-3 text-right">Tổng chi tiêu</th>
            </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
            <c:choose>
                <c:when test="${empty vipList}">
                    <tr>
                        <td colspan="5" class="px-4 py-4 text-center text-slate-400">
                            Chưa có dữ liệu khách hàng VIP.
                        </td>
                    </tr>
                </c:when>
                <c:otherwise>
                    <c:forEach items="${vipList}" var="v">
                        <tr class="hover:bg-slate-50">
                            <td class="px-4 py-3 font-mono text-xs text-slate-500">#${v.userId}</td>
                            <td class="px-4 py-3 font-semibold text-slate-700">${v.fullName}</td>
                            <td class="px-4 py-3 text-slate-600">${v.email}</td>
                            <td class="px-4 py-3 text-center">${v.orderCount}</td>
                            <td class="px-4 py-3 text-right text-slate-700">
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

<!-- FontAwesome cho icon -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/js/all.min.js"></script>
</body>
</html>
