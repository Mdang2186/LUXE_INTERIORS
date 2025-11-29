package Utils;

import java.io.OutputStream;
import java.math.BigDecimal;
import java.util.List;

import dal.AdminStatsDAO.VipCustomer;
import dal.AdminStatsDAO.BrandRevenue;
import dal.AdminStatsDAO.HourStat;
import dal.AdminStatsDAO.CategoryRevenue;   // <<-- THÊM
import java.io.IOException;
import model.Order;
import model.Product;
import model.User;                          // <<-- THÊM

// POI
import org.apache.poi.hssf.usermodel.HSSFWorkbook;     // .xls
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.DataFormat;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * Các hàm xuất Excel cho FurniShop (POI 5.x, HSSFWorkbook - .xls).
 *  - exportOrders           : danh sách đơn hàng
 *  - exportRevenueStats     : thống kê doanh thu theo ngày
 *  - exportVipCustomers     : khách hàng VIP
 *  - exportBrandRevenue     : doanh thu theo thương hiệu
 *  - exportPeakHours        : giờ vàng đặt hàng
 *  - exportProducts         : danh sách sản phẩm (đầy đủ thông tin)
 *
 *  (MỚI)
 *  - exportCategoryRevenue  : doanh thu theo danh mục + tỷ trọng %
 *  - exportNewUsers         : danh sách khách hàng mới
 */
public class ExcelExportUtil {

    // =========================================================
    // 1. Xuất danh sách ĐƠN HÀNG
    // =========================================================

    
    // =========================================================
    // 2. Xuất THỐNG KÊ doanh thu theo ngày
    // =========================================================

    /** Export thống kê doanh thu theo ngày (labels + values) */
    public static void exportRevenueStats(List<String> labels,
                                          List<BigDecimal> values,
                                          OutputStream out) throws Exception {
        Workbook wb = new HSSFWorkbook();
        try {
            Sheet sheet = wb.createSheet("Revenue");

            CellStyle headerStyle = createHeaderStyle(wb);
            CellStyle moneyStyle  = createMoneyStyle(wb);
            CellStyle textStyle   = createTextCellStyle(wb);

            // HEADER
            Row header = sheet.createRow(0);
            header.setHeightInPoints(22);
            Cell h0 = header.createCell(0);
            h0.setCellValue("Date");
            h0.setCellStyle(headerStyle);

            Cell h1 = header.createCell(1);
            h1.setCellValue("TotalRevenue");
            h1.setCellStyle(headerStyle);

            // DATA
            if (labels != null) {
                for (int i = 0; i < labels.size(); i++) {
                    Row r = sheet.createRow(i + 1);

                    // Date (string)
                    Cell c0 = r.createCell(0);
                    c0.setCellValue(labels.get(i));
                    c0.setCellStyle(textStyle);

                    // Revenue
                    BigDecimal v = (values != null && i < values.size() && values.get(i) != null)
                            ? values.get(i)
                            : BigDecimal.ZERO;

                    Cell c1 = r.createCell(1);
                    c1.setCellValue(v.doubleValue());
                    c1.setCellStyle(moneyStyle);
                }
            }

            sheet.autoSizeColumn(0);
            sheet.autoSizeColumn(1);
            sheet.createFreezePane(0, 1);

            wb.write(out);
        } finally {
            wb.close();
        }
    }

    // =========================================================
    // 3. Xuất danh sách KHÁCH HÀNG VIP
    // =========================================================

