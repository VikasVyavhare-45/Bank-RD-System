package controller;

import service.EmailService;
import controller.DBConnection;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.*;
import java.sql.*;
import java.time.LocalDate;

@WebServlet("/TestEmailServlet")
public class T extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<!DOCTYPE html><html><head>");
        out.println("<title>Email Test</title>");
        out.println("<link href='https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap' rel='stylesheet'/>");
        out.println("<style>");
        out.println("body{font-family:'Inter',sans-serif;background:#F0F2F5;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0;}");
        out.println(".card{background:#fff;border-radius:16px;padding:36px;max-width:520px;width:100%;box-shadow:0 4px 24px rgba(0,0,0,0.08);}");
        out.println("h2{color:#1a1a2e;margin-bottom:6px;} .sub{color:#9CA3AF;font-size:13px;margin-bottom:24px;}");
        out.println(".result{padding:16px;border-radius:10px;margin-top:20px;font-size:14px;font-weight:600;}");
        out.println(".success{background:#DCFCE7;color:#16A34A;border:1px solid #bbf7d0;}");
        out.println(".error{background:#FEE2E2;color:#DC2626;border:1px solid #fecaca;}");
        out.println(".info{background:#EFF6FF;color:#2563EB;border:1px solid #bfdbfe;margin-bottom:16px;padding:14px;border-radius:10px;font-size:13px;}");
        out.println("table{width:100%;border-collapse:collapse;font-size:13px;margin-top:16px;}");
        out.println("th{background:#F9FAFB;padding:10px 14px;text-align:left;color:#9CA3AF;font-weight:600;border-bottom:1px solid #E5E7EB;}");
        out.println("td{padding:10px 14px;border-bottom:1px solid #F3F4F6;color:#374151;}");
        out.println(".badge{padding:3px 10px;border-radius:12px;font-size:11px;font-weight:600;background:#DCFCE7;color:#16A34A;}");
        out.println(".badge.fail{background:#FEE2E2;color:#DC2626;}");
        out.println("</style></head><body><div class='card'>");
        out.println("<h2>📧 Email Notification Test</h2>");
        out.println("<div class='sub'>MyBank – Due Date Reminder</div>");

        int todayDay = LocalDate.now().getDayOfMonth();
        out.println("<div class='info'>📅 आजची तारीख: <strong>" + LocalDate.now() + "</strong> (Day " + todayDay + ")<br/>");
        out.println("📌 सध्या <strong>सर्व Active RD accounts</strong> ना test email पाठवतोय...</div>");

        int sent = 0, failed = 0;
        StringBuilder rows = new StringBuilder();

        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT r.account_id, r.account_no, r.amount, r.due_day, " +
                "u.username, u.full_name, u.email " +
                "FROM rd_account r " +
                "JOIN users u ON u.id = r.user_id " +
                "WHERE r.status = 'Active' " +
                "AND u.email IS NOT NULL AND u.email != ''"
            );
            ResultSet rs = ps.executeQuery();

            while(rs.next()) {
                String accNo    = rs.getString("account_no");
                double amount   = rs.getDouble("amount");
                int    dueDay   = rs.getInt("due_day");
                String username = rs.getString("username");
                String fullName = rs.getString("full_name");
                String email    = rs.getString("email");
                String name     = (fullName != null && !fullName.isEmpty()) ? fullName : username;

                String status;
                try {
                    EmailService.sendDueReminder(email, name, accNo, amount, dueDay);
                    status = "<span class='badge'>✅ Sent</span>";
                    sent++;
                } catch(Exception ex) {
                    status = "<span class='badge fail'>❌ Failed: " + ex.getMessage() + "</span>";
                    failed++;
                }

                rows.append("<tr>")
                    .append("<td>").append(name).append("</td>")
                    .append("<td style='font-family:monospace;'>").append(accNo).append("</td>")
                    .append("<td style='color:#9CA3AF;font-size:12px;'>").append(email).append("</td>")
                    .append("<td style='color:#F07600;font-weight:700;'>&#8377;").append(String.format("%.0f", amount)).append("</td>")
                    .append("<td>").append(status).append("</td>")
                    .append("</tr>");
            }
            con.close();

 
            if(sent > 0) {
                try {
                    EmailService.sendAdminSummary("vikasvyavhare7@gmail.com", sent, rows.toString());
                    out.println("<div class='result success'>✅ " + sent + " user email(s) sent successfully!<br/>📊 Admin summary email also sent!</div>");
                } catch(Exception ex) {
                    out.println("<div class='result success'>✅ " + sent + " user email(s) sent!<br/>⚠️ Admin summary failed: " + ex.getMessage() + "</div>");
                }
            } else {
                out.println("<div class='result error'>❌ No emails sent. Email column empty असेल किंवा connection error.</div>");
            }

            if(rows.length() > 0) {
                out.println("<table><thead><tr><th>User</th><th>Account No</th><th>Email</th><th>Amount</th><th>Status</th></tr></thead><tbody>");
                out.println(rows.toString());
                out.println("</tbody></table>");
            }

        } catch(Exception e) {
            out.println("<div class='result error'>❌ Database Error: " + e.getMessage() + "</div>");
            e.printStackTrace(out);
        }

        out.println("<br/><a href='adminDashboard.jsp' style='color:#F07600;font-size:13px;text-decoration:none;'>← Back to Dashboard</a>");
        out.println("</div></body></html>");
    }
}