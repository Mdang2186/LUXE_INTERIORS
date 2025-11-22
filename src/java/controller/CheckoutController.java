package controller;

import Utils.EmailService;
import dal.OrderDAO;
import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import model.CartItem;
import model.Order;
import model.OrderItem;
import model.Product;
import model.User;

@WebServlet(name = "CheckoutController", urlPatterns = {"/checkout"})
public class CheckoutController extends HttpServlet {

    // ================== CẤU HÌNH ĐẶT CỌC & TÀI KHOẢN NHẬN TIỀN ==================

    /**
     * Quy ước:
     * - COD: Đặt cọc 50%, còn lại trả khi giao hàng.
     * - CARD / MOMO / VNPAY: Thanh toán 100% online.
     */
    private static final double DEPOSIT_RATE_COD   = 0.5;  // COD: đặt cọc 50%
    private static final double DEPOSIT_RATE_CARD  = 1.0;  // Thẻ / chuyển khoản: 100%
    private static final double DEPOSIT_RATE_MOMO  = 1.0;  // Momo: 100%
    private static final double DEPOSIT_RATE_VNPAY = 1.0;  // VNPAY: 100%

    // Thông tin tài khoản nhận tiền (dùng cho VietQR)
    // TODO: ĐỔI LẠI CHO ĐÚNG TÀI KHOẢN THẬT CỦA BẠN
    private static final String BANK_BIN          = "970422";                     // VD: MB Bank
    private static final String BANK_ACCOUNT_NO   = "0123456789";                 // Số tài khoản
    private static final String BANK_ACCOUNT_NAME = "LUXE INTERIORS CO., LTD";    // Tên chủ TK

    private final EmailService mailer = new EmailService();

    // ======================= GET: hiển thị trang checkout =======================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession ss = req.getSession(true);
        User user = (User) ss.getAttribute("account");
        String ctx = req.getContextPath();

        // Chưa đăng nhập -> ép login
        if (user == null) {
            String returnUrl = "/checkout";
            String sel = req.getParameter("sel");
            if (sel != null && !sel.isBlank()) {
                returnUrl += "?sel=" + URLEncoder.encode(sel, StandardCharsets.UTF_8);
            }
            ss.setAttribute("returnUrl", returnUrl);
            resp.sendRedirect(ctx + "/login");
            return;
        }

