package service;

import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

public class EmailService {

    private static final String SMTP_HOST = "smtp-relay.brevo.com";
    private static final String SMTP_PORT = "465";

    public static void sendEmail(String toEmail, String subject, String htmlBody) {

        // ── Runtime मध्ये variables read करतो (static नाही) ──
        String smtpLogin = System.getenv("BREVO_LOGIN");
        String smtpKey   = System.getenv("BREVO_KEY");
        String fromEmail = System.getenv("FROM_EMAIL");

        // ── Debug logs — Railway Deploy Logs मध्ये दिसतील ──
        System.out.println("=== EMAIL DEBUG ===");
        System.out.println("BREVO_LOGIN : " + (smtpLogin != null ? smtpLogin : "❌ NOT SET"));
        System.out.println("BREVO_KEY   : " + (smtpKey   != null ? "✅ SET (hidden)" : "❌ NOT SET"));
        System.out.println("FROM_EMAIL  : " + (fromEmail != null ? fromEmail : "❌ NOT SET"));
        System.out.println("TO_EMAIL    : " + toEmail);
        System.out.println("===================");

        // ── Validation ──
        if (smtpLogin == null || smtpLogin.isEmpty()) {
            System.err.println("❌ BREVO_LOGIN not set in Railway Variables!");
            return;
        }
        if (smtpKey == null || smtpKey.isEmpty()) {
            System.err.println("❌ BREVO_KEY not set in Railway Variables!");
            return;
        }
        if (fromEmail == null || fromEmail.isEmpty()) {
            System.err.println("❌ FROM_EMAIL not set in Railway Variables!");
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host",              SMTP_HOST);
        props.put("mail.smtp.port",              SMTP_PORT);
        props.put("mail.smtp.auth",              "true");
        props.put("mail.smtp.ssl.enable", "true");
        props.put("mail.smtp.ssl.protocols",     "TLSv1.2");
        props.put("mail.smtp.connectiontimeout", "15000");
        props.put("mail.smtp.timeout",           "15000");
        props.put("mail.smtp.writetimeout",      "15000");

        final String login = smtpLogin;
        final String key   = smtpKey;

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(login, key);
            }
        });

        // Debug mode ON — errors clearly दिसतील
        session.setDebug(false);

        try {
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(fromEmail, "Apex Saving Bank"));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject(subject);
            msg.setContent(htmlBody, "text/html; charset=utf-8");
            Transport.send(msg);
            System.out.println("✅ Email successfully sent to: " + toEmail);
        } catch (AuthenticationFailedException e) {
            System.err.println("❌ SMTP Authentication Failed! Check BREVO_LOGIN and BREVO_KEY");
            System.err.println("   Details: " + e.getMessage());
        } catch (MessagingException e) {
            System.err.println("❌ Email sending failed: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static void sendOTPEmail(String toEmail, String name, String otp) {
        String subject = "Your Apex Saving Bank Login OTP: " + otp;
        String body =
            "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;background:#f4f4f4;padding:20px;'>" +
            "<div style='max-width:480px;margin:auto;background:#fff;border-radius:14px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.1);'>" +
            "<div style='background:linear-gradient(135deg,#F07600,#ff9a3c);padding:28px;text-align:center;'>" +
            "<h2 style='color:#fff;margin:0;font-size:22px;'>Apex Saving Bank</h2>" +
            "<p style='color:rgba(255,255,255,0.85);margin:4px 0 0;font-size:13px;'>Secure Login OTP</p>" +
            "</div>" +
            "<div style='padding:32px;text-align:center;'>" +
            "<p style='font-size:15px;color:#333;'>Hello <strong>" + name + "</strong>,</p>" +
            "<p style='color:#666;font-size:14px;margin:8px 0 24px;'>Your one-time password for login:</p>" +
            "<div style='background:#FFF3E6;border:2px dashed #F07600;border-radius:12px;padding:20px;display:inline-block;min-width:220px;'>" +
            "<div style='font-size:38px;font-weight:800;letter-spacing:12px;color:#F07600;'>" + otp + "</div>" +
            "<div style='font-size:12px;color:#9CA3AF;margin-top:8px;'>Valid for <strong>5 minutes</strong></div>" +
            "</div>" +
            "<div style='background:#FEF2F2;border-radius:8px;padding:12px;font-size:12px;color:#DC2626;margin:20px 0;'>" +
            "Never share this OTP with anyone." +
            "</div>" +
            "</div>" +
            "<div style='background:#F9FAFB;padding:14px;text-align:center;border-top:1px solid #E5E7EB;'>" +
            "<p style='color:#9CA3AF;font-size:12px;margin:0;'>2026 Apex Saving Bank Ltd. | RBI License No. ASB-2024-001</p>" +
            "</div></div></body></html>";
        sendEmail(toEmail, subject, body);
    }

    public static void sendDueReminder(String toEmail, String userName,
                                        String accNo, double amount, int dueDay) {
        String subject = "Apex Saving Bank - RD Payment Due: " + accNo;
        String body =
            "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;background:#f4f4f4;padding:20px;'>" +
            "<div style='max-width:500px;margin:auto;background:#fff;border-radius:12px;overflow:hidden;'>" +
            "<div style='background:linear-gradient(135deg,#F07600,#ff9a3c);padding:24px;text-align:center;'>" +
            "<h2 style='color:#fff;margin:0;'>Apex Saving Bank</h2>" +
            "</div><div style='padding:28px;'>" +
            "<p>Dear <strong>" + userName + "</strong>,</p>" +
            "<p>Your RD payment is due on <strong style='color:#F07600;'>Day " + dueDay + "</strong> of this month.</p>" +
            "<div style='background:#FFF3E6;border-left:4px solid #F07600;border-radius:8px;padding:16px;margin:20px 0;'>" +
            "<table style='width:100%;font-size:14px;'>" +
            "<tr><td style='color:#888;'>Account No</td><td style='font-weight:700;text-align:right;'>" + accNo + "</td></tr>" +
            "<tr><td style='color:#888;'>Monthly Amount</td><td style='font-weight:700;color:#F07600;text-align:right;'>&#8377;" + String.format("%.0f", amount) + "</td></tr>" +
            "</table></div>" +
            "<p style='color:#666;font-size:13px;'>Please log in to Apex Saving Bank and pay your installment on time to avoid a late penalty of <strong style='color:#DC2626;'>&#8377;10 per day</strong>.</p>" +
            "</div>" +
            "<div style='background:#F9FAFB;padding:14px;text-align:center;border-top:1px solid #E5E7EB;'>" +
            "<p style='color:#9CA3AF;font-size:12px;margin:0;'>2026 Apex Saving Bank Ltd.</p>" +
            "</div></div></body></html>";
        sendEmail(toEmail, subject, body);
    }

    public static void sendAdminSummary(String adminEmail, int dueCount, String detailsHtml) {
        String subject = "Apex Saving Bank - Today's RD Due Summary";
        String body =
            "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;background:#f4f4f4;padding:20px;'>" +
            "<div style='max-width:600px;margin:auto;background:#fff;border-radius:12px;overflow:hidden;'>" +
            "<div style='background:linear-gradient(135deg,#F07600,#ff9a3c);padding:24px;text-align:center;'>" +
            "<h2 style='color:#fff;margin:0;'>Apex Saving Bank Admin</h2>" +
            "</div><div style='padding:28px;'>" +
            "<p>Today <strong style='color:#F07600;'>" + dueCount + "</strong> RD account(s) have payment due.</p>" +
            "<table style='width:100%;border-collapse:collapse;font-size:13px;margin-top:16px;'>" +
            "<thead><tr style='background:#F9FAFB;'>" +
            "<th style='padding:10px;text-align:left;color:#9CA3AF;'>User</th>" +
            "<th style='padding:10px;text-align:left;color:#9CA3AF;'>Account No</th>" +
            "<th style='padding:10px;text-align:right;color:#9CA3AF;'>Amount</th>" +
            "</tr></thead><tbody>" + detailsHtml + "</tbody></table>" +
            "</div><div style='background:#F9FAFB;padding:14px;text-align:center;border-top:1px solid #E5E7EB;'>" +
            "<p style='color:#9CA3AF;font-size:12px;margin:0;'>2026 Apex Saving Bank Ltd.</p>" +
            "</div></div></body></html>";
        sendEmail(adminEmail, subject, body);
    }
}
