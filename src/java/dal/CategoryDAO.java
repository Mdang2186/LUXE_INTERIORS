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

    /**
     * Lấy tất cả danh mục. (Đã sửa lỗi cột và chuẩn hóa kết nối)
     */
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT CategoryID, CategoryName FROM Categories ORDER BY CategoryName ASC";

        try (PreparedStatement st = requireConn().prepareStatement(sql); 
             ResultSet rs = st.executeQuery()) {

            while (rs.next()) {
                Category c = new Category();
                c.setCategoryID(rs.getInt("CategoryID"));
                c.setCategoryName(rs.getString("CategoryName"));
                // KHÔNG set 'Description' vì cột này không tồn tại
                list.add(c);
            }
        } catch (SQLException e) {
            System.out.println("Error in getAllCategories: " + e.getMessage());
            e.printStackTrace(); 
        }
        return list;
    }

    public int countCategories() {
        String sql = "SELECT COUNT(*) FROM Categories";
        try (var st = requireConn().prepareStatement(sql); 
             var rs = st.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
             System.out.println("Error in countCategories: " + e.getMessage());
        }
        return 0;
    }

    public Category getById(int id) {
        // SỬA LỖI: Bỏ cột 'Description'
        String sql = "SELECT CategoryID, CategoryName FROM Categories WHERE CategoryID=?";
        try (var st = requireConn().prepareStatement(sql)) {
            st.setInt(1, id);
            try (var rs = st.executeQuery()) {
                if (rs.next()) {
                    Category c = new Category();
                    c.setCategoryID(rs.getInt(1));
                    c.setCategoryName(rs.getString(2));
                    // c.setDescription(rs.getString(3)); // LỖI: Cột không tồn tại
                    return c;
                }
            }
        } catch (Exception e) {
             System.out.println("Error in getById(Category): " + e.getMessage());
        }
        return null;
    }

    public boolean insert(Category c) {
        // SỬA LỖI: Bỏ cột 'Description'
        String sql = "INSERT INTO Categories(CategoryName) VALUES(?)";
        try (var st = requireConn().prepareStatement(sql)) {
            st.setString(1, c.getCategoryName());
            // st.setString(2, c.getDescription()); // LỖI: Cột không tồn tại
            return st.executeUpdate() > 0;
        } catch (Exception e) {
             System.out.println("Error in insert(Category): " + e.getMessage());
            return false;
        }
    }

    public boolean update(Category c) {
        // SỬA LỖI: Bỏ cột 'Description'
        String sql = "UPDATE Categories SET CategoryName=? WHERE CategoryID=?";
        try (var st = requireConn().prepareStatement(sql)) {
            st.setString(1, c.getCategoryName());
            // st.setString(2, c.getDescription()); // LỖI: Cột không tồn tại
            st.setInt(2, c.getCategoryID()); // THAY ĐỔI: Index
            return st.executeUpdate() > 0;
        } catch (Exception e) {
             System.out.println("Error in update(Category): " + e.getMessage());
            return false;
        }
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM Categories WHERE CategoryID=?";
        try (var st = requireConn().prepareStatement(sql)) {
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
             System.out.println("Error in delete(Category): " + e.getMessage());
            return false;
        }
    }
}