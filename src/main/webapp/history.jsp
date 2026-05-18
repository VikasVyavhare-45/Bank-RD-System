<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,controller.DBConnection,model.Customer" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) { response.sendRedirect("login.jsp"); return; }
    String username = customer.getUsername();
    Connection con = DBConnection.getConnection();
    PreparedStatement ps1 = con.prepareStatement("SELECT * FROM rd_account WHERE username=?");
    ps1.setString(1, username);
    ResultSet rs1 = ps1.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Apex Saving Bank - Transaction History</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
*{margin:0;padding:0;box-sizing:border-box;font-family:'Inter',sans-serif;}
body{background:#F0F2F5;min-height:100vh;}
.navbar{background:#fff;padding:0 28px;height:60px;display:flex;align-items:center;justify-content:space-between;box-shadow:0 2px 8px rgba(0,0,0,0.07);}
.nav-logo{font-size:20px;font-weight:700;color:#F07600;display:flex;align-items:center;gap:8px;}
.nav-logo span{background:#F07600;color:#fff;border-radius:8px;width:34px;height:34px;display:inline-flex;align-items:center;justify-content:center;}
.nav-links a{text-decoration:none;color:#555;font-size:13px;font-weight:500;margin-left:20px;}
.nav-links a:hover{color:#F07600;}
.content{max-width:900px;margin:32px auto;padding:0 20px;}
.page-title{font-size:21px;font-weight:700;color:#1a1a2e;margin-bottom:20px;}
.page-title em{color:#F07600;font-style:normal;}
.acc-card{background:#fff;border-radius:14px;border:1px solid #E5E7EB;margin-bottom:24px;overflow:hidden;box-shadow:0 2px 10px rgba(0,0,0,0.04);}
.acc-header{background:linear-gradient(135deg,#1a1a2e,#2d3561);padding:16px 22px;display:flex;justify-content:space-between;align-items:center;}
.acc-no{font-size:14px;font-weight:700;color:#fff;}
.acc-status{padding:4px 12px;border-radius:20px;font-size:12px;font-weight:600;}
.acc-status.active{background:#DCFCE7;color:#16A34A;}
.acc-status.matured{background:#DBEAFE;color:#1D4ED8;}
.acc-status.closed{background:#FEE2E2;color:#DC2626;}
.acc-summary{display:grid;grid-template-columns:repeat(4,1fr);gap:0;border-bottom:1px solid #E5E7EB;}
.sum-item{padding:14px 18px;border-right:1px solid #E5E7EB;}
.sum-item:last-child{border-right:none;}
.sum-label{font-size:11px;color:#9CA3AF;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:4px;}
.sum-value{font-size:15px;font-weight:700;color:#1a1a2e;}
.sum-value.orange{color:#F07600;}
.sum-value.green{color:#16A34A;}
.txn-table{width:100%;border-collapse:collapse;}
.txn-table th{padding:10px 18px;font-size:11px;font-weight:600;color:#9CA3AF;text-transform:uppercase;background:#F9FAFB;text-align:left;border-bottom:1px solid #E5E7EB;}
.txn-table td{padding:12px 18px;font-size:13.5px;color:#374151;border-bottom:1px solid #F3F4F6;}
.txn-table tr:last-child td{border-bottom:none;}
.txn-table tr:hover td{background:#FFFAF5;}
.amount-cell{font-weight:700;color:#16A34A;}
.no-txn{text-align:center;padding:24px;color:#9CA3AF;font-size:13px;}
.back-link{display:inline-flex;align-items:center;gap:6px;text-decoration:none;color:#6B7280;font-size:13px;margin-bottom:16px;}
.back-link:hover{color:#F07600;}
@media(max-width:768px){.content{padding:0 12px;margin:20px auto;}.page-title{font-size:18px;}.navbar{padding:0 14px;}.nav-links a{margin-left:10px;font-size:12px;}.acc-summary{grid-template-columns:1fr 1fr;}.txn-table{display:block;overflow-x:auto;white-space:nowrap;-webkit-overflow-scrolling:touch;font-size:12px;}}
@media(max-width:480px){.content{padding:0 8px;}.acc-summary{grid-template-columns:1fr;}.sum-item{padding:10px 14px;}.nav-links{display:none;}.page-title{font-size:16px;}}
</style>
</head>
<body>
<nav class="navbar">
  <div class="nav-logo"><span>A</span> Apex Saving Bank</div>
  <div class="nav-links">
    <a href="dashboard.jsp">Dashboard</a>
    <a href="selectAccount.jsp">Deposit</a>
    <a href="history.jsp">History</a>
    <a href="LogoutServlet" style="color:#EF4444;">Logout</a>
  </div>
</nav>

<div class="content">
  <a href="dashboard.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
  <div class="page-title">Transaction <em>History</em></div>

  <%
  boolean anyAccount = false;
  while (rs1.next()) {
    anyAccount = true;
    int accId = rs1.getInt("account_id");
    String accNo = rs1.getString("account_no");
    double rdAmount = rs1.getDouble("amount");
    double totalDep = rs1.getDouble("total_deposited");
    double maturity = rs1.getDouble("maturity_amount");
    String status = rs1.getString("status");
    PreparedStatement ps2 = con.prepareStatement("SELECT COUNT(*) FROM transactions WHERE account_id=?");
    ps2.setInt(1, accId);
    ResultSet rc = ps2.executeQuery();
    int txnCount = rc.next() ? rc.getInt(1) : 0;
  %>
  <div class="acc-card">
    <div class="acc-header">
      <div class="acc-no"><i class="fas fa-university" style="margin-right:8px;color:#F07600;"></i><%= accNo != null ? accNo : "ACC-" + accId %></div>
      <span class="acc-status <%= status != null ? status.toLowerCase() : "active" %>"><%= status != null ? status : "Active" %></span>
    </div>
    <div class="acc-summary">
      <div class="sum-item"><div class="sum-label">Monthly Amount</div><div class="sum-value orange">&#8377;<%= String.format("%.0f", rdAmount) %></div></div>
      <div class="sum-item"><div class="sum-label">Total Deposited</div><div class="sum-value">&#8377;<%= String.format("%.0f", totalDep) %></div></div>
      <div class="sum-item"><div class="sum-label">Maturity Value</div><div class="sum-value green">&#8377;<%= String.format("%.0f", maturity) %></div></div>
      <div class="sum-item"><div class="sum-label">Transactions</div><div class="sum-value"><%= txnCount %> payments</div></div>
    </div>
    <table class="txn-table">
      <thead><tr><th>#</th><th>Date</th><th>Type</th><th>Amount</th></tr></thead>
      <tbody>
      <%
        PreparedStatement ps3 = con.prepareStatement("SELECT * FROM transactions WHERE account_id=? ORDER BY txn_date DESC");
        ps3.setInt(1, accId);
        ResultSet rs3 = ps3.executeQuery();
        int sno = 1;
        boolean hasTxn = false;
        while (rs3.next()) {
          hasTxn = true;
      %>
        <tr>
          <td style="color:#9CA3AF;"><%= sno++ %></td>
          <td><i class="fas fa-calendar-alt" style="color:#F07600;margin-right:6px;"></i><%= rs3.getDate("txn_date") %></td>
          <td><span style="background:#FFF3E6;color:#F07600;padding:3px 10px;border-radius:12px;font-size:12px;font-weight:600;"><%= rs3.getString("txn_type") != null ? rs3.getString("txn_type") : "Deposit" %></span></td>
          <td class="amount-cell">&#8377;<%= String.format("%.2f", rs3.getDouble("amount")) %></td>
        </tr>
      <% } if (!hasTxn) { %>
        <tr><td colspan="4" class="no-txn"><i class="fas fa-inbox" style="font-size:24px;display:block;margin-bottom:6px;"></i>No transactions yet</td></tr>
      <% } %>
      </tbody>
    </table>
  </div>
  <% } %>

  <% if (!anyAccount) { %>
    <div style="text-align:center;background:#fff;border-radius:14px;padding:48px;color:#9CA3AF;">
      <i class="fas fa-inbox" style="font-size:40px;margin-bottom:12px;display:block;"></i>
      No RD accounts found. <a href="openAccount.jsp" style="color:#F07600;">Open one now &#8594;</a>
    </div>
  <% } %>
  <% con.close(); %>
</div>
</body>
</html>
