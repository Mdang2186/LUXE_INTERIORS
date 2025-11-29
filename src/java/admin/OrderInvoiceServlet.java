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
 * Xem / tải hóa đơn PDF cho 1 đơn hàng:
 *  GET /admin/order-invoice?id=123
 *  -> mở/ tải file invoice-123.pdf
 */
@WebServlet(name = "OrderInvoiceServlet",
        urlPatterns = {"/admin/order-invoice"})
public class OrderInvoiceServlet extends HttpServlet {

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

        // có thể set menu active nếu dùng chung layout
        req.setAttribute("adminActive", "orders");

        String idRaw = req.getParameter("id");
        if (idRaw == null || idRaw.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu id đơn hàng");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idRaw.trim());
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Mã đơn không hợp lệ");
            return;
        }

        // 1. Lấy order + items
        Order order = orderDAO.getOrderByIdWithItems(id);
        if (order == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy đơn hàng");
            return;
        }

        // 2. Lấy info user (nếu có)
        User user = null;
        try {
            if (order.getUserID() > 0) {
                // CHÚ Ý: dùng getUserById (không phải getById)
                user = userDAO.getUserById(order.getUserID());
            }
        } catch (Exception ignored) {
        }

        // 3. Tạo PDF dùng util chung
        byte[] pdfBytes;
        try {
            pdfBytes = InvoicePdfUtil.generateInvoicePdf(order, user);
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Lỗi tạo file hóa đơn PDF.");
            return;
        }

        if (pdfBytes == null || pdfBytes.length == 0) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "File PDF rỗng.");
            return;
        }

        // 4. Header response (inline để mở ngay trên trình duyệt)
        String fileName = "order-" + id + ".pdf";
        String encodedFileName = URLEncoder.encode(fileName, StandardCharsets.UTF_8)
                                           .replace("+", "%20");

        resp.setContentType("application/pdf");
        // inline: hiển thị trong tab; nếu muốn tải về thì đổi inline -> attachment
        resp.setHeader("Content-Disposition",
                "inline; filename=\"" + encodedFileName + "\"; filename*=UTF-8''" + encodedFileName);
        resp.setContentLength(pdfBytes.length);

        resp.getOutputStream().write(pdfBytes);
        resp.getOutputStream().flush();
    }
}
