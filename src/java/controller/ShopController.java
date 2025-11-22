package controller;

import dal.CategoryDAO;
import dal.ProductDAO;
import model.Product;
import model.Category;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.*;

@WebServlet(name="ShopController", urlPatterns={"/shop"})
public class ShopController extends HttpServlet {
    private static final int ITEMS_PER_PAGE = 12;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // ---- Params (ĐÃ BỔ SUNG brandName)
            String keyword = trim(req.getParameter("keyword"));
            String cidParam = trim(req.getParameter("cid"));     // "all" | number
            String brandName = trim(req.getParameter("brandName")); // <-- THAY ĐỔI MỚI
            String sort     = Optional.ofNullable(req.getParameter("sort")).orElse("newest");
            int page        = parseInt(req.getParameter("page"), 1);
            double min      = parseDouble(req.getParameter("min"), 0);
            double max      = parseDouble(req.getParameter("max"), 0);

            // Normalize brandName: treat "all" or empty as null (no filter)
            if (brandName != null) {
                brandName = brandName.trim();
                if (brandName.isEmpty() || "all".equalsIgnoreCase(brandName)) brandName = null;
            }

            // ---- Category parse
            int selectedCidInt = -1;                // -1 = all
            if (cidParam != null && !"all".equalsIgnoreCase(cidParam)) {
                selectedCidInt = parseInt(cidParam, -1);
            }
            List<Integer> categoryIds = null;
            if (selectedCidInt > 0) {
                categoryIds = Collections.singletonList(selectedCidInt);
            }

            // ---- DAO
            ProductDAO pdao = new ProductDAO();
            CategoryDAO cdao = new CategoryDAO();

            // ---- Truy vấn (ĐÃ BỔ SUNG brandName)
            int totalCount = pdao.countProducts(keyword, categoryIds, min, max, brandName); // <-- THAY ĐỔI MỚI
            int totalPages = totalCount == 0 ? 1 : Math.max(1, (int)Math.ceil(totalCount / (double)ITEMS_PER_PAGE));
            page = Math.min(Math.max(1, page), totalPages);
            int offset = (page - 1) * ITEMS_PER_PAGE;

            List<Product> products = pdao.searchAndFilterProducts(
                    keyword, categoryIds, min, max, sort, offset, ITEMS_PER_PAGE, brandName); // <-- THAY ĐỔI MỚI

            // ---- Lấy dữ liệu cho bộ lọc (ĐÃ BỔ SUNG getDistinctBrands)
            List<Category> categories = cdao.getAllCategories();
            List<String> brands = pdao.getDistinctBrands();
            if (brands == null) brands = Collections.emptyList();

            // ---- Attributes cho JSP (ĐÃ BỔ SUNG brands & selectedBrand)
            req.setAttribute("products", products);
            req.setAttribute("categories", categories);
            req.setAttribute("brands", brands); // <-- THAY ĐỔI MỚI

            req.setAttribute("keywordValue", keyword);
            req.setAttribute("selectedCid", cidParam == null ? "all" : cidParam);
            req.setAttribute("selectedCidInt", selectedCidInt);
            req.setAttribute("selectedBrand", brandName == null ? "all" : brandName); // giữ "all" cho view
            req.setAttribute("minValue", min);
            req.setAttribute("maxValue", max);
            req.setAttribute("sortByValue", sort);

            req.setAttribute("totalCount", totalCount);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("currentPage", page);
            req.setAttribute("pageSize", ITEMS_PER_PAGE);

            req.getRequestDispatcher("/shop.jsp").forward(req, resp);
        } catch (Exception ex) {
            // log + fallback
            ex.printStackTrace();
            req.setAttribute("error", "Không tải được danh sách sản phẩm.");
            req.getRequestDispatcher("/error.jsp").forward(req, resp);
        }
    }

    // helpers
    private String trim(String s){ return (s==null)?null:s.trim(); }
    private int parseInt(String s, int def){ try{ return Integer.parseInt(s); }catch(Exception e){ return def; } }
    private double parseDouble(String s, double def){ try{ return Double.parseDouble(s); }catch(Exception e){ return def; } }
}
