package admin;

import Utils.ExcelExportUtil;
import dal.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import model.Order;

@WebServlet(name = "AdminOrderExportController",
        urlPatterns = {"/admin/orders/export-excel"})
public class AdminOrderExportController extends HttpServlet {

    private OrderDAO odao;

    @Override
    public void init() throws ServletException {
        odao = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idRaw = req.getParameter("id");
        List<Order> orders = new ArrayList<>();

        if (idRaw != null && !idRaw.isBlank()) {
            try {
                int id = Integer.parseInt(idRaw);
                Order o = odao.getOrderByIdWithItems(id);
                if (o != null) orders.add(o);
            } catch (Exception ignored) { }
        } else {
            // tất cả đơn
            orders = odao.getAllOrders(null, 0, Integer.MAX_VALUE);
        }

        String fileName;
        if (orders.size() == 1) {
            fileName = "order-" + orders.get(0).getOrderID() + ".xlsx";
        } else {
            fileName = "orders-all.xlsx";
        }

        resp.setContentType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        resp.setHeader("Content-Disposition",
                "attachment; filename=\"" +
                        URLEncoder.encode(fileName, StandardCharsets.UTF_8) + "\"");

        try {
            ExcelExportUtil.exportOrders(orders, resp.getOutputStream());
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(500, "Không thể xuất Excel.");
        }
    }
}
