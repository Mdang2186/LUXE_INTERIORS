package controller;

import dal.SubscriberDAO; // Thêm import DAO
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import Utils.EmailService; // Thêm import EmailService

import java.io.IOException;
import java.net.URI;
import java.util.regex.Pattern;

@WebServlet(name = "SubscribeController", urlPatterns = {"/subscribe"})
public class SubscribeController extends HttpServlet {
    private static final Pattern EMAIL_RX =
            Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    // Khởi tạo DAO và EmailService
    private final SubscriberDAO subscriberDAO = new SubscriberDAO();
    private final EmailService emailService = new EmailService();
    // Email admin để nhận thông báo
    private final String adminEmail = "jejangwangminh@gmail.com"; // (Email trong EmailService của bạn)

    private String safeReferer(String referer) {
        try {
            URI uri = new URI(referer);
            // chỉ cho phép quay lại cùng host/context
            return referer;
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String email = req.getParameter("email");
        String referer = req.getHeader("Referer");

        if (email == null || !EMAIL_RX.matcher(email).matches()) {
            req.getSession().setAttribute("error", "Email không hợp lệ.");
        } else {
            // --- BẮT ĐẦU CẬP NHẬT LOGIC ---
            try {
                // 1. Lưu vào Database
                subscriberDAO.insert(email);

                // 2. Gửi email xác nhận cho người dùng
                emailService.sendSubscriptionConfirmation(email);
                
                // 3. Gửi thông báo cho admin
                emailService.sendSubscriptionNotification(adminEmail, email);

                // 4. Đặt thông báo thành công
                req.getSession().setAttribute("success", "Đã đăng ký nhận ưu đãi. Vui lòng kiểm tra email!");

            } catch (Exception e) {
                e.printStackTrace();
                req.getSession().setAttribute("error", "Có lỗi xảy ra. Vui lòng thử lại.");
            }
            // --- KẾT THÚC CẬP NHẬT ---
        }

        String back = safeReferer(referer);
        if (back != null) {
            resp.sendRedirect(back);
        } else {
            resp.sendRedirect(req.getContextPath() + "/home");
        }
    }
}