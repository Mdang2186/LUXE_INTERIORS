package controller;

import dal.UserDAO;
import model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

@WebServlet(name = "ChangePasswordController", urlPatterns = {"/change-password"})
public class ChangePasswordController extends HttpServlet {

    private static final int MIN_PASSWORD_LENGTH = 8;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // show change password page
        request.getRequestDispatcher("change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("account");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String oldPassword = safeTrim(request.getParameter("oldPassword"));
        String newPassword = safeTrim(request.getParameter("newPassword"));
        String reNewPassword = safeTrim(request.getParameter("re_newPassword"));

        // Basic validations
        if (oldPassword.isEmpty() || newPassword.isEmpty() || reNewPassword.isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ các trường.");
            request.getRequestDispatcher("change-password.jsp").forward(request, response);
            return;
        }

        if (!newPassword.equals(reNewPassword)) {
            request.setAttribute("error", "Mật khẩu mới không khớp!");
            request.getRequestDispatcher("change-password.jsp").forward(request, response);
            return;
        }

        if (newPassword.length() < MIN_PASSWORD_LENGTH) {
            request.setAttribute("error", "Mật khẩu mới phải có ít nhất " + MIN_PASSWORD_LENGTH + " ký tự.");
            request.getRequestDispatcher("change-password.jsp").forward(request, response);
            return;
        }

        // Verify old password using BCrypt
        String storedHash = currentUser.getPasswordHash();
        if (storedHash == null || storedHash.isEmpty() || !BCrypt.checkpw(oldPassword, storedHash)) {
            request.setAttribute("error", "Mật khẩu cũ không chính xác!");
            request.getRequestDispatcher("change-password.jsp").forward(request, response);
            return;
        }

        // Prevent reusing the same password (optional but helpful)
        if (BCrypt.checkpw(newPassword, storedHash)) {
            request.setAttribute("error", "Mật khẩu mới không được trùng với mật khẩu cũ!");
            request.getRequestDispatcher("change-password.jsp").forward(request, response);
            return;
        }

        // Hash new password and update DB
        String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        UserDAO userDAO = new UserDAO();
        boolean success;
        try {
            success = userDAO.updatePasswordByID(currentUser.getUserID(), newHash);
        } catch (Exception ex) {
            // log server-side (do not expose stack to user)
            ex.printStackTrace();
            success = false;
        }

        if (success) {
            // update session user
            currentUser.setPasswordHash(newHash);
            session.setAttribute("account", currentUser);
            request.setAttribute("success", "Đổi mật khẩu thành công!");
        } else {
            request.setAttribute("error", "Đã có lỗi xảy ra, vui lòng thử lại sau.");
        }

        request.getRequestDispatcher("change-password.jsp").forward(request, response);
    }

    private static String safeTrim(String s) {
        return s == null ? "" : s.trim();
    }
}
