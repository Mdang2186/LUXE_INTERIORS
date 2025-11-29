<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>FurniShop - ${product == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'}</title>

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
                        display: ['"Outfit"', 'sans-serif']
                    },
                    colors: {
                        furni: {
                            50: '#f5f7ff',
                            100: '#e4ebff',
                            500: '#4361ee',
                            600: '#3a56d9',
                            700: '#2f46b5'
                        },
                        neon: {
                            pink: '#f72585',
                            purple: '#7209b7',
                            cyan: '#4cc9f0'
                        }
                    },
                    boxShadow: {
                        'glass': '0 18px 40px rgba(15,23,42,0.10)'
                    }
                }
            }
        }
    </script>

    <style>
        body {
            background:
                radial-gradient(circle at 0% 0%, rgba(67,97,238,0.12), transparent 55%),
                radial-gradient(circle at 100% 0%, rgba(247,37,133,0.12), transparent 55%),
                radial-gradient(circle at 100% 100%, rgba(76,201,240,0.10), transparent 55%),
                #f3f4ff;
        }
        .glass-panel {
            background: rgba(255,255,255,0.75);
            backdrop-filter: blur(22px);
            -webkit-backdrop-filter: blur(22px);
            border: 1px solid rgba(255,255,255,0.9);
        }
        .sidebar-link {
            transition: all 0.25s ease;
            border-left: 3px solid transparent;
        }
        .sidebar-link:hover {
            background: linear-gradient(90deg, rgba(67,97,238,0.08) 0%, transparent 100%);
            color: #4361ee;
            padding-left: 1.25rem;
        }
        .sidebar-link.active {
            background: linear-gradient(90deg, rgba(67,97,238,0.16) 0%, transparent 100%);
            color: #4361ee;
            border-left-color: #4361ee;
            font-weight: 600;
        }
        .thumb-active {
            outline: 2px solid #4361ee;
            outline-offset: 2px;
        }
        .custom-scroll::-webkit-scrollbar { width: 6px; }
        .custom-scroll::-webkit-scrollbar-thumb {
            background: rgba(148,163,184,0.8); border-radius: 999px;
        }
    </style>
</head>
<body class="flex h-screen w-full font-sans antialiased">

<!-- SIDEBAR (đồng bộ với products-list.jsp) -->
<aside class="w-72 glass-panel flex flex-col h-full flex-shrink-0 border-r border-white/60">
    <div class="h-24 flex items-center px-8">
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-2xl bg-gradient-to-tr from-furni-500 via-neon-purple to-neon-pink
                        flex items-center justify-center text-white shadow-md">
                <i class="fa-solid fa-couch text-lg"></i>
            </div>
            <div>
                <h1 class="text-xl font-bold font-display tracking-tight text-slate-900">
                    Furni<span class="text-furni-500">Shop</span>
                </h1>
                <p class="text-[10px] font-bold text-neon-purple tracking-widest uppercase">Admin v2.0</p>
            </div>
        </div>
    </div>

    <nav class="flex-1 px-4 py-4 space-y-1 overflow-y-auto custom-scroll">
        <a href="${path}/admin/dashboard"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl
                  text-slate-500 ${adminActive == 'dashboard' ? 'active' : ''}">
            <i class="fa-solid fa-chart-pie w-5 text-center"></i> <span>Dashboard</span>
        </a>
        <a href="${path}/admin/products"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl
                  text-slate-500 ${adminActive == 'products' ? 'active' : ''}">
            <i class="fa-solid fa-box-open w-5 text-center"></i> <span>Sản phẩm</span>
        </a>
        <a href="${path}/admin/orders"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl
                  text-slate-500 ${adminActive == 'orders' ? 'active' : ''}">
            <i class="fa-solid fa-receipt w-5 text-center"></i> <span>Đơn hàng</span>
        </a>
        <a href="${path}/admin/categories"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl
                  text-slate-500 ${adminActive == 'categories' ? 'active' : ''}">
            <i class="fa-solid fa-layer-group w-5 text-center"></i> <span>Danh mục</span>
        </a>
        <a href="${path}/admin/users"
           class="sidebar-link flex items-center gap-4 px-4 py-3.5 text-sm font-medium rounded-xl
                  text-slate-500 ${adminActive == 'users' ? 'active' : ''}">
            <i class="fa-solid fa-users w-5 text-center"></i> <span>Người dùng</span>
        </a>
    </nav>
