package controller;

import model.Customer;
import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/RDAccountServlet")
public class RDAccountServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

       
        if (session == null || session.getAttribute("customer") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Customer customer = (Customer) session.getAttribute("customer");
        String username   = customer.getUsername();
        int userId        = customer.getId();

        try {
            double amount      = Double.parseDouble(request.getParameter("amount").trim());
            int months         = Integer.parseInt(request.getParameter("months").trim());
            int dueDay         = Integer.parseInt(request.getParameter("due_day").trim());
            double interestRate = 7.5; 

          
            if (amount <= 0 || months <= 0 || dueDay < 1 || dueDay > 31) {
                session.setAttribute("rdMsg", "error:Invalid input values!");
                response.sendRedirect("openAccount.jsp");
                return;
            }

            
            double maturityAmount = amount * months +
                (amount * months * (months + 1) / 2.0 * interestRate / 1200.0);

            Connection con = DBConnection.getConnection();

            if (con == null) {
                session.setAttribute("rdMsg", "error:Database connection failed!");
                response.sendRedirect("openAccount.jsp");
                return;
            }

           
            String accountNo = "MYRD" + userId + System.currentTimeMillis() % 10000;

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO rd_account(" +
                "  username, user_id, account_no, amount, months, due_day, " +
                "  start_date, interest_rate, maturity_amount, total_deposited, status" +
                ") VALUES (?, ?, ?, ?, ?, ?, CURRENT_DATE, ?, ?, 0, 'Active')"
            );
            ps.setString(1, username);
            ps.setInt(2, userId);
            ps.setString(3, accountNo);
            ps.setDouble(4, amount);
            ps.setInt(5, months);
            ps.setInt(6, dueDay);
            ps.setDouble(7, interestRate);
            ps.setDouble(8, maturityAmount);

            int i = ps.executeUpdate();

            if (i > 0) {
                session.setAttribute("rdMsg",
                    "success:🎉 RD Account Created Successfully!" +
                    " | Account No: " + accountNo +
                    " | Monthly: ₹" + amount +
                    " | Duration: " + months + " months" +
                    " | Maturity: ₹" + String.format("%.2f", maturityAmount));
            } else {
                session.setAttribute("rdMsg", "error:Failed to create RD Account!");
            }

            con.close();

        } catch (NumberFormatException e) {
            session.setAttribute("rdMsg", "error:Please enter valid numbers!");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("rdMsg", "error:Server Error: " + e.getMessage());
        }

        response.sendRedirect("openAccount.jsp");
    }
}
