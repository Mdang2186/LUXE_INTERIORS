<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/includes/header.jsp" />

<main class="container" style="max-width:640px;margin:5rem auto">
  <div class="card-luxury p-4 g-gold">
    <h2 class="font-playfair mb-3">Tạo tài khoản</h2>

    <c:if test="${not empty error}">
      <div class="alert alert-danger">${error}</div>
    </c:if>
    <c:if test="${not empty success}">
      <div class="alert alert-success">${success}</div>
    </c:if>

    <form action="<c:url value='/register'/>" method="post" class="needs-validation" novalidate>
      <div class="mb-3">
        <label class="form-label fw-semibold">Họ và tên</label>
        <input name="fullName" class="form-control rounded-pill" required>
        <div class="invalid-feedback">Vui lòng nhập họ tên.</div>
      </div>

      <div class="mb-3">
        <label class="form-label fw-semibold">Email</label>
        <input type="email" name="email" class="form-control rounded-pill" required>
        <div class="invalid-feedback">Email không hợp lệ.</div>
      </div>

      <div class="mb-3">
        <label class="form-label fw-semibold">Mật khẩu</label>
        <input type="password" name="password" minlength="6" class="form-control rounded-pill" required>
        <div class="invalid-feedback">Tối thiểu 6 ký tự.</div>
      </div>

      <div class="mb-4">
        <label class="form-label fw-semibold">Nhập lại mật khẩu</label>
        <input type="password" name="re_password" minlength="6" class="form-control rounded-pill" required>
      </div>

      <button class="btn-luxury ripple w-100" type="submit">ĐĂNG KÝ</button>
      <p class="text-center mt-3 mb-0">Đã có tài khoản? <a href="<c:url value='/login'/>">Đăng nhập</a></p>
    </form>
  </div>
</main>

<jsp:include page="/includes/footer.jsp" />

<script>
(() => {
  const form = document.querySelector('form.needs-validation');
  form?.addEventListener('submit', e => {
    if (!form.checkValidity()) { e.preventDefault(); e.stopPropagation(); }
    form.classList.add('was-validated');
  });
})();
</script>
