package Utils;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.Multipart;
import jakarta.mail.internet.MimeBodyPart;
import jakarta.mail.internet.MimeMultipart;
import jakarta.activation.DataHandler;
import jakarta.mail.util.ByteArrayDataSource;

import java.nio.charset.StandardCharsets;
import java.util.Properties;

import model.Order;

/**
 * EmailService — gửi email SMTP (Gmail App Password / SendGrid / Mailgun...)
 * - Gửi được HTML template thương hiệu LUXE INTERIORS
 * - Có sẵn OTP, welcome, contact, subscription, và xác nhận đơn hàng kèm QR
 * - ĐÃ BỔ SUNG: gửi email kèm file đính kèm (PDF, Excel...)
 *
 * LƯU Ý:
 *  - Với Gmail: BẮT BUỘC dùng App Password (bật 2FA).
 *  - Không commit App Password thật lên GitHub.
 */
public class EmailService {

    /* ==== Cấu hình nhanh (có thể override bằng biến môi trường) ==== */
    private static final String SMTP_USER_DEF      = "jejangwangminh@gmail.com";   // TODO: đổi email của bạn
    private static final String SMTP_PASS_APP_DEF  = "ppdo vxpv waik cdsk";        // TODO: App Password (KHÔNG commit thật)
    private static final String SMTP_HOST_DEF      = "smtp.gmail.com";
    private static final int    SMTP_PORT_DEF      = 587; // STARTTLS
    private static final String FROM_NAME_DEF      = "LUXE INTERIORS";
    /* =============================================================== */

    private final String host     = or(System.getenv("SMTP_HOST"),      SMTP_HOST_DEF);
    private final int    port     = parseInt(or(System.getenv("SMTP_PORT"), String.valueOf(SMTP_PORT_DEF)), SMTP_PORT_DEF);
    private final String user     = or(System.getenv("SMTP_USER"),      SMTP_USER_DEF);
    private final String pass     = or(System.getenv("SMTP_PASS"),      SMTP_PASS_APP_DEF);
    private final String fromName = or(System.getenv("SMTP_FROM_NAME"), FROM_NAME_DEF);

