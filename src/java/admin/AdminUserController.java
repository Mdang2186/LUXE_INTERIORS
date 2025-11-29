package admin;

import dal.UserDAO;
import dal.OrderDAO;
import model.User;
import model.Order;
import java.io.PrintWriter;
import java.text.DecimalFormat;

import Utils.EmailService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

// Apache POI (dùng HSSF cho .xls – tương thích bản cũ)
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFFont;

@WebServlet(name = "AdminUserController", urlPatterns = {"/admin/users"})
public class AdminUserController extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 20;
// ==================== CSV Helpers ====================

private static final char CSV_DELIM = ';';

/**
 * Ghi 1 dòng CSV, tự bọc mỗi cột trong dấu " và escape ".
 */
private void writeCsvLine(PrintWriter w, String... cols) {
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < cols.length; i++) {
        if (i > 0) sb.append(CSV_DELIM);
        String val = cols[i];
        if (val == null) val = "";
        // escape dấu "
        val = val.replace("\"", "\"\"");
        sb.append('"').append(val).append('"');
    }
    w.println(sb.toString());
}

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // để sidebar active "Người dùng"
        req.setAttribute("adminActive", "users");

        String action = req.getParameter("action");
        if (action == null || action.isBlank()) {
            action = "list";
        }

        switch (action) {
            case "detail":
                handleDetail(req, resp);
                break;
            case "export-users":
                exportUserListExcel(req, resp);
                break;
            case "export-user-orders":
                exportUserOrdersExcel(req, resp);
                break;
            default:
                handleList(req, resp);
                break;
        }
    }

    /* =========================================================
       1. LIST + SEARCH + FILTER + PHÂN TRANG
       ========================================================= */
    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String q      = trimOrNull(req.getParameter("q"));
        String role   = trimOrNull(req.getParameter("role"));   // Admin / Staff / Customer / null = all
        String status = trimOrNull(req.getParameter("status")); // để dành sau này (Active/Inactive...)

        int page = parseIntOrDefault(req.getParameter("page"), 1);
        if (page < 1) page = 1;

        int pageSize = parseIntOrDefault(req.getParameter("size"), DEFAULT_PAGE_SIZE);
        if (pageSize <= 0 || pageSize > 200) pageSize = DEFAULT_PAGE_SIZE;

        int offset = (page - 1) * pageSize;

        UserDAO udao = new UserDAO();

        int total = udao.countUsers(q, role, status);
        int totalPages = (int) Math.ceil(total / (double) pageSize);

        List<User> users = udao.searchUsers(q, role, status, offset, pageSize);

        req.setAttribute("users", users);
        req.setAttribute("q", q);
        req.setAttribute("role", role);
        req.setAttribute("status", status);
        req.setAttribute("page", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("total", total);
        req.setAttribute("totalPages", totalPages);

        req.getRequestDispatcher("/WEB-INF/admin/users-list.jsp").forward(req, resp);
    }

    /* =========================================================
       2. CHI TIẾT USER + LỊCH SỬ ĐƠN
       ========================================================= */
    private void handleDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        String idRaw = req.getParameter("id");
        int id;
        try {
            id = Integer.parseInt(idRaw);
        } catch (Exception e) {
            session.setAttribute("error", "Mã người dùng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        UserDAO udao = new UserDAO();
        User u = udao.getById(id);
        if (u == null) {
            session.setAttribute("error", "Không tìm thấy người dùng.");
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        OrderDAO odao = new OrderDAO();
        List<Order> orders = odao.getOrdersByUser(id);
        BigDecimal totalSpent = odao.totalSpentByUser(id);

        Date lastOrderDate = null;
        if (orders != null && !orders.isEmpty()) {
            lastOrderDate = orders.get(0).getOrderDate();
        }

        req.setAttribute("user", u);
        req.setAttribute("orders", orders);
        req.setAttribute("totalSpent", totalSpent);
        req.setAttribute("lastOrderDate", lastOrderDate);

        req.getRequestDispatcher("/WEB-INF/admin/user-detail.jsp").forward(req, resp);
    }

    /* =========================================================
       3. POST: ĐỔI ROLE + GỬI BÁO CÁO EMAIL
       ========================================================= */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "role":
            case "update-role":
                updateRole(req, resp);
                break;

            case "send-user-report":
                sendUserReport(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/admin/users");
        }
    }

    private void updateRole(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();
        UserDAO udao = new UserDAO();

        String idRaw = req.getParameter("id");
        String role  = req.getParameter("role");
        int id;

        try {
            id = Integer.parseInt(idRaw);
        } catch (Exception ex) {
            session.setAttribute("error", "ID người dùng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        try {
            boolean ok = udao.updateRole(id, role);
            session.setAttribute(ok ? "success" : "error",
                    ok ? "Đã cập nhật vai trò người dùng." : "Cập nhật vai trò thất bại.");
        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("error", "Có lỗi xảy ra: " + ex.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/users?action=detail&id=" + id);
    }

    private void sendUserReport(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();
        String idRaw = req.getParameter("id");
        int userId;

        try {
            userId = Integer.parseInt(idRaw);
        } catch (Exception e) {
            session.setAttribute("error", "ID người dùng không hợp lệ để gửi báo cáo.");
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        UserDAO udao = new UserDAO();
        User user = udao.getById(userId);
        if (user == null || user.getEmail() == null || user.getEmail().isBlank()) {
            session.setAttribute("error", "Không tìm thấy user hoặc email không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/users");
            return;
        }

        OrderDAO odao = new OrderDAO();
        List<Order> orders = odao.getOrdersByUser(userId);
        BigDecimal totalSpent = odao.totalSpentByUser(userId);

        int totalOrders = (orders == null) ? 0 : orders.size();
        String spentStr = (totalSpent == null) ? "0" : totalSpent.toPlainString();

        StringBuilder body = new StringBuilder();
        body.append("Xin chào ").append(user.getFullName() == null ? "bạn" : user.getFullName()).append(",\n\n")
            .append("Đây là báo cáo tổng quan lịch sử đơn hàng của bạn tại FurniShop:\n")
            .append("- Tổng số đơn hàng: ").append(totalOrders).append("\n")
            .append("- Tổng chi tiêu (đơn đã hoàn tất): ").append(spentStr).append(" VND\n\n")
            .append("Cảm ơn bạn đã tin tưởng và mua sắm tại FurniShop.\n")
            .append("Trân trọng,\nLUXE INTERIORS / FurniShop.");

        EmailService mailer = new EmailService();
        boolean ok = mailer.sendPlainText(
                user.getEmail(),
                "Báo cáo đơn hàng của bạn tại FurniShop",
                body.toString()
        );

        session.setAttribute(ok ? "success" : "error",
                ok ? "Đã gửi báo cáo đơn hàng qua email cho khách." : "Gửi email báo cáo thất bại.");

        resp.sendRedirect(req.getContextPath() + "/admin/users?action=detail&id=" + userId);
    }

    /* =========================================================
       4. EXPORT EXCEL – DANH SÁCH USER THEO FILTER HIỆN TẠI
       URL: /admin/users?action=export-users&q=...&role=...&status=...
       ========================================================= */
    // =========================================================
// 4. EXPORT EXCEL – DANH SÁCH USER THEO FILTER HIỆN TẠI
// URL: /admin/users?action=export-users&q=...&role=...&status=...
// =========================================================
// 4. EXPORT CSV – DANH SÁCH USER THEO FILTER HIỆN TẠI
// URL: /admin/users?action=export-users&q=...&role=...&status=...
// 4. EXPORT CSV – DANH SÁCH USER THEO FILTER HIỆN TẠI
// URL: /admin/users?action=export-users&q=...&role=...&status=...
private void exportUserListExcel(HttpServletRequest req, HttpServletResponse resp)
        throws IOException {

    String q      = trimOrNull(req.getParameter("q"));
    String role   = trimOrNull(req.getParameter("role"));
    String status = trimOrNull(req.getParameter("status"));

    int offset   = 0;
    int pageSize = 10_000; // xuất tối đa 10k dòng

    UserDAO udao = new UserDAO();
    List<User> users = udao.searchUsers(q, role, status, offset, pageSize);

    String filename = "users-"
            + new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date())
            + ".csv";

    resp.setContentType("text/csv; charset=UTF-8");
    resp.setCharacterEncoding("UTF-8");
    resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

    PrintWriter writer = resp.getWriter();

    // BOM để Excel hiểu UTF-8, hiển thị đúng tiếng Việt
    writer.write('\uFEFF');

    // Khai báo delimiter cho Excel
    writer.println("sep=" + CSV_DELIM);

    // ====== HEADER ======
    writeCsvLine(writer,
            "STT",
            "ID",
            "Họ tên",
            "Email",
            "Số điện thoại",
            "Địa chỉ",
            "Vai trò",
            "Ngày tạo"
    );

    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    int stt = 1;

    if (users != null) {
        for (User u : users) {
            String createdAtStr = "";
            Date createdAt = u.getCreatedAt();
            if (createdAt != null) {
                createdAtStr = df.format(createdAt);
            }

            // Vai trò hiển thị cho đẹp (nếu bạn muốn mapping)
            String roleDisplay = nz(u.getRole());
            if ("ADMIN".equalsIgnoreCase(roleDisplay)) {
                roleDisplay = "Quản trị viên";
            } else if ("STAFF".equalsIgnoreCase(roleDisplay)) {
                roleDisplay = "Nhân viên";
            } else if ("CUSTOMER".equalsIgnoreCase(roleDisplay)) {
                roleDisplay = "Khách hàng";
            }

            writeCsvLine(writer,
                    String.valueOf(stt),
                    String.valueOf(u.getUserID()),
                    nz(u.getFullName()),
                    nz(u.getEmail()),
                    nz(u.getPhone()),
                    nz(u.getAddress()),
                    roleDisplay,
                    createdAtStr
            );

            stt++;
        }
    }

    writer.flush();
}


// =========================================================
// 5. EXPORT EXCEL – TẤT CẢ ĐƠN + CHI TIẾT HÀNG CỦA 1 USER
// URL: /admin/users?action=export-user-orders&id=123
// =========================================================
// 5. EXPORT CSV – TẤT CẢ ĐƠN + CHI TIẾT HÀNG CỦA 1 USER
// URL: /admin/users?action=export-user-orders&id=123
// 5. EXPORT CSV – TẤT CẢ ĐƠN + CHI TIẾT HÀNG CỦA 1 USER
// URL: /admin/users?action=export-user-orders&id=123
private void exportUserOrdersExcel(HttpServletRequest req, HttpServletResponse resp)
        throws IOException {

    HttpSession session = req.getSession();
    int userId;
    try {
        userId = Integer.parseInt(req.getParameter("id"));
    } catch (Exception e) {
        session.setAttribute("error", "Mã người dùng không hợp lệ để xuất file.");
        resp.sendRedirect(req.getContextPath() + "/admin/users");
        return;
    }

    UserDAO udao = new UserDAO();
    User user = udao.getById(userId);
    if (user == null) {
        session.setAttribute("error", "Không tìm thấy người dùng để xuất file.");
        resp.sendRedirect(req.getContextPath() + "/admin/users");
        return;
    }

    OrderDAO odao = new OrderDAO();
    List<Object[]> rows = odao.findOrderItemsByUser(userId);

    String safeName = (user.getFullName() == null || user.getFullName().isBlank())
            ? "user-" + user.getUserID()
            : user.getFullName().trim().replaceAll("\\s+", "_");

    String filename = "orders-" + safeName + "-"
            + new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date())
            + ".csv";

    resp.setContentType("text/csv; charset=UTF-8");
    resp.setCharacterEncoding("UTF-8");
    resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

    PrintWriter writer = resp.getWriter();
    writer.write('\uFEFF');                // BOM UTF-8
    writer.println("sep=" + CSV_DELIM);   // delimiter cho Excel

    // ====== HEADER ======
    writeCsvLine(writer,
            "STT",
            "Mã đơn",
            "Ngày đặt",
            "Trạng thái",
            "Tên sản phẩm",
            "Số lượng",
            "Đơn giá (VND)",
            "Thành tiền (VND)"
    );

    SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    DecimalFormat money = new DecimalFormat("#,##0"); // format tiền 1.000.000

    int stt = 1;

    if (rows != null) {
        for (Object[] row : rows) {
            Integer orderId     = toInt(row[0]);
            Date orderDate      = (row[1] instanceof Date) ? (Date) row[1] : null;
            String statusStr    = row[2] != null ? row[2].toString() : "";
            String productName  = row[3] != null ? row[3].toString() : "";
            Integer quantityObj = toInt(row[4]);
            int quantity        = quantityObj != null ? quantityObj : 0;
            double unitPrice    = toDouble(row[5]);
            double lineTotal    = toDouble(row[6]);

            String dateStr = (orderDate != null) ? df.format(orderDate) : "";

            // Định dạng tiền
            String unitPriceStr = money.format(unitPrice);
            String lineTotalStr = money.format(lineTotal);

            writeCsvLine(writer,
                    String.valueOf(stt),
                    String.valueOf(orderId != null ? orderId : 0),
                    dateStr,
                    statusStr,
                    productName,
                    String.valueOf(quantity),
                    unitPriceStr,
                    lineTotalStr
            );

            stt++;
        }
    }

    writer.flush();
}

// Escape text cho CSV: bao trong dấu " và replace " -> ""
private String toCsv(String s) {
    if (s == null) return "\"\"";
    String v = s.replace("\"", "\"\"");
    return "\"" + v + "\"";
}



    /* ==================== Helpers ==================== */

    private String trimOrNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private int parseIntOrDefault(String raw, int def) {
        try {
            return Integer.parseInt(raw);
        } catch (Exception e) {
            return def;
        }
    }

    private Integer toInt(Object o) {
        if (o == null) return null;
        if (o instanceof Integer) return (Integer) o;
        if (o instanceof Number) return ((Number) o).intValue();
        try {
            return Integer.parseInt(o.toString());
        } catch (Exception e) {
            return null;
        }
    }

    private double toDouble(Object o) {
        if (o == null) return 0d;
        if (o instanceof Number) return ((Number) o).doubleValue();
        try {
            return Double.parseDouble(o.toString());
        } catch (Exception e) {
            return 0d;
        }
    }

    private String nz(String s) {
        return s == null ? "" : s;
    }
}
