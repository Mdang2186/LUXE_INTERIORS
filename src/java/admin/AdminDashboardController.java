package admin;

import dal.OrderDAO;
import dal.ProductDAO;
import dal.CategoryDAO;
import dal.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet(name="AdminDashboardController", urlPatterns={"/admin","/admin/","/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {
  @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    req.setAttribute("adminActive", "dashboard");

    ProductDAO pdao = new ProductDAO();
    CategoryDAO cdao = new CategoryDAO();
    OrderDAO odao = new OrderDAO();
    UserDAO udao = new UserDAO();

    // THAY ĐỔI: Thêm tham số 'null' cho brandName
    req.setAttribute("countProducts", pdao.countProducts(null, null, 0, 0, null));
    
    req.setAttribute("countCategories", cdao.countCategories());
    req.setAttribute("countOrders", odao.countAll());
    req.setAttribute("countUsers", udao.countAll());

    // doanh thu 7 ngày gần nhất
    Map<String, Double> rev = odao.revenueLastDays(7); // key: yyyy-MM-dd
    req.setAttribute("revLabels", new ArrayList<>(rev.keySet()));
    req.setAttribute("revValues", new ArrayList<>(rev.values()));

    // top 5 bán chạy
    req.setAttribute("topProducts", odao.topSellingProducts(5));

    req.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(req, resp);
  }
}