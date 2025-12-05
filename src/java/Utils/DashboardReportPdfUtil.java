package Utils;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import dal.ProductDAO;   // thêm dòng này

import dal.AdminStatsDAO;
import dal.AdminStatsDAO.RevenuePoint;
import dal.AdminStatsDAO.StatusCount;
import dal.AdminStatsDAO.CategoryRevenue;
import dal.AdminStatsDAO.MonthlyCount;

import model.Product;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.List;

/**
 * Tạo PDF báo cáo tổng quan Dashboard Admin.
 * - KPI tổng: user, product, order, doanh thu, review, contact
 * - Bảng doanh thu theo ngày
 * - Bảng trạng thái đơn hàng
 * - Bảng doanh thu theo danh mục
 * - Bảng user mới theo tháng
 * - Bảng top sản phẩm bán chạy
 * - Bảng cảnh báo tồn kho
 */
public class DashboardReportPdfUtil {

    public static byte[] generateDashboardReport(
            AdminStatsDAO stats,
            LocalDate fromDate,
            LocalDate toDate,
            int year
    ) throws Exception {

        if (stats == null) {
            throw new IllegalArgumentException("stats is null");
        }

        // ===================== 1. LẤY DỮ LIỆU =====================

        // KPI tổng
        int countUsers      = stats.countUsers();
        int countProducts   = stats.countProducts();
        int countOrders     = stats.countOrders();
        BigDecimal sumDone  = stats.sumRevenueDone();
        int countReviews    = stats.countReviews();
        int countContacts   = stats.countContacts();

        // Doanh thu theo ngày trong khoảng [fromDate, toDate]
        List<RevenuePoint> revenuePoints =
                stats.getRevenueByDateRange(
                        Date.valueOf(fromDate),
                        Date.valueOf(toDate)
                );

        // Trạng thái đơn hàng
        List<StatusCount> statusCounts = stats.countOrdersByStatus();

        // Doanh thu theo danh mục
        List<CategoryRevenue> catRevenues =
                stats.getRevenueByCategory(
                        Date.valueOf(fromDate),
                        Date.valueOf(toDate)
                );

        // User mới theo tháng
        List<MonthlyCount> userMonths = stats.getNewUsersByMonth(year);

        // Top sản phẩm bán chạy (Top 5)
        List<AdminStatsDAO.TopProduct> topProducts = stats.getTopSellingProducts(5);

        // Sản phẩm tồn kho thấp (ngưỡng 5) - dùng ProductDAO giống AdminDashboardServlet
        ProductDAO pdao = new ProductDAO();
        List<Product> lowStockProducts = pdao.getLowStockProducts(5);

        // ===================== 2. TẠO PDF =====================

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 36, 36, 36, 36);

        PdfWriter.getInstance(document, baos);
        document.open();

        // ===== Fonts: dùng font Unicode để hiển thị đúng tiếng Việt =====
        FontSet fonts = createFontSet();
        Font titleFont   = fonts.title;
        Font sectionFont = fonts.section;
        Font normalFont  = fonts.normal;
        Font boldFont    = fonts.bold;

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

