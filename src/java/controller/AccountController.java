package controller;

import dal.UserDAO;
import model.User;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;

@WebServlet(name = "AccountController", urlPatterns = {"/account"})
public class AccountController extends HttpServlet {

    // ===== HẰNG SỐ TAB & ACTION =====
    private static final String TAB_PROFILE  = "profile";
    private static final String TAB_PASSWORD = "password";

    private static final String ACTION_UPDATE_PROFILE  = "update-profile";
    private static final String ACTION_CHANGE_PASSWORD = "change-password";

    // ========== GET ==========

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");
        String ctx = request.getContextPath();

        // Chưa đăng nhập -> lưu returnTo rồi ép login
        if (user == null) {
            session.setAttribute("returnTo", ctx + "/account");
            response.sendRedirect(ctx + "/login");
            return;
        }

        // CSRF token cho form POST (profile + password)
        String csrf = ensureCsrfToken(session);
        request.setAttribute("csrf", csrf);

        // tab đang mở (profile | password)
        String tab = n(request.getParameter("tab"));
        if (!TAB_PASSWORD.equals(tab)) {
            tab = TAB_PROFILE;
        }
        request.setAttribute("tab", tab);

        request.getRequestDispatcher("account.jsp").forward(request, response);
    }

    // ========== POST ==========

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User current = (User) session.getAttribute("account");
        String ctx = request.getContextPath();

        if (current == null) {
            session.setAttribute("returnTo", ctx + "/account");
            response.sendRedirect(ctx + "/login");
            return;
        }

        // Chống CSRF
        String tokenForm = n(request.getParameter("_csrf"));
        String tokenSess = (String) session.getAttribute("csrf");

        if (tokenForm.isEmpty() || tokenSess == null || !tokenForm.equals(tokenSess)) {
            // Token không hợp lệ -> tạo token mới luôn cho lần sau
            String newToken = genCsrf();
            session.setAttribute("csrf", newToken);
            request.setAttribute("csrf", newToken);

            request.setAttribute("error", "Phiên làm việc không hợp lệ. Vui lòng thử lại.");
            request.setAttribute("tab", TAB_PROFILE);
            request.getRequestDispatcher("account.jsp").forward(request, response);
            return;
        }

        String action = n(request.getParameter("action"));
        UserDAO userDAO = new UserDAO();

        try {
            switch (action) {

                // ===== Cập nhật thông tin cá nhân =====
                case ACTION_UPDATE_PROFILE: {
                    String fullName = n(request.getParameter("fullName"));
                    String phone    = n(request.getParameter("phone"));
                    String address  = n(request.getParameter("address"));

                    // Validate đơn giản
                    if (fullName.isEmpty()) {
                        request.setAttribute("error", "Họ tên không được để trống.");
                    } else if (!phone.isEmpty() && !phone.matches("^(0|\\+?84)\\d{8,10}$")) {
                        request.setAttribute("error", "Số điện thoại không hợp lệ.");
                    }

                    if (request.getAttribute("error") == null) {
                        current.setFullName(fullName);
                        current.setPhone(phone);
                        current.setAddress(address);

                        boolean ok = userDAO.updateUserProfile(current);
                        if (ok) {
                            // đồng bộ lại session
                            session.setAttribute("account", current);
                            request.setAttribute("success", "Cập nhật thông tin thành công.");
                        } else {
                            request.setAttribute("error", "Không thể cập nhật lúc này. Thử lại sau.");
                        }
                    }

                    request.setAttribute("tab", TAB_PROFILE);
                    break;
                }

                // ===== Đổi mật khẩu =====
                case ACTION_CHANGE_PASSWORD: {
                    String oldPwd = n(request.getParameter("oldPassword"));
                    String newPwd = n(request.getParameter("newPassword"));
                    String rePwd  = n(request.getParameter("re_newPassword"));

                    if (oldPwd.isEmpty() || newPwd.isEmpty() || rePwd.isEmpty()) {
                        request.setAttribute("error", "Vui lòng nhập đủ các trường.");
                    } else if (newPwd.length() < 6) {
                        request.setAttribute("error", "Mật khẩu mới tối thiểu 6 ký tự.");
                    } else if (!newPwd.equals(rePwd)) {
                        request.setAttribute("error", "Xác nhận mật khẩu không khớp.");
                    } else {
                        // Lấy user hiện tại từ DB để có PasswordHash mới nhất
                        User fresh = userDAO.getUserByEmail(current.getEmail());
                        if (fresh == null) {
                            request.setAttribute("error", "Không tìm thấy tài khoản.");
                        } else {
                            String hash = n(fresh.getPasswordHash());

                            boolean oldOk;
                            if (!hash.isEmpty() && hash.startsWith("$2")) {
                                // DB đã dùng BCrypt
                                oldOk = BCrypt.checkpw(oldPwd, hash);
                            } else {
                                // Fallback dự án cũ từng lưu plain
                                oldOk = oldPwd.equals(hash) || oldPwd.equals(n(current.getPasswordHash()));
                            }

                            if (!oldOk) {
                                request.setAttribute("error", "Mật khẩu hiện tại không đúng.");
                            } else {
                                String newHash = BCrypt.hashpw(newPwd, BCrypt.gensalt(10));
                                boolean ok = userDAO.updatePasswordByID(current.getUserID(), newHash);
                                if (ok) {
                                    current.setPasswordHash(newHash);
                                    session.setAttribute("account", current);
                                    request.setAttribute("success", "Đổi mật khẩu thành công.");
                                } else {
                                    request.setAttribute("error", "Không thể đổi mật khẩu lúc này.");
                                }
                            }
                        }
                    }

                    request.setAttribute("tab", TAB_PASSWORD);
                    break;
                }

                // ===== Action không hợp lệ =====
                default: {
                    request.setAttribute("error", "Hành động không hợp lệ.");
                    request.setAttribute("tab", TAB_PROFILE);
                }
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("error", "Hệ thống bận. Vui lòng thử lại.");
            request.setAttribute("tab", TAB_PROFILE);
        }

        // giữ lại CSRF cho lần submit sau
        request.setAttribute("csrf", session.getAttribute("csrf"));
        request.getRequestDispatcher("account.jsp").forward(request, response);
    }

    // ===== utils =====
    private static String n(String s) {
        return (s == null) ? "" : s.trim();
    }

    /** Đảm bảo trong session luôn có CSRF token, nếu chưa có thì tạo mới */
    private static String ensureCsrfToken(HttpSession session) {
        String csrf = (String) session.getAttribute("csrf");
        if (csrf == null || csrf.isEmpty()) {
            csrf = genCsrf();
            session.setAttribute("csrf", csrf);
        }
        return csrf;
    }

    private static String genCsrf() {
        byte[] b = new byte[24];
        new SecureRandom().nextBytes(b);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(b);
    }
}
