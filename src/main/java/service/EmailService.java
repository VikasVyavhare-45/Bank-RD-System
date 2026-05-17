package service;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

public class EmailService {

    // ✅ Environment variables वापरतो — key directly नाही
    // Railway Dashboard मध्ये हे variables set करायचे
    private static final String SMTP_HOST  = "smtp-relay.brevo.com";
    private static final String SMTP_PORT  = "587";
    private static final String SMTP_LOGIN = System.getenv("BREVO_LOGIN") != null
                                              ? System.getenv("BREVO_LOGIN")
                                              : "ab981e001@smtp-brevo.com";
    private static final String SMTP_KEY   = System.getenv("BREVO_KEY") != null
                                              ? System.getenv("BREVO_KEY")
                                              : "";
    private static final String FROM_EMAIL = System.getenv("FROM_EMAIL") != null
                                              ? System.getenv("FROM_EMAIL")
                                              : "apexsavingbank@gmail.com";
    private static final String FROM_NAME  = "Apex Saving Bank";

    public static void sendEmail(String toEmail, String subject, String htmlBody) {

        if (SMTP_KEY == null || SMTP_KEY.isEmpty()) {
            System.err.println("❌ BREVO_KEY environment variable not set!");
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host",              SMTP_HOST);
        props.put("mail.smtp.port",              SMTP_PORT);
        props.put("mail.smtp.auth",              "true");
        props.put("mail.smtp.starttls.enable",   "true");
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.ssl.protocols",     "TLSv1.2");
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout",           "10000");
        props.put("mail.smtp.writetimeout",      "10000");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_LOGIN, SMTP_KEY);
            }
        });

        try {
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(FROM_EMAIL, FROM_NAME));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject(subject);
            msg.setContent(htmlBody, "text/html; charset=utf-8");
            Transport.send(msg);
            System.out.println("✅ Email sent to: " + toEmail);
        } catch (Exception e) {
            System.err.println("❌ Email failed: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static void sendOTPEmail(String toEmail, String name, String otp) {
        String subject = "🔐 Apex Saving Bank – Login OTP: " + otp;
        String body =
            "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;background:#f4f4f4;padding:20px;'>" +
            "<div style='max-width:480px;margin:auto;background:#fff;border-radius:14px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.1);'>" +
            "<div style='background:linear-gradient(135deg,#1E40AF,#3B82F6);padding:28px;text-align:center;'>" +
            "<h2 style='color:#fff;margin:0;'>🏦 Apex Saving Bank</h2>" +
            "<p style='color:rgba(255,255,255,0.75);margin:4px 0 0;font-size:13px;'>Secure Login OTP</p>" +
            "</div>" +
            "<div style='padding:32px;text-align:center;'>" +
            "<p style='font-size:15px;color:#333;'>Hello <strong>" + name + "</strong>,</p>" +
            "<p style='color:#666;font-size:14px;margin:8px 0 24px;'>Your one-time password for login:</p>" +
            "<div style='background:#EFF6FF;border:2px dashed #3B82F6;border-radius:12px;padding:20px;display:inline-block;min-width:220px;'>" +
            "<div style='font-size:38px;font-weight:800;letter-spacing:12px;color:#1E40AF;'>" + otp + "</div>" +
            "<div style='font-size:12px;color:#9CA3AF;margin-top:8px;'>Valid for <strong>5 minutes</strong></div>" +
            "</div>" +
            "<div style='background:#FEF2F2;border-radius:8px;padding:12px;font-size:12px;color:#DC2626;margin:20px 0;'>" +
            "⚠️ Never share this OTP with anyone." +
            "</div>" +
            "</div>" +
            "<div style='background:#F9FAFB;padding:14px;text-align:center;border-top:1px solid #E5E7EB;'>" +
            "<p style='color:#9CA3AF;font-size:12px;margin:0;'>© 2026 Apex Saving Bank Ltd.</p>" +
            "</div></div></body></html>";
        sendEmail(toEmail, subject, body);
    }

    public static void sendDueReminder(String toEmail, String userName,
                                        String accNo, double amount, int dueDay) {
        String subject = "⏰ Apex Saving Bank – RD Payment Due: " + accNo;
        String body =
            "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;background:#f4f4f4;padding:20px;'>" +
            "<div style='max-width:500px;margin:auto;background:#fff;border-radius:12px;overflow:hidden;'>" +
            "<div style='background:linear-gradient(135deg,#1E40AF,#3B82F6);padding:24px;text-align:center;'>" +
            "<h2 style='color:#fff;margin:0;'>🏦 Apex Saving Bank</h2>" +
            "</div><div style='padding:28px;'>" +
            "<p>Dear <strong>" + userName + "</strong>,</p>" +
            "<p>Your RD payment is due on <strong style='color:#3B82F6;'>Day " + dueDay + "</strong>.</p>" +
            "<div style='background:#EFF6FF;border-left:4px solid #3B82F6;border-radius:8px;padding:16px;margin:20px 0;'>" +
            "<table style='width:100%;font-size:14px;'>" +
            "<tr><td style='color:#888;'>Account No</td><td style='font-weight:700;text-align:right;'>" + accNo + "</td></tr>" +
            "<tr><td style='color:#888;'>Monthly Amount</td><td style='font-weight:700;color:#3B82F6;text-align:right;'>&#8377;" + String.format("%.0f", amount) + "</td></tr>" +
            "</table></div></div>" +
            "<div style='background:#F9FAFB;padding:14px;text-align:center;border-top:1px solid #E5E7EB;'>" +
            "<p style='color:#9CA3AF;font-size:12px;margin:0;'>© 2026 Apex Saving Bank Ltd.</p>" +
            "</div></div></body></html>";
        sendEmail(toEmail, subject, body);
    }

    public static void sendAdminSummary(String adminEmail, int dueCount, String detailsHtml) {
        String subject = "📊 Apex Saving Bank – Today's RD Due Summary";
        String body =
            "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;background:#f4f4f4;padding:20px;'>" +
            "<div style='max-width:600px;margin:auto;background:#fff;border-radius:12px;overflow:hidden;'>" +
            "<div style='background:linear-gradient(135deg,#1E40AF,#3B82F6);padding:24px;text-align:center;'>" +
            "<h2 style='color:#fff;margin:0;'>🏦 Apex Saving Bank Admin</h2>" +
            "</div><div style='padding:28px;'>" +
            "<p>Today <strong style='color:#3B82F6;'>" + dueCount + "</strong> RD account(s) have payment due.</p>" +
            "<table style='width:100%;border-collapse:collapse;font-size:13px;margin-top:16px;'>" +
            "<thead><tr style='background:#F9FAFB;'>" +
            "<th style='padding:10px;text-align:left;color:#9CA3AF;'>User</th>" +
            "<th style='padding:10px;text-align:left;color:#9CA3AF;'>Account No</th>" +
            "<th style='padding:10px;text-align:right;color:#9CA3AF;'>Amount</th>" +
            "</tr></thead><tbody>" + detailsHtml + "</tbody></table>" +
            "</div><div style='background:#F9FAFB;padding:14px;text-align:center;border-top:1px solid #E5E7EB;'>" +
            "<p style='color:#9CA3AF;font-size:12px;margin:0;'>© 2026 Apex Saving Bank Ltd.</p>" +
            "</div></div></body></html>";
        sendEmail(adminEmail, subject, body);
    }
}