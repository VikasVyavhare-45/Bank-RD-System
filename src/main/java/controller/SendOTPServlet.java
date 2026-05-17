package controller;

import service.EmailService;
import java.io.*;
import java.sql.*;
import java.util.Random;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/SendOTPServlet")
public class SendOTPServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String username  = request.getParameter("username");
        String password  = request.getParameter("password");
        boolean isResend = "true".equals(request.getParameter("resend"));

        HttpSession session = request.getSession();

        // ✅ ADMIN — OTP bypass
        if (!isResend && "admin".equals(username) && "V!kas".equals(password)) {
            session.setAttribute("user", "admin");
            session.setAttribute("role", "admin");
            out.print("{\"success\":true,\"isAdmin\":true}");
            return;
        }

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps;

            if (isResend) {
                username = (String) session.getAttribute("otpUsername");
                ps = con.prepareStatement("SELECT email, full_name FROM users WHERE username=?");
                ps.setString(1, username);
            } else {
                ps = con.prepareStatement("SELECT email, full_name, password FROM users WHERE username=?");
                ps.setString(1, username);
            }

            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                con.close();
                out.print("{\"success\":false,\"message\":\"Invalid username or password!\"}");
                return;
            }

            // Password verify
            if (!isResend) {
                String dbPass = rs.getString("password");
                if (!dbPass.equals(password)) {
                    con.close();
                    out.print("{\"success\":false,\"message\":\"Invalid username or password!\"}");
                    return;
                }
            }

            String email    = rs.getString("email");
            String fullName = rs.getString("full_name");
            if (fullName == null || fullName.isEmpty()) fullName = username;
            con.close();

            if (email == null || email.isEmpty()) {
                out.print("{\"success\":false,\"message\":\"No email linked to this account. Contact admin.\"}");
                return;
            }

            // ✅ OTP generate करा
            String otp    = String.format("%06d", new Random().nextInt(999999));
            long   expiry = System.currentTimeMillis() + (5 * 60 * 1000); // 5 min

            // Session मध्ये save करा
            session.setAttribute("otpCode",     otp);
            session.setAttribute("otpExpiry",   expiry);
            session.setAttribute("otpUsername", username);

            // ✅ KEY FIX: Email BACKGROUND thread मध्ये पाठवा
            // User ला लगेच response मिळेल — email background मध्ये जाईल
            final String finalEmail    = email;
            final String finalFullName = fullName;
            final String finalOtp      = otp;

            new Thread(new Runnable() {
                public void run() {
                    try {
                        sendOTPEmail(finalEmail, finalFullName, finalOtp);
                        System.out.println("✅ OTP email sent to: " + finalEmail);
                    } catch (Exception e) {
                        System.err.println("❌ OTP email failed: " + e.getMessage());
                    }
                }
            }).start();

            // ✅ Email पाठवायच्या आधीच user ला success response द्या
            String maskedEmail = maskEmail(email);
            out.print("{\"success\":true,\"isAdmin\":false,\"maskedEmail\":\"" + maskedEmail + "\"}");

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Server error. Please try again.\"}");
        }
    }

    private void sendOTPEmail(String toEmail, String name, String otp) {
        String subject = "🔐 Apex Saving Bank – Login OTP: " + otp;
        String body =
            "<!DOCTYPE html><html><body style='font-family:Arial,sans-serif;background:#f4f4f4;padding:20px;'>" +
            "<div style='max-width:480px;margin:auto;background:#fff;border-radius:14px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.1);'>" +
            "<div style='background:linear-gradient(135deg,#1E40AF,#3B82F6);padding:28px;text-align:center;'>" +
            "<h2 style='color:#fff;margin:0;font-size:22px;'>🏦 Apex Saving Bank</h2>" +
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
            "<p style='color:#9CA3AF;font-size:12px;margin:0;'>© 2026 Apex Saving Bank Ltd. | RBI License No. ASB-2024-001</p>" +
            "</div></div></body></html>";

        EmailService.sendEmail(toEmail, subject, body);
    }

    private String maskEmail(String email) {
        int at = email.indexOf('@');
        if (at <= 2) return "***" + email.substring(at);
        return email.charAt(0) + "***" + email.substring(at - 1);
    }
}