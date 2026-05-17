package service;

import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;

/**
 * Brevo HTTP API वापरतो — SMTP port issues नाहीत
 * Railway वर SMTP ports block होतात पण HTTPS नाही
 */
public class EmailService {

    private static final String BREVO_API_URL = "https://api.brevo.com/v3/smtp/email";

    public static void sendEmail(String toEmail, String subject, String htmlBody) {

        String apiKey    = System.getenv("BREVO_API_KEY");
        String fromEmail = System.getenv("FROM_EMAIL");

        System.out.println("=== EMAIL DEBUG ===");
        System.out.println("BREVO_API_KEY : " + (apiKey    != null ? "SET" : "NOT SET"));
        System.out.println("FROM_EMAIL    : " + (fromEmail != null ? fromEmail : "NOT SET"));
        System.out.println("TO            : " + toEmail);

        if (apiKey == null || apiKey.isEmpty()) {
            System.err.println("BREVO_API_KEY not set!");
            return;
        }
        if (fromEmail == null || fromEmail.isEmpty()) {
            System.err.println("FROM_EMAIL not set!");
            return;
        }

        try {
            String safeSubject = subject.replace("\\", "\\\\").replace("\"", "\\\"");
            String safeBody = htmlBody
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "")
                .replace("\n", "\\n");

            String jsonBody = "{"
                + "\"sender\":{\"name\":\"Apex Saving Bank\",\"email\":\"" + fromEmail + "\"},"
                + "\"to\":[{\"email\":\"" + toEmail + "\"}],"
                + "\"subject\":\"" + safeSubject + "\","
                + "\"htmlContent\":\"" + safeBody + "\""
                + "}";

            URL url = new URL(BREVO_API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("accept",       "application/json");
            conn.setRequestProperty("content-type", "application/json");
            conn.setRequestProperty("api-key",      apiKey);
            conn.setConnectTimeout(15000);
            conn.setReadTimeout(15000);
            conn.setDoOutput(true);

            try (OutputStream os = conn.getOutputStream()) {
                os.write(jsonBody.getBytes(StandardCharsets.UTF_8));
            }

            int code = conn.getResponseCode();
            System.out.println("Brevo API Response: " + code);

            if (code == 201 || code == 200) {
                System.out.println("Email sent OK to: " + toEmail);
            } else {
                InputStream es = conn.getErrorStream();
                if (es != null) {
                    BufferedReader br = new BufferedReader(new InputStreamReader(es, StandardCharsets.UTF_8));
                    StringBuilder sb = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) sb.append(line);
                    System.err.println("Brevo API Error: " + sb.toString());
                }
            }
            conn.disconnect();

        } catch (Exception e) {
            System.err.println("Email exception: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static void sendOTPEmail(String toEmail, String name, String otp) {
        String subject = "Your Apex Saving Bank Login OTP: " + otp;
        String body = "<div style='font-family:Arial,sans-serif;max-width:480px;margin:auto;background:#fff;border-radius:14px;overflow:hidden;'>"
            + "<div style='background:linear-gradient(135deg,#F07600,#ff9a3c);padding:28px;text-align:center;'>"
            + "<h2 style='color:#fff;margin:0;'>Apex Saving Bank</h2>"
            + "<p style='color:rgba(255,255,255,0.85);margin:4px 0 0;font-size:13px;'>Secure Login OTP</p></div>"
            + "<div style='padding:32px;text-align:center;'>"
            + "<p style='font-size:15px;color:#333;'>Hello <strong>" + name + "</strong>,</p>"
            + "<p style='color:#666;font-size:14px;'>Your one-time password for login:</p>"
            + "<div style='background:#FFF3E6;border:2px dashed #F07600;border-radius:12px;padding:20px;margin:20px auto;display:inline-block;min-width:200px;'>"
            + "<div style='font-size:36px;font-weight:800;letter-spacing:10px;color:#F07600;'>" + otp + "</div>"
            + "<div style='font-size:12px;color:#9CA3AF;margin-top:6px;'>Valid for 5 minutes</div></div>"
            + "<div style='background:#FEF2F2;border-radius:8px;padding:10px;font-size:12px;color:#DC2626;margin-top:16px;'>"
            + "Never share this OTP with anyone.</div></div>"
            + "<div style='background:#F9FAFB;padding:12px;text-align:center;border-top:1px solid #E5E7EB;'>"
            + "<p style='color:#9CA3AF;font-size:11px;margin:0;'>2026 Apex Saving Bank Ltd.</p></div></div>";
        sendEmail(toEmail, subject, body);
    }

    public static void sendDueReminder(String toEmail, String userName,
                                        String accNo, double amount, int dueDay) {
        String subject = "Apex Saving Bank - RD Payment Due: " + accNo;
        String body = "<div style='font-family:Arial,sans-serif;max-width:500px;margin:auto;'>"
            + "<div style='background:#F07600;padding:24px;text-align:center;'>"
            + "<h2 style='color:#fff;margin:0;'>Apex Saving Bank</h2></div>"
            + "<div style='padding:28px;'><p>Dear <strong>" + userName + "</strong>,</p>"
            + "<p>Your RD installment is due on <strong>Day " + dueDay + "</strong> of this month.</p>"
            + "<p><strong>Account:</strong> " + accNo + "<br><strong>Amount:</strong> Rs." + String.format("%.0f", amount) + "</p>"
            + "<p style='color:#DC2626;'>Late penalty: Rs.10 per day after due date.</p>"
            + "</div></div>";
        sendEmail(toEmail, subject, body);
    }

    public static void sendAdminSummary(String adminEmail, int dueCount, String detailsHtml) {
        String subject = "Apex Saving Bank - Today's RD Due Summary";
        String body = "<div style='font-family:Arial,sans-serif;max-width:600px;margin:auto;'>"
            + "<div style='background:#F07600;padding:24px;text-align:center;'>"
            + "<h2 style='color:#fff;margin:0;'>Admin Summary</h2></div>"
            + "<div style='padding:28px;'>"
            + "<p>Today <strong>" + dueCount + "</strong> RD account(s) have payment due.</p>"
            + "<table style='width:100%;border-collapse:collapse;font-size:13px;margin-top:16px;'>"
            + "<tr style='background:#F9FAFB;'><th style='padding:10px;text-align:left;'>User</th>"
            + "<th style='padding:10px;text-align:left;'>Account</th>"
            + "<th style='padding:10px;text-align:right;'>Amount</th></tr>"
            + detailsHtml + "</table></div></div>";
        sendEmail(adminEmail, subject, body);
    }
}