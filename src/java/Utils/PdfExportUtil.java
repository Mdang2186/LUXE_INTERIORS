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
import java.awt.Color;

import java.io.OutputStream;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import model.Order;

import model.Product;

/**
 * PdfExportUtil
 *  - Xuất PDF báo cáo danh sách sản phẩm cho admin.
 *  - Dùng cùng với AdminProductController.exportProductsPdf(...)
 *
 * Layout: hiện đại, ngang (landscape), có header + summary + bảng chi tiết.
 */
public class PdfExportUtil {

    // ===== Thông tin shop – sửa theo ý bạn =====
    private static final String SHOP_NAME     = "LUXE INTERIORS - FurniShop";
    private static final String SHOP_SUBTITLE = "Báo cáo danh sách sản phẩm";
    private static final String SHOP_WEBSITE  = "http://localhost:8080/Nhom2_FurniShop";

    // ===== Public API =====

    /**
     * Xuất PDF danh sách sản phẩm ra OutputStream.
     * Gọi từ servlet: PdfExportUtil.exportProductsPdf(list, out);
     */
    public static void exportProductsPdf(List<Product> products, OutputStream out) throws Exception {
        if (products == null || products.isEmpty()) {
            throw new IllegalArgumentException("Danh sách sản phẩm rỗng.");
        }

        // Khổ A4 xoay ngang cho thoáng bảng
        Document doc = new Document(PageSize.A4.rotate(), 36, 36, 36, 36);
        PdfWriter.getInstance(doc, out);
        doc.open();

        FontSet fonts = createFontSet();
        NumberFormat currency = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

        // 1. Header
        addHeader(doc, fonts, sdf);

        // 2. Summary (tổng sản phẩm, tổng tồn kho, giá min/max/avg)
        addSummary(doc, products, currency, fonts);

        // 3. Bảng chi tiết sản phẩm
        addProductTable(doc, products, currency, fonts);

        // 4. Footer
        addFooter(doc, fonts);

        doc.close();
    }

    // ===== FontSet nội bộ =====

    private static class FontSet {
        Font title;
        Font subtitle;
        Font header;
        Font cell;
        Font cellBold;
        Font footer;
    }

