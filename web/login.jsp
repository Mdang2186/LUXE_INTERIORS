<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="/includes/header.jsp" />

<%-- Gộp nguồn returnTo: ưu tiên ?returnTo=..., nếu không có thì lấy từ session --%>
<c:set var="returnTo"
       value="${empty param.returnTo ? sessionScope.returnTo : param.returnTo}" />

<main class="container" style="max-width:520px; margin:5rem auto;">
  <div class="card-luxury p-4">
    <h2 class="text-center font-playfair mb-3">Đăng nhập</h2>

    <c:if test="${not empty returnTo}">
      <div class="alert alert-info py-2">
        Bạn cần đăng nhập để tiếp tục <strong>thanh toán</strong>.
      </div>
    </c:if>

    <c:if test="${not empty requestScope.success}">
      <div class="alert alert-success" role="alert">${requestScope.success}</div>
    </c:if>

    <c:if test="${not empty requestScope.error}">
      <div class="alert alert-danger" role="alert">${requestScope.error}</div>
    </c:if>

    <form action="<c:url value='/login'/>" method="post" class="needs-validation" novalidate>
      <c:if test="${not empty returnTo}">
        <input type="hidden" name="returnTo" value="${fn:escapeXml(returnTo)}"/>
      </c:if>

      <div class="mb-3">
        <label for="email" class="form-label">Email</label>
        <input type="email" class="form-control rounded-pill" id="email" name="email" required
               value="${fn:escapeXml(param.email)}">
        <div class="invalid-feedback">Vui lòng nhập email hợp lệ.</div>
      </div>

      <div class="mb-2">
        <label for="password" class="form-label">Mật khẩu</label>
        <input type="password" class="form-control rounded-pill" id="password" name="password" required>
        <div class="invalid-feedback">Vui lòng nhập mật khẩu.</div>
      </div>

      <div class="text-end mb-3">
        <a href="<c:url value='/password-reset'/>">Quên mật khẩu?</a>
      </div>

      <button type="submit" class="btn-luxury ripple w-100">Đăng nhập</button>
    </form>

    <div class="text-center mt-4">
      <p>Chưa có tài khoản?
        <a href="<c:url value='/register'/>">Đăng ký ngay</a>
      </p>
    </div>
  </div>
</main>

<jsp:include page="/includes/footer.jsp" />

<script>
  // Boostrap-like client validation (nhẹ nhàng)
  (function () {
    const form = document.querySelector('form.needs-validation');
    form?.addEventListener('submit', function (e) {
      if (!form.checkValidity()) { e.preventDefault(); e.stopPropagation(); }
      form.classList.add('was-validated');
    });
  })();
</script>
