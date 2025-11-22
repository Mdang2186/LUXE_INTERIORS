<%-- Thay thế toàn bộ file: home.jsp --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<fmt:setLocale value="vi_VN"/>

<%-- Đặt tiêu đề động cho trang --%>
<c:set var="pageTitle" value="Trang chủ - LUXE INTERIORS" scope="request" />
<style>
/* container for the compact hero video */
.home-compact-video .video-wrap{
  position: relative;
  overflow: hidden;
  border-radius: 12px;
  background: #000;
}

/* video sizing: cover and centered */
.home-compact-video__elm{
  display: block;
  width: 100%;
  height: 360px;            /* desktop height */
  object-fit: cover;
  object-position: center;
  transform: translateZ(0); /* promote to GPU for smoother rendering */
  -webkit-backface-visibility: hidden;
  backface-visibility: hidden;
}

/* overlay caption area (subtle, not intrusive) */
.video-caption{
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 3;
  background: linear-gradient(180deg, rgba(255,255,255,0) 0%, rgba(255,255,255,0.92) 85%);
  padding: 16px;
  gap: 12px;
  pointer-events: none; /* no interaction */
}

/* typography */
.video-caption h4 { font-size: 1.05rem; color: #222; }
.video-caption small { color: #666; }

/* small badge on right */
.video-badge { opacity: 0.85; font-size: 0.85rem; }

/* responsive adjustments */
@media (max-width: 992px){
  .home-compact-video__elm{ height: 300px; }
}
@media (max-width: 576px){
  .home-compact-video__elm{ height: 200px; }
  .video-caption{ padding: 10px; }
  .video-caption h4{ font-size: 0.95rem; }
}

/* accessibility: respects reduced motion */
@media (prefers-reduced-motion: reduce){
  .home-compact-video__elm { animation: none; }
}
</style>


<%-- Gọi file Header (đã chứa CSS Luxe, Fonts, Menu...) --%>
<jsp:include page="includes/header.jsp" />

<style>
/* outer wrapper */
.home-large-video .large-video-wrap{
  position: relative;
  overflow: hidden;
  border-radius: 12px;
  background: #000;
}

/* viewport enforces an aspect ratio for the visible area */
/* default: 16/9 large frame — change to 21/9 for wider cinematic feel if you want */
.large-video-viewport{
  width: 100%;
  aspect-ratio: 16 / 9; /* keeps a large frame with preserved ratio */
  max-height: 720px;    /* cap height to prevent enormous frames on huge screens */
  background: #000;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* the video itself is set to contain so it never stretches; it will letterbox if needed */
.large-video-elm{
  width: 100%;
  height: 100%;
  object-fit: contain;   /* preserve full video with letterbox/pillarbox as needed */
  object-position: center;
  display: block;
  transform: translateZ(0);
}

/* caption sits over the bottom area but subtle */
.large-video-caption{
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 3;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 14px 18px;
  background: linear-gradient(180deg, rgba(255,255,255,0) 0%, rgba(255,255,255,0.95) 90%);
  pointer-events: none;
}

/* typography tweaks */
.large-video-caption h3 { font-size: 1.15rem; color: #222; }
.large-video-caption small { color: #666; }
.video-brand { color: #999; font-weight: 600; font-size: 0.95rem; }

/* responsive - make the frame even larger on wide screens */
@media (min-width: 1920px) {
  .large-video-viewport { aspect-ratio: 21 / 9; max-height: 720px; } /* optional wider cinematic on big screens */
}

/* mobile sizing */
@media (max-width: 1080px){
  .large-video-viewport { aspect-ratio: 4 / 3; max-height: 420px; }
  .large-video-caption { padding: 10px 12px; }
  .large-video-caption h3 { font-size: 1rem; }
}
</style>
<%-- BẮT ĐẦU NỘI DUNG CHÍNH CỦA TRANG (THEME LUXE SÁNG) --%>
<main>

    <%-- 
      =================================================
      PHẦN HERO ĐÃ ĐƯỢC CẬP NHẬT
      - Đã thay thế <img> bằng <video>
      - Thêm: autoplay, loop, muted, playsinline (bắt buộc để video tự chạy)
      - Không có thuộc tính 'controls' (theo yêu cầu "không được thao tác")
      =================================================
    --%>
    <section class="position-relative d-flex align-items-center" style="min-height:92vh; overflow: hidden;">
        
        <video 
             class="position-absolute w-100 h-100" 
             style="object-fit: cover;" 
             autoplay loop muted playsinline
             <%-- poster là ảnh hiển thị trong lúc video tải, dùng lại ảnh cũ --%>
             poster="https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=2000&q=80">
            
            <%-- 
              QUAN TRỌNG: 
              Bạn cần thêm video của mình vào đường dẫn này 
              (ví dụ: /assets/videos/hero_background.mp4) 
            --%>
            <source src="${path}/assets/videos/hero_background.mp4" type="video/mp4">
            
            <%-- Fallback nếu trình duyệt không hỗ trợ --%>
            <img src="https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&w=2000&q=80"
                 alt="Luxury Interior" class="position-absolute w-100 h-100" 
                 style="object-fit:cover;">
        </video>

        <%-- Lớp phủ mờ (giữ nguyên) --%>
        <div class="hero-overlay position-absolute w-100 h-100"></div>

        <%-- Nội dung text (giữ nguyên) --%>
        <%-- Nội dung text (ĐÃ SỬA ĐỂ HIỂN THỊ LOGO) --%>
<div class="container position-relative text-center text-white scroll-reveal">
    
    <%-- 
      =================================================
      ĐÃ THÊM LOGO TẠI ĐÂY
      - Giả định logo được lưu tại: /assets/images/logo.jpg
      - Thêm style để logo "to và rõ ràng"
      =================================================
    --%>
    <img src="<c:url value='/assets/images/logo/logo.svg'/>" 
         alt="LUXE INTERIORS Logo"
         class="mb-4"
         style="max-width: 100%; width: 200px; height: auto; 
                filter: drop-shadow(0 4px 10px rgba(0,0,0,0.5));">
    
    <%-- Giữ lại phần tiêu đề phụ "Collection 2025" và loại bỏ chữ "LUXE" --%>
    <h1 class="hero-title font-playfair mb-4">
        <span class="d-block text-luxury-gold fw-medium">COLLECTION</span>
        <span class="d-block fs-3 font-cormorant text-warning mt-3">2025</span>
    </h1>

    <%-- Giữ lại mô tả và các nút --%>
    <p class="fs-5 font-cormorant mx-auto mb-4" style="max-width:740px">
        Khám phá bộ sưu tập nội thất cao cấp được tuyển chọn, mang đến không gian sống đẳng cấp với chất 
        lượng hoàn hảo. 
    </p>
    <div class="d-flex flex-column flex-sm-row gap-3 justify-content-center">
        <a href="<c:url value='/shop'/>" class="btn-luxury ripple">Khám phá bộ sưu tập</a>
        <a href="<c:url value='/shop'/>" class="btn btn-outline-light rounded-pill px-4 py-3">Xem catalog 2025</a>
    </div>
</div>
    </section>
    
    <%-- (Các phần còn lại của home.jsp giữ nguyên) --%>
    <section class="py-5" style="background: #fdfcf9;">
         <div class="container">
            <div class="row g-4">
                <div class="col-6 col-md-3 scroll-reveal"><div class="stats-card"><div class="h2 text-luxury-gold mb-2 font-playfair">15+</div><div class="text-muted text-uppercase small fw-semibold">Năm kinh nghiệm</div></div></div>
                <div class="col-6 col-md-3 scroll-reveal" style="transition-delay: 0.1s;"><div class="stats-card"><div class="h2 text-luxury-gold mb-2 font-playfair">2,500+</div><div class="text-muted text-uppercase small fw-semibold">Dự án hoàn thành</div></div></div>
                <div class="col-6 col-md-3 scroll-reveal" style="transition-delay: 0.2s;"><div class="stats-card"><div class="h2 text-luxury-gold mb-2 font-playfair">150+</div><div class="text-muted text-uppercase small fw-semibold">Thương hiệu đối tác</div></div></div>
                <div class="col-6 col-md-3 scroll-reveal" style="transition-delay: 0.3s;"><div class="stats-card"><div class="h2 text-luxury-gold mb-2 font-playfair">99%</div><div class="text-muted text-uppercase small fw-semibold">Khách hàng hài lòng</div></div></div>
            </div>
        </div>
    </section>
<!-- ====== CENTERED LARGE HERO VIDEO (replace old video block) ====== -->
<section class="hero-center-video my-5">
  <div class="hero-center-video__outer">
    <div class="hero-center-video__frame">
      <video id="heroCenterVideo"
             class="hero-center-video__video"
             playsinline
             muted
             loop
             preload="metadata"
             poster="${pageContext.request.contextPath}/assets/images/hero_poster.jpg"
             aria-hidden="true"> 
        <source src="${pageContext.request.contextPath}/assets/videos/home.mp4" type="video/mp4">
        Trình duyệt không hỗ trợ video.
      </video>
 
    </div>
  </div>
</section>

<!-- ====== STYLES: center + big frame (move to style.css if you want) ====== -->
<style>
/* outer center wrapper */
.hero-center-video__outer {
  width: 100%;
  display: flex;
  justify-content: center; /* center horizontally */
  padding: 0 16px;
  box-sizing: border-box;
}

/* frame: controls visible max-width; increase to make video bigger */
.hero-center-video__frame {
  width: 100%;
  max-width: 1400px;          /* <-- Tăng giá trị này nếu muốn to hơn (1600/1800...) */
  aspect-ratio: 16 / 9;       /* khung 16:9 (1920x1080 tương đương) */
  position: relative;
  overflow: hidden;
  border-radius: 10px;
  box-shadow: 0 6px 18px rgba(20,20,20,0.08);
  background: #000;
}

/* video fills and crops to cover the frame: no black bars */
.hero-center-video__video {
  position: absolute;
  top: 50%;
  left: 50%;
  min-width: 100%;
  min-height: 100%;
  width: auto;
  height: auto;
  transform: translate(-50%, -50%);
  object-fit: cover;           /* IMPORTANT: cover to fill, no black bars */
  object-position: center;     /* adjust (e.g. 40% center) to focus subject */
  display: block;
  -webkit-backface-visibility: hidden;
  backface-visibility: hidden;
}

/* caption overlay (subtle) */
.hero-center-video__caption {
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 3;
  padding: 14px 20px;
  background: linear-gradient(180deg, rgba(255,255,255,0) 0%, rgba(255,255,255,0.92) 92%);
  display: flex;
  justify-content: space-between;
  align-items: center;
  pointer-events: none;
}

/* text sizing */
.hero-center-video__text h2 { font-size: 1.35rem; margin:0; color:#1f1f1f; }
.hero-center-video__text p { margin:0; font-size:0.95rem; color:#666; }

/* responsive */
@media (max-width: 1200px) {
  .hero-center-video__frame { max-width: 1100px; }
  .hero-center-video__text h2 { font-size: 1.15rem; }
}
@media (max-width: 768px) {
  .hero-center-video__frame { max-width: 720px; aspect-ratio: 16/9; }
  .hero-center-video__text h2 { font-size: 1rem; }
  .hero-center-video__caption { padding: 10px 12px; }
}

/* if you want it even larger on ultra wide screens */
@media (min-width: 1600px) {
  .hero-center-video__frame { max-width: 1600px; }
}
</style>

<!-- ====== JS: lazy play/pause — keep performance solid ====== -->
<script>
document.addEventListener('DOMContentLoaded', function() {
  const v = document.getElementById('heroCenterVideo');
  if (!v) return;
  v.muted = true; // ensure autoplay allowed

  const playSafe = () => {
    const p = v.play();
    if (p && p.catch) p.catch(()=>{/* ignore autoplay prevented */});
  };
  const pauseSafe = () => { try { v.pause(); } catch(e){} };

  if ('IntersectionObserver' in window) {
    const io = new IntersectionObserver(entries => {
      entries.forEach(en => {
        if (en.isIntersecting && en.intersectionRatio > 0.2) playSafe();
        else pauseSafe();
      });
    }, { threshold: [0,0.2,0.5,1] });
    io.observe(v);
  } else {
    playSafe();
  }

  // free memory on pagehide
  window.addEventListener('pagehide', () => {
    try { v.pause(); v.src = ''; } catch(e) {}
  });
});
</script>


    <%-- KHỐI SẢN PHẨM "BÁN CHẠY" --%>
    <c:if test="${not empty bestSellersEx}">
        <section class="py-5" style="background: #fdfcf9;">
           <div class="container">
                <div class="text-center mb-4 scroll-reveal">
                    <p class="text-muted small text-uppercase mb-2">Sản phẩm bán chạy</p>
                    <h2 class="h1 font-playfair">Bộ sưu tập <span class="text-luxury-gold">Bán chạy nhất</span></h2>
                </div>

                 <div class="row row-cols-2 row-cols-lg-4 g-3">
                    <c:forEach var="it" items="${bestSellersEx}" varStatus="loop">
                        <c:set var="p" value="${it.product}"/>
                        <div class="col scroll-reveal" style="transition-delay: ${loop.index * 0.1}s;">
                             <div class="h-100 d-flex flex-column bg-transparent">
                                <div class="product-image-wrap shine mb-2">
                                    <span class="ribbon">Bán chạy</span>
                                    <a href="<c:url value='/product-detail?pid=${p.productID}'/>" class="d-block ratio ratio-1x1">
                                        <img src="${p.imageURL}" alt="${p.productName}"
                                             onerror="this.src='<c:url value="/assets/images/placeholder.png"/>'"
                                             class="product-image"/>
                                    </a>
                                    <div class="quick-actions">
                                        <a href="<c:url value='/product-detail?pid=${p.productID}'/>" class="qa-btn" title="Xem nhanh"><i class="fas fa-eye"></i></a>
                                        <a href="<c:url value='/cart?action=add&pid=${p.productID}'/>" class="qa-btn" title="Thêm vào giỏ"><i class="fas fa-cart-plus"></i></a>
                                    </div>
                                 </div>
                                <div class="d-flex align-items-center gap-2 mb-1">
                                    <span class="badge bg-warning text-dark">Đã bán ${it.sold}</span>
                                 </div>
                                 
                                <h6 class="fw-semibold text-truncate mb-1" title="${p.productName}">${p.productName}</h6>
                                <p class="small text-muted mb-2"><i class="fas fa-gem me-1 opacity-50"></i> ${p.material}</p>
                                
                                <div class="mt-auto">
                                    <h5 class="fw-bold" style="color: var(--gold4, #b68d16);">
                                        <fmt:formatNumber value="${p.price}" type="currency" currencyCode="VND"/>
                                    </h5>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
           </div>
        </section>
    </c:if>

    <%-- KHỐI SẢN PHẨM "ĐẶC BIỆT" --%>
    <c:if test="${not empty specialProduct}">
        <section class="py-5 bg-white">
            <div class="container">
                <div class="text-center mb-4 scroll-reveal">
                    <p class="text-muted small text-uppercase mb-2">Sản phẩm đặc biệt</p>
                     <h2 class="h1 font-playfair">Tác phẩm <span class="text-luxury-gold">nghệ thuật</span></h2>
                </div>
                <div class="row g-4 align-items-center">
                    <div class="col-lg-6 scroll-reveal">
                        <div class="position-relative">
                             <img src="${specialProduct.imageURL}"
                                 onerror="this.src='<c:url value="/assets/images/placeholder.png"/>'"
                                 alt="${fn:escapeXml(specialProduct.productName)}"
                                 class="w-100 rounded-4 shadow" style="height:500px;object-fit:cover">
                            <span class="special-badge position-absolute top-0 start-0 m-3">Limited Edition</span>
                        </div>
                     </div>
                    <div class="col-lg-6 scroll-reveal" style="transition-delay: 0.2s;">
                        <p class="text-uppercase small text-muted mb-2">Độc quyền • Phiên bản giới hạn</p>
                        <h3 class="h2 mb-3">${specialProduct.productName}</h3>
                         <p class="text-secondary mb-4">${specialProduct.description}</p>
                        
                        <div class="d-flex align-items-center justify-content-between border-top pt-3">
                             <h4 class="fw-bold" style="color: var(--gold4, #b68d16);">
                                <fmt:formatNumber value="${specialProduct.price}" type="currency" currencyCode="VND"/>
                             </h4>
                        </div>
                        <div class="d-flex gap-3 mt-3">
                            <a class="btn-luxury ripple flex-grow-1" href="<c:url value='/product-detail?pid=${specialProduct.productID}'/>">Xem chi tiết</a>
                             <form action="<c:url value='/cart'/>" method="post" class="flex-grow-1">
                                <input type="hidden" name="action" value="add"/>
                                <input type="hidden" name="pid" value="${specialProduct.productID}"/>
                                 <input type="hidden" name="quantity" value="1"/>
                                <button type="submit" class="btn btn-outline-secondary rounded-pill w-100 py-3">Thêm vào giỏ</button>
                            </form>
                         </div>
                    </div>
                </div>
            </div>
        </section>
    </c:if>

    <%-- KHỐI SẢN PHẨM "MỚI VỀ" --%>
    <section class="py-5" style="background: #fdfcf9;">
        <div class="container">
             <div class="text-center mb-4 scroll-reveal">
                <p class="text-muted small text-uppercase mb-2">Sản phẩm nổi bật</p>
                <h2 class="h1 font-playfair">Bộ sưu tập <span class="text-luxury-gold">mới về</span></h2>
            </div>
            <c:choose>
                <c:when test="${not empty products}">
                     <div class="row g-4" id="productsGrid">
                        <c:forEach items="${products}" var="p" varStatus="st" begin="0" end="5">
                            <div class="col-12 col-md-6 col-lg-4 scroll-reveal" style="transition-delay: ${st.index * 0.1}s;">
                                 <div class="h-100 d-flex flex-column bg-transparent">
                                    <div class="product-image-wrap shine mb-3">
                                         <a href="<c:url value='/product-detail?pid=${p.productID}'/>" class="d-block rounded-4 overflow-hidden">
                                            <img src="${p.imageURL}" alt="${fn:escapeXml(p.productName)}"
                                                 onerror="this.src='<c:url value="/assets/images/placeholder.png"/>'"
                                                 class="product-image">
                                        </a>
                                         <div class="quick-actions">
                                          <a href="<c:url value='/product-detail?pid=${p.productID}'/>" class="qa-btn" title="Xem nhanh">
                                            <i class="fas fa-eye"></i>
                                          </a>
                                          <a href="<c:url value='/cart?action=add&pid=${p.productID}'/>" class="qa-btn" title="Thêm vào giỏ">
                                            <i class="fas fa-cart-plus"></i>
                                          </a>
                                        </div>
                                    </div>
                                    <h5 class="fw-semibold text-truncate mb-1" title="${p.productName}">${p.productName}</h5>
                                    <p class="small text-muted mb-2"><i class="fas fa-gem me-1 opacity-50"></i> ${p.material}</p>
                                    <p class="text-secondary small mb-3" style="min-height: 48px; max-height:48px; overflow:hidden">${p.description}</p>
                                    
                                    <div class="mt-auto">
                                        <h5 class="fw-bold" style="color: var(--gold4, #b68d16);">
                                            <fmt:formatNumber value="${p.price}" type="currency" currencyCode="VND"/>
                                        </h5>
                                    </div>
                                </div>
                             </div>
                        </c:forEach>
                    </div>
                    <div class="text-center mt-4 scroll-reveal">
                         <a href="<c:url value='/shop'/>" class="btn btn-outline-secondary rounded-pill px-4 py-3">Xem tất cả sản phẩm</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5 scroll-reveal">
                        <i class="fas fa-box-open fa-3x text-muted mb-3"></i>
                        <p class="mb-0 text-muted">Chưa có sản phẩm để hiển thị.</p>
                    </div>
                </c:otherwise>
             </c:choose>
        </div>
    </section>

  <section class="py-5 trust-badge-section">
      <div class="container">
          <div class="row g-4">
              <div class="col-md-3 col-6">
                  <div class="trust-badge">
                      <div class="badge-icon">
                          <i class="fas fa-shield-alt"></i>
                      </div>
                      <h6>Thương hiệu đảm bảo</h6>
                      <p>Nhập khẩu, bảo hành chính hãng</p>
                  </div>
              </div>
              <div class="col-md-3 col-6">
                  <div class="trust-badge">
                      <div class="badge-icon">
                          <i class="fas fa-exchange-alt"></i>
                      </div>
                      <h6>Đổi trả dễ dàng</h6>
                      <p>Theo chính sách đổi trả ưu việt</p>
                  </div>
              </div>
              <div class="col-md-3 col-6">
                  <div class="trust-badge">
                      <div class="badge-icon">
                          <i class="fas fa-truck"></i>
                      </div>
                      <h6>Giao hàng tận nơi</h6>
                      <p>Lắp đặt chuyên nghiệp toàn quốc</p>
                  </div>
              </div>
              <div class="col-md-3 col-6">
                  <div class="trust-badge">
                      <div class="badge-icon">
                           <i class="fas fa-gem"></i>
                      </div>
                      <h6>Sản phẩm chất lượng</h6>
                      <p>Đảm bảo tương thích và độ bền cao</p>
                  </div>
              </div>
          </div>
      </div>
  </section>

</main>
<%-- KẾT THÚC NỘI DUNG CHÍNH --%>

 
<%-- Gọi file Footer (sẽ chứa JS và nội dung footer) --%>
<jsp:include page="includes/footer.jsp"/>