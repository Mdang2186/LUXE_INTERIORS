package admin;

import dal.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import model.Order;

/**
 * Quản lý đơn hàng cho Admin:
 *  - GET  /admin/orders?action=list (hoặc null)       : danh sách đơn (có lọc trạng thái + phân trang)
 *  - GET  /admin/orders?action=detail&id=?            : xem chi tiết đơn (kèm items)
 *  - POST /admin/orders?action=status                 : cập nhật trạng thái theo flow, không cho quay ngược
 *
 * Các trạng thái (gợi ý):
 *  Pending  -> Confirmed -> Packing -> Shipping -> Done
 *                         \-> Canceled (từ Pending / Confirmed)
 *  Done / Canceled: trạng thái cuối, không đổi nữa
 */
@WebServlet(name = "AdminOrderController", urlPatterns = {"/admin/orders"})
public class AdminOrderController extends HttpServlet {

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

        if ("detail".equalsIgnoreCase(action)) {
            handleDetail(req, resp);
        } else {
            // mặc định: list
            handleList(req, resp);
        }
    }

    /** Danh sách đơn hàng với filter trạng thái + phân trang */
    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String status = req.getParameter("status");
        if (status != null && status.isBlank()) status = null;
        if ("all".equalsIgnoreCase(status)) status = null;

        int page = parseIntOrDefault(req.getParameter("page"), 1);
        if (page < 1) page = 1;
        int size = 12;

        int total = odao.countByStatus(status);
        int totalPages = (int) Math.ceil(total / (double) size);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<Order> orders = odao.getAllOrders(status, (page - 1) * size, size);

        req.setAttribute("orders", orders);
        req.setAttribute("status", status);          // giữ lại trạng thái đang filter
        req.setAttribute("allStatuses", getAllStatuses()); // danh sách trạng thái cho combobox
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalOrders", total);

        req.getRequestDispatcher("/WEB-INF/admin/orders-list.jsp").forward(req, resp);
    }

    /** Chi tiết đơn hàng + gợi ý trạng thái tiếp theo để hiển thị nút */
    private void handleDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        String idRaw = req.getParameter("id");

        int id;
        try {
            id = Integer.parseInt(idRaw);
        } catch (Exception e) {
            session.setAttribute("error", "Mã đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        Order o = odao.getOrderByIdWithItems(id);
        if (o == null) {
            session.setAttribute("error", "Không tìm thấy đơn hàng.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        // Danh sách trạng thái có thể chuyển tới (theo flow)
        List<String> nextStatuses = getNextStatuses(o.getStatus());

        req.setAttribute("order", o);
        req.setAttribute("nextStatuses", nextStatuses);
        req.setAttribute("allStatuses", getAllStatuses());

        req.getRequestDispatcher("/WEB-INF/admin/order-detail.jsp").forward(req, resp);
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
            case "status" -> handleUpdateStatus(req, resp);
            default -> resp.sendRedirect(req.getContextPath() + "/admin/orders");
        }
    }

    /** Cập nhật trạng thái đơn theo quy trình, không cho quay ngược */
    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();
        String idRaw = req.getParameter("id");
        String newStatus = req.getParameter("status");

        int id;
        try {
            id = Integer.parseInt(idRaw);
        } catch (Exception e) {
            session.setAttribute("error", "Mã đơn hàng không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }

        if (newStatus == null || newStatus.isBlank()) {
            session.setAttribute("error", "Trạng thái mới không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/orders?action=detail&id=" + id);
            return;
        }

        // GỌI HÀM MỚI: updateStatusFlow -> chỉ cho phép đi tới giai đoạn sau
        boolean ok = odao.updateStatusFlow(id, newStatus);

        if (ok) {
            session.setAttribute("success", "Đã cập nhật trạng thái đơn hàng.");
        } else {
            session.setAttribute("error",
                    "Không thể chuyển trạng thái ngược quy trình hoặc trạng thái không hợp lệ.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/orders?action=detail&id=" + id);
    }

    // ========================= Tiện ích =========================

    /** Danh sách toàn bộ trạng thái để hiển thị filter / select */
    private List<String> getAllStatuses() {
        // Anh chỉnh cho đúng với DB của mình nếu tên khác
        return Arrays.asList("Pending", "Confirmed", "Packing", "Shipping", "Done", "Canceled");
    }

    /** Lấy danh sách trạng thái kế tiếp hợp lệ để show nút trên màn detail */
    private List<String> getNextStatuses(String currentStatus) {
        List<String> next = new ArrayList<>();
        if (currentStatus == null) return next;

        String s = currentStatus.trim().toLowerCase();

        switch (s) {
            case "pending" -> {
                next.add("Confirmed");
                next.add("Canceled");
            }
            case "confirmed" -> {
                next.add("Packing");
                next.add("Canceled");
            }
            case "packing" -> next.add("Shipping");
            case "shipping" -> next.add("Done");
            default -> {
                // Done / Canceled / trạng thái khác -> không có bước tiếp theo
            }
        }
        return next;
    }

    private int parseIntOrDefault(String raw, int defaultValue) {
        try {
            return Integer.parseInt(raw);
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
