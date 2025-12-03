package admin;

import dal.OrderDAO;
import dal.UserDAO;
import model.Order;
import model.User;
import Utils.PdfExportUtil;   
import Utils.ExcelExportUtil;
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
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Quản lý đơn hàng Admin:
 *
 *  GET  /admin/orders?action=list (hoặc null)
 *      - Danh sách đơn, có:
 *        + Tìm kiếm (q: mã đơn / mã KH / địa chỉ)
 *        + Lọc trạng thái
 *        + Lọc phương thức thanh toán
 *        + Lọc khoảng ngày đặt (fromDate / toDate)
 *        + Lọc khoảng tổng tiền (minTotal / maxTotal)
 *        + Phân trang
 *
 *  GET  /admin/orders?action=detail&id=?
 *      - Xem chi tiết 1 đơn (thông tin user + items)
 *
 *  GET  /admin/orders?action=export-orders&...filters...
 *      - Xuất Excel danh sách đơn theo filter hiện tại
 *
 *  POST /admin/orders?action=status
 *      - Cập nhật trạng thái đơn theo flow
 *
 *  POST /admin/orders?action=send-order-email
 *      - Gửi email thông tin đơn cho khách
 */
@WebServlet(name = "AdminOrderController", urlPatterns = {"/admin/orders"})
public class AdminOrderController extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 12;
    private static final int MAX_EXPORT_ROWS   = 10_000;

    private OrderDAO odao;

    @Override
    public void init() throws ServletException {
        super.init();
        odao = new OrderDAO();
    }

    // ========================= GET =========================

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setAttribute("adminActive", "orders");

        String action = req.getParameter("action");
        if (action == null || action.isBlank()) action = "list";

        switch (action) {
            case "detail":
                handleDetail(req, resp);
                return;
            case "export-orders":
                exportOrdersExcel(req, resp);
                return;
            case "export-orders-pdf":              // <<< THÊM CASE PDF
                exportOrdersPdf(req, resp);
                return;
            default:
                handleList(req, resp);
                return;
        }
    }

    /**
     * Danh sách đơn hàng + filter + phân trang
     */
    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ====== Lấy filter từ request ======
        String q       = trimOrNull(req.getParameter("q"));
        String status  = normalizeStatus(req.getParameter("status"));
        String payment = trimOrNull(req.getParameter("payment"));
        String fromStr = trimOrNull(req.getParameter("fromDate"));   // yyyy-MM-dd
        String toStr   = trimOrNull(req.getParameter("toDate"));
        String minStr  = trimOrNull(req.getParameter("minTotal"));
        String maxStr  = trimOrNull(req.getParameter("maxTotal"));

        Date fromDate       = parseDate(fromStr);
        Date toDate         = parseDate(toStr);
        BigDecimal minTotal = parseBigDecimal(minStr);
        BigDecimal maxTotal = parseBigDecimal(maxStr);

        int page = parseIntOrDefault(req.getParameter("page"), 1);
        if (page < 1) page = 1;
        int size = DEFAULT_PAGE_SIZE;

        // ====== Lấy danh sách từ DAO (chỉ theo status) ======
        List<Order> rawOrders = odao.getAllOrders(status, 0, MAX_EXPORT_ROWS);
        if (rawOrders == null) rawOrders = new ArrayList<>();

        // ====== Lọc tiếp theo các tiêu chí khác ======
        List<Order> filtered = filterOrders(
                rawOrders, q, status, payment,
                fromDate, toDate, minTotal, maxTotal
        );

        // ====== Phân trang ======
        int total = filtered.size();
        int totalPages = (int) Math.ceil(total / (double) size);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int fromIndex = (page - 1) * size;
        int toIndex   = Math.min(fromIndex + size, total);
        List<Order> pageOrders = filtered.subList(fromIndex, toIndex);

        // ====== Đẩy dữ liệu ra view ======
        req.setAttribute("orders", pageOrders);
        req.setAttribute("allStatuses", getAllStatuses());

        req.setAttribute("q", q);
        req.setAttribute("status", status);
        req.setAttribute("payment", payment);
        req.setAttribute("fromDate", fromStr);
        req.setAttribute("toDate", toStr);
        req.setAttribute("minTotal", minStr);
        req.setAttribute("maxTotal", maxStr);

        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("pageSize", size);
        req.setAttribute("totalOrders", total);

        req.getRequestDispatcher("/WEB-INF/admin/orders-list.jsp")
           .forward(req, resp);
    }

    /**
     * Chi tiết 1 đơn
     */
    private void handleDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        int id = parseIntOrDefault(req.getParameter("id"), -1);
        if (id <= 0) {
            session.setAttribute("error", "Mã đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        Order order = odao.getOrderByIdWithItems(id);
        if (order == null) {
            session.setAttribute("error", "Không tìm thấy đơn hàng.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        // Lấy thông tin user để hiển thị thêm
        UserDAO udao = new UserDAO();
        User user = udao.getById(order.getUserID());

        List<String> nextStatuses = getNextStatuses(order.getStatus());

        req.setAttribute("order", order);
        req.setAttribute("user", user);
        req.setAttribute("nextStatuses", nextStatuses);
        req.setAttribute("allStatuses", getAllStatuses());

        req.getRequestDispatcher("/WEB-INF/admin/order-detail.jsp")
           .forward(req, resp);
    }

    /**
     * Export danh sách đơn hàng theo filter hiện tại.
     */
      private void exportOrdersExcel(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();

        String q       = trimOrNull(req.getParameter("q"));
        String status  = normalizeStatus(req.getParameter("status"));
        String payment = trimOrNull(req.getParameter("payment"));
        String fromStr = trimOrNull(req.getParameter("fromDate"));
        String toStr   = trimOrNull(req.getParameter("toDate"));
        String minStr  = trimOrNull(req.getParameter("minTotal"));
        String maxStr  = trimOrNull(req.getParameter("maxTotal"));

        Date fromDate       = parseDate(fromStr);
        Date toDate         = parseDate(toStr);
        BigDecimal minTotal = parseBigDecimal(minStr);
        BigDecimal maxTotal = parseBigDecimal(maxStr);

        List<Order> rawOrders = odao.getAllOrders(status, 0, MAX_EXPORT_ROWS);
        if (rawOrders == null) rawOrders = new ArrayList<>();
        List<Order> filtered = filterOrders(
                rawOrders, q, status, payment,
                fromDate, toDate, minTotal, maxTotal
        );

        if (filtered.isEmpty()) {
            session.setAttribute("error",
                    "Không có đơn hàng nào phù hợp để xuất Excel.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        String fileName = "orders"
                + (status != null ? "-" + status.toLowerCase() : "")
                + "-" + new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date())
                + ".xls";

        resp.setContentType("application/vnd.ms-excel");
        resp.setHeader("Content-Disposition",
                "attachment; filename=\"" + fileName + "\"");

        try (OutputStream out = resp.getOutputStream()) {
            ExcelExportUtil.exportOrders(filtered, out);
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error",
                    "Có lỗi khi xuất Excel: " + e.getMessage());
            // nếu lỗi, chuyển về trang list (không để 0B)
            resp.reset();
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
        }
    }


    // ========================= POST =========================

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        switch (action) {
            case "status":
                handleUpdateStatus(req, resp);
                break;
            case "send-order-email":
                handleSendOrderEmail(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/orders");
        }
    }

    /** Cập nhật trạng thái đơn theo flow */
    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();
        int id = parseIntOrDefault(req.getParameter("id"), -1);
        String newStatus = trimOrNull(req.getParameter("status"));

        if (id <= 0) {
            session.setAttribute("error", "Mã đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }
        if (newStatus == null) {
            session.setAttribute("error", "Trạng thái mới không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders?action=detail&id=" + id);
            return;
        }

        boolean ok = odao.updateStatusFlow(id, newStatus);
        if (ok) {
            session.setAttribute("success", "Đã cập nhật trạng thái đơn hàng.");
        } else {
            session.setAttribute("error",
                    "Không thể chuyển trạng thái ngược quy trình hoặc trạng thái không hợp lệ.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/orders?action=detail&id=" + id);
    }

    /** Gửi email thông tin đơn hàng cho khách */
    private void handleSendOrderEmail(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();
        int orderId = parseIntOrDefault(req.getParameter("id"), -1);
        if (orderId <= 0) {
            session.setAttribute("error", "Mã đơn hàng không hợp lệ để gửi email.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        Order order = odao.getOrderByIdWithItems(orderId);
        if (order == null) {
            session.setAttribute("error", "Không tìm thấy đơn hàng để gửi email.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        UserDAO udao = new UserDAO();
        User user = udao.getById(order.getUserID());
        if (user == null || user.getEmail() == null || user.getEmail().isBlank()) {
            session.setAttribute("error", "Không tìm thấy khách hàng hoặc email không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders?action=detail&id=" + orderId);
            return;
        }

        SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");

        StringBuilder body = new StringBuilder();
        body.append("Xin chào ")
            .append(user.getFullName() == null ? "bạn" : user.getFullName())
            .append(",\n\n")
            .append("FurniShop gửi bạn thông tin đơn hàng #").append(order.getOrderID()).append(":\n")
            .append("- Ngày đặt: ")
            .append(order.getOrderDate() != null ? df.format(order.getOrderDate()) : "N/A").append("\n")
            .append("- Tổng tiền: ").append(order.getTotalAmount()).append(" VND\n")
            .append("- Trạng thái hiện tại: ").append(order.getStatus()).append("\n")
            .append("- Phương thức thanh toán: ").append(order.getPaymentMethod()).append("\n")
            .append("- Địa chỉ giao hàng: ").append(order.getShippingAddress()).append("\n\n")
            .append("Cảm ơn bạn đã mua sắm tại LUXE INTERIORS / FurniShop.\n")
            .append("Trân trọng.");

        EmailService mailer = new EmailService();
        boolean ok = mailer.sendPlainText(
                user.getEmail(),
                "Thông tin đơn hàng #" + order.getOrderID() + " tại FurniShop",
                body.toString()
        );

        session.setAttribute(ok ? "success" : "error",
                ok ? "Đã gửi email thông tin đơn hàng cho khách."
                   : "Gửi email đơn hàng thất bại.");

        resp.sendRedirect(req.getContextPath() + "/admin/orders?action=detail&id=" + orderId);
    }

    // ========================= Helpers =========================

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

    private Date parseDate(String raw) {
        if (raw == null || raw.isEmpty()) return null;
        try {
            return new SimpleDateFormat("yyyy-MM-dd").parse(raw);
        } catch (ParseException e) {
            return null;
        }
    }

    private BigDecimal parseBigDecimal(String raw) {
        if (raw == null || raw.isEmpty()) return null;
        try {
            return new BigDecimal(raw);
        } catch (Exception e) {
            return null;
        }
    }

    /** Tất cả trạng thái dùng cho filter + timeline */
    private List<String> getAllStatuses() {
        return Arrays.asList("Pending", "Confirmed", "Packing", "Shipping", "Done", "Canceled");
    }

    /** Trạng thái kế tiếp hợp lệ */
    private List<String> getNextStatuses(String currentStatus) {
        List<String> next = new ArrayList<>();
        if (currentStatus == null) return next;

        String s = currentStatus.trim().toLowerCase();
        switch (s) {
            case "pending":
                next.add("Confirmed");
                next.add("Canceled");
                break;
            case "confirmed":
                next.add("Packing");
                next.add("Canceled");
                break;
            case "packing":
                next.add("Shipping");
                break;
            case "shipping":
                next.add("Done");
                break;
            default:
                break; // Done / Canceled
        }
        return next;
    }

    private String normalizeStatus(String s) {
        s = trimOrNull(s);
        if (s == null) return null;
        if ("all".equalsIgnoreCase(s)) return null;
        return s;
    }

    /** Lọc danh sách đơn theo filter */
    private List<Order> filterOrders(List<Order> source,
                                     String q,
                                     String status,
                                     String payment,
                                     Date fromDate,
                                     Date toDate,
                                     BigDecimal minTotal,
                                     BigDecimal maxTotal) {

        List<Order> result = new ArrayList<>();
        String qLower = (q == null) ? null : q.toLowerCase();

        for (Order o : source) {
            if (o == null) continue;

            // Status
            if (status != null && o.getStatus() != null
                    && !status.equalsIgnoreCase(o.getStatus())) {
                continue;
            }

            // Payment
            if (payment != null) {
                String pay = o.getPaymentMethod();
                if (pay == null || !payment.equalsIgnoreCase(pay.trim())) {
                    continue;
                }
            }

            // Keyword
            if (qLower != null) {
                String orderIdStr = String.valueOf(o.getOrderID());
                String userIdStr  = String.valueOf(o.getUserID());
                String addr       = o.getShippingAddress() == null ? "" : o.getShippingAddress();

                boolean matchQ = orderIdStr.toLowerCase().contains(qLower)
                        || userIdStr.toLowerCase().contains(qLower)
                        || addr.toLowerCase().contains(qLower);
                if (!matchQ) continue;
            }

            // Date range
            Date od = o.getOrderDate();
            if (fromDate != null && od != null && od.before(fromDate)) {
                continue;
            }
            if (toDate != null && od != null && od.after(toDate)) {
                continue;
            }

            // Total range (TotalAmount kiểu double trong model)
            BigDecimal orderTotal = BigDecimal.valueOf(o.getTotalAmount());
            if (minTotal != null && orderTotal.compareTo(minTotal) < 0) {
                continue;
            }
            if (maxTotal != null && orderTotal.compareTo(maxTotal) > 0) {
                continue;
            }

            result.add(o);
        }
        return result;
    }
     private void exportOrdersPdf(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();

        String q       = trimOrNull(req.getParameter("q"));
        String status  = normalizeStatus(req.getParameter("status"));
        String payment = trimOrNull(req.getParameter("payment"));
        String fromStr = trimOrNull(req.getParameter("fromDate"));
        String toStr   = trimOrNull(req.getParameter("toDate"));
        String minStr  = trimOrNull(req.getParameter("minTotal"));
        String maxStr  = trimOrNull(req.getParameter("maxTotal"));

        Date fromDate       = parseDate(fromStr);
        Date toDate         = parseDate(toStr);
        BigDecimal minTotal = parseBigDecimal(minStr);
        BigDecimal maxTotal = parseBigDecimal(maxStr);

        List<Order> rawOrders = odao.getAllOrders(status, 0, MAX_EXPORT_ROWS);
        if (rawOrders == null) rawOrders = new ArrayList<>();
        List<Order> filtered = filterOrders(
                rawOrders, q, status, payment,
                fromDate, toDate, minTotal, maxTotal
        );

        if (filtered.isEmpty()) {
            session.setAttribute("error",
                    "Không có đơn hàng nào phù hợp để xuất PDF.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        String fileName = "orders"
                + (status != null ? "-" + status.toLowerCase() : "")
                + "-" + new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date())
                + ".pdf";

        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition",
                "attachment; filename=\"" + fileName + "\"");

        try (OutputStream out = resp.getOutputStream()) {
            PdfExportUtil.exportOrders(filtered, out);   // sẽ viết ở bước 4
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error",
                    "Có lỗi khi xuất PDF: " + e.getMessage());
            resp.reset();
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
        }
    }
}


