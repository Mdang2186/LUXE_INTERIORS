package dal;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import model.Product;
import model.User;

/**
 * AdminStatsDAO
 *  - Cung cấp dữ liệu cho Dashboard & các báo cáo nâng cao.
 *
 *  Bảng giả định:
 *  - Users(UserID, FullName, Email, CreatedAt, ...)
 *  - Products(ProductID, ProductName, Brand, Stock, CostPrice, ...)
 *  - Orders(OrderID, UserID, OrderDate, TotalAmount, Status, PaymentMethod, ShippingAddress, ...)
 *  - OrderItems(OrderItemID, OrderID, ProductID, Quantity, UnitPrice, ...)
 *  - Categories(CategoryID, CategoryName, ...)
 *  - Reviews, Contacts ...
 */
public class AdminStatsDAO extends DBContext {

    /* ================== 1. COUNTERS CƠ BẢN ================== */

    public int countUsers() {
        String sql = "SELECT COUNT(*) FROM Users";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int countProducts() {
        String sql = "SELECT COUNT(*) FROM Products";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int countOrders() {
        String sql = "SELECT COUNT(*) FROM Orders";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    /** Doanh thu chỉ tính các đơn đã hoàn tất (Status = 'Done'). */
    public BigDecimal sumRevenueDone() {
        String sql = "SELECT COALESCE(SUM(TotalAmount),0) FROM Orders WHERE Status = 'Done'";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        } catch (Exception e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }

    public int countReviews() {
        String sql = "SELECT COUNT(*) FROM Reviews";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    public int countContacts() {
        String sql = "SELECT COUNT(*) FROM Contacts";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    /* ================== 2. TỒN KHO / STOCK ================== */

    /** Số sản phẩm có Stock <= ngưỡng cảnh báo (low stock, gồm cả hết hàng). */
    public int countLowStock(int threshold) {
        String sql = "SELECT COUNT(*) FROM Products WHERE Stock <= ?";
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

    /** Số sản phẩm đã hết hàng (Stock = 0). */
    public int countOutOfStock() {
        String sql = "SELECT COUNT(*) FROM Products WHERE Stock = 0";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }

    /**
     * Danh sách sản phẩm tồn kho thấp (dùng cho bảng cảnh báo).
     * Trả về model.Product để JSP dùng ${p.productID}, ${p.productName}, ${p.stock}.
     */
    public List<Product> getLowStockProducts(int threshold) {
        String sql =
            "SELECT ProductID, ProductName, Stock " +
            "FROM Products " +
            "WHERE Stock IS NOT NULL AND Stock <= ? " +
            "ORDER BY Stock ASC, ProductName ASC " +
            "LIMIT 10"; // lấy tối đa 10 sản phẩm

        List<Product> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductID(rs.getInt("ProductID"));
                    p.setProductName(rs.getString("ProductName"));
                    p.setStock(rs.getInt("Stock"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ================== 3. DOANH THU THEO THỜI GIAN ================== */

    /** Điểm doanh thu theo ngày trong khoảng [from, to]. */
    public List<RevenuePoint> getRevenueByDateRange(java.sql.Date from, java.sql.Date to) {
        String sql = "SELECT DATE(OrderDate) AS d, COALESCE(SUM(TotalAmount),0) AS s "
                   + "FROM Orders "
                   + "WHERE OrderDate BETWEEN ? AND ? AND Status = 'Done' "
                   + "GROUP BY DATE(OrderDate) ORDER BY d";
        List<RevenuePoint> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, from);
            ps.setDate(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RevenuePoint rp = new RevenuePoint();
                    rp.setDate(rs.getString("d"));
                    rp.setTotal(rs.getBigDecimal("s"));
                    list.add(rp);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Đếm đơn hàng theo Status để vẽ chart doughnut. */
    public List<StatusCount> countOrdersByStatus() {
        String sql = "SELECT Status, COUNT(*) AS c FROM Orders GROUP BY Status";
        List<StatusCount> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                StatusCount sc = new StatusCount();
                sc.setStatus(rs.getString("Status"));
                sc.setCount(rs.getInt("c"));
                list.add(sc);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Doanh thu theo Category trong khoảng ngày (dùng cho biểu đồ cột).
     */
    public List<CategoryRevenue> getRevenueByCategory(java.sql.Date from, java.sql.Date to) {
        String sql = "SELECT c.CategoryName, " +
                     "       COALESCE(SUM(oi.Quantity * oi.UnitPrice),0) AS revenue, " +
                     "       COUNT(DISTINCT o.OrderID) AS orderCount " +
                     "FROM Categories c " +
                     "JOIN Products p ON p.CategoryID = c.CategoryID " +
                     "JOIN OrderItems oi ON oi.ProductID = p.ProductID " +
                     "JOIN Orders o ON o.OrderID = oi.OrderID AND o.Status = 'Done' " +
                     "WHERE o.OrderDate BETWEEN ? AND ? " +
                     "GROUP BY c.CategoryID, c.CategoryName " +
                     "ORDER BY revenue DESC";
        List<CategoryRevenue> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, from);
            ps.setDate(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CategoryRevenue cr = new CategoryRevenue();
                    cr.setCategoryName(rs.getString("CategoryName"));
                    cr.setRevenue(rs.getBigDecimal("revenue"));
                    cr.setOrderCount(rs.getInt("orderCount"));
                    list.add(cr);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Số user mới theo tháng của 1 năm (dùng cho biểu đồ cột/line). */
    public List<MonthlyCount> getNewUsersByMonth(int year) {
        String sql = "SELECT DATE_FORMAT(CreatedAt, '%Y-%m') AS ym, COUNT(*) AS c "
                   + "FROM Users WHERE YEAR(CreatedAt) = ? "
                   + "GROUP BY ym ORDER BY ym";
        List<MonthlyCount> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MonthlyCount mc = new MonthlyCount();
                    mc.setMonth(rs.getString("ym"));
                    mc.setCount(rs.getInt("c"));
                    list.add(mc);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ================== 4. TOP PRODUCTS / VIP CUSTOMERS ================== */

    /** Top N sản phẩm bán chạy (đã hoàn tất). */
    public List<TopProduct> getTopSellingProducts(int limit) {
        String sql = "SELECT p.ProductID, p.ProductName, COALESCE(SUM(oi.Quantity),0) AS qty "
                   + "FROM OrderItems oi "
                   + "JOIN Products p ON p.ProductID = oi.ProductID "
                   + "JOIN Orders o ON o.OrderID = oi.OrderID AND o.Status = 'Done' "
                   + "GROUP BY p.ProductID, p.ProductName "
                   + "ORDER BY qty DESC "
                   + "LIMIT ?";
        List<TopProduct> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TopProduct t = new TopProduct();
                    t.setProductID(rs.getInt("ProductID"));
                    t.setProductName(rs.getString("ProductName"));
                    t.setQuantity(rs.getInt("qty"));
                    list.add(t);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Top khách hàng chi tiêu nhiều nhất (VIP) – toàn thời gian. */
    public List<VipCustomer> getTopVipCustomers(int limit) {
        String sql = "SELECT u.UserID, u.FullName, u.Email, "
                   + "       COUNT(o.OrderID) AS orderCount, "
                   + "       COALESCE(SUM(o.TotalAmount),0) AS totalSpent "
                   + "FROM Orders o "
                   + "JOIN Users u ON u.UserID = o.UserID "
                   + "WHERE o.Status = 'Done' "
                   + "GROUP BY u.UserID, u.FullName, u.Email "
                   + "ORDER BY totalSpent DESC "
                   + "LIMIT ?";
        List<VipCustomer> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VipCustomer v = new VipCustomer();
                    v.setUserId(rs.getInt("UserID"));
                    v.setFullName(rs.getString("FullName"));
                    v.setEmail(rs.getString("Email"));
                    v.setOrderCount(rs.getInt("orderCount"));
                    v.setTotalSpent(rs.getBigDecimal("totalSpent"));
                    list.add(v);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Top khách hàng VIP trong 1 tháng cụ thể (theo năm + tháng). */
    public List<VipCustomer> getTopVipCustomersInMonth(int year, int month, int limit) {
        String sql = "SELECT u.UserID, u.FullName, u.Email, " +
                     "       COUNT(o.OrderID) AS orderCount, " +
                     "       COALESCE(SUM(o.TotalAmount),0) AS totalSpent " +
                     "FROM Orders o " +
                     "JOIN Users u ON u.UserID = o.UserID " +
                     "WHERE o.Status = 'Done' " +
                     "  AND YEAR(o.OrderDate) = ? " +
                     "  AND MONTH(o.OrderDate) = ? " +
                     "GROUP BY u.UserID, u.FullName, u.Email " +
                     "ORDER BY totalSpent DESC " +
                     "LIMIT ?";
        List<VipCustomer> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VipCustomer v = new VipCustomer();
                    v.setUserId(rs.getInt("UserID"));
                    v.setFullName(rs.getString("FullName"));
                    v.setEmail(rs.getString("Email"));
                    v.setOrderCount(rs.getInt("orderCount"));
                    v.setTotalSpent(rs.getBigDecimal("totalSpent"));
                    list.add(v);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Danh sách khách hàng mới trong 1 tháng (DTO gọn). */
    public List<NewCustomer> getNewCustomersInMonth(int year, int month) {
        String sql = "SELECT UserID, FullName, Email, CreatedAt " +
                     "FROM Users " +
                     "WHERE YEAR(CreatedAt) = ? AND MONTH(CreatedAt) = ? " +
                     "ORDER BY CreatedAt ASC";
        List<NewCustomer> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    NewCustomer nc = new NewCustomer();
                    nc.setUserId(rs.getInt("UserID"));
                    nc.setFullName(rs.getString("FullName"));
                    nc.setEmail(rs.getString("Email"));
                    nc.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    list.add(nc);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Danh sách khách hàng mới trong 1 tháng (trả về full model User). */
    public List<User> getNewUsersInMonth(int year, int month) {
        String sql = "SELECT UserID, FullName, Email, Phone, Address, Role, CreatedAt " +
                     "FROM Users " +
                     "WHERE YEAR(CreatedAt) = ? AND MONTH(CreatedAt) = ? " +
                     "ORDER BY CreatedAt DESC";
        List<User> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setUserID(rs.getInt("UserID"));
                    u.setFullName(rs.getString("FullName"));
                    u.setEmail(rs.getString("Email"));
                    u.setPhone(rs.getString("Phone"));
                    u.setAddress(rs.getString("Address"));
                    u.setRole(rs.getString("Role"));
                    u.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    list.add(u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /* ========== 5. RETENTION / REGION / SLOW PRODUCT / BRAND / PROFIT ========== */

    /** Tỷ lệ retention: khách có >= 2 đơn so với tổng khách từng mua. */
    public RetentionStats getRetentionStats() {
        String sqlTotal   = "SELECT COUNT(DISTINCT UserID) FROM Orders";
        String sqlReturn  = "SELECT COUNT(*) FROM (SELECT UserID FROM Orders GROUP BY UserID HAVING COUNT(*) >= 2) t";

        RetentionStats st = new RetentionStats();
        try (Statement s = connection.createStatement()) {
            try (ResultSet rs = s.executeQuery(sqlTotal)) {
                if (rs.next()) st.setTotalCustomers(rs.getInt(1));
            }
            try (ResultSet rs = s.executeQuery(sqlReturn)) {
                if (rs.next()) st.setReturningCustomers(rs.getInt(1));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (st.getTotalCustomers() > 0) {
            double rate = (st.getReturningCustomers() * 100.0) / st.getTotalCustomers();
            st.setRetentionRate(rate);
        } else {
            st.setRetentionRate(0.0);
        }
        return st;
    }

    /** Đơn hàng theo vùng địa lý: group theo ShippingAddress. */
    public List<RegionStat> getOrdersByRegion() {
        String sql = "SELECT ShippingAddress AS region, COUNT(*) AS c, COALESCE(SUM(TotalAmount),0) AS revenue "
                   + "FROM Orders GROUP BY ShippingAddress ORDER BY c DESC";
        List<RegionStat> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                RegionStat r = new RegionStat();
                r.setRegion(rs.getString("region"));
                r.setOrderCount(rs.getInt("c"));
                r.setRevenue(rs.getBigDecimal("revenue"));
                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Sản phẩm bán chậm: không có đơn trong X ngày gần nhất. */
    public List<SlowProduct> getSlowMovingProducts(int days) {
        String sql =
            "SELECT p.ProductID, p.ProductName, p.Stock, " +
            "       MAX(o.OrderDate) AS lastSold " +
            "FROM Products p " +
            "LEFT JOIN OrderItems oi ON oi.ProductID = p.ProductID " +
            "LEFT JOIN Orders o ON o.OrderID = oi.OrderID " +
                "AND o.Status IN ('Confirmed','Packing','Shipping','Done') " +
            "GROUP BY p.ProductID, p.ProductName, p.Stock " +
            "HAVING lastSold IS NULL OR lastSold < DATE_SUB(CURDATE(), INTERVAL ? DAY) " +
            "ORDER BY lastSold IS NULL DESC, lastSold ASC";
        List<SlowProduct> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SlowProduct sp = new SlowProduct();
                    sp.setProductID(rs.getInt("ProductID"));
                    sp.setProductName(rs.getString("ProductName"));
                    sp.setStock(rs.getInt("Stock"));
                    sp.setLastSold(rs.getTimestamp("lastSold"));
                    list.add(sp);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Doanh thu theo Brand của sản phẩm. */
    public List<BrandRevenue> getRevenueByBrand(java.sql.Date from, java.sql.Date to) {
        String sql = "SELECT p.Brand AS BrandName, " +
                     "       COALESCE(SUM(oi.Quantity * oi.UnitPrice),0) AS revenue, " +
                     "       COUNT(DISTINCT o.OrderID) AS orderCount " +
                     "FROM Products p " +
                     "JOIN OrderItems oi ON oi.ProductID = p.ProductID " +
                     "JOIN Orders o ON o.OrderID = oi.OrderID AND o.Status = 'Done' " +
                     "WHERE o.OrderDate BETWEEN ? AND ? " +
                     "GROUP BY p.Brand " +
                     "ORDER BY revenue DESC";
        List<BrandRevenue> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, from);
            ps.setDate(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BrandRevenue br = new BrandRevenue();
                    br.setBrandName(rs.getString("BrandName"));
                    br.setRevenue(rs.getBigDecimal("revenue"));
                    br.setOrderCount(rs.getInt("orderCount"));
                    list.add(br);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Lợi nhuận ước tính: yêu cầu bảng Products có cột CostPrice (giá nhập). */
    public BigDecimal getEstimatedProfit(java.sql.Date from, java.sql.Date to) {
        String sql = "SELECT COALESCE(SUM((oi.UnitPrice - p.CostPrice) * oi.Quantity),0) AS profit "
                   + "FROM OrderItems oi "
                   + "JOIN Products p ON p.ProductID = oi.ProductID "
                   + "JOIN Orders o ON o.OrderID = oi.OrderID AND o.Status = 'Done' "
                   + "WHERE o.OrderDate BETWEEN ? AND ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, from);
            ps.setDate(2, to);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal("profit") : BigDecimal.ZERO;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }

    /* ================== 6. TREND & OPERATIONAL METRICS ================== */

    /** Doanh thu của 1 tháng bất kỳ. */
    public BigDecimal getRevenueForMonth(int year, int month) {
        String sql = "SELECT COALESCE(SUM(TotalAmount),0) FROM Orders "
                   + "WHERE Status = 'Done' "
                   + "AND YEAR(OrderDate) = ? AND MONTH(OrderDate) = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }

    /** Doanh thu theo từng tháng của 1 năm. */
    public List<MonthlyRevenue> getMonthlyRevenue(int year) {
        String sql = "SELECT MONTH(OrderDate) AS m, COALESCE(SUM(TotalAmount),0) AS s "
                   + "FROM Orders WHERE Status = 'Done' AND YEAR(OrderDate) = ? "
                   + "GROUP BY MONTH(OrderDate) ORDER BY m";
        List<MonthlyRevenue> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MonthlyRevenue mr = new MonthlyRevenue();
                    mr.setYear(year);
                    mr.setMonth(rs.getInt("m"));
                    mr.setTotal(rs.getBigDecimal("s"));
                    list.add(mr);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Số đơn theo giờ đặt hàng (peak hours) + doanh thu. */
    public List<HourStat> getOrdersByHour() {
        String sql = "SELECT HOUR(OrderDate) AS h, " +
                     "       COUNT(*) AS c, " +
                     "       COALESCE(SUM(TotalAmount),0) AS revenue " +
                     "FROM Orders " +
                     "GROUP BY HOUR(OrderDate) " +
                     "ORDER BY h";
        List<HourStat> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                HourStat h = new HourStat();
                h.setHour(rs.getInt("h"));
                h.setOrderCount(rs.getInt("c"));
                h.setRevenue(rs.getBigDecimal("revenue"));
                list.add(h);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Tỷ lệ hủy đơn + AOV (Average Order Value). */
    public CancellationStats getCancellationStats() {
        String sqlTotal    = "SELECT COUNT(*), COALESCE(SUM(TotalAmount),0) FROM Orders";
        String sqlCanceled = "SELECT COUNT(*) FROM Orders WHERE Status = 'Canceled'";
        CancellationStats cs = new CancellationStats();
        try (Statement st = connection.createStatement()) {
            try (ResultSet rs = st.executeQuery(sqlTotal)) {
                if (rs.next()) {
                    cs.setTotalOrders(rs.getInt(1));
                    cs.setTotalRevenue(rs.getBigDecimal(2));
                }
            }
            try (ResultSet rs = st.executeQuery(sqlCanceled)) {
                if (rs.next()) {
                    cs.setCanceledOrders(rs.getInt(1));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (cs.getTotalOrders() > 0) {
            cs.setCancelRate(cs.getCanceledOrders() * 100.0 / cs.getTotalOrders());
            cs.setAverageOrderValue(
                cs.getTotalRevenue().divide(
                        BigDecimal.valueOf(cs.getTotalOrders()),
                        2,
                        java.math.RoundingMode.HALF_UP
                )
            );
        } else {
            cs.setCancelRate(0.0);
            cs.setAverageOrderValue(BigDecimal.ZERO);
        }
        return cs;
    }

    /* ================== 7. INNER DTO CLASSES ================== */

    public static class RevenuePoint {
        private String date;
        private BigDecimal total;
        public String getDate() { return date; }
        public void setDate(String date) { this.date = date; }
        public BigDecimal getTotal() { return total; }
        public void setTotal(BigDecimal total) { this.total = total; }
    }

    public static class StatusCount {
        private String status;
        private int count;
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public int getCount() { return count; }
        public void setCount(int count) { this.count = count; }
    }

    public static class CategoryRevenue {
        private String categoryName;
        private BigDecimal revenue;
        private int orderCount;
        public String getCategoryName() { return categoryName; }
        public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
        public BigDecimal getRevenue() { return revenue; }
        public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }
        public int getOrderCount() { return orderCount; }
        public void setOrderCount(int orderCount) { this.orderCount = orderCount; }
    }

    public static class MonthlyCount {
        private String month;
        private int count;
        public String getMonth() { return month; }
        public void setMonth(String month) { this.month = month; }
        public int getCount() { return count; }
        public void setCount(int count) { this.count = count; }
    }

    public static class TopProduct {
        private int productID;
        private String productName;
        private int quantity;
        public int getProductID() { return productID; }
        public void setProductID(int productID) { this.productID = productID; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
    }

    /** DTO cho khách hàng VIP (top chi tiêu) */
    public static class VipCustomer {
        private int userID;               // để tương thích code cũ
        private String fullName;
        private String email;
        private int orderCount;
        private BigDecimal totalSpent;
        public int getUserID() { return userID; }
        public void setUserID(int userID) { this.userID = userID; }
        public int getUserId() { return userID; }
        public void setUserId(int userId) { this.userID = userId; }
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public int getOrderCount() { return orderCount; }
        public void setOrderCount(int orderCount) { this.orderCount = orderCount; }
        public BigDecimal getTotalSpent() { return totalSpent; }
        public void setTotalSpent(BigDecimal totalSpent) { this.totalSpent = totalSpent; }
    }

    public static class RetentionStats {
        private int totalCustomers;
        private int returningCustomers;
        private double retentionRate;
        public int getTotalCustomers() { return totalCustomers; }
        public void setTotalCustomers(int totalCustomers) { this.totalCustomers = totalCustomers; }
        public int getReturningCustomers() { return returningCustomers; }
        public void setReturningCustomers(int returningCustomers) { this.returningCustomers = returningCustomers; }
        public double getRetentionRate() { return retentionRate; }
        public void setRetentionRate(double retentionRate) { this.retentionRate = retentionRate; }
    }

    public static class RegionStat {
        private String region;
        private int orderCount;
        private BigDecimal revenue;
        public String getRegion() { return region; }
        public void setRegion(String region) { this.region = region; }
        public int getOrderCount() { return orderCount; }
        public void setOrderCount(int orderCount) { this.orderCount = orderCount; }
        public BigDecimal getRevenue() { return revenue; }
        public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }
    }

    public static class SlowProduct {
        private int productID;
        private String productName;
        private int stock;
        private Timestamp lastSold;
        public int getProductID() { return productID; }
        public void setProductID(int productID) { this.productID = productID; }
        public String getProductName() { return productName; }
        public void setProductName(String productName) { this.productName = productName; }
        public int getStock() { return stock; }
        public void setStock(int stock) { this.stock = stock; }
        public Timestamp getLastSold() { return lastSold; }
        public void setLastSold(Timestamp lastSold) { this.lastSold = lastSold; }
    }

    public static class BrandRevenue {
        private String brandName;
        private BigDecimal revenue;
        private int orderCount;
        public String getBrandName() { return brandName; }
        public void setBrandName(String brandName) { this.brandName = brandName; }
        public String getBrand() { return brandName; }
        public void setBrand(String brand) { this.brandName = brand; }
        public BigDecimal getRevenue() { return revenue; }
        public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }
        public int getOrderCount() { return orderCount; }
        public void setOrderCount(int orderCount) { this.orderCount = orderCount; }
    }

    public static class HourStat {
        private int hour;
        private int orderCount;
        private BigDecimal revenue;
        public int getHour() { return hour; }
        public void setHour(int hour) { this.hour = hour; }
        public int getOrderCount() { return orderCount; }
        public void setOrderCount(int orderCount) { this.orderCount = orderCount; }
        public BigDecimal getRevenue() { return revenue; }
        public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }
    }

    /** DTO khách hàng mới trong tháng (gọn cho báo cáo / PDF). */
    public static class NewCustomer {
        private int userId;
        private String fullName;
        private String email;
        private Timestamp createdAt;
        public int getUserId() { return userId; }
        public void setUserId(int userId) { this.userId = userId; }
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public Timestamp getCreatedAt() { return createdAt; }
        public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    }

    public static class MonthlyRevenue {
        private int year;
        private int month;
        private BigDecimal total;
        public int getYear() { return year; }
        public void setYear(int year) { this.year = year; }
        public int getMonth() { return month; }
        public void setMonth(int month) { this.month = month; }
        public BigDecimal getTotal() { return total; }
        public void setTotal(BigDecimal total) { this.total = total; }
    }

    public static class CancellationStats {
        private int totalOrders;
        private int canceledOrders;
        private BigDecimal totalRevenue;
        private double cancelRate;
        private BigDecimal averageOrderValue;
        public int getTotalOrders() { return totalOrders; }
        public void setTotalOrders(int totalOrders) { this.totalOrders = totalOrders; }
        public int getCanceledOrders() { return canceledOrders; }
        public void setCanceledOrders(int canceledOrders) { this.canceledOrders = canceledOrders; }
        public BigDecimal getTotalRevenue() { return totalRevenue; }
        public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }
        public double getCancelRate() { return cancelRate; }
        public void setCancelRate(double cancelRate) { this.cancelRate = cancelRate; }
        public BigDecimal getAverageOrderValue() { return averageOrderValue; }
        public void setAverageOrderValue(BigDecimal averageOrderValue) { this.averageOrderValue = averageOrderValue; }
    }

    /* ================== 8. PROFIT BY MONTH ================== */

    /** Lợi nhuận ước tính theo từng tháng của 1 năm (dựa trên CostPrice). */
    public List<MonthlyRevenue> getMonthlyProfit(int year) {
        String sql = "SELECT MONTH(o.OrderDate) AS m, " +
                     "       COALESCE(SUM((oi.UnitPrice - p.CostPrice) * oi.Quantity),0) AS profit " +
                     "FROM Orders o " +
                     "JOIN OrderItems oi ON o.OrderID = oi.OrderID " +
                     "JOIN Products p ON p.ProductID = oi.ProductID " +
                     "WHERE o.Status = 'Done' AND YEAR(o.OrderDate) = ? " +
                     "GROUP BY MONTH(o.OrderDate) " +
                     "ORDER BY m";
        List<MonthlyRevenue> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    MonthlyRevenue mr = new MonthlyRevenue();
                    mr.setYear(year);
                    mr.setMonth(rs.getInt("m"));
                    mr.setTotal(rs.getBigDecimal("profit")); // dùng total = profit
                    list.add(mr);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /** Lợi nhuận ước tính của 1 tháng bất kỳ (nếu cần tính riêng). */
    public BigDecimal getProfitForMonth(int year, int month) {
        String sql = "SELECT COALESCE(SUM((oi.UnitPrice - p.CostPrice) * oi.Quantity),0) " +
                     "FROM Orders o " +
                     "JOIN OrderItems oi ON o.OrderID = oi.OrderID " +
                     "JOIN Products p ON p.ProductID = oi.ProductID " +
                     "WHERE o.Status = 'Done' AND YEAR(o.OrderDate) = ? AND MONTH(o.OrderDate) = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }

    /* ====== 9. CÁC HÀM WRAPPER CŨ (NẾU Ở CHỖ KHÁC ĐÃ DÙNG TÊN NÀY) ====== */

    public int countLowStockProducts(int threshold) {
        return countLowStock(threshold);
    }

    public int countOutOfStockProducts() {
        return countOutOfStock();
    }
}
