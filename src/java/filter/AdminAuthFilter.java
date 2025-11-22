package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

@WebFilter(urlPatterns = {"/admin/*"})
public class AdminAuthFilter implements Filter {
    @Override public void init(FilterConfig filterConfig) {}
    @Override public void destroy() {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpSession session = request.getSession(false);

        User account = (session == null) ? null : (User) session.getAttribute("account");
        boolean isAdmin = account != null && account.getRole() != null
                && account.getRole().equalsIgnoreCase("Admin");

        if (!isAdmin) {
            // nhớ contextPath kẻo lệch route
            request.setAttribute("error", "Bạn không có quyền truy cập trang quản trị.");
            request.getRequestDispatcher("/login.jsp").forward(request, res);
            return;
        }
        chain.doFilter(req, res);
    }
}
