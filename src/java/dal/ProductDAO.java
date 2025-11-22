package dal;

import model.Product;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Handles all database operations related to the Products table.
 */
public class ProductDAO extends DBContext {

    /* ========= Connection helper ========= */
    private Connection requireConn() throws SQLException {
        if (this.connection == null || this.connection.isClosed()) {
            this.connection = new DBContext().connection;
        }
        return this.connection;
    }

    /* ========= Single / Detail ========= */
    public Product getProductByID(int id) {
        final String sql = "SELECT * FROM Products WHERE ProductID = ?";
        Product product = null;
        try (PreparedStatement st = requireConn().prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    product = mapResultSetToProduct(rs);
                    product.setImageUrls(getProductImages(id));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getProductByID: " + e.getMessage());
        }
        return product;
    }

    // Backward-compatible overloads (giữ API cũ nếu có nơi khác gọi)
    public List<Product> searchAndFilterProducts(String keyword, List<Integer> categoryIds,
            double minPrice, double maxPrice, String sortBy) {
        return searchAndFilterProducts(keyword, categoryIds, minPrice, maxPrice, sortBy, (String) null);
    }

    public List<Product> searchAndFilterProducts(String keyword, List<Integer> categoryIds,
            double minPrice, double maxPrice, String sortBy,
            int offset, int pageSize) {
        return searchAndFilterProducts(keyword, categoryIds, minPrice, maxPrice, sortBy, offset, pageSize, null);
    }

    public int countProducts(String keyword, List<Integer> categoryIds, double minPrice, double maxPrice) {
        return countProducts(keyword, categoryIds, minPrice, maxPrice, null);
    }

    public List<Product> findRelated(int categoryId, int excludeProductId, int limit) throws SQLException {
        String sql = "SELECT * FROM Products WHERE CategoryID=? AND ProductID<>? ORDER BY CreatedAt DESC LIMIT ?";
        List<Product> list = new ArrayList<>();
        try (PreparedStatement ps = requireConn().prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            ps.setInt(2, excludeProductId);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        }
        return list;
    }

    /* ========= Search / Filter / Sort ========= */

    /**
     * Thêm 'brandName' vào phương thức
     */
    public List<Product> searchAndFilterProducts(String keyword, List<Integer> categoryIds,
            double minPrice, double maxPrice, String sortBy, String brandName) {
        StringBuilder sql = new StringBuilder("SELECT * FROM Products WHERE 1=1");
        List<Object> params = new ArrayList<>();

        buildWhere(sql, params, keyword, categoryIds, minPrice, maxPrice, brandName);
        appendOrderBy(sql, sortBy);

        List<Product> list = new ArrayList<>();
        try (PreparedStatement st = requireConn().prepareStatement(sql.toString())) {
            bindParams(st, params);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in searchAndFilterProducts: " + e.getMessage());
        }
        return list;
    }

    /**
     * Thêm 'brandName' vào phương thức (paged)
     */
    public List<Product> searchAndFilterProducts(String keyword, List<Integer> categoryIds,
            double minPrice, double maxPrice, String sortBy,
            int offset, int pageSize, String brandName) {
        StringBuilder sql = new StringBuilder("SELECT * FROM Products WHERE 1=1");
        List<Object> params = new ArrayList<>();

        buildWhere(sql, params, keyword, categoryIds, minPrice, maxPrice, brandName);
        appendOrderBy(sql, sortBy);

        sql.append(" LIMIT ?, ?");
        params.add(Math.max(0, offset));
        params.add(Math.max(1, pageSize));

        List<Product> list = new ArrayList<>();
        try (PreparedStatement st = requireConn().prepareStatement(sql.toString())) {
            bindParams(st, params);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in searchAndFilterProducts(paged): " + e.getMessage());
        }
        return list;
    }

    /**
     * Thêm 'brandName' vào phương thức count
     */
    public int countProducts(String keyword, List<Integer> categoryIds, double minPrice, double maxPrice, String brandName) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Products WHERE 1=1");
        List<Object> params = new ArrayList<>();
        buildWhere(sql, params, keyword, categoryIds, minPrice, maxPrice, brandName);

        try (PreparedStatement st = requireConn().prepareStatement(sql.toString())) {
            bindParams(st, params);
            try (ResultSet rs = st.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            System.err.println("Error in countProducts: " + e.getMessage());
            return 0;
        }
    }

    /* ========= PHƯƠNG THỨC MỚI: Lấy danh sách Thương hiệu ========= */

