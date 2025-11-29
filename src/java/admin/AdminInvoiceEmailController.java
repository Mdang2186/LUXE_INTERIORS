package admin;

import Utils.EmailService;
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

@WebServlet(
        name = "AdminInvoiceEmailController",
        urlPatterns = {
                "/admin/orders/invoice-email",   // đường dẫn cũ
                "/admin/order-invoice-email"     // có thể dùng trong dashboard / order detail
        }
)
public class AdminInvoiceEmailController extends HttpServlet {

    private OrderDAO odao;
    private UserDAO udao;
    private EmailService email;

    @Override
    public void init() throws ServletException {
        super.init();
        odao   = new OrderDAO();
        udao   = new UserDAO();
        email  = new EmailService();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setCharacterEncoding("UTF-8");

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

        // Lấy đơn + user
        Order order = odao.getOrderByIdWithItems(id);
        if (order == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND,
                    "Không tìm thấy đơn hàng.");
            return;
        }

        User user = udao.getUserById(order.getUserID());
        if (user == null || user.getEmail() == null || user.getEmail().trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Đơn hàng không có email khách hàng.");
            return;
        }

        // Tạo file PDF hóa đơn
        byte[] pdfBytes;
        try {
            pdfBytes = InvoicePdfUtil.generateInvoicePdf(order, user);
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Lỗi tạo file PDF hóa đơn.", e);
        }

        if (pdfBytes == null || pdfBytes.length == 0) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Không tạo được nội dung PDF.");
            return;
        }

        // Gửi email bằng template đẹp trong EmailService
        boolean ok = email.sendInvoicePdf(
                user.getEmail(),
                user.getFullName() != null ? user.getFullName() : "Quý khách",
                order,
                pdfBytes
        );

        // Trả kết quả (dùng tốt cho AJAX hoặc form đơn giản)
        resp.setContentType("text/plain; charset=UTF-8");
        resp.getWriter().write(ok ? "Đã gửi hóa đơn qua email." : "Gửi hóa đơn thất bại.");
    }

    // Nếu muốn hỗ trợ GET để test nhanh trên trình duyệt:
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doPost(req, resp);
    }
}
