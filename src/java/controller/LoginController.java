package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import org.mindrot.jbcrypt.BCrypt;
import model.User;

@WebServlet(name = "LoginController", urlPatterns = {"/login"})
public class LoginController extends HttpServlet {

    // ===== Helpers: nhận diện định dạng hash cũ/mới =====
    private static boolean isBcrypt(String s) {
        if (s == null) return false;
        return (s.startsWith("$2a$") || s.startsWith("$2b$") || s.startsWith("$2y$")) && s.length() >= 60;
    }

    private static boolean isMd5(String s) {
        return s != null && s.matches("^[a-fA-F0-9]{32}$");
    }

    private static String md5Hex(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] d = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : d) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) { return ""; }
    }

    // ===== Helpers: xử lý returnTo an toàn =====
    private static boolean isSafeReturnTo(String rt) {
        if (rt == null || rt.isBlank()) return false;
        String trimmed = rt.trim();

        // Chỉ chấp nhận đường dẫn TƯƠNG ĐỐI trong site (bắt đầu bằng 1 dấu '/')
        // Loại bỏ: schema://, //host, javascript:, data:, v.v.
        if (!trimmed.startsWith("/")) return false;
        if (trimmed.startsWith("//")) return false;
        return true;
    }

    private static String pickReturnTo(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        String p = req.getParameter("returnTo");
        if (!isSafeReturnTo(p)) p = null;

        String fromSession = (s != null) ? (String) s.getAttribute("returnTo") : null;
        if (!isSafeReturnTo(fromSession)) fromSession = null;

        // Ưu tiên param nếu hợp lệ, rồi tới session
        return (p != null) ? p : fromSession;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Lưu returnTo (nếu hợp lệ) để quay lại đúng trang sau login
        String rt = req.getParameter("returnTo");
        if (isSafeReturnTo(rt)) {
            req.getSession(true).setAttribute("returnTo", rt.trim());
        }
        req.getRequestDispatcher("login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        // Lấy returnTo trước khi đụng tới session (để có thể recreate session)
        String returnTo = pickReturnTo(req);

        // Lấy session cũ để dọn dẹp sau login
        HttpSession oldSession = req.getSession(false);

        String email = req.getParameter("email");
        String pass  = req.getParameter("password");

        try {
            UserDAO userDAO = new UserDAO();
            User user = userDAO.getUserByEmail(email);

            if (user == null) {
                req.setAttribute("error", "Email hoặc mật khẩu không đúng.");
                req.getRequestDispatcher("login.jsp").forward(req, resp);
                return;
            }

            String stored = user.getPasswordHash();
            boolean ok = false;

            if (isBcrypt(stored)) {
                try {
                    ok = BCrypt.checkpw(pass, stored);
                } catch (IllegalArgumentException badSalt) {
                    ok = false;
                }
            } else {
                // Di sản: plaintext hoặc MD5
                if (stored != null && stored.equals(pass)) {
                    ok = true;
                } else if (isMd5(stored) && stored.equalsIgnoreCase(md5Hex(pass))) {
                    ok = true;
                }
                // Nếu đăng nhập OK với di sản -> nâng cấp lên BCrypt
                if (ok) {
                    String newHash = BCrypt.hashpw(pass, BCrypt.gensalt(12));
                    userDAO.updatePasswordByID(user.getUserID(), newHash);
                    user.setPasswordHash(newHash);
                }
            }

            if (!ok) {
                req.setAttribute("error", "Email hoặc mật khẩu không đúng.");
                req.getRequestDispatcher("login.jsp").forward(req, resp);
                return;
            }

            // ==== Login thành công: chống session fixation ====
            if (oldSession != null) {
                oldSession.removeAttribute("returnTo");
                oldSession.invalidate();
            }
            HttpSession session = req.getSession(true);
            session.setAttribute("account", user);
            session.setMaxInactiveInterval(30 * 60); // 30 phút

            // Nếu có returnTo hợp lệ -> ưu tiên quay lại
            if (returnTo != null && !returnTo.isBlank()) {
                resp.sendRedirect(req.getContextPath() + returnTo);
                return;
            }

            // Nếu là Admin -> vào admin dashboard
            if ("Admin".equalsIgnoreCase(user.getRole())) {
                resp.sendRedirect(req.getContextPath() + "/admin");
                return;
            }

            // Mặc định về trang chủ
            resp.sendRedirect(req.getContextPath() + "/home");

        } catch (Exception ex) {
            ex.printStackTrace();
            req.setAttribute("error", "Hệ thống đang bận. Vui lòng thử lại sau.");
            req.getRequestDispatcher("login.jsp").forward(req, resp);
        }
    }
}
