package admin;

import dal.AdminStatsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Dashboard Admin:
 *  - Thống kê số lượng: user, product, order, review, contact
 *  - Tồn kho: sắp hết, hết hàng, danh sách tồn kho thấp
 *  - Biểu đồ doanh thu lọc theo khoảng ngày
 *  - Biểu đồ trạng thái đơn hàng
 *  - Biểu đồ doanh thu theo danh mục
 *  - Biểu đồ user mới theo tháng
 *  - Top sản phẩm bán chạy
 */
@WebServlet(name = "AdminDashboardController",
        urlPatterns = {"/admin", "/admin/", "/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {

    private AdminStatsDAO stats;

    @Override
    public void init() throws ServletException {
        super.init();
        stats = new AdminStatsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setAttribute("adminActive", "dashboard");

        // ================= 1. Thống kê tổng quan =================
        req.setAttribute("countUsers", stats.countUsers());
        req.setAttribute("countProducts", stats.countProducts());
        req.setAttribute("countOrders", stats.countOrders());
        req.setAttribute("sumRevenueDone", stats.sumRevenueDone());
        req.setAttribute("countReviews", stats.countReviews());
        req.setAttribute("countContacts", stats.countContacts());

        // ================= 2. Tồn kho (inventory) =================
        int lowStockThreshold = 5;  // ngưỡng cảnh báo tồn kho thấp
        req.setAttribute("lowStockThreshold", lowStockThreshold);
        req.setAttribute("countLowStock", stats.countLowStock(lowStockThreshold));
        req.setAttribute("countOutOfStock", stats.countOutOfStock());
        req.setAttribute("lowStockProducts", stats.getLowStockProducts(lowStockThreshold));

        // ================= 3. Doanh thu theo thời gian =================
        // Lọc theo from/to, mặc định 7 ngày gần nhất
        String fromStr = req.getParameter("from");
        String toStr = req.getParameter("to");

        LocalDate today = LocalDate.now();
        LocalDate fromDate;
        LocalDate toDate;

        if (fromStr == null || fromStr.isBlank()
                || toStr == null || toStr.isBlank()) {
            // Mặc định: 7 ngày gần nhất
            toDate = today;
            fromDate = today.minusDays(6);
        } else {
            try {
                fromDate = LocalDate.parse(fromStr);
                toDate = LocalDate.parse(toStr);
                // Nếu from > to -> đảo lại
                if (fromDate.isAfter(toDate)) {
                    LocalDate tmp = fromDate;
                    fromDate = toDate;
                    toDate = tmp;
                }
            } catch (Exception e) {
                // Nếu parse lỗi -> fallback 7 ngày gần nhất
                toDate = today;
                fromDate = today.minusDays(6);
            }
        }

        req.setAttribute("from", fromDate.toString());
        req.setAttribute("to", toDate.toString());

        List<AdminStatsDAO.RevenuePoint> revenuePoints =
                stats.getRevenueByDateRange(Date.valueOf(fromDate), Date.valueOf(toDate));

        List<String> revLabels = new ArrayList<>();
        List<BigDecimal> revValues = new ArrayList<>();
        BigDecimal totalRevenueRange = BigDecimal.ZERO;

        for (AdminStatsDAO.RevenuePoint rp : revenuePoints) {
            revLabels.add(rp.getDate());      // yyyy-MM-dd
            revValues.add(rp.getTotal());
            if (rp.getTotal() != null) {
                totalRevenueRange = totalRevenueRange.add(rp.getTotal());
            }
        }
        req.setAttribute("revLabels", revLabels);
        req.setAttribute("revValues", revValues);
        req.setAttribute("totalRevenueRange", totalRevenueRange);

        // ================= 4. Đơn hàng theo trạng thái =================
        List<AdminStatsDAO.StatusCount> statusCounts = stats.countOrdersByStatus();
        List<String> statusLabels = new ArrayList<>();
        List<Integer> statusValues = new ArrayList<>();

        for (AdminStatsDAO.StatusCount sc : statusCounts) {
            statusLabels.add(sc.getStatus());
            statusValues.add(sc.getCount());
        }
        req.setAttribute("statusLabels", statusLabels);
        req.setAttribute("statusValues", statusValues);

        // ================= 5. Doanh thu theo danh mục =================
        List<AdminStatsDAO.CategoryRevenue> catRevenues =
                stats.getRevenueByCategory(Date.valueOf(fromDate), Date.valueOf(toDate));
        List<String> catLabels = new ArrayList<>();
        List<BigDecimal> catValues = new ArrayList<>();

        for (AdminStatsDAO.CategoryRevenue cr : catRevenues) {
            catLabels.add(cr.getCategoryName());
            catValues.add(cr.getRevenue());
        }
        req.setAttribute("catLabels", catLabels);
        req.setAttribute("catValues", catValues);

        // ================= 6. User mới theo tháng =================
        String yearStr = req.getParameter("year");
        int year;
        if (yearStr == null || yearStr.isBlank()) {
            year = today.getYear();
        } else {
            try {
                year = Integer.parseInt(yearStr);
            } catch (NumberFormatException e) {
                year = today.getYear();
            }
        }
        req.setAttribute("year", year);

        List<AdminStatsDAO.MonthlyCount> userMonths = stats.getNewUsersByMonth(year);
        List<String> userMonthLabels = new ArrayList<>();
        List<Integer> userMonthValues = new ArrayList<>();
        for (AdminStatsDAO.MonthlyCount mc : userMonths) {
            userMonthLabels.add(mc.getMonth());   // "2025-01"
            userMonthValues.add(mc.getCount());
        }
        req.setAttribute("userMonthLabels", userMonthLabels);
        req.setAttribute("userMonthValues", userMonthValues);

        // ================= 7. Top sản phẩm bán chạy =================
        req.setAttribute("topProducts", stats.getTopSellingProducts(5));

        // ================= 8. Forward tới JSP =================
        req.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(req, resp);
    }
}
