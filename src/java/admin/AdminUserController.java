package admin;

import dal.UserDAO;
import model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name="AdminUserController", urlPatterns={"/admin/users"})
public class AdminUserController extends HttpServlet {
  @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    req.setAttribute("adminActive","users");
    String q = req.getParameter("q");
    UserDAO udao = new UserDAO();
    List<User> users = udao.searchUsers(q);
    req.setAttribute("users", users);
    req.setAttribute("q", q);
    req.getRequestDispatcher("/WEB-INF/admin/users-list.jsp").forward(req, resp);
  }

  @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    String action = req.getParameter("action");
    UserDAO udao = new UserDAO();
    if ("role".equals(action)) {
      int id = Integer.parseInt(req.getParameter("id"));
      String role = req.getParameter("role");
      boolean ok = udao.updateRole(id, role);
      req.getSession().setAttribute(ok?"success":"error", ok? "Đã cập nhật vai trò.":"Thất bại.");
      resp.sendRedirect(req.getContextPath()+"/admin/users"); return;
    }
  }
}
