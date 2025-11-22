<%-- includes/footer.jsp (ĐÃ KIỂM TRA - CHÍNH XÁC) --%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="path" value="${pageContext.request.contextPath}" />

<footer class="footer-luxe mt-auto">
  <!-- CTA -->
  <section class="footer-cta container">
    <div class="cta-wrap">
      <div class="cta-left">
        <div class="cta-icon"><i class="fa-solid fa-envelope-open-text"></i></div>
        <div>
          <div class="cta-title">Nhận ưu đãi & bộ sưu tập mới</div>
          <div class="cta-sub">Tin giảm giá, sản phẩm hot, cảm hứng décor mỗi tuần.</div>
        </div>
      </div>
      <%-- Form này POST đến /subscribe (SubscribeController) - CHÍNH XÁC --%>
      <form action="${path}/subscribe" method="post" class="cta-form" onsubmit="return luxeSub(this)">
        <input type="email" name="email" class="cta-input" placeholder="Email của bạn" required />
        <button class="cta-btn btn-luxe" type="submit">Đăng ký</button>
      </form>
    </div>
  </section>

  <!-- MAIN -->
  <div class="footer-main">
    <div class="container">
      <div class="row g-4">
        <!-- Brand -->
        <div class="col-lg-4 col-md-6">
          <a class="navbar-brand" href="${path}/home">
                        <%-- 
                          LƯU Ý: Hãy thay đổi đường dẫn này 
                          cho đúng với vị trí file name.svg của bạn 
                        --%>
                        <img src="${path}/assets/images/logo/name.svg" alt="LUXE INTERIORS" class="navbar-brand-logo-svg">
                    </a>
          <p class="muted">Mang đến sản phẩm nội thất cao cấp – cân bằng thẩm mỹ & công năng cho không gian sống đẳng cấp.</p>
          <div class="socials">
            <a href="#" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
            <a href="#" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
            <a href="#" aria-label="YouTube"><i class="fab fa-youtube"></i></a>
            <a href="#" aria-label="Pinterest"><i class="fab fa-pinterest-p"></i></a>
          </div>
        </div>

        <!-- Links -->
        <div class="col-lg-2 col-md-6">
          <h6 class="heading">Liên kết</h6>
          <ul class="links">
            <li><a href="${path}/home">Trang chủ</a></li>
            <li><a href="${path}/shop">Sản phẩm</a></li>
            <li><a href="${path}/cart">Giỏ hàng</a></li>
            <li><a href="${path}/orders">Đơn hàng</a></li>
            <li><a href="${path}/account">Tài khoản</a></li>
          </ul>
        </div>

        <!-- Team -->
        <div class="col-lg-3 col-md-6">
          <h6 class="heading">Nhóm phát triển</h6>
          <ul class="team">
            <li><span class="dot"></span> Đỗ Công Minh — Frontend · UX/UI</li>
            <li><span class="dot"></span> Đặng Đình Thế Hiếu — Backend · API</li>
            <li><span class="dot"></span> Lý Ngọc Long — Database · QA</li>
            <li><span class="dot"></span> Nguyễn Hữu Lương — Tester · Content</li>
          </ul>
        </div>

        <!-- Support -->
        <div class="col-lg-3 col-md-6">
          <h6 class="heading">Hỗ trợ</h6>
          <ul class="links">
            <li><a href="${path}/policy/shipping">Giao hàng & lắp đặt</a></li>
            <li><a href="${path}/policy/return">Đổi trả & bảo hành</a></li>
            <li><a href="${path}/policy/payment">Thanh toán & trả góp</a></li>
            <%-- Link này trỏ đến /contact (ContactController) - CHÍNH XÁC --%>
            <li><a href="${path}/contact">Liên hệ tư vấn</a></li>
          </ul>
        </div>
      </div>

      <!-- Payments & Banks -->
      <div class="badges">
        <!-- Cổng thanh toán -->
        <img class="logo" src="${path}/assets/images/payments/visa.png" alt="Visa" onerror="luxeFallback(this,'VISA')">
        <img class="logo" src="${path}/assets/images/payments/mastercard.svg" alt="Mastercard" onerror="luxeFallback(this,'MC')">
        <img class="logo" src="${path}/assets/images/payments/momo.svg" alt="MoMo" onerror="luxeFallback(this,'MOMO')">
        <img class="logo" src="${path}/assets/images/payments/vnpay.svg" alt="VNPay" onerror="luxeFallback(this,'VNPAY')">
        <span class="sep"></span>
        <!-- Ngân hàng nội địa -->
        <img class="logo" src="${path}/assets/images/banks/vietcombank.png" alt="Vietcombank" onerror="luxeFallback(this,'VCB')">
        <img class="logo" src="${path}/assets/images/banks/techcombank.png" alt="Techcombank" onerror="luxeFallback(this,'TCB')">
        <img class="logo" src="${path}/assets/images/banks/vietinbank.svg" alt="VietinBank" onerror="luxeFallback(this,'VTB')">
        <img class="logo" src="${path}/assets/images/banks/bidv.svg" alt="BIDV" onerror="luxeFallback(this,'BIDV')">
        <img class="logo" src="${path}/assets/images/banks/acb.svg" alt="ACB" onerror="luxeFallback(this,'ACB')">
        <img class="logo" src="${path}/assets/images/banks/mbbank.svg" alt="MB Bank" onerror="lSuxeFallback(this,'MB')">
      </div>
    </div>
  </div>

  <!-- Bottom -->
  <div class="footer-bottom">
    <div class="container d-flex flex-wrap justify-content-between align-items-center gap-2">
      <p class="m-0 small">© 2025 LUXE INTERIORS. Đồ án thực tập Java Web.</p>
      <div class="small">
        <a href="${path}/policy/privacy" class="muted me-3">Chính sách bảo mật</a>
        <a href="${path}/policy/terms" class="muted">Điều khoản sử dụng</a>
      </div>
    </div>
  </div>
