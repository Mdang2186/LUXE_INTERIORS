package controller;

import dal.OrderDAO;
import model.Order;
import model.CartItem;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet(name = "OrderSuccessController", urlPatterns = {"/order-success"})
public class OrderSuccessController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String ctx = req.getContextPath();

        // Không có session => quay về lịch sử đơn
        if (session == null) {
            resp.sendRedirect(ctx + "/orders");
            return;
        }

        // === LẤY DATA TỪ CHECKOUT ===
        Order  sesOrder          = (Order)  session.getAttribute("lastOrder");
        @SuppressWarnings("unchecked")
        List<CartItem> cartItems = (List<CartItem>) session.getAttribute("lastOrderItems");
        Double depositObj        = (Double) session.getAttribute("lastOrderDeposit");
        Double remainingObj      = (Double) session.getAttribute("lastOrderRemaining");
        String ordersQrContent   = (String) session.getAttribute("lastOrderQrContent");

        Long   payAmountObj      = (Long)   session.getAttribute("lastOrderPaymentAmount");
        String paymentNote       = (String) session.getAttribute("lastOrderPaymentNote");
        String paymentQrUrl      = (String) session.getAttribute("lastOrderPaymentQrUrl");

        // Không có đơn trong session => quay về lịch sử
        if (sesOrder == null) {
            resp.sendRedirect(ctx + "/orders");
            return;
        }

        // === LẤY ĐƠN MỚI NHẤT TỪ DB (có items) ===
        OrderDAO odao = new OrderDAO();
        Order order = odao.getOrderByIdWithItems(sesOrder.getOrderID());
        if (order == null) {
            // fallback: dùng đơn trong session
            order = sesOrder;
        }

        double total     = order.getTotalAmount();
        double deposit   = (depositObj   != null) ? depositObj   : 0d;
        double remaining = (remainingObj != null) ? remainingObj : Math.max(0d, total - deposit);
        long   payAmount = (payAmountObj != null) ? payAmountObj
                                                 : Math.round(deposit > 0 ? deposit : total);

        // === QR tra cứu đơn hàng (link tới /orders) ===
        String ordersQrImgUrl = null;
        if (ordersQrContent != null && !ordersQrContent.isBlank()) {
            try {
                String encoded = URLEncoder.encode(ordersQrContent, StandardCharsets.UTF_8.toString());
                ordersQrImgUrl = "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=" + encoded;
            } catch (Exception e) {
                ordersQrImgUrl = "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=" + ordersQrContent;
            }
        }

        // === ĐẨY SANG JSP ===
        req.setAttribute("order",          order);
        req.setAttribute("cartItems",      cartItems);          // để show lại sản phẩm
        req.setAttribute("total",          total);
        req.setAttribute("deposit",        deposit);
        req.setAttribute("remaining",      remaining);
        req.setAttribute("paymentMethod",  order.getPaymentMethod());
        req.setAttribute("paymentAmount",  payAmount);
        req.setAttribute("paymentNote",    paymentNote);
        req.setAttribute("paymentQrUrl",   paymentQrUrl);       // ảnh VietQR thanh toán
        req.setAttribute("ordersQrImgUrl", ordersQrImgUrl);     // QR tra cứu đơn

        // === DỌN DATA 1 LẦN KHỎI SESSION (tránh F5 giữ dữ liệu cũ) ===
        session.removeAttribute("lastOrder");
        session.removeAttribute("lastOrderItems");
        session.removeAttribute("lastOrderDeposit");
        session.removeAttribute("lastOrderRemaining");
        session.removeAttribute("lastOrderQrContent");
        session.removeAttribute("lastOrderPaymentAmount");
        session.removeAttribute("lastOrderPaymentNote");
        session.removeAttribute("lastOrderPaymentQrUrl");

        req.getRequestDispatcher("order-success.jsp").forward(req, resp);
    }
}
