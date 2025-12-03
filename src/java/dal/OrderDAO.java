package dal;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Order;
import model.OrderItem;
import model.Product;

public class OrderDAO extends DBContext {

    // ===================== TẠO ĐƠN HÀNG =====================
public List<Order> getAllOrdersForExport() {
    String sql = "SELECT OrderID, UserID, OrderDate, TotalAmount, Status, PaymentMethod, ShippingAddress " +
                 "FROM Orders ORDER BY OrderDate DESC";

    List<Order> list = new ArrayList<>();
    try (PreparedStatement ps = connection.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            Order o = new Order();
            o.setOrderID(rs.getInt("OrderID"));
            o.setUserID(rs.getInt("UserID"));
            o.setOrderDate(rs.getTimestamp("OrderDate"));
            o.setTotalAmount(rs.getDouble("TotalAmount")); // nếu model dùng BigDecimal thì sửa cho đúng
            o.setStatus(rs.getString("Status"));
            o.setPaymentMethod(rs.getString("PaymentMethod"));
            o.setShippingAddress(rs.getString("ShippingAddress"));
            list.add(o);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    return list;
}

    public boolean createOrder(Order order) {
        if (connection == null) {
            System.err.println("createOrder error: DB connection is null");
            return false;
        }
        boolean previousAutoCommit = true;
        try {
            previousAutoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);

            String sqlOrder = """
                INSERT INTO Orders
                    (UserID, TotalAmount, Status, PaymentMethod, ShippingAddress, Note, OrderDate)
                VALUES (?, ?, ?, ?, ?, ?, NOW())
            """;

            try (PreparedStatement stOrder = connection.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                stOrder.setInt(1, order.getUserID());
                stOrder.setDouble(2, order.getTotalAmount());
                stOrder.setString(3, order.getStatus() == null ? "Pending" : order.getStatus());
                stOrder.setString(4, order.getPaymentMethod());
                stOrder.setString(5, order.getShippingAddress());
                stOrder.setString(6, order.getNote());

                int affected = stOrder.executeUpdate();
                if (affected == 0) {
                    throw new SQLException("Creating order failed, no rows affected.");
                }

                try (ResultSet generatedKeys = stOrder.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        int orderId = generatedKeys.getInt(1);
                        order.setOrderID(orderId);

                        OrderItemDAO orderItemDAO = new OrderItemDAO(connection);

                        String sqlDec = "UPDATE Products SET Stock = Stock - ? WHERE ProductID = ? AND Stock >= ?";

                        try (PreparedStatement stDec = connection.prepareStatement(sqlDec)) {
                            for (OrderItem item : order.getItems()) {
                                item.setOrderID(orderId);
                                boolean ok = orderItemDAO.addOrderItem(item);
                                if (!ok) {
                                    connection.rollback();
                                    System.err.println("createOrder: addOrderItem failed, rolling back");
                                    return false;
                                }

                                stDec.setInt(1, item.getQuantity());
                                stDec.setInt(2, item.getProductID());
                                stDec.setInt(3, item.getQuantity());
                                int updated = stDec.executeUpdate();
                                if (updated == 0) {
                                    connection.rollback();
                                    System.err.println("createOrder: insufficient stock for product " + item.getProductID()
                                            + " (requested=" + item.getQuantity() + ")");
                                    return false;
                                }
                            }
                        }
                    } else {
                        throw new SQLException("Creating order failed, no ID obtained.");
                    }
                }
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            System.err.println("Error in createOrder transaction: " + e.getMessage());
            try {
                connection.rollback();
            } catch (SQLException ex) {
                System.err.println("Error on rollback: " + ex.getMessage());
            }
            return false;
        } finally {
            try {
                connection.setAutoCommit(previousAutoCommit);
            } catch (SQLException ex) {
                System.err.println("Error restoring auto-commit: " + ex.getMessage());
            }
        }
    }

    // ===================== LẤY ĐƠN THEO USER (FULL CHI TIẾT) =====================

