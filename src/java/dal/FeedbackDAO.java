package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;

/**
 * DAO này dùng để lưu trữ các liên hệ (feedback) từ người dùng vào CSDL.
 */
public class FeedbackDAO extends DBContext {

    /**
     * Chèn một liên hệ mới vào bảng 'feedbacks'.
     * Giả sử bảng có các cột: 
     * feedbackID (INT, PK, AI), 
     * userID (INT, NULLABLE, FK), 
     * fullName (VARCHAR), 
     * email (VARCHAR), 
     * phone (VARCHAR), 
     * subject (VARCHAR), 
     * message (TEXT), 
     * createdAt (DATETIME),
     * isResolved (BOOLEAN, DEFAULT 0)
     */
    public boolean insert(int userId, String fullName, String email, String phone, String subject, String message) {
        Connection conn = null;
        PreparedStatement ps = null;
        String sql = "INSERT INTO feedbacks (userID, fullName, email, phone, subject, message, createdAt, isResolved) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, 0)";

        try {
            conn = super.connection; // Lấy connection từ DBContext
            ps = conn.prepareStatement(sql);
            
            // Xử lý userID (nếu người dùng chưa đăng nhập, userId = 0)
            if (userId == 0) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, userId);
            }
            
            ps.setString(2, fullName);
            ps.setString(3, email);
            ps.setString(4, phone);
            ps.setString(5, subject);
            ps.setString(6, message);
            ps.setTimestamp(7, Timestamp.from(Instant.now())); // Thời gian hiện tại

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] Lỗi khi chèn feedback: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            // Không đóng connection ở đây vì nó được quản lý bởi DBContext
            try {
                if (ps != null) ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}