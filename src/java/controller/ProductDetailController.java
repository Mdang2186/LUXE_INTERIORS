package controller;

import dal.ProductDAO;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet(name="ProductDetailController", urlPatterns={"/product-detail"})
public class ProductDetailController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pidRaw = req.getParameter("pid");
        int pid = -1;
        try { pid = Integer.parseInt(pidRaw); } catch (Exception ignored) {}

        ProductDAO dao = new ProductDAO();
        Product product = (pid > 0) ? dao.getProductByID(pid) : null;

        if (product == null) {
            req.setAttribute("error", "Sản phẩm không tồn tại hoặc đã bị gỡ.");
            resp.sendRedirect(req.getContextPath() + "/shop");
            return;
        }

        // Gallery: dùng list từ DAO, fallback ảnh chính
        List<String> gallery = new ArrayList<>();
        if (product.getImageUrls() != null && !product.getImageUrls().isEmpty()) {
            gallery.addAll(product.getImageUrls());
        } else if (product.getImageURL() != null && !product.getImageURL().isEmpty()) {
            gallery.add(product.getImageURL());
        }

        // Liên quan (cùng danh mục, loại trừ chính nó)
        List<Product> related = Collections.emptyList();
        try {
            related = dao.findRelated(product.getCategoryID(), product.getProductID(), 8);
        } catch (Exception ignored) {}

        req.setAttribute("product", product);
        req.setAttribute("gallery", gallery);
        req.setAttribute("related", related);

        req.getRequestDispatcher("/product-detail.jsp").forward(req, resp);
    }
}
