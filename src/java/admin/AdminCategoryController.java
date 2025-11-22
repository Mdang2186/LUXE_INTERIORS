package admin;

import dal.CategoryDAO;
import model.Category;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name="AdminCategoryController", urlPatterns={"/admin/categories"})
public class AdminCategoryController extends HttpServlet {
  @Override protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    req.setAttribute("adminActive","categories");
    String action = req.getParameter("action");
    CategoryDAO cdao = new CategoryDAO();

    if ("create".equals(action) || "edit".equals(action)) {
      Category c = null;
      if ("edit".equals(action)) {
        try { c = cdao.getById(Integer.parseInt(req.getParameter("id"))); } catch(Exception ignored){}
      }
      req.setAttribute("category", c);
      req.getRequestDispatcher("/WEB-INF/admin/category-form.jsp").forward(req, resp);
      return;
    }

    req.setAttribute("categories", cdao.getAllCategories());
    req.getRequestDispatcher("/WEB-INF/admin/categories-list.jsp").forward(req, resp);
  }

  @Override protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    String action = req.getParameter("action");
    CategoryDAO cdao = new CategoryDAO();

    if ("delete".equals(action)) {
      int id = Integer.parseInt(req.getParameter("id"));
      boolean ok = cdao.delete(id);
      req.getSession().setAttribute(ok?"success":"error", ok? "Đã xóa danh mục.":"Không thể xóa.");
      resp.sendRedirect(req.getContextPath()+"/admin/categories"); return;
    }

    if ("save".equals(action)) {
      req.setCharacterEncoding("UTF-8");
      try{
        Integer id = null;
        try{ id = Integer.parseInt(req.getParameter("categoryID")); }catch(Exception ignored){}
        String name = req.getParameter("categoryName");
        // String des = req.getParameter("description"); // <-- SỬA LỖI: Đã Xóa

        Category c = new Category();
        if (id!=null) c.setCategoryID(id);
        c.setCategoryName(name); 
        // c.setDescription(des); // <-- SỬA LỖI: Đã Xóa

        boolean ok = (id==null) ? cdao.insert(c) : cdao.update(c);
        req.getSession().setAttribute(ok?"success":"error", ok? "Đã lưu danh mục.":"Lưu thất bại.");
      }catch(Exception e){
        req.getSession().setAttribute("error","Dữ liệu không hợp lệ.");
      }
      resp.sendRedirect(req.getContextPath()+"/admin/categories"); return;
    }
  }
}