package admin;

import dal.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.Category;

/**
 * Quản lý danh mục sản phẩm cho Admin:
 * - GET  /admin/categories?action=list (hoặc null) : danh sách danh mục
 * - GET  /admin/categories?action=create           : form tạo mới
 * - GET  /admin/categories?action=edit&id=?        : form chỉnh sửa
 * - POST /admin/categories?action=save             : lưu (tạo / cập nhật)
 * - POST /admin/categories?action=delete&id=?      : xóa danh mục
 *
 * Có:
 *  - Validate tên danh mục
 *  - Thông báo lỗi / thành công qua session (flash message)
 *  - Xử lý trường hợp id không hợp lệ, danh mục không tồn tại
 */
@WebServlet(name = "AdminCategoryController", urlPatterns = {"/admin/categories"})
public class AdminCategoryController extends HttpServlet {

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
        String action = req.getParameter("action");
        if (action == null || action.isBlank() || "list".equals(action)) {
            // Mặc định: xem danh sách
            handleList(req, resp);
        } else if ("create".equals(action) || "edit".equals(action)) {
            // Hiển thị form tạo / sửa
            handleForm(req, resp, action);
        } else {
            // Action không hợp lệ -> quay về danh sách
            resp.sendRedirect(req.getContextPath() + "/admin/categories");
        }
    }

    /** Danh sách tất cả danh mục */
    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setAttribute("categories", cdao.getAllCategories());
        req.getRequestDispatcher("/WEB-INF/admin/categories-list.jsp").forward(req, resp);
    }

    /** Hiển thị form tạo mới / chỉnh sửa */
    private void handleForm(HttpServletRequest req, HttpServletResponse resp, String action)
            throws ServletException, IOException {

        Category c = null;

        if ("edit".equals(action)) {
            // Lấy id từ query string
            String idRaw = req.getParameter("id");
            try {
                int id = Integer.parseInt(idRaw);
                c = cdao.getById(id);
                if (c == null) {
                    // Không tìm thấy -> báo lỗi rồi quay về list
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

        // Nếu create thì c = null -> form hiểu là tạo mới
        req.setAttribute("category", c);
        req.getRequestDispatcher("/WEB-INF/admin/category-form.jsp").forward(req, resp);
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

        // Lấy dữ liệu từ form
        String idRaw   = req.getParameter("categoryID");
        String nameRaw = req.getParameter("categoryName");
        // Nếu sau này anh thêm mô tả:
        // String desRaw  = req.getParameter("description");

        String name = nameRaw != null ? nameRaw.trim() : "";

        // ========== Validate cơ bản ==========
        String errorMessage = null;
        if (name.isBlank()) {
            errorMessage = "Tên danh mục không được để trống.";
        } else if (name.length() > 100) { // giới hạn ví dụ
            errorMessage = "Tên danh mục quá dài (tối đa 100 ký tự).";
        }

        // Chuẩn bị object để nếu lỗi còn show lại form
        Category c = new Category();
        c.setCategoryName(name);
        // c.setDescription(desRaw); // nếu có field này trong model

        Integer id = null;
        if (idRaw != null && !idRaw.isBlank()) {
            try {
                id = Integer.parseInt(idRaw);
                c.setCategoryID(id);
            } catch (NumberFormatException ignored) {
                // nếu id sai định dạng sẽ xử lý ở dưới
                errorMessage = "Mã danh mục không hợp lệ.";
            }
        }

        if (errorMessage != null) {
            // Có lỗi -> trả về form với thông báo & dữ liệu đã nhập
            req.setAttribute("error", errorMessage);
            req.setAttribute("category", c);

            req.setAttribute("adminActive", "categories");
            req.getRequestDispatcher("/WEB-INF/admin/category-form.jsp").forward(req, resp);
            return;
        }

        // ========== Gọi DAO để insert/update ==========
        boolean ok;
        String msg;

        if (id == null) {
            // Tạo mới
            ok = cdao.insert(c);
            msg = ok ? "Đã tạo danh mục mới." : "Tạo danh mục thất bại.";
        } else {
            // Cập nhật
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

            // Lưu ý: nếu DB có ràng buộc khóa ngoại với products,
            // delete có thể bị lỗi -> trong CategoryDAO nên catch & trả false.
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
}
