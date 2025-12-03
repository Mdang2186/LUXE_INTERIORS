package Utils;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import model.Order;

import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.List;

public class OrdersPdfUtil {

    private static final Font FONT_TITLE = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 16);
    private static final Font FONT_HEADER = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
    private static final Font FONT_CELL = FontFactory.getFont(FontFactory.HELVETICA, 9);

    public static void exportOrders(List<Order> orders, OutputStream out) throws Exception {
        Document doc = new Document(PageSize.A4.rotate(), 36, 36, 36, 36);
        PdfWriter.getInstance(doc, out);
        doc.open();

        // Tiêu đề
        Paragraph title = new Paragraph("Danh sách đơn hàng FurniShop", FONT_TITLE);
        title.setAlignment(Element.ALIGN_CENTER);
        title.setSpacingAfter(10f);
        doc.add(title);

        // Bảng
        PdfPTable table = new PdfPTable(6); // ID, Ngày, KH, Trạng thái, Thanh toán, Tổng
        table.setWidthPercentage(100);
        table.setWidths(new float[]{8f, 16f, 24f, 14f, 14f, 14f});
        table.setHeaderRows(1);

        addHeaderCell(table, "Mã đơn");
        addHeaderCell(table, "Ngày đặt");
        addHeaderCell(table, "Mã KH");
        addHeaderCell(table, "Trạng thái");
        addHeaderCell(table, "Thanh toán");
        addHeaderCell(table, "Tổng tiền");

        SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm");

        for (Order o : orders) {
            if (o == null) continue;

            addCell(table, String.valueOf(o.getOrderID()));
            addCell(table, o.getOrderDate() == null ? "" : df.format(o.getOrderDate()));
            addCell(table, String.valueOf(o.getUserID()));
            addCell(table, o.getStatus());
            addCell(table, o.getPaymentMethod());
            addCell(table, String.format("%,.0f", o.getTotalAmount()));
        }

        doc.add(table);
        doc.close();
    }

    private static void addHeaderCell(PdfPTable table, String text) {
        PdfPCell cell = new PdfPCell(new Phrase(text, FONT_HEADER));
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setBackgroundColor(new BaseColor(230, 230, 250));
        cell.setPadding(5f);
        table.addCell(cell);
    }

    private static void addCell(PdfPTable table, String text) {
        PdfPCell cell = new PdfPCell(new Phrase(text == null ? "" : text, FONT_CELL));
        cell.setPadding(4f);
        table.addCell(cell);
    }
}