    /**
     * Lấy tất cả các thương hiệu (distinct) để hiển thị trong bộ lọc.
     */
    public List<String> getDistinctBrands() {
        List<String> brands = new ArrayList<>();
        String sql = "SELECT DISTINCT Brand FROM Products WHERE Brand IS NOT NULL AND Brand != '' ORDER BY Brand ASC";
        try (PreparedStatement st = requireConn().prepareStatement(sql);
             ResultSet rs = st.executeQuery()) {
            while (rs.next()) {
                brands.add(rs.getString("Brand"));
            }
        } catch (SQLException e) {
            System.err.println("Error in getDistinctBrands: " + e.getMessage());
        }
        return brands;
    }

    /* ========= Home sections (Giữ nguyên) ========= */

    public List<Product> getNewArrivals(int limit) throws SQLException {
        String sql = "SELECT * FROM Products WHERE Stock>0 ORDER BY CreatedAt DESC LIMIT ?";
        List<Product> list = new ArrayList<>();
        try (PreparedStatement ps = requireConn().prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        }
        return list;
    }

    public List<Product> getBestSellers(int limit, int days) throws SQLException {
        String sql
                = "SELECT p.* FROM Products p "
                + "JOIN OrderItems oi ON oi.ProductID = p.ProductID "
                + "JOIN Orders o ON o.OrderID = oi.OrderID "
                + "WHERE o.OrderDate >= DATE_SUB(NOW(), INTERVAL ? DAY) "
                + "GROUP BY p.ProductID "
                + "ORDER BY SUM(oi.Quantity) DESC "
                + "LIMIT ?";
        List<Product> list = new ArrayList<>();
        try (PreparedStatement ps = requireConn().prepareStatement(sql)) {
            ps.setInt(1, days);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        }
        return list;
    }

    public List<Product> getTrending(int limit, int days) throws SQLException {
        String sql
                = "SELECT p.* FROM Products p "
                + "LEFT JOIN OrderItems oi ON oi.ProductID = p.ProductID "
                + "LEFT JOIN Orders o ON o.OrderID = oi.OrderID "
                + "WHERE (o.OrderDate >= DATE_SUB(NOW(), INTERVAL ? DAY) "
                + "   OR  p.CreatedAt >= DATE_SUB(NOW(), INTERVAL ? DAY)) "
                + "GROUP BY p.ProductID "
                + "ORDER BY COALESCE(SUM(oi.Quantity),0) DESC, p.CreatedAt DESC "
                + "LIMIT ?";
        List<Product> list = new ArrayList<>();
        try (PreparedStatement ps = requireConn().prepareStatement(sql)) {
            ps.setInt(1, days);
            ps.setInt(2, days);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        }
        return list;
    }

