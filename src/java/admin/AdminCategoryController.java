package admin;

import dal.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Category;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * Quản lý danh mục sản phẩm cho Admin:
 *
 * GET  /admin/categories?action=list (hoặc null)      : danh sách + tìm kiếm + phân trang
 * GET  /admin/categories?action=create                : form tạo mới
 * GET  /admin/categories?action=edit&id=?             : form chỉnh sửa
 * GET  /admin/categories?action=export-categories-csv : xuất CSV
 * GET  /admin/categories?action=export-categories-xls : xuất Excel (bảng HTML)
 * GET  /admin/categories?action=export-categories-pdf : xuất PDF (nếu có PdfExportUtil)
 *
 * POST /admin/categories?action=save                  : lưu (tạo / cập nhật)
 * POST /admin/categories?action=delete&id=?           : xóa danh mục
 */
@WebServlet(name = "AdminCategoryController", urlPatterns = {"/admin/categories"})
public class AdminCategoryController extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 12;
    private static final int MAX_EXPORT_ROWS   = 10_000;

    private CategoryDAO cdao;

    @Override
    public void init() throws ServletException {
        super.init();
        cdao = new CategoryDAO();
    }

    // ========================= GET =========================

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setAttribute("adminActive", "categories");

        String action = opt(req.getParameter("action"));
        if (action == null) action = "list";

        switch (action) {
            // List + search + paging
            case "list":
            default:
                handleList(req, resp);
                break;

            // Form create / edit
            case "create":
            case "edit":
                handleForm(req, resp, action);
                break;

            // Export CSV / Excel / PDF
            case "export-categories-csv":
                exportCategoriesCsv(req, resp);
                break;
            case "export-categories-xls":
                exportCategoriesExcel(req, resp);
                break;
            case "export-categories-pdf":
                exportCategoriesPdf(req, resp);
                break;
        }
    }

    /**
     * Danh sách danh mục + tìm kiếm + phân trang
     * GET /admin/categories?action=list&q=...&page=1&size=12
     */
    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String keyword = opt(req.getParameter("q"));
        int page = parseInt(req.getParameter("page"), 1);
        int size = parseInt(req.getParameter("size"), DEFAULT_PAGE_SIZE);
        if (page < 1) page = 1;
        if (size <= 0 || size > 200) size = DEFAULT_PAGE_SIZE;

        int total = cdao.countCategories(keyword); // cần thêm hàm này trong CategoryDAO
        int totalPages = (int) Math.ceil(total / (double) size);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * size;

        List<Category> categories = cdao.searchCategories(keyword, offset, size);
        // nếu bạn chưa có searchCategories, có thể cho getAll() khi keyword=null và bỏ paging.

        req.setAttribute("categories", categories);
        req.setAttribute("q", keyword);
        req.setAttribute("page", page);
        req.setAttribute("pageSize", size);
        req.setAttribute("total", total);
        req.setAttribute("totalPages", totalPages);

        req.getRequestDispatcher("/WEB-INF/admin/categories-list.jsp").forward(req, resp);
    }

    /** Form tạo mới / chỉnh sửa  */
    private void handleForm(HttpServletRequest req, HttpServletResponse resp, String action)
            throws ServletException, IOException {

        Category c = null;

        if ("edit".equals(action)) {
            String idRaw = req.getParameter("id");
            try {
                int id = Integer.parseInt(idRaw);
                c = cdao.getById(id);
                if (c == null) {
                    HttpSession session = req.getSession();
                    session.setAttribute("error", "Danh mục không tồn tại.");
                    resp.sendRedirect(req.getContextPath() + "/admin/categories");
                    return;
                }
            } catch (Exception e) {
                HttpSession session = req.getSession();
                session.setAttribute("error", "Mã danh mục không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/admin/categories");
                return;
            }
        }

        req.setAttribute("category", c);
        req.getRequestDispatcher("/WEB-INF/admin/category-form.jsp").forward(req, resp);
    }

    // ========================= EXPORT CSV =========================

    private void exportCategoriesCsv(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();

        String keyword = opt(req.getParameter("q"));
        List<Category> list = cdao.searchCategories(keyword, 0, MAX_EXPORT_ROWS);

        if (list == null || list.isEmpty()) {
            session.setAttribute("error", "Không có danh mục nào để xuất CSV.");
            resp.sendRedirect(req.getContextPath() + "/admin/categories");
            return;
        }

        String filename = "categories-" +
                new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date()) +
                ".csv";

        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try (PrintWriter out = resp.getWriter()) {
            // BOM để Excel hiểu UTF-8
            out.write('\uFEFF');

            // header
            out.println("\"ID\";\"Tên danh mục\";\"Mô tả\"");

            for (Category c : list) {
                out.print("\"" + c.getCategoryID() + "\";");
                out.print("\"" + nz(c.getCategoryName()) + "\";");
                out.print("\"" + nz(c.getDescription()) + "\"");
                out.println();
            }
        }
    }

    // ========================= EXPORT EXCEL (HTML) =========================

    /**
     * Xuất file .xls nhưng nội dung là bảng HTML – Excel mở được, hỗ trợ UTF-8.
     */
    private void exportCategoriesExcel(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();

        String keyword = opt(req.getParameter("q"));
        List<Category> list = cdao.searchCategories(keyword, 0, MAX_EXPORT_ROWS);

        if (list == null || list.isEmpty()) {
            session.setAttribute("error", "Không có danh mục nào để xuất Excel.");
            resp.sendRedirect(req.getContextPath() + "/admin/categories");
            return;
        }

        String filename = "categories-" +
                new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date()) +
                ".xls";

        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/vnd.ms-excel; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try (PrintWriter out = resp.getWriter()) {
            out.println("<html><head><meta charset='UTF-8' />");
            out.println("<style>");
            out.println("table{border-collapse:collapse;font-family:Arial;}");
            out.println("th,td{border:1px solid #cccccc;padding:4px 8px;font-size:12px;}");
            out.println("th{background:#f1f5f9;font-weight:bold;}");
            out.println("</style></head><body>");
            out.println("<h3>Báo cáo danh mục sản phẩm FurniShop</h3>");
            out.println("<table>");
            out.println("<tr><th>ID</th><th>Tên danh mục</th><th>Mô tả</th></tr>");

            for (Category c : list) {
                out.println("<tr>");
                out.println("<td>" + c.getCategoryID() + "</td>");
                out.println("<td>" + escapeHtml(nz(c.getCategoryName())) + "</td>");
                out.println("<td>" + escapeHtml(nz(c.getDescription())) + "</td>");
                out.println("</tr>");
            }

            out.println("</table>");
            out.println("</body></html>");
        }
    }

    // ========================= EXPORT PDF (OPTION) =========================

    /**
     * Nếu bạn có PdfExportUtil, có thể implement:
     * PdfExportUtil.exportCategoriesPdf(List<Category>, OutputStream)
     * Ở đây mình để trống, bạn có thể bổ sung sau hoặc bỏ action này nếu chưa cần.
     */
    private void exportCategoriesPdf(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();

        String keyword = opt(req.getParameter("q"));
        List<Category> list = cdao.searchCategories(keyword, 0, MAX_EXPORT_ROWS);

        if (list == null || list.isEmpty()) {
            session.setAttribute("error", "Không có danh mục nào để xuất PDF.");
            resp.sendRedirect(req.getContextPath() + "/admin/categories");
            return;
        }

        // Nếu CHƯA có PdfExportUtil, tạm thời báo lỗi nhẹ:
        session.setAttribute("error", "Chức năng xuất PDF danh mục chưa được cấu hình.");
        resp.sendRedirect(req.getContextPath() + "/admin/categories");

        // Khi bạn có PdfExportUtil:
        // String filename = "categories-" + System.currentTimeMillis() + ".pdf";
        // resp.setContentType("application/pdf");
        // resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
        //
        // try (OutputStream out = resp.getOutputStream()) {
        //     PdfExportUtil.exportCategoriesPdf(list, out);
        // } catch (Exception ex) {
        //     ex.printStackTrace();
        //     session.setAttribute("error", "Có lỗi khi xuất PDF danh mục: " + ex.getMessage());
        //     resp.sendRedirect(req.getContextPath() + "/admin/categories");
        // }
    }

    // ========================= POST =========================

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/categories");
            return;
        }

        switch (action) {
            case "save"   -> handleSave(req, resp);
            case "delete" -> handleDelete(req, resp);
            default       -> resp.sendRedirect(req.getContextPath() + "/admin/categories");
        }
    }

    /** Lưu danh mục (tạo mới hoặc cập nhật) */
    private void handleSave(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();

        String idRaw   = req.getParameter("categoryID");
        String nameRaw = req.getParameter("categoryName");
        String desRaw  = req.getParameter("description"); // nếu form có

        String name = nameRaw != null ? nameRaw.trim() : "";
        String description = desRaw != null ? desRaw.trim() : "";

        String errorMessage = null;
        if (name.isBlank()) {
            errorMessage = "Tên danh mục không được để trống.";
        } else if (name.length() > 100) {
            errorMessage = "Tên danh mục quá dài (tối đa 100 ký tự).";
        }

        Category c = new Category();
        c.setCategoryName(name);
        c.setDescription(description);

        Integer id = null;
        if (idRaw != null && !idRaw.isBlank()) {
            try {
                id = Integer.parseInt(idRaw);
                c.setCategoryID(id);
            } catch (NumberFormatException ignored) {
                errorMessage = "Mã danh mục không hợp lệ.";
            }
        }

        if (errorMessage != null) {
            req.setAttribute("error", errorMessage);
            req.setAttribute("category", c);
            req.setAttribute("adminActive", "categories");
            req.getRequestDispatcher("/WEB-INF/admin/category-form.jsp").forward(req, resp);
            return;
        }

        boolean ok;
        String msg;

        if (id == null) {
            ok = cdao.insert(c);
            msg = ok ? "Đã tạo danh mục mới." : "Tạo danh mục thất bại.";
        } else {
            ok = cdao.update(c);
            msg = ok ? "Đã cập nhật danh mục." : "Cập nhật danh mục thất bại.";
        }

        session.setAttribute(ok ? "success" : "error", msg);
        resp.sendRedirect(req.getContextPath() + "/admin/categories");
    }

    /** Xóa danh mục */
    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();
        String idRaw = req.getParameter("id");

        try {
            int id = Integer.parseInt(idRaw);
            boolean ok = cdao.delete(id);

            if (ok) {
                session.setAttribute("success", "Đã xóa danh mục.");
            } else {
                session.setAttribute("error", "Không thể xóa danh mục (có thể đang được sử dụng).");
            }
        } catch (Exception e) {
            session.setAttribute("error", "Mã danh mục không hợp lệ hoặc lỗi hệ thống.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/categories");
    }

    // ========================= Helpers =========================

    private static String opt(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }

    private static int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private static String nz(String s) {
        return (s == null) ? "" : s;
    }

    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
