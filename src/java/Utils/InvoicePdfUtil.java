package Utils;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import Utils.OrdersPdfUtil;

import java.io.OutputStream;
import java.io.ByteArrayOutputStream;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;

import model.Order;
import model.OrderItem;
import model.Product;
import model.User;

/**
 * InvoicePdfUtil
 *  - Tạo PDF hóa đơn cho 1 đơn hàng (Order + User).
 *  - Dùng cho Admin hoặc khách tải hóa đơn.
 *
 * Style: sang trọng, tone tối hiện đại, bố cục rõ ràng.
 */
public class InvoicePdfUtil {

    // =================== THÔNG TIN SHOP (có thể sửa) ===================

    private static final String SHOP_NAME       = "LUXE INTERIORS - FurniShop";
    private static final String SHOP_SUBTITLE   = "Nội thất cao cấp & Decor";
    private static final String SHOP_ADDRESS    = "123 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh";
    private static final String SHOP_PHONE      = "Hotline: 0123 456 789";
    private static final String SHOP_EMAIL      = "Email: support@furnishop.vn";
    private static final String SHOP_WEBSITE    = "Website: http://localhost:8080/Nhom2_FurniShop";

    // ======================= API chính (trả về byte[]) =======================

    /**
     * Tạo file PDF hóa đơn cho 1 đơn hàng.
     *
     * @param order Đơn hàng (chứa danh sách OrderItem)
     * @param user  Người dùng đặt (có thể null)
     * @return      Mảng byte PDF
     */
    public static byte[] generateInvoicePdf(Order order, User user) throws Exception {
        if (order == null) {
            throw new IllegalArgumentException("Order không được null khi tạo PDF hóa đơn.");
        }

        Document doc = new Document(PageSize.A4, 36, 36, 36, 36);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfWriter.getInstance(doc, baos);
        doc.open();

        // Font (ưu tiên Unicode cho tiếng Việt)
        FontSet fonts = createFontSet();

        NumberFormat currency = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
        SimpleDateFormat sdf  = new SimpleDateFormat("dd/MM/yyyy HH:mm");

        // 1. Header thương hiệu + block INVOICE
        addBrandHeader(doc, fonts);

        // 2. Thông tin khách + thông tin đơn
        addInfoBlock(doc, order, user, currency, sdf, fonts);

        // 3. Bảng chi tiết sản phẩm
        addItemsTable(doc, order, currency, fonts);

        // 4. Tổng tiền + ghi chú đơn hàng
        addSummaryAndNote(doc, order, currency, fonts);

        // 5. Footer cảm ơn + thông tin liên hệ
        addFooter(doc, fonts);

        doc.close();
        return baos.toByteArray();
    }

    // ======================= API tiện dụng (ghi ra OutputStream) =======================

    /**
     * Ghi trực tiếp PDF hóa đơn ra OutputStream
     * (dùng trong Servlet xuất file).
     */
    public static void exportInvoice(Order order, User user, OutputStream out) throws Exception {
        byte[] data = generateInvoicePdf(order, user);
        out.write(data);
        out.flush();
    }

    /** Overload: không cần truyền User. */
    public static void exportInvoice(Order order, OutputStream out) throws Exception {
        exportInvoice(order, null, out);
    }

    // =========================================================
    // ============ CÁC HÀM THÀNH PHẦN (PRIVATE) ===============
    // =========================================================

    /** Gói các font cần dùng để dễ quản lý */
    private static class FontSet {
        Font title;       // tiêu đề lớn
        Font subtitle;    // phụ đề / text nhạt
        Font sectionTitle;// tiêu đề section
        Font tableHeader; // header bảng
        Font tableCell;   // ô bình thường
        Font tableCellBold;
        Font note;
        Font footer;
    }

