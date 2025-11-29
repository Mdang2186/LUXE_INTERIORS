package Utils;

import dal.AdminStatsDAO;
import dal.AdminStatsDAO.VipCustomer;
import dal.AdminStatsDAO.NewCustomer;
import dal.AdminStatsDAO.MonthlyRevenue;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * MonthlyReportExcelUtil
 *  - Tạo file Excel báo cáo tháng (doanh thu, lợi nhuận, VIP, khách mới).
 *  - Dùng Apache POI (bạn đã dùng sẵn cho xuất Excel orders).
 */
public class MonthlyReportExcelUtil {

    /**
     * Xây dựng file Excel báo cáo tháng và trả về mảng byte.
     *
     * @param year           năm
     * @param month          tháng
     * @param revenueMonth   doanh thu tháng
     * @param profitMonth    lợi nhuận ước tính tháng
     * @param vipList        danh sách khách hàng VIP trong tháng
     * @param newCustomers   danh sách khách hàng mới trong tháng
     * @param revenueYear    doanh thu từng tháng trong năm (có thể null)
     * @param profitYear     lợi nhuận từng tháng trong năm (có thể null)
     */
    public static byte[] buildMonthlyReportWorkbook(
            int year,
            int month,
            BigDecimal revenueMonth,
            BigDecimal profitMonth,
            List<VipCustomer> vipList,
            List<NewCustomer> newCustomers,
            List<MonthlyRevenue> revenueYear,
            List<MonthlyRevenue> profitYear
    ) {
        try (Workbook wb = new XSSFWorkbook();
             ByteArrayOutputStream baos = new ByteArrayOutputStream()) {

            CreationHelper helper = wb.getCreationHelper();

            // ===== STYLE CƠ BẢN =====
            CellStyle headerStyle = wb.createCellStyle();
            Font headerFont = wb.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.LIGHT_YELLOW.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(BorderStyle.THIN);

            CellStyle moneyStyle = wb.createCellStyle();
            moneyStyle.setDataFormat(helper.createDataFormat().getFormat("#,##0"));

            // ===== SHEET 1: TÓM TẮT =====
            Sheet summary = wb.createSheet("Summary");

            int rowIdx = 0;
            Row titleRow = summary.createRow(rowIdx++);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("BÁO CÁO THÁNG " + String.format("%02d/%d", month, year));
            titleCell.getRow().getSheet().createRow(0);
            titleCell.getSheet().addMergedRegion(
                    new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 3)
            );

            Row r1 = summary.createRow(rowIdx++);
            r1.createCell(0).setCellValue("Doanh thu tháng");
            Cell cRev = r1.createCell(1);
            cRev.setCellValue(revenueMonth.doubleValue());
            cRev.setCellStyle(moneyStyle);

            Row r2 = summary.createRow(rowIdx++);
            r2.createCell(0).setCellValue("Lợi nhuận ước tính");
            Cell cProf = r2.createCell(1);
            cProf.setCellValue(profitMonth.doubleValue());
            cProf.setCellStyle(moneyStyle);

            summary.autoSizeColumn(0);
            summary.autoSizeColumn(1);

            // ===== SHEET 2: VIP CUSTOMERS =====
            Sheet vipSheet = wb.createSheet("VipCustomers");
            rowIdx = 0;
            Row hVip = vipSheet.createRow(rowIdx++);
            String[] vipHeaders = {"UserID", "Họ tên", "Email", "Số đơn", "Tổng chi tiêu"};
            for (int i = 0; i < vipHeaders.length; i++) {
                Cell cell = hVip.createCell(i);
                cell.setCellValue(vipHeaders[i]);
                cell.setCellStyle(headerStyle);
            }

            if (vipList != null) {
                for (AdminStatsDAO.VipCustomer v : vipList) {
                    Row r = vipSheet.createRow(rowIdx++);
                    r.createCell(0).setCellValue(v.getUserId());
                    r.createCell(1).setCellValue(v.getFullName());
                    r.createCell(2).setCellValue(v.getEmail());
                    r.createCell(3).setCellValue(v.getOrderCount());
                    Cell cAmt = r.createCell(4);
                    if (v.getTotalSpent() != null) {
                        cAmt.setCellValue(v.getTotalSpent().doubleValue());
                    }
                    cAmt.setCellStyle(moneyStyle);
                }
            }
            for (int i = 0; i < vipHeaders.length; i++) vipSheet.autoSizeColumn(i);

            // ===== SHEET 3: NEW CUSTOMERS =====
            Sheet newSheet = wb.createSheet("NewCustomers");
            rowIdx = 0;
            String[] newHeaders = {"UserID", "Họ tên", "Email", "Ngày tạo"};
            Row hNew = newSheet.createRow(rowIdx++);
            for (int i = 0; i < newHeaders.length; i++) {
                Cell cell = hNew.createCell(i);
                cell.setCellValue(newHeaders[i]);
                cell.setCellStyle(headerStyle);
            }

            if (newCustomers != null) {
                for (AdminStatsDAO.NewCustomer nc : newCustomers) {
                    Row r = newSheet.createRow(rowIdx++);
                    r.createCell(0).setCellValue(nc.getUserId());
                    r.createCell(1).setCellValue(nc.getFullName());
                    r.createCell(2).setCellValue(nc.getEmail());
                    Cell cDate = r.createCell(3);
                    if (nc.getCreatedAt() != null) {
                        cDate.setCellValue(nc.getCreatedAt().toLocalDateTime().toString());
                    }
                }
            }
            for (int i = 0; i < newHeaders.length; i++) newSheet.autoSizeColumn(i);

            // ===== SHEET 4: Revenue & Profit by Month (optional) =====
            Sheet trend = wb.createSheet("RevenueTrend");
            rowIdx = 0;
            Row hTrend = trend.createRow(rowIdx++);
            String[] trendHeaders = {"Tháng", "Doanh thu", "Lợi nhuận"};
            for (int i = 0; i < trendHeaders.length; i++) {
                Cell cell = hTrend.createCell(i);
                cell.setCellValue(trendHeaders[i]);
                cell.setCellStyle(headerStyle);
            }

            if (revenueYear != null) {
                // Map month -> revenue/profit
                java.util.Map<Integer, BigDecimal> revMap = new java.util.HashMap<>();
                for (MonthlyRevenue mr : revenueYear) {
                    revMap.put(mr.getMonth(), mr.getTotal());
                }
                java.util.Map<Integer, BigDecimal> profMap = new java.util.HashMap<>();
                if (profitYear != null) {
                    for (MonthlyRevenue mr : profitYear) {
                        profMap.put(mr.getMonth(), mr.getTotal());
                    }
                }

                for (int m = 1; m <= 12; m++) {
                    Row r = trend.createRow(rowIdx++);
                    r.createCell(0).setCellValue(m);
                    Cell cR = r.createCell(1);
                    BigDecimal rv = revMap.getOrDefault(m, BigDecimal.ZERO);
                    cR.setCellValue(rv.doubleValue());
                    cR.setCellStyle(moneyStyle);

                    Cell cP = r.createCell(2);
                    BigDecimal pf = profMap.getOrDefault(m, BigDecimal.ZERO);
                    cP.setCellValue(pf.doubleValue());
                    cP.setCellStyle(moneyStyle);
                }
            }
            for (int i = 0; i < trendHeaders.length; i++) trend.autoSizeColumn(i);

            // ===== Ghi ra byte[] =====
            wb.write(baos);
            return baos.toByteArray();
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}
