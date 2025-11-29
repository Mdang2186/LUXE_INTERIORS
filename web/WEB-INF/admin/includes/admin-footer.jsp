</main> <footer class="py-4 text-center text-[11px] text-slate-400 border-t border-slate-200 glass flex-shrink-0">
            &copy; 2025 FurniShop System. ???c phát tri?n b?i <span class="text-brand-600 font-bold">Nhom2</span>.
        </footer>

    </div> <div id="mobile-overlay" onclick="toggleSidebar()" class="fixed inset-0 bg-slate-900/50 z-40 hidden backdrop-blur-sm lg:hidden transition-opacity"></div>

</div> <script>
    // Logic Toggle Sidebar Mobile
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('mobile-overlay');

    function toggleSidebar() {
        const isHidden = sidebar.classList.contains('-translate-x-full');
        if (isHidden) {
            // M? menu
            sidebar.classList.remove('-translate-x-full');
            overlay.classList.remove('hidden');
        } else {
            // ?óng menu
            sidebar.classList.add('-translate-x-full');
            overlay.classList.add('hidden');
        }
    }

    // Auto close sidebar on resize (n?u ?ang m? ? mobile mà kéo to màn hình)
    window.addEventListener('resize', () => {
        if (window.innerWidth >= 1024) {
            sidebar.classList.remove('-translate-x-full'); // Hi?n sidebar ? desktop
            overlay.classList.add('hidden');
        } else {
            sidebar.classList.add('-translate-x-full'); // ?n sidebar ? mobile
        }
    });
</script>

<script>
    function exportTableToExcel(tableID, filename = 'export_data') {
        const table = document.getElementById(tableID);
        if(!table) return alert('Không tìm th?y b?ng d? li?u!');
        
        // Clone b?ng ?? lo?i b? c?t thao tác n?u c?n
        const tableClone = table.cloneNode(true);
        const ignoreCols = tableClone.querySelectorAll('.ignore-export');
        ignoreCols.forEach(el => el.remove());

        const wb = XLSX.utils.table_to_book(tableClone, {sheet: "Sheet1"});
        XLSX.writeFile(wb, filename + '.xlsx');
    }
</script>

</body>
</html>