    public List<Order> getOrdersByUserIdWithDetails(int userId) {
        if (connection == null) return new ArrayList<>();
        List<Order> orderList = new ArrayList<>();
        String sql = """
            SELECT OrderID, UserID, OrderDate, TotalAmount, Status, PaymentMethod, ShippingAddress, Note
            FROM Orders
            WHERE UserID = ?
            ORDER BY OrderDate DESC
        """;
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderID(rs.getInt("OrderID"));
                    order.setUserID(rs.getInt("UserID"));
                    order.setOrderDate(rs.getTimestamp("OrderDate"));
                    order.setTotalAmount(rs.getDouble("TotalAmount"));
                    order.setStatus(rs.getString("Status"));
                    order.setPaymentMethod(rs.getString("PaymentMethod"));
                    order.setShippingAddress(rs.getString("ShippingAddress"));
                    order.setNote(rs.getString("Note"));
                    order.setItems(getOrderItemsByOrderId(order.getOrderID()));
                    orderList.add(order);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getOrdersByUserIdWithDetails: " + e.getMessage());
        }
        return orderList;
    }

    public List<OrderItem> getOrderItemsByOrderId(int orderId) {
        List<OrderItem> itemList = new ArrayList<>();
        if (connection == null) return itemList;
        String sql = """
            SELECT oi.OrderItemID, oi.OrderID, oi.ProductID, oi.Quantity, oi.UnitPrice,
                   p.ProductName, p.ImageURL
            FROM OrderItems oi
            JOIN Products p ON oi.ProductID = p.ProductID
            WHERE oi.OrderID = ?
        """;
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, orderId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setOrderItemID(rs.getInt("OrderItemID"));
                    item.setOrderID(rs.getInt("OrderID"));
                    item.setProductID(rs.getInt("ProductID"));
                    item.setQuantity(rs.getInt("Quantity"));
                    item.setUnitPrice(rs.getDouble("UnitPrice"));

                    Product product = new Product();
                    product.setProductID(rs.getInt("ProductID"));
                    product.setProductName(rs.getString("ProductName"));
                    product.setImageURL(rs.getString("ImageURL"));

                    item.setProduct(product);
                    itemList.add(item);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getOrderItemsByOrderId: " + e.getMessage());
        }
        return itemList;
    }

    // ===================== THỐNG KÊ ĐƠN =====================

    public int countAll() {
        if (connection == null) return 0;
        String sql = "SELECT COUNT(*) FROM Orders";
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("OrderDAO.countAll error: " + e.getMessage());
        }
        return 0;
    }

    public int countByStatus(String status) {
        if (connection == null) return 0;
        String sql = (status == null || status.isBlank())
                ? "SELECT COUNT(*) FROM Orders"
                : "SELECT COUNT(*) FROM Orders WHERE Status = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            if (status != null && !status.isBlank()) {
                st.setString(1, status);
            }
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("OrderDAO.countByStatus error: " + e.getMessage());
        }
        return 0;
    }

    public List<Order> getAllOrders(String status, int offset, int limit) {
        List<Order> list = new ArrayList<>();
        if (connection == null) return list;
        String base = """
            SELECT OrderID, UserID, OrderDate, TotalAmount, Status, PaymentMethod, ShippingAddress, Note
            FROM Orders
        """;
        String sql = base
                + ((status == null || status.isBlank()) ? "" : " WHERE Status = ?")
                + " ORDER BY OrderDate DESC LIMIT ? OFFSET ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            int idx = 1;
            if (status != null && !status.isBlank()) {
                st.setString(idx++, status);
            }
            st.setInt(idx++, limit);
            st.setInt(idx, offset);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order();
                    o.setOrderID(rs.getInt("OrderID"));
                    o.setUserID(rs.getInt("UserID"));
                    o.setOrderDate(rs.getTimestamp("OrderDate"));
                    o.setTotalAmount(rs.getDouble("TotalAmount"));
                    o.setStatus(rs.getString("Status"));
                    o.setPaymentMethod(rs.getString("PaymentMethod"));
                    o.setShippingAddress(rs.getString("ShippingAddress"));
                    o.setNote(rs.getString("Note"));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            System.err.println("OrderDAO.getAllOrders error: " + e.getMessage());
        }
        return list;
    }

    public Order getOrderByIdWithItems(int id) {
        Order o = null;
        if (connection == null) return null;
        String sql = """
            SELECT OrderID, UserID, OrderDate, TotalAmount, Status, PaymentMethod, ShippingAddress, Note
            FROM Orders
            WHERE OrderID = ?
        """;
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    o = new Order();
                    o.setOrderID(rs.getInt("OrderID"));
                    o.setUserID(rs.getInt("UserID"));
                    o.setOrderDate(rs.getTimestamp("OrderDate"));
                    o.setTotalAmount(rs.getDouble("TotalAmount"));
                    o.setStatus(rs.getString("Status"));
                    o.setPaymentMethod(rs.getString("PaymentMethod"));
                    o.setShippingAddress(rs.getString("ShippingAddress"));
                    o.setNote(rs.getString("Note"));
                }
            }
        } catch (SQLException e) {
            System.err.println("OrderDAO.getOrderByIdWithItems error: " + e.getMessage());
        }
        if (o != null) {
            o.setItems(getOrderItemsByOrderId(id));
        }
        return o;
    }

    public boolean updateStatus(int id, String status) {
        if (connection == null) return false;
        String sql = "UPDATE Orders SET Status = ? WHERE OrderID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, status);
            st.setInt(2, id);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("OrderDAO.updateStatus error: " + e.getMessage());
            return false;
        }
    }

    // ===================== DOANH THU =====================

    public Map<String, Double> revenueLastDays(int days) {
        Map<String, Double> map = new LinkedHashMap<>();
        if (connection == null) return map;

        String sql = """
            SELECT DATE(OrderDate) d, SUM(TotalAmount) s
            FROM Orders
            WHERE OrderDate >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
              AND Status IN ('Processing','Packing','Shipping','Shipped','Delivered','Done')
            GROUP BY d
            ORDER BY d
        """;
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, days);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getString("d"), rs.getDouble("s"));
                }
            }
        } catch (SQLException e) {
            System.err.println("OrderDAO.revenueLastDays error: " + e.getMessage());
        }
        return map;
    }

    public List<Map<String, Object>> topSellingProducts(int limit) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (connection == null) return list;
        String sql = """
            SELECT p.ProductID, p.ProductName, SUM(oi.Quantity) qty
            FROM OrderItems oi
            JOIN Orders o   ON o.OrderID = oi.OrderID
            JOIN Products p ON oi.ProductID = p.ProductID
            WHERE o.Status IN ('Processing','Packing','Shipping','Shipped','Delivered','Done')
            GROUP BY p.ProductID, p.ProductName
            ORDER BY qty DESC
            LIMIT ?
        """;
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, limit);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("productID", rs.getInt("ProductID"));
                    m.put("productName", rs.getString("ProductName"));
                    m.put("quantity", rs.getInt("qty"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            System.err.println("OrderDAO.topSellingProducts error: " + e.getMessage());
        }
        return list;
    }

    // ===================== FLOW TRẠNG THÁI ĐƠN =====================

