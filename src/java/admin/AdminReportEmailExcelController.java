package admin;

import Utils.EmailService;
import dal.AdminStatsDAO;
import dal.AdminStatsDAO.VipCustomer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * Gửi email đính kèm Excel danh sách KH VIP.
 * GET  /admin/report-email-excel  : form + preview
 * POST /admin/report-email-excel  : gửi email
 */
@WebServlet(name = "AdminReportEmailExcelController",
        urlPatterns = {"/admin/report-email-excel"})
public class AdminReportEmailExcelController extends HttpServlet {

    private AdminStatsDAO stats;

    @Override
    public void init() throws ServletException {
        super.init();
        stats = new AdminStatsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int limit = parseIntOrDefault(req.getParameter("limit"), 50);
        if (limit <= 0) limit = 50;

        List<VipCustomer> vipList = stats.getTopVipCustomers(limit);

        req.setAttribute("limit", limit);
        req.setAttribute("vipList", vipList);

        req.getRequestDispatcher("/WEB-INF/admin/report-email-excel.jsp")
                .forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String emailTo = req.getParameter("emailTo");
        int limit = parseIntOrDefault(req.getParameter("limit"), 50);
        if (limit <= 0) limit = 50;

        req.setAttribute("limit", limit);
        req.setAttribute("emailTo", emailTo);

        if (emailTo == null || emailTo.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập email người nhận.");
            doGet(req, resp);
            return;
        }

        List<VipCustomer> vipList = stats.getTopVipCustomers(limit);
        req.setAttribute("vipList", vipList);

        byte[] excelBytes = buildVipExcel(vipList);
        if (excelBytes == null) {
            req.setAttribute("error", "Không tạo được file Excel.");
            doGet(req, resp);
            return;
        }

        EmailService emailService = new EmailService();
        int year = LocalDate.now().getYear();
        String subject = "Danh sách khách hàng VIP - FurniShop";

        StringBuilder body = new StringBuilder();
        body.append("<p>Chào anh/chị,</p>")
                .append("<p>Đính kèm là file Excel danh sách <b>khách hàng VIP</b> của hệ thống FurniShop.</p>")
                .append("<ul>")
                .append("<li>Năm hiện tại: <b>").append(year).append("</b></li>")
                .append("<li>Số khách VIP trong danh sách: <b>")
                .append(vipList != null ? vipList.size() : 0)
                .append("</b></li>")
                .append("</ul>")
                .append("<p>Trân trọng,<br/>Hệ thống FurniShop</p>");

        boolean ok = emailService.sendWithAttachment(
                emailTo.trim(),
                subject,
                body.toString(),
                "vip-customers.xlsx",
                excelBytes,
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        );

        req.setAttribute("sent", ok);
        doGet(req, resp);
    }

    // Tạo Excel VIP ngay trong controller
    private byte[] buildVipExcel(List<VipCustomer> list) {
        try (Workbook wb = new XSSFWorkbook();
             ByteArrayOutputStream baos = new ByteArrayOutputStream()) {

            DataFormat df = wb.createDataFormat();

            CellStyle headerStyle = wb.createCellStyle();
            Font headerFont = wb.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.LIGHT_YELLOW.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

            CellStyle moneyStyle = wb.createCellStyle();
            moneyStyle.setDataFormat(df.getFormat("#,##0"));

            Sheet sheet = wb.createSheet("VipCustomers");
            int rowIdx = 0;

            Row h = sheet.createRow(rowIdx++);
            String[] titles = {"UserID", "Họ tên", "Email", "Số đơn", "Tổng chi tiêu"};
            for (int i = 0; i < titles.length; i++) {
                Cell c = h.createCell(i);
                c.setCellValue(titles[i]);
                c.setCellStyle(headerStyle);
            }

            if (list != null) {
                for (VipCustomer v : list) {
                    Row r = sheet.createRow(rowIdx++);
                    r.createCell(0).setCellValue(v.getUserId());
                    r.createCell(1).setCellValue(v.getFullName());
                    r.createCell(2).setCellValue(v.getEmail());
                    r.createCell(3).setCellValue(v.getOrderCount());
                    Cell cAmt = r.createCell(4);
                    BigDecimal amt = v.getTotalSpent() == null ? BigDecimal.ZERO : v.getTotalSpent();
                    cAmt.setCellValue(amt.doubleValue());
                    cAmt.setCellStyle(moneyStyle);
                }
            }

            for (int i = 0; i < titles.length; i++) sheet.autoSizeColumn(i);

            wb.write(baos);
            return baos.toByteArray();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private int parseIntOrDefault(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }
}
