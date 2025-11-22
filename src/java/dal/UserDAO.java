package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import model.User;
import org.mindrot.jbcrypt.BCrypt;

public class UserDAO extends DBContext {

    /** Giữ 1 tên bảng duy nhất (MySQL: backtick để tránh keyword) */
    private static final String TBL = "`Users`";
    private static final String COLS = "UserID, FullName, Email, PasswordHash, Phone, Address, Role, CreatedAt";

    /* ===================== LOGIN ===================== */

    /** Đăng nhập: lấy hash từ DB và check BCrypt */
    public User checkLogin(String email, String rawPassword) {
        String norm = normalizeEmail(email);
        String sql = "SELECT " + COLS + " FROM " + TBL + " WHERE Email = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, norm);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    String hash = rs.getString("PasswordHash");
                    if (hash != null && BCrypt.checkpw(rawPassword, hash)) {
                        return mapUser(rs);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.checkLogin error: " + e.getMessage());
        }
        return null;
    }

    /* ===================== REGISTER ===================== */

    public boolean checkEmailExists(String email) {
        String norm = normalizeEmail(email);
        String sql = "SELECT 1 FROM " + TBL + " WHERE Email = ? LIMIT 1";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, norm);
            try (ResultSet rs = st.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.checkEmailExists error: " + e.getMessage());
            return false;
        }
    }

    /** Đăng ký với tham số rời rạc (hash đã có sẵn). */
    public boolean registerUser(String fullName, String email, String bcryptHash) {
        String norm = normalizeEmail(email);
        String sql = "INSERT INTO " + TBL + " (FullName, Email, PasswordHash, Role, CreatedAt) "
                   + "VALUES (?, ?, ?, 'Customer', NOW())";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, nz(fullName));
            st.setString(2, norm);
            st.setString(3, ensureBcrypt(bcryptHash));
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("UserDAO.registerUser(str) error: " + e.getMessage());
            return false;
        }
    }

    /** Đăng ký với User (nếu lỡ truyền raw password, sẽ tự hash). */
    public boolean registerUser(User user) {
        if (user == null) return false;

        String hash = user.getPasswordHash();
        if (!isBcrypt(hash)) {
            hash = BCrypt.hashpw(nz(hash), BCrypt.gensalt(12));
        }
        String role = normalizeRole(user.getRole());

        String sql = "INSERT INTO " + TBL + " (FullName, Email, PasswordHash, Role, CreatedAt) "
                   + "VALUES (?, ?, ?, ?, NOW())";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, nz(user.getFullName()));
            st.setString(2, normalizeEmail(user.getEmail()));
            st.setString(3, hash);
            st.setString(4, role);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("UserDAO.registerUser(user) error: " + e.getMessage());
            return false;
        }
    }

    /* ===================== PROFILE / LOOKUP ===================== */

    public boolean updateUserProfile(User user) {
        String sql = "UPDATE " + TBL + " SET FullName = ?, Phone = ?, Address = ? WHERE UserID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, nz(user.getFullName()));
            st.setString(2, nz(user.getPhone()));
            st.setString(3, nz(user.getAddress()));
            st.setInt(4, user.getUserID());
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("UserDAO.updateUserProfile error: " + e.getMessage());
            return false;
        }
    }

    public User getUserByEmail(String email) {
        String norm = normalizeEmail(email);
        String sql = "SELECT " + COLS + " FROM " + TBL + " WHERE Email = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, norm);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return mapUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.getUserByEmail error: " + e.getMessage());
        }
        return null;
    }

    public User getUserById(int userId) {
        String sql = "SELECT " + COLS + " FROM " + TBL + " WHERE UserID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setInt(1, userId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return mapUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.getUserById error: " + e.getMessage());
        }
        return null;
    }

    /* ===================== PASSWORD ===================== */

    /** Cập nhật mật khẩu bằng email – chấp nhận raw hoặc bcrypt, luôn lưu dạng bcrypt. */
    public boolean updatePasswordByEmail(String email, String rawOrHash) {
        String norm = normalizeEmail(email);
        String hash = ensureBcrypt(rawOrHash);
        String sql = "UPDATE " + TBL + " SET PasswordHash = ? WHERE Email = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, hash);
            st.setString(2, norm);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("UserDAO.updatePasswordByEmail error: " + e.getMessage());
            return false;
        }
    }

    /** Cập nhật mật khẩu bằng UserID – chấp nhận raw hoặc bcrypt, luôn lưu dạng bcrypt. */
    public boolean updatePasswordByID(int userID, String rawOrHash) {
        String hash = ensureBcrypt(rawOrHash);
        String sql = "UPDATE " + TBL + " SET PasswordHash = ? WHERE UserID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, hash);
            st.setInt(2, userID);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("UserDAO.updatePasswordByID error: " + e.getMessage());
            return false;
        }
    }

    /* ===================== ADMIN UTILS ===================== */

    public int countAll() {
        String sql = "SELECT COUNT(*) FROM " + TBL;
        try (PreparedStatement st = connection.prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("UserDAO.countAll error: " + e.getMessage());
        }
        return 0;
    }

    public List<User> searchUsers(String q) {
        List<User> list = new ArrayList<>();
        String base = "SELECT UserID, FullName, Email, Phone, Address, Role, CreatedAt FROM " + TBL + " ";
        String sql = base + ((q == null || q.isBlank()) ? "" : "WHERE FullName LIKE ? OR Email LIKE ? ")
                   + "ORDER BY CreatedAt DESC LIMIT 100";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            if (q != null && !q.isBlank()) {
                String like = "%" + q.trim() + "%";
                st.setString(1, like);
                st.setString(2, like);
            }
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    User u = new User();
                    u.setUserID(rs.getInt(1));
                    u.setFullName(rs.getString(2));
                    u.setEmail(rs.getString(3));
                    u.setPhone(rs.getString(4));
                    u.setAddress(rs.getString(5));
                    u.setRole(rs.getString(6));
                    u.setCreatedAt(rs.getTimestamp(7));
                    list.add(u);
                }
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.searchUsers error: " + e.getMessage());
        }
        return list;
    }

    /** Chỉ cho phép: Admin / Staff / Customer */
    public boolean updateRole(int userId, String role) {
        String safeRole = normalizeRole(role);
        String sql = "UPDATE " + TBL + " SET Role = ? WHERE UserID = ?";
        try (PreparedStatement st = connection.prepareStatement(sql)) {
            st.setString(1, safeRole);
            st.setInt(2, userId);
            return st.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("UserDAO.updateRole error: " + e.getMessage());
            return false;
        }
    }

    /* ===================== Helpers ===================== */

    private static String nz(String s) {
        return (s == null) ? "" : s;
    }

    /** email chuẩn hóa để so sánh/unique. */
    private static String normalizeEmail(String email) {
        if (email == null) return null;
        return email.trim().toLowerCase(Locale.ROOT);
    }

    private static boolean isBcrypt(String s) {
        return s != null && s.startsWith("$2"); // $2a/$2b/$2y
    }

    private static String ensureBcrypt(String rawOrHash) {
        if (isBcrypt(rawOrHash)) return rawOrHash;
        String raw = (rawOrHash == null) ? "" : rawOrHash;
        return BCrypt.hashpw(raw, BCrypt.gensalt(12));
    }

    private static String normalizeRole(String role) {
        if (role == null) return "Customer";
        String r = role.trim();
        if (r.equalsIgnoreCase("Admin")) return "Admin";
        if (r.equalsIgnoreCase("Staff")) return "Staff";
        return "Customer";
    }

    private static User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserID(rs.getInt("UserID"));
        u.setFullName(rs.getString("FullName"));
        u.setEmail(rs.getString("Email"));
        u.setPasswordHash(rs.getString("PasswordHash"));
        u.setPhone(rs.getString("Phone"));
        u.setAddress(rs.getString("Address"));
        u.setRole(rs.getString("Role"));
        u.setCreatedAt(rs.getTimestamp("CreatedAt"));
        return u;
    }
}
