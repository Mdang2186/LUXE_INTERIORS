<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="path" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/admin/includes/admin-header.jsp"/>
<jsp:include page="includes/admin-sidebar.jsp"/>

<main class="admin-content-main">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="luxe-title m-0">Quản lý Đơn hàng</h1>
        <div class="luxe-card p-2">
            <form class="d-flex gap-2">
                <select name="status" class="form-select form-dark" onchange="this.form.submit()">
                    <option value="">Tất cả trạng thái</option>
                    <c:forEach var="s" items="${['Pending','Processing','Shipped','Delivered','Cancelled']}">
                        <option value="${s}" <c:if test="${status==s}">selected</c:if>>${s}</option>
                    </c:forEach>
                </select>
            </form>
        </div>
    </div>

    <div class="luxe-card p-3">
        <div class="table-responsive">
            <table class="table table-luxe">
                <thead>
                    <tr>
                        <th>Mã ĐH</th>
                        <th>Ngày đặt</th>
                        <th>Khách hàng</th>
                        <th>Tổng tiền</th>
                        <th>Trạng thái</th>
                        <th class="text-end">Chi tiết</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${orders}" var="o">
                        <tr>
                            <td>#${o.orderID}</td>
                            <td><fmt:formatDate value="${o.orderDate}" pattern="HH:mm dd/MM/yyyy"/></td>
                            <td>${o.userID}</td>
                            <td><fmt:formatNumber value="${o.totalAmount}" type="currency" currencyCode="VND"/></td>
                            <td>
                                <span class="${o.status=='Pending' || o.status=='Processing' ? 'badge-warn' : (o.status=='Cancelled' ? 'badge-bad' : 'badge-ok')}">
                                    ${o.status}
                                </span>
                            </td>
                            <td class="text-end">
                                <a class="btn btn-dark btn-sm" href="${path}/admin/orders?action=detail&id=${o.orderID}">
                                    Xem
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
    
    <%-- Phân trang --%>
    <c:if test="${totalPages > 1}">
      <nav class="mt-4"><ul class="pagination">
        <c:forEach begin="1" end="${totalPages}" var="i">
            <li class="page-item ${i == currentPage ? 'active' : ''}">
                <a class="page-link" href="?page=${i}&status=${status}">${i}</a>
            </li>
        </c:forEach>
      </ul></nav>
    </c:if>

</main>

<jsp:include page="/WEB-INF/admin/includes/admin-footer.jsp"/>