    /** Export danh sách khách hàng VIP sang Excel (.xls).
     *  Lưu ý:
     *   - Nếu bạn muốn Top 5 VIP trong tháng thì ở AdminStatsDAO
     *     hãy lọc sẵn top 5 rồi truyền list đó vào đây.
     */
    public static void exportVipCustomers(List<VipCustomer> vipCustomers,
                                          OutputStream out) throws Exception {
        Workbook wb = new HSSFWorkbook();
        try {
            Sheet sheet = wb.createSheet("VIP Customers");

            CellStyle headerStyle = createHeaderStyle(wb);
            CellStyle moneyStyle  = createMoneyStyle(wb);
            CellStyle textStyle   = createTextCellStyle(wb);

            int rowIdx = 0;

            // HEADER
            Row header = sheet.createRow(rowIdx++);
            header.setHeightInPoints(22);
            String[] heads = {
                    "STT", "UserID", "Họ tên", "Email",
                    "Tổng chi tiêu", "Số đơn"
            };
            for (int i = 0; i < heads.length; i++) {
                Cell c = header.createCell(i);
                c.setCellValue(heads[i]);
                c.setCellStyle(headerStyle);
            }

            // DATA
            if (vipCustomers != null) {
                int stt = 1;
                for (VipCustomer v : vipCustomers) {
                    Row r = sheet.createRow(rowIdx++);
                    int col = 0;

                    // STT
                    Cell c0 = r.createCell(col++);
                    c0.setCellValue(stt++);
                    c0.setCellStyle(textStyle);

                    // UserID
                    Cell c1 = r.createCell(col++);
                    c1.setCellValue(v.getUserId());
                    c1.setCellStyle(textStyle);

                    // FullName
                    Cell c2 = r.createCell(col++);
                    c2.setCellValue(nz(v.getFullName()));
                    c2.setCellStyle(textStyle);

                    // Email
                    Cell c3 = r.createCell(col++);
                    c3.setCellValue(nz(v.getEmail()));
                    c3.setCellStyle(textStyle);

                    // TotalSpent
                    Cell c4 = r.createCell(col++);
                    if (v.getTotalSpent() != null) {
                        c4.setCellValue(v.getTotalSpent().doubleValue());
                    } else {
                        c4.setCellValue(0d);
                    }
                    c4.setCellStyle(moneyStyle);

                    // OrderCount
                    Cell c5 = r.createCell(col++);
                    c5.setCellValue(v.getOrderCount());
                    c5.setCellStyle(textStyle);
                }
            }

            for (int i = 0; i < 6; i++) {
                sheet.autoSizeColumn(i);
            }

            sheet.createFreezePane(0, 1);

            wb.write(out);
        } finally {
            wb.close();
        }
    }

    // =========================================================
    // 4. Xuất DOANH THU THEO THƯƠNG HIỆU
    // =========================================================

    public static void exportBrandRevenue(List<BrandRevenue> brands,
                                          OutputStream out) throws Exception {
        Workbook wb = new HSSFWorkbook();
        try {
            Sheet sheet = wb.createSheet("Brand Revenue");

            CellStyle headerStyle = createHeaderStyle(wb);
            CellStyle moneyStyle  = createMoneyStyle(wb);
            CellStyle textStyle   = createTextCellStyle(wb);

            int rowIdx = 0;

            // HEADER
            Row header = sheet.createRow(rowIdx++);
            header.setHeightInPoints(22);
            String[] heads = {
                    "STT", "Thương hiệu", "Tổng doanh thu", "Số đơn"
            };
            for (int i = 0; i < heads.length; i++) {
                Cell c = header.createCell(i);
                c.setCellValue(heads[i]);
                c.setCellStyle(headerStyle);
            }

            // DATA
            if (brands != null) {
                int stt = 1;
                for (BrandRevenue b : brands) {
                    Row r = sheet.createRow(rowIdx++);
                    int col = 0;

                    Cell c0 = r.createCell(col++);
                    c0.setCellValue(stt++);
                    c0.setCellStyle(textStyle);

                    Cell c1 = r.createCell(col++);
                    c1.setCellValue(nz(b.getBrandName()));
                    c1.setCellStyle(textStyle);

                    Cell c2 = r.createCell(col++);
                    if (b.getRevenue() != null) {
                        c2.setCellValue(b.getRevenue().doubleValue());
                    } else {
                        c2.setCellValue(0d);
                    }
                    c2.setCellStyle(moneyStyle);

                    Cell c3 = r.createCell(col++);
                    c3.setCellValue(b.getOrderCount());
                    c3.setCellStyle(textStyle);
                }
            }

            for (int i = 0; i < 4; i++) {
                sheet.autoSizeColumn(i);
            }

            sheet.createFreezePane(0, 1);

            wb.write(out);
        } finally {
            wb.close();
        }
    }

    // =========================================================
    // 5. Xuất GIỜ VÀNG ĐẶT HÀNG
    // =========================================================

