package dal;

import model.Product;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * DAO cho bảng Products.
 * - Hỗ trợ: tìm kiếm, lọc, sắp xếp, phân trang, thống kê, nhiều ảnh (product_images).
 * - Tương thích với AdminProductController mới (sort: newest, priceasc, pricedesc, stockasc, stockdesc).
 */
public class ProductDAO extends DBContext {

    // ======================= CONNECTION HELPER =======================

    /**
     * Lấy connection hiện tại, nếu null/closed thì tạo mới.
     */
    private Connection requireConn() throws SQLException {
        if (this.connection == null || this.connection.isClosed()) {
            this.connection = new DBContext().connection;
        }
        return this.connection;
    }

    // ======================= SINGLE / DETAIL =======================

    /**
     * Lấy 1 sản phẩm theo ID (kèm danh sách ảnh từ product_images).
     */
    public Product getProductByID(int id) {
        final String sql = "SELECT * FROM Products WHERE ProductID = ?";
        Product product = null;
        try (PreparedStatement st = requireConn().prepareStatement(sql)) {
            st.setInt(1, id);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    product = mapResultSetToProduct(rs);
                    // Gán danh sách ảnh chi tiết
                    product.setImageUrls(getProductImages(id));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getProductByID: " + e.getMessage());
        }
        return product;
    }

    // ======================= SEARCH / FILTER / SORT =======================

    // --------- Overload cũ (giữ tương thích) ---------

    public List<Product> searchAndFilterProducts(String keyword,
                                                 List<Integer> categoryIds,
                                                 double minPrice,
                                                 double maxPrice,
                                                 String sortBy) {
        return searchAndFilterProducts(keyword, categoryIds, minPrice, maxPrice, sortBy, null);
    }

    public List<Product> searchAndFilterProducts(String keyword,
                                                 List<Integer> categoryIds,
                                                 double minPrice,
                                                 double maxPrice,
                                                 String sortBy,
                                                 int offset,
                                                 int pageSize) {
        return searchAndFilterProducts(keyword, categoryIds, minPrice, maxPrice, sortBy, offset, pageSize, null);
    }

    public int countProducts(String keyword,
                             List<Integer> categoryIds,
                             double minPrice,
                             double maxPrice) {
        return countProducts(keyword, categoryIds, minPrice, maxPrice, null);
    }

    // --------- Bản có brandName (dùng cho AdminProductController mới) ---------

    /**
     * Tìm kiếm + lọc + sort, không phân trang (dùng khi cần lấy full list).
     */
    public List<Product> searchAndFilterProducts(String keyword,
                                                 List<Integer> categoryIds,
                                                 double minPrice,
                                                 double maxPrice,
                                                 String sortBy,
                                                 String brandName) {
        StringBuilder sql = new StringBuilder("SELECT * FROM Products WHERE 1=1");
        List<Object> params = new ArrayList<>();

        buildWhere(sql, params, keyword, categoryIds, minPrice, maxPrice, brandName);
        appendOrderBy(sql, sortBy);

        List<Product> list = new ArrayList<>();
        try (PreparedStatement st = requireConn().prepareStatement(sql.toString())) {
            bindParams(st, params);
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Product p = mapResultSetToProduct(rs);
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in searchAndFilterProducts (no paging): " + e.getMessage());
        }
        return list;
    }

