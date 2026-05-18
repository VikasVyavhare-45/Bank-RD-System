<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.Customer" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) { response.sendRedirect("login.jsp"); return; }
    String accId = request.getParameter("account_id");
    if (accId == null) { response.sendRedirect("selectAccount.jsp"); return; }
    String msg = (String) session.getAttribute("depositMsg");
    session.removeAttribute("depositMsg");
%>
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Apex Saving Bank - Deposit</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
*{margin:0;padding:0;box-sizing:border-box;font-family:'Inter',sans-serif;}
body{background:#F0F2F5;min-height:100vh;}
.navbar{background:#fff;padding:0 28px;height:60px;display:flex;align-items:center;justify-content:space-between;box-shadow:0 2px 8px rgba(0,0,0,0.07);}
.nav-logo{font-size:20px;font-weight:700;color:#F07600;display:flex;align-items:center;gap:8px;}
.nav-logo span{background:#F07600;color:#fff;border-radius:8px;width:34px;height:34px;display:inline-flex;align-items:center;justify-content:center;}
.content{max-width:500px;margin:32px auto;padding:0 20px;}
.page-title{font-size:21px;font-weight:700;color:#1a1a2e;margin-bottom:20px;}
.page-title em{color:#F07600;font-style:normal;}
.alert{padding:12px 16px;border-radius:10px;font-size:13px;margin-bottom:20px;display:flex;align-items:center;gap:10px;}
.alert.success{background:#DCFCE7;border:1px solid #BBF7D0;color:#16A34A;}
.alert.error{background:#FEE2E2;border:1px solid #FECACA;color:#DC2626;}
.card{background:#fff;border-radius:16px;border:1px solid #E5E7EB;box-shadow:0 2px 12px rgba(0,0,0,0.05);overflow:hidden;}
.card-header{background:linear-gradient(135deg,#F07600,#ff9a3c);padding:20px 24px;color:#fff;}
.card-header h3{font-size:16px;font-weight:700;}
.card-header p{font-size:12px;opacity:0.85;margin-top:3px;}
.card-body{padding:28px;}
.acct-chip{background:#FFF3E6;border:1px solid #FDDBB4;border-radius:8px;padding:10px 14px;font-size:13px;color:#92400E;margin-bottom:20px;display:flex;align-items:center;gap:8px;}
.field label{display:block;font-size:12px;font-weight:600;color:#6B7280;text-transform:uppercase;margin-bottom:7px;}
.input-wrap{position:relative;}
.input-wrap i{position:absolute;left:13px;top:50%;transform:translateY(-50%);color:#9CA3AF;font-size:13px;}
input[type="number"]{width:100%;padding:12px 14px 12px 38px;border:1.5px solid #E5E7EB;border-radius:10px;font-size:14px;color:#1a1a2e;font-family:inherit;}
input[type="number"]:focus{outline:none;border-color:#F07600;box-shadow:0 0 0 3px rgba(240,118,0,0.1);}
.btn{width:100%;margin-top:20px;padding:13px;border:none;border-radius:10px;background:linear-gradient(135deg,#F07600,#ff9a3c);color:#fff;font-size:15px;font-weight:700;cursor:pointer;font-family:inherit;}
.back-link{display:block;text-align:center;margin-top:14px;font-size:13px;color:#6B7280;text-decoration:none;}
.back-link:hover{color:#F07600;}
@media(max-width:768px){.content{padding:0 12px;margin:20px auto;}.page-title{font-size:18px;}.card-body{padding:20px;}}
@media(max-width:480px){.content{padding:0 8px;}.page-title{font-size:16px;}.card-body{padding:16px;}.card-header{padding:16px 18px;}.card-header h3{font-size:14px;}.btn{font-size:14px;padding:12px;}}
</style>
</head>
<body>
<nav class="navbar">
  <div class="nav-logo"><span>A</span> Apex Saving Bank</div>
</nav>
<div class="content">
  <div class="page-title"><em>Deposit</em> Installment</div>
  <% if (msg != null) {
    boolean ok = msg.startsWith("success:");
    String txt = msg.substring(msg.indexOf(":") + 1); %>
    <div class="alert <%= ok ? "success" : "error" %>">
      <i class="fas fa-<%= ok ? "check-circle" : "exclamation-circle" %>"></i> <%= txt %>
    </div>
  <% } %>
  <div class="card">
    <div class="card-header">
      <h3><i class="fas fa-credit-card"></i> &nbsp;Pay Monthly Installment</h3>
      <p>Enter the exact RD monthly amount</p>
    </div>
    <div class="card-body">
      <div class="acct-chip"><i class="fas fa-university"></i> Account ID: <strong><%= accId %></strong></div>
      <form action="DepositServlet" method="post">
        <input type="hidden" name="account_id" value="<%= accId %>"/>
        <div class="field">
          <label>Deposit Amount (&#8377;)</label>
          <div class="input-wrap">
            <i class="fas fa-rupee-sign"></i>
            <input type="number" name="amount" placeholder="Enter exact RD amount" min="1" required/>
          </div>
        </div>
        <button type="submit" class="btn"><i class="fas fa-paper-plane"></i> &nbsp;Pay Now</button>
      </form>
      <a href="selectAccount.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Change Account</a>
    </div>
  </div>
</div>
</body>
</html>
