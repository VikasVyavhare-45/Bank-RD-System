<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="model.Customer" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) { response.sendRedirect("login.jsp"); return; }
    String msg = (String) session.getAttribute("rdMsg");
    session.removeAttribute("rdMsg");
%>
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Apex Saving Bank - Open RD Account</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
*{margin:0;padding:0;box-sizing:border-box;font-family:'Inter',sans-serif;}
body{background:#F0F2F5;min-height:100vh;}
.navbar{background:#fff;padding:0 28px;height:60px;display:flex;align-items:center;justify-content:space-between;box-shadow:0 2px 8px rgba(0,0,0,0.07);}
.nav-logo{font-size:20px;font-weight:700;color:#F07600;display:flex;align-items:center;gap:8px;}
.nav-logo span{background:#F07600;color:#fff;border-radius:8px;width:34px;height:34px;display:inline-flex;align-items:center;justify-content:center;font-size:16px;}
.nav-links a{text-decoration:none;color:#555;font-size:13px;font-weight:500;margin-left:20px;transition:color 0.2s;}
.nav-links a:hover,.nav-links a.active{color:#F07600;}
.nav-user{display:flex;align-items:center;gap:10px;}
.nav-avatar{width:34px;height:34px;background:#F07600;border-radius:50%;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:14px;}
.content{max-width:680px;margin:32px auto;padding:0 20px;}
.page-title{font-size:21px;font-weight:700;color:#1a1a2e;margin-bottom:20px;}
.page-title span{color:#F07600;}
.alert{padding:12px 16px;border-radius:10px;font-size:13px;margin-bottom:20px;display:flex;align-items:center;gap:10px;}
.alert.success{background:#DCFCE7;border:1px solid #BBF7D0;color:#16A34A;}
.alert.error{background:#FEE2E2;border:1px solid #FECACA;color:#DC2626;}
.card{background:#fff;border-radius:16px;border:1px solid #E5E7EB;box-shadow:0 2px 12px rgba(0,0,0,0.05);overflow:hidden;}
.card-header{background:linear-gradient(135deg,#F07600,#ff9a3c);padding:22px 28px;color:#fff;}
.card-header h3{font-size:17px;font-weight:700;margin-bottom:4px;}
.card-header p{font-size:12px;opacity:0.85;}
.card-body{padding:28px;}
.field{margin-bottom:20px;}
.field label{display:block;font-size:12px;font-weight:600;color:#6B7280;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:7px;}
.input-wrap{position:relative;}
.input-wrap i{position:absolute;left:13px;top:50%;transform:translateY(-50%);color:#9CA3AF;font-size:13px;}
.field input,.field select{width:100%;padding:12px 14px 12px 38px;border:1.5px solid #E5E7EB;border-radius:10px;font-size:14px;color:#1a1a2e;background:#fff;font-family:inherit;transition:border-color 0.2s,box-shadow 0.2s;}
.field input:focus,.field select:focus{outline:none;border-color:#F07600;box-shadow:0 0 0 3px rgba(240,118,0,0.1);}
.grid-2{display:grid;grid-template-columns:1fr 1fr;gap:16px;}
.info-box{background:#FFF8F2;border:1px solid #FDDBB4;border-radius:10px;padding:14px 16px;margin-bottom:20px;}
.info-box p{font-size:12.5px;color:#92400E;display:flex;align-items:center;gap:8px;margin-bottom:4px;}
.info-box p:last-child{margin-bottom:0;}
.calc-result{background:linear-gradient(135deg,#FFF8F2,#FFF0DC);border:1px solid #FDDBB4;border-radius:12px;padding:16px;display:grid;grid-template-columns:repeat(3,1fr);gap:10px;text-align:center;margin-bottom:20px;}
.calc-item label{font-size:11px;color:#92400E;text-transform:uppercase;letter-spacing:0.5px;display:block;margin-bottom:4px;}
.calc-item span{font-size:17px;font-weight:700;color:#1a1a2e;}
.calc-item span.big{color:#F07600;font-size:20px;}
.btn-submit{width:100%;padding:13px;border:none;border-radius:10px;background:linear-gradient(135deg,#F07600,#ff9a3c);color:#fff;font-size:15px;font-weight:700;cursor:pointer;font-family:inherit;box-shadow:0 4px 16px rgba(240,118,0,0.3);transition:all 0.2s;}
.btn-submit:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(240,118,0,0.4);}
.back-link{display:block;text-align:center;margin-top:14px;font-size:13px;color:#6B7280;text-decoration:none;}
.back-link:hover{color:#F07600;}
@media(max-width:768px){.content{padding:0 12px;margin:20px auto;}.page-title{font-size:18px;}.grid-2{grid-template-columns:1fr;gap:10px;}.card-body{padding:20px;}.calc-result{grid-template-columns:1fr;gap:8px;}.navbar{padding:0 14px;}.nav-links a{margin-left:10px;font-size:12px;}}
@media(max-width:480px){.content{padding:0 8px;}.page-title{font-size:16px;}.card-header{padding:16px 18px;}.card-header h3{font-size:15px;}.btn-submit{font-size:14px;padding:12px;}.nav-links{display:none;}}
</style>
</head>
<body>
<nav class="navbar">
  <div class="nav-logo"><span>A</span> Apex Saving Bank</div>
  <div class="nav-links">
    <a href="dashboard.jsp">Dashboard</a>
    <a href="openAccount.jsp" class="active">Open RD</a>
    <a href="history.jsp">History</a>
  </div>
  <div class="nav-user">
    <div class="nav-avatar"><%= customer.getName().charAt(0) %></div>
    <span style="font-size:13px;font-weight:600;color:#1a1a2e;"><%= customer.getName() %></span>
    <a href="LogoutServlet" style="font-size:12px;color:#EF4444;margin-left:8px;text-decoration:none;"><i class="fas fa-sign-out-alt"></i></a>
  </div>
</nav>

<div class="content">
  <div class="page-title">Open <span>RD Account</span></div>

  <% if (msg != null) {
    boolean isSuccess = msg.startsWith("success:");
    String msgText = msg.substring(msg.indexOf(":") + 1); %>
    <div class="alert <%= isSuccess ? "success" : "error" %>">
      <i class="fas fa-<%= isSuccess ? "check-circle" : "exclamation-circle" %>"></i>
      <%= msgText %>
    </div>
  <% } %>

  <div class="card">
    <div class="card-header">
      <h3><i class="fas fa-plus-circle"></i> &nbsp;New Recurring Deposit</h3>
      <p>Start saving monthly with Apex Saving Bank RD &mdash; Interest Rate: 7.5% p.a.</p>
    </div>
    <div class="card-body">
      <div class="info-box">
        <p><i class="fas fa-info-circle"></i> Minimum monthly deposit: ₹500</p>
        <p><i class="fas fa-info-circle"></i> Minimum duration: 6 months | Maximum: 120 months</p>
        <p><i class="fas fa-info-circle"></i> Interest compounded quarterly at 7.5% p.a.</p>
      </div>
      <div class="calc-result" id="calcBox">
        <div class="calc-item"><label>Total Invested</label><span id="rTotal">₹0</span></div>
        <div class="calc-item"><label>Interest Earned</label><span id="rInterest">₹0</span></div>
        <div class="calc-item"><label>Maturity Amount</label><span class="big" id="rMaturity">₹0</span></div>
      </div>
      <form action="RDAccountServlet" method="post">
        <div class="grid-2">
          <div class="field">
            <label>Monthly Amount (₹)</label>
            <div class="input-wrap">
              <i class="fas fa-rupee-sign"></i>
              <input type="number" name="amount" id="fAmount" placeholder="e.g. 5000" min="500" required oninput="calc()"/>
            </div>
          </div>
          <div class="field">
            <label>Duration (Months)</label>
            <div class="input-wrap">
              <i class="fas fa-calendar-alt"></i>
              <input type="number" name="months" id="fMonths" placeholder="e.g. 12" min="6" max="120" required oninput="calc()"/>
            </div>
          </div>
        </div>
        <div class="field">
          <label>Monthly Due Date (1-28)</label>
          <div class="input-wrap">
            <i class="fas fa-calendar-day"></i>
            <input type="number" name="due_day" placeholder="e.g. 5" min="1" max="28" required/>
          </div>
        </div>
        <button type="submit" class="btn-submit"><i class="fas fa-piggy-bank"></i> &nbsp;Open RD Account</button>
      </form>
      <a href="dashboard.jsp" class="back-link"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
    </div>
  </div>
</div>

<script>
function calc(){
  var P=parseFloat(document.getElementById('fAmount').value)||0;
  var n=parseInt(document.getElementById('fMonths').value)||0;
  var r=7.5;
  var interest=P*n*(n+1)/2*r/1200;
  var total=P*n;var maturity=total+interest;
  var fmt=function(v){return '₹'+v.toLocaleString('en-IN',{maximumFractionDigits:0});};
  document.getElementById('rTotal').textContent=fmt(total);
  document.getElementById('rInterest').textContent=fmt(interest);
  document.getElementById('rMaturity').textContent=fmt(maturity);
}
</script>
</body>
</html>