</footer>

<%-- (Phần script và style của footer giữ nguyên) --%>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  // Reveal
  (function () {
    const els = Array.from(document.querySelectorAll('.scroll-reveal'));
    if (!('IntersectionObserver' in window)) { els.forEach(el=>el.classList.add('revealed')); return; }
    const io = new IntersectionObserver((entries)=>{
      entries.forEach(e=>{ if(e.isIntersecting){ e.target.classList.add('revealed'); io.unobserve(e.target);} });
    }, {threshold:.12});
    els.forEach(el=>io.observe(el));
  })();

  // Demo subscribe
  function luxeSub(form){
    const email=form.email.value.trim(); if(!email) return false;
    const btn=form.querySelector('.cta-btn'); btn.disabled=true; btn.innerText='Đã đăng ký ✓';
    // Chuyển sang submit thật (không giả lập nữa)
    // setTimeout(()=>{ btn.disabled=false; btn.innerText='Đăng ký'; form.reset(); }, 2200);
    // return false; 
    return true; // Cho phép form submit thật
  }

  // Fallback icon ngân hàng: đổi <img> hỏng thành badge text (VCB/TCB/...)
  function luxeFallback(img, text){
    const tag = document.createElement('span');
    tag.className = 'bank-badge';
    tag.textContent = text;
    img.replaceWith(tag);
  }
</script>

