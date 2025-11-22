package controller;

import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import model.CartItem;
import model.Product;

@WebServlet(name = "CartController", urlPatterns = {"/cart"})
public class CartController extends HttpServlet {

    private int i(String s, int def) {
        try { return Integer.parseInt(s); } catch (Exception e) { return def; }
    }

    @SuppressWarnings("unchecked")
    private List<CartItem> ensureCart(HttpSession session){
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);  // luôn nhét lại để lần view không bị null
        }
        return cart;
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(json);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        process(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        process(req, resp);
    }

    private void process(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(true);
        List<CartItem> cart = ensureCart(session);

        String action = request.getParameter("action");
        if (action == null) action = "view";

        String ctx = request.getContextPath();
        boolean ajax = "1".equals(request.getParameter("ajax"));

        try {
            switch (action) {
                case "add": {
                    int pid = i(request.getParameter("pid"), -1);
                    int qtyReq = i(request.getParameter("quantity"), 1);
                    int qtyToAdd = Math.max(qtyReq, 1);

                    if (pid <= 0) {
                        if (ajax) { writeJson(response, "{\"ok\":false,\"msg\":\"pid invalid\"}"); return; }
                        response.sendRedirect(ctx + "/shop");
                        return;
                    }

                    ProductDAO pdao = new ProductDAO();
                    Product p = pdao.getProductByID(pid);
                    if (p == null) {
                        if (ajax) { writeJson(response, "{\"ok\":false,\"msg\":\"product not found\"}"); return; }
                        session.setAttribute("message", "Sản phẩm không còn tồn tại.");
                        response.sendRedirect(ctx + "/shop");
                        return;
                    }

                    int available = p.getStock();
                    if (available <= 0) {
                        if (ajax) { writeJson(response, "{\"ok\":false,\"msg\":\"Sản phẩm đã hết hàng\"}"); return; }
                        session.setAttribute("message", "Sản phẩm đã hết hàng.");
                        response.sendRedirect(ctx + "/shop");
                        return;
                    }

                    // tìm trong giỏ
                    boolean found = false;
                    for (CartItem it : cart) {
                        if (it.getProduct().getProductID() == pid) {
                            found = true;
                            int newQty = it.getQuantity() + qtyToAdd;
                            if (newQty > available) {
                                newQty = available;
                                // feedback
                                if (ajax) {
                                    writeJson(response,
                                            "{\"ok\":true,\"cartSize\":" + session.getAttribute("cartSize")
                                                    + ",\"msg\":\"Số lượng đã được điều chỉnh xuống " + newQty + " do tồn kho.\"}");
                                    // update quantity and totals then return
                                    it.setQuantity(newQty);
                                    updateTotals(session, cart);
                                    return;
                                } else {
                                    session.setAttribute("message", "Số lượng đã được điều chỉnh xuống còn " + newQty + " do tồn kho.");
                                }
                            }
                            it.setQuantity(newQty);
                            updateTotals(session, cart);
                            if (ajax) { writeJson(response,
                                    "{\"ok\":true,\"cartSize\":"+ session.getAttribute("cartSize") +"}"); return; }
                            response.sendRedirect(ctx + "/cart");
                            return;
                        }
                    }

                    // chưa có -> thêm nhưng cap theo stock
                    int finalQty = Math.min(qtyToAdd, available);
                    if (finalQty <= 0) {
                        if (ajax) { writeJson(response, "{\"ok\":false,\"msg\":\"Sản phẩm đã hết hàng\"}"); return; }
                        session.setAttribute("message", "Sản phẩm đã hết hàng.");
                        response.sendRedirect(ctx + "/shop");
                        return;
                    }
                    cart.add(new CartItem(p, finalQty));
                    updateTotals(session, cart);

                    if (ajax) {
                        writeJson(response, "{\"ok\":true,\"cartSize\":"+ session.getAttribute("cartSize") +"}");
                        return;
                    }
                    // non-ajax: set friendly message if qty was reduced
                    if (finalQty < qtyToAdd) {
                        session.setAttribute("message", "Số lượng đã được điều chỉnh xuống còn " + finalQty + " do tồn kho.");
                    }
                    response.sendRedirect(ctx + "/cart");
                    return;
                }

                case "update": {
                    int pid = i(request.getParameter("pid"), -1);
                    int qtyReq = i(request.getParameter("quantity"), 1);
                    if (pid <= 0) {
                        if (ajax) { writeJson(response, "{\"ok\":false,\"msg\":\"pid invalid\"}"); return; }
                        response.sendRedirect(ctx + "/cart");
                        return;
                    }

                    ProductDAO pdao = new ProductDAO();
                    Product p = pdao.getProductByID(pid);
                    int available = (p == null) ? 0 : p.getStock();

                    if (qtyReq <= 0) {
                        cart.removeIf(it -> it.getProduct().getProductID() == pid);
                        updateTotals(session, cart);
                        if (ajax) {
                            writeJson(response,
                                    "{\"ok\":true,\"lineTotal\":0,\"cartSize\":" + session.getAttribute("cartSize") + "}");
                            return;
                        }
                        response.sendRedirect(ctx + "/cart");
                        return;
                    }

                    int setQty = qtyReq;
                    boolean adjusted = false;
                    if (available <= 0) {
                        // no stock -> remove item
                        cart.removeIf(it -> it.getProduct().getProductID() == pid);
                        setQty = 0;
                        adjusted = true;
                        session.setAttribute("message", "Sản phẩm đã hết hàng và đã bị gỡ khỏi giỏ.");
                    } else if (qtyReq > available) {
                        setQty = available;
                        adjusted = true;
                        session.setAttribute("message", "Số lượng đã được điều chỉnh xuống còn " + setQty + " do tồn kho.");
                    }

                    for (CartItem it : cart) {
                        if (it.getProduct().getProductID() == pid) {
                            if (setQty <= 0) {
                                // already removed above
                            } else {
                                it.setQuantity(setQty);
                            }
                            break;
                        }
                    }
                    updateTotals(session, cart);

                    if (ajax) {
                        double lineTotal = 0;
                        for (CartItem it : cart)
                            if (it.getProduct().getProductID() == pid) { lineTotal = it.getTotalPrice(); break; }
                        StringBuilder jo = new StringBuilder();
                        jo.append("{\"ok\":true,\"lineTotal\":").append(lineTotal)
                          .append(",\"cartSize\":").append(session.getAttribute("cartSize"));
                        if (adjusted) jo.append(",\"msg\":\"Số lượng đã được điều chỉnh do tồn kho.\"");
                        jo.append("}");
                        writeJson(response, jo.toString());
                        return;
                    }
                    response.sendRedirect(ctx + "/cart");
                    return;
                }

                case "remove": {
                    int pid = i(request.getParameter("pid"), -1);
                    cart.removeIf(it -> it.getProduct().getProductID() == pid);
                    updateTotals(session, cart);

                    if (ajax) {
                        writeJson(response, "{\"ok\":true,\"cartSize\":"+ session.getAttribute("cartSize") +"}");
                        return;
                    }
                    response.sendRedirect(ctx + "/cart");
                    return;
                }

                default: { // view
                    request.getRequestDispatcher("cart.jsp").forward(request, response);
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendRedirect(ctx + "/shop");
        }
    }

    private void updateTotals(HttpSession session, List<CartItem> cart) {
        double totalAmount = 0; int totalItems = 0;
        for (CartItem it : cart) { totalAmount += it.getTotalPrice(); totalItems += it.getQuantity(); }
        session.setAttribute("totalAmount", totalAmount);
        session.setAttribute("cartSize", totalItems);
        session.setAttribute("cart", cart);
    }
}