    public static void exportPeakHours(List<HourStat> hours,
                                       OutputStream out) throws Exception {
        Workbook wb = new HSSFWorkbook();
        try {
            Sheet sheet = wb.createSheet("Peak Hours");

            CellStyle headerStyle = createHeaderStyle(wb);
            CellStyle textStyle   = createTextCellStyle(wb);

            int rowIdx = 0;

            // HEADER
            Row header = sheet.createRow(rowIdx++);
            header.setHeightInPoints(22);
            String[] heads = { "Giờ", "Số đơn" };
            for (int i = 0; i < heads.length; i++) {
                Cell c = header.createCell(i);
                c.setCellValue(heads[i]);
                c.setCellStyle(headerStyle);
            }

            // DATA
            if (hours != null) {
                for (HourStat h : hours) {
                    Row r = sheet.createRow(rowIdx++);
                    int col = 0;

                    Cell c0 = r.createCell(col++);
                    c0.setCellValue(h.getHour());
                    c0.setCellStyle(textStyle);

                    Cell c1 = r.createCell(col++);
                    c1.setCellValue(h.getOrderCount());
                    c1.setCellStyle(textStyle);
                }
            }

            for (int i = 0; i < 2; i++) {
                sheet.autoSizeColumn(i);
            }

            sheet.createFreezePane(0, 1);

            wb.write(out);
        } finally {
            wb.close();
        }
    }

    // =========================================================
    // 6. Xuất DANH SÁCH SẢN PHẨM (đầy đủ)
    // =========================================================

    /** Export danh sách sản phẩm (.xls) theo list Product hiện có */
    public static void exportProducts(List<Product> products, OutputStream out) throws Exception {
        if (products == null) {
            products = java.util.Collections.emptyList();
        }

        Workbook wb = new HSSFWorkbook();
        try {
            Sheet sheet = wb.createSheet("Products");

            CellStyle headerStyle = createHeaderStyle(wb);
            CellStyle textStyle   = createTextCellStyle(wb);
            CellStyle moneyStyle  = createMoneyStyle(wb);

            int rowIdx = 0;

            // HEADER
            Row header = sheet.createRow(rowIdx++);
            header.setHeightInPoints(23);
            String[] heads = {
                    "ID", "Tên sản phẩm", "Danh mục",
                    "Thương hiệu", "Giá", "Tồn kho",
                    "Chất liệu", "Kích thước", "Ảnh (ImageURL)", "Tính năng"
            };
            for (int i = 0; i < heads.length; i++) {
                Cell c = header.createCell(i);
                c.setCellValue(heads[i]);
                c.setCellStyle(headerStyle);
            }

            // DATA
            int count = 0;
            for (Product p : products) {
                Row r = sheet.createRow(rowIdx++);
                r.setHeightInPoints(18);
                int col = 0;

                // ID
                Cell c0 = r.createCell(col++);
                c0.setCellValue(p.getProductID());
                c0.setCellStyle(textStyle);

                // Name
                Cell c1 = r.createCell(col++);
                c1.setCellValue(nz(p.getProductName()));
                c1.setCellStyle(textStyle);

                // CategoryID
                Cell c2 = r.createCell(col++);
                c2.setCellValue(p.getCategoryID());
                c2.setCellStyle(textStyle);

                // Brand
                Cell c3 = r.createCell(col++);
                c3.setCellValue(nz(p.getBrand()));
                c3.setCellStyle(textStyle);

                // Price
                Cell c4 = r.createCell(col++);
                c4.setCellValue(p.getPrice());
                c4.setCellStyle(moneyStyle);

                // Stock
                Cell c5 = r.createCell(col++);
                c5.setCellValue(p.getStock());
                c5.setCellStyle(textStyle);

                // Material
                Cell c6 = r.createCell(col++);
                c6.setCellValue(nz(p.getMaterial()));
                c6.setCellStyle(textStyle);

                // Dimensions
                Cell c7 = r.createCell(col++);
                c7.setCellValue(nz(p.getDimensions()));
                c7.setCellStyle(textStyle);

                // ImageURL
                Cell c8 = r.createCell(col++);
                c8.setCellValue(nz(p.getImageURL()));
                c8.setCellStyle(textStyle);

                // Features
                Cell c9 = r.createCell(col++);
                c9.setCellValue(nz(p.getFeatures()));
                c9.setCellStyle(textStyle);

                count++;
            }

            System.out.println("[EXPORT-EXCEL] Rows exported = " + count);

            // Auto-size
            for (int i = 0; i < heads.length; i++) {
                sheet.autoSizeColumn(i);
            }

            // Freeze header + AutoFilter cho toàn bảng
            sheet.createFreezePane(0, 1);
            sheet.setAutoFilter(new CellRangeAddress(0, rowIdx - 1, 0, heads.length - 1));

            wb.write(out);
            out.flush();
        } finally {
            wb.close();
        }
    }

