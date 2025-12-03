package admin;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet(name = "AdminUserExportCsvController",
        urlPatterns = {"/admin/users/export-csv"})
public class AdminUserExportCsvController extends HttpServlet {

    private UserDAO udao;

    @Override
    public void init() throws ServletException {
        super.init();
        udao = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<User> users = udao.getAllUsersForExport();

        String filename = "users_export.csv";
        String headerValue = "attachment; filename=\"" +
                URLEncoder.encode(filename, StandardCharsets.UTF_8) + "\"";

        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", headerValue);

        // ghi BOM để Excel mở đúng tiếng Việt
        resp.getOutputStream().write(new byte[]{(byte)0xEF, (byte)0xBB, (byte)0xBF});

        try (PrintWriter out = resp.getWriter()) {
            // header
            out.println("UserID,FullName,Email,Phone,Address,Role,CreatedAt");

            for (User u : users) {
                String line = String.format("\"%d\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"",
                        u.getUserID(),
                        safe(u.getFullName()),
                        safe(u.getEmail()),
                        safe(u.getPhone()),
                        safe(u.getAddress()),
                        safe(u.getRole()),
                        u.getCreatedAt() != null ? u.getCreatedAt().toString() : ""
                );
                out.println(line);
            }
            out.flush();
        }
    }

    private String safe(String s) {
        return s == null ? "" : s.replace("\"", "\"\"");
    }
}
