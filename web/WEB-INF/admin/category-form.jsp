<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0" />
    <title>
        <c:choose>
            <c:when test="${empty category}">Thêm danh mục</c:when>
            <c:otherwise>Sửa danh mục</c:otherwise>
        </c:choose> - FurniShop Admin
    </title>

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
                    }
                }
            }
        }
    </script>

    <style>
        body{
            background:#f0f2f5;
            background-image:
               radial-gradient(at 0% 0%, rgba(67,97,238,0.05) 0, transparent 50%),
               radial-gradient(at 100% 0%, rgba(247,37,133,0.05) 0, transparent 50%),
               radial-gradient(at 100% 100%, rgba(76,201,240,0.05) 0, transparent 50%);
            color:#1e293b;
        }
        .panel{
            background:rgba(255,255,255,0.96);
            border-radius:1.5rem;
            border:1px solid rgba(255,255,255,0.95);
            box-shadow:0 18px 40px rgba(15,23,42,0.12);
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center font-sans antialiased px-4">

<div class="max-w-xl w-full panel p-8">
    <div class="flex items-center justify-between mb-6">
        <div>
            <p class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-1">
                Danh mục sản phẩm
            </p>
            <h1 class="text-2xl font-bold font-display text-slate-800">
                <c:choose>
                    <c:when test="${empty category}">Thêm danh mục mới</c:when>
                    <c:otherwise>Cập nhật danh mục</c:otherwise>
                </c:choose>
            </h1>
        </div>
        <a href="${path}/admin/categories"
           class="inline-flex items-center gap-1 text-xs font-semibold px-3 py-2 rounded-xl bg-slate-100 text-slate-600 hover:bg-slate-200">
            <i class="fa-solid fa-arrow-left"></i> Quay lại
        </a>
    </div>

    <c:if test="${not empty error}">
        <div class="mb-4 rounded-xl border border-rose-200 bg-rose-50 text-rose-700 px-4 py-3 text-sm flex items-start gap-2">
            <i class="fa-solid fa-circle-exclamation mt-0.5"></i>
            <span>${error}</span>
        </div>
    </c:if>

    <form action="${path}/admin/categories" method="post" class="space-y-6">
        <input type="hidden" name="action" value="save"/>

        <c:if test="${not empty category}">
            <input type="hidden" name="categoryID" value="${category.categoryID}" />
        </c:if>

        <div>
            <label class="block text-xs font-semibold text-slate-600 mb-1">
                Tên danh mục <span class="text-rose-500">*</span>
            </label>
            <input type="text" name="categoryName"
                   value="${empty category ? '' : category.categoryName}"
                   placeholder="Ví dụ: Sofa phòng khách"
                   required
                   class="w-full text-sm bg-white border border-slate-200 rounded-xl px-3 py-2.5
                          focus:outline-none focus:ring-2 focus:ring-indigo-500">
            <p class="mt-1 text-[11px] text-slate-400">
                Tên hiển thị cho nhóm sản phẩm trên website.
            </p>
        </div>

        <div class="pt-2 flex justify-end gap-3">
            <a href="${path}/admin/categories"
               class="text-xs font-semibold px-4 py-2.5 rounded-xl bg-slate-100 text-slate-600 hover:bg-slate-200">
                Hủy
            </a>
            <button type="submit"
                    class="text-xs font-bold px-4 py-2.5 rounded-xl bg-slate-900 text-white hover:bg-indigo-600">
                <c:choose>
                    <c:when test="${empty category}">
                        <i class="fa-solid fa-check mr-1"></i> Tạo danh mục
                    </c:when>
                    <c:otherwise>
                        <i class="fa-solid fa-check mr-1"></i> Lưu thay đổi
                    </c:otherwise>
                </c:choose>
            </button>
        </div>
    </form>
</div>

</body>
</html>