    /**
     * Tạo bộ font:
     *  - Cố gắng dùng font Unicode (Arial) để hiển thị tiếng Việt.
     *  - Nếu lỗi (không tìm thấy file font), fallback về HELVETICA.
     */
    private static FontSet createFontSet() {
        FontSet fs = new FontSet();

        BaseFont bfUnicode = null;
        try {
            // Đường dẫn font Windows – nếu deploy Linux/server khác thì đổi lại cho phù hợp
            String fontPath = "C:/Windows/Fonts/arial.ttf";
            bfUnicode = BaseFont.createFont(fontPath, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
        } catch (Exception ignore) {
            // fallback
        }

        if (bfUnicode != null) {
            fs.title         = new Font(bfUnicode, 18, Font.BOLD, new BaseColor(34, 34, 34));
            fs.subtitle      = new Font(bfUnicode, 10, Font.NORMAL, new BaseColor(107, 114, 128));
            fs.sectionTitle  = new Font(bfUnicode, 11, Font.BOLD, new BaseColor(31, 41, 55));
            fs.tableHeader   = new Font(bfUnicode, 9, Font.BOLD, BaseColor.WHITE);
            fs.tableCell     = new Font(bfUnicode, 9, Font.NORMAL, new BaseColor(31, 41, 55));
            fs.tableCellBold = new Font(bfUnicode, 9, Font.BOLD, new BaseColor(31, 41, 55));
            fs.note          = new Font(bfUnicode, 9, Font.NORMAL, new BaseColor(75, 85, 99));
            fs.footer        = new Font(bfUnicode, 9, Font.ITALIC, new BaseColor(156, 163, 175));
        } else {
            // Fallback HELVETICA
            fs.title         = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD, new BaseColor(34, 34, 34));
            fs.subtitle      = new Font(Font.FontFamily.HELVETICA, 10, Font.NORMAL, new BaseColor(107, 114, 128));
            fs.sectionTitle  = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD, new BaseColor(31, 41, 55));
            fs.tableHeader   = new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD, BaseColor.WHITE);
            fs.tableCell     = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, new BaseColor(31, 41, 55));
            fs.tableCellBold = new Font(Font.FontFamily.HELVETICA, 9, Font.BOLD, new BaseColor(31, 41, 55));
            fs.note          = new Font(Font.FontFamily.HELVETICA, 9, Font.NORMAL, new BaseColor(75, 85, 99));
            fs.footer        = new Font(Font.FontFamily.HELVETICA, 9, Font.ITALIC, new BaseColor(156, 163, 175));
        }

        return fs;
    }

    // ---------------------------------------------------------
    // 1. BRAND HEADER
    // ---------------------------------------------------------
    private static void addBrandHeader(Document doc, FontSet fs) throws Exception {
        PdfPTable headerTable = new PdfPTable(2);
        headerTable.setWidthPercentage(100);
        headerTable.setWidths(new float[]{2f, 1f});
        headerTable.setSpacingAfter(18f);

        // Trái: tên shop + thông tin liên hệ
        PdfPCell left = new PdfPCell();
        left.setBorder(PdfPCell.NO_BORDER);
        left.setPadding(0);

        Paragraph brandName = new Paragraph(SHOP_NAME, fs.title);
        brandName.setSpacingAfter(2f);

        Paragraph brandSub = new Paragraph(SHOP_SUBTITLE, fs.subtitle);
        brandSub.setSpacingAfter(6f);

        Paragraph contact1 = new Paragraph(SHOP_ADDRESS, fs.subtitle);
        Paragraph contact2 = new Paragraph(SHOP_PHONE + "  •  " + SHOP_EMAIL, fs.subtitle);

        left.addElement(brandName);
        left.addElement(brandSub);
        left.addElement(contact1);
        left.addElement(contact2);

        // Phải: block INVOICE
        PdfPCell right = new PdfPCell();
        right.setBorder(PdfPCell.NO_BORDER);

        PdfPTable inner = new PdfPTable(1);
        inner.setWidthPercentage(100f);

        PdfPCell invoiceCell = new PdfPCell(new Phrase(
                "HÓA ĐƠN / INVOICE",
                new Font(fs.sectionTitle.getBaseFont(), 12, Font.BOLD, BaseColor.WHITE)
        ));
        invoiceCell.setBackgroundColor(new BaseColor(24, 24, 27));
        invoiceCell.setHorizontalAlignment(Element.ALIGN_CENTER);
        invoiceCell.setPaddingTop(8f);
        invoiceCell.setPaddingBottom(8f);
        invoiceCell.setBorder(PdfPCell.NO_BORDER);
        inner.addCell(invoiceCell);

        PdfPCell taglineCell = new PdfPCell(new Phrase(
                "Luxury Furniture & Decor",
                new Font(fs.subtitle.getBaseFont(), 8, Font.NORMAL, new BaseColor(209, 213, 219))
        ));
        taglineCell.setBackgroundColor(new BaseColor(24, 24, 27));
        taglineCell.setHorizontalAlignment(Element.ALIGN_CENTER);
        taglineCell.setPaddingBottom(6f);
        taglineCell.setBorder(PdfPCell.NO_BORDER);
        inner.addCell(taglineCell);

        right.addElement(inner);

        headerTable.addCell(left);
        headerTable.addCell(right);

        doc.add(headerTable);
    }

    // ---------------------------------------------------------
    // 2. INFO BLOCK
    // ---------------------------------------------------------
    private static void addInfoBlock(
            Document doc,
            Order order,
            User user,
            NumberFormat currency,
            SimpleDateFormat sdf,
            FontSet fs
    ) throws Exception {

        PdfPTable info = new PdfPTable(2);
        info.setWidthPercentage(100);
        info.setWidths(new float[]{1.4f, 1.6f});
        info.setSpacingAfter(18f);

        BaseColor headerBg = new BaseColor(243, 244, 246); // xám rất nhạt
        BaseColor border   = new BaseColor(229, 231, 235);

        // Header 2 cột
        PdfPCell cell = new PdfPCell(new Phrase("THÔNG TIN KHÁCH HÀNG", fs.sectionTitle));
        cell.setBackgroundColor(headerBg);
        cell.setBorderColor(border);
        cell.setPadding(6f);
        info.addCell(cell);

        cell = new PdfPCell(new Phrase("THÔNG TIN ĐƠN HÀNG", fs.sectionTitle));
        cell.setBackgroundColor(headerBg);
        cell.setBorderColor(border);
        cell.setPadding(6f);
        info.addCell(cell);

        // Nội dung bên trái: khách hàng
        StringBuilder sbLeft = new StringBuilder();
        if (user != null) {
            sbLeft.append("Họ tên: ").append(nz(user.getFullName())).append("\n");
            sbLeft.append("Email: ").append(nz(user.getEmail())).append("\n");
            if (user.getPhone() != null && !user.getPhone().isEmpty()) {
                sbLeft.append("SĐT: ").append(user.getPhone()).append("\n");
            }
            if (user.getAddress() != null && !user.getAddress().isEmpty()) {
                sbLeft.append("Địa chỉ: ").append(user.getAddress()).append("\n");
            }
        } else {
            sbLeft.append("Khách hàng: (Không tìm thấy thông tin)\n");
        }

        PdfPCell left = new PdfPCell(new Phrase(sbLeft.toString(), fs.tableCell));
        left.setPadding(8f);
        left.setBorderColor(border);
        info.addCell(left);

        // Nội dung bên phải: đơn hàng
        StringBuilder sbRight = new StringBuilder();
        sbRight.append("Mã đơn: #").append(order.getOrderID()).append("\n");
        if (order.getOrderDate() != null) {
            sbRight.append("Ngày đặt: ").append(sdf.format(order.getOrderDate())).append("\n");
        }
        sbRight.append("Trạng thái: ").append(nz(order.getStatus())).append("\n");
        sbRight.append("Thanh toán: ").append(nz(order.getPaymentMethod())).append("\n");
        sbRight.append("Địa chỉ giao: ").append(nz(order.getShippingAddress())).append("\n");

        PdfPCell right = new PdfPCell(new Phrase(sbRight.toString(), fs.tableCell));
        right.setPadding(8f);
        right.setBorderColor(border);
        info.addCell(right);

        doc.add(info);
    }

    // ---------------------------------------------------------
    // 3. ITEMS TABLE
    // ---------------------------------------------------------
    private static void addItemsTable(
            Document doc,
            Order order,
            NumberFormat currency,
            FontSet fs
    ) throws Exception {

        PdfPTable table = new PdfPTable(5);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{0.8f, 2.8f, 0.8f, 1.2f, 1.3f});
        table.setSpacingBefore(4f);

        addHeaderCell(table, "STT", fs.tableHeader);
        addHeaderCell(table, "Sản phẩm", fs.tableHeader);
        addHeaderCell(table, "SL", fs.tableHeader);
        addHeaderCell(table, "Đơn giá", fs.tableHeader);
        addHeaderCell(table, "Thành tiền", fs.tableHeader);

        int idx = 1;
        List<OrderItem> items = order.getItems();

        if (items != null) {
            for (OrderItem item : items) {
                double line = item.getUnitPrice() * item.getQuantity();

                table.addCell(makeCell(String.valueOf(idx++), fs.tableCell, Element.ALIGN_CENTER));

                String productName = "Sản phẩm #" + item.getProductID();
                Product pdt = item.getProduct();
                if (pdt != null && pdt.getProductName() != null) {
                    productName = pdt.getProductName();
                }
                table.addCell(makeCell(productName, fs.tableCell, Element.ALIGN_LEFT));

                table.addCell(makeCell(String.valueOf(item.getQuantity()), fs.tableCell, Element.ALIGN_CENTER));
                table.addCell(makeCell(currency.format(item.getUnitPrice()), fs.tableCell, Element.ALIGN_RIGHT));
                table.addCell(makeCell(currency.format(line), fs.tableCellBold, Element.ALIGN_RIGHT));
            }
        }

        doc.add(table);
    }

    // ---------------------------------------------------------
    // 4. SUMMARY & NOTE
    // ---------------------------------------------------------
    private static void addSummaryAndNote(
            Document doc,
            Order order,
            NumberFormat currency,
            FontSet fs
    ) throws Exception {

        double totalFromOrder = order.getTotalAmount();
        double grandTotal = totalFromOrder > 0 ? totalFromOrder : calcTotalFromItems(order);

        double subtotal = calcTotalFromItems(order);
        BaseColor border = new BaseColor(229, 231, 235);

        PdfPTable summary = new PdfPTable(2);
        summary.setWidthPercentage(40);
        summary.setHorizontalAlignment(Element.ALIGN_RIGHT);
        summary.setWidths(new float[]{1.3f, 1.2f});
        summary.setSpacingBefore(12f);

        // Tạm tính
        PdfPCell c1 = new PdfPCell(new Phrase("Tạm tính", fs.tableCell));
        c1.setBorderColor(border);
        c1.setPadding(4f);
        summary.addCell(c1);

        PdfPCell c2 = new PdfPCell(new Phrase(currency.format(subtotal), fs.tableCell));
        c2.setHorizontalAlignment(Element.ALIGN_RIGHT);
        c2.setBorderColor(border);
        c2.setPadding(4f);
        summary.addCell(c2);

        // Nếu totalAmount khác subtotal (có giảm giá / phụ phí)
        if (Math.abs(grandTotal - subtotal) > 0.001) {
            PdfPCell c3 = new PdfPCell(new Phrase("Điều chỉnh", fs.tableCell));
            c3.setBorderColor(border);
            c3.setPadding(4f);
            summary.addCell(c3);

            PdfPCell c4 = new PdfPCell(new Phrase(currency.format(grandTotal - subtotal), fs.tableCell));
            c4.setHorizontalAlignment(Element.ALIGN_RIGHT);
            c4.setBorderColor(border);
            c4.setPadding(4f);
            summary.addCell(c4);
        }

        // Tổng cộng
        PdfPCell c5 = new PdfPCell(new Phrase("Tổng cộng", fs.tableCellBold));
        c5.setBorderColor(border);
        c5.setPadding(6f);
        summary.addCell(c5);

        PdfPCell c6 = new PdfPCell(new Phrase(currency.format(grandTotal), fs.tableCellBold));
        c6.setHorizontalAlignment(Element.ALIGN_RIGHT);
        c6.setBorderColor(border);
        c6.setPadding(6f);
        summary.addCell(c6);

        doc.add(summary);

        // Ghi chú đơn hàng (nếu có)
        if (order.getNote() != null && !order.getNote().trim().isEmpty()) {
            Paragraph noteTitle = new Paragraph("Ghi chú của đơn hàng:", fs.sectionTitle);
            noteTitle.setSpacingBefore(10f);
            noteTitle.setSpacingAfter(4f);
            doc.add(noteTitle);

            Paragraph noteBody = new Paragraph(order.getNote(), fs.note);
            noteBody.setLeading(14f);
            doc.add(noteBody);
        }
    }

    // ---------------------------------------------------------
    // 5. FOOTER
    // ---------------------------------------------------------
    private static void addFooter(Document doc, FontSet fs) throws Exception {
        Paragraph thank = new Paragraph(
                "Cảm ơn bạn đã mua sắm tại LUXE INTERIORS / FurniShop!",
                fs.footer
        );
        thank.setAlignment(Element.ALIGN_CENTER);
        thank.setSpacingBefore(24f);
        doc.add(thank);

        Paragraph site = new Paragraph(
                SHOP_WEBSITE + "  •  " + SHOP_PHONE,
                fs.footer
        );
        site.setAlignment(Element.ALIGN_CENTER);
        site.setSpacingBefore(4f);
        doc.add(site);
    }

    // =========================================================
    // ================== Helper cho bảng ======================
    // =========================================================

    private static void addHeaderCell(PdfPTable t, String text, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBackgroundColor(new BaseColor(31, 41, 55));
        cell.setPadding(6f);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
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

    private static double calcTotalFromItems(Order order) {
        double sum = 0d;
        if (order.getItems() != null) {
            for (OrderItem item : order.getItems()) {
                sum += item.getUnitPrice() * item.getQuantity();
            }
        }
        return sum;
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }
}
