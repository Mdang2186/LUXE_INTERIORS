package Utils;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

import dal.AdminStatsDAO.CategoryRevenue;
import dal.AdminStatsDAO.RevenuePoint;
import dal.AdminStatsDAO.CancellationStats;
import dal.AdminStatsDAO.RetentionStats;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;

/**
 * MonthlyReportPdfUtil
 *  - Tạo PDF báo cáo doanh thu theo THÁNG cho Admin.
 *  - Dùng trong AdminReportMonthlyEmailController (gửi kèm email).
 */
public class MonthlyReportPdfUtil {

    /* ======================= API CHÍNH ======================= */

    /**
     * Tạo file PDF báo cáo tháng.
     *
     * @param year          Năm (vd 2025)
     * @param month         Tháng (1–12)
     * @param revenue       Doanh thu tháng
     * @param profit        Lợi nhuận ước tính tháng
     * @param dailyRevenue  Danh sách điểm doanh thu theo ngày
     * @param catRevenues   Doanh thu theo danh mục
     * @param cs            Thống kê hủy đơn + AOV
     * @param rs            Thống kê retention khách hàng
     */
    public static byte[] generateMonthlyReportPdf(
            int year,
            int month,
            BigDecimal revenue,
            BigDecimal profit,
            List<RevenuePoint> dailyRevenue,
            List<CategoryRevenue> catRevenues,
            CancellationStats cs,
            RetentionStats rs
    ) throws Exception {

        Document doc = new Document(PageSize.A4, 36, 36, 40, 40);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfWriter.getInstance(doc, baos);
        doc.open();

        FontSet fs = createFontSet();
        NumberFormat currency = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
        java.text.DecimalFormat percentFmt = new java.text.DecimalFormat("#0.0'%'");

        // ================== 1. HEADER thương hiệu ==================
        addBrandHeader(doc, fs, year, month);

        // ================== 2. TỔNG QUAN CHỈ SỐ ==================
        addKpiOverview(doc, fs, year, month, revenue, profit, cs, rs, currency, percentFmt);

        // ================== 3. DOANH THU THEO NGÀY ================
        addDailyRevenueSection(doc, fs, dailyRevenue, currency);

        // ================== 4. DOANH THU THEO DANH MỤC ============
        addCategoryRevenueSection(doc, fs, catRevenues, currency);

        // ================== 5. FOOTER =============================
        Paragraph footer = new Paragraph(
                "Báo cáo được tạo tự động bởi hệ thống LUXE INTERIORS / FurniShop.",
                fs.footer
        );
        footer.setAlignment(Element.ALIGN_CENTER);
        footer.setSpacingBefore(24f);
        doc.add(footer);

        doc.close();
        return baos.toByteArray();
    }

    /* ======================= FONT SET ======================== */

    private static class FontSet {
        Font title;
        Font subtitle;
        Font sectionTitle;
        Font kpiNumber;
        Font tableHeader;
        Font tableCell;
        Font tableCellBold;
        Font note;
        Font footer;
    }

