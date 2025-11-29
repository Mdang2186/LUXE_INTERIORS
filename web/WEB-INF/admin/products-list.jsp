<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="path" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0" />
    <title>FurniShop - Quản lý sản phẩm</title>

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
<!-- SIDEBAR -->
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
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl
                  text-slate-500 ${adminActive eq 'products' ? 'active' : ''}">
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
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl text-slate-500">
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
        <div>
            <h2 class="text-2xl font-bold font-display text-slate-800 tracking-tight">Sản phẩm</h2>
            <p class="text-sm text-slate-500 font-medium mt-1">
                Quản lý danh sách sản phẩm nội thất, tồn kho, thương hiệu.
            </p>
        </div>

                <div class="flex items-center gap-3">
            <a href="${path}/admin/products?action=create"
               class="inline-flex items-center gap-2 text-xs font-bold px-4 py-2.5 rounded-xl
                      bg-slate-900 text-white hover:bg-neon-blue transition-colors shadow-sm">
                <i class="fa-solid fa-plus"></i> Thêm sản phẩm
            </a>

            <%-- Build URL giữ filter cho CSV/Excel/PDF --%>
            <c:url var="exportCsvUrl" value="/admin/products">
                <c:param name="action" value="export-products-csv"/>
                <c:if test="${not empty q}"><c:param name="q" value="${q}"/></c:if>
                <c:if test="${not empty cid}"><c:param name="cid" value="${cid}"/></c:if>
                <c:if test="${not empty brandName}"><c:param name="brandName" value="${brandName}"/></c:if>
                <c:if test="${not empty minPrice}"><c:param name="minPrice" value="${minPrice}"/></c:if>
                <c:if test="${not empty maxPrice}"><c:param name="maxPrice" value="${maxPrice}"/></c:if>
                <c:if test="${not empty sort}"><c:param name="sort" value="${sort}"/></c:if>
            </c:url>

            <c:url var="exportExcelUrl" value="/admin/products">
                <c:param name="action" value="export-products-excel"/>
                <c:if test="${not empty q}"><c:param name="q" value="${q}"/></c:if>
                <c:if test="${not empty cid}"><c:param name="cid" value="${cid}"/></c:if>
                <c:if test="${not empty brandName}"><c:param name="brandName" value="${brandName}"/></c:if>
                <c:if test="${not empty minPrice}"><c:param name="minPrice" value="${minPrice}"/></c:if>
                <c:if test="${not empty maxPrice}"><c:param name="maxPrice" value="${maxPrice}"/></c:if>
                <c:if test="${not empty sort}"><c:param name="sort" value="${sort}"/></c:if>
            </c:url>

            <c:url var="exportPdfUrl" value="/admin/products">
                <c:param name="action" value="export-products-pdf"/>
                <c:if test="${not empty q}"><c:param name="q" value="${q}"/></c:if>
                <c:if test="${not empty cid}"><c:param name="cid" value="${cid}"/></c:if>
                <c:if test="${not empty brandName}"><c:param name="brandName" value="${brandName}"/></c:if>
                <c:if test="${not empty minPrice}"><c:param name="minPrice" value="${minPrice}"/></c:if>
                <c:if test="${not empty maxPrice}"><c:param name="maxPrice" value="${maxPrice}"/></c:if>
                <c:if test="${not empty sort}"><c:param name="sort" value="${sort}"/></c:if>
            </c:url>

            <!-- CSV -->
            <a href="${exportCsvUrl}"
               class="inline-flex items-center gap-2 text-xs font-semibold px-3 py-2 rounded-xl
                      bg-white border border-slate-200 text-slate-700 hover:bg-slate-50">
                <i class="fa-solid fa-file-csv text-emerald-500"></i> CSV
            </a>

            <!-- Excel -->
            <a href="${exportExcelUrl}"
               class="inline-flex items-center gap-2 text-xs font-semibold px-3 py-2 rounded-xl
                      bg-gradient-to-r from-neon-blue to-neon-purple text-white shadow-neon-blue hover:opacity-90">
                <i class="fa-solid fa-file-excel"></i> Excel
            </a>

            <!-- PDF -->
            <a href="${exportPdfUrl}"
               class="inline-flex items-center gap-2 text-xs font-semibold px-3 py-2 rounded-xl
                      bg-white border border-slate-200 text-slate-700 hover:bg-slate-50">
                <i class="fa-solid fa-file-pdf text-rose-500"></i> PDF
            </a>
        </div>

    </header>

    <!-- CONTENT -->
    <div class="flex-1 overflow-y-auto px-10 pb-10 custom-scroll">
        <!-- NOTIFY -->
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

        <!-- KPI -->
        <c:set var="pageProductCount" value="${fn:length(products)}" />
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 mb-6">
            <div class="neon-card p-5">
                <p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Tổng sản phẩm</p>
                <h3 class="text-2xl font-bold text-slate-800 mt-2 font-display">${totalAllProducts}</h3>
                <p class="text-xs text-slate-400 mt-1">Trong toàn hệ thống.</p>
            </div>
            <div class="neon-card p-5">
                <p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Theo bộ lọc</p>
                <h3 class="text-2xl font-bold text-slate-800 mt-2 font-display">${totalFiltered}</h3>
                <p class="text-xs text-slate-400 mt-1">Sản phẩm khớp điều kiện hiện tại.</p>
            </div>
            <div class="neon-card p-5">
                <p class="text-xs font-bold text-slate-400 uppercase tracking-widest">Thương hiệu</p>
                <h3 class="text-2xl font-bold text-slate-800 mt-2 font-display">${brandCount}</h3>
                <p class="text-xs text-slate-400 mt-1">Brand đang kinh doanh.</p>
            </div>
        </div>

        <!-- FILTER -->
        <div class="neon-card p-6 mb-6">
            <form action="${path}/admin/products" method="get"
                  class="grid grid-cols-1 md:grid-cols-4 xl:grid-cols-6 gap-4 items-end">
                <input type="hidden" name="action" value="list"/>

                <!-- keyword -->
                <div class="md:col-span-2">
                    <label class="block text-xs font-semibold text-slate-500 mb-1">Từ khóa</label>
                    <input type="text" name="q" value="${q}"
                           placeholder="Tìm theo tên, mã, thương hiệu, chất liệu..."
                           class="w-full text-sm bg-white border border-slate-200 rounded-xl px-3 py-2
                                  focus:outline-none focus:ring-2 focus:ring-neon-blue">
                </div>

                <!-- category -->
                <div>
                    <label class="block text-xs font-semibold text-slate-500 mb-1">Danh mục</label>
                    <select name="cid"
                            class="w-full text-sm bg-white border border-slate-200 rounded-xl px-3 py-2 text-slate-700">
                        <option value="">Tất cả</option>
                        <c:forEach var="c" items="${categories}">
                            <option value="${c.categoryID}"
                                <c:if test="${cid eq c.categoryID}">selected</c:if>>
                                ${c.categoryName}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <!-- brand -->
                <div>
                    <label class="block text-xs font-semibold text-slate-500 mb-1">Thương hiệu</label>
                    <select name="brandName"
                            class="w-full text-sm bg-white border border-slate-200 rounded-xl px-3 py-2 text-slate-700">
                        <option value="">Tất cả</option>
                        <c:forEach var="b" items="${brands}">
                            <option value="${b}"
                                <c:if test="${brandName eq b}">selected</c:if>>
                                ${b}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <!-- price -->
                <div>
                    <label class="block text-xs font-semibold text-slate-500 mb-1">Giá từ</label>
                    <input type="number" step="1000" name="minPrice" value="${minPrice}"
                           class="w-full text-sm bg-white border border-slate-200 rounded-xl px-3 py-2">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-500 mb-1">Giá đến</label>
                    <input type="number" step="1000" name="maxPrice" value="${maxPrice}"
                           class="w-full text-sm bg-white border border-slate-200 rounded-xl px-3 py-2">
                </div>

                <!-- sort -->
                <div>
                    <label class="block text-xs font-semibold text-slate-500 mb-1">Sắp xếp</label>
                    <select name="sort"
                            class="w-full text-sm bg-white border border-slate-200 rounded-xl px-3 py-2 text-slate-700">
                        <option value="newest"   <c:if test="${sort eq 'newest'}">selected</c:if>>Mới nhất</option>
                        <option value="priceasc" <c:if test="${sort eq 'priceasc'}">selected</c:if>>Giá tăng dần</option>
                        <option value="pricedesc"<c:if test="${sort eq 'pricedesc'}">selected</c:if>>Giá giảm dần</option>
                        <option value="stockasc" <c:if test="${sort eq 'stockasc'}">selected</c:if>>Tồn kho thấp → cao</option>
                        <option value="stockdesc"<c:if test="${sort eq 'stockdesc'}">selected</c:if>>Tồn kho cao → thấp</option>
                    </select>
                </div>

                <!-- buttons -->
                <div class="md:col-span-2 xl:col-span-1 flex gap-3">
                    <button type="submit"
                            class="flex-1 text-xs font-bold px-3 py-2 rounded-xl
                                   bg-slate-900 text-white hover:bg-neon-blue transition-colors">
                        <i class="fa-solid fa-filter mr-1"></i> Lọc
                    </button>
                    <a href="${path}/admin/products"
                       class="text-xs font-bold px-3 py-2 rounded-xl bg-slate-100 text-slate-600 hover:bg-slate-200">
                        Reset
                    </a>
                </div>
            </form>
        </div>

        <!-- TABLE -->
        <div class="neon-card p-0">
            <div class="px-6 pt-5 pb-3 border-b border-slate-100 flex justify-between items-center">
                <div>
                    <h3 class="font-bold text-lg text-slate-800 font-display">Danh sách sản phẩm</h3>
                    <p class="text-xs text-slate-400 mt-1">
                        Trang <span class="font-semibold">${currentPage}</span> / <span class="font-semibold">${totalPages}</span>
                    </p>
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="min-w-full text-sm">
                    <thead>
                    <tr class="bg-slate-50 text-xs font-bold text-slate-400 uppercase tracking-wider">
                        <th class="px-4 py-3 text-left">#</th>
                        <th class="px-4 py-3 text-left">Sản phẩm</th>
                        <th class="px-4 py-3 text-left">Danh mục</th>
                        <th class="px-4 py-3 text-left">Brand</th>
                        <th class="px-4 py-3 text-right">Giá</th>
                        <th class="px-4 py-3 text-center">Tồn kho</th>
                        <th class="px-4 py-3 text-right">Thao tác</th>
                    </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-50">
                    <c:choose>
                        <c:when test="${empty products}">
                            <tr>
                                <td colspan="7" class="px-4 py-6 text-center text-sm text-slate-400">
                                    Không có sản phẩm nào.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:set var="stt" value="${(currentPage-1) * pageSize}" />
                            <c:forEach var="p" items="${products}">
                                <c:set var="stt" value="${stt + 1}" />

                                <%-- Ảnh chính + 2 thumbnail phụ --%>
                                <c:set var="imgMain" value="${empty p.imageURL ? 'assets/img/no-image.png' : p.imageURL}" />
                                <c:set var="img2" value="" />
                                <c:set var="img3" value="" />
                                <c:if test="${not empty p.imageUrls}">
                                    <c:if test="${fn:length(p.imageUrls) >= 2}">
                                        <c:set var="img2" value="${p.imageUrls[1]}" />
                                    </c:if>
                                    <c:if test="${fn:length(p.imageUrls) >= 3}">
                                        <c:set var="img3" value="${p.imageUrls[2]}" />
                                    </c:if>
                                </c:if>

                                <tr class="hover:bg-indigo-50/40 transition-colors">
                                    <td class="px-4 py-3 text-xs text-slate-400 font-mono">${stt}</td>
                                    <td class="px-4 py-3">
                                        <div class="flex items-center gap-3">
                                            <div class="flex flex-col gap-1">
                                                <div class="w-16 h-16 rounded-xl bg-slate-100 overflow-hidden flex-shrink-0">
                                                    <img src="${path}/${imgMain}"
                                                         alt="${p.productName}"
                                                         class="w-full h-full object-cover">
                                                </div>
                                                <div class="flex gap-1">
                                                    <c:if test="${not empty img2}">
                                                        <div class="w-10 h-10 rounded-lg overflow-hidden border border-slate-100">
                                                            <img src="${path}/${img2}"
                                                                 alt="${p.productName}"
                                                                 class="w-full h-full object-cover">
                                                        </div>
                                                    </c:if>
                                                    <c:if test="${not empty img3}">
                                                        <div class="w-10 h-10 rounded-lg overflow-hidden border border-slate-100">
                                                            <img src="${path}/${img3}"
                                                                 alt="${p.productName}"
                                                                 class="w-full h-full object-cover">
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <div>
                                                <p class="font-semibold text-slate-800 truncate max-w-xs">${p.productName}</p>
                                                <p class="text-xs text-slate-400">
                                                    ID: <span class="font-mono">#${p.productID}</span>
                                                </p>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-sm text-slate-600">${p.categoryID}</td>
                                    <td class="px-4 py-3 text-sm text-slate-600">${p.brand}</td>
                                    <td class="px-4 py-3 text-right text-sm text-slate-800 font-semibold">
                                        <fmt:formatNumber value="${p.price}" type="number" pattern="#,##0"/> ₫
                                    </td>
                                    <td class="px-4 py-3 text-center">
                                        <c:choose>
                                            <c:when test="${p.stock le 0}">
                                                <span class="inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold bg-rose-50 text-rose-600 border border-rose-100">
                                                    Hết hàng
                                                </span>
                                            </c:when>
                                            <c:when test="${p.stock le 5}">
                                                <span class="inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold bg-amber-50 text-amber-600 border border-amber-100">
                                                    Còn ${p.stock}
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-600 border border-emerald-100">
                                                    ${p.stock} sp
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-4 py-3 text-right">
                                        <div class="inline-flex gap-2">
                                            <a href="${path}/admin/products?action=edit&id=${p.productID}"
                                               class="inline-flex items-center justify-center w-8 h-8 rounded-full bg-slate-900 text-white hover:bg-neon-blue text-xs"
                                               title="Sửa">
                                                <i class="fa-solid fa-pen-to-square"></i>
                                            </a>
                                            <form action="${path}/admin/products" method="post"
                                                  onsubmit="return confirm('Xóa sản phẩm này?');">
                                                <input type="hidden" name="action" value="delete"/>
                                                <input type="hidden" name="id" value="${p.productID}"/>
                                                <button type="submit"
                                                        class="w-8 h-8 rounded-full bg-rose-50 text-rose-600 hover:bg-rose-100 text-xs flex items-center justify-center"
                                                        title="Xóa">
                                                    <i class="fa-solid fa-trash"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>

            <!-- PAGINATION -->
            <c:if test="${totalPages > 1}">
                <div class="px-6 py-4 flex flex-col md:flex-row justify-between items-center gap-3 border-t border-slate-100 text-xs text-slate-500">
                    <p>
                        Hiển thị
                        <span class="font-semibold">
                            <c:choose>
                                <c:when test="${totalFiltered == 0}">0</c:when>
                                <c:otherwise>
                                    ${(currentPage-1)*pageSize + 1}
                                    -
                                    <c:choose>
                                        <c:when test="${currentPage*pageSize gt totalFiltered}">
                                            ${totalFiltered}
                                        </c:when>
                                        <c:otherwise>
                                            ${currentPage*pageSize}
                                        </c:otherwise>
                                    </c:choose>
                                </c:otherwise>
                            </c:choose>
                        </span>
                        trên tổng <span class="font-semibold">${totalFiltered}</span> sản phẩm lọc được.
                    </p>

                    <div class="flex items-center gap-1">
                        <c:forEach var="pno" begin="1" end="${totalPages}">
                            <c:url var="pageUrl" value="/admin/products">
                                <c:param name="page" value="${pno}"/>
                                <c:if test="${not empty q}"><c:param name="q" value="${q}"/></c:if>
                                <c:if test="${not empty cid}"><c:param name="cid" value="${cid}"/></c:if>
                                <c:if test="${not empty brandName}"><c:param name="brandName" value="${brandName}"/></c:if>
                                <c:if test="${not empty minPrice}"><c:param name="minPrice" value="${minPrice}"/></c:if>
                                <c:if test="${not empty maxPrice}"><c:param name="maxPrice" value="${maxPrice}"/></c:if>
                                <c:if test="${not empty sort}"><c:param name="sort" value="${sort}"/></c:if>
                            </c:url>
                            <a href="${pageUrl}"
                               class="px-3 py-1.5 rounded-lg border text-[11px] font-semibold
                                      ${pno eq currentPage
                                         ? 'bg-slate-900 text-white border-slate-900'
                                         : 'bg-white text-slate-600 border-slate-200 hover:bg-slate-50'}">
                                ${pno}
                            </a>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
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
