package dal;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO phục vụ Dashboard admin:
 * - Thống kê số lượng users / products / orders / reviews / contacts
 * - Tồn kho: sản phẩm sắp hết, hết hàng, danh sách tồn kho thấp
 * - Doanh thu: tổng doanh thu đơn Done, doanh thu theo khoảng ngày, theo danh mục
 * - Đơn hàng: thống kê theo trạng thái
 * - Người dùng: số user mới theo tháng
 * - Sản phẩm: top bán chạy
 */
public class AdminStatsDAO extends DBContext {

    // ========== 1. Thống kê số lượng đơn giản ==========

    public int countUsers() {
        String sql = "SELECT COUNT(*) FROM users";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int countProducts() {
        String sql = "SELECT COUNT(*) FROM products";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int countOrders() {
        String sql = "SELECT COUNT(*) FROM orders";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    /** Doanh thu chỉ tính các đơn trạng thái 'Done' */
    public BigDecimal sumRevenueDone() {
        String sql = "SELECT COALESCE(SUM(TotalAmount),0) FROM orders WHERE Status = 'Done'";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        } catch (Exception e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }

    public int countReviews() {
        String sql = "SELECT COUNT(*) FROM reviews";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int countContacts() {
        String sql = "SELECT COUNT(*) FROM contacts";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    // ========== 2. Tồn kho: sắp hết, hết hàng, danh sách chi tiết ==========

    /** Đếm số sản phẩm có tồn kho <= threshold (sắp hết hàng) */
    public int countLowStock(int threshold) {
        String sql = "SELECT COUNT(*) FROM products WHERE Stock > 0 AND Stock <= ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    /** Đếm số sản phẩm đã hết hàng (Stock <= 0) */
    public int countOutOfStock() {
        String sql = "SELECT COUNT(*) FROM products WHERE Stock <= 0";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    /** DTO đơn giản cho sản phẩm tồn kho thấp */
    public static class LowStockItem {
        private int productID;
        private String productName;
        private int stock;

        public int getProductID() { return productID; }
        public void setProductID(int productID) { this.productID = productID; }

        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }

        public int getStock() { return stock; }
        public void setStock(int stock) { this.stock = stock; }
    }

    /** Danh sách sản phẩm tồn kho thấp để hiển thị bảng cảnh báo */
    public List<LowStockItem> getLowStockProducts(int threshold) {
        String sql = """
            SELECT ProductID, ProductName, Stock
            FROM products
            WHERE Stock > 0 AND Stock <= ?
            ORDER BY Stock ASC
        """;
        List<LowStockItem> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LowStockItem item = new LowStockItem();
                    item.setProductID(rs.getInt("ProductID"));
                    item.setProductName(rs.getString("ProductName"));
                    item.setStock(rs.getInt("Stock"));
                    list.add(item);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ========== 3. Doanh thu theo thời gian (vẽ biểu đồ line, lọc from/to) ==========

    /** Một điểm dữ liệu doanh thu theo ngày */
    public static class RevenuePoint {
        private String date;        // yyyy-MM-dd
        private BigDecimal total;   // doanh thu trong ngày

        public RevenuePoint(String date, BigDecimal total) {
            this.date = date;
            this.total = total;
        }

        public String getDate() { return date; }
        public BigDecimal getTotal() { return total; }
    }

    /**
     * Doanh thu theo ngày trong khoảng [from, to] (bao gồm hai đầu).
     * Chỉ tính các đơn Status = 'Done'.
     */
    public List<RevenuePoint> getRevenueByDateRange(Date from, Date to) {
        String sql = """
            SELECT DATE(o.OrderDate) AS d, SUM(o.TotalAmount) AS revenue
            FROM orders o
            WHERE o.Status = 'Done'
              AND o.OrderDate >= ? AND o.OrderDate < DATE_ADD(?, INTERVAL 1 DAY)
            GROUP BY DATE(o.OrderDate)
            ORDER BY DATE(o.OrderDate)
        """;
        List<RevenuePoint> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, from);
            ps.setDate(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String d = rs.getString("d");
                    BigDecimal rev = rs.getBigDecimal("revenue");
                    list.add(new RevenuePoint(d, rev));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ========== 4. Đơn hàng theo trạng thái (vẽ biểu đồ tròn) ==========

    public static class StatusCount {
        private String status;
        private int count;

        public StatusCount(String status, int count) {
            this.status = status;
            this.count = count;
        }

        public String getStatus() { return status; }
        public int getCount() { return count; }
    }

    /** Đếm số đơn theo từng trạng thái */
    public List<StatusCount> countOrdersByStatus() {
        String sql = "SELECT Status, COUNT(*) FROM orders GROUP BY Status";
        List<StatusCount> result = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.add(new StatusCount(rs.getString(1), rs.getInt(2)));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // ========== 5. Doanh thu theo danh mục (vẽ biểu đồ cột) ==========

    public static class CategoryRevenue {
        private String categoryName;
        private BigDecimal revenue;

        public CategoryRevenue(String categoryName, BigDecimal revenue) {
            this.categoryName = categoryName;
            this.revenue = revenue;
        }

        public String getCategoryName() { return categoryName; }
        public BigDecimal getRevenue() { return revenue; }
    }

    /**
     * Doanh thu theo danh mục sản phẩm trong khoảng [from, to],
     * chỉ tính đơn Status = 'Done'.
     */
    public List<CategoryRevenue> getRevenueByCategory(Date from, Date to) {
        String sql = """
            SELECT c.CategoryName, SUM(oi.Quantity * oi.Price) AS revenue
            FROM orders o
            JOIN orderitems oi ON oi.OrderID = o.OrderID
            JOIN products p   ON p.ProductID = oi.ProductID
            JOIN categories c ON c.CategoryID = p.CategoryID
            WHERE o.Status = 'Done'
              AND o.OrderDate >= ? AND o.OrderDate < DATE_ADD(?, INTERVAL 1 DAY)
            GROUP BY c.CategoryName
            ORDER BY revenue DESC
        """;
        List<CategoryRevenue> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, from);
            ps.setDate(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new CategoryRevenue(
                        rs.getString("CategoryName"),
                        rs.getBigDecimal("revenue")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ========== 6. User mới theo tháng (biểu đồ cột/đường) ==========

    public static class MonthlyCount {
        private String month; // dạng "2025-01"
        private int count;

        public MonthlyCount(String month, int count) {
            this.month = month;
            this.count = count;
        }

        public String getMonth() { return month; }
        public int getCount() { return count; }
    }

    /** Số user đăng ký mới theo từng tháng của một năm */
    public List<MonthlyCount> getNewUsersByMonth(int year) {
        String sql = """
            SELECT DATE_FORMAT(RegisteredAt, '%Y-%m') AS m, COUNT(*) AS cnt
            FROM users
            WHERE YEAR(RegisteredAt) = ?
            GROUP BY DATE_FORMAT(RegisteredAt, '%Y-%m')
            ORDER BY m
        """;
        List<MonthlyCount> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new MonthlyCount(
                        rs.getString("m"),
                        rs.getInt("cnt")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ========== 7. Top sản phẩm bán chạy (tên + số lượng) ==========

    /** DTO cho top sản phẩm bán chạy */
    public static class TopProduct {
        private int productID;
        private String productName;
        private int totalQuantity;

        public TopProduct(int productID, String productName, int totalQuantity) {
            this.productID = productID;
            this.productName = productName;
            this.totalQuantity = totalQuantity;
        }

        public int getProductID() { return productID; }
        public String getProductName() { return productName; }
        public int getTotalQuantity() { return totalQuantity; }
    }

    /** Top N bán chạy: trả về đối tượng đầy đủ (ID, Name, Quantity) */
    public List<TopProduct> getTopSellingProducts(int limit) {
        String sql = """
            SELECT p.ProductID, p.ProductName, SUM(oi.Quantity) AS totalQty
            FROM orderitems oi
            JOIN products p ON p.ProductID = oi.ProductID
            GROUP BY p.ProductID, p.ProductName
            ORDER BY totalQty DESC
            LIMIT ?
        """;
        List<TopProduct> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new TopProduct(
                        rs.getInt("ProductID"),
                        rs.getString("ProductName"),
                        rs.getInt("totalQty")
                    ));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Giữ lại hàm cũ nếu chỗ khác đang dùng: chỉ trả về tên */
    public List<String> topSellingProductNames(int limit) {
        List<String> names = new ArrayList<>();
        for (TopProduct tp : getTopSellingProducts(limit)) {
            names.add(tp.getProductName());
        }
        return names;
    }
}
