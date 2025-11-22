<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/includes/header.jsp" />

<main class="container" style="max-width:640px;margin:5rem auto">
  <div class="card-luxury p-4 g-gold">
    <h2 class="font-playfair mb-3">Xác minh email</h2>

    <c:if test="${not empty info}">
      <div class="alert alert-info">${info}</div>
    </c:if>
    <c:if test="${not empty error}">
      <div class="alert alert-danger">${error}</div>
    </c:if>

    <p class="text-muted mb-3">
      Nhập mã OTP đã gửi tới: <b>${email}</b>
    </p>

    <form action="<c:url value='/register'/>" method="post" class="needs-validation" novalidate>
      <div class="mb-3">
        <label class="form-label fw-semibold">Mã OTP (6 số)</label>
        <input type="text" name="code" id="otp" inputmode="numeric"
               class="form-control rounded-pill"
               pattern="[0-9]{6}" minlength="6" maxlength="6" required>
        <div class="invalid-feedback">Vui lòng nhập đúng 6 chữ số.</div>
      </div>

      <div class="d-grid gap-2">
        <button class="btn-luxury ripple" type="submit">Xác minh</button>
        <button class="btn btn-outline-secondary rounded-pill" name="resend" value="1">Gửi lại mã</button>
      </div>
    </form>
  </div>
</main>

<jsp:include page="/includes/footer.jsp" />

<script>
(() => {
  const form = document.querySelector('form.needs-validation');
  form?.addEventListener('submit', e => {
    const otp = document.getElementById('otp');
    otp.value = (otp.value || '').trim();
    if (!form.checkValidity()) { e.preventDefault(); e.stopPropagation(); }
    form.classList.add('was-validated');
  });
})();
</script>