    /**
     * Tạo bộ font (ưu tiên Arial Unicode, fallback Helvetica).
     */
    private static FontSet createFontSet() {
        FontSet fs = new FontSet();
        BaseFont bf = null;

        try {
            // Nếu deploy trên Linux thì chỉnh lại path font cho phù hợp
            String fontPath = "C:/Windows/Fonts/arial.ttf";
            bf = BaseFont.createFont(fontPath, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
        } catch (Exception ignored) { }

        if (bf != null) {
            fs.title    = new Font(bf, 18, Font.BOLD, new BaseColor(15, 23, 42));
            fs.subtitle = new Font(bf, 11, Font.NORMAL, new BaseColor(100, 116, 139));
            fs.header   = new Font(bf, 9, Font.BOLD, BaseColor.WHITE);
            fs.cell     = new Font(bf, 9, Font.NORMAL, new BaseColor(30, 41, 59));
            fs.cellBold = new Font(bf, 9, Font.BOLD, new BaseColor(30, 41, 59));
            fs.footer   = new Font(bf, 9, Font.ITALIC, new BaseColor(148, 163, 184));
        } else {
            fs.title    = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD, new BaseColor(15, 23, 42));
            fs.subtitle = new Font(Font.FontFamily.HELVETICA, 11, Font.NORMAL, new BaseColor(100, 116, 139));
            fs.header   = new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD, BaseColor.WHITE);
            fs.cell     = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, new BaseColor(30, 41, 59));
            fs.cellBold = new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD, new BaseColor(30, 41, 59));
            fs.footer   = new Font(Font.FontFamily.HELVETICA, 9, Font.ITALIC, new BaseColor(148, 163, 184));
        }

        return fs;
    }

    // ===== 1. HEADER =====

    private static void addHeader(Document doc, FontSet fs, SimpleDateFormat sdf) throws DocumentException {
        PdfPTable header = new PdfPTable(2);
        header.setWidthPercentage(100);
        header.setWidths(new float[]{2f, 1f});
        header.setSpacingAfter(16f);

        // Trái: tên hệ thống
        PdfPCell left = new PdfPCell();
        left.setBorder(PdfPCell.NO_BORDER);

        Paragraph pTitle = new Paragraph(SHOP_NAME, fs.title);
        pTitle.setSpacingAfter(4f);

        Paragraph pSub = new Paragraph(SHOP_SUBTITLE, fs.subtitle);
        pSub.setSpacingAfter(4f);

        left.addElement(pTitle);
        left.addElement(pSub);

        // Phải: ngày giờ + ghi chú
        PdfPCell right = new PdfPCell();
        right.setBorder(PdfPCell.NO_BORDER);

        Paragraph pDate = new Paragraph("Thời gian xuất: " + sdf.format(new Date()), fs.subtitle);
        pDate.setAlignment(Element.ALIGN_RIGHT);

        Paragraph pNote = new Paragraph("Báo cáo dùng nội bộ quản trị hệ thống.", fs.subtitle);
        pNote.setAlignment(Element.ALIGN_RIGHT);

        right.addElement(pDate);
        right.addElement(pNote);

        header.addCell(left);
        header.addCell(right);

        doc.add(header);
    }

    // ===== 2. SUMMARY BLOCK =====

    private static void addSummary(Document doc, List<Product> products,
                                   NumberFormat currency, FontSet fs) throws DocumentException {

        int count = products.size();
        int totalStock = 0;
        double minPrice = Double.MAX_VALUE;
        double maxPrice = 0;
        double sumPrice = 0;

        for (Product p : products) {
            int stock = p.getStock();
            double price = p.getPrice();

            totalStock += stock;
            sumPrice   += price;

            if (price < minPrice) minPrice = price;
            if (price > maxPrice) maxPrice = price;
        }

        double avgPrice = (count > 0) ? (sumPrice / count) : 0;

        PdfPTable info = new PdfPTable(4);
        info.setWidthPercentage(100);
        info.setWidths(new float[]{1.2f, 1.2f, 1.2f, 1.4f});
        info.setSpacingAfter(12f);

        BaseColor bg = new BaseColor(241, 245, 249);
        BaseColor border = new BaseColor(226, 232, 240);

        info.addCell(summaryCell("Tổng sản phẩm", String.valueOf(count), bg, border, fs));
        info.addCell(summaryCell("Tổng tồn kho", String.valueOf(totalStock), bg, border, fs));
        info.addCell(summaryCell("Giá TB", currency.format(avgPrice), bg, border, fs));
        info.addCell(summaryCell("Khoảng giá", currency.format(minPrice) + " - " + currency.format(maxPrice),
                bg, border, fs));

        doc.add(info);
    }

    private static PdfPCell summaryCell(String label, String value,
                                        BaseColor bg, BaseColor border, FontSet fs) {

        Paragraph p = new Paragraph();
        p.add(new Phrase(label + "\n", fs.cell));
        p.add(new Phrase(value, fs.cellBold));

        PdfPCell cell = new PdfPCell(p);
        cell.setBackgroundColor(bg);
        cell.setBorderColor(border);
        cell.setPaddingTop(6f);
        cell.setPaddingBottom(6f);
        cell.setPaddingLeft(8f);
        cell.setPaddingRight(8f);
        return cell;
    }

    // ===== 3. PRODUCT TABLE =====

    private static void addProductTable(Document doc, List<Product> products,
                                        NumberFormat currency, FontSet fs) throws DocumentException {

        PdfPTable table = new PdfPTable(10);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{
                0.7f, 0.8f, 2.2f, 1.0f, 1.2f,
                0.9f, 1.4f, 1.4f, 1.4f, 2.0f
        });

        // Header
        addHeaderCell(table, "STT", fs.header);
        addHeaderCell(table, "ID", fs.header);
        addHeaderCell(table, "Tên sản phẩm", fs.header);
        addHeaderCell(table, "Danh mục", fs.header);
        addHeaderCell(table, "Thương hiệu", fs.header);
        addHeaderCell(table, "Tồn kho", fs.header);
        addHeaderCell(table, "Giá", fs.header);
        addHeaderCell(table, "Chất liệu", fs.header);
        addHeaderCell(table, "Kích thước", fs.header);
        addHeaderCell(table, "Ảnh / Tính năng", fs.header);

        int idx = 1;
        BaseColor rowBg1 = BaseColor.WHITE;
        BaseColor rowBg2 = new BaseColor(248, 250, 252);

        for (Product p : products) {
            BaseColor bg = (idx % 2 == 0) ? rowBg2 : rowBg1;

            table.addCell(dataCell(String.valueOf(idx), fs.cell, Element.ALIGN_CENTER, bg));
            table.addCell(dataCell(String.valueOf(p.getProductID()), fs.cell, Element.ALIGN_CENTER, bg));
            table.addCell(dataCell(nz(p.getProductName()), fs.cellBold, Element.ALIGN_LEFT, bg));
            table.addCell(dataCell(String.valueOf(p.getCategoryID()), fs.cell, Element.ALIGN_CENTER, bg));
            table.addCell(dataCell(nz(p.getBrand()), fs.cell, Element.ALIGN_LEFT, bg));
            table.addCell(dataCell(String.valueOf(p.getStock()), fs.cell, Element.ALIGN_RIGHT, bg));
            table.addCell(dataCell(currency.format(p.getPrice()), fs.cell, Element.ALIGN_RIGHT, bg));
            table.addCell(dataCell(nz(p.getMaterial()), fs.cell, Element.ALIGN_LEFT, bg));
            table.addCell(dataCell(nz(p.getDimensions()), fs.cell, Element.ALIGN_LEFT, bg));

            String lastCol = "";
            if (p.getImageURL() != null && !p.getImageURL().isEmpty()) {
                lastCol += "Ảnh: " + p.getImageURL();
            }
            if (p.getFeatures() != null && !p.getFeatures().isEmpty()) {
                if (!lastCol.isEmpty()) lastCol += "\n";
                lastCol += "Tính năng: " + p.getFeatures();
            }

            table.addCell(dataCell(lastCol, fs.cell, Element.ALIGN_LEFT, bg));

            idx++;
        }

        doc.add(table);
    }

    private static void addHeaderCell(PdfPTable table, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(new BaseColor(30, 64, 175)); // xanh đậm
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setPaddingTop(5f);
        cell.setPaddingBottom(5f);
        cell.setBorderColor(new BaseColor(30, 64, 175));
        table.addCell(cell);
    }

    private static PdfPCell dataCell(String text, Font font, int align, BaseColor bg) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setHorizontalAlignment(align);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setBackgroundColor(bg);
        cell.setPadding(4f);
        cell.setBorderColor(new BaseColor(226, 232, 240));
        return cell;
    }

    // ===== 4. FOOTER =====

    private static void addFooter(Document doc, FontSet fs) throws DocumentException {
        Paragraph p1 = new Paragraph("Báo cáo được tạo tự động từ hệ thống quản trị FurniShop.", fs.footer);
        p1.setAlignment(Element.ALIGN_CENTER);
        p1.setSpacingBefore(18f);
        doc.add(p1);

        Paragraph p2 = new Paragraph("Đường dẫn: " + SHOP_WEBSITE, fs.footer);
        p2.setAlignment(Element.ALIGN_CENTER);
        p2.setSpacingBefore(4f);
        doc.add(p2);
    }

    // ===== helper =====

      // ===== helper =====

    private static String nz(String s) {
        return (s == null) ? "" : s;
    }

    // ========================= EXPORT ORDERS (UNICODE) =========================
    public static void exportOrders(List<Order> orders, OutputStream out) throws Exception {
        if (orders == null) {
            orders = java.util.Collections.emptyList();
        }

        // Khổ A4 xoay ngang cho rộng bảng
        Document doc = new Document(PageSize.A4.rotate(), 36, 36, 36, 36);
        PdfWriter.getInstance(doc, out);
        doc.open();

        // Dùng cùng FontSet với phần xuất sản phẩm (Arial Unicode + fallback Helvetica)
        FontSet fonts = createFontSet();
        NumberFormat currency = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
        java.text.SimpleDateFormat df = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");

        // ===== Tiêu đề =====
        Paragraph title = new Paragraph("Danh sách đơn hàng FurniShop", fonts.title);
        title.setAlignment(Element.ALIGN_CENTER);
        title.setSpacingAfter(10f);
        doc.add(title);

        // ===== Bảng dữ liệu =====
        PdfPTable table = new PdfPTable(7);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{8, 8, 18, 12, 12, 12, 30});
        table.setHeaderRows(1);

        String[] headers = {
                "Order ID", "User ID", "Ngày đặt",
                "Trạng thái", "Thanh toán",
                "Tổng tiền", "Địa chỉ giao hàng"
        };

        // Header
        for (String h : headers) {
            PdfPCell cell = new PdfPCell(new Phrase(h, fonts.header));
            cell.setHorizontalAlignment(Element.ALIGN_CENTER);
            cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
            cell.setPadding(5f);
            cell.setBackgroundColor(new BaseColor(30, 64, 175)); // nền xanh, chữ trắng
            table.addCell(cell);
        }

        // Dòng dữ liệu
        for (Order o : orders) {
            if (o == null) continue;

            addOrderCell(table, String.valueOf(o.getOrderID()), fonts.cell, Element.ALIGN_CENTER);
            addOrderCell(table, String.valueOf(o.getUserID()), fonts.cell, Element.ALIGN_CENTER);

            addOrderCell(table,
                    (o.getOrderDate() == null ? "" : df.format(o.getOrderDate())),
                    fonts.cell, Element.ALIGN_LEFT);

            addOrderCell(table, nz(o.getStatus()), fonts.cell, Element.ALIGN_LEFT);
            addOrderCell(table, nz(o.getPaymentMethod()), fonts.cell, Element.ALIGN_LEFT);

            // Tổng tiền – dùng NumberFormat cho VND, tránh lỗi format
            String totalStr;
            try {
                totalStr = currency.format(o.getTotalAmount());
            } catch (Exception ex) {
                totalStr = String.valueOf(o.getTotalAmount());
            }
            addOrderCell(table, totalStr, fonts.cell, Element.ALIGN_RIGHT);

            addOrderCell(table, nz(o.getShippingAddress()), fonts.cell, Element.ALIGN_LEFT);
        }

        doc.add(table);
        doc.close();
    }

    private static void addOrderCell(PdfPTable table, String text, Font font, int align) {
        PdfPCell cell = new PdfPCell(new Phrase(text == null ? "" : text, font));
        cell.setPadding(4f);
        cell.setHorizontalAlignment(align);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        table.addCell(cell);
    }
}


