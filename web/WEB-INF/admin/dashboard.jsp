<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/admin/includes/admin-header.jsp"/>
<jsp:include page="includes/admin-sidebar.jsp"/>

<main class="admin-content-main">

    <div class="row g-3">
        <div class="col-md-3"><div class="p-3 luxe-card">
                <div class="d-flex justify-content-between"><span class="luxe-title">Sản phẩm</span><i class="fa-solid fa-couch"></i></div>
                <div class="display-6 fw-bold mt-2">${countProducts}</div>
            </div></div>
        <div class="col-md-3"><div class="p-3 luxe-card">
                <div class="d-flex justify-content-between"><span class="luxe-title">Danh mục</span><i class="fa-solid fa-layer-group"></i></div>
                <div class="display-6 fw-bold mt-2">${countCategories}</div>
            </div></div>
        <div class="col-md-3"><div class="p-3 luxe-card">
                <div class="d-flex justify-content-between"><span class="luxe-title">Đơn hàng</span><i class="fa-solid fa-receipt"></i></div>
                <div class="display-6 fw-bold mt-2">${countOrders}</div>
            </div></div>
        <div class="col-md-3"><div class="p-3 luxe-card">
                <div class="d-flex justify-content-between"><span class="luxe-title">Người dùng</span><i class="fa-solid fa-users"></i></div>
                <div class="display-6 fw-bold mt-2">${countUsers}</div>
            </div></div>
    </div>

    <div class="row g-3 mt-1">
        <div class="col-lg-8"><div class="p-3 luxe-card">
                <div class="d-flex justify-content-between align-items-center">
                    <h5 class="m-0 luxe-title">Doanh thu 7 ngày</h5>
                    <span class="luxe-chip"><i class="fa-regular fa-calendar"></i> Gần nhất</span>
                </div>
                <canvas id="revChart" height="110"></canvas>
            </div></div>
        <div class="col-lg-4"><div class="p-3 luxe-card">
                <h5 class="luxe-title">Top bán chạy</h5>
                <ol class="mt-3">
                    <c:forEach items="${topProducts}" var="t">
                        <li class="mb-2 d-flex justify-content-between">
                            <span>${t.productName}</span><span class="badge-ok">${t.quantity}</span>
                        </li>
                    </c:forEach>
                </ol>
            </div></div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        const labels = ${revLabels==null? "[]": revLabels};
        const values = ${revValues==null? "[]": revValues};
        new Chart(document.getElementById('revChart'), {
            type: 'line',
            data: {labels: labels, datasets: [{label: 'VNĐ', data: values, tension: .35}]},
            options: {plugins: {legend: {display: false}}, scales: {y: {beginAtZero: true}}}
        });
    </script>

</main>
<jsp:include page="/WEB-INF/admin/includes/admin-footer.jsp"/>