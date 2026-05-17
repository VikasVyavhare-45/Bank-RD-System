package controller;

import model.Customer;
import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/OpenRDServlet")
public class OpenRDServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        //  Session check
        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        
        Customer customer = (Customer) session.getAttribute("customer");
        String username = customer.getUsername();
        int userId = customer.getId();

        try {
            double amount    = Double.parseDouble(request.getParameter("amount").trim());
            int dueDay       = Integer.parseInt(request.getParameter("due_day").trim());
            int durationMonth = Integer.parseInt(request.getParameter("duration").trim());
            double interestRate = 7.5; 

            
            double maturityAmount = amount * durationMonth +
                    (amount * durationMonth * (durationMonth + 1) / 2.0 * interestRate / 1200.0);

            Connection con = DBConnection.getConnection();

            if (con == null) {
                session.setAttribute("rdMsg", "error:Database connection failed!");
                response.sendRedirect("openAccount.jsp");
                return;
            }

            
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO rd_account(username, user_id, amount, start_date, due_day, " +
                "duration_months, interest_rate, maturity_amount, total_deposited, status) " +
                "VALUES (?, ?, ?, CURRENT_DATE, ?, ?, ?, ?, 0, 'Active')"
            );
            ps.setString(1, username);
            ps.setInt(2, userId);
            ps.setDouble(3, amount);
            ps.setInt(4, dueDay);
            ps.setInt(5, durationMonth);
            ps.setDouble(6, interestRate);
            ps.setDouble(7, maturityAmount);

            int i = ps.executeUpdate();

            if (i > 0) {
                session.setAttribute("rdMsg", "success:RD Account Created Successfully! ✅ " +
                    "Monthly Amount: ₹" + amount +
                    " | Duration: " + durationMonth + " months" +
                    " | Maturity Amount: ₹" + String.format("%.2f", maturityAmount));
            } else {
                session.setAttribute("rdMsg", "error:Failed to Create RD Account! ❌");
            }

            con.close();

        } catch (NumberFormatException e) {
            session.setAttribute("rdMsg", "error:Invalid input! Please enter correct values.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("rdMsg", "error:Server Error: " + e.getMessage());
        }

        response.sendRedirect("openAccount.jsp");
    }
}