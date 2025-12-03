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
import java.time.YearMonth;
import java.util.*;

import model.Product;  // để JSP dùng ProductID, ProductName, Stock

/**
 * Dashboard Admin
 */
@WebServlet(
        name = "AdminDashboardController",
        urlPatterns = {"/admin", "/admin/", "/admin/dashboard"}
)
public class AdminDashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private AdminStatsDAO stats;

    private static final List<String> STATUS_FLOW = Arrays.asList(
            "Pending", "Confirmed", "Packing", "Shipping", "Done", "Canceled"
    );

    @Override
    public void init() throws ServletException {
        super.init();
        stats = new AdminStatsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // active sidebar
        req.setAttribute("adminActive", "dashboard");

        /* ========== 1. KPI tổng quan ========== */
        req.setAttribute("countUsers",     stats.countUsers());
        req.setAttribute("countProducts",  stats.countProducts());
        req.setAttribute("countOrders",    stats.countOrders());
        req.setAttribute("sumRevenueDone", stats.sumRevenueDone());
        req.setAttribute("countReviews",   stats.countReviews());
        req.setAttribute("countContacts",  stats.countContacts());

        /* ========== 2. Tồn kho ========== */
        int lowStockThreshold = 5;
        req.setAttribute("lowStockThreshold", lowStockThreshold);
        req.setAttribute("countLowStock",   stats.countLowStock(lowStockThreshold));
        req.setAttribute("countOutOfStock", stats.countOutOfStock());

        // LẤY LIST SẢN PHẨM TỒN KHO THẤP TỪ AdminStatsDAO
        List<Product> lowStockProducts = stats.getLowStockProducts(lowStockThreshold);
        req.setAttribute("lowStockProducts", lowStockProducts);

        /* ========== 3. Doanh thu theo ngày ========== */
        LocalDate today = LocalDate.now();
        LocalDate[] range = resolveDateRange(
                req.getParameter("from"),
                req.getParameter("to"),
                6,
                today
        );
        LocalDate fromDate = range[0];
        LocalDate toDate   = range[1];

        req.setAttribute("from", fromDate.toString());
        req.setAttribute("to",   toDate.toString());

        List<AdminStatsDAO.RevenuePoint> revenuePoints =
                stats.getRevenueByDateRange(Date.valueOf(fromDate), Date.valueOf(toDate));

        Map<String, BigDecimal> revenueMap = new HashMap<>();
        if (revenuePoints != null) {
            for (AdminStatsDAO.RevenuePoint rp : revenuePoints) {
                if (rp == null) continue;
                BigDecimal v = rp.getTotal() == null ? BigDecimal.ZERO : rp.getTotal();
                revenueMap.put(rp.getDate(), v);
            }
        }

        List<String> revLabels = new ArrayList<>();
        List<BigDecimal> revValues = new ArrayList<>();
        BigDecimal totalRevenueRange = BigDecimal.ZERO;

        LocalDate cursor = fromDate;
        while (!cursor.isAfter(toDate)) {
            String key = cursor.toString();
            BigDecimal val = revenueMap.getOrDefault(key, BigDecimal.ZERO);
            revLabels.add(key);
            revValues.add(val);
            totalRevenueRange = totalRevenueRange.add(val);
            cursor = cursor.plusDays(1);
        }

        req.setAttribute("revLabels", revLabels);
        req.setAttribute("revValues", revValues);
        req.setAttribute("totalRevenueRange", totalRevenueRange);

        /* ========== 4. Đơn hàng theo trạng thái ========== */
        List<AdminStatsDAO.StatusCount> statusCounts = stats.countOrdersByStatus();

        Map<String, Integer> statusMap = new LinkedHashMap<>();
        for (String s : STATUS_FLOW) {
            statusMap.put(s, 0);
        }
        int otherCount = 0;

        if (statusCounts != null) {
            for (AdminStatsDAO.StatusCount sc : statusCounts) {
                if (sc == null) continue;
                String canonical = canonicalStatus(sc.getStatus());
                int c = sc.getCount();
                if (canonical == null) {
                    otherCount += c;
                } else {
                    statusMap.put(canonical, statusMap.get(canonical) + c);
                }
            }
        }

        List<String> statusLabels = new ArrayList<>();
        List<Integer> statusValues = new ArrayList<>();
        for (Map.Entry<String, Integer> e : statusMap.entrySet()) {
            statusLabels.add(e.getKey());
            statusValues.add(e.getValue());
        }
        if (otherCount > 0) {
            statusLabels.add("Other");
            statusValues.add(otherCount);
        }
        req.setAttribute("statusLabels", statusLabels);
        req.setAttribute("statusValues", statusValues);

        /* ========== 5. Doanh thu theo danh mục ========== */
        List<AdminStatsDAO.CategoryRevenue> catRevenues =
                stats.getRevenueByCategory(Date.valueOf(fromDate), Date.valueOf(toDate));

        List<String> catLabels = new ArrayList<>();
        List<BigDecimal> catValues = new ArrayList<>();
        if (catRevenues != null) {
            for (AdminStatsDAO.CategoryRevenue cr : catRevenues) {
                if (cr == null) continue;
                catLabels.add(cr.getCategoryName());
                catValues.add(
                        cr.getRevenue() == null ? BigDecimal.ZERO : cr.getRevenue()
                );
            }
        }
        req.setAttribute("catLabels", catLabels);
        req.setAttribute("catValues", catValues);

        /* ========== 6. User mới theo tháng ========== */
        int year = resolveYear(req.getParameter("year"), today.getYear());
        req.setAttribute("year", year);

        List<AdminStatsDAO.MonthlyCount> userMonths = stats.getNewUsersByMonth(year);
        Map<String, Integer> userMonthMap = new HashMap<>();
        if (userMonths != null) {
            for (AdminStatsDAO.MonthlyCount mc : userMonths) {
                if (mc == null) continue;
                userMonthMap.put(mc.getMonth(), mc.getCount());
            }
        }

        List<String> userMonthLabels = new ArrayList<>();
        List<Integer> userMonthValues = new ArrayList<>();
        for (int m = 1; m <= 12; m++) {
            YearMonth ym = YearMonth.of(year, m);
            String key = ym.toString();
            userMonthLabels.add(key);
            userMonthValues.add(userMonthMap.getOrDefault(key, 0));
        }
        req.setAttribute("userMonthLabels", userMonthLabels);
        req.setAttribute("userMonthValues", userMonthValues);

        /* ========== 7. Top sản phẩm bán chạy ========== */
        req.setAttribute("topProducts", stats.getTopSellingProducts(5));

        /* ========== 8. Forward JSP ========== */
        req.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp")
           .forward(req, resp);
    }

    // ---------- helpers ----------
    private LocalDate[] resolveDateRange(String fromStr,
                                         String toStr,
                                         int defaultDaysBack,
                                         LocalDate today) {
        LocalDate fromDate;
        LocalDate toDate;

        if (fromStr == null || fromStr.isBlank()
                || toStr == null || toStr.isBlank()) {
            toDate = today;
            fromDate = today.minusDays(defaultDaysBack);
        } else {
            try {
                fromDate = LocalDate.parse(fromStr.trim());
                toDate   = LocalDate.parse(toStr.trim());
                if (fromDate.isAfter(toDate)) {
                    LocalDate tmp = fromDate;
                    fromDate = toDate;
                    toDate   = tmp;
                }
            } catch (Exception ex) {
                toDate = today;
                fromDate = today.minusDays(defaultDaysBack);
            }
        }
        return new LocalDate[]{fromDate, toDate};
    }

    private int resolveYear(String yearStr, int currentYear) {
        if (yearStr == null || yearStr.isBlank()) return currentYear;
        try {
            return Integer.parseInt(yearStr.trim());
        } catch (NumberFormatException ex) {
            return currentYear;
        }
    }

    private String canonicalStatus(String s) {
        if (s == null) return null;
        String x = s.trim().toLowerCase();
        switch (x) {
            case "pending":   return "Pending";
            case "confirmed": return "Confirmed";
            case "packing":   return "Packing";
            case "shipping":
            case "shipped":   return "Shipping";
            case "done":
            case "delivered": return "Done";
            case "canceled":
            case "cancelled": return "Canceled";
            default:          return null;
        }
    }
}
