package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import model.User;
import org.mindrot.jbcrypt.BCrypt;

public class UserDAO extends DBContext {

    /** Giữ 1 tên bảng duy nhất (MySQL: backtick để tránh keyword) */
    private static final String TBL  = "`Users`";
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

    /** Alias để AdminUserController dùng `getById` cho gọn */
    public User getById(int id) {
        return getUserById(id);
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

    /* ===================== ADMIN UTILS CŨ ===================== */

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

    /** Dùng cho Admin list user + search theo q (tên/email) – bản cũ không phân trang */
    public List<User> searchUsers(String q) {
        List<User> list = new ArrayList<>();
        String base = "SELECT " + COLS + " FROM " + TBL + " ";
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
                    list.add(mapUser(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.searchUsers error: " + e.getMessage());
        }
        return list;
    }

    /** Lấy tất cả user (dùng cho Admin khi không nhập q) */
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT " + COLS + " FROM " + TBL + " ORDER BY CreatedAt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapUser(rs));
            }
        } catch (Exception e) {
            System.err.println("UserDAO.getAllUsers error: " + e.getMessage());
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

    /* ===================== ADMIN + PHÂN TRANG MỞ RỘNG ===================== */

    /**
     * Đếm tổng số user theo bộ lọc để phân trang.
     * @param q      chuỗi tìm kiếm (tên/email)
     * @param role   lọc theo vai trò (Admin/Staff/Customer hoặc null/all)
     * @param status để dành cho sau này (active/inactive...), hiện có thể null
     */
    public int countUsers(String q, String role, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM " + TBL + " WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND (FullName LIKE ? OR Email LIKE ?)");
            String like = "%" + q.trim() + "%";
            params.add(like);
            params.add(like);
        }

        if (role != null && !role.isBlank() && !"all".equalsIgnoreCase(role)) {
            sql.append(" AND Role = ?");
            params.add(normalizeRole(role));
        }

        // status: nếu sau này có cột Status/IsActive thì thêm điều kiện tại đây

        try (PreparedStatement st = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                st.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.countUsers error: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Tìm user theo q + role + status + phân trang.
     *
     * @param offset   vị trí bắt đầu ( (page-1) * pageSize )
     * @param pageSize số dòng mỗi trang
     */
    public List<User> searchUsers(String q, String role, String status, int offset, int pageSize) {
        List<User> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder("SELECT " + COLS + " FROM " + TBL + " WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (q != null && !q.isBlank()) {
            sql.append(" AND (FullName LIKE ? OR Email LIKE ?)");
            String like = "%" + q.trim() + "%";
            params.add(like);
            params.add(like);
        }

        if (role != null && !role.isBlank() && !"all".equalsIgnoreCase(role)) {
            sql.append(" AND Role = ?");
            params.add(normalizeRole(role));
        }

        // status: để dành, chưa lọc gì thêm

        sql.append(" ORDER BY CreatedAt DESC LIMIT ?, ?");
        params.add(offset);
        params.add(pageSize);

        try (PreparedStatement st = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                st.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapUser(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("UserDAO.searchUsers(q,role,status,offset,pageSize) error: " + e.getMessage());
        }

        return list;
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

    static String normalizeRole(String role) {
        if (role == null) return "Customer";
        String r = role.trim();
        if (r.equalsIgnoreCase("Admin")) return "Admin";
        if (r.equalsIgnoreCase("Staff")) return "Staff";
        return "Customer";
    }

    /** Map 1 dòng ResultSet -> User đầy đủ */
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
