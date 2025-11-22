<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="includes/header.jsp" />

<main class="container my-5">
    <div class="row">
        <%-- Menu bên trái, tương tự trang account.jsp --%>
        <div class="col-md-3">
            <div class="list-group">
                <a href="account" class="list-group-item list-group-item-action">
                    <i class="fas fa-user-edit me-2"></i>Thông tin tài khoản
                </a>
                <a href="orders" class="list-group-item list-group-item-action">
                    <i class="fas fa-clipboard-list me-2"></i>Lịch sử đơn hàng
                </a>
                <%-- Thêm link trỏ đến trang đổi mật khẩu và active nó --%>
                <a href="change-password" class="list-group-item list-group-item-action active">
                    <i class="fas fa-key me-2"></i>Đổi mật khẩu
                </a>
                <a href="logout" class="list-group-item list-group-item-action text-danger">
                    <i class="fas fa-sign-out-alt me-2"></i>Đăng xuất
                </a>
            </div>
        </div>

        <%-- Form đổi mật khẩu --%>
        <div class="col-md-9">
            <h2>Đổi mật khẩu</h2>
            <p>Để bảo mật tài khoản, vui lòng không chia sẻ mật khẩu cho người khác.</p>
            <hr>

            <c:if test="${not empty requestScope.success}">
                <div class="alert alert-success">${requestScope.success}</div>
            </c:if>
            <c:if test="${not empty requestScope.error}">
                <div class="alert alert-danger">${requestScope.error}</div>
            </c:if>

            <form action="change-password" method="post" class="mt-4" style="max-width: 500px;">
                <div class="mb-3">
                    <label for="oldPassword" class="form-label">Mật khẩu cũ</label>
                    <input type="password" id="oldPassword" name="oldPassword" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label for="newPassword" class="form-label">Mật khẩu mới</label>
                    <input type="password" id="newPassword" name="newPassword" class="form-control" required>
                </div>
                <div class="mb-3">
                    <label for="re_newPassword" class="form-label">Xác nhận mật khẩu mới</label>
                    <input type="password" id="re_newPassword" name="re_newPassword" class="form-control" required>
                </div>
                
                <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
            </form>
        </div>
    </div>
</main>

<jsp:include page="includes/footer.jsp" />