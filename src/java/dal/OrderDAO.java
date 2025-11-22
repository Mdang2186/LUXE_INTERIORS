package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Order;
import model.OrderItem;
import model.Product;

public class OrderDAO extends DBContext {

    public boolean createOrder(Order order) {
    if (connection == null) {
        System.err.println("createOrder error: DB connection is null");
        return false;
    }
    boolean previousAutoCommit = true;
    try {
        previousAutoCommit = connection.getAutoCommit();
        connection.setAutoCommit(false);

        String sqlOrder = "INSERT INTO Orders (UserID, TotalAmount, Status, PaymentMethod, ShippingAddress, Note, OrderDate) " +
                          "VALUES (?, ?, ?, ?, ?, ?, NOW())";

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

                    // 🔥 GÁN LẠI CHO OBJECT ORDER Ở ĐÂY
                    order.setOrderID(orderId);

                    OrderItemDAO orderItemDAO = new OrderItemDAO(connection);

                    // Prepare decrement statement once (atomic stock decrement)
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

                            // decrement stock atomically
                            stDec.setInt(1, item.getQuantity());
                            stDec.setInt(2, item.getProductID());
                            stDec.setInt(3, item.getQuantity());
                            int updated = stDec.executeUpdate();
                            if (updated == 0) {
                                // insufficient stock for this item -> rollback entire order
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


    public List<Order> getOrdersByUserIdWithDetails(int userId) {
        if (connection == null) return new ArrayList<>();
        List<Order> orderList = new ArrayList<>();
        String sql = "SELECT OrderID, UserID, OrderDate, TotalAmount, Status, PaymentMethod, ShippingAddress, Note FROM Orders WHERE USERID = ? ORDER BY OrderDate DESC";
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
        String sql = "SELECT oi.OrderItemID, oi.OrderID, oi.ProductID, oi.Quantity, oi.UnitPrice, p.ProductName, p.ImageURL "
                   + "FROM OrderItems oi JOIN Products p ON oi.ProductID = p.ProductID WHERE oi.OrderID = ?";
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
        String sql = (status == null || status.isBlank()) ? "SELECT COUNT(*) FROM Orders" : "SELECT COUNT(*) FROM Orders WHERE Status = ?";
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
        String base = "SELECT OrderID, UserID, OrderDate, TotalAmount, Status, PaymentMethod, ShippingAddress, Note FROM Orders";
        String sql = base + ((status == null || status.isBlank()) ? "" : " WHERE Status = ?") + " ORDER BY OrderDate DESC LIMIT ? OFFSET ?";
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
        String sql = "SELECT OrderID, UserID, OrderDate, TotalAmount, Status, PaymentMethod, ShippingAddress, Note FROM Orders WHERE OrderID = ?";
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

    public Map<String, Double> revenueLastDays(int days) {
        Map<String, Double> map = new LinkedHashMap<>();
        if (connection == null) return map;
        String sql = "SELECT DATE(OrderDate) d, SUM(TotalAmount) s FROM Orders WHERE OrderDate >= DATE_SUB(CURDATE(), INTERVAL ? DAY) AND Status IN ('Processing','Shipped','Delivered') GROUP BY d ORDER BY d";
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
        String sql = "SELECT p.ProductID, p.ProductName, SUM(oi.Quantity) qty FROM OrderItems oi JOIN Products p ON oi.ProductID = p.ProductID "
                   + "GROUP BY p.ProductID, p.ProductName ORDER BY qty DESC LIMIT ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, limit);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("productID", rs.getInt(1));
                    m.put("productName", rs.getString(2));
                    m.put("quantity", rs.getInt(3));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            System.err.println("OrderDAO.topSellingProducts error: " + e.getMessage());
        }
        return list;
    }
// Cập nhật trạng thái theo quy trình, không cho quay ngược
public boolean updateStatusFlow(int orderId, String newStatus) {
    // Có thể dùng getOrderByIdWithItems hoặc hàm getOrderById tùy anh đang có
    Order o = getOrderByIdWithItems(orderId);
    if (o == null) return false;

    String current = o.getStatus();

    // kiểm tra xem có được chuyển current -> newStatus không
    if (!canTransition(current, newStatus)) {
        return false;
    }

    String sql = "UPDATE orders SET Status = ? WHERE OrderID = ?";
    try (PreparedStatement ps = connection.prepareStatement(sql)) {
        ps.setString(1, newStatus);
        ps.setInt(2, orderId);
        return ps.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}

/**
 * Quy tắc luồng trạng thái:
 * Pending -> Confirmed -> Packing -> Shipping -> Done
 * Pending / Confirmed có thể chuyển sang Canceled
 * Done / Canceled: trạng thái cuối, không đổi nữa.
 */
private boolean canTransition(String current, String target) {
    if (current == null || target == null) return false;

    String cur = current.trim().toLowerCase();
    String tar = target.trim().toLowerCase();

    // Đơn đã hoàn tất hoặc đã hủy thì khóa
    if (cur.equals("done") || cur.equals("canceled")) return false;

    // Không thay đổi gì
    if (cur.equals(tar)) return true;

    switch (cur) {
        case "pending":
            // từ Pending -> Confirmed hoặc Canceled
            return tar.equals("confirmed") || tar.equals("canceled");
        case "confirmed":
            // từ Confirmed -> Packing hoặc Canceled
            return tar.equals("packing") || tar.equals("canceled");
        case "packing":
            // từ Packing -> Shipping
            return tar.equals("shipping");
        case "shipping":
            // từ Shipping -> Done
            return tar.equals("done");
        default:
            return false;
    }
}

}
