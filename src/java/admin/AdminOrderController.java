package admin;

import dal.OrderDAO;
import model.Order;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name="AdminOrderController", urlPatterns={"/admin/orders"})
public class AdminOrderController extends HttpServlet {
  @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    req.setAttribute("adminActive","orders");
    String action = req.getParameter("action");
    OrderDAO odao = new OrderDAO();

    if ("detail".equals(action)) {
      int id = Integer.parseInt(req.getParameter("id"));
      Order o = odao.getOrderByIdWithItems(id);
      req.setAttribute("order", o);
      req.getRequestDispatcher("/WEB-INF/admin/order-detail.jsp").forward(req, resp);
      return;
    }

    String status = req.getParameter("status");
    int page = 1;
    try{ page = Integer.parseInt(req.getParameter("page")); }catch(Exception ignored){}
    int size = 12;

    int total = odao.countByStatus(status);
    List<Order> orders = odao.getAllOrders(status, (page-1)*size, size);

    req.setAttribute("orders", orders);
    req.setAttribute("status", status);
    req.setAttribute("totalPages", (int)Math.ceil(total/(double)size));
    req.setAttribute("currentPage", page);
    req.getRequestDispatcher("/WEB-INF/admin/orders-list.jsp").forward(req, resp);
  }

  @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    String action = req.getParameter("action");
    OrderDAO odao = new OrderDAO();

    if ("status".equals(action)) {
      int id = Integer.parseInt(req.getParameter("id"));
      String status = req.getParameter("status");
      boolean ok = odao.updateStatus(id, status);
      req.getSession().setAttribute(ok?"success":"error", ok? "Đã cập nhật trạng thái.":"Cập nhật thất bại.");
      resp.sendRedirect(req.getContextPath()+"/admin/orders?action=detail&id="+id); return;
    }
  }
}
