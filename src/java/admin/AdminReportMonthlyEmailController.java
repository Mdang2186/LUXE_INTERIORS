package admin;

import Utils.EmailService;
import Utils.MonthlyReportExcelUtil;
import dal.AdminStatsDAO;
import dal.AdminStatsDAO.CategoryRevenue;
import dal.AdminStatsDAO.BrandRevenue;
import dal.AdminStatsDAO.CancellationStats;
import dal.AdminStatsDAO.HourStat;
import dal.AdminStatsDAO.MonthlyRevenue;
import dal.AdminStatsDAO.NewCustomer;
import dal.AdminStatsDAO.RegionStat;
import dal.AdminStatsDAO.RetentionStats;
import dal.AdminStatsDAO.VipCustomer;

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
import java.util.List;

/**
 * Báo cáo tháng (preview + gửi email kèm Excel).
 * GET  /admin/report-monthly-email : xem + form gửi
 * POST /admin/report-monthly-email : gửi email
 */
@WebServlet(name = "AdminReportMonthlyEmailController",
        urlPatterns = {"/admin/report-monthly-email"})
public class AdminReportMonthlyEmailController extends HttpServlet {

    private AdminStatsDAO stats;

    @Override
    public void init() throws ServletException {
        super.init();
        stats = new AdminStatsDAO();
    }

    // ======================= PREVIEW =========================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        LocalDate today = LocalDate.now();
        int year  = parseIntOrDefault(req.getParameter("year"), today.getYear());
        int month = parseIntOrDefault(req.getParameter("month"), today.getMonthValue());

        if (month < 1) month = 1;
        if (month > 12) month = 12;

        YearMonth ym = YearMonth.of(year, month);
        LocalDate from = ym.atDay(1);
        LocalDate to   = ym.atEndOfMonth();

        req.setAttribute("year", year);
        req.setAttribute("month", month);
        req.setAttribute("fromDate", from.toString());
        req.setAttribute("toDate", to.toString());

        Date sqlFrom = Date.valueOf(from);
        Date sqlTo   = Date.valueOf(to);

        // 1. Doanh thu / lợi nhuận tháng
        BigDecimal revenueMonth = stats.getRevenueForMonth(year, month);
        BigDecimal profitMonth  = stats.getProfitForMonth(year, month);
        req.setAttribute("revenueMonth", revenueMonth);
        req.setAttribute("profitMonth", profitMonth);

        // 2. Theo danh mục / brand
        List<CategoryRevenue> catRevenues = stats.getRevenueByCategory(sqlFrom, sqlTo);
        List<BrandRevenue> brandRevenues  = stats.getRevenueByBrand(sqlFrom, sqlTo);
        req.setAttribute("catRevenues", catRevenues);
        req.setAttribute("brandRevenues", brandRevenues);

        // 3. VIP & khách mới
        List<VipCustomer> vipTop   = stats.getTopVipCustomersInMonth(year, month, 10);
        List<NewCustomer> newCusts = stats.getNewCustomersInMonth(year, month);
        req.setAttribute("vipTop", vipTop);
        req.setAttribute("newCustomers", newCusts);

        // 4. Xu hướng năm
        List<MonthlyRevenue> revenueYear = stats.getMonthlyRevenue(year);
        List<MonthlyRevenue> profitYear  = stats.getMonthlyProfit(year);
        req.setAttribute("revenueYear", revenueYear);
        req.setAttribute("profitYear", profitYear);

        // 5. Theo giờ, vùng, hủy đơn, retention
        List<HourStat> hourStats      = stats.getOrdersByHour();
        List<RegionStat> regionStats  = stats.getOrdersByRegion();
        CancellationStats cancelStats = stats.getCancellationStats();
        RetentionStats retentionStats = stats.getRetentionStats();

        req.setAttribute("hourStats", hourStats);
        req.setAttribute("regionStats", regionStats);
        req.setAttribute("cancelStats", cancelStats);
        req.setAttribute("retentionStats", retentionStats);

        req.getRequestDispatcher("/WEB-INF/admin/report-monthly-email.jsp")
                .forward(req, resp);
    }

    // ======================= SEND EMAIL ======================
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        LocalDate today = LocalDate.now();
        int year  = parseIntOrDefault(req.getParameter("year"), today.getYear());
        int month = parseIntOrDefault(req.getParameter("month"), today.getMonthValue());

        String emailTo = req.getParameter("emailTo");
        req.setAttribute("emailTo", emailTo);

        if (emailTo == null || emailTo.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập email người nhận.");
            doGet(req, resp);
            return;
        }

        if (month < 1) month = 1;
        if (month > 12) month = 12;

        // Lấy dữ liệu để build Excel
        BigDecimal revenueMonth = stats.getRevenueForMonth(year, month);
        BigDecimal profitMonth  = stats.getProfitForMonth(year, month);
        List<VipCustomer> vipTop   = stats.getTopVipCustomersInMonth(year, month, 50);
        List<NewCustomer> newCusts = stats.getNewCustomersInMonth(year, month);
        List<MonthlyRevenue> revenueYear = stats.getMonthlyRevenue(year);
        List<MonthlyRevenue> profitYear  = stats.getMonthlyProfit(year);

        byte[] excelBytes = MonthlyReportExcelUtil.buildMonthlyReportWorkbook(
                year,
                month,
                revenueMonth,
                profitMonth,
                vipTop,
                newCusts,
                revenueYear,
                profitYear
        );

        if (excelBytes == null) {
            req.setAttribute("error", "Không tạo được file Excel báo cáo tháng.");
            doGet(req, resp);
            return;
        }

        EmailService emailService = new EmailService();

        String subject = String.format("Báo cáo doanh thu tháng %02d/%d - FurniShop", month, year);
        StringBuilder body = new StringBuilder();
        body.append("<p>Chào anh/chị,</p>")
                .append("<p>Đính kèm là file Excel <b>Báo cáo tháng ")
                .append(String.format("%02d/%d", month, year))
                .append("</b> của hệ thống FurniShop.</p>")
                .append("<ul>")
                .append("<li>Doanh thu tháng: <b>").append(revenueMonth).append(" VND</b></li>")
                .append("<li>Lợi nhuận ước tính: <b>").append(profitMonth).append(" VND</b></li>")
                .append("<li>Số khách VIP trong tháng: <b>")
                .append(vipTop != null ? vipTop.size() : 0)
                .append("</b></li>")
                .append("<li>Số khách hàng mới trong tháng: <b>")
                .append(newCusts != null ? newCusts.size() : 0)
                .append("</b></li>")
                .append("</ul>")
                .append("<p>Trân trọng,<br/>Hệ thống FurniShop</p>");

        boolean ok = emailService.sendWithAttachment(
                emailTo.trim(),
                subject,
                body.toString(),
                String.format("report-%d-%02d.xlsx", year, month),
                excelBytes,
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        );

        req.setAttribute("sent", ok);
        doGet(req, resp);
    }

    private int parseIntOrDefault(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }
}
