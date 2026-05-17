package controller;

import model.Customer;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.*;
import java.sql.*;

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if(session == null || session.getAttribute("customer") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Customer customer = (Customer) session.getAttribute("customer");
        int userId = customer.getId();
        String type = request.getParameter("type");

        try {
            Connection con = DBConnection.getConnection();

            if("info".equals(type)) {
                // ── Update full name, mobile, email ──
                String fullName = request.getParameter("full_name") != null ? request.getParameter("full_name").trim() : "";
                String mobile   = request.getParameter("mobile")    != null ? request.getParameter("mobile").trim()    : "";
                String email    = request.getParameter("email")     != null ? request.getParameter("email").trim()     : "";

                PreparedStatement ps = con.prepareStatement(
                    "UPDATE users SET full_name=?, mobile=?, email=? WHERE id=?"
                );
                ps.setString(1, fullName);
                ps.setString(2, mobile);
                ps.setString(3, email);
                ps.setInt(4, userId);
                ps.executeUpdate();
                con.close();

                session.setAttribute("profileMsg", "Profile updated successfully!");

            } else if("password".equals(type)) {
                // ── Change password ──
                String oldPass  = request.getParameter("old_password");
                String newPass  = request.getParameter("new_password");
                String confPass = request.getParameter("confirm_password");

                // Verify old password
                PreparedStatement ps1 = con.prepareStatement(
                    "SELECT password FROM users WHERE id=?"
                );
                ps1.setInt(1, userId);
                ResultSet rs = ps1.executeQuery();

                if(rs.next()) {
                    String currentPass = rs.getString("password");

                    if(!currentPass.equals(oldPass)) {
                        con.close();
                        session.setAttribute("profileMsg", "ERROR:Current password is incorrect!");
                        response.sendRedirect("dashboard.jsp");
                        return;
                    }
                    if(!newPass.equals(confPass)) {
                        con.close();
                        session.setAttribute("profileMsg", "ERROR:New passwords do not match!");
                        response.sendRedirect("dashboard.jsp");
                        return;
                    }
                    if(newPass.length() < 6) {
                        con.close();
                        session.setAttribute("profileMsg", "ERROR:Password must be at least 6 characters!");
                        response.sendRedirect("dashboard.jsp");
                        return;
                    }

                    PreparedStatement ps2 = con.prepareStatement(
                        "UPDATE users SET password=? WHERE id=?"
                    );
                    ps2.setString(1, newPass);
                    ps2.setInt(2, userId);
                    ps2.executeUpdate();
                    con.close();

                    session.setAttribute("profileMsg", "Password changed successfully!");
                }
            }

        } catch(Exception e) {
            e.printStackTrace();
            session.setAttribute("profileMsg", "ERROR:Something went wrong: " + e.getMessage());
        }

        response.sendRedirect("dashboard.jsp");
    }
}