package controller;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.sql.*;
import java.time.LocalDate;

@WebServlet("/DepositServlet")
public class DepositServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            int    accountId  = Integer.parseInt(request.getParameter("account_id").trim());
            double userAmount = Double.parseDouble(request.getParameter("amount").trim());

            Connection con = DBConnection.getConnection();

            // ── Fetch RD account details (amount, status, due_day) ──
            PreparedStatement ps1 = con.prepareStatement(
                "SELECT amount, status, due_day FROM rd_account WHERE account_id = ?"
            );
            ps1.setInt(1, accountId);
            ResultSet rs = ps1.executeQuery();

            if (rs.next()) {
                double rdAmount = rs.getDouble("amount");
                String status   = rs.getString("status");
                int    dueDay   = rs.getInt("due_day");   // e.g. 5 means 5th of every month

                // ── Check account is Active ──
                if (!"Active".equalsIgnoreCase(status)) {
                    session.setAttribute("depositMsg", "error:Account is not Active!");
                    response.sendRedirect("deposit.jsp?account_id=" + accountId);
                    return;
                }

                // ── Amount exact match check ──
                if (Math.abs(userAmount - rdAmount) >= 0.01) {
                    session.setAttribute("depositMsg",
                        "error:Invalid Amount! Enter exact RD amount: ₹" + rdAmount);
                    response.sendRedirect("deposit.jsp?account_id=" + accountId);
                    return;
                }

                // ══════════════════════════════════════════════
                //   LATE PAYMENT PENALTY LOGIC — ₹10 per day
                // ══════════════════════════════════════════════
                LocalDate today       = LocalDate.now();
                int       todayDay    = today.getDayOfMonth();
                int       daysLate    = 0;
                double    penaltyAmt  = 0.0;
                String    penaltyNote = "";

                // ── Check: did user already pay this month? ──
                // If today's day > due_day → user is late
                // Also make sure no deposit exists for current month already
                PreparedStatement psCheck = con.prepareStatement(
                    "SELECT COUNT(*) FROM transactions " +
                    "WHERE account_id = ? " +
                    "  AND txn_type = 'Deposit' " +
                    "  AND MONTH(txn_date) = MONTH(CURRENT_DATE) " +
                    "  AND YEAR(txn_date)  = YEAR(CURRENT_DATE)"
                );
                psCheck.setInt(1, accountId);
                ResultSet rsCheck = psCheck.executeQuery();
                boolean alreadyPaidThisMonth = rsCheck.next() && rsCheck.getInt(1) > 0;

                if (alreadyPaidThisMonth) {
                    session.setAttribute("depositMsg",
                        "error:You have already paid the installment for this month!");
                    con.close();
                    response.sendRedirect("deposit.jsp?account_id=" + accountId);
                    return;
                }

                // ── Calculate late days ──
                if (todayDay > dueDay) {
                    daysLate   = todayDay - dueDay;
                    penaltyAmt = daysLate * 10.0;   // ₹10 per day
                    penaltyNote = " (Late by " + daysLate + " day(s) — Penalty: ₹" + (int)penaltyAmt + ")";
                }

                double totalDebit = rdAmount + penaltyAmt;

                // ── Insert main Deposit transaction ──
                PreparedStatement ps2 = con.prepareStatement(
                    "INSERT INTO transactions(account_id, amount, txn_date, txn_type) " +
                    "VALUES (?, ?, CURRENT_DATE, 'Deposit')"
                );
                ps2.setInt(1, accountId);
                ps2.setDouble(2, rdAmount);
                ps2.executeUpdate();

                // ── If late → insert separate Penalty transaction ──
                if (penaltyAmt > 0) {
                    PreparedStatement psPenalty = con.prepareStatement(
                        "INSERT INTO transactions(account_id, amount, txn_date, txn_type) " +
                        "VALUES (?, ?, CURRENT_DATE, 'Late Penalty')"
                    );
                    psPenalty.setInt(1, accountId);
                    psPenalty.setDouble(2, penaltyAmt);
                    psPenalty.executeUpdate();
                }

                // ── Update total_deposited (only RD amount, not penalty) ──
                PreparedStatement ps3 = con.prepareStatement(
                    "UPDATE rd_account SET total_deposited = total_deposited + ? " +
                    "WHERE account_id = ?"
                );
                ps3.setDouble(1, rdAmount);
                ps3.setInt(2, accountId);
                ps3.executeUpdate();

                // ── Success message ──
                if (penaltyAmt > 0) {
                    session.setAttribute("depositMsg",
                        "success:Deposit Successful! ✅" + penaltyNote +
                        " | Total Charged: ₹" + (int)totalDebit);
                } else {
                    session.setAttribute("depositMsg",
                        "success:Deposit Successful! ✅ Paid on time.");
                }

                con.close();

            } else {
                session.setAttribute("depositMsg", "error:Account Not Found!");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("depositMsg", "error:Server Error: " + e.getMessage());
        }

        response.sendRedirect("deposit.jsp?account_id=" + request.getParameter("account_id"));
    }
}