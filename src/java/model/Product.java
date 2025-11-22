package model;

import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

/**
 * Product model used across DAO / controllers / JSP.
 * Fields names kept compatible with existing DB mapping:
 *  ProductID, CategoryID, ProductName, Price, Description, Material, Dimensions, Features,
 *  ImageURL, Brand, Stock, CreatedAt
 *
 * Added convenience helpers: getFormattedPrice(), getPrimaryImage(), stock helpers.
 */
public class Product {
    private int productID;
    private int categoryID;
    private String productName;
    private double price;
    private String description;
    private String material;
    private String dimensions; // Kích thước
    private String features;
    private String imageURL; // Ảnh đại diện (relative URL hoặc path)
    private List<String> imageUrls; // Danh sách các ảnh chi tiết
    private String brand;
    private int stock;
    private Date createdAt;

    public Product() {
        this.imageUrls = new ArrayList<>(); // luôn khởi tạo để tránh NPE
    }

    /* ----------------- Getters / Setters ----------------- */
    public int getProductID() { return productID; }
    public void setProductID(int productID) { this.productID = productID; }

    public int getCategoryID() { return categoryID; }
    public void setCategoryID(int categoryID) { this.categoryID = categoryID; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName == null ? "" : productName.trim(); }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description == null ? "" : description.trim(); }

    public String getMaterial() { return material; }
    public void setMaterial(String material) { this.material = material == null ? "" : material.trim(); }

    public String getDimensions() { return dimensions; }
    public void setDimensions(String dimensions) { this.dimensions = dimensions == null ? "" : dimensions.trim(); }

    public String getFeatures() { return features; }
    public void setFeatures(String features) { this.features = features == null ? "" : features.trim(); }

    public String getImageURL() { return imageURL; }
    public void setImageURL(String imageURL) { this.imageURL = imageURL == null ? "" : imageURL.trim(); }

    public List<String> getImageUrls() { return imageUrls; }
    public void setImageUrls(List<String> imageUrls) {
        this.imageUrls = imageUrls == null ? new ArrayList<>() : imageUrls;
    }

    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand == null ? "" : brand.trim(); }

    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = Math.max(0, stock); }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt == null ? null : new Date(createdAt.getTime()); }

    /* ----------------- Convenience helpers ----------------- */

    /**
     * Trả về chuỗi giá đã format theo locale VN.
     * Sử dụng ở JSP: ${product.formattedPrice}
     */
    public String getFormattedPrice() {
        try {
            return NumberFormat.getCurrencyInstance(new Locale("vi", "VN")).format(this.price);
        } catch (Exception ex) {
            return String.format("%.0f VND", this.price);
        }
    }

    /**
     * Trả về đường dẫn ảnh chính nếu có, ngược lại lấy ảnh đầu tiên trong imageUrls,
     * nếu không có gì thì trả null — view nên dùng fallback image khi null.
     */
    public String getPrimaryImage() {
        if (this.imageURL != null && !this.imageURL.trim().isEmpty()) return this.imageURL;
        if (this.imageUrls != null && !this.imageUrls.isEmpty() && this.imageUrls.get(0) != null && !this.imageUrls.get(0).isEmpty())
            return this.imageUrls.get(0);
        return null;
    }

    /**
     * Kiểm tra còn hàng.
     */
    public boolean isInStock() {
        return this.stock > 0;
    }

    /**
     * Kiểm tra có đủ số lượng yêu cầu hay không.
     */
    public boolean hasStock(int qty) {
        return qty > 0 && this.stock >= qty;
    }

    /**
     * Giảm tồn kho (thread-safe).
     * @param qty số lượng cần giảm (dương)
     * @return true nếu thành công (đủ hàng và đã giảm), false nếu không đủ
     */
    public synchronized boolean decreaseStock(int qty) {
        if (qty <= 0) return false;
        if (this.stock >= qty) {
            this.stock -= qty;
            return true;
        }
        return false;
    }

    /**
     * Tăng tồn kho (thread-safe).
     */
    public synchronized void increaseStock(int qty) {
        if (qty <= 0) return;
        this.stock += qty;
    }

    /* ----------------- equals/hashCode/toString ----------------- */

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Product)) return false;
        Product p = (Product) o;
        return productID == p.productID;
    }

    @Override
    public int hashCode() {
        return Objects.hash(productID);
    }

    @Override
    public String toString() {
        return "Product{" +
                "productID=" + productID +
                ", productName='" + productName + '\'' +
                ", brand='" + brand + '\'' +
                ", price=" + price +
                ", stock=" + stock +
                '}';
    }
}
