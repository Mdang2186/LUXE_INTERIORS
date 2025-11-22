<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="path" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/admin/includes/admin-header.jsp"/>
<jsp:include page="includes/admin-sidebar.jsp"/>


<main class="admin-content-main">

    <h1 class="luxe-title mb-4">${empty product?'Thêm sản phẩm mới':'Chỉnh sửa sản phẩm'}</h1>

    <div class="luxe-card p-4">
        <form method="post" action="${path}/admin/products" class="row g-3">
            <input type="hidden" name="action" value="save"/>
            <c:if test="${not empty product}">
                <input type="hidden" name="productID" value="${product.productID}"/>
            </c:if>

            <div class="col-md-6">
                <label class="form-label">Tên sản phẩm</label>
                <input class="form-control form-dark" name="productName" value="${product.productName}" required/>
            </div>
            <div class="col-md-3">
                <label class="form-label">Giá (VND)</label>
                <input class="form-control form-dark" type="number" step="1000" name="price" value="${product.price}" required/>
            </div>
            <div class="col-md-3">
                <label class="form-label">Số lượng kho</label>
                <input class="form-control form-dark" type="number" name="stock" value="${product.stock}" required/>
            </div>

            <div class="col-md-4">
                <label class="form-label">Danh mục</label>
                <select name="categoryID" class="form-select form-dark" required>
                    <c:forEach items="${categories}" var="c">
                        <option value="${c.categoryID}" <c:if test="${product.categoryID==c.categoryID}">selected</c:if>>${c.categoryName}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-md-4">
                <label class="form-label">Chất liệu</label>
                <input class="form-control form-dark" name="material" value="${product.material}"/>
            </div>
            <div class="col-md-4">
                <label class="form-label">Kích thước</label>
                <input class="form-control form-dark" name="dimensions" value="${product.dimensions}"/>
            </div>

            <div class="col-md-6">
                <label class="form-label">Ảnh chính URL</label>
                <input class="form-control form-dark" name="imageURL" value="${product.imageURL}"/>
            </div>
            <div class="col-md-6">
                <label class="form-label">Thương hiệu</label>
                <input class="form-control form-dark" name="brand" value="${product.brand}"/>
            </div>

            <div class="col-12">
                <label class="form-label">Mô tả</label>
                <textarea name="description" rows="4" class="form-control form-dark">${product.description}</textarea>
            </div>
            
            <div class="col-12">
                <label class="form-label">Đặc điểm (Features)</label>
                <textarea name="features" rows="3" class="form-control form-dark">${product.features}</textarea>
            </div>

            <div class="col-12 d-flex gap-2">
                <button class="btn btn-gold">Lưu sản phẩm</button>
                <a class="btn btn-dark" href="${path}/admin/products">Hủy</a>
            </div>
        </form>
    </div>

</main>

<jsp:include page="/WEB-INF/admin/includes/admin-footer.jsp"/>