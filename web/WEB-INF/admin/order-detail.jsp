<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/admin/includes/admin-header.jsp"/>
<jsp:include page="includes/admin-sidebar.jsp"/>


<main class="admin-content-main">

    <h1 class="luxe-title mb-3">Chi tiết Đơn hàng #${order.orderID}</h1>
    
    <div class="row g-4">
        <div class="col-lg-5">
            <div class="p-4 luxe-card h-100">
                <h5 class="luxe-title mb-3">Thông tin đơn hàng</h5>
                <p class="mb-2"><strong>Ngày đặt:</strong> <fmt:formatDate value="${order.orderDate}" pattern="HH:mm dd/MM/yyyy"/></p>
                <p class="mb-2"><strong>Mã khách hàng:</strong> ${order.userID}</p>
                <p class="mb-2"><strong>Thanh toán:</strong> ${order.paymentMethod}</p>
                <p class="mb-2"><strong>Địa chỉ:</strong> ${order.shippingAddress}</p>
                <p class="mb-2"><strong>Ghi chú:</strong> ${order.note}</p>
                
                <hr style="border-color: var(--line);">
                
                <h6 class="luxe-title mb-3">Cập nhật trạng thái</h6>
                <form method="post" action="${path}/admin/orders" class="d-flex gap-2">
                    <input type="hidden" name="action" value="status"/>
                    <input type="hidden" name="id" value="${order.orderID}"/>
                    <select name="status" class="form-select form-dark">
                        <c:forEach var="s" items="${['Pending','Processing','Shipped','Delivered','Cancelled']}">
                            <option value="${s}" <c:if test="${order.status==s}">selected</c:if>>${s}</option>
                        </c:forEach>
                    </select>
                    <button class="btn btn-gold">Cập nhật</button>
                </form>
            </div>
        </div>

        <div class="col-lg-7">
            <div class="p-4 luxe-card h-100">
                <h5 class="luxe-title mb-3">Chi tiết sản phẩm</h5>
                <div class="table-responsive">
                    <table class="table table-luxe">
                        <thead>
                            <tr>
                                <th>Sản phẩm</th>
                                <th>SL</th>
                                <th>Đơn giá</th>
                                <th class="text-end">Tổng</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${order.items}" var="it">
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <img src="${it.product.imageURL}" class="rounded me-2" style="height:48px;width:48px;object-fit:cover" onerror="this.src='${path}/assets/images/placeholder.png'"/>
                                            <span>${it.product.productName}</span>
                                        </div>
                                    </td>
                                    <td>${it.quantity}</td>
                                    <td><fmt:formatNumber value="${it.unitPrice}" type="currency" currencyCode="VND"/></td>
                                    <td class="text-end fw-bold"><fmt:formatNumber value="${it.quantity * it.unitPrice}" type="currency" currencyCode="VND"/></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <hr style="border-color: var(--line);">
                <div class="text-end">
                    <span class="text-muted me-2">Tổng cộng:</span>
                    <span class="luxe-title fs-4"><fmt:formatNumber value="${order.totalAmount}" type="currency" currencyCode="VND"/></span>
                </div>
            </div>
        </div>
    </div>

</main>


<jsp:include page="/WEB-INF/admin/includes/admin-footer.jsp"/>