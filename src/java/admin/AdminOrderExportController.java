package admin;

import dal.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Order;
import Utils.ExcelExportUtil;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet(name = "AdminOrderExportController",
        urlPatterns = {"/admin/orders/export-excel"})
public class AdminOrderExportController extends HttpServlet {

    private OrderDAO odao;

    @Override
    public void init() throws ServletException {
        super.init();
        odao = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Order> orders = odao.getAllOrdersForExport();

        String fileName = "orders.xlsx";
        String headerValue = "attachment; filename=\"" +
                URLEncoder.encode(fileName, StandardCharsets.UTF_8) + "\"";

        resp.setContentType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        );
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Content-Disposition", headerValue);

        try {
            ExcelExportUtil.exportOrders(orders, resp.getOutputStream());
        } catch (Exception ex) {
            ex.printStackTrace();
            if (!resp.isCommitted()) {
                resp.reset();
                resp.setContentType("text/plain; charset=UTF-8");
                resp.getWriter().println("Lỗi khi xuất Excel đơn hàng: " + ex.getMessage());
            }
        }
    }
}
