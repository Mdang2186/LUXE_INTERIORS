package controller;

import Utils.EmailService;
import dal.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.security.SecureRandom;
import org.mindrot.jbcrypt.BCrypt;

/**
 * PasswordResetController (2-step):
 *  - Step 1 (POST email): gửi OTP -> forward /verify-code.jsp
 *  - Step 2 (POST code + newPassword): verify OTP, hash new password, update DB, gửi email xác nhận
 *
 * IMPORTANT: UserDAO.updatePasswordByEmail(email, passwordHash) phải nhận passwordHash (đã hash).
 */
@WebServlet(urlPatterns = {"/password-reset"})
public class PasswordResetController extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final EmailService mailer = new EmailService();
    private static final SecureRandom SR = new SecureRandom();

    // Cấu hình OTP
    private static final long OTP_TTL_MS = 10 * 60_000L; // 10 phút
    private static final int MIN_PASSWORD_LENGTH = 8;

    // Giới hạn spam OTP trong 1 session
    private static final int MAX_OTP_REQUESTS_PER_SESSION = 5;       // tối đa 5 lần / session
    private static final long MIN_OTP_INTERVAL_MS = 60_000L;         // cách nhau ít nhất 60s

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(true);

        // Nếu có code => bước 2: verify OTP + đổi mật khẩu
        String code = trim(req.getParameter("code"));
        String newPassword = trim(req.getParameter("newPassword"));

        if (!code.isEmpty()) {
            // ======= BƯỚC 2: XÁC MINH OTP + ĐỔI MẬT KHẨU =======
            String expect = (String) session.getAttribute("resetCode");
            Long   exp    = (Long)   session.getAttribute("resetExp");
            String email  = (String) session.getAttribute("emailToReset");

            if (expect == null || exp == null || email == null) {
                // session expired or missing
                clearResetSession(session);
                req.setAttribute("error", "Phiên xác minh đã hết hạn. Vui lòng yêu cầu mã mới.");
                req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
                return;
            }

            if (System.currentTimeMillis() > exp) {
                clearResetSession(session);
                req.setAttribute("error", "Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới.");
                req.setAttribute("email", email);
                req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
                return;
            }

            if (!expect.equals(code)) {
                req.setAttribute("error", "Mã OTP không đúng.");
                req.setAttribute("email", email);
                req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
                return;
            }

            // validate new password
            if (newPassword.length() < MIN_PASSWORD_LENGTH) {
                req.setAttribute("error", "Mật khẩu mới phải từ " + MIN_PASSWORD_LENGTH + " ký tự trở lên.");
                req.setAttribute("email", email);
                req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
                return;
            }

            // hash password BEFORE updating DB
            String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());

            boolean ok;
            try {
                ok = userDAO.updatePasswordByEmail(email, newHash); // DAO must accept hashed password
            } catch (Exception ex) {
                ex.printStackTrace();
                ok = false;
            }

            if (!ok) {
                req.setAttribute("error", "Đổi mật khẩu thất bại. Thử lại sau.");
                req.setAttribute("email", email);
                req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
                return;
            }

            // success: clear session reset flags
            clearResetSession(session);

            // send confirmation email (non-blocking recommended; here simple sync call)
            try {
                String subject = "Xác nhận thay đổi mật khẩu - LUXE INTERIORS";
                String body = "Xin chào,\n\nMật khẩu tài khoản của bạn tại LUXE INTERIORS đã được thay đổi thành công.\n"
                        + "Nếu không phải bạn thực hiện, vui lòng liên hệ hỗ trợ ngay lập tức.\n\n"
                        + "Trân trọng,\nLUXE INTERIORS Team";
                mailer.sendPlainText(email, subject, body);
            } catch (Exception e) {
                // don't fail the flow if mail sending fails — just log
                System.err.println("Warning: failed to send password-change confirmation email to "
                        + email + " : " + e.getMessage());
            }

            req.setAttribute("success", "Đổi mật khẩu thành công. Mời đăng nhập.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // ======= BƯỚC 1: NHẬN EMAIL VÀ GỬI OTP =======
        String email = trim(req.getParameter("email")).toLowerCase();
        if (email.isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập email.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Chống spam: giới hạn số lần yêu cầu OTP trong 1 session
        long now = System.currentTimeMillis();
        Long lastReq = (Long) session.getAttribute("resetLastTime");
        Integer count = (Integer) session.getAttribute("resetReqCount");
        if (count == null) count = 0;

        if (lastReq != null && now - lastReq < MIN_OTP_INTERVAL_MS) {
            req.setAttribute("error", "Bạn vừa yêu cầu mã OTP, vui lòng thử lại sau ít phút.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }
        if (count >= MAX_OTP_REQUESTS_PER_SESSION) {
            req.setAttribute("error", "Bạn đã yêu cầu mã OTP quá nhiều lần. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        // check existence (nếu muốn bảo mật hơn: có thể giữ message chung, không nói rõ "Email không tồn tại")
        boolean exists = false;
        try {
            exists = userDAO.checkEmailExists(email);
        } catch (Throwable t) {
            // fallback
            exists = userDAO.getUserByEmail(email) != null;
        }

        if (!exists) {
            // Phiên bản hiện tại: thông báo rõ cho người dùng
            req.setAttribute("error", "Email không tồn tại.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;

            /*
            // Phiên bản bảo mật hơn (tuỳ bạn):
            // Không phân biệt tồn tại / không tồn tại để tránh lộ danh sách email.
            // session.removeAttribute("resetCode");
            // session.removeAttribute("resetExp");
            // session.removeAttribute("emailToReset");
            // req.setAttribute("info",
            //        "Nếu email tồn tại trong hệ thống, chúng tôi đã gửi mã OTP đến email đó. Vui lòng kiểm tra hộp thư (kể cả Spam).");
            // req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            // return;
            */
        }

        // generate OTP securely
        String otp = genOtp();
        long expTime = now + OTP_TTL_MS;

        // store in session
        session.setAttribute("resetCode", otp);
        session.setAttribute("resetExp", expTime);
        session.setAttribute("emailToReset", email);
        session.setAttribute("resetLastTime", now);
        session.setAttribute("resetReqCount", count + 1);

        // send OTP email
        boolean sent = false;
        try {
            sent = mailer.sendOtp(email, otp); // existing method you had
        } catch (Exception e) {
            e.printStackTrace();
            sent = false;
        }

        if (!sent) {
            // cleanup
            clearResetSession(session);
            req.setAttribute("error", "Không gửi được email OTP. Kiểm tra cấu hình SMTP.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("email", email);
        req.setAttribute("info", "Đã gửi mã OTP vào email. Vui lòng kiểm tra hộp thư (cả Spam). Mã có hiệu lực trong 10 phút.");
        req.getRequestDispatcher("/verify-code.jsp").forward(req, resp);
    }

    private static String genOtp() {
        // secure 6-digit numeric OTP
        int num = SR.nextInt(1_000_000);
        return String.format("%06d", num);
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private static void clearResetSession(HttpSession session) {
        session.removeAttribute("resetCode");
        session.removeAttribute("resetExp");
        session.removeAttribute("emailToReset");
        // không xoá resetLastTime/resetReqCount để vẫn giữ limit trong cùng session
    }
}
