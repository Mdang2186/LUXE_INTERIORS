package controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "PolicyController", urlPatterns = {"/policy/*"})
public class PolicyController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getPathInfo(); // /shipping, /return, /payment, /privacy, /terms
        if (path == null) path = "/shipping";

        switch (path) {
            case "/shipping":
                req.getRequestDispatcher("/policy-shipping.jsp").forward(req, resp);
                break;
            case "/return":
                req.getRequestDispatcher("/policy-return.jsp").forward(req, resp);
                break;
            case "/payment":
                req.getRequestDispatcher("/policy-payment.jsp").forward(req, resp);
                break;
            case "/privacy":
                req.getRequestDispatcher("/policy-privacy.jsp").forward(req, resp);
                break;
            case "/terms":
                req.getRequestDispatcher("/policy-terms.jsp").forward(req, resp);
                break;
            default:
                // 404 nhẹ nhàng
                req.setAttribute("error", "Trang không tồn tại.");
                req.getRequestDispatcher("/policy-terms.jsp").forward(req, resp);
        }
    }
}
