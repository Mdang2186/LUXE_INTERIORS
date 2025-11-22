package controller;

import Utils.EmailService;
import dal.UserDAO;
import model.User;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Date;
import java.util.Random;

/**
 * RegisterController (nâng cấp):
 * - Hash password bằng BCrypt ở đây trước khi lưu.
 * - Lưu tạm newUser + regCode + regExp + regEmail trong session.
 * - Hạn chế resend OTP (3 lần trong 10 phút).
 * - Trước khi insert lại kiểm tra email tồn tại (tránh race).
 */
@WebServlet(urlPatterns = {"/register"})
public class RegisterController extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final EmailService mailer = new EmailService();

    // resend limit
    private static final int MAX_RESEND = 3;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Nếu đang có phiên đăng ký dở (đã gửi OTP) thì hiển thị trang verify
        if (req.getSession().getAttribute("newUser") != null) {
            req.getRequestDispatcher("/verify-registration.jsp").forward(req, resp);
            return;
        }
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(true);

        // ----- RESEND OTP -----
        if ("1".equals(req.getParameter("resend"))) {
            String email = (String) session.getAttribute("regEmail");
            User newUser = (User) session.getAttribute("newUser");
            if (newUser == null || email == null) {
                req.setAttribute("error", "Phiên đăng ký đã hết hạn. Vui lòng đăng ký lại.");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }

            Integer resendCount = (Integer) session.getAttribute("regResendCount");
            Long lastSent = (Long) session.getAttribute("regLastSent");
            if (resendCount == null) resendCount = 0;
            // if resends exceed MAX or too frequent -> block
            if (resendCount >= MAX_RESEND) {
                req.setAttribute("error", "Bạn đã gửi lại mã quá nhiều lần. Vui lòng thử lại sau.");
                req.getRequestDispatcher("/verify-registration.jsp").forward(req, resp);
                return;
            }

            // create new otp and update counters
            String otp = genOtp();
            session.setAttribute("regCode", otp);
            session.setAttribute("regExp", System.currentTimeMillis() + 10 * 60_000);
            session.setAttribute("regResendCount", resendCount + 1);
            session.setAttribute("regLastSent", System.currentTimeMillis());

            boolean s = mailer.sendOtp(email, otp);
            if (!s) {
                req.setAttribute("error", "Không gửi được email OTP. Kiểm tra cấu hình SMTP.");
                req.getRequestDispatcher("/verify-registration.jsp").forward(req, resp);
                return;
            }

            req.setAttribute("email", email);
            req.setAttribute("info", "Đã gửi lại mã xác minh vào email.");
            req.getRequestDispatcher("/verify-registration.jsp").forward(req, resp);
            return;
        }

        // ----- STEP 2: VERIFY OTP -----
        String code = t(req.getParameter("code"));
        if (!code.isEmpty()) {
            if (!code.matches("\\d{6}")) {
                req.setAttribute("error", "Mã OTP phải gồm đúng 6 chữ số.");
                req.getRequestDispatcher("/verify-registration.jsp").forward(req, resp);
                return;
            }
            String regCode = (String) session.getAttribute("regCode");
            Long   regExp  = (Long)   session.getAttribute("regExp");
            User   newUser = (User)   session.getAttribute("newUser");
            String regEmail = (String) session.getAttribute("regEmail");

            if (newUser == null || regCode == null || regExp == null || regEmail == null) {
                req.setAttribute("error", "Phiên đăng ký đã hết hạn. Vui lòng đăng ký lại.");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }

            if (System.currentTimeMillis() > regExp) {
                req.setAttribute("error", "Mã OTP đã hết hạn. Vui lòng đăng ký lại.");
                // clear to force re-register
                session.removeAttribute("newUser");
                session.removeAttribute("regCode");
                session.removeAttribute("regExp");
                session.removeAttribute("regEmail");
                session.removeAttribute("regResendCount");
                session.removeAttribute("regLastSent");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }

            if (!regCode.equals(code)) {
                req.setAttribute("error", "Mã xác minh không đúng.");
                req.setAttribute("email", regEmail);
                req.getRequestDispatcher("/verify-registration.jsp").forward(req, resp);
                return;
            }

            // Final check: email not used (double-check to avoid race)
            try {
                if (userDAO.checkEmailExists(regEmail)) {
                    req.setAttribute("error", "Email đã được sử dụng. Vui lòng đăng nhập hoặc dùng email khác.");
                    // clear session
                    session.removeAttribute("newUser");
                    session.removeAttribute("regCode");
                    session.removeAttribute("regExp");
                    session.removeAttribute("regEmail");
                    session.removeAttribute("regResendCount");
                    session.removeAttribute("regLastSent");
                    req.getRequestDispatcher("/register.jsp").forward(req, resp);
                    return;
                }
            } catch (Exception ex) {
                // trong trường hợp DAO lỗi, trả lỗi chung
                ex.printStackTrace();
                req.setAttribute("error", "Lỗi hệ thống. Vui lòng thử lại sau.");
                req.getRequestDispatcher("/verify-registration.jsp").forward(req, resp);
                return;
            }

            // Lưu DB (UserDAO.registerUser phải insert passwordHash đã được set)
            boolean ok;
            try {
                ok = userDAO.registerUser(newUser);
            } catch (Exception ex) {
                ex.printStackTrace();
                ok = false;
            }

            if (!ok) {
                req.setAttribute("error", "Không thể tạo tài khoản lúc này. Thử lại sau.");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }

            // Clear session tạm
            session.removeAttribute("newUser");
            session.removeAttribute("regCode");
            session.removeAttribute("regExp");
            session.removeAttribute("regEmail");
            session.removeAttribute("regResendCount");
            session.removeAttribute("regLastSent");

            // (tuỳ chọn) gửi email chào mừng
            try {
                mailer.sendWelcome(newUser.getEmail(), newUser.getFullName());
            } catch (Exception e) {
                // không lỗi fatal nếu email không gửi được — log thôi
                e.printStackTrace();
            }

            req.setAttribute("success", "Đăng ký thành công. Mời đăng nhập.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        // ----- STEP 1: RECEIVE FORM & SEND OTP -----
        String fullName = t(req.getParameter("fullName"));
        String email    = t(req.getParameter("email")).toLowerCase();
        String pass     = t(req.getParameter("password"));
        String rePass   = t(req.getParameter("re_password"));

        // Basic validation
        if (fullName.isEmpty() || email.isEmpty() || pass.isEmpty() || rePass.isEmpty()) {
            req.setAttribute("error", "Vui lòng điền đầy đủ thông tin.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        if (!email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            req.setAttribute("error", "Email không hợp lệ.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        if (!pass.equals(rePass)) {
            req.setAttribute("error", "Xác nhận mật khẩu không khớp.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }
        if (pass.length() < 8) {
            req.setAttribute("error", "Mật khẩu phải có ít nhất 8 ký tự.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        // Check email exists early
        try {
            if (userDAO.checkEmailExists(email)) {
                req.setAttribute("error", "Email đã được sử dụng.");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            req.setAttribute("error", "Lỗi hệ thống. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        // Hash BCrypt (đồng bộ với LoginController)
        String hash = BCrypt.hashpw(pass, BCrypt.gensalt(10));

        User u = new User();
        u.setFullName(fullName);
        u.setEmail(email);
        u.setPasswordHash(hash);
        u.setRole("Customer");
        u.setCreatedAt(new Date());

        // generate OTP & store temp session
        String otp = genOtp();
        session.setAttribute("newUser", u);
        session.setAttribute("regCode", otp);
        session.setAttribute("regExp", System.currentTimeMillis() + 10 * 60_000);
        session.setAttribute("regEmail", email);
        session.setAttribute("regResendCount", 0);
        session.setAttribute("regLastSent", System.currentTimeMillis());

        boolean sent = mailer.sendOtp(email, otp);
        if (!sent) {
            // nếu gửi ko được, clear temp
            session.removeAttribute("newUser");
            session.removeAttribute("regCode");
            session.removeAttribute("regExp");
            session.removeAttribute("regEmail");
            session.removeAttribute("regResendCount");
            session.removeAttribute("regLastSent");

            req.setAttribute("error", "Không gửi được email OTP. Kiểm tra cấu hình SMTP (App Password).");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        req.setAttribute("email", email);
        req.setAttribute("info", "Đã gửi mã xác minh vào email. Vui lòng kiểm tra hộp thư (kể cả Spam). Mã có hiệu lực 10 phút.");
        req.getRequestDispatcher("/verify-registration.jsp").forward(req, resp);
    }

    private static String genOtp() {
        return String.format("%06d", new Random().nextInt(1_000_000));
    }
    private static String t(String s){ return s == null ? "" : s.trim(); }
}
