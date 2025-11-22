<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="includes/header.jsp" />

<main class="container" style="max-width: 600px; margin-top: 5rem; margin-bottom: 5rem;">
    <div class="card">
        <div class="card-body p-5">
            <h2 class="text-center mb-4">Quên Mật Khẩu</h2>
            <p class="text-center">Vui lòng nhập email của bạn để nhận mã đặt lại mật khẩu.</p>

            <c:if test="${not empty requestScope.error}">
                <div class="alert alert-danger" role="alert">
                    ${requestScope.error}
                </div>
            </c:if>

            <form action="password-reset" method="post">
                <input type="hidden" name="action" value="send-code">
                <div class="mb-3">
                    <label for="email" class="form-label">Địa chỉ Email</label>
                    <input type="email" class="form-control" id="email" name="email" required>
                </div>
                <button type="submit" class="btn btn-primary w-100 mt-3">Gửi mã</button>
            </form>
        </div>
    </div>
</main>

<jsp:include page="includes/footer.jsp" />