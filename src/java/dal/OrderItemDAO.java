package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import model.OrderItem;

public class OrderItemDAO extends DBContext {
    private Connection transactionConnection;

    public OrderItemDAO(Connection connection) {
        this.transactionConnection = connection;
    }
    
    public OrderItemDAO() {
        super();
    }

    public boolean addOrderItem(OrderItem item) {
        String sql = "INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES (?, ?, ?, ?)";
        Connection conn = (transactionConnection != null) ? transactionConnection : this.connection;
        
        try (PreparedStatement st = conn.prepareStatement(sql)) {
            st.setInt(1, item.getOrderID());
            st.setInt(2, item.getProductID());
            st.setInt(3, item.getQuantity());
            st.setDouble(4, item.getUnitPrice());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.out.println("Error in addOrderItem: " + e.getMessage());
            return false;
        }
    }
}