    /** Cố gắng dùng font Unicode; lỗi thì fallback HELVETICA. */
    private static FontSet createFontSet() {
        FontSet fs = new FontSet();

        BaseFont bfUnicode = null;
        try {
            // chỉnh path nếu deploy trên Linux (ví dụ DejaVuSans)
            String fontPath = "C:/Windows/Fonts/arial.ttf";
            bfUnicode = BaseFont.createFont(fontPath, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
        } catch (Exception ignore) {
        }

        if (bfUnicode != null) {
            fs.title         = new Font(bfUnicode, 18, Font.BOLD, new BaseColor(24, 24, 27));
            fs.subtitle      = new Font(bfUnicode, 10, Font.NORMAL, new BaseColor(107, 114, 128));
            fs.sectionTitle  = new Font(bfUnicode, 11, Font.BOLD, new BaseColor(31, 41, 55));
            fs.kpiNumber     = new Font(bfUnicode, 12, Font.BOLD, new BaseColor(30, 64, 175));
            fs.tableHeader   = new Font(bfUnicode, 9, Font.BOLD, BaseColor.WHITE);
            fs.tableCell     = new Font(bfUnicode, 9, Font.NORMAL, new BaseColor(31, 41, 55));
            fs.tableCellBold = new Font(bfUnicode, 9, Font.BOLD, new BaseColor(31, 41, 55));
            fs.note          = new Font(bfUnicode, 9, Font.NORMAL, new BaseColor(75, 85, 99));
            fs.footer        = new Font(bfUnicode, 9, Font.ITALIC, new BaseColor(156, 163, 175));
        } else {
            fs.title         = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD, new BaseColor(24, 24, 27));
            fs.subtitle      = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, new BaseColor(107, 114, 128));
            fs.sectionTitle  = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD, new BaseColor(31, 41, 55));
            fs.kpiNumber     = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD, new BaseColor(30, 64, 175));
            fs.tableHeader   = new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD, BaseColor.WHITE);
            fs.tableCell     = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, new BaseColor(31, 41, 55));
            fs.tableCellBold = new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD, new BaseColor(31, 41, 55));
            fs.note          = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, new BaseColor(75, 85, 99));
            fs.footer        = new Font(Font.FontFamily.HELVETICA, 9, Font.ITALIC, new BaseColor(156, 163, 175));
        }

        return fs;
    }

    /* ======================= HEADER ========================== */

    private static void addBrandHeader(Document doc, FontSet fs, int year, int month)
            throws DocumentException {

        PdfPTable headerTable = new PdfPTable(2);
        headerTable.setWidthPercentage(100);
        headerTable.setWidths(new float[]{2f, 1.4f});
        headerTable.setSpacingAfter(18f);

        // LEFT: brand
        PdfPCell left = new PdfPCell();
        left.setBorder(PdfPCell.NO_BORDER);

        Paragraph brand = new Paragraph("LUXE INTERIORS", fs.title);
        brand.setSpacingAfter(2f);
        Paragraph tag   = new Paragraph("FurniShop - Nội thất cao cấp", fs.subtitle);

        left.addElement(brand);
        left.addElement(tag);

        // RIGHT: report title
        PdfPCell right = new PdfPCell();
        right.setBorder(PdfPCell.NO_BORDER);

        PdfPTable inner = new PdfPTable(1);
        inner.setWidthPercentage(100);

        PdfPCell cTitle = new PdfPCell(new Phrase(
                "BÁO CÁO DOANH THU THÁNG " + String.format("%02d/%d", month, year),
                new Font(fs.sectionTitle.getBaseFont(), 12, Font.BOLD, BaseColor.WHITE)
        ));
        cTitle.setHorizontalAlignment(Element.ALIGN_CENTER);
        cTitle.setBackgroundColor(new BaseColor(31, 41, 55));
        cTitle.setPaddingTop(8f);
        cTitle.setPaddingBottom(8f);
        cTitle.setBorder(PdfPCell.NO_BORDER);
        inner.addCell(cTitle);

        PdfPCell cSub = new PdfPCell(new Phrase(
                "Tổng quan doanh thu, lợi nhuận và hành vi khách hàng",
                new Font(fs.subtitle.getBaseFont(), 8, Font.NORMAL, new BaseColor(209, 213, 219))
        ));
        cSub.setHorizontalAlignment(Element.ALIGN_CENTER);
        cSub.setBackgroundColor(new BaseColor(31, 41, 55));
        cSub.setPaddingBottom(6f);
        cSub.setBorder(PdfPCell.NO_BORDER);
        inner.addCell(cSub);

        right.addElement(inner);

        headerTable.addCell(left);
        headerTable.addCell(right);

        doc.add(headerTable);
    }

    /* ======================= KPI OVERVIEW ==================== */

    private static void addKpiOverview(
            Document doc,
            FontSet fs,
            int year,
            int month,
            BigDecimal revenue,
            BigDecimal profit,
            CancellationStats cs,
            RetentionStats rs,
            NumberFormat currency,
            java.text.DecimalFormat percentFmt
    ) throws DocumentException {

        Paragraph title = new Paragraph("1. Tổng quan chỉ số", fs.sectionTitle);
        title.setSpacingAfter(6f);
        doc.add(title);

        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{1f, 1f});
        table.setSpacingAfter(12f);

        BaseColor border = new BaseColor(229, 231, 235);

        // Ô 1: tài chính
        PdfPCell c1 = new PdfPCell();
        c1.setBorderColor(border);
        c1.setPadding(8f);

        Paragraph p1Title = new Paragraph("Chỉ số tài chính", fs.sectionTitle);
        p1Title.setSpacingAfter(4f);
        c1.addElement(p1Title);

        String revStr = currency.format(nzBig(revenue));
        String profStr = currency.format(nzBig(profit));

        Paragraph pRev = new Paragraph("Doanh thu tháng: " + revStr, fs.kpiNumber);
        pRev.setSpacingAfter(2f);
        c1.addElement(pRev);

        Paragraph pProf = new Paragraph("Lợi nhuận ước tính: " + profStr, fs.kpiNumber);
        pProf.setSpacingAfter(4f);
        c1.addElement(pProf);

        if (cs != null) {
            Paragraph pCancel = new Paragraph(
                    String.format("Tổng đơn: %d  •  Hủy: %d (%.1f%%)",
                            cs.getTotalOrders(),
                            cs.getCanceledOrders(),
                            cs.getCancelRate()),
                    fs.tableCell
            );
            pCancel.setSpacingAfter(2f);
            c1.addElement(pCancel);

            Paragraph pAov = new Paragraph(
                    "Giá trị đơn hàng trung bình (AOV): "
                            + currency.format(nzBig(cs.getAverageOrderValue())),
                    fs.tableCell
            );
            c1.addElement(pAov);
        }

        // Ô 2: hành vi khách hàng
        PdfPCell c2 = new PdfPCell();
        c2.setBorderColor(border);
        c2.setPadding(8f);

        Paragraph p2Title = new Paragraph("Hành vi & giữ chân khách hàng", fs.sectionTitle);
        p2Title.setSpacingAfter(4f);
        c2.addElement(p2Title);

        if (rs != null) {
            Paragraph pRet = new Paragraph(
                    String.format("Khách từng mua: %d  •  Quay lại: %d",
                            rs.getTotalCustomers(), rs.getReturningCustomers()),
                    fs.tableCell
            );
            pRet.setSpacingAfter(2f);
            c2.addElement(pRet);

            Paragraph pRate = new Paragraph(
                    "Tỷ lệ giữ chân: " + percentFmt.format(rs.getRetentionRate()),
                    fs.kpiNumber
            );
            pRate.setSpacingAfter(4f);
            c2.addElement(pRate);
        } else {
            c2.addElement(new Paragraph("Chưa có số liệu retention.", fs.tableCell));
        }

        Paragraph pNote = new Paragraph(
                "Gợi ý: tỷ lệ giữ chân cao và AOV tốt cho thấy phân khúc khách hàng ổn định. " +
                        "Tập trung remarketing vào nhóm VIP để tối ưu lợi nhuận.",
                fs.note
        );
        pNote.setLeading(13f);
        pNote.setSpacingBefore(4f);
        c2.addElement(pNote);

        table.addCell(c1);
        table.addCell(c2);

        doc.add(table);
    }

    /* ======================= DAILY REVENUE ================== */

    private static void addDailyRevenueSection(
            Document doc,
            FontSet fs,
            List<RevenuePoint> dailyRevenue,
            NumberFormat currency
    ) throws DocumentException {

        Paragraph title = new Paragraph("2. Doanh thu theo ngày", fs.sectionTitle);
        title.setSpacingBefore(4f);
        title.setSpacingAfter(4f);
        doc.add(title);

        if (dailyRevenue == null || dailyRevenue.isEmpty()) {
            Paragraph p = new Paragraph("Không có dữ liệu doanh thu trong tháng.", fs.note);
            p.setSpacingAfter(8f);
            doc.add(p);
            return;
        }

        PdfPTable table = new PdfPTable(2);
        table.setWidthPercentage(60); // nhỏ, đặt bên trái
        table.setWidths(new float[]{1.2f, 1.2f});
        table.setSpacingAfter(10f);

        addHeaderCell(table, "Ngày", fs.tableHeader);
        addHeaderCell(table, "Doanh thu", fs.tableHeader);

        for (RevenuePoint rp : dailyRevenue) {
            PdfPCell cDate = makeCell(rp.getDate(), fs.tableCell, Element.ALIGN_LEFT);
            PdfPCell cVal  = makeCell(
                    currency.format(nzBig(rp.getTotal())),
                    fs.tableCell,
                    Element.ALIGN_RIGHT
            );
            table.addCell(cDate);
            table.addCell(cVal);
        }

        doc.add(table);
    }

    /* ======================= CATEGORY REVENUE =============== */

    private static void addCategoryRevenueSection(
            Document doc,
            FontSet fs,
            List<CategoryRevenue> catRevenues,
            NumberFormat currency
    ) throws DocumentException {

        Paragraph title = new Paragraph("3. Doanh thu theo danh mục sản phẩm", fs.sectionTitle);
        title.setSpacingBefore(4f);
        title.setSpacingAfter(4f);
        doc.add(title);

        if (catRevenues == null || catRevenues.isEmpty()) {
            Paragraph p = new Paragraph("Chưa có số liệu doanh thu theo danh mục.", fs.note);
            p.setSpacingAfter(8f);
            doc.add(p);
            return;
        }

        PdfPTable table = new PdfPTable(3);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{0.7f, 2.5f, 1.3f});
        table.setSpacingAfter(8f);

        addHeaderCell(table, "STT", fs.tableHeader);
        addHeaderCell(table, "Danh mục", fs.tableHeader);
        addHeaderCell(table, "Doanh thu", fs.tableHeader);

        int idx = 1;
        for (CategoryRevenue cr : catRevenues) {
            table.addCell(makeCell(String.valueOf(idx++), fs.tableCell, Element.ALIGN_CENTER));
            table.addCell(makeCell(nz(cr.getCategoryName()), fs.tableCell, Element.ALIGN_LEFT));
            table.addCell(makeCell(
                    currency.format(nzBig(cr.getRevenue())),
                    fs.tableCellBold,
                    Element.ALIGN_RIGHT
            ));
        }

        doc.add(table);

        Paragraph note = new Paragraph(
                "Các danh mục có doanh thu cao nên được ưu tiên về tồn kho, trưng bày và chiến dịch quảng cáo.",
                fs.note
        );
        note.setLeading(13f);
        doc.add(note);
    }

    /* ======================= TABLE HELPERS ================== */

    private static void addHeaderCell(PdfPTable t, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(new BaseColor(31, 41, 55));
        cell.setPadding(5f);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setBorderColor(new BaseColor(17, 24, 39));
        t.addCell(cell);
    }

    private static PdfPCell makeCell(String text, Font font, int align) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setPadding(4f);
        cell.setHorizontalAlignment(align);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setBorderColor(new BaseColor(229, 231, 235));
        return cell;
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }

    private static BigDecimal nzBig(BigDecimal b) {
        return b == null ? BigDecimal.ZERO : b;
    }
}
