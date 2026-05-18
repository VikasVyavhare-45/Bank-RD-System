<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,controller.DBConnection,model.Customer" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) { response.sendRedirect("login.jsp"); return; }
    String username = customer.getUsername();
    Connection conn = DBConnection.getConnection();
    PreparedStatement ps = conn.prepareStatement("SELECT * FROM rd_account WHERE username=? AND status='Active'");
    ps.setString(1, username);
    ResultSet rs = ps.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Apex Saving Bank - Select Account</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
*{margin:0;padding:0;box-sizing:border-box;font-family:'Inter',sans-serif;}
body{background:#F0F2F5;min-height:100vh;}
.navbar{background:#fff;padding:0 28px;height:60px;display:flex;align-items:center;justify-content:space-between;box-shadow:0 2px 8px rgba(0,0,0,0.07);}
.nav-logo{font-size:20px;font-weight:700;color:#F07600;display:flex;align-items:center;gap:8px;}
.nav-logo span{background:#F07600;color:#fff;border-radius:8px;width:34px;height:34px;display:inline-flex;align-items:center;justify-content:center;}
.content{max-width:600px;margin:32px auto;padding:0 20px;}
.page-title{font-size:21px;font-weight:700;color:#1a1a2e;margin-bottom:20px;}
.page-title em{color:#F07600;font-style:normal;}
.card{background:#fff;border-radius:16px;border:1px solid #E5E7EB;padding:28px;box-shadow:0 2px 12px rgba(0,0,0,0.05);}
.field label{display:block;font-size:12px;font-weight:600;color:#6B7280;text-transform:uppercase;margin-bottom:8px;}
select{width:100%;padding:12px 14px;border:1.5px solid #E5E7EB;border-radius:10px;font-size:14px;color:#1a1a2e;font-family:inherit;background:#fff;}
select:focus{outline:none;border-color:#F07600;}
.btn{width:100%;margin-top:20px;padding:13px;border:none;border-radius:10px;background:linear-gradient(135deg,#F07600,#ff9a3c);color:#fff;font-size:15px;font-weight:700;cursor:pointer;font-family:inherit;}
.no-acc{text-align:center;color:#9CA3AF;padding:20px;font-size:14px;}
.back-link{display:block;text-align:center;margin-top:14px;font-size:13px;color:#6B7280;text-decoration:none;}
.back-link:hover{color:#F07600;}
@media(max-width:768px){.content{padding:0 12px;margin:20px auto;}.page-title{font-size:18px;}.card{padding:20px;}}
@media(max-width:480px){.content{padding:0 8px;}.page-title{font-size:16px;}.card{padding:14px;}.btn{font-size:14px;padding:11px;}}
</style>
</head>
<body>
<nav class="navbar">
  <div class="nav-logo"><span>A</span> Apex Saving Bank</div>
</nav>
<div class="content">
  <div class="page-title">Select <em>RD Account</em></div>
  <div class="card">
    <% boolean found = false;
       StringBuilder options = new StringBuilder();
       while(rs.next()){
         found = true;
         options.append("<option value='").append(rs.getInt("account_id")).append("'>")
                .append("Account: ").append(rs.getString("account_no"))
                .append(" | \u20B9").append(rs.getDouble("amount")).append("/month")
                .append("</option>");
       }
       conn.close();
    %>
    <% if (!found) { %>
      <div class="no-acc"><i class="fas fa-inbox" style="font-size:32px;margin-bottom:8px;display:block;"></i>No active RD accounts found.<br><a href="openAccount.jsp" style="color:#F07600;">Open one now &#8594;</a></div>
    <% } else { %>
      <form action="deposit.jsp" method="get">
        <div class="field">
          <label>Choose RD Account</label>
          <select name="account_id"><%= options %></select>
        </div>
        <button type="submit" class="btn"><i class="fas fa-arrow-right"></i> &nbsp;Continue to Deposit</button>
      </form>
    <% } %>
    <a href="dashboard.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
  </div>
</div>
</body>
</html>
