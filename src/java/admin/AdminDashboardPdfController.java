package admin;

import Utils.DashboardReportPdfUtil;
import dal.AdminStatsDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;

/**
 * Tải báo cáo tổng quan Dashboard dạng PDF:
 *  GET /admin/dashboard/export-pdf
 *      (có thể truyền ?from=yyyy-MM-dd&to=yyyy-MM-dd&year=2025)
 */
@WebServlet(name = "AdminDashboardPdfController",
        urlPatterns = {"/admin/dashboard/export-pdf"})
public class AdminDashboardPdfController extends HttpServlet {

    private AdminStatsDAO stats;

    @Override
    public void init() throws ServletException {
        stats = new AdminStatsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        LocalDate today = LocalDate.now();

        String fromStr = req.getParameter("from");
        String toStr   = req.getParameter("to");
        String yearStr = req.getParameter("year");

        LocalDate fromDate;
        LocalDate toDate;
        int year;

        // Khoảng ngày: nếu không có, mặc định 7 ngày gần nhất
        try {
            if (fromStr == null || fromStr.isBlank()
                    || toStr == null || toStr.isBlank()) {
                toDate = today;
                fromDate = today.minusDays(6);
            } else {
                fromDate = LocalDate.parse(fromStr.trim());
                toDate   = LocalDate.parse(toStr.trim());
                if (fromDate.isAfter(toDate)) {
                    LocalDate tmp = fromDate;
                    fromDate = toDate;
                    toDate = tmp;
                }
            }
        } catch (Exception e) {
            toDate = today;
            fromDate = today.minusDays(6);
        }

        // Năm thống kê user mới
        try {
            if (yearStr == null || yearStr.isBlank()) {
                year = today.getYear();
            } else {
                year = Integer.parseInt(yearStr.trim());
            }
        } catch (Exception e) {
            year = today.getYear();
        }

        byte[] pdf;
        try {
            pdf = DashboardReportPdfUtil.generateDashboardReport(
                    stats, fromDate, toDate, year
            );
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(500, "Lỗi tạo báo cáo PDF");
            return;
        }

        String fileName = String.format(
                "dashboard-report-%s-to-%s.pdf",
                fromDate.toString(), toDate.toString()
        );

        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition",
                "attachment; filename=\"" + fileName + "\"");
        resp.setContentLength(pdf.length);
        resp.getOutputStream().write(pdf);
    }
}
