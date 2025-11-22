package dal;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/** DAO phục vụ Dashboard admin */
public class AdminStatsDAO extends DBContext {

    public int countUsers() {
        String sql = "SELECT COUNT(*) FROM users";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) { e.printStackTrace(); return 0; }
    }

    public int countProducts() {
        String sql = "SELECT COUNT(*) FROM products";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) { e.printStackTrace(); return 0; }
    }

    public int countOrders() {
        String sql = "SELECT COUNT(*) FROM orders";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) { e.printStackTrace(); return 0; }
    }

    /** Doanh thu chỉ tính các đơn trạng thái 'Done' */
    public BigDecimal sumRevenueDone() {
        String sql = "SELECT COALESCE(SUM(TotalAmount),0) FROM orders WHERE Status = 'Done'";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
        } catch (Exception e) { e.printStackTrace(); return BigDecimal.ZERO; }
    }

    public int countReviews() {
        String sql = "SELECT COUNT(*) FROM reviews";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) { e.printStackTrace(); return 0; }
    }

    public int countContacts() {
        String sql = "SELECT COUNT(*) FROM contacts";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) { e.printStackTrace(); return 0; }
    }

    public int countLowStock(int threshold) {
        String sql = "SELECT COUNT(*) FROM products WHERE Stock <= ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) { e.printStackTrace(); return 0; }
    }

    /** Top N bán chạy: trả về [ProductName] */
    public List<String> topSellingProductNames(int limit) {
        String sql = """
            SELECT p.ProductName
            FROM orderitems oi
            JOIN products p ON p.ProductID = oi.ProductID
            GROUP BY p.ProductID, p.ProductName
            ORDER BY SUM(oi.Quantity) DESC
            LIMIT ?
        """;
        List<String> names = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) names.add(rs.getString(1));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return names;
    }
}
