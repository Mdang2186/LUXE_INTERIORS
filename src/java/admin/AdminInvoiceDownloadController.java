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

@WebServlet(
        name = "AdminInvoiceDownloadController",
        urlPatterns = {
                "/admin/orders/invoice/download",   // đường dẫn cũ (nếu JSP đang dùng)
                "/admin/order-invoice-download"     // đường dẫn gọn hơn, có thể dùng mới
        }
)
public class AdminInvoiceDownloadController extends HttpServlet {

    private OrderDAO odao;
    private UserDAO udao;

    @Override
    public void init() throws ServletException {
        super.init();
        odao = new OrderDAO();
        udao = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idRaw = req.getParameter("id");
        if (idRaw == null || idRaw.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Thiếu tham số id đơn hàng.");
            return;
        }

        int id;
        try {
            id = Integer.parseInt(idRaw.trim());
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "OrderID không hợp lệ.");
            return;
        }

        // Lấy đơn hàng kèm item
        Order order = odao.getOrderByIdWithItems(id);
        if (order == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND,
                    "Không tìm thấy đơn hàng.");
            return;
        }

        // Lấy thông tin user (nếu cần in trên hóa đơn)
        User user = null;
        try {
            user = udao.getUserById(order.getUserID());
        } catch (Exception ignored) {
        }

        // Sinh PDF
        byte[] pdfBytes;
        try {
            pdfBytes = InvoicePdfUtil.generateInvoicePdf(order, user);
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Lỗi khi tạo file PDF hóa đơn.", e);
        }

        if (pdfBytes == null || pdfBytes.length == 0) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Không tạo được nội dung PDF.");
            return;
        }

        // Cấu hình response để tải về file PDF
        String fileName = "invoice-" + order.getOrderID() + ".pdf";
        String encodedFileName = URLEncoder.encode(fileName, StandardCharsets.UTF_8)
                                           .replace("+", "%20");

        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition",
                "attachment; filename=\"" + encodedFileName + "\"");
        resp.setContentLength(pdfBytes.length);

        resp.getOutputStream().write(pdfBytes);
        resp.getOutputStream().flush();
    }
}
