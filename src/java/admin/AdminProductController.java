package admin;

import dal.CategoryDAO;
import dal.ProductDAO;
import model.Product;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet(name="AdminProductController", urlPatterns={"/admin/products"})
public class AdminProductController extends HttpServlet {
  @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    req.setAttribute("adminActive","products");
    String action = req.getParameter("action");
    ProductDAO pdao = new ProductDAO();
    CategoryDAO cdao = new CategoryDAO();

    if ("create".equals(action) || "edit".equals(action)) {
      Product p = null;
      if ("edit".equals(action)) {
        try { p = pdao.getProductByID(Integer.parseInt(req.getParameter("id"))); } catch(Exception ignored){}
      }
      req.setAttribute("product", p);
      req.setAttribute("categories", cdao.getAllCategories());
      req.getRequestDispatcher("/WEB-INF/admin/product-form.jsp").forward(req, resp);
      return;
    }

    int page = parseInt(req.getParameter("page"), 1);
    int size = 10;
    String keyword = opt(req.getParameter("q"));
    Integer cid = parseIntObj(req.getParameter("cid"));
    String brandName = opt(req.getParameter("brandName")); // <-- THAY ĐỔI MỚI

    // THAY ĐỔI: Thêm brandName (null) vào các hàm gọi DAO
    int total = pdao.countProducts(keyword, (cid==null?null:List.of(cid)), 0, 0, brandName);
    List<Product> data = pdao.searchAndFilterProducts(keyword, (cid==null?null:List.of(cid)), 0, 0, "newest", (page-1)*size, size, brandName);

    req.setAttribute("products", data);
    req.setAttribute("categories", cdao.getAllCategories());
    req.setAttribute("brands", pdao.getDistinctBrands()); // <-- THAY ĐỔI MỚI
    req.setAttribute("q", keyword); 
    req.setAttribute("cid", cid);
    req.setAttribute("brandName", brandName); // <-- THAY ĐỔI MỚI
    
    req.setAttribute("totalPages", (int)Math.ceil(total/(double)size));
    req.setAttribute("currentPage", page);
    req.getRequestDispatcher("/WEB-INF/admin/products-list.jsp").forward(req, resp);
  }

  @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    String action = req.getParameter("action");
    ProductDAO pdao = new ProductDAO();

    if ("delete".equals(action)) {
      int id = Integer.parseInt(req.getParameter("id"));
      req.getSession().setAttribute("success", pdao.deleteProduct(id) ? "Đã xóa sản phẩm." : "Xóa thất bại.");
      resp.sendRedirect(req.getContextPath()+"/admin/products"); return;
    }

    if ("save".equals(action)) {
      req.setCharacterEncoding("UTF-8");
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
        String imageURL = req.getParameter("imageURL");
        // THAY ĐỔI MỚI: Lấy thêm Features (nếu có)
        String features = req.getParameter("features"); 

        Product p = new Product();
        p.setProductID(id==null?0:id);
        p.setCategoryID(categoryID);
        p.setProductName(name); p.setPrice(price); p.setDescription(desc);
        p.setMaterial(material); p.setDimensions(dimensions);
        p.setBrand(brand); p.setStock(stock); p.setImageURL(imageURL);
        p.setFeatures(features); // <-- THAY ĐỔI MỚI

        boolean ok = (id==null) ? pdao.insertProduct(p) : pdao.updateProduct(p);
        req.getSession().setAttribute(ok? "success":"error", ok? "Đã lưu sản phẩm.":"Lưu thất bại.");
      } catch (Exception e) {
        req.getSession().setAttribute("error","Dữ liệu không hợp lệ.");
      }
      resp.sendRedirect(req.getContextPath()+"/admin/products"); return;
    }
  }

  private static String opt(String s){ return (s==null||s.isBlank())?null:s.trim(); }
  private static Integer parseIntObj(String s){ try { return (s==null||s.isBlank())?null:Integer.parseInt(s); } catch(Exception e){ return null; } }
  private static int parseInt(String s, int d){ try { return Integer.parseInt(s);} catch(Exception e){ return d; } }
}