    public List<Product> getSeasonalByCategory(List<Integer> cids, int limit) throws SQLException {
        if (cids == null || cids.isEmpty()) {
            return Collections.emptyList();
        }
        String in = String.join(",", Collections.nCopies(cids.size(), "?"));
        String sql = "SELECT * FROM Products WHERE CategoryID IN (" + in + ") ORDER BY CreatedAt DESC LIMIT ?";
        List<Product> list = new ArrayList<>();
        try (PreparedStatement ps = requireConn().prepareStatement(sql)) {
            int i = 1;
            for (Integer cid : cids) {
                ps.setInt(i++, cid);
            }
            ps.setInt(i, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToProduct(rs));
                }
            }
        }
        return list;
    }

    /* ========= Helpers ========= */

    private void buildWhere(StringBuilder sql, List<Object> params,
            String keyword, List<Integer> categoryIds,
            double minPrice, double maxPrice, String brandName) {

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND ProductName LIKE ?");
            params.add("%" + keyword.trim() + "%");
        }
        if (categoryIds != null && !categoryIds.isEmpty()) {
            sql.append(" AND CategoryID IN (");
            for (int i = 0; i < categoryIds.size(); i++) {
                sql.append(i == 0 ? "?" : ",?");
            }
            sql.append(")");
            params.addAll(categoryIds);
        }
        if (maxPrice > 0 && maxPrice > minPrice) {
            sql.append(" AND Price BETWEEN ? AND ?");
            params.add(minPrice);
            params.add(maxPrice);
        }

        if (brandName != null && !brandName.trim().isEmpty() && !"all".equalsIgnoreCase(brandName.trim())) {
            sql.append(" AND Brand = ?");
            params.add(brandName.trim());
        }
    }

    private void appendOrderBy(StringBuilder sql, String sortBy) {
        if (sortBy == null) {
            sql.append(" ORDER BY CreatedAt DESC");
            return;
        }
        switch (sortBy) {
            case "price-asc":
                sql.append(" ORDER BY Price ASC");
                break;
            case "price-desc":
                sql.append(" ORDER BY Price DESC");
                break;
            default:
                sql.append(" ORDER BY CreatedAt DESC");
                break;
        }
    }

    private void bindParams(PreparedStatement st, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            st.setObject(i + 1, params.get(i));
        }
    }

    private List<String> getProductImages(int productId) {
        List<String> images = new ArrayList<>();
        String sql = "SELECT ImageURL FROM product_images WHERE ProductID = ?";
        try (PreparedStatement st = requireConn().prepareStatement(sql)) {
            st.setInt(1, productId);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    images.add(rs.getString("ImageURL"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getProductImages: " + e.getMessage());
        }
        return images;
    }

    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductID(rs.getInt("ProductID"));
        p.setCategoryID(rs.getInt("CategoryID"));
        p.setProductName(rs.getString("ProductName"));
        p.setPrice(rs.getDouble("Price"));
        p.setDescription(rs.getString("Description"));
        p.setMaterial(rs.getString("Material"));
        p.setDimensions(rs.getString("Dimensions"));
        p.setFeatures(rs.getString("Features"));
        p.setImageURL(rs.getString("ImageURL"));
        p.setBrand(rs.getString("Brand"));
        p.setStock(rs.getInt("Stock"));
        p.setCreatedAt(rs.getTimestamp("CreatedAt"));
        return p;
    }

    /* ========= Lớp DTO ========= */
    public static class ProductSold {
        private final Product product;
        private final int sold;

        public ProductSold(Product product, int sold) {
            this.product = product;
            this.sold = sold;
        }
        public Product getProduct() { return product; }
        public int getSold() { return sold; }
    }

    public List<ProductSold> getBestSellersWithSold(int limit, int days) throws SQLException {
        String sql
                = "SELECT p.*, COALESCE(SUM(oi.Quantity),0) AS Sold "
                + "FROM Products p "
                + "JOIN OrderItems oi ON oi.ProductID = p.ProductID "
                + "JOIN Orders o ON o.OrderID = oi.OrderID "
                + "WHERE o.OrderDate >= DATE_SUB(NOW(), INTERVAL ? DAY) "
                + "GROUP BY p.ProductID "
                + "ORDER BY Sold DESC "
                + "LIMIT ?";
        List<ProductSold> list = new ArrayList<>();
        try (PreparedStatement ps = requireConn().prepareStatement(sql)) {
            ps.setInt(1, days);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = mapResultSetToProduct(rs);
                    int sold = rs.getInt("Sold");
                    list.add(new ProductSold(p, sold));
                }
            }
        }
        return list;
    }

    // CUD methods — dùng requireConn() và cap stock >= 0
    public boolean insertProduct(Product p) {
        String sql = "INSERT INTO Products(CategoryID,ProductName,Price,Description,Material,Dimensions,Features,ImageURL,Brand,Stock,CreatedAt) "
                + "VALUES(?,?,?,?,?,?,?,?,?,?,NOW())";
        try (PreparedStatement st = requireConn().prepareStatement(sql)) {
            st.setInt(1, p.getCategoryID());
            st.setString(2, p.getProductName());
            st.setDouble(3, p.getPrice());
            st.setString(4, p.getDescription());
            st.setString(5, p.getMaterial());
            st.setString(6, p.getDimensions());
            st.setString(7, p.getFeatures());
            st.setString(8, p.getImageURL());
            st.setString(9, p.getBrand());
            st.setInt(10, Math.max(0, p.getStock()));
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("insertProduct error: " + e.getMessage());
            return false;
        }
    }

    public boolean updateProduct(Product p) {
        String sql = "UPDATE Products SET CategoryID=?,ProductName=?,Price=?,Description=?,Material=?,Dimensions=?,Features=?,ImageURL=?,Brand=?,Stock=? WHERE ProductID=?";
        try (PreparedStatement st = requireConn().prepareStatement(sql)) {
            st.setInt(1, p.getCategoryID());
            st.setString(2, p.getProductName());
            st.setDouble(3, p.getPrice());
            st.setString(4, p.getDescription());
            st.setString(5, p.getMaterial());
            st.setString(6, p.getDimensions());
            st.setString(7, p.getFeatures());
            st.setString(8, p.getImageURL());
            st.setString(9, p.getBrand());
            st.setInt(10, Math.max(0, p.getStock()));
            st.setInt(11, p.getProductID());
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("updateProduct error: " + e.getMessage());
            return false;
        }
    }

    public boolean deleteProduct(int id) {
        String sql = "DELETE FROM Products WHERE ProductID=?";
        try (PreparedStatement st = requireConn().prepareStatement(sql)) {
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("deleteProduct error: " + e.getMessage());
            return false;
        }
    }

}