    // =========================================================
    // 7. (MỚI) Xuất DOANH THU THEO DANH MỤC + TỶ TRỌNG %
    // =========================================================

    /**
     * Export doanh thu theo danh mục:
     *  - STT, Tên danh mục, Tổng doanh thu, Tỷ trọng (% theo tổng doanh thu).
     *  Dữ liệu CategoryRevenue lấy từ AdminStatsDAO.getRevenueByCategory(...)
     */
    public static void exportCategoryRevenue(List<CategoryRevenue> categories,
                                             OutputStream out) throws Exception {
        Workbook wb = new HSSFWorkbook();
        try {
            Sheet sheet = wb.createSheet("Category Revenue");

            CellStyle headerStyle  = createHeaderStyle(wb);
            CellStyle moneyStyle   = createMoneyStyle(wb);
            CellStyle percentStyle = createPercentStyle(wb);
            CellStyle textStyle    = createTextCellStyle(wb);

            int rowIdx = 0;

            // Tính tổng doanh thu để ra %.
            BigDecimal totalRevenue = BigDecimal.ZERO;
            if (categories != null) {
                for (CategoryRevenue c : categories) {
                    if (c.getRevenue() != null) {
                        totalRevenue = totalRevenue.add(c.getRevenue());
                    }
                }
            }

            // HEADER
            Row header = sheet.createRow(rowIdx++);
            header.setHeightInPoints(22);
            String[] heads = {
                    "STT", "Danh mục", "Tổng doanh thu", "Tỷ trọng (%)"
            };
            for (int i = 0; i < heads.length; i++) {
                Cell cell = header.createCell(i);
                cell.setCellValue(heads[i]);
                cell.setCellStyle(headerStyle);
            }

            // DATA
            if (categories != null) {
                int stt = 1;
                for (CategoryRevenue c : categories) {
                    Row r = sheet.createRow(rowIdx++);
                    int col = 0;

                    // STT
                    Cell c0 = r.createCell(col++);
                    c0.setCellValue(stt++);
                    c0.setCellStyle(textStyle);

                    // CategoryName
                    Cell c1 = r.createCell(col++);
                    c1.setCellValue(nz(c.getCategoryName()));
                    c1.setCellStyle(textStyle);

                    // Revenue
                    BigDecimal rev = (c.getRevenue() != null) ? c.getRevenue() : BigDecimal.ZERO;
                    Cell c2 = r.createCell(col++);
                    c2.setCellValue(rev.doubleValue());
                    c2.setCellStyle(moneyStyle);

                    // Percentage
                    Cell c3 = r.createCell(col++);
                    double percent = 0d;
                    if (totalRevenue.compareTo(BigDecimal.ZERO) > 0) {
                        percent = rev.divide(totalRevenue, 4, BigDecimal.ROUND_HALF_UP).doubleValue();
                    }
                    c3.setCellValue(percent);
                    c3.setCellStyle(percentStyle);
                }
            }

            for (int i = 0; i < heads.length; i++) {
                sheet.autoSizeColumn(i);
            }
            sheet.createFreezePane(0, 1);

            wb.write(out);
        } finally {
            wb.close();
        }
    }

    // =========================================================
    // 8. (MỚI) Xuất DANH SÁCH KHÁCH HÀNG MỚI
    // =========================================================

