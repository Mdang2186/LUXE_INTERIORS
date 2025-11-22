<%@ page pageEncoding="UTF-8"%> 
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />
<%
  String ctrl = (String) request.getAttribute("adminActive");
  if (ctrl == null) ctrl = "";
%>

<aside class="admin-sidebar">
    <h3 class="sidebar-brand text-center mb-4 luxe-title text-gold">FurniShop</h3>
            
    <ul class="nav flex-column">
        <li class="nav-item">
            <%-- ĐÃ SỬA: text-gold --%>
            <a class="nav-link <%=(ctrl.equals("dashboard")?"active text-gold":"")%>" href="${path}/admin/dashboard">
                <i class="fa-solid fa-chart-line me-2 fa-fw"></i> Dashboard
            </a>
        </li>
        <li class="nav-item">
            <%-- ĐÃ SỬA: text-gold --%>
            <a class="nav-link <%=(ctrl.equals("products")?"active text-gold":"")%>" href="${path}/admin/products">
                <i class="fa-solid fa-couch me-2 fa-fw"></i> Sản phẩm
            </a>
        </li>
        <li class="nav-item">
            <%-- ĐÃ SỬA: text-gold --%>
            <a class="nav-link <%=(ctrl.equals("categories")?"active text-gold":"")%>" href="${path}/admin/categories">
                 <i class="fa-solid fa-layer-group me-2 fa-fw"></i> Danh mục
            </a>
        </li>
        <li class="nav-item">
            <%-- ĐÃ SỬA: text-gold --%>
            <a class="nav-link <%=(ctrl.equals("orders")?"active text-gold":"")%>" href="${path}/admin/orders">
                <i class="fa-solid fa-receipt me-2 fa-fw"></i> Đơn hàng
            </a>
        </li>
        <li class="nav-item">
            <%-- ĐÃ SỬA: text-gold --%>
            <a class="nav-link <%=(ctrl.equals("users")?"active text-gold":"")%>" href="${path}/admin/users">
                <i class="fa-solid fa-users me-2 fa-fw"></i> Người dùng
            </a>
        </li>
        <li class="nav-item mt-3 border-top" style="border-color: var(--line) !important;">
             <a class="nav-link" href="${path}/logout">
                <i class="fas fa-sign-out-alt me-2 fa-fw"></i> Đăng xuất
            </a>
        </li>
    </ul>
</aside>