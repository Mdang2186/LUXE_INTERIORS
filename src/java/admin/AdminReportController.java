package admin;

import dal.AdminStatsDAO;
import dal.AdminStatsDAO.BrandRevenue;
import dal.AdminStatsDAO.HourStat;
import dal.AdminStatsDAO.VipCustomer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

/**
 * AdminReportController
 *  - Xuất các báo cáo dạng Excel:
 *    + type=vip-excel      : Top KH VIP (toàn thời gian)
 *    + type=brand-excel    : Doanh thu theo thương hiệu (from/to)
 *    + type=hours-excel    : Doanh thu theo khung giờ trong ngày
 *
 *  Được map cả /admin/report và /admin/report-excel để khớp với các link JSP.
 */
@WebServlet(
        name = "AdminReportController",
        urlPatterns = {"/admin/report", "/admin/report-excel"}
)
public class AdminReportController extends HttpServlet {

    private AdminStatsDAO stats;

    @Override
    public void init() throws ServletException {
        super.init();
        stats = new AdminStatsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String type = req.getParameter("type");
        if (type == null || type.isBlank()) {
            // Không có type -> redirect về dashboard
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        switch (type) {
            case "vip-excel":
                exportVipExcel(req, resp);
                break;
            case "brand-excel":
                exportBrandExcel(req, resp);
                break;
            case "hours-excel":
                exportHoursExcel(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    // ========================================================================
    // 1. Top KH VIP (toàn thời gian)
    // ========================================================================
    private void exportVipExcel(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        int limit = parseIntOrDefault(req.getParameter("limit"), 100);
        if (limit <= 0) limit = 100;

        List<VipCustomer> vipList = stats.getTopVipCustomers(limit);

        try (Workbook wb = new XSSFWorkbook()) {

            Sheet sheet = wb.createSheet("VipCustomers");
            int rowIdx = 0;

            // Header style
            CellStyle headerStyle = createHeaderStyle(wb);
            CellStyle moneyStyle  = createMoneyStyle(wb);

            Row header = sheet.createRow(rowIdx++);
            String[] titles = {"UserID", "Họ tên", "Email", "Số đơn", "Tổng chi tiêu"};
            for (int i = 0; i < titles.length; i++) {
                Cell c = header.createCell(i);
                c.setCellValue(titles[i]);
                c.setCellStyle(headerStyle);
            }

            if (vipList != null) {
                for (VipCustomer v : vipList) {
                    Row r = sheet.createRow(rowIdx++);
                    r.createCell(0).setCellValue(v.getUserId());
                    r.createCell(1).setCellValue(v.getFullName());
                    r.createCell(2).setCellValue(v.getEmail());
                    r.createCell(3).setCellValue(v.getOrderCount());
                    Cell totalCell = r.createCell(4);
                    BigDecimal amount = v.getTotalSpent() == null ? BigDecimal.ZERO : v.getTotalSpent();
                    totalCell.setCellValue(amount.doubleValue());
                    totalCell.setCellStyle(moneyStyle);
                }
            }

            for (int i = 0; i < titles.length; i++) sheet.autoSizeColumn(i);

            String fileName = "vip-customers.xlsx";
            writeWorkbookToResponse(wb, resp, fileName);
        }
    }

    // ========================================================================
    // 2. Doanh thu theo thương hiệu (from/to)
    // ========================================================================
    private void exportBrandExcel(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        LocalDate today = LocalDate.now();
        LocalDate fromDate = parseDateOrDefault(req.getParameter("from"), today.minusDays(30));
        LocalDate toDate   = parseDateOrDefault(req.getParameter("to"),   today);

        if (fromDate.isAfter(toDate)) {
            LocalDate tmp = fromDate;
            fromDate = toDate;
            toDate = tmp;
        }

        List<BrandRevenue> list = stats.getRevenueByBrand(
                Date.valueOf(fromDate),
                Date.valueOf(toDate)
        );

        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("BrandRevenue");
            int rowIdx = 0;

            CellStyle headerStyle = createHeaderStyle(wb);
            CellStyle moneyStyle  = createMoneyStyle(wb);

            Row header = sheet.createRow(rowIdx++);
            String[] titles = {"Thương hiệu", "Doanh thu", "Số đơn"};
            for (int i = 0; i < titles.length; i++) {
                Cell c = header.createCell(i);
                c.setCellValue(titles[i]);
                c.setCellStyle(headerStyle);
            }

            if (list != null) {
                for (BrandRevenue br : list) {
                    Row r = sheet.createRow(rowIdx++);
                    r.createCell(0).setCellValue(br.getBrandName());
                    Cell revCell = r.createCell(1);
                    BigDecimal rev = br.getRevenue() == null ? BigDecimal.ZERO : br.getRevenue();
                    revCell.setCellValue(rev.doubleValue());
                    revCell.setCellStyle(moneyStyle);
                    r.createCell(2).setCellValue(br.getOrderCount());
                }
            }

            for (int i = 0; i < titles.length; i++) sheet.autoSizeColumn(i);

            String fileName = String.format("brand-revenue-%s_to_%s.xlsx", fromDate, toDate);
            writeWorkbookToResponse(wb, resp, fileName);
        }
    }

    // ========================================================================
    // 3. Doanh thu theo khung giờ
    // ========================================================================
    private void exportHoursExcel(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        List<HourStat> list = stats.getOrdersByHour();

        try (Workbook wb = new XSSFWorkbook()) {
            Sheet sheet = wb.createSheet("RevenueByHour");
            int rowIdx = 0;

            CellStyle headerStyle = createHeaderStyle(wb);
            CellStyle moneyStyle  = createMoneyStyle(wb);

            Row header = sheet.createRow(rowIdx++);
            String[] titles = {"Giờ", "Số đơn", "Doanh thu"};
            for (int i = 0; i < titles.length; i++) {
                Cell c = header.createCell(i);
                c.setCellValue(titles[i]);
                c.setCellStyle(headerStyle);
            }

            if (list != null) {
                for (HourStat h : list) {
                    Row r = sheet.createRow(rowIdx++);
                    r.createCell(0).setCellValue(h.getHour());
                    r.createCell(1).setCellValue(h.getOrderCount());
                    Cell cRev = r.createCell(2);
                    BigDecimal rev = h.getRevenue() == null ? BigDecimal.ZERO : h.getRevenue();
                    cRev.setCellValue(rev.doubleValue());
                    cRev.setCellStyle(moneyStyle);
                }
            }

            for (int i = 0; i < titles.length; i++) sheet.autoSizeColumn(i);

            String fileName = "revenue-hours.xlsx";
            writeWorkbookToResponse(wb, resp, fileName);
        }
    }

    // ========================================================================
    // Helpers
    // ========================================================================
    private void writeWorkbookToResponse(Workbook wb, HttpServletResponse resp, String fileName)
            throws IOException {

        resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
        try (OutputStream os = resp.getOutputStream()) {
            wb.write(os);
            os.flush();
        }
    }

    private CellStyle createHeaderStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(true);
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.LIGHT_YELLOW.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderBottom(BorderStyle.THIN);
        return style;
    }

    private CellStyle createMoneyStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        DataFormat df = wb.createDataFormat();
        style.setDataFormat(df.getFormat("#,##0"));
        return style;
    }

    private int parseIntOrDefault(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }

    private LocalDate parseDateOrDefault(String s, LocalDate def) {
        try {
            return (s == null || s.isBlank()) ? def : LocalDate.parse(s.trim());
        } catch (Exception e) {
            return def;
        }
    }
}