    /**
     * Export danh sách khách hàng mới:
     *  - Bạn có thể truyền vào list User đã lọc "đăng ký trong tháng này".
     *  - Cột: STT, UserID, Họ tên, Email, SĐT.
     */
    public static void exportNewUsers(List<User> newUsers,
                                      OutputStream out) throws Exception {
        Workbook wb = new HSSFWorkbook();
        try {
            Sheet sheet = wb.createSheet("New Customers");

            CellStyle headerStyle = createHeaderStyle(wb);
            CellStyle textStyle   = createTextCellStyle(wb);

            int rowIdx = 0;

            String[] heads = {
                    "STT", "UserID", "Họ tên", "Email", "SĐT"
            };
            Row header = sheet.createRow(rowIdx++);
            header.setHeightInPoints(22);
            for (int i = 0; i < heads.length; i++) {
                Cell c = header.createCell(i);
                c.setCellValue(heads[i]);
                c.setCellStyle(headerStyle);
            }

            if (newUsers != null) {
                int stt = 1;
                for (User u : newUsers) {
                    Row r = sheet.createRow(rowIdx++);
                    int col = 0;

                    Cell c0 = r.createCell(col++);
                    c0.setCellValue(stt++);
                    c0.setCellStyle(textStyle);

                    Cell c1 = r.createCell(col++);
                    c1.setCellValue(u.getUserID());
                    c1.setCellStyle(textStyle);

                    Cell c2 = r.createCell(col++);
                    c2.setCellValue(nz(u.getFullName()));
                    c2.setCellStyle(textStyle);

                    Cell c3 = r.createCell(col++);
                    c3.setCellValue(nz(u.getEmail()));
                    c3.setCellStyle(textStyle);

                    Cell c4 = r.createCell(col++);
                    c4.setCellValue(nz(u.getPhone()));
                    c4.setCellStyle(textStyle);
                }
            }

            for (int i = 0; i < heads.length; i++) {
                sheet.autoSizeColumn(i);
            }
            sheet.createFreezePane(0, 1);

            wb.write(out);
        } finally {
            wb.close();
        }
    }

    // =========================================================
    // ================ CÁC HÀM TẠO STYLE ======================
    // =========================================================

    /** Style cho header: nền xanh đậm + chữ trắng + border */
    private static CellStyle createHeaderStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();

        Font headerFont = wb.createFont();
        headerFont.setBold(true);
        headerFont.setColor(IndexedColors.WHITE.getIndex());
        headerFont.setFontHeightInPoints((short) 11);
        headerFont.setFontName("Calibri");
        style.setFont(headerFont);