</aside>

<!-- MAIN -->
<main class="flex-1 flex flex-col h-full min-w-0 overflow-hidden">
    <!-- HEADER -->
    <header class="h-24 flex items-center justify-between px-10 shrink-0">
        <div>
            <h2 class="text-2xl font-bold font-display text-slate-900 tracking-tight">
                ${product == null ? 'Thêm sản phẩm mới' : 'Sửa sản phẩm'}
            </h2>
            <p class="text-sm text-slate-500 mt-1">
                Điền đầy đủ thông tin & 3 ảnh sản phẩm để hiển thị đẹp trên website FurniShop.
            </p>
        </div>
        <a href="${path}/admin/products"
           class="inline-flex items-center gap-2 text-xs font-bold px-4 py-2.5 rounded-xl
                  bg-white/80 text-slate-600 border border-slate-200 hover:border-furni-500 hover:text-furni-500">
            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
        </a>
    </header>

    <!-- CONTENT -->
    <div class="flex-1 overflow-y-auto px-10 pb-10 custom-scroll">
        <div class="max-w-6xl mx-auto glass-panel rounded-3xl shadow-glass p-7">
            <form action="${path}/admin/products" method="post"
                  class="grid grid-cols-1 xl:grid-cols-12 gap-8">
                <input type="hidden" name="action" value="save"/>
                <c:if test="${product != null}">
                    <input type="hidden" name="productID" value="${product.productID}"/>
                </c:if>

                <!-- LEFT: INFO -->
                <section class="xl:col-span-7 space-y-5">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-semibold text-slate-500 mb-1">
                                Tên sản phẩm
                            </label>
                            <input type="text" name="productName"
                                   value="${product != null ? product.productName : ''}"
                                   required
                                   class="w-full text-sm bg-white border border-slate-200 rounded-2xl px-3.5 py-2.5
                                          focus:outline-none focus:ring-2 focus:ring-furni-500/70">
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-slate-500 mb-1">
                                Danh mục
                            </label>
                            <select name="categoryID" required
                                    class="w-full text-sm bg-white border border-slate-200 rounded-2xl px-3.5 py-2.5">
                                <c:forEach var="c" items="${categories}">
                                    <option value="${c.categoryID}"
                                        ${product != null && product.categoryID == c.categoryID ? 'selected' : ''}>
                                        ${c.categoryName}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div>
                            <label class="block text-xs font-semibold text-slate-500 mb-1">Thương hiệu</label>
                            <input type="text" name="brand"
                                   value="${product != null ? product.brand : ''}"
                                   class="w-full text-sm bg-white border border-slate-200 rounded-2xl px-3.5 py-2.5">
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-slate-500 mb-1">Giá (VND)</label>
                            <input type="number" name="price" step="1000" min="0"
                                   value="${product != null ? product.price : ''}"
                                   required
                                   class="w-full text-sm bg-white border border-slate-200 rounded-2xl px-3.5 py-2.5">
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-slate-500 mb-1">Tồn kho</label>
                            <input type="number" name="stock" min="0"
                                   value="${product != null ? product.stock : 0}"
                                   required
                                   class="w-full text-sm bg-white border border-slate-200 rounded-2xl px-3.5 py-2.5">
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-semibold text-slate-500 mb-1">Chất liệu</label>
                            <input type="text" name="material"
                                   value="${product != null ? product.material : ''}"
                                   class="w-full text-sm bg-white border border-slate-200 rounded-2xl px-3.5 py-2.5">
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-slate-500 mb-1">Kích thước</label>
                            <input type="text" name="dimensions"
                                   value="${product != null ? product.dimensions : ''}"
                                   placeholder="VD: 200cm x 160cm x 40cm"
                                   class="w-full text-sm bg-white border border-slate-200 rounded-2xl px-3.5 py-2.5">
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-slate-500 mb-1">
                            Tính năng nổi bật
                        </label>
                        <textarea name="features" rows="2"
                                  class="w-full text-sm bg-white border border-slate-200 rounded-2xl px-3.5 py-2.5
                                         focus:outline-none focus:ring-1 focus:ring-furni-500/70"
                                  placeholder="VD: Khung gỗ tự nhiên, nệm mút cao cấp, bảo hành 2 năm...">${product != null ? product.features : ''}</textarea>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-slate-500 mb-1">
                            Mô tả chi tiết
                        </label>
                        <textarea name="description" rows="4"
                                  class="w-full text-sm bg-white border border-slate-200 rounded-2xl px-3.5 py-2.5
                                         focus:outline-none focus:ring-1 focus:ring-furni-500/70">${product != null ? product.description : ''}</textarea>
                    </div>
                </section>

                <!-- RIGHT: IMAGES (3 ảnh, đồng bộ Controller: imageUrl1/2/3) -->
                <section class="xl:col-span-5 space-y-4">
                    <div class="rounded-3xl bg-gradient-to-br from-white via-furni-50 to-white p-4 border border-white/80">
                        <h3 class="text-sm font-semibold text-slate-700 flex items-center gap-2 mb-3">
                            <span class="w-7 h-7 rounded-full bg-slate-900 text-white flex items-center justify-center text-xs">
                                <i class="fa-solid fa-image"></i>
                            </span>
                            Ảnh sản phẩm
                        </h3>

                        <div class="space-y-3">
                            <div>
                                <label class="block text-[11px] font-semibold text-slate-500 mb-1">
                                    Ảnh 1 (chính)
                                </label>
                                <input type="text" id="image1" name="imageUrl1"
                                       value="${not empty img1 ? img1 : (product != null ? product.imageURL : '')}"
                                       class="w-full text-xs bg-white border border-slate-200 rounded-2xl px-3 py-2"
                                       data-image-input="0">
                            </div>
                            <div>
                                <label class="block text-[11px] font-semibold text-slate-500 mb-1">
                                    Ảnh 2
                                </label>
                                <input type="text" id="image2" name="imageUrl2"
                                       value="${img2}"
                                       class="w-full text-xs bg-white border border-slate-200 rounded-2xl px-3 py-2"
                                       data-image-input="1">
                            </div>
                            <div>
                                <label class="block text-[11px] font-semibold text-slate-500 mb-1">
                                    Ảnh 3
                                </label>
                                <input type="text" id="image3" name="imageUrl3"
                                       value="${img3}"
                                       class="w-full text-xs bg-white border border-slate-200 rounded-2xl px-3 py-2"
                                       data-image-input="2">
                            </div>

                            <p class="text-[11px] text-slate-400">
                                Dán URL tuyệt đối hoặc đường dẫn tương đối trong project
                                (ví dụ: <span class="font-mono">assets/images/ban-trang-diem-1.jpg</span>).
                            </p>
                        </div>

                        <!-- PREVIEW -->
                        <div class="mt-4 grid grid-cols-1 gap-3">
                            <div class="relative">
                                <div class="absolute inset-x-0 -top-3 flex justify-center pointer-events-none">
                                    <div class="h-6 w-40 rounded-full bg-gradient-to-r from-furni-500 via-neon-pink to-neon-cyan opacity-60 blur-md"></div>
                                </div>
                                <div class="aspect-[4/3] w-full bg-slate-100 rounded-2xl overflow-hidden flex items-center justify-center border border-slate-200 relative">
                                    <img id="mainPreview" alt="Preview"
                                         class="w-full h-full object-cover"
                                         src="<c:choose>
                                                <c:when test='${not empty img1}'>
                                                    ${img1}
                                                </c:when>
                                                <c:when test='${product != null && not empty product.imageURL}'>
                                                    ${product.imageURL}
                                                </c:when>
                                                <c:otherwise>${path}/assets/img/no-image.png</c:otherwise>
                                              </c:choose>">
                                </div>
                            </div>

                            <div class="flex gap-3">
                                <div class="flex-1 aspect-[4/3] bg-slate-100 rounded-xl overflow-hidden border border-slate-200">
                                    <img id="thumb0" class="w-full h-full object-cover thumb-active"
                                         src="<c:out value='${not empty img1 ? img1 : (product != null ? product.imageURL : path.concat("/assets/img/no-image.png"))}'/>"
                                         alt="Thumb 1">
                                </div>
                                <div class="flex-1 aspect-[4/3] bg-slate-100 rounded-xl overflow-hidden border border-slate-200">
                                    <img id="thumb1" class="w-full h-full object-cover"
                                         src="<c:out value='${not empty img2 ? img2 : path.concat("/assets/img/no-image.png")}'/>"
                                         alt="Thumb 2">
                                </div>
                                <div class="flex-1 aspect-[4/3] bg-slate-100 rounded-xl overflow-hidden border border-slate-200">
                                    <img id="thumb2" class="w-full h-full object-cover"
                                         src="<c:out value='${not empty img3 ? img3 : path.concat("/assets/img/no-image.png")}'/>"
                                         alt="Thumb 3">
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="pt-1 flex flex-col gap-2">
                        <button type="submit"
                                class="w-full inline-flex items-center justify-center gap-2 text-sm font-bold px-4 py-3 rounded-2xl
                                       bg-slate-900 text-white hover:bg-furni-600 shadow-md">
                            <i class="fa-solid fa-floppy-disk"></i>
                            ${product == null ? 'Lưu sản phẩm mới' : 'Cập nhật sản phẩm'}
                        </button>
                        <a href="${path}/admin/products"
                           class="w-full inline-flex items-center justify-center gap-2 text-xs font-semibold px-4 py-3 rounded-2xl
                                  bg-white text-slate-600 border border-slate-200 hover:bg-slate-50">
                            Hủy
                        </a>
                    </div>
                </section>
            </form>
        </div>
    </div>
