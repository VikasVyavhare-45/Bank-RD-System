package controller;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullname = request.getParameter("fullname").trim();
        String username = request.getParameter("username").trim();
        String aadhar   = request.getParameter("aadhar").trim();
        String pan      = request.getParameter("pan").trim().toUpperCase();
        String mobile   = request.getParameter("mobile").trim();
        String email    = request.getParameter("email").trim();
        String password = request.getParameter("password").trim();
        String account  = request.getParameter("account").trim();
        String ifsc     = request.getParameter("ifsc").trim().toUpperCase();
        String bank     = request.getParameter("bank").trim();
        String role     = "user";

        if (fullname.isEmpty() || username.isEmpty() || password.isEmpty()) {
            response.sendRedirect("register.jsp?error=empty");
            return;
        }

        try {
            Connection con = DBConnection.getConnection();
            if (con == null) { response.sendRedirect("register.jsp?error=db"); return; }

           
            PreparedStatement check = con.prepareStatement("SELECT id FROM users WHERE username=?");
            check.setString(1, username);
            ResultSet rs = check.executeQuery();
            if (rs.next()) {
                response.sendRedirect("register.jsp?error=exists");
                con.close(); return;
            }

            String q = "INSERT INTO users(full_name,username,aadhar,pan,mobile,email,password,account_no,ifsc,bank_name,role) VALUES(?,?,?,?,?,?,?,?,?,?,?)";
            PreparedStatement ps = con.prepareStatement(q);
            ps.setString(1, fullname); ps.setString(2, username); ps.setString(3, aadhar);
            ps.setString(4, pan);     ps.setString(5, mobile);   ps.setString(6, email);
            ps.setString(7, password); ps.setString(8, account); ps.setString(9, ifsc);
            ps.setString(10, bank);   ps.setString(11, role);

            int i = ps.executeUpdate();
            con.close();

            if (i > 0) response.sendRedirect("login.jsp?msg=success");
            else        response.sendRedirect("register.jsp?error=failed");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=server");
        }
    }
}