<style>
  :root{
    --ink:#1d1a16; --bg:#0e0d0c; --muted:#9c9aa0;
    --gold1:#f7e7a1; --gold2:#f1c40f; --gold3:#d4af37; --gold4:#b68d16;
    --ring: rgba(212,175,55,.22);
  }
  .footer-luxe{ color:#e9e7e4; background: radial-gradient(1200px 800px at 15% -10%,rgba(212,175,55,.10),transparent 55%), #0b0a09; }
  .footer-luxe .muted{ color:var(--muted); }
  .footer-luxe a{ color:#e9e7e4; text-decoration:none }
  .footer-luxe a:hover{ color:var(--gold1) }

  /* CTA */
  .footer-cta{ padding: 36px 0 10px }
  .cta-wrap{ display:flex; gap:20px; align-items:center; justify-content:space-between;
    padding:18px 22px; border-radius:18px;
    background:linear-gradient(145deg,rgba(255,255,255,.06),rgba(255,255,255,.03));
    border:1px solid rgba(212,175,55,.18); box-shadow:0 10px 24px rgba(0,0,0,.20);
    backdrop-filter:saturate(140%) blur(6px);}
  .cta-left{ display:flex; gap:14px; align-items:center }
  .cta-icon{ width:44px;height:44px;border-radius:12px;display:grid;place-items:center;
    background:linear-gradient(135deg,var(--gold2),var(--gold3)); color:#1b1304; box-shadow:0 6px 18px rgba(212,175,55,.30) }
  .cta-title{ font-weight:700; letter-spacing:.2px }
  .cta-sub{ font-size:.925rem; color:var(--muted) }
  .cta-form{ display:flex; gap:10px; align-items:center }
  .cta-input{ background:#111; color:#eee; border:1px solid rgba(255,255,255,.08);
    padding:12px 14px; border-radius:999px; min-width:260px; outline:none }
  .cta-input:focus{ border-color:var(--gold3); box-shadow:0 0 0 3px var(--ring) }
  .btn-luxe{ border:none; border-radius:999px; padding:12px 18px; font-weight:700; cursor:pointer;
    background:linear-gradient(135deg,#f4d03f 0%,#f1c40f 25%,#d4af37 50%,#b7950b 75%,#9c7a0c 100%);
    color:#1b1304; box-shadow:0 12px 24px rgba(212,175,55,.28) }
  .btn-luxe:hover{ transform:translateY(-1px) }
  .btn-luxe:disabled { background: #555; color: #999; cursor: not-allowed; box-shadow: none; }


  .footer-main{ padding: 28px 0 10px }
  .brand{ font-family:'Playfair Display',serif; font-weight:700;
    background:linear-gradient(135deg,#f4d03f,#d4af37); -webkit-background-clip:text; -webkit-text-fill-color:transparent }
  .heading{ text-transform:uppercase; letter-spacing:.12em; color:#f1e9c8; margin-bottom:10px }
  .links{ list-style:none; padding:0; margin:0 }
  .links li{ margin:8px 0 }
  .team{ list-style:none; padding:0; margin:0; color:#dcd8cf }
  .team li{ margin:8px 0; display:flex; gap:8px; align-items:center }
  .team .dot{ width:6px; height:6px; background:linear-gradient(135deg,var(--gold2),var(--gold3)); border-radius:50% }

  .socials{ display:flex; gap:10px; margin-top:12px }
  .socials a{ width:38px; height:38px; border-radius:12px; display:grid; place-items:center;
    background:rgba(255,255,255,.06); border:1px solid rgba(255,255,255,.12) }
  .socials a:hover{ background:linear-gradient(135deg,var(--gold2),var(--gold3)); color:#1b1304; border-color:transparent; box-shadow:0 10px 18px rgba(212,175,55,.25) }

  .badges{ display:flex; flex-wrap:wrap; gap:14px; align-items:center; margin-top:18px; opacity:.95 }
  .badges .logo{ height:24px; filter:grayscale(15%) }
  .badges .sep{ width:1px; height:22px; background:rgba(255,255,255,.12); margin:0 6px; }

  .bank-badge{ display:inline-flex; align-items:center; justify-content:center;
    height:26px; padding:0 10px; border-radius:8px; border:1px solid rgba(255,255,255,.14);
    background:rgba(255,255,255,.06); font-weight:800; letter-spacing:.5px; font-size:.78rem;
    color:#e8e6de }

  .footer-bottom{ border-top:1px solid rgba(255,255,255,.06);
    background:linear-gradient(180deg,rgba(255,255,255,.02),rgba(255,255,255,0)); padding:14px 0 24px }

  @media (max-width:768px){
    .cta-wrap{ flex-direction:column; align-items:stretch }
    .cta-form{ width:100% } .cta-input{ width:100%; min-width:0 } .btn-luxe{ width:100% }
  }
</style>

</body>
</html>