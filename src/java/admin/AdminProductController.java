package admin;

import dal.CategoryDAO;
import dal.ProductDAO;
import model.Product;
import Utils.PdfExportUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.OutputStream;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@WebServlet(name = "AdminProductController", urlPatterns = {"/admin/products"})
public class AdminProductController extends HttpServlet {

    private static final int DEFAULT_PAGE_SIZE = 12;
    private static final int MAX_EXPORT_ROWS   = 10_000;

    // ========================== GET ==========================

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setAttribute("adminActive", "products");

        String action = opt(req.getParameter("action"));
        if (action == null) action = "list";

        switch (action) {
            case "create":
            case "edit":
                showForm(req, resp, action);
                break;

            // CSV / Excel / PDF
            case "export-products-csv":
                exportProductsCsv(req, resp);
                break;
            case "export-products-excel":
            case "export-products":            // cho chắc, nếu chỗ nào còn dùng action cũ
                exportProductsExcel(req, resp);
                break;
            case "export-products-pdf":
                exportProductsPdf(req, resp);
                break;

            default:
                handleList(req, resp);
                break;
        }
    }

    // ====================== LIST + FILTER ====================

    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        ProductDAO pdao = new ProductDAO();
        CategoryDAO cdao = new CategoryDAO();

        int page = parseInt(req.getParameter("page"), 1);
        if (page < 1) page = 1;
        int size = DEFAULT_PAGE_SIZE;

        String keyword   = opt(req.getParameter("q"));
        Integer cid      = parseIntObj(req.getParameter("cid"));
        String brandName = opt(req.getParameter("brandName"));

        String minPriceStr = opt(req.getParameter("minPrice"));
        String maxPriceStr = opt(req.getParameter("maxPrice"));
        Double minPrice = parseDoubleObj(minPriceStr);
        Double maxPrice = parseDoubleObj(maxPriceStr);

        String sort = normalizeSort(req.getParameter("sort"));

        double min = (minPrice != null) ? minPrice : 0;
        double max = (maxPrice != null) ? maxPrice : 0;

        List<Integer> categoryIds = null;
        if (cid != null) {
            categoryIds = new ArrayList<>();
            categoryIds.add(cid);
        }

        int totalFiltered = pdao.countProducts(keyword, categoryIds, min, max, brandName);
        int totalPages = (int) Math.ceil(totalFiltered / (double) size);
        if (totalPages == 0) totalPages = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * size;

        List<Product> products = pdao.searchAndFilterProducts(
                keyword,
                categoryIds,
                min,
                max,
                sort,
                offset,
                size,
                brandName
        );

        int totalAllProducts = pdao.countProducts(null, null, 0, 0, null);
        List<String> allBrands = pdao.getDistinctBrands();
        int brandCount = (allBrands != null) ? allBrands.size() : 0;

        req.setAttribute("products", products);
        req.setAttribute("categories", cdao.getAllCategories());
        req.setAttribute("brands", allBrands);

        req.setAttribute("q", keyword);
        req.setAttribute("cid", cid);
        req.setAttribute("brandName", brandName);
        req.setAttribute("minPrice", minPriceStr);
        req.setAttribute("maxPrice", maxPriceStr);
        req.setAttribute("sort", sort);

        req.setAttribute("totalPages", totalPages);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", size);
        req.setAttribute("totalFiltered", totalFiltered);
        req.setAttribute("totalAllProducts", totalAllProducts);
        req.setAttribute("brandCount", brandCount);

        req.getRequestDispatcher("/WEB-INF/admin/products-list.jsp").forward(req, resp);
    }

    // ====================== CREATE / EDIT FORM ===============

    private void showForm(HttpServletRequest req, HttpServletResponse resp, String action)
            throws ServletException, IOException {

        ProductDAO pdao = new ProductDAO();
        CategoryDAO cdao = new CategoryDAO();

        Product p = null;
        String img1 = "";
        String img2 = "";
        String img3 = "";

        if ("edit".equalsIgnoreCase(action)) {
            Integer id = parseIntObj(req.getParameter("id"));
            if (id != null) {
                p = pdao.getProductByID(id); // DAO cần set imageUrls
            }
        }

        if (p != null) {
            List<String> imgs = p.getImageUrls();
            if (imgs != null && !imgs.isEmpty()) {
                if (imgs.size() > 0 && imgs.get(0) != null) img1 = imgs.get(0);
                if (imgs.size() > 1 && imgs.get(1) != null) img2 = imgs.get(1);
                if (imgs.size() > 2 && imgs.get(2) != null) img3 = imgs.get(2);
            } else if (p.getImageURL() != null && !p.getImageURL().isBlank()) {
                img1 = p.getImageURL();
            }
        }

        req.setAttribute("product", p);
        req.setAttribute("img1", img1);
        req.setAttribute("img2", img2);
        req.setAttribute("img3", img3);
        req.setAttribute("categories", cdao.getAllCategories());
        req.setAttribute("brands", pdao.getDistinctBrands());

        req.getRequestDispatcher("/WEB-INF/admin/product-form.jsp").forward(req, resp);
    }

    // ====================== EXPORT CSV =======================

    private void exportProductsCsv(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();
        List<Product> list = getFilteredProductsForExport(req);

        if (list == null || list.isEmpty()) {
            session.setAttribute("error", "Không có sản phẩm nào phù hợp để xuất CSV.");
            resp.sendRedirect(req.getContextPath() + "/admin/products");
            return;
        }

        String filename = "products-" +
                new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date()) +
                ".csv";

        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        DecimalFormat dfPrice = new DecimalFormat("#,##0");

        try (PrintWriter out = resp.getWriter()) {
            // BOM để Excel hiểu UTF-8, không lỗi tiếng Việt
            out.write('\uFEFF');

            // header
            out.println("\"ID\";\"Tên sản phẩm\";\"Danh mục\";\"Thương hiệu\";\"Giá\";\"Tồn kho\";\"Chất liệu\";\"Kích thước\";\"Ảnh 1\";\"Ảnh 2\";\"Ảnh 3\"");

            for (Product p : list) {
                String priceStr = dfPrice.format(p.getPrice());

                String img1 = "";
                String img2 = "";
                String img3 = "";
                List<String> imgs = p.getImageUrls();
                if (imgs != null && !imgs.isEmpty()) {
                    if (imgs.size() > 0 && imgs.get(0) != null) img1 = imgs.get(0);
                    if (imgs.size() > 1 && imgs.get(1) != null) img2 = imgs.get(1);
                    if (imgs.size() > 2 && imgs.get(2) != null) img3 = imgs.get(2);
                } else if (p.getImageURL() != null) {
                    img1 = p.getImageURL();
                }

                out.print("\"" + p.getProductID()       + "\";");
                out.print("\"" + nz(p.getProductName())  + "\";");
                out.print("\"" + p.getCategoryID()       + "\";");
                out.print("\"" + nz(p.getBrand())        + "\";");
                out.print("\"" + priceStr                + "\";");
                out.print("\"" + p.getStock()            + "\";");
                out.print("\"" + nz(p.getMaterial())     + "\";");
                out.print("\"" + nz(p.getDimensions())   + "\";");
                out.print("\"" + nz(img1)                + "\";");
                out.print("\"" + nz(img2)                + "\";");
                out.print("\"" + nz(img3)                + "\"");
                out.println();
            }
        }
    }

    // ====================== EXPORT EXCEL (HTML) ==============

    /**
     * Xuất "Excel" mà không dùng POI:
     *  - Gửi file .xls
     *  - Nội dung là bảng HTML UTF-8, Excel mở được, hiển thị tiếng Việt chuẩn.
     */
    private void exportProductsExcel(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();
        List<Product> list = getFilteredProductsForExport(req);

        if (list == null || list.isEmpty()) {
            session.setAttribute("error", "Không có sản phẩm nào phù hợp để xuất Excel.");
            resp.sendRedirect(req.getContextPath() + "/admin/products");
            return;
        }

        String filename = "products-" +
                new SimpleDateFormat("yyyyMMdd-HHmmss").format(new Date()) +
                ".xls";

        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/vnd.ms-excel; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        DecimalFormat dfPrice = new DecimalFormat("#,##0");

        try (PrintWriter out = resp.getWriter()) {
            out.println("<html><head><meta charset='UTF-8' />");
            out.println("<style>");
            out.println("table{border-collapse:collapse;font-family:Arial;}");
            out.println("th,td{border:1px solid #cccccc;padding:4px 8px;font-size:12px;}");
            out.println("th{background:#f1f5f9;font-weight:bold;}");
            out.println("</style></head><body>");
            out.println("<h3>Báo cáo danh sách sản phẩm FurniShop</h3>");
            out.println("<table>");
            out.println("<tr>" +
                    "<th>ID</th>" +
                    "<th>Tên sản phẩm</th>" +
                    "<th>Danh mục</th>" +
                    "<th>Thương hiệu</th>" +
                    "<th>Giá (VND)</th>" +
                    "<th>Tồn kho</th>" +
                    "<th>Chất liệu</th>" +
                    "<th>Kích thước</th>" +
                    "<th>Ảnh 1</th>" +
                    "<th>Ảnh 2</th>" +
                    "<th>Ảnh 3</th>" +
                    "</tr>");

            for (Product p : list) {

                String img1 = "";
                String img2 = "";
                String img3 = "";
                List<String> imgs = p.getImageUrls();
                if (imgs != null && !imgs.isEmpty()) {
                    if (imgs.size() > 0 && imgs.get(0) != null) img1 = imgs.get(0);
                    if (imgs.size() > 1 && imgs.get(1) != null) img2 = imgs.get(1);
                    if (imgs.size() > 2 && imgs.get(2) != null) img3 = imgs.get(2);
                } else if (p.getImageURL() != null) {
                    img1 = p.getImageURL();
                }

                out.println("<tr>");
                out.println("<td>" + p.getProductID() + "</td>");
                out.println("<td>" + escapeHtml(nz(p.getProductName())) + "</td>");
                out.println("<td>" + p.getCategoryID() + "</td>");
                out.println("<td>" + escapeHtml(nz(p.getBrand())) + "</td>");
                out.println("<td>" + dfPrice.format(p.getPrice()) + "</td>");
                out.println("<td>" + p.getStock() + "</td>");
                out.println("<td>" + escapeHtml(nz(p.getMaterial())) + "</td>");
                out.println("<td>" + escapeHtml(nz(p.getDimensions())) + "</td>");
                out.println("<td>" + escapeHtml(nz(img1)) + "</td>");
                out.println("<td>" + escapeHtml(nz(img2)) + "</td>");
                out.println("<td>" + escapeHtml(nz(img3)) + "</td>");
                out.println("</tr>");
            }

            out.println("</table>");
            out.println("</body></html>");
        }
    }

    // ====================== EXPORT PDF =======================

    private void exportProductsPdf(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        HttpSession session = req.getSession();
        List<Product> list = getFilteredProductsForExport(req);

        if (list == null || list.isEmpty()) {
            session.setAttribute("error", "Không có sản phẩm nào phù hợp để xuất PDF.");
            resp.sendRedirect(req.getContextPath() + "/admin/products");
            return;
        }

        String filename = "products-" + System.currentTimeMillis() + ".pdf";
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try (OutputStream out = resp.getOutputStream()) {
            PdfExportUtil.exportProductsPdf(list, out);
        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("error", "Có lỗi khi xuất PDF sản phẩm: " + ex.getMessage());
        }
    }

    /**
     * Lấy list sản phẩm theo filter hiện tại để export (dùng chung cho CSV/Excel/PDF).
     */
    private List<Product> getFilteredProductsForExport(HttpServletRequest req) {

        ProductDAO pdao = new ProductDAO();

        String keyword   = opt(req.getParameter("q"));
        Integer cid      = parseIntObj(req.getParameter("cid"));
        String brandName = opt(req.getParameter("brandName"));

        String minPriceStr = opt(req.getParameter("minPrice"));
        String maxPriceStr = opt(req.getParameter("maxPrice"));
        Double minPrice = parseDoubleObj(minPriceStr);
        Double maxPrice = parseDoubleObj(maxPriceStr);

        String sort = normalizeSort(req.getParameter("sort"));

        double min = (minPrice != null) ? minPrice : 0;
        double max = (maxPrice != null) ? maxPrice : 0;

        List<Integer> categoryIds = null;
        if (cid != null) {
            categoryIds = new ArrayList<>();
            categoryIds.add(cid);
        }

        return pdao.searchAndFilterProducts(
                keyword,
                categoryIds,
                min,
                max,
                sort,
                0,
                MAX_EXPORT_ROWS,
                brandName
        );
    }

    // ========================== POST ==========================

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/products");
            return;
        }

        ProductDAO pdao = new ProductDAO();
        HttpSession session = req.getSession();

        switch (action) {
            case "delete" -> {
                Integer id = parseIntObj(req.getParameter("id"));
                if (id == null) {
                    session.setAttribute("error", "Mã sản phẩm không hợp lệ.");
                } else {
                    boolean ok = pdao.deleteProduct(id);
                    session.setAttribute(ok ? "success" : "error",
                            ok ? "Đã xóa sản phẩm." : "Xóa sản phẩm thất bại.");
                }
                resp.sendRedirect(req.getContextPath() + "/admin/products");
            }

            case "save" -> {
                try {
                    Integer id = parseIntObj(req.getParameter("productID"));
                    int categoryID = Integer.parseInt(req.getParameter("categoryID"));
                    String name = req.getParameter("productName");
                    double price = Double.parseDouble(req.getParameter("price"));
                    String desc = req.getParameter("description");
                    String material = req.getParameter("material");
                    String dimensions = req.getParameter("dimensions");
                    String brand = req.getParameter("brand");
                    int stock = Integer.parseInt(req.getParameter("stock"));
                    String features = req.getParameter("features");

                    String imageUrl1 = opt(req.getParameter("imageUrl1"));
                    String imageUrl2 = opt(req.getParameter("imageUrl2"));
                    String imageUrl3 = opt(req.getParameter("imageUrl3"));

                    Product p = new Product();
                    p.setProductID(id == null ? 0 : id);
                    p.setCategoryID(categoryID);
                    p.setProductName(name);
                    p.setPrice(price);
                    p.setDescription(desc);
                    p.setMaterial(material);
                    p.setDimensions(dimensions);
                    p.setBrand(brand);
                    p.setStock(stock);
                    p.setFeatures(features);

                    List<String> imgs = new ArrayList<>();
                    if (imageUrl1 != null) imgs.add(imageUrl1);
                    if (imageUrl2 != null) imgs.add(imageUrl2);
                    if (imageUrl3 != null) imgs.add(imageUrl3);
                    p.setImageUrls(imgs);

                    p.setImageURL(imageUrl1 != null ? imageUrl1 : "");

                    boolean ok;
                    if (id == null) {
                        ok = pdao.insertProductWithImages(p);
                    } else {
                        ok = pdao.updateProductWithImages(p);
                    }

                    session.setAttribute(ok ? "success" : "error",
                            ok ? "Đã lưu sản phẩm." : "Lưu sản phẩm thất bại.");
                } catch (Exception e) {
                    e.printStackTrace();
                    session.setAttribute("error", "Dữ liệu sản phẩm không hợp lệ.");
                }
                resp.sendRedirect(req.getContextPath() + "/admin/products");
            }

            default -> resp.sendRedirect(req.getContextPath() + "/admin/products");
        }
    }

    // ========================== TIỆN ÍCH ==========================

    private static String opt(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }

    private static Integer parseIntObj(String s) {
        try {
            return (s == null || s.isBlank()) ? null : Integer.parseInt(s.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private static int parseInt(String s, int d) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return d;
        }
    }

    private static Double parseDoubleObj(String s) {
        try {
            return (s == null || s.isBlank()) ? null : Double.parseDouble(s.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private static String normalizeSort(String s) {
        String v = opt(s);
        if (v == null) return "newest";
        v = v.toLowerCase();
        return switch (v) {
            case "priceasc", "pricedesc", "stockasc", "stockdesc", "newest" -> v;
            default -> "newest";
        };
    }

    private static String nz(String s) {
        return (s == null) ? "" : s;
    }

    // escape đơn giản cho HTML table Excel
    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
