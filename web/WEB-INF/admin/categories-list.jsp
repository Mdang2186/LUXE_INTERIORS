<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/admin/includes/admin-header.jsp"/>
<jsp:include page="includes/admin-sidebar.jsp"/>


<main class="admin-content-main">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="luxe-title m-0">Quản lý Danh mục</h1>
        <a href="${path}/admin/categories?action=create" class="btn btn-gold">
            Thêm danh mục
        </a>
    </div>

    <c:if test="${not empty sessionScope.success}">
        <div class="alert alert-success">${sessionScope.success}</div>
        <c:remove var="success" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger">${sessionScope.error}</div>
        <c:remove var="error" scope="session"/>
    </c:if>

    <div class="luxe-card p-3">
        <div class="table-responsive">
            <table class="table table-luxe">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Tên danh mục</th>
                        <th class="text-end">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${categories}" var="c">
                        <tr>
                            <td>${c.categoryID}</td>
                            <td><b>${c.categoryName}</b></td>
                            <td class="text-end">
                                <a class="btn btn-dark btn-sm" href="${path}/admin/categories?action=edit&id=${c.categoryID}">Sửa</a>
                                
                                <form class="d-inline" method="post" action="${path}/admin/categories" onsubmit="return confirm('Bạn có chắc muốn xóa danh mục này? Nó có thể ảnh hưởng đến các sản phẩm liên quan.')">
                                    <input type="hidden" name="action" value="delete"/>
                                    <input type="hidden" name="id" value="${c.categoryID}"/>
                                    <button class="btn btn-dark btn-sm">Xóa</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

</main>

<jsp:include page="/WEB-INF/admin/includes/admin-footer.jsp"/>