package admin;

import Utils.DashboardReportPdfUtil;
import Utils.EmailService;
import dal.AdminStatsDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;

/**
 * Gửi báo cáo tổng quan Dashboard (PDF) qua email bất kỳ:
 *  POST /admin/dashboard/email-pdf
 *   - param: email (địa chỉ nhận)
 *   - optional: from, to, year
 */
@WebServlet(name = "AdminDashboardEmailController",
        urlPatterns = {"/admin/dashboard/email-pdf"})
public class AdminDashboardEmailController extends HttpServlet {

    private AdminStatsDAO stats;
    private EmailService emailService;

    @Override
    public void init() throws ServletException {
        stats = new AdminStatsDAO();
        emailService = new EmailService();
    }

    /** Nếu ai đó GET trực tiếp URL thì cho quay về dashboard */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String toEmail = req.getParameter("email");
        if (toEmail == null || toEmail.isBlank()) {
            // set message đẹp rồi forward ra JSP
            req.setAttribute("success", false);
            req.setAttribute("message", "Vui lòng nhập email nhận báo cáo.");
            req.getRequestDispatcher("/WEB-INF/admin/email-report-result.jsp")
               .forward(req, resp);
            return;
        }

        LocalDate today = LocalDate.now();

        String fromStr = req.getParameter("from");
        String toStr   = req.getParameter("to");
        String yearStr = req.getParameter("year");

        LocalDate fromDate;
        LocalDate toDate;
        int year;

        // Khoảng ngày
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
                    toDate   = tmp;
                }
            }
        } catch (Exception e) {
            toDate = today;
            fromDate = today.minusDays(6);
        }

        // Năm
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
            req.setAttribute("success", false);
            req.setAttribute("message", "Lỗi tạo báo cáo PDF. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/WEB-INF/admin/email-report-result.jsp")
               .forward(req, resp);
            return;
        }

        String fileName = String.format(
                "dashboard-report-%s-to-%s.pdf",
                fromDate.toString(), toDate.toString()
        );

        String subject = "Báo cáo tổng quan FurniShop: " + fromDate + " → " + toDate;
        String html = "<p>Chào Admin,</p>"
                + "<p>Đính kèm là báo cáo tổng quan Dashboard FurniShop trong khoảng "
                + fromDate + " → " + toDate + ".</p>"
                + "<p>Trân trọng,<br/>FurniShop System</p>";

        boolean ok = emailService.sendWithAttachment(
                toEmail.trim(),
                subject,
                html,
                fileName,
                pdf,
                "application/pdf"
        );

        // Gửi xong -> set thuộc tính + forward sang JSP giao diện đẹp
        req.setAttribute("success", ok);
        if (ok) {
            req.setAttribute("message",
                    "Báo cáo đã được gửi tới địa chỉ email: " + toEmail.trim());
        } else {
            req.setAttribute("message",
                    "Gửi báo cáo thất bại. Vui lòng kiểm tra cấu hình email hoặc thử lại sau.");
        }
        req.setAttribute("fromDate", fromDate.toString());
        req.setAttribute("toDate", toDate.toString());

        req.getRequestDispatcher("/WEB-INF/admin/email-report-result.jsp")
           .forward(req, resp);
    }
}