        @SuppressWarnings("unchecked")
        List<CartItem> cart = (List<CartItem>) ss.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(ctx + "/cart");
            return;
        }

        // Lọc item đã chọn (sel = "1,2,3"), nếu không có thì lấy hết
        Set<Integer> chosen = parseSel(req.getParameter("sel"));
        List<CartItem> items = new ArrayList<>();
        for (CartItem it : cart) {
            Product p = it.getProduct();
            if (chosen.isEmpty() || chosen.contains(p.getProductID())) {
                items.add(it);
            }
        }
        if (items.isEmpty()) {
            resp.sendRedirect(ctx + "/cart");
            return;
        }

        double sub = 0;
        for (CartItem it : items) {
            sub += it.getTotalPrice();
        }

        req.setAttribute("sel", req.getParameter("sel")); // giữ lại khi POST
        req.setAttribute("items", items);
        req.setAttribute("subTotal", sub);
        req.setAttribute("grandTotal", sub);

        // Gợi ý data user nếu request chưa set (khi quay lại doPost error, ta đã set sẵn)
        if (req.getAttribute("fullName") == null) {
            req.setAttribute("fullName", user.getFullName());
        }
        if (req.getAttribute("address") == null) {
            req.setAttribute("address", user.getAddress());
        }
        if (req.getAttribute("phone") == null) {
            req.setAttribute("phone", user.getPhone());
        }

        req.getRequestDispatcher("checkout.jsp").forward(req, resp);
    }

    // ============================= POST: tạo đơn ================================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession ss = req.getSession(true);
        User user = (User) ss.getAttribute("account");
        String ctx = req.getContextPath();

        if (user == null) {
            ss.setAttribute("returnUrl", "/checkout");
            resp.sendRedirect(ctx + "/login");
            return;
        }

        @SuppressWarnings("unchecked")
        List<CartItem> cart = (List<CartItem>) ss.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(ctx + "/cart");
            return;
        }

        // Lọc item được chọn
        Set<Integer> chosen = parseSel(req.getParameter("sel"));
        List<CartItem> items = new ArrayList<>();
        for (CartItem it : cart) {
            if (chosen.isEmpty() || chosen.contains(it.getProduct().getProductID())) {
                items.add(it);
            }
        }
        if (items.isEmpty()) {
            req.setAttribute("error", "Chưa chọn sản phẩm hợp lệ.");
            doGet(req, resp);
            return;
        }

        // Lấy dữ liệu form
        String fullName = n(req.getParameter("fullName"));
        String phone    = n(req.getParameter("phone"));
        String address  = n(req.getParameter("address"));
        String payment  = n(req.getParameter("paymentMethod"));
        String note     = n(req.getParameter("note"));

        // Giữ lại để khi báo lỗi quay lại form không mất
        req.setAttribute("fullName", fullName);
        req.setAttribute("phone", phone);
        req.setAttribute("address", address);

        if (fullName.isEmpty() || phone.isEmpty() || address.isEmpty()) {
            req.setAttribute("error", "Vui lòng điền đầy đủ họ tên, số điện thoại và địa chỉ.");
            req.setAttribute("selectedPayment", payment);
            doGet(req, resp);
            return;
        }

        // --- Kiểm tra tồn kho mới nhất từ DB ---
        ProductDAO pdao = new ProductDAO();
        for (CartItem it : items) {
            Product p = pdao.getProductByID(it.getProduct().getProductID());
            if (p == null) {
                req.setAttribute("error", "Sản phẩm không tồn tại (id=" + it.getProduct().getProductID() + ").");
                req.setAttribute("selectedPayment", payment);
                doGet(req, resp);
                return;
            }
            if (it.getQuantity() > p.getStock()) {
                req.setAttribute("error", "Sản phẩm \"" + p.getProductName()
                        + "\" hiện chỉ còn " + p.getStock() + " đơn vị. Vui lòng điều chỉnh giỏ hàng.");
                req.setAttribute("selectedPayment", payment);
                doGet(req, resp);
                return;
            }
        }

        // --- Payment-specific fields ---
        String cardNumber = n(req.getParameter("cardNumber"));
        String bankName   = n(req.getParameter("bankName"));
        String momoPhone  = n(req.getParameter("momoPhone"));
        String vnpayTxn   = n(req.getParameter("vnpayTxn"));

        if (payment == null || payment.isEmpty()) {
            payment = "COD";
        }

        // Validate theo từng phương thức
        switch (payment.toUpperCase()) {
            case "CARD":
                if (cardNumber.isEmpty() || bankName.isEmpty()) {
                    req.setAttribute("error", "Vui lòng cung cấp số thẻ / số tài khoản và tên ngân hàng.");
                    req.setAttribute("selectedPayment", payment);
                    doGet(req, resp);
                    return;
                }
                break;
            case "MOMO":
                if (momoPhone.isEmpty()) {
                    req.setAttribute("error", "Vui lòng cung cấp số điện thoại Momo để thanh toán.");
                    req.setAttribute("selectedPayment", payment);
                    doGet(req, resp);
                    return;
                }
                break;
            case "VNPAY":
                // tùy luồng tích hợp, hiện tạm thời không bắt buộc mã giao dịch
                break;
            case "COD":
            default:
                // không yêu cầu thêm
                break;
        }

        // --- Tính tổng tiền và tạo list OrderItem ---
        double total = 0;
        List<OrderItem> oi = new ArrayList<>();
        for (CartItem it : items) {
            total += it.getTotalPrice();
            OrderItem row = new OrderItem();
            row.setProductID(it.getProduct().getProductID());
            row.setQuantity(it.getQuantity());
            row.setUnitPrice(it.getProduct().getPrice());
            oi.add(row);
        }

        // --- Tính đặt cọc / còn lại ---
        double depositAmount   = calcDeposit(payment, total);
        double remainingAmount = roundMoney(total - depositAmount);

        // --- Gộp note: note khách + note thanh toán / đặt cọc ---
        String paymentNote  = buildPaymentNote(payment, depositAmount, remainingAmount,
                                               cardNumber, bankName, momoPhone, vnpayTxn);
        String combinedNote = combineNote(note, paymentNote);

        // --- Tạo Order ---
        Order order = new Order();
        order.setUserID(user.getUserID());
        order.setTotalAmount(total);
        order.setPaymentMethod(payment.isEmpty() ? "COD" : payment);
        order.setShippingAddress(fullName + " - " + phone + ", " + address);
        order.setNote(combinedNote);
        order.setItems(oi);

        boolean ok = new OrderDAO().createOrder(order);
        if (!ok) {
            // Re-check tồn kho để trả lỗi cụ thể nếu có
            StringBuilder sb = new StringBuilder();
            boolean foundIssue = false;
            for (CartItem it : items) {
                Product p = pdao.getProductByID(it.getProduct().getProductID());
                if (p == null) {
                    sb.append("Sản phẩm không tồn tại: id=").append(it.getProduct().getProductID()).append(". ");
                    foundIssue = true;
                } else if (it.getQuantity() > p.getStock()) {
                    sb.append("Sản phẩm \"").append(p.getProductName()).append("\" chỉ còn ")
                      .append(p.getStock()).append(" đơn vị. ");
                    foundIssue = true;
                }
            }
            if (foundIssue) {
                req.setAttribute("error", sb.toString().trim());
            } else {
                req.setAttribute("error", "Có lỗi khi tạo đơn hàng. Vui lòng thử lại.");
            }
            req.setAttribute("selectedPayment", payment);
            doGet(req, resp);
            return;
        }

        // ================== TẠO QR THANH TOÁN (VietQR) ==================
        // Số tiền cần thanh toán qua chuyển khoản:
        // - COD: số tiền đặt cọc (50%)
        // - CARD: thanh toán đủ 100%
        long payAmount = Math.round(depositAmount > 0 ? depositAmount : total);

        // Nội dung chuyển khoản: LUXE <TYPE> <OrderID> <Phone> <Name rút gọn>
        String transferNote = buildTransferNote(
                order, fullName, phone, payment,
                payAmount, depositAmount, remainingAmount
        );

        String paymentQrUrl = null;

        // QR VietQR dùng cho chuyển khoản ngân hàng (COD & CARD)
        switch (payment.toUpperCase()) {
            case "COD":
            case "CARD":
                paymentQrUrl = buildVietQrUrl(payAmount, transferNote);
                break;
            default:
                // MOMO / VNPAY: tùy bạn tích hợp thêm, ở đây tạm thời không sinh VietQR
                break;
        }

        // ================== QR LINK TỚI LỊCH SỬ ĐƠN (giữ nguyên) ==================
        String requestURL  = req.getRequestURL().toString();   // vd: http://localhost:8080/Nhom2_FurniShop/checkout
        String requestURI  = req.getRequestURI();              //      /Nhom2_FurniShop/checkout
        String contextPath = req.getContextPath();             //      /Nhom2_FurniShop
        String baseUrl     = requestURL.replace(requestURI, contextPath);

        // Hiện tại: QR dẫn tới trang lịch sử đơn hàng.
        String qrContent = baseUrl + "/orders";

        // --- Gửi email xác nhận (nếu EmailService dùng qrContent) ---
        try {
            mailer.sendOrderConfirmationWithQr(
                    user.getEmail(),
                    user.getFullName(),
                    order,
                    depositAmount,
                    remainingAmount,
                    payment,
                    qrContent
            );
        } catch (Exception e) {
            System.err.println("Warning: failed to send order confirmation email: " + e.getMessage());
        }

        // --- Lưu thông tin đơn gần nhất vào session cho /order-success ---
        ss.setAttribute("lastOrder", order);
        ss.setAttribute("lastOrderItems", items);              // dùng CartItem để JSP hiển thị tiện hơn
        ss.setAttribute("lastOrderDeposit", depositAmount);
        ss.setAttribute("lastOrderRemaining", remainingAmount);

        // Thông tin QR thanh toán VietQR (thật, theo từng đơn)
        ss.setAttribute("lastOrderPaymentAmount", payAmount);     // long
        ss.setAttribute("lastOrderPaymentNote", transferNote);    // String
        ss.setAttribute("lastOrderPaymentQrUrl", paymentQrUrl);   // String (ảnh VietQR, có thể null)

        // (Giữ lại QR link tới lịch sử đơn nếu bạn còn dùng chỗ khác)
        ss.setAttribute("lastOrderQrContent", qrContent);

        // --- Dọn giỏ: xoá các item đã đặt ---
        if (chosen.isEmpty()) {
            cart.clear();
        } else {
            cart.removeIf(it -> chosen.contains(it.getProduct().getProductID()));
        }
        recalcSessionTotals(ss, cart);

        // Chuyển sang trang "Đặt hàng thành công"
        // Nếu bạn KHÔNG dùng OrderSuccessController, hãy đảm bảo /order-success trỏ tới JSP.
        resp.sendRedirect(ctx + "/order-success");
    }

    // =============================== Helpers ===================================

    private static Set<Integer> parseSel(String sel) {
        Set<Integer> ids = new HashSet<>();
        if (sel == null || sel.isBlank()) return ids;
        for (String s : sel.split(",")) {
            try {
                ids.add(Integer.parseInt(s.trim()));
            } catch (Exception ignore) { }
        }
        return ids;
    }

    private static void recalcSessionTotals(HttpSession ss, List<CartItem> cart) {
        double total = 0;
        int size = 0;
        for (CartItem it : cart) {
            total += it.getTotalPrice();
            size += it.getQuantity();
        }
        ss.setAttribute("totalAmount", total);
        ss.setAttribute("cartSize", size);
        ss.setAttribute("cart", cart);
    }

    private static String n(String s) {
        return (s == null) ? "" : s.trim();
    }

    private static double calcDeposit(String method, double total) {
        if (total <= 0) return 0;
        if (method == null) method = "";
        double rate;
        switch (method.toUpperCase()) {
            case "CARD":
                rate = DEPOSIT_RATE_CARD;
                break;
            case "MOMO":
                rate = DEPOSIT_RATE_MOMO;
                break;
            case "VNPAY":
                rate = DEPOSIT_RATE_VNPAY;
                break;
            case "COD":
            default:
                rate = DEPOSIT_RATE_COD;
                break;
        }
        return roundMoney(total * rate);
    }

    private static double roundMoney(double v) {
        // VND: làm tròn tới đơn vị
        return Math.round(v);
    }

    private static String maskCard(String cardNumber) {
        if (cardNumber == null) return "";
        String digits = cardNumber.replaceAll("\\D+", "");
        if (digits.length() <= 4) return "****";
        String last4 = digits.substring(digits.length() - 4);
        return "**** **** **** " + last4;
    }

    /**
     * Ghi chú thanh toán để lưu trong Order.note
     */
    private static String buildPaymentNote(String payment, double deposit, double remain,
                                           String cardNumber, String bankName,
                                           String momoPhone, String vnpayTxn) {

        StringBuilder sb = new StringBuilder();
        String method = (payment == null || payment.isEmpty()) ? "COD" : payment;

        sb.append("[Thanh toán] Phương thức: ").append(method);

        if (deposit <= 0) {
            sb.append(" | Thanh toán toàn bộ khi nhận hàng");
        } else if (remain <= 0) {
            sb.append(" | Thanh toán online 100%: ").append((long) deposit).append(" VND");
        } else {
            sb.append(" | Đặt cọc: ").append((long) deposit).append(" VND");
            sb.append(" | Còn lại: ").append((long) remain).append(" VND");
        }

        switch (method.toUpperCase()) {
            case "CARD":
                if (bankName != null && !bankName.isBlank()) {
                    sb.append(" | Ngân hàng: ").append(bankName.trim());
                }
                if (cardNumber != null && !cardNumber.isBlank()) {
                    sb.append(" | Số thẻ: ").append(maskCard(cardNumber));
                }
                break;
            case "MOMO":
                if (momoPhone != null && !momoPhone.isBlank()) {
                    sb.append(" | SĐT Momo: ").append(momoPhone.trim());
                }
                break;
            case "VNPAY":
                if (vnpayTxn != null && !vnpayTxn.isBlank()) {
                    sb.append(" | Mã giao dịch VNPAY: ").append(vnpayTxn.trim());
                } else {
                    sb.append(" | Thanh toán qua cổng VNPAY");
                }
                break;
            case "COD":
            default:
                break;
        }
        return sb.toString();
    }

    private static String combineNote(String userNote, String paymentNote) {
        if (userNote == null || userNote.isBlank()) {
            return paymentNote;
        }
        return userNote.trim() + " \n---\n" + paymentNote;
    }

    /**
     * Sinh nội dung chuyển khoản cho VietQR:
     * LUXE <TYPE> <orderID> <phone> <name rút gọn>
     */
    private static String buildTransferNote(Order order,
                                            String fullName,
                                            String phone,
                                            String payment,
                                            long amount,
                                            double deposit,
                                            double remaining) {

        String methodCode;
        switch (payment == null ? "" : payment.toUpperCase()) {
            case "COD":
                methodCode = (deposit > 0 && remaining > 0) ? "COD50" : "COD";
                break;
            case "CARD":
                methodCode = "CARD100";
                break;
            case "MOMO":
                methodCode = "MOMO100";
                break;
            case "VNPAY":
                methodCode = "VNPAY100";
                break;
            default:
                methodCode = "PAY";
        }

        String safePhone = phone == null ? "" : phone.replaceAll("\\D+", "");
        String safeName  = fullName == null ? "" :
                fullName.toUpperCase().replaceAll("[^A-Z0-9 ]", "");
        if (safeName.length() > 18) {
            safeName = safeName.substring(0, 18);
        }

        StringBuilder sb = new StringBuilder();
        sb.append("LUXE ")
          .append(methodCode)
          .append(" ")
          .append(order.getOrderID());

        if (!safePhone.isEmpty()) {
            sb.append(" ").append(safePhone);
        }
        if (!safeName.isEmpty()) {
            sb.append(" ").append(safeName);
        }
        return sb.toString();
    }

    /**
     * Sinh URL ảnh VietQR từ bin + số tài khoản + số tiền + nội dung.
     * Ảnh này có thể nhúng trực tiếp vào <img src="..."> trên JSP.
     */
    private static String buildVietQrUrl(long amount, String addInfo) {
        String infoEnc = URLEncoder.encode(addInfo, StandardCharsets.UTF_8);
        String nameEnc = URLEncoder.encode(BANK_ACCOUNT_NAME, StandardCharsets.UTF_8);

        // Format: https://img.vietqr.io/image/{bin}-{account}-qr_only.png?amount=...&addInfo=...&accountName=...
        return String.format(
                "https://img.vietqr.io/image/%s-%s-qr_only.png?amount=%d&addInfo=%s&accountName=%s",
                BANK_BIN,
                BANK_ACCOUNT_NO,
                amount,
                infoEnc,
                nameEnc
        );
    }
}