        // ===== TITLE =====
        Paragraph title = new Paragraph("BÁO CÁO TỔNG QUAN DASHBOARD - FURNISHOP", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        document.add(title);

        Paragraph timeInfo = new Paragraph(
                "Khoảng thời gian: " + sdf.format(Date.valueOf(fromDate))
                        + "  →  " + sdf.format(Date.valueOf(toDate))
                        + "   |   Năm thống kê user mới: " + year,
                normalFont
        );
        timeInfo.setSpacingBefore(8);
        timeInfo.setSpacingAfter(12);
        document.add(timeInfo);

        // ======================================================
        // SECTION 1: KPI TỔNG QUAN
        // ======================================================

        Paragraph sec1 = new Paragraph("1. Thống kê tổng quan", sectionFont);
        sec1.setSpacingBefore(6);
        sec1.setSpacingAfter(4);
        document.add(sec1);

        PdfPTable kpiTable = new PdfPTable(3);
        kpiTable.setWidthPercentage(100);
        kpiTable.setWidths(new float[]{3, 3, 3});

        addKpiCell(kpiTable, "Tổng khách hàng", String.valueOf(countUsers), boldFont, normalFont);
        addKpiCell(kpiTable, "Tổng sản phẩm", String.valueOf(countProducts), boldFont, normalFont);
        addKpiCell(kpiTable, "Tổng đơn hàng", String.valueOf(countOrders), boldFont, normalFont);

        String revenueStr = (sumDone != null)
                ? String.format("%,d ₫", sumDone.longValue())
                : "0 ₫";
        addKpiCell(kpiTable, "Tổng doanh thu (đơn hoàn tất)", revenueStr, boldFont, normalFont);
        addKpiCell(kpiTable, "Tổng review", String.valueOf(countReviews), boldFont, normalFont);
        addKpiCell(kpiTable, "Tổng liên hệ", String.valueOf(countContacts), boldFont, normalFont);

        document.add(kpiTable);

        // ======================================================
        // SECTION 2: DOANH THU THEO NGÀY
        // ======================================================

        Paragraph sec2 = new Paragraph("2. Doanh thu theo ngày", sectionFont);
        sec2.setSpacingBefore(10);
        sec2.setSpacingAfter(4);
        document.add(sec2);

        PdfPTable revTable = new PdfPTable(2);
        revTable.setWidthPercentage(100);
        revTable.setWidths(new float[]{4, 3});

        addHeaderCell(revTable, "Ngày", boldFont);
        addHeaderCell(revTable, "Doanh thu (₫)", boldFont);

        if (revenuePoints != null && !revenuePoints.isEmpty()) {
            for (RevenuePoint rp : revenuePoints) {
                String dateLabel = rp.getDate(); // dạng "yyyy-MM-dd"
                BigDecimal total = (rp.getTotal() != null) ? rp.getTotal() : BigDecimal.ZERO;

                addBodyCell(revTable, dateLabel, normalFont);
                addBodyCell(revTable, String.format("%,d", total.longValue()), normalFont);
            }
        } else {
            addBodyCell(revTable, "Không có dữ liệu doanh thu trong khoảng này.", normalFont, 2);
        }

        document.add(revTable);

        // ======================================================
        // SECTION 3: TRẠNG THÁI ĐƠN HÀNG
        // ======================================================

        Paragraph sec3 = new Paragraph("3. Trạng thái đơn hàng", sectionFont);
        sec3.setSpacingBefore(10);
        sec3.setSpacingAfter(4);
        document.add(sec3);

        PdfPTable statusTable = new PdfPTable(2);
        statusTable.setWidthPercentage(60);
        statusTable.setWidths(new float[]{4, 2});

        addHeaderCell(statusTable, "Trạng thái", boldFont);
        addHeaderCell(statusTable, "Số đơn", boldFont);

        if (statusCounts != null && !statusCounts.isEmpty()) {
            for (StatusCount sc : statusCounts) {
                addBodyCell(statusTable, sc.getStatus(), normalFont);
                addBodyCell(statusTable, String.valueOf(sc.getCount()), normalFont);
            }
        } else {
            addBodyCell(statusTable, "Không có dữ liệu trạng thái đơn hàng.", normalFont, 2);
        }

        document.add(statusTable);

        // ======================================================
        // SECTION 4: DOANH THU THEO DANH MỤC
        // ======================================================

        Paragraph sec4 = new Paragraph("4. Doanh thu theo danh mục", sectionFont);
        sec4.setSpacingBefore(10);
        sec4.setSpacingAfter(4);
        document.add(sec4);

        PdfPTable catTable = new PdfPTable(3);
        catTable.setWidthPercentage(100);
        catTable.setWidths(new float[]{4, 3, 3});

        addHeaderCell(catTable, "Danh mục", boldFont);
        addHeaderCell(catTable, "Doanh thu (₫)", boldFont);
        addHeaderCell(catTable, "Ghi chú", boldFont);

        if (catRevenues != null && !catRevenues.isEmpty()) {
            for (CategoryRevenue cr : catRevenues) {
                BigDecimal rev = (cr.getRevenue() != null) ? cr.getRevenue() : BigDecimal.ZERO;

                addBodyCell(catTable, cr.getCategoryName(), normalFont);
                addBodyCell(catTable, String.format("%,d", rev.longValue()), normalFont);
                addBodyCell(catTable, "", normalFont);
            }
        } else {
            addBodyCell(catTable, "Không có dữ liệu doanh thu theo danh mục.", normalFont, 3);
        }

        document.add(catTable);

        // ======================================================
        // SECTION 5: USER MỚI THEO THÁNG
        // ======================================================

        Paragraph sec5 = new Paragraph("5. User mới theo tháng (" + year + ")", sectionFont);
        sec5.setSpacingBefore(10);
        sec5.setSpacingAfter(4);
        document.add(sec5);

        PdfPTable userMonthTable = new PdfPTable(2);
        userMonthTable.setWidthPercentage(60);
        userMonthTable.setWidths(new float[]{4, 2});

        addHeaderCell(userMonthTable, "Tháng", boldFont);
        addHeaderCell(userMonthTable, "Số user mới", boldFont);

        if (userMonths != null && !userMonths.isEmpty()) {
            for (MonthlyCount mc : userMonths) {
                addBodyCell(userMonthTable, mc.getMonth(), normalFont);
                addBodyCell(userMonthTable, String.valueOf(mc.getCount()), normalFont);
            }
        } else {
            addBodyCell(userMonthTable, "Không có dữ liệu user mới.", normalFont, 2);
        }

        document.add(userMonthTable);

        // ======================================================
        // SECTION 6: TOP SẢN PHẨM BÁN CHẠY
        // ======================================================

        Paragraph sec6 = new Paragraph("6. Top sản phẩm bán chạy", sectionFont);
        sec6.setSpacingBefore(10);
        sec6.setSpacingAfter(4);
        document.add(sec6);

        PdfPTable topTable = new PdfPTable(3);
        topTable.setWidthPercentage(100);
        topTable.setWidths(new float[]{1, 5, 2});

        addHeaderCell(topTable, "Top", boldFont);
        addHeaderCell(topTable, "Sản phẩm", boldFont);
        addHeaderCell(topTable, "Số lượng bán", boldFont);

        if (topProducts != null && !topProducts.isEmpty()) {
            int rank = 1;
            for (AdminStatsDAO.TopProduct tp : topProducts) {
                addBodyCell(topTable, String.valueOf(rank++), normalFont);
                addBodyCell(topTable, tp.getProductName(), normalFont);
                addBodyCell(topTable, String.valueOf(tp.getQuantity()), normalFont);
            }
        } else {
            addBodyCell(topTable, "Chưa có dữ liệu bán hàng.", normalFont, 3);
        }

        document.add(topTable);

        // ======================================================
        // SECTION 7: CẢNH BÁO TỒN KHO
        // ======================================================

        Paragraph sec7 = new Paragraph("7. Cảnh báo tồn kho", sectionFont);
        sec7.setSpacingBefore(10);
        sec7.setSpacingAfter(4);
        document.add(sec7);

        PdfPTable stockTable = new PdfPTable(3);
        stockTable.setWidthPercentage(100);
        stockTable.setWidths(new float[]{1, 5, 2});

        addHeaderCell(stockTable, "ID", boldFont);
        addHeaderCell(stockTable, "Sản phẩm", boldFont);
        addHeaderCell(stockTable, "Tồn kho", boldFont);

        if (lowStockProducts != null && !lowStockProducts.isEmpty()) {
            for (Product p : lowStockProducts) {
                addBodyCell(stockTable, String.valueOf(p.getProductID()), normalFont);
                addBodyCell(stockTable, p.getProductName(), normalFont);
                addBodyCell(stockTable, String.valueOf(p.getStock()), normalFont);
            }
        } else {
            addBodyCell(stockTable, "Kho đang ổn định, chưa có sản phẩm dưới ngưỡng cảnh báo.", normalFont, 3);
        }

        document.add(stockTable);

        // FOOTER
        Paragraph footer = new Paragraph(
                "Báo cáo được tạo tự động từ hệ thống FurniShop Admin.",
                normalFont
        );
        footer.setSpacingBefore(15);
        document.add(footer);

        document.close();
        return baos.toByteArray();
    }

