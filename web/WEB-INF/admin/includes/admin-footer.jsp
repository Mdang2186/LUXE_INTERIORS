</div> 

<div style="padding:1rem; text-align:center; color:var(--muted); border-top:1px solid var(--line); background: var(--panel);">
    © 2025 FurniShop - Admin Panel
</div>

<script src="${pageContext.request.contextPath}/assets/js/bootstrap.bundle.min.js"></script>

<script>
    document.addEventListener('click', function (e) {
        if (e.target.id === 'btn-toggle-sidebar' || e.target.closest('#btn-toggle-sidebar')) {
            e.preventDefault();
            var sb = document.querySelector('.admin-sidebar');
            if (sb)
                sb.classList.toggle('open');
        }
    });
</script>
</body>
</html>