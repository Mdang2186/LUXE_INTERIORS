<%@ page pageEncoding="UTF-8"%> 
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />
<%
  // Lấy active page từ request để highlight menu
  String activePage = (String) request.getAttribute("adminActive");
  if (activePage == null) activePage = "";
%>

<aside id="sidebar" 
       class="glass-sidebar w-72 flex-shrink-0 flex flex-col h-full fixed lg:static transform -translate-x-full lg:translate-x-0 transition-transform duration-300 z-50 bg-white/80 border-r border-slate-200 backdrop-blur-xl">
    
    <div class="h-20 flex items-center justify-center border-b border-slate-100/50">
        <a href="${path}/admin/dashboard" class="flex items-center gap-3 group">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-indigo-600 to-purple-600 flex items-center justify-center text-white shadow-lg shadow-indigo-500/30 group-hover:scale-110 transition-transform duration-300">
                <i class="fa-solid fa-couch text-lg"></i>
            </div>
            <div class="flex flex-col">
                <span class="text-xl font-extrabold bg-clip-text text-transparent bg-gradient-to-r from-slate-800 to-slate-600 tracking-tight">FurniShop</span>
                <span class="text-[10px] font-bold text-indigo-500 uppercase tracking-widest">Admin Panel</span>
            </div>
        </a>
    </div>

    <div class="flex-1 overflow-y-auto py-6 px-4 space-y-1 custom-scroll">
        <p class="px-4 text-[11px] font-bold text-slate-400 uppercase tracking-widest mb-2">Thống kê</p>
        
        <a href="${path}/admin/dashboard" class="nav-link flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl text-slate-500 hover:bg-indigo-50 hover:text-indigo-600 transition-all <%=activePage.equals("dashboard")?"active shadow-sm bg-indigo-50 text-indigo-600":""%>">
            <i class="fa-solid fa-chart-pie w-5 text-center transition-colors"></i> <span>Tổng quan</span>
        </a>

        <p class="px-4 text-[11px] font-bold text-slate-400 uppercase tracking-widest mt-6 mb-2">Quản lý</p>

        <a href="${path}/admin/products" class="nav-link flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl text-slate-500 hover:bg-indigo-50 hover:text-indigo-600 transition-all <%=activePage.equals("products")?"active shadow-sm bg-indigo-50 text-indigo-600":""%>">
            <i class="fa-solid fa-box-open w-5 text-center transition-colors"></i> <span>Sản phẩm</span>
        </a>

        <a href="${path}/admin/categories" class="nav-link flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl text-slate-500 hover:bg-indigo-50 hover:text-indigo-600 transition-all <%=activePage.equals("categories")?"active shadow-sm bg-indigo-50 text-indigo-600":""%>">
            <i class="fa-solid fa-layer-group w-5 text-center transition-colors"></i> <span>Danh mục</span>
        </a>

        <a href="${path}/admin/orders" class="nav-link flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl text-slate-500 hover:bg-indigo-50 hover:text-indigo-600 transition-all <%=activePage.equals("orders")?"active shadow-sm bg-indigo-50 text-indigo-600":""%>">
            <i class="fa-solid fa-receipt w-5 text-center transition-colors"></i> <span>Đơn hàng</span>
            <span class="ml-auto bg-red-100 text-red-600 text-[10px] font-bold px-2 py-0.5 rounded-full">Hot</span>
        </a>

        <a href="${path}/admin/users" class="nav-link flex items-center gap-3 px-4 py-3 text-sm font-medium rounded-xl text-slate-500 hover:bg-indigo-50 hover:text-indigo-600 transition-all <%=activePage.equals("users")?"active shadow-sm bg-indigo-50 text-indigo-600":""%>">
            <i class="fa-solid fa-users w-5 text-center transition-colors"></i> <span>Người dùng</span>
        </a>
    </div>

    <div class="p-4 border-t border-slate-100/80">
        <a href="${path}/logout" class="flex items-center gap-3 p-3 rounded-xl border border-slate-200 bg-white hover:border-red-200 hover:shadow-md transition-all group cursor-pointer">
            <div class="w-9 h-9 rounded-lg bg-slate-50 flex items-center justify-center text-slate-400 group-hover:text-red-500 transition-colors">
                <i class="fa-solid fa-right-from-bracket"></i>
            </div>
            <div class="flex-1 min-w-0">
                <p class="text-xs font-bold text-slate-700 group-hover:text-red-600 transition-colors">Đăng xuất</p>
                <p class="text-[10px] text-slate-400 truncate">Kết thúc phiên làm việc</p>
            </div>
        </a>
    </div>
</aside>