        style.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);

        style.setBorderBottom(BorderStyle.MEDIUM);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);

        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);

        return style;
    }

    /** Style cho text thông thường */
    private static CellStyle createTextCellStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();

        Font font = wb.createFont();
        font.setBold(false);
        font.setFontHeightInPoints((short) 10);
        font.setFontName("Calibri");
        style.setFont(font);

        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);

        style.setAlignment(HorizontalAlignment.LEFT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setWrapText(true);

        return style;
    }

    /** Style cho tiền tệ (căn phải, format #,##0) */
    private static CellStyle createMoneyStyle(Workbook wb) {
        CellStyle style = createTextCellStyle(wb);
        style.setAlignment(HorizontalAlignment.RIGHT);

        DataFormat df = wb.createDataFormat();
        style.setDataFormat(df.getFormat("#,##0"));

        return style;
    }

    /** Style cho ngày (format dd/MM/yyyy HH:mm) */
    private static CellStyle createDateStyle(Workbook wb) {
        CellStyle style = createTextCellStyle(wb);

        DataFormat df = wb.createDataFormat();
        style.setDataFormat(df.getFormat("dd/MM/yyyy HH:mm"));

        return style;
    }

    /** Style cho phần trăm (0.0%) */
    private static CellStyle createPercentStyle(Workbook wb) {
        CellStyle style = createTextCellStyle(wb);
        style.setAlignment(HorizontalAlignment.RIGHT);

        DataFormat df = wb.createDataFormat();
        style.setDataFormat(df.getFormat("0.0%"));

        return style;
    }

    private static String nz(String s) {
        return (s == null) ? "" : s;
    }
     /**
     * Xuất danh sách đơn hàng ra file Excel (XLSX) vào OutputStream.
     */
    public static void exportOrders(List<Order> orders, OutputStream out) throws IOException {
        if (orders == null) {
            throw new IllegalArgumentException("orders is null");
        }

        try (Workbook wb = new XSSFWorkbook()) {
            CreationHelper helper = wb.getCreationHelper();
            Sheet sheet = wb.createSheet("Orders");

            // ===== STYLE =====
            // Header style
            CellStyle headerStyle = wb.createCellStyle();
            Font headerFont = wb.createFont();
            headerFont.setBold(true);
            headerFont.setFontHeightInPoints((short) 11);
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setBorderTop(BorderStyle.THIN);
            headerStyle.setBorderLeft(BorderStyle.THIN);
            headerStyle.setBorderRight(BorderStyle.THIN);

            // Date style
            CellStyle dateStyle = wb.createCellStyle();
            dateStyle.setDataFormat(
                    helper.createDataFormat().getFormat("dd/MM/yyyy HH:mm")
            );
            dateStyle.setBorderBottom(BorderStyle.THIN);
            dateStyle.setBorderTop(BorderStyle.THIN);
            dateStyle.setBorderLeft(BorderStyle.THIN);
            dateStyle.setBorderRight(BorderStyle.THIN);

            // Number (money) style
            CellStyle moneyStyle = wb.createCellStyle();
            moneyStyle.setDataFormat(
                    helper.createDataFormat().getFormat("#,##0")
            );
            moneyStyle.setBorderBottom(BorderStyle.THIN);
            moneyStyle.setBorderTop(BorderStyle.THIN);
            moneyStyle.setBorderLeft(BorderStyle.THIN);
            moneyStyle.setBorderRight(BorderStyle.THIN);

            // Normal cell style
            CellStyle normalStyle = wb.createCellStyle();
            normalStyle.setBorderBottom(BorderStyle.THIN);
            normalStyle.setBorderTop(BorderStyle.THIN);
            normalStyle.setBorderLeft(BorderStyle.THIN);
            normalStyle.setBorderRight(BorderStyle.THIN);

            // ===== HEADER ROW =====
            String[] headers = {
                    "Order ID",
                    "User ID",
                    "Order Date",
                    "Status",
                    "Payment",
                    "Total Amount"
            };

            int rowIdx = 0;
            Row headerRow = sheet.createRow(rowIdx++);
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }

            // ===== DATA ROWS =====
            for (Order o : orders) {
                if (o == null) continue;

                Row row = sheet.createRow(rowIdx++);
                int col = 0;

                // Order ID
                Cell c0 = row.createCell(col++);
                c0.setCellValue(o.getOrderID());
                c0.setCellStyle(normalStyle);

                // User ID
                Cell c1 = row.createCell(col++);
                c1.setCellValue(o.getUserID());
                c1.setCellStyle(normalStyle);

                // Order date
                Cell c2 = row.createCell(col++);
                if (o.getOrderDate() != null) {
                    // getOrderDate() thường là java.util.Date
                    c2.setCellValue(o.getOrderDate());
                    c2.setCellStyle(dateStyle);
                } else {
                    c2.setCellValue("");
                    c2.setCellStyle(normalStyle);
                }

                // Status
                Cell c3 = row.createCell(col++);
                c3.setCellValue(o.getStatus() == null ? "" : o.getStatus());
                c3.setCellStyle(normalStyle);

                // Payment method
                Cell c4 = row.createCell(col++);
                c4.setCellValue(o.getPaymentMethod() == null ? "" : o.getPaymentMethod());
                c4.setCellStyle(normalStyle);

                // Total amount
                Cell c5 = row.createCell(col++);
                try {
                    c5.setCellValue(o.getTotalAmount()); // double
                } catch (Exception ex) {
                    // Nếu là BigDecimal thì có thể dùng doubleValue()
                    // c5.setCellValue(o.getTotalAmount().doubleValue());
                    c5.setCellValue(0);
                }
                c5.setCellStyle(moneyStyle);
            }

            // Auto-size cột
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }

            // Ghi workbook ra stream
            wb.write(out);
            out.flush();
        }
    }
}
