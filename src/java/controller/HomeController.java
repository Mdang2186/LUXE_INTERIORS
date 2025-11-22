package controller;

import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import model.Product;

@WebServlet(name = "HomeController", urlPatterns = {"/home", ""})
public class HomeController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        
        try {
            ProductDAO pdao = new ProductDAO(); //
            
            // === LẤY DỮ LIỆU CHO TRANG "LUXE" ===

            // 1. Lấy 8 sản phẩm MỚI NHẤT (cho ${products} - "Bộ sưu tập đặc biệt")
            //
            List<Product> newestProducts = pdao.getNewArrivals(8); 
            
            // 2. Lấy 4 sản phẩm BÁN CHẠY (cho ${bestSellersEx} - "Bán chạy")
            // Trang home.jsp mới dùng 'bestSellersEx' và 'it.sold'
            // Chúng ta sẽ dùng 30 ngày làm mốc
            //
            List<ProductDAO.ProductSold> bestSellingProducts = pdao.getBestSellersWithSold(4, 30); 
            
            // 3. Lấy 1 sản phẩm ĐẶC BIỆT (cho ${specialProduct})
            // Lấy tạm sản phẩm có ID = 1 (hoặc một ID nào đó bạn chắc chắn có)
            Product specialProduct = pdao.getProductByID(1); //

            // 4. Gửi tất cả dữ liệu sang JSP
            // Gửi "products" cho phần "Bộ sưu tập đặc biệt"
            request.setAttribute("products", newestProducts); 
            
            // Gửi "bestSellersEx" cho phần "Bán chạy"
            request.setAttribute("bestSellersEx", bestSellingProducts); 
            
            // Gửi "specialProduct" cho "Sản phẩm nghệ thuật"
            request.setAttribute("specialProduct", specialProduct); 
            
            request.getRequestDispatcher("home.jsp").forward(request, response); //
            
        } catch (Exception e) {
            System.out.println("HomeController doGet Error: " + e.getMessage()); //
            e.printStackTrace(); //
            response.sendRedirect("error.jsp"); //
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response); //
    }
}