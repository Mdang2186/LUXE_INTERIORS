package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Category;

public class CategoryDAO extends DBContext {

    private Connection requireConn() throws SQLException {
        if (this.connection == null || this.connection.isClosed()) {
            this.connection = new DBContext().connection;
        }
        return this.connection;
    }

    // =====================================================
    // 1. Lấy tất cả danh mục (không phân trang)
    // =====================================================
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT CategoryID, CategoryName FROM Categories ORDER BY CategoryName ASC";

        try (PreparedStatement st = requireConn().prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                Category c = new Category();
                c.setCategoryID(rs.getInt("CategoryID"));
                c.setCategoryName(rs.getString("CategoryName"));
                list.add(c);
            }
        } catch (SQLException e) {
            System.out.println("Error in getAllCategories: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    // =====================================================
    // 2. Đếm tổng danh mục (không filter)
    // =====================================================
    public int countCategories() {
        return countCategories(null);
    }

    // =====================================================
    // 3. Đếm danh mục theo từ khóa (dùng cho phân trang)
    // =====================================================
    public int countCategories(String keyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Categories");
        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();

        if (hasKeyword) {
            sql.append(" WHERE CategoryName LIKE ?");
        }

        try (PreparedStatement st = requireConn().prepareStatement(sql.toString())) {
            if (hasKeyword) {
                st.setString(1, "%" + keyword.trim() + "%");
            }
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            System.out.println("Error in countCategories(keyword): " + e.getMessage());
        }
        return 0;
    }

    // =====================================================
    // 4. Tìm kiếm + phân trang
    //    keyword = null => lấy tất cả, có LIMIT offset,size
    // =====================================================
    public List<Category> searchCategories(String keyword, int offset, int limit) {
        List<Category> list = new ArrayList<>();

        boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
        StringBuilder sql = new StringBuilder(
                "SELECT CategoryID, CategoryName FROM Categories"
        );
        if (hasKeyword) {
            sql.append(" WHERE CategoryName LIKE ?");
        }
        sql.append(" ORDER BY CategoryName ASC LIMIT ?, ?");   // MySQL: offset, size

        try (PreparedStatement st = requireConn().prepareStatement(sql.toString())) {
            int idx = 1;
            if (hasKeyword) {
                st.setString(idx++, "%" + keyword.trim() + "%");
            }
            st.setInt(idx++, offset);
            st.setInt(idx, limit);

            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Category c = new Category();
                    c.setCategoryID(rs.getInt("CategoryID"));
                    c.setCategoryName(rs.getString("CategoryName"));
                    list.add(c);
                }
            }
        } catch (Exception e) {
            System.out.println("Error in searchCategories: " + e.getMessage());
            e.printStackTrace();
        }

        return list;
    }

    // =====================================================
    // 5. Lấy 1 category theo ID
    // =====================================================
    public Category getById(int id) {
        String sql = "SELECT CategoryID, CategoryName FROM Categories WHERE CategoryID=?";
        try (PreparedStatement st = requireConn().prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    Category c = new Category();
                    c.setCategoryID(rs.getInt("CategoryID"));
                    c.setCategoryName(rs.getString("CategoryName"));
                    return c;
                }
            }
        } catch (Exception e) {
            System.out.println("Error in getById(Category): " + e.getMessage());
        }
        return null;
    }

    // =====================================================
    // 6. Insert
    // =====================================================
    public boolean insert(Category c) {
        String sql = "INSERT INTO Categories(CategoryName) VALUES(?)";
        try (PreparedStatement st = requireConn().prepareStatement(sql)) {
            st.setString(1, c.getCategoryName());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Error in insert(Category): " + e.getMessage());
            return false;
        }
    }

    // =====================================================
    // 7. Update
    // =====================================================
    public boolean update(Category c) {
        String sql = "UPDATE Categories SET CategoryName=? WHERE CategoryID=?";
        try (PreparedStatement st = requireConn().prepareStatement(sql)) {
            st.setString(1, c.getCategoryName());
            st.setInt(2, c.getCategoryID());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Error in update(Category): " + e.getMessage());
            return false;
        }
    }

    // =====================================================
    // 8. Delete
    // =====================================================
    public boolean delete(int id) {
        String sql = "DELETE FROM Categories WHERE CategoryID=?";
        try (PreparedStatement st = requireConn().prepareStatement(sql)) {
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Error in delete(Category): " + e.getMessage());
            return false;
        }
    }
}
