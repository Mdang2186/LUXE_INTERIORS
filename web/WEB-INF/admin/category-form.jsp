<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/admin/includes/admin-header.jsp"/>
<jsp:include page="includes/admin-sidebar.jsp"/>

<main class="admin-content-main">

    <h1 class="luxe-title mb-4">${empty category ? 'Thêm danh mục mới' : 'Chỉnh sửa danh mục'}</h1>

    <div class="luxe-card p-4" style="max-width: 700px;">
        <form method="post" action="${path}/admin/categories" class="row g-3">
            <input type="hidden" name="action" value="save"/>
            <c:if test="${not empty category}">
                <input type="hidden" name="categoryID" value="${category.categoryID}"/>
            </c:if>
            
            <div class="col-12">
                <label class="form-label">Tên danh mục</label>
                <input class="form-control form-dark" name="categoryName" value="${category.categoryName}" required/>
            </div>
            
            <div class="col-12 d-flex gap-2">
                <button class="btn btn-gold">Lưu danh mục</button>
                <a class="btn btn-dark" href="${path}/admin/categories">Hủy</a>
            </div>
        </form>
    </div>

</main>

<jsp:include page="/WEB-INF/admin/includes/admin-footer.jsp"/>