    /**
     * Tìm kiếm + lọc + sort + phân trang + brandName.
     * Dùng trực tiếp trong AdminProductController (list + export).
     */
    public List<Product> searchAndFilterProducts(String keyword,
                                                 List<Integer> categoryIds,
                                                 double minPrice,
                                                 double maxPrice,
                                                 String sortBy,
                                                 int offset,
                                                 int pageSize,
                                                 String brandName) {
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
                    Product p = mapResultSetToProduct(rs);
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in searchAndFilterProducts (paged): " + e.getMessage());
        }
        return list;
    }

    /**
     * Đếm tổng sản phẩm theo filter (có brandName).
     */
    public int countProducts(String keyword,
                             List<Integer> categoryIds,
                             double minPrice,
                             double maxPrice,
                             String brandName) {
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

    /**
     * Lấy danh sách thương hiệu (distinct) để fill combobox filter.
     */
    public List<String> getDistinctBrands() {
        List<String> brands = new ArrayList<>();
        String sql = "SELECT DISTINCT Brand FROM Products " +
                     "WHERE Brand IS NOT NULL AND Brand <> '' " +
                     "ORDER BY Brand ASC";
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

    // ======================= HOME SECTIONS / RECOMMEND =======================

    /**
     * Sản phẩm mới (Stock > 0) theo CreatedAt DESC.
     */
    public List<Product> getNewArrivals(int limit) throws SQLException {
        String sql = "SELECT * FROM Products WHERE Stock > 0 ORDER BY CreatedAt DESC LIMIT ?";
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

    /**
     * Best-sellers trong X ngày gần đây (dựa trên OrderItems).
     */
    public List<Product> getBestSellers(int limit, int days) throws SQLException {
        String sql =
                "SELECT p.* FROM Products p " +
                "JOIN OrderItems oi ON oi.ProductID = p.ProductID " +
                "JOIN Orders o ON o.OrderID = oi.OrderID " +
                "WHERE o.OrderDate >= DATE_SUB(NOW(), INTERVAL ? DAY) " +
                "GROUP BY p.ProductID " +
                "ORDER BY SUM(oi.Quantity) DESC " +
                "LIMIT ?";
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

    /**
     * Trending: có đơn gần đây hoặc mới tạo trong X ngày.
     */
    public List<Product> getTrending(int limit, int days) throws SQLException {
        String sql =
                "SELECT p.* FROM Products p " +
                "LEFT JOIN OrderItems oi ON oi.ProductID = p.ProductID " +
                "LEFT JOIN Orders o ON o.OrderID = oi.OrderID " +
                "WHERE (o.OrderDate >= DATE_SUB(NOW(), INTERVAL ? DAY) " +
                "   OR  p.CreatedAt >= DATE_SUB(NOW(), INTERVAL ? DAY)) " +
                "GROUP BY p.ProductID " +
                "ORDER BY COALESCE(SUM(oi.Quantity),0) DESC, p.CreatedAt DESC " +
                "LIMIT ?";
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

    /**
     * Sản phẩm theo một nhóm category (theo mùa, theo chủ đề…).
     */
    public List<Product> getSeasonalByCategory(List<Integer> cids, int limit) throws SQLException {
        if (cids == null || cids.isEmpty()) return Collections.emptyList();

        String in = String.join(",", Collections.nCopies(cids.size(), "?"));
        String sql =
                "SELECT * FROM Products WHERE CategoryID IN (" + in + ") " +
                "ORDER BY CreatedAt DESC " +
                "LIMIT ?";
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

    // ======================= RELATED / BEST SELLER DTO =======================

    /**
     * Sản phẩm liên quan trong cùng category (loại trừ chính nó).
     */
    public List<Product> findRelated(int categoryId, int excludeProductId, int limit) throws SQLException {
        String sql = "SELECT * FROM Products WHERE CategoryID = ? AND ProductID <> ? " +
                     "ORDER BY CreatedAt DESC LIMIT ?";
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

    /**
     * DTO BestSeller có kèm số lượng đã bán.
     */
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
        String sql =
                "SELECT p.*, COALESCE(SUM(oi.Quantity),0) AS Sold " +
                "FROM Products p " +
                "JOIN OrderItems oi ON oi.ProductID = p.ProductID " +
                "JOIN Orders o ON o.OrderID = oi.OrderID " +
                "WHERE o.OrderDate >= DATE_SUB(NOW(), INTERVAL ? DAY) " +
                "GROUP BY p.ProductID " +
                "ORDER BY Sold DESC " +
                "LIMIT ?";
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

    // ======================= CRUD CƠ BẢN (KHÔNG ẢNH PHỤ) =======================

    public boolean insertProduct(Product p) {
        String sql =
                "INSERT INTO Products(" +
                "CategoryID, ProductName, Price, Description, Material, Dimensions, " +
                "Features, ImageURL, Brand, Stock, CreatedAt) " +
                "VALUES(?,?,?,?,?,?,?,?,?,?,NOW())";
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
        String sql =
                "UPDATE Products SET " +
                "CategoryID=?, ProductName=?, Price=?, Description=?, Material=?, Dimensions=?, " +
                "Features=?, ImageURL=?, Brand=?, Stock=? " +
                "WHERE ProductID=?";
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
        String sql = "DELETE FROM Products WHERE ProductID = ?";
        try (PreparedStatement st = requireConn().prepareStatement(sql)) {
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("deleteProduct error: " + e.getMessage());
            return false;
        }
    }

    // ======================= CRUD + ẢNH PHỤ (product_images) =======================

    /**
     * Thêm sản phẩm + danh sách ảnh (imageUrls) trong 1 transaction.
     * - p.imageURL: ảnh đại diện (thumbnail)
     * - p.imageUrls: list ảnh chi tiết (tối đa 3 hoặc bao nhiêu tùy bạn).
     */
    public boolean insertProductWithImages(Product p) {
        String insertProduct =
                "INSERT INTO Products(" +
                "CategoryID, ProductName, Description, Price, Material, Dimensions, " +
                "Features, ImageURL, Brand, Stock, CreatedAt) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?,NOW())";

        String insertImage =
                "INSERT INTO product_images (ProductID, ImageURL) VALUES (?,?)";

        Connection con = null;
        try {
            con = requireConn();
            boolean oldAuto = con.getAutoCommit();
            con.setAutoCommit(false);

            // 1. Insert product
            try (PreparedStatement ps = con.prepareStatement(insertProduct, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, p.getCategoryID());
                ps.setString(2, p.getProductName());
                ps.setString(3, p.getDescription());
                ps.setDouble(4, p.getPrice());
                ps.setString(5, p.getMaterial());
                ps.setString(6, p.getDimensions());
                ps.setString(7, p.getFeatures());
                ps.setString(8, p.getImageURL());
                ps.setString(9, p.getBrand());
                ps.setInt(10, Math.max(0, p.getStock()));

                int affected = ps.executeUpdate();
                if (affected == 0) {
                    con.rollback();
                    con.setAutoCommit(oldAuto);
                    return false;
                }

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        p.setProductID(rs.getInt(1));
                    }
                }
            }

            // 2. Insert images chi tiết
            if (p.getImageUrls() != null && !p.getImageUrls().isEmpty()) {
                try (PreparedStatement psImg = con.prepareStatement(insertImage)) {
                    for (String url : p.getImageUrls()) {
                        if (url == null || url.isBlank()) continue;
                        psImg.setInt(1, p.getProductID());
                        psImg.setString(2, url.trim());
                        psImg.addBatch();
                    }
                    psImg.executeBatch();
                }
            }

            con.commit();
            con.setAutoCommit(true);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            if (con != null) {
                try { con.rollback(); } catch (SQLException ignore) {}
            }
            return false;
        }
    }

    /**
     * Cập nhật sản phẩm + thay toàn bộ ảnh chi tiết trong 1 transaction.
     */
    public boolean updateProductWithImages(Product p) {
        String updateProduct =
                "UPDATE Products SET " +
                "CategoryID=?, ProductName=?, Description=?, Price=?, " +
                "Material=?, Dimensions=?, Features=?, ImageURL=?, Brand=?, Stock=? " +
                "WHERE ProductID=?";

        String deleteImages = "DELETE FROM product_images WHERE ProductID = ?";
        String insertImage  = "INSERT INTO product_images (ProductID, ImageURL) VALUES (?,?)";

        Connection con = null;
        try {
            con = requireConn();
            boolean oldAuto = con.getAutoCommit();
            con.setAutoCommit(false);

            // 1. Update product
            try (PreparedStatement ps = con.prepareStatement(updateProduct)) {
                ps.setInt(1, p.getCategoryID());
                ps.setString(2, p.getProductName());
                ps.setString(3, p.getDescription());
                ps.setDouble(4, p.getPrice());
                ps.setString(5, p.getMaterial());
                ps.setString(6, p.getDimensions());
                ps.setString(7, p.getFeatures());
                ps.setString(8, p.getImageURL());
                ps.setString(9, p.getBrand());
                ps.setInt(10, Math.max(0, p.getStock()));
                ps.setInt(11, p.getProductID());
                ps.executeUpdate();
            }

            // 2. Xóa ảnh cũ
            try (PreparedStatement psDel = con.prepareStatement(deleteImages)) {
                psDel.setInt(1, p.getProductID());
                psDel.executeUpdate();
            }

            // 3. Thêm ảnh mới
            if (p.getImageUrls() != null && !p.getImageUrls().isEmpty()) {
                try (PreparedStatement psImg = con.prepareStatement(insertImage)) {
                    for (String url : p.getImageUrls()) {
                        if (url == null || url.isBlank()) continue;
                        psImg.setInt(1, p.getProductID());
                        psImg.setString(2, url.trim());
                        psImg.addBatch();
                    }
                    psImg.executeBatch();
                }
            }

            con.commit();
            con.setAutoCommit(true);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            if (con != null) {
                try { con.rollback(); } catch (SQLException ignore) {}
            }
            return false;
        }
    }

    // ======================= IMAGE HELPERS =======================

    /**
     * Lấy danh sách URL ảnh chi tiết của product từ bảng product_images.
     */
    public List<String> getProductImages(int productId) {
        List<String> result = new ArrayList<>();
        String sql = "SELECT ImageURL FROM product_images WHERE ProductID = ? ORDER BY ImageID ASC";
        try (PreparedStatement ps = requireConn().prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String url = rs.getString("ImageURL");
                    if (url != null && !url.isBlank()) {
                        result.add(url.trim());
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error in getProductImages: " + e.getMessage());
        }
        return result;
    }

    // ======================= PRIVATE HELPERS =======================

    /**
     * Build điều kiện WHERE chung cho search/filter.
     */
    private void buildWhere(StringBuilder sql,
                            List<Object> params,
                            String keyword,
                            List<Integer> categoryIds,
                            double minPrice,
                            double maxPrice,
                            String brandName) {

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

        if (brandName != null && !brandName.trim().isEmpty()
                && !"all".equalsIgnoreCase(brandName.trim())) {
            sql.append(" AND Brand = ?");
            params.add(brandName.trim());
        }
    }

    /**
     * Áp dụng ORDER BY dựa trên tham số sort từ controller.
     * Hỗ trợ: newest, priceasc, pricedesc, stockasc, stockdesc.
     */
    private void appendOrderBy(StringBuilder sql, String sortBy) {
        if (sortBy == null) {
            sql.append(" ORDER BY CreatedAt DESC");
            return;
        }
        String s = sortBy.toLowerCase();
        switch (s) {
            case "priceasc":
                sql.append(" ORDER BY Price ASC");
                break;
            case "pricedesc":
                sql.append(" ORDER BY Price DESC");
                break;
            case "stockasc":
                sql.append(" ORDER BY Stock ASC");
                break;
            case "stockdesc":
                sql.append(" ORDER BY Stock DESC");
                break;
            case "newest":
            default:
                sql.append(" ORDER BY CreatedAt DESC");
                break;
        }
    }

    /**
     * Bind param theo thứ tự vào PreparedStatement.
     */
    private void bindParams(PreparedStatement st, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            st.setObject(i + 1, params.get(i));
        }
    }

    /**
     * Map 1 dòng ResultSet -> Product (không có imageUrls).
     */
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
        // imageUrls sẽ được gán riêng nếu cần (getProductByID)
        return p;
    }
    public List<Product> getLowStockProducts(int threshold) {
        List<Product> list = new ArrayList<>();

        String sql =
            "SELECT TOP (?) * " +
            "FROM Products " +
            "WHERE stock <= ? " +
            "ORDER BY stock ASC, productName ASC";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, 50);          // giới hạn tối đa 50 dòng (tùy bạn chỉnh)
            ps.setInt(2, threshold);   // ngưỡng tồn kho

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setProductID(rs.getInt("productID"));
                p.setProductName(rs.getString("productName"));
                p.setStock(rs.getInt("stock"));

                // nếu Product có thêm cột (price, imageURL, ...) thì set thêm
                // p.setPrice(rs.getDouble("price"));
                // p.setImageURL(rs.getString("imageURL"));

                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
}
