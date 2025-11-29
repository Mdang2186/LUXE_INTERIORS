package admin;

import Utils.InvoicePdfUtil;
import dal.OrderDAO;
import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Order;
import model.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Xuất hóa đơn PDF cho 1 đơn hàng:
 *  GET /admin/orders/invoice?id=123
 *  -> tải file invoice-123.pdf
 */
@WebServlet(
        name = "AdminOrderInvoiceController",
        urlPatterns = {"/admin/orders/invoice"}
)
public class AdminOrderInvoiceController extends HttpServlet {

    private OrderDAO orderDAO;
    private UserDAO  userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        orderDAO = new OrderDAO();
        userDAO  = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // (optional) đánh dấu menu đang active
        req.setAttribute("adminActive", "orders");

        String idRaw = req.getParameter("id");
        if (idRaw == null || idRaw.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số id đơn hàng.");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idRaw.trim());
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã đơn không hợp lệ.");
            return;
        }

        // ===== 1. Lấy Order + Items =====
        Order order = orderDAO.getOrderByIdWithItems(id);
        if (order == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn hàng.");
            return;
        }

        // ===== 2. Lấy thông tin User (khách hàng) =====
        User user = null;
        try {
            if (order.getUserID() > 0) {
                user = userDAO.getUserById(order.getUserID());
            }
        } catch (Exception ignored) {
        }

        // ===== 3. Tạo PDF bằng util chung =====
        byte[] pdfBytes;
        try {
            pdfBytes = InvoicePdfUtil.generateInvoicePdf(order, user);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Không thể tạo file hóa đơn PDF. Vui lòng thử lại sau.");
            return;
        }

        if (pdfBytes == null || pdfBytes.length == 0) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "File PDF rỗng.");
            return;
        }

        // ===== 4. Chuẩn bị header tải file =====
        String fileName = "invoice-" + id + ".pdf";
        String encoded = URLEncoder.encode(fileName, StandardCharsets.UTF_8)
                                   .replace("+", "%20"); // tránh space => +

        resp.setContentType("application/pdf");
        // attachment: tải về; nếu muốn xem trực tiếp thì đổi attachment -> inline
        resp.setHeader("Content-Disposition",
                "attachment; filename=\"" + encoded + "\"; filename*=UTF-8''" + encoded);
        resp.setContentLength(pdfBytes.length);

        // ===== 5. Ghi dữ liệu ra output =====
        resp.getOutputStream().write(pdfBytes);
        resp.getOutputStream().flush();
    }
}
