<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="includes/header.jsp" />

<main class="container" style="max-width: 600px; margin-top: 5rem; margin-bottom: 5rem;">
    <div class="card">
        <div class="card-body p-5">
            <h2 class="text-center mb-4">Đặt Lại Mật Khẩu</h2>
            <p class="text-center">Một mã xác thực đã được gửi đến email của bạn.</p>
            
            <c:if test="${not empty requestScope.error}">
                <div class="alert alert-danger" role="alert">
                    ${requestScope.error}
                </div>
            </c:if>
            
            <form action="password-reset" method="post">
                <input type="hidden" name="action" value="verify-and-reset">
                
                <div class="mb-3">
                    <label for="code" class="form-label">Mã xác thực</label>
                    <input type="text" class="form-control" id="code" name="code" required>
                </div>
                
                <div class="mb-3">
                    <label for="newPassword" class="form-label">Mật khẩu mới</label>
                    <input type="password" class="form-control" id="newPassword" name="newPassword" required>
                </div>
                
                <button type="submit" class="btn btn-primary w-100 mt-3">Đặt Lại Mật Khẩu</button>
            </form>
        </div>
    </div>
</main>

<jsp:include page="includes/footer.jsp" />