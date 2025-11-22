package controller;

import dal.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Collections;
import java.util.List;
import model.Order;
import model.User;

@WebServlet(name = "OrderHistoryController", urlPatterns = {"/orders"})
public class OrderHistoryController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false); // không auto tạo
        User user = session == null ? null : (User) session.getAttribute("account");
        String ctx = request.getContextPath();

        // ÉP ĐĂNG NHẬP + LƯU RETURN URL
        if (user == null) {
            // lưu returnUrl để redirect về sau khi login
            if (session == null) session = request.getSession(true);
            session.setAttribute("returnUrl", "/orders");
            response.sendRedirect(ctx + "/login");
            return;
        }

        try {
            OrderDAO orderDAO = new OrderDAO();
            // nếu muốn filter trạng thái từ query param: ?status=Delivered
            String statusFilter = request.getParameter("status");
            List<Order> orderList;
            if (statusFilter == null || statusFilter.isBlank()) {
                orderList = orderDAO.getOrdersByUserIdWithDetails(user.getUserID());
            } else {
                // nếu chưa có DAO filter by status, lọc ở Controller (nhẹ)
                List<Order> all = orderDAO.getOrdersByUserIdWithDetails(user.getUserID());
                orderList = all.stream()
                        .filter(o -> statusFilter.equalsIgnoreCase(o.getStatus()))
                        .toList();
                request.setAttribute("statusFilter", statusFilter);
            }

            request.setAttribute("orderList", orderList == null ? Collections.emptyList() : orderList);
            request.getRequestDispatcher("orders.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Không tải được lịch sử đơn hàng. Vui lòng thử lại sau.");
            request.setAttribute("orderList", Collections.emptyList());
            request.getRequestDispatcher("orders.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Giữ behavior hiện tại: chuyển về GET (xử lý idempotent)
        doGet(request, response);
    }
}
