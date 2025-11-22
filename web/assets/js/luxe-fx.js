// File: assets/js/luxe-fx.js

// Reveal on view
(function () {
    const els = [...document.querySelectorAll('.scroll-reveal')];
    if ('IntersectionObserver' in window) {
        const io = new IntersectionObserver((entries) => {
            entries.forEach(e => {
                if (e.isIntersecting) {
                    e.target.classList.add('revealed');
                    io.unobserve(e.target);
                }
            });
        }, { threshold: .15 });
        els.forEach(el => io.observe(el));
    } else {
        els.forEach(el => el.classList.add('revealed'));
    }
})();

// Ripple vàng
document.querySelectorAll('.ripple').forEach(btn => {
    btn.addEventListener('pointerdown', e => {
        const r = btn.getBoundingClientRect();
        btn.style.setProperty('--x', (e.clientX - r.left) + 'px');
        btn.style.setProperty('--y', (e.clientY - r.top) + 'px');
    });
});

// Parallax tilt cho card
document.querySelectorAll('.card-luxury.g-hover').forEach(card => {
    let rect;
    const onMove = e => {
        rect ||= card.getBoundingClientRect();
        const x = (e.clientX - rect.left) / rect.width - .5;
        const y = (e.clientY - rect.top) / rect.height - .5;
        card.style.transform = `perspective(900px) rotateY(${x * 8}deg) rotateX(${-y * 8}deg) translateY(-4px)`;
    };
    const reset = () => {
        card.style.transform = 'perspective(900px) rotateX(0) rotateY(0)';
        rect = null;
    };
    card.addEventListener('pointermove', onMove);
    card.addEventListener('pointerleave', reset);
});