    // =========================================================================
    // Tạo Session dùng chung
    // =========================================================================
    private Session createSession() {
        Properties p = new Properties();
        p.put("mail.smtp.auth", "true");
        p.put("mail.smtp.starttls.enable", "true");
        p.put("mail.smtp.host", host);
        p.put("mail.smtp.port", String.valueOf(port));

        return Session.getInstance(p, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(user, pass);
            }
        });
    }

    // =========================================================================
    // Gửi email thô: subject + HTML body
    // =========================================================================
    public boolean send(String to, String subject, String htmlBody) {
        if (isBlank(user) || isBlank(pass)) {
            System.err.println("[EmailService] Chưa cấu hình SMTP_USER/SMTP_PASS (App Password).");
            return false;
        }
        try {
            Session session = createSession();

            MimeMessage m = new MimeMessage(session);
            m.setFrom(new InternetAddress(user, fromName, StandardCharsets.UTF_8.name()));
            m.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to, false));
            m.setSubject(subject, StandardCharsets.UTF_8.name());
            m.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(m);
            return true;
        } catch (Exception e) {
            System.err.println("[EmailService] Send error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Gửi email dạng text đơn giản nhưng vẫn bọc trong template thương hiệu.
     * Dùng cho thông báo hệ thống (đổi mật khẩu, cảnh báo...).
     */
    public boolean sendPlainText(String to, String subject, String body) {
        String safe = escape(body).replace("\n", "<br/>");
        String inner = "<p style=\"margin:0 0 12px 0;\">" + safe + "</p>";

        String preheader = safe.length() > 80 ? safe.substring(0, 80) + "..." : safe;
        String html = wrapBrandMail(subject, preheader, inner);
        return send(to, subject, html);
    }

    // =========================================================================
    // GỬI EMAIL KÈM FILE ĐÍNH KÈM (MỚI THÊM)
    // =========================================================================

    /**
     * Gửi email HTML kèm 1 file đính kèm (ví dụ: invoice.pdf hoặc report.xlsx).
     *
     * @param to       Email người nhận
     * @param subject  Tiêu đề mail
     * @param htmlBody Nội dung HTML (đã bọc template hoặc sẽ bọc bên ngoài)
     * @param fileName Tên file hiển thị (vd: "invoice-123.pdf")
     * @param data     Mảng byte nội dung file
     * @param mimeType Kiểu MIME (vd: "application/pdf", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
     */
    public boolean sendWithAttachment(String to,
                                      String subject,
                                      String htmlBody,
                                      String fileName,
                                      byte[] data,
                                      String mimeType) {
        if (isBlank(user) || isBlank(pass)) {
            System.err.println("[EmailService] Chưa cấu hình SMTP_USER/SMTP_PASS.");
            return false;
        }

        try {
            Session session = createSession();

            MimeMessage msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(user, fromName, StandardCharsets.UTF_8.name()));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to, false));
            msg.setSubject(subject, StandardCharsets.UTF_8.name());

            // Phần 1: body HTML
            MimeBodyPart bodyPart = new MimeBodyPart();
            bodyPart.setContent(htmlBody, "text/html; charset=UTF-8");

            // Phần 2: file đính kèm
            MimeBodyPart attachPart = new MimeBodyPart();
            attachPart.setDataHandler(new DataHandler(
                    new ByteArrayDataSource(data, mimeType)
            ));
            attachPart.setFileName(fileName);

            Multipart multipart = new MimeMultipart();
            multipart.addBodyPart(bodyPart);
            multipart.addBodyPart(attachPart);

            msg.setContent(multipart);
            Transport.send(msg);
            return true;
        } catch (Exception e) {
            System.err.println("[EmailService] sendWithAttachment error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Gửi email HTML kèm 2 file đính kèm (ví dụ: Excel + PDF).
     *
     * Dùng cho case:
     *  - Báo cáo doanh thu tháng: gửi kèm report.xlsx + report.pdf
     */
    public boolean sendWithTwoAttachments(String to,
                                          String subject,
                                          String htmlBody,
                                          String fileName1,
                                          byte[] data1,
                                          String mimeType1,
                                          String fileName2,
                                          byte[] data2,
                                          String mimeType2) {
        if (isBlank(user) || isBlank(pass)) {
            System.err.println("[EmailService] Chưa cấu hình SMTP_USER/SMTP_PASS.");
            return false;
        }

        try {
            Session session = createSession();

            MimeMessage msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(user, fromName, StandardCharsets.UTF_8.name()));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to, false));
            msg.setSubject(subject, StandardCharsets.UTF_8.name());

            // Body HTML
            MimeBodyPart bodyPart = new MimeBodyPart();
            bodyPart.setContent(htmlBody, "text/html; charset=UTF-8");

            // Attachment 1
            MimeBodyPart attach1 = new MimeBodyPart();
            attach1.setDataHandler(new DataHandler(
                    new ByteArrayDataSource(data1, mimeType1)
            ));
            attach1.setFileName(fileName1);

            // Attachment 2
            MimeBodyPart attach2 = new MimeBodyPart();
            attach2.setDataHandler(new DataHandler(
                    new ByteArrayDataSource(data2, mimeType2)
            ));
            attach2.setFileName(fileName2);

            Multipart multipart = new MimeMultipart();
            multipart.addBodyPart(bodyPart);
            multipart.addBodyPart(attach1);
            multipart.addBodyPart(attach2);

            msg.setContent(multipart);
            Transport.send(msg);
            return true;
        } catch (Exception e) {
            System.err.println("[EmailService] sendWithTwoAttachments error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Ví dụ helper: Gửi hóa đơn PDF cho 1 đơn hàng (nếu bạn muốn dùng nhanh,
     * còn không thì dùng controller gọi trực tiếp sendWithAttachment cũng được).
     */
    public boolean sendInvoicePdf(String toEmail,
                                  String fullName,
                                  Order order,
                                  byte[] pdfBytes) {

        String subject = "Hóa đơn đơn hàng "
                + (order != null && order.getOrderID() > 0 ? ("#" + order.getOrderID()) : "")
                + " - LUXE INTERIORS";

        String preheader = "Hóa đơn mua hàng tại LUXE INTERIORS.";
        String inner = ""
                + "<p style=\"margin:0 0 12px 0\">Xin chào <b>" + escape(fullName) + "</b>,</p>"
                + "<p style=\"margin:0 0 16px 0\">"
                + "Đính kèm là hóa đơn PDF cho đơn hàng của bạn tại <b>LUXE INTERIORS</b>."
                + "</p>"
                + "<p style=\"margin:0 0 0 0;color:#6b7280;font-size:13px\">"
                + "Nếu có bất kỳ thắc mắc, vui lòng phản hồi email này hoặc liên hệ đội ngũ hỗ trợ."
                + "</p>";

        String html = wrapBrandMail(subject, preheader, inner);
        return sendWithAttachment(
                toEmail,
                subject,
                html,
                "invoice-" + (order != null ? order.getOrderID() : "order") + ".pdf",
                pdfBytes,
                "application/pdf"
        );
    }

    // =========================================================================
    // Template thương hiệu dùng lại
    // =========================================================================
    private String wrapBrandMail(String subject, String preheader, String innerHtml) {
        StringBuilder sb = new StringBuilder();

        sb.append("<!doctype html><html lang=\"vi\"><head>")
          .append("<meta charset=\"UTF-8\">")
          .append("<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">")
          // preheader
          .append("<span style=\"display:none!important;opacity:0;visibility:hidden;height:0;width:0;\">")
          .append(escape(preheader)).append("</span>")
          .append("</head><body style=\"margin:0;background:#faf7f2;font-family:Inter,Segoe UI,Roboto,Arial,sans-serif;\">")
          .append("<table role=\"presentation\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" style=\"background:#faf7f2;padding:24px 0;\">")
          .append("<tr><td align=\"center\">")
          .append("<table role=\"presentation\" width=\"640\" cellspacing=\"0\" cellpadding=\"0\" ")
          .append("style=\"max-width:640px;width:100%;background:#ffffff;border-radius:16px;box-shadow:0 10px 30px rgba(0,0,0,.06);overflow:hidden;\">")
          // Header
          .append("<tr><td style=\"padding:24px 28px;background:linear-gradient(135deg,#ffeb99,#c79a2d);\">")
          .append("<div style=\"display:flex;align-items:center;gap:12px;color:#2b1e08;\">")
          .append("<div style=\"width:36px;height:36px;border-radius:10px;background:#fff;display:grid;place-items:center;font-size:18px;\">🛋️</div>")
          .append("<div style=\"font-weight:800;font-size:18px;letter-spacing:.3px\">LUXE INTERIORS</div>")
          .append("</div></td></tr>")
          // Title
          .append("<tr><td style=\"padding:26px 28px 0 28px;\">")
          .append("<div style=\"font-weight:700;font-size:20px;color:#1f2937;margin-bottom:6px;\">")
          .append(escape(subject)).append("</div>")
          .append("<div style=\"color:#6b7280;font-size:13px\">Email thông báo từ hệ thống</div>")
          .append("</td></tr>")
          // Body
          .append("<tr><td style=\"padding:12px 28px 6px 28px;\">")
          .append(innerHtml)
          .append("</td></tr>")
          // Footer
          .append("<tr><td style=\"padding:18px 28px 26px 28px;color:#6b7280;font-size:12px;border-top:1px solid #f1eadf;\">")
          .append("Đây là email tự động, vui lòng không trả lời. ")
          .append("Truy cập <a href=\"http://localhost:8080/Nhom2_FurniShop/home\" style=\"color:#a47f1a;text-decoration:none;\">LUXE INTERIORS</a> để biết thêm chi tiết.")
          .append("</td></tr>")
          .append("</table></td></tr></table></body></html>");

        return sb.toString();
    }

    // =========================================================================
    // OTP
    // =========================================================================
    public boolean sendOtp(String to, String otp) {
        String subject   = "Mã xác thực OTP";
        String preheader = "Mã OTP của bạn là " + otp + " (hiệu lực 10 phút).";

        StringBuilder inner = new StringBuilder();
        inner.append("<p style=\"margin:0 0 12px 0\">Xin chào,</p>")
             .append("<p style=\"margin:0 0 16px 0\">Để hoàn tất đăng ký/khôi phục tài khoản, vui lòng dùng mã OTP bên dưới:</p>")
             .append("<div style=\"text-align:center;margin:18px 0 8px 0;\">")
             .append("<span style=\"display:inline-block;font-family:Courier New,monospace;font-weight:700;")
             .append("letter-spacing:6px;font-size:28px;color:#2b1e08;background:#fff7e6;border:1px solid #f1d48a;border-radius:10px;")
             .append("padding:14px 18px;\">")
             .append(escape(otp)).append("</span></div>")
             .append("<ul style=\"margin:16px 0 0 16px;color:#374151;padding-left:18px;\">")
             .append("<li>Mã có hiệu lực <b>10 phút</b>.</li>")
             .append("<li>Không chia sẻ mã cho bất cứ ai.</li>")
             .append("<li>Nếu không phải bạn yêu cầu, hãy bỏ qua email này.</li>")
             .append("</ul>")
             .append("<p style=\"margin:16px 0 0 0;color:#6b7280;font-size:13px\">Trân trọng,<br/>Đội ngũ LUXE INTERIORS</p>");

        String html = wrapBrandMail(subject, preheader, inner.toString());
        return send(to, subject, html);
    }

    // =========================================================================
    // Welcome
    // =========================================================================
    public boolean sendWelcome(String to, String fullName) {
        String subject   = "Chào mừng đến LUXE INTERIORS";
        String preheader = "Tài khoản của " + escape(fullName) + " đã được tạo thành công.";

        String inner = ""
            + "<p style=\"margin:0 0 12px 0\">Xin chào <b>" + escape(fullName) + "</b>,</p>"
            + "<p style=\"margin:0 0 16px 0\">Bạn đã đăng ký thành công tài khoản tại "
            + "<b>LUXE INTERIORS</b>. Bắt đầu khám phá các bộ sưu tập nội thất sang trọng ngay hôm nay!</p>"
            + "<div style=\"text-align:center;margin:18px 0;\">"
            + "  <a href=\"http://localhost:8080/Nhom2_FurniShop/home\" "
            + "     style=\"display:inline-block;padding:12px 20px;border-radius:999px;"
            + "            background:linear-gradient(135deg,#ffde59,#b7860b);"
            + "            color:#2b1e08;font-weight:700;text-decoration:none;\">"
            + "     Khám phá sản phẩm"
            + "  </a>"
            + "</div>"
            + "<p style=\"margin:16px 0 0 0;color:#6b7280;font-size:13px\">"
            + "Chúc bạn mua sắm vui vẻ!<br/>Đội ngũ LUXE INTERIORS"
            + "</p>";

        String html = wrapBrandMail(subject, preheader, inner);
        return send(to, subject, html);
    }

    // =========================================================================
    // Contact: gửi cho Admin
    // =========================================================================
    public boolean sendContactNotification(String adminEmail, String name,
                                           String email, String phone,
                                           String subject, String message) {

        String mailSubject = "Liên hệ MỚI từ: " + escape(name);
        String preheader   = "Chủ đề: " + escape(subject);

        String inner = ""
            + "<p style=\"margin:0 0 16px 0\">Bạn vừa nhận được một yêu cầu liên hệ mới qua website:</p>"
            + "<table role=\"presentation\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" style=\"font-size:14px;color:#374151;border-collapse:collapse;\">"
            + "<tr><td style=\"padding:8px;background:#f9fafb;border:1px solid #e5e7eb;width:100px;\"><b>Họ tên</b></td>"
            + "<td style=\"padding:8px;border:1px solid #e5e7eb;\">" + escape(name) + "</td></tr>"

            + "<tr><td style=\"padding:8px;background:#f9fafb;border:1px solid #e5e7eb;\"><b>Email</b></td>"
            + "<td style=\"padding:8px;border:1px solid #e5e7eb;\">" + escape(email) + "</td></tr>"

            + "<tr><td style=\"padding:8px;background:#f9fafb;border:1px solid #e5e7eb;\"><b>Điện thoại</b></td>"
            + "<td style=\"padding:8px;border:1px solid #e5e7eb;\">" + escape(phone) + "</td></tr>"

            + "<tr><td style=\"padding:8px;background:#f9fafb;border:1px solid #e5e7eb;\"><b>Chủ đề</b></td>"
            + "<td style=\"padding:8px;border:1px solid #e5e7eb;\">" + escape(subject) + "</td></tr>"

            + "<tr><td style=\"padding:8px;background:#f9fafb;border:1px solid #e5e7eb;vertical-align:top;\"><b>Nội dung</b></td>"
            + "<td style=\"padding:8px;border:1px solid #e5e7eb;line-height:1.6;\">" + escape(message).replace("\n", "<br/>") + "</td></tr>"
            + "</table>"
            + "<p style=\"margin:16px 0 0 0;color:#6b7280;font-size:13px\">"
            + "Vui lòng phản hồi sớm.<br/>Đội ngũ LUXE INTERIORS"
            + "</p>";

        String html = wrapBrandMail(mailSubject, preheader, inner);
        return send(adminEmail, mailSubject, html);
    }

    // =========================================================================
    // Contact: xác nhận cho người dùng
    // =========================================================================
    public boolean sendContactConfirmation(String toEmail, String name) {
        String subject   = "Đã nhận yêu cầu liên hệ của bạn";
        String preheader = "Cảm ơn " + escape(name) + ", chúng tôi sẽ phản hồi sớm nhất!";

        String inner = ""
            + "<p style=\"margin:0 0 12px 0\">Xin chào <b>" + escape(name) + "</b>,</p>"
            + "<p style=\"margin:0 0 16px 0\">"
            + "Chúng tôi đã nhận được yêu cầu tư vấn của bạn. Đội ngũ LUXE INTERIORS sẽ xem xét và phản hồi qua email hoặc SĐT của bạn trong thời gian sớm nhất."
            + "</p>"
            + "<div style=\"text-align:center;margin:18px 0;\">"
            + "  <a href=\"http://localhost:8080/Nhom2_FurniShop/shop\" "
            + "     style=\"display:inline-block;padding:12px 20px;border-radius:999px;"
            + "            background:linear-gradient(135deg,#ffde59,#b7860b);"
            + "            color:#2b1e08;font-weight:700;text-decoration:none;\">"
            + "     Tiếp tục mua sắm"
            + "  </a>"
            + "</div>"
            + "<p style=\"margin:16px 0 0 0;color:#6b7280;font-size:13px\">"
            + "Cảm ơn bạn đã tin tưởng LUXE INTERIORS!"
            + "</p>";

        String html = wrapBrandMail(subject, preheader, inner);
        return send(toEmail, subject, html);
    }

    // =========================================================================
    // Subscription: thông báo admin
    // =========================================================================
    public boolean sendSubscriptionNotification(String adminEmail, String newSubscriberEmail) {
        String mailSubject = "Đăng ký nhận tin MỚI";
        String preheader   = "Email: " + escape(newSubscriberEmail);

        String inner = ""
            + "<p style=\"margin:0 0 16px 0\">Bạn vừa nhận được một lượt đăng ký nhận tin mới qua website:</p>"
            + "<table role=\"presentation\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" style=\"font-size:14px;color:#374151;border-collapse:collapse;\">"
            + "<tr><td style=\"padding:8px;background:#f9fafb;border:1px solid #e5e7eb;width:100px;\"><b>Email</b></td>"
            + "<td style=\"padding:8px;border:1px solid #e5e7eb;\"><b>" + escape(newSubscriberEmail) + "</b></td></tr>"
            + "</table>"
            + "<p style=\"margin:16px 0 0 0;color:#6b7280;font-size:13px\">"
            + "Đã tự động lưu vào CSDL (bảng subscribers).<br/>Đội ngũ LUXE INTERIORS"
            + "</p>";

        String html = wrapBrandMail(mailSubject, preheader, inner);
        return send(adminEmail, mailSubject, html);
    }

    // =========================================================================
    // Subscription: xác nhận cho người dùng
    // =========================================================================
    public boolean sendSubscriptionConfirmation(String toEmail) {
        String subject   = "Xác nhận đăng ký nhận ưu đãi";
        String preheader = "Cảm ơn bạn đã đăng ký nhận tin từ LUXE INTERIORS!";

        String inner = ""
            + "<p style=\"margin:0 0 12px 0\">Xin chào,</p>"
            + "<p style=\"margin:0 0 16px 0\">"
            + "Cảm ơn bạn đã đăng ký nhận thông tin ưu đãi, bộ sưu tập mới và các cảm hứng décor từ <b>LUXE INTERIORS</b>."
            + "</p>"
            + "<p style=\"margin:0 0 16px 0\">"
            + "Chúng tôi sẽ gửi email cho bạn sớm nhất khi có chương trình khuyến mãi hấp dẫn!"
            + "</p>"
            + "<div style=\"text-align:center;margin:18px 0;\">"
            + "  <a href=\"http://localhost:8080/Nhom2_FurniShop/shop\" "
            + "     style=\"display:inline-block;padding:12px 20px;border-radius:999px;"
            + "            background:linear-gradient(135deg,#ffde59,#b7860b);"
            + "            color:#2b1e08;font-weight:700;text-decoration:none;\">"
            + "     Khám phá sản phẩm"
            + "  </a>"
            + "</div>"
            + "<p style=\"margin:16px 0 0 0;color:#6b7280;font-size:13px\">"
            + "Trân trọng,<br/>Đội ngũ LUXE INTERIORS"
            + "</p>";

        String html = wrapBrandMail(subject, preheader, inner);
        return send(toEmail, subject, html);
    }

    // =========================================================================
    // Xác nhận đơn hàng + QR
    // =========================================================================
    /**
     * Gửi email xác nhận đơn hàng kèm mã QR.
     * qrContent: chuỗi dữ liệu để đưa vào QR (thường là URL tra cứu đơn hàng).
     */
    public boolean sendOrderConfirmationWithQr(
            String toEmail,
            String fullName,
            Order order,
            double depositAmount,
            double remainingAmount,
            String paymentMethod,
            String qrContent
    ) {
        String subject = "Xác nhận đơn hàng"
                + (order.getOrderID() > 0 ? (" #" + order.getOrderID()) : "")
                + " - LUXE INTERIORS";

        // Tạo URL ảnh QR dùng service public (không cần thêm thư viện)
        String qrImgUrl;
        try {
            String encoded = java.net.URLEncoder.encode(
                    qrContent,
                    java.nio.charset.StandardCharsets.UTF_8.toString()
            );
            qrImgUrl = "https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=" + encoded;
        } catch (Exception e) {
            // fallback, vẫn cố gắng gửi
            qrImgUrl = "https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=" + escape(qrContent);
        }

        String preheader = "Đơn hàng của " + escape(fullName) + " đã được tạo thành công.";

        long total   = Math.round(order.getTotalAmount());
        long deposit = Math.round(depositAmount);
        long remain  = Math.round(remainingAmount);

        StringBuilder inner = new StringBuilder();
        inner.append("<p style=\"margin:0 0 12px 0\">Xin chào <b>")
             .append(escape(fullName))
             .append("</b>,</p>")
             .append("<p style=\"margin:0 0 16px 0\">")
             .append("Đơn hàng của bạn tại <b>LUXE INTERIORS</b> đã được ghi nhận. ")
             .append("Chúng tôi sẽ liên hệ để xác nhận lịch giao & lắp đặt.")
             .append("</p>");

        // Bảng tóm tắt đơn
        inner.append("<table role=\"presentation\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" ")
             .append("style=\"font-size:14px;color:#374151;border-collapse:collapse;margin:0 0 12px 0;\">")

             .append("<tr>")
             .append("<td style=\"padding:6px 0;width:120px;color:#6b7280;\">Mã đơn</td>")
             .append("<td style=\"padding:6px 0;\">")
             .append(order.getOrderID() > 0 ? ("#" + order.getOrderID()) : "(đang xử lý)")
             .append("</td>")
             .append("</tr>")

             .append("<tr>")
             .append("<td style=\"padding:6px 0;color:#6b7280;\">Tổng tiền</td>")
             .append("<td style=\"padding:6px 0;\"><b>")
             .append(total).append(" VND")
             .append("</b></td>")
             .append("</tr>")

             .append("<tr>")
             .append("<td style=\"padding:6px 0;color:#6b7280;\">Phương thức</td>")
             .append("<td style=\"padding:6px 0;\">")
             .append(escape(paymentMethod))
             .append("</td>")
             .append("</tr>");

        if (deposit > 0) {
            inner.append("<tr>")
                 .append("<td style=\"padding:6px 0;color:#6b7280;\">Đặt cọc</td>")
                 .append("<td style=\"padding:6px 0;\">")
                 .append(deposit).append(" VND")
                 .append("</td>")
                 .append("</tr>")
                 .append("<tr>")
                 .append("<td style=\"padding:6px 0;color:#6b7280;\">Còn lại</td>")
                 .append("<td style=\"padding:6px 0;\">")
                 .append(remain).append(" VND")
                 .append("</td>")
                 .append("</tr>");
        }

        inner.append("</table>");

        // QR
        inner.append("<p style=\"margin:12px 0 6px 0;color:#374151;font-size:14px;\">")
             .append("Bạn có thể quét mã QR dưới đây để xem/tracking đơn hàng trên website:")
             .append("</p>")
             .append("<p style=\"text-align:center;margin:10px 0 4px 0;\">")
             .append("<img src=\"").append(qrImgUrl)
             .append("\" alt=\"QR đơn hàng\" ")
             .append("style=\"max-width:220px;border-radius:16px;border:1px solid #e5e7eb;\"/>")
             .append("</p>")
             .append("<p style=\"margin:0;color:#6b7280;font-size:12px;\">")
             .append("Nếu không quét được, bạn có thể vào mục <b>Đơn hàng của tôi</b> sau khi đăng nhập.")
             .append("</p>");

        String html = wrapBrandMail(subject, preheader, inner.toString());
        return send(toEmail, subject, html);
    }

    // =========================================================================
    // Helpers
    // =========================================================================
    private static String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }

    private static String or(String a, String b) {
        return isBlank(a) ? b : a;
    }

    private static boolean isBlank(String s) {
        return (s == null) || s.trim().isEmpty();
    }

    private static int parseInt(String s, int def) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return def;
        }
    }
}