public boolean updateStatusFlow(int orderId, String newStatus) {
    if (connection == null) return false;
    if (newStatus == null || newStatus.trim().isEmpty()) return false;

    // Trạng thái mới chuẩn (viết hoa đầu cho đồng bộ DB & UI)
    String target = canonicalStatus(newStatus);
    if (target == null) return false;

    // Lấy đơn hiện tại
    Order o = getOrderByIdWithItems(orderId);
    if (o == null) return false;

    String current = o.getStatus();
    if (current == null) current = "Pending";
    current = canonicalStatus(current);

    // Kiểm tra luồng
    if (!canTransition(current, target)) {
        return false;  // sai luồng hoặc không cho phép
    }

    String sql = "UPDATE Orders SET Status = ? WHERE OrderID = ? AND Status = ?";
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setString(1, target);
        ps.setInt(2, orderId);
        ps.setString(3, current); // bảo vệ: chỉ update nếu còn đúng trạng thái hiện tại

        int updated = ps.executeUpdate();
        return updated > 0;
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}

/** Chuẩn hóa tên status thành 1 trong các giá trị chuẩn lưu DB/UI */
private String canonicalStatus(String s) {
    if (s == null) return null;
    String x = s.trim().toLowerCase();
    switch (x) {
        case "pending":   return "Pending";
        case "confirmed": return "Confirmed";
        case "packing":   return "Packing";
        case "shipping":  return "Shipping";
        case "done":      return "Done";
        case "canceled":
        case "cancelled": return "Canceled";
        default:
            return null; // các trạng thái khác không dùng cho flow Admin
    }
}

