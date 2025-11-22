package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;

/**
 * DAO này để lưu email của người dùng đăng ký nhận tin.
 * (Đây là tệp còn thiếu mà IDE của bạn báo lỗi)
 */
public class SubscriberDAO extends DBContext {

    /**
     * Chèn email mới vào bảng 'subscribers'.
     * Giả sử bảng có: email (VARCHAR, PK), createdAt (DATETIME)
     * Dùng ON DUPLICATE KEY UPDATE để nếu email đã tồn tại,
     * nó chỉ cập nhật lại ngày đăng ký (tránh lỗi trùng lặp).
     */
    public boolean insert(String email) {
        Connection conn = null;
        PreparedStatement ps = null;
        String sql = "INSERT INTO subscribers (email, createdAt) VALUES (?, ?) "
                   + "ON DUPLICATE KEY UPDATE createdAt = VALUES(createdAt)";

        try {
            conn = super.connection; // Lấy connection từ DBContext
            ps = conn.prepareStatement(sql);
            
            ps.setString(1, email);
            ps.setTimestamp(2, Timestamp.from(Instant.now())); // Thời gian hiện tại

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("[SubscriberDAO] Lỗi khi chèn email: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            // Không đóng connection ở đây vì nó được quản lý bởi DBContext
        }
    }
}