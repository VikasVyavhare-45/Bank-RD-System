package controller;

import model.Customer;
import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/OTPVerifyServlet")
public class OTPVerifyServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if(session == null) {
            response.sendRedirect("login.jsp?error=nouser");
            return;
        }

        String enteredOTP  = request.getParameter("otp");
        String username    = request.getParameter("username");
        String storedOTP   = (String) session.getAttribute("otpCode");
        Long   expiry      = (Long)   session.getAttribute("otpExpiry");
        String otpUsername = (String) session.getAttribute("otpUsername");

        // Null check
        if(enteredOTP == null || storedOTP == null || expiry == null || otpUsername == null) {
            response.sendRedirect("login.jsp?error=badotp");
            return;
        }

        // Username match
        if(!otpUsername.equals(username)) {
            response.sendRedirect("login.jsp?error=badotp");
            return;
        }

        // Expiry check (5 minutes)
        if(System.currentTimeMillis() > expiry) {
            session.removeAttribute("otpCode");
            session.removeAttribute("otpExpiry");
            session.removeAttribute("otpUsername");
            response.sendRedirect("login.jsp?error=badotp");
            return;
        }

        // OTP match
        if(!enteredOTP.trim().equals(storedOTP)) {
            response.sendRedirect("login.jsp?error=badotp");
            return;
        }

        // ✅ OTP सही — session create करा
        try {
            Connection con = DBConnection.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM users WHERE username=?");
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if(rs.next()) {
                // OTP session clear
                session.removeAttribute("otpCode");
                session.removeAttribute("otpExpiry");
                session.removeAttribute("otpUsername");

                String role = rs.getString("role");

                // Admin check
                if("admin".equals(role)) {
                    session.setAttribute("user", username);
                    session.setAttribute("role", "admin");
                    con.close();
                    response.sendRedirect("adminDashboard.jsp");
                    return;
                }

                // ✅ LoginServlet सारखंच Customer object बनवा
                Customer customer = new Customer();
                customer.setId(rs.getInt("id"));
                customer.setName(rs.getString("full_name"));
                customer.setEmail(rs.getString("email"));
                customer.setPhone(rs.getString("mobile"));
                customer.setUsername(username);
                customer.setAccountNo(rs.getString("account_no"));

                session.setAttribute("customer", customer);
                session.setAttribute("user", username);
                session.setAttribute("role", "user");

                con.close();
                response.sendRedirect("dashboard.jsp");

            } else {
                con.close();
                response.sendRedirect("login.jsp?error=nouser");
            }

        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=badotp");
        }
    }
}