/** Chỉ cho phép đi tới 1 bước, hoặc hủy (Canceled) từ vài trạng thái đầu */
private boolean canTransition(String current, String target) {
    if (current == null || target == null) return false;

    // Đơn đã hoàn tất hoặc đã hủy thì KHÔNG cho đổi nữa
    if (current.equals("Done") || current.equals("Canceled")) {
        return false;
    }

    // Nếu giống nhau thì không cần đổi (nhưng coi như hợp lệ)
    if (current.equals(target)) return true;

    // Cho phép hủy từ một số trạng thái đầu
    if (target.equals("Canceled")) {
        return current.equals("Pending")
            || current.equals("Confirmed")
            || current.equals("Packing")
            || current.equals("Shipping");
    }

    // Flow 1 chiều: Pending -> Confirmed -> Packing -> Shipping -> Done
    int curIdx = getStepIndex(current);
    int tarIdx = getStepIndex(target);

    // Chỉ cho phép nhảy đúng 1 bước tiến
    return curIdx >= 0 && tarIdx == curIdx + 1;
}

/** Mapping thứ tự các bước trong flow */
private int getStepIndex(String status) {
    if (status == null) return -1;
    switch (status) {
        case "Pending":   return 0;
        case "Confirmed": return 1;
        case "Packing":   return 2;
        case "Shipping":  return 3;
        case "Done":      return 4;
        default:          return -1;
    }
}

    // ===================== HỖ TRỢ ADMIN USER DETAIL =====================

    public List<Order> getOrdersByUser(int userId) {
        List<Order> list = new ArrayList<>();
        if (connection == null) return list;

        String sql = "SELECT * FROM Orders WHERE UserID = ? ORDER BY OrderDate DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToOrder(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public BigDecimal totalSpentByUser(int userId) {
        if (connection == null) return BigDecimal.ZERO;

        String sql = """
            SELECT COALESCE(SUM(TotalAmount),0)
            FROM Orders
            WHERE UserID = ?
              AND Status IN ('Done','Delivered')
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }

    private Order mapRowToOrder(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderID(rs.getInt("OrderID"));
        o.setUserID(rs.getInt("UserID"));
        o.setOrderDate(rs.getTimestamp("OrderDate"));
        o.setTotalAmount(rs.getDouble("TotalAmount"));
        o.setStatus(rs.getString("Status"));
        o.setPaymentMethod(rs.getString("PaymentMethod"));
        o.setShippingAddress(rs.getString("ShippingAddress"));
        o.setNote(rs.getString("Note"));
        return o;
    }

    /**
     * Dùng cho AdminUserController – xuất Excel đơn + chi tiết 1 user.
     * Object[] = {OrderID, OrderDate, Status, ProductName, Quantity, UnitPrice, LineTotal}
     */
    public List<Object[]> findOrderItemsByUser(int userId) {
        List<Object[]> list = new ArrayList<>();

        String sql =
            "SELECT o.OrderID, o.OrderDate, o.Status, " +
            "       p.ProductName, oi.Quantity, oi.UnitPrice, " +
            "       (oi.Quantity * oi.UnitPrice) AS LineTotal " +
            "FROM Orders o " +
            "JOIN OrderItems oi ON o.OrderID = oi.OrderID " +
            "JOIN Products   p  ON oi.ProductID = p.ProductID " +
            "WHERE o.UserID = ? " +
            "ORDER BY o.OrderDate DESC, o.OrderID DESC";

        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Object[] row = new Object[7];
                    row[0] = rs.getInt("OrderID");
                    row[1] = rs.getTimestamp("OrderDate");
                    row[2] = rs.getString("Status");
                    row[3] = rs.getString("ProductName");
                    row[4] = rs.getInt("Quantity");
                    row[5] = rs.getDouble("UnitPrice");
                    row[6] = rs.getDouble("LineTotal");
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            System.err.println("OrderDAO.findOrderItemsByUser error: " + e.getMessage());
        }

        return list;
    }
}
