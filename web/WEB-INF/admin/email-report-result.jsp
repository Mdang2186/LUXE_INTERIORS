<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Kết quả gửi báo cáo</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap"
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
                        'glass': '0 18px 45px rgba(15,23,42,0.18)',
                    }
                }
            }
        }
    </script>

    <style>
        body {
            background:
                radial-gradient(at 0% 0%, rgba(67,97,238,0.18) 0, transparent 55%),
                radial-gradient(at 100% 100%, rgba(247,37,133,0.18) 0, transparent 55%),
                #0f172a;
            min-height: 100vh;
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center px-4 font-sans text-slate-900">

<div class="max-w-lg w-full">
    <div class="relative bg-white/90 backdrop-blur-xl rounded-3xl border border-white/40 shadow-glass p-8">

        <!-- Icon -->
        <div class="flex justify-center mb-4">
            <c:choose>
                <c:when test="${success}">
                    <div class="w-16 h-16 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
                        <i class="fa-solid fa-circle-check text-3xl"></i>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="w-16 h-16 rounded-2xl bg-rose-50 text-rose-600 flex items-center justify-center">
                        <i class="fa-solid fa-circle-exclamation text-3xl"></i>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Title & message -->
        <div class="text-center space-y-2 mb-6">
            <h1 class="text-2xl font-display font-semibold text-slate-900">
                <c:choose>
                    <c:when test="${success}">Gửi báo cáo thành công</c:when>
                    <c:otherwise>Gửi báo cáo thất bại</c:otherwise>
                </c:choose>
            </h1>

            <p class="text-sm text-slate-600 leading-relaxed">
                <c:out value="${message}" default="Hệ thống đã xử lý yêu cầu gửi báo cáo của bạn."/>
            </p>

            <c:if test="${not empty fromDate && not empty toDate}">
                <p class="text-[11px] text-slate-400">
                    Khoảng thời gian báo cáo:
                    <span class="font-semibold text-slate-600">${fromDate}</span>
                    →
                    <span class="font-semibold text-slate-600">${toDate}</span>
                </p>
            </c:if>

            <c:if test="${success}">
                <p class="text-[11px] uppercase tracking-wide font-semibold text-emerald-500 mt-1">
                    <i class="fa-solid fa-envelope-open-text mr-1"></i>
                    Vui lòng kiểm tra hộp thư email
                </p>
            </c:if>
        </div>

        <!-- Buttons -->
        <div class="flex flex-col sm:flex-row gap-3 justify-center">
            <a href="${path}/admin/dashboard"
               class="inline-flex items-center justify-center px-4 py-2.5 rounded-2xl text-sm font-semibold
                      bg-slate-900 text-white hover:bg-neon-blue transition-colors gap-2">
                <i class="fa-solid fa-gauge-high text-xs"></i>
                <span>Quay về Dashboard</span>
            </a>

            <a href="${path}/admin/orders"
               class="inline-flex items-center justify-center px-4 py-2.5 rounded-2xl text-sm font-semibold
                      bg-white text-slate-700 border border-slate-200 hover:bg-slate-50 gap-2">
                <i class="fa-solid fa-receipt text-xs"></i>
                <span>Xem danh sách đơn hàng</span>
            </a>
        </div>

        <div class="mt-6 text-center">
            <p class="text-[11px] text-slate-400">
                Nếu không thấy email trong hộp thư đến, hãy kiểm tra thư mục
                <span class="font-semibold">Spam / Quảng cáo</span>.
            </p>
        </div>
    </div>
</div>

</body>
</html>
