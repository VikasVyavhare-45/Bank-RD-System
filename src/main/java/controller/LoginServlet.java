package controller;

import model.Customer;
import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username").trim();
        String password = request.getParameter("password").trim();

        //  Empty check
        if (username.isEmpty() || password.isEmpty()) {
            response.sendRedirect("login.jsp?error=1");
            return;
        }

        HttpSession session = request.getSession();

        // ADMIN CHECK
        if (username.equals("admin") && password.equals("1234")) {
            session.setAttribute("user", username);
            session.setAttribute("role", "admin");
            response.sendRedirect("adminDashboard.jsp");
            return;
        }

        try {
            Connection con = DBConnection.getConnection();

            if (con == null) {
                System.out.println("❌ DB Connection is null!");
                response.sendRedirect("login.jsp?error=1");
                return;
            }

            String q = "SELECT * FROM users WHERE username=? AND password=?";
            PreparedStatement ps = con.prepareStatement(q);
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
               
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
                response.sendRedirect("login.jsp?error=1");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=1");
        }
    }
}