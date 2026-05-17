package service;

import controller.DBConnection;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.*;
import java.time.LocalDate;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class DueDateScheduler implements ServletContextListener {

    private static final String ADMIN_EMAIL = "apexsavingbank@gmail.com";
    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();

        
        long initialDelay = getSecondsUntil8AM();

        scheduler.scheduleAtFixedRate(() -> {
            System.out.println("⏰ DueDateScheduler running at: " + LocalDate.now());
            sendDueReminders();
        }, initialDelay, 24 * 60 * 60, TimeUnit.SECONDS); 

        System.out.println("✅ DueDateScheduler started. Next run in " + initialDelay + " seconds.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            System.out.println("🛑 DueDateScheduler stopped.");
        }
    }

    private void sendDueReminders() {
        int todayDay = LocalDate.now().getDayOfMonth();
        
        
        int reminderDay = todayDay + 3;

        StringBuilder adminDetails = new StringBuilder();
        int dueCount = 0;

        try {
            Connection con = DBConnection.getConnection();

          
            PreparedStatement ps = con.prepareStatement(
                "SELECT r.account_id, r.account_no, r.amount, r.due_day, " +
                "u.username, u.full_name, u.email " +
                "FROM rd_account r " +
                "JOIN users u ON u.id = r.user_id " +
                "WHERE r.status = 'Active' " +
                "AND r.due_day = ? " +
                "AND u.email IS NOT NULL " +
                "AND u.email != ''"
            );
            ps.setInt(1, reminderDay);
            ResultSet rs = ps.executeQuery();

            while(rs.next()) {
                String accNo    = rs.getString("account_no");
                double amount   = rs.getDouble("amount");
                int    dueDay   = rs.getInt("due_day");
                String username = rs.getString("username");
                String fullName = rs.getString("full_name");
                String email    = rs.getString("email");

                String displayName = (fullName != null && !fullName.isEmpty()) ? fullName : username;

              
                EmailService.sendDueReminder(email, displayName, accNo, amount, dueDay);

                // ── Admin table row ──
                adminDetails.append("<tr>")
                    .append("<td style='padding:10px 14px;color:#374151;border-bottom:1px solid #F3F4F6;'>").append(displayName).append("</td>")
                    .append("<td style='padding:10px 14px;color:#374151;border-bottom:1px solid #F3F4F6;font-family:monospace;'>").append(accNo).append("</td>")
                    .append("<td style='padding:10px 14px;color:#F07600;font-weight:700;border-bottom:1px solid #F3F4F6;text-align:right;'>&#8377;").append(String.format("%.0f", amount)).append("</td>")
                    .append("<td style='padding:10px 14px;text-align:center;border-bottom:1px solid #F3F4F6;font-weight:600;'>").append(dueDay).append("</td>")
                    .append("</tr>");
                dueCount++;
            }

            con.close();
 
            if(dueCount > 0) {
                EmailService.sendAdminSummary(ADMIN_EMAIL, dueCount, adminDetails.toString());
                System.out.println("✅ Sent " + dueCount + " reminder(s) + admin summary.");
            } else {
                System.out.println("ℹ️ No RD dues in next 3 days.");
            }

        } catch(Exception e) {
            System.err.println("❌ DueDateScheduler error: " + e.getMessage());
            e.printStackTrace();
        }
    }
 
    private long getSecondsUntil8AM() {
        LocalDate now = LocalDate.now();
        java.time.LocalDateTime next8AM = now.atTime(8, 0);
        java.time.LocalDateTime nowTime = java.time.LocalDateTime.now();
        if(nowTime.isAfter(next8AM)) {
            next8AM = next8AM.plusDays(1);
        }
        return java.time.Duration.between(nowTime, next8AM).getSeconds();
    }
}