</main>

<script>
    const ctxPath = '${path}';

    function resolveUrl(url) {
        if (!url || url.trim().length === 0) {
            return ctxPath + '/assets/img/no-image.png';
        }
        url = url.trim();
        if (url.startsWith('http://') || url.startsWith('https://')) {
            return url;
        }
        if (url.startsWith('/')) {
            return ctxPath + url;
        }
        return ctxPath + '/' + url;
    }

    function refreshPreview() {
        const inputs = document.querySelectorAll('[data-image-input]');
        const mainImg = document.getElementById('mainPreview');
        const thumbs = [
            document.getElementById('thumb0'),
            document.getElementById('thumb1'),
            document.getElementById('thumb2')
        ];

        let mainSet = false;
        inputs.forEach((input, idx) => {
            const raw = input.value || '';
            const url = resolveUrl(raw);
            if (thumbs[idx]) {
                thumbs[idx].src = url;
            }
            if (!mainSet && raw.trim().length > 0) {
                mainImg.src = url;
                mainSet = true;
            }
        });

        if (!mainSet) {
            mainImg.src = resolveUrl('');
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        const inputs = document.querySelectorAll('[data-image-input]');
        const mainImg = document.getElementById('mainPreview');
        const thumbs = [
            document.getElementById('thumb0'),
            document.getElementById('thumb1'),
            document.getElementById('thumb2')
        ];

        // Khi nhập URL -> update preview
        inputs.forEach((input) => {
            input.addEventListener('input', refreshPreview);
            input.addEventListener('focus', () => {
                mainImg.src = resolveUrl(input.value);
            });
        });

        // Click thumb -> chọn main + highlight
        thumbs.forEach((thumb, idx) => {
            if (!thumb) return;
            thumb.style.cursor = 'pointer';
            thumb.addEventListener('click', () => {
                mainImg.src = thumb.src;
                thumbs.forEach(t => t && t.classList.remove('thumb-active'));
                thumb.classList.add('thumb-active');
            });
        });

        // Khởi tạo preview lúc đầu
        refreshPreview();
    });
</script>

</body>
</html>