    // ===================== FontSet dùng chung =====================

    /**
     * Nhóm font sử dụng cho báo cáo Dashboard.
     */
    private static class FontSet {
        Font title;
        Font section;
        Font normal;
        Font bold;
    }

    /**
     * Tạo bộ font Unicode cho PDF.
     *  - Trên Windows: dùng C:/Windows/Fonts/arial.ttf
     *  - Nếu cần deploy trên Linux/server khác: đổi lại đường dẫn font cho phù hợp.
     */
    private static FontSet createFontSet() {
        FontSet fs = new FontSet();
        BaseFont bfUnicode = null;

        try {
            // Đường dẫn font trên Windows.
            // Nếu chạy trên Linux, có thể đổi thành: "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
            String fontPath = "C:/Windows/Fonts/arial.ttf";
            bfUnicode = BaseFont.createFont(fontPath, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
        } catch (Exception ex) {
            // ignore, sẽ fallback phía dưới
        }

        if (bfUnicode != null) {
            fs.title   = new Font(bfUnicode, 16, Font.BOLD, BaseColor.BLACK);
            fs.section = new Font(bfUnicode, 12, Font.BOLD, BaseColor.BLACK);
            fs.normal  = new Font(bfUnicode, 10, Font.NORMAL, BaseColor.BLACK);
            fs.bold    = new Font(bfUnicode, 10, Font.BOLD, BaseColor.BLACK);
        } else {
            // Fallback – vẫn chạy nhưng nếu font không hỗ trợ Unicode thì có thể vẫn lỗi dấu
            fs.title   = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16);
            fs.section = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);
            fs.normal  = FontFactory.getFont(FontFactory.HELVETICA, 10);
            fs.bold    = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
        }

        return fs;
    }

    // ============ helper thêm cell =============

    private static void addKpiCell(PdfPTable table, String label, String value,
                                   Font labelFont, Font valueFont) {
        PdfPCell cell = new PdfPCell();
        cell.setPadding(6);
        cell.setUseAscender(true);
        cell.setUseDescender(true);

        Paragraph p = new Paragraph();
        p.add(new Phrase(label + "\n", labelFont));
        p.add(new Phrase(value, valueFont));

        cell.addElement(p);
        table.addCell(cell);
    }

    private static void addHeaderCell(PdfPTable table, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setPadding(5);
        table.addCell(cell);
    }

    private static void addBodyCell(PdfPTable table, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(4);
        table.addCell(cell);
    }

    private static void addBodyCell(PdfPTable table, String text, Font font, int colspan) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(4);
        cell.setColspan(colspan);
        table.addCell(cell);
    }
}
