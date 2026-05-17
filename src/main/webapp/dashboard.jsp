<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Customer, java.sql.*, controller.DBConnection" %>
<%
    Customer customer = (Customer) session.getAttribute("customer");
    if (customer == null) { response.sendRedirect("login.jsp"); return; }

    String customerName = customer.getName();
    String customerId   = "XXXX" + customer.getId();
    String username     = customer.getUsername();
    int    userId       = customer.getId();

    Connection con = DBConnection.getConnection();

    String userFullName = "", userMobile = "", userEmail = "";
    PreparedStatement psU = con.prepareStatement("SELECT full_name, mobile, email FROM users WHERE id=?");
    psU.setInt(1, userId);
    ResultSet rsU = psU.executeQuery();
    if(rsU.next()) {
        userFullName = rsU.getString("full_name") != null ? rsU.getString("full_name") : "";
        userMobile   = rsU.getString("mobile")    != null ? rsU.getString("mobile")    : "";
        userEmail    = rsU.getString("email")      != null ? rsU.getString("email")     : "";
    }

    int totalAccounts = 0, activeCount = 0, maturedCount = 0;
    double totalDeposited = 0, totalMaturity = 0;
    PreparedStatement ps0 = con.prepareStatement(
        "SELECT COUNT(*) as total, " +
        "SUM(CASE WHEN status='Active' THEN 1 ELSE 0 END) as active_c, " +
        "SUM(CASE WHEN status='Matured' THEN 1 ELSE 0 END) as mat_c, " +
        "COALESCE(SUM(total_deposited),0) as tot_dep, " +
        "COALESCE(SUM(maturity_amount),0) as tot_mat " +
        "FROM rd_account WHERE username=?"
    );
    ps0.setString(1, username);
    ResultSet rs0 = ps0.executeQuery();
    if (rs0.next()) {
        totalAccounts  = rs0.getInt("total");
        activeCount    = rs0.getInt("active_c");
        maturedCount   = rs0.getInt("mat_c");
        totalDeposited = rs0.getDouble("tot_dep");
        totalMaturity  = rs0.getDouble("tot_mat");
    }

    String nextDueDate = "\u2014"; double nextDueAmt = 0;
    PreparedStatement psN = con.prepareStatement(
        "SELECT amount, due_day FROM rd_account WHERE username=? AND status='Active' ORDER BY due_day LIMIT 1"
    );
    psN.setString(1, username);
    ResultSet rsN = psN.executeQuery();
    if (rsN.next()) {
        nextDueAmt  = rsN.getDouble("amount");
        nextDueDate = rsN.getInt("due_day") + " (this month)";
    }

    PreparedStatement psT = con.prepareStatement(
        "SELECT * FROM rd_account WHERE username=? ORDER BY account_id DESC"
    );
    psT.setString(1, username);
    ResultSet rsT = psT.executeQuery();

    StringBuilder tableRows = new StringBuilder();
    boolean hasRows = false;

    while (rsT.next()) {
        hasRows = true;
        int accId     = rsT.getInt("account_id");
        String accNo  = rsT.getString("account_no");
        double amount = rsT.getDouble("amount");
        int months    = rsT.getInt("months");
        double rate   = rsT.getDouble("interest_rate");
        double matAmt = rsT.getDouble("maturity_amount");
        String status = rsT.getString("status");
        PreparedStatement psTxn = con.prepareStatement("SELECT COUNT(*) FROM transactions WHERE account_id=?");
        psTxn.setInt(1, accId);
        ResultSet rsTxn = psTxn.executeQuery();
        int txnCount = rsTxn.next() ? rsTxn.getInt(1) : 0;
        int pct = (months > 0) ? Math.min(100, (int)((txnCount * 100.0) / months)) : 0;
        String sc = status != null ? status.toLowerCase() : "active";
        String accDisplay = (accNo != null && !accNo.isEmpty()) ? accNo : "APXRD-" + accId;
        tableRows.append("<tr data-status='").append(sc).append("'>");
        tableRows.append("<td><span class='acct-badge'><i class='fas fa-university'></i> ").append(accDisplay).append("</span></td>");
        tableRows.append("<td><span class='amount-cell'>₹").append(String.format("%,.0f", amount)).append("</span></td>");
        tableRows.append("<td>").append(months).append(" Months</td>");
        tableRows.append("<td><span style='color:var(--orange);font-weight:700;'>").append(rate).append("%</span></td>");
        tableRows.append("<td><span style='color:var(--success);font-weight:700;'>₹").append(String.format("%,.0f", matAmt)).append("</span></td>");
        tableRows.append("<td><div class='progress-wrap'><div class='progress-label'><span>").append(txnCount).append("/").append(months).append("</span><span>").append(pct).append("%</span></div><div class='progress-bar'><div class='progress-fill' style='width:").append(pct).append("%'></div></div></div></td>");
        tableRows.append("<td><span class='status-badge ").append(sc).append("'>").append(status).append("</span></td>");
        tableRows.append("<td><div class='action-btns'>");
        if ("Active".equalsIgnoreCase(status)) tableRows.append("<a href='deposit.jsp?account_id=").append(accId).append("' class='action-btn pay'><i class='fas fa-credit-card'></i> Pay</a>");
        tableRows.append("<a href='history.jsp' class='action-btn hist'><i class='fas fa-history'></i></a></div></td></tr>");
    }
    con.close();

    String profileMsg = (String) session.getAttribute("profileMsg");
    if(profileMsg != null) session.removeAttribute("profileMsg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Apex Saving Bank &ndash; Dashboard</title>
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
:root{--orange:#F07600;--orange-dark:#D96A00;--orange-light:#FFF3E6;--red:#C8102E;--dark:#1A1A2E;--gray:#6B7280;--border:#E5E7EB;--white:#FFFFFF;--success:#16A34A;--blue:#3B82F6;--purple:#8B5CF6;}
body{font-family:'Source Sans 3',sans-serif;background:#F0F2F5;color:var(--dark);min-height:100vh;}
.top-bar{background:var(--red);color:white;font-size:12px;padding:6px 24px;display:flex;justify-content:space-between;align-items:center;}
.top-bar a{color:white;text-decoration:none;margin-left:16px;opacity:0.9;cursor:pointer;transition:opacity 0.2s;}
.top-bar a:hover{opacity:1;text-decoration:underline;}
.main-header{background:var(--white);padding:0 24px;display:flex;align-items:center;justify-content:space-between;height:64px;box-shadow:0 2px 8px rgba(0,0,0,0.08);position:sticky;top:0;z-index:100;}
.icici-logo{display:flex;align-items:center;gap:8px;}
.logo-icon{width:44px;height:44px;background:var(--orange);border-radius:8px;display:flex;align-items:center;justify-content:center;color:white;font-size:20px;font-weight:800;}
.logo-text{font-size:18px;font-weight:700;color:var(--red);}
.logo-sub{font-size:10px;color:var(--gray);letter-spacing:2px;text-transform:uppercase;display:block;}
.header-nav{display:flex;gap:4px;}
.nav-link{text-decoration:none;color:#374151;font-size:13px;font-weight:500;padding:8px 14px;border-radius:6px;transition:all 0.2s;cursor:pointer;border:none;background:none;font-family:inherit;display:flex;align-items:center;gap:5px;}
.nav-link:hover,.nav-link.active{background:var(--orange-light);color:var(--orange);font-weight:600;}
.header-right{display:flex;align-items:center;gap:12px;}
.user-chip{display:flex;align-items:center;gap:8px;background:var(--orange-light);border:1px solid #FDDBB4;padding:6px 14px 6px 8px;border-radius:24px;cursor:pointer;transition:all 0.2s;user-select:none;}
.user-chip:hover{background:#FDDBB4;box-shadow:0 2px 8px rgba(240,118,0,0.2);}
.user-avatar{width:28px;height:28px;background:var(--orange);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:12px;font-weight:700;}
.user-name{font-size:13px;font-weight:600;}
.logout-btn{background:var(--orange);color:white;border:none;padding:8px 16px;border-radius:6px;font-size:13px;font-weight:600;cursor:pointer;font-family:inherit;}
.logout-btn:hover{background:var(--orange-dark);}
.sub-nav{background:var(--white);border-bottom:1px solid var(--border);padding:0 24px;display:flex;}
.sub-nav a{text-decoration:none;font-size:13px;font-weight:500;color:var(--gray);padding:12px 18px;border-bottom:3px solid transparent;transition:all 0.2s;display:flex;align-items:center;gap:6px;}
.sub-nav a.active{color:var(--orange);border-bottom-color:var(--orange);font-weight:600;}
.sub-nav a:hover{color:var(--orange);background:var(--orange-light);}
.breadcrumb{background:#F5F5F5;padding:10px 24px;font-size:12px;color:var(--gray);}
.breadcrumb span{color:var(--orange);}
.main-content{max-width:1200px;margin:24px auto;padding:0 24px;}
.page-title-row{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;}
.page-title{font-size:22px;font-weight:700;}
.page-title span{color:var(--orange);}
.open-rd-btn{background:var(--orange);color:white;border:none;padding:10px 22px;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer;display:flex;align-items:center;gap:8px;font-family:inherit;transition:all 0.2s;text-decoration:none;}
.open-rd-btn:hover{background:var(--orange-dark);transform:translateY(-1px);}
.summary-cards{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:24px;}
.summary-card{background:var(--white);border-radius:12px;padding:20px;border:1px solid var(--border);position:relative;overflow:hidden;transition:all 0.2s;}
.summary-card::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;background:var(--orange);}
.summary-card:hover{box-shadow:0 4px 16px rgba(0,0,0,0.08);transform:translateY(-2px);}
.card-icon{position:absolute;top:16px;right:16px;width:40px;height:40px;background:var(--orange-light);border-radius:10px;display:flex;align-items:center;justify-content:center;color:var(--orange);font-size:18px;}
.card-label{font-size:12px;color:var(--gray);font-weight:500;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:8px;}
.card-value{font-size:24px;font-weight:700;margin-bottom:4px;}
.card-value.green{color:var(--success);}
.card-value.orange{color:var(--orange);}
.card-sub{font-size:12px;color:var(--gray);}
.section-card{background:var(--white);border-radius:12px;border:1px solid var(--border);overflow:hidden;margin-bottom:24px;scroll-margin-top:80px;}
.section-header{padding:18px 24px;border-bottom:1px solid var(--border);display:flex;justify-content:space-between;align-items:center;}
.section-title{font-size:16px;font-weight:700;display:flex;align-items:center;gap:8px;}
.section-title i{color:var(--orange);}
.filter-row{display:flex;gap:8px;}
.filter-btn{padding:6px 14px;border-radius:20px;border:1px solid var(--border);background:var(--white);font-size:12px;font-weight:500;cursor:pointer;color:var(--gray);font-family:inherit;transition:all 0.2s;}
.filter-btn.active,.filter-btn:hover{background:var(--orange);color:white;border-color:var(--orange);}
.rd-table{width:100%;border-collapse:collapse;}
.rd-table thead tr{background:#FFF8F2;}
.rd-table th{padding:12px 16px;font-size:12px;font-weight:600;color:var(--gray);text-align:left;text-transform:uppercase;letter-spacing:0.5px;border-bottom:1px solid var(--border);}
.rd-table td{padding:14px 16px;font-size:13.5px;border-bottom:1px solid #F3F4F6;vertical-align:middle;}
.rd-table tr:last-child td{border-bottom:none;}
.rd-table tbody tr:hover{background:#FFFAF5;}
.acct-badge{display:inline-flex;align-items:center;gap:6px;font-weight:600;font-size:13px;}
.acct-badge i{color:var(--orange);}
.amount-cell{font-weight:700;font-size:14px;}
.status-badge{display:inline-flex;align-items:center;gap:5px;padding:4px 10px;border-radius:20px;font-size:12px;font-weight:600;}
.status-badge.active{background:#DCFCE7;color:#16A34A;}
.status-badge.active::before{content:'';width:6px;height:6px;background:#16A34A;border-radius:50%;}
.status-badge.matured{background:#DBEAFE;color:#1D4ED8;}
.status-badge.matured::before{content:'';width:6px;height:6px;background:#1D4ED8;border-radius:50%;}
.status-badge.closed{background:#FEE2E2;color:#DC2626;}
.progress-wrap{min-width:120px;}
.progress-label{font-size:11px;color:var(--gray);margin-bottom:4px;display:flex;justify-content:space-between;}
.progress-bar{height:6px;background:#E5E7EB;border-radius:4px;overflow:hidden;}
.progress-fill{height:100%;background:linear-gradient(90deg,var(--orange),#FF9A3C);border-radius:4px;}
.action-btns{display:flex;gap:6px;}
.action-btn{padding:6px 12px;border-radius:6px;font-size:12px;font-weight:600;cursor:pointer;border:none;font-family:inherit;transition:all 0.2s;text-decoration:none;display:inline-flex;align-items:center;gap:4px;}
.action-btn.pay{background:var(--orange-light);color:var(--orange);}
.action-btn.pay:hover{background:var(--orange);color:white;}
.action-btn.hist{background:#F5F3FF;color:#7C3AED;}
.action-btn.hist:hover{background:#7C3AED;color:white;}
.empty-state{text-align:center;padding:48px;color:var(--gray);}
.empty-state i{font-size:40px;color:#D1D5DB;margin-bottom:12px;display:block;}
.calc-body{padding:20px 24px;}
.calc-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:16px;}
.input-group{display:flex;flex-direction:column;gap:6px;}
.input-label{font-size:12px;font-weight:600;color:var(--gray);text-transform:uppercase;letter-spacing:0.5px;}
.icici-input{padding:10px 14px;border:1.5px solid var(--border);border-radius:8px;font-size:14px;font-family:inherit;background:var(--white);}
.icici-input:focus{outline:none;border-color:var(--orange);}
.calc-result{background:linear-gradient(135deg,var(--orange-light),#FFF0DC);border:1px solid #FDDBB4;border-radius:10px;padding:16px;display:grid;grid-template-columns:repeat(3,1fr);gap:12px;text-align:center;}
.calc-res-label{font-size:11px;color:var(--gray);margin-bottom:4px;text-transform:uppercase;}
.calc-res-value{font-size:18px;font-weight:700;}
.calc-res-value.highlight{color:var(--orange);font-size:20px;}
.nav-info-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;padding:24px;}
.nic{background:#F9FAFB;border-radius:12px;padding:18px;border:1px solid var(--border);transition:all 0.2s;}
.nic:hover{border-color:var(--orange);box-shadow:0 4px 16px rgba(240,118,0,0.1);transform:translateY(-2px);}
.nic-icon{width:42px;height:42px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:18px;margin-bottom:12px;}
.nic h5{font-size:14px;font-weight:700;margin-bottom:6px;color:var(--dark);}
.nic p{font-size:12px;color:var(--gray);line-height:1.55;margin-bottom:10px;}
.nic .tag{display:inline-block;padding:3px 10px;border-radius:20px;font-size:10px;font-weight:700;}
.info-grid-3{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;padding:24px;}
.icard{border-radius:12px;padding:22px;border:1px solid var(--border);}
.icard-icon{width:48px;height:48px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:20px;margin-bottom:14px;}
.icard h4{font-size:15px;font-weight:700;margin-bottom:8px;}
.icard p{font-size:13px;color:var(--gray);line-height:1.6;margin-bottom:12px;}
.icard .row{display:flex;align-items:center;gap:8px;font-size:13px;margin-bottom:6px;}
.icard .row i{color:var(--orange);width:16px;text-align:center;}
.ibtn{display:inline-flex;align-items:center;gap:6px;padding:9px 18px;border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;border:none;font-family:inherit;transition:all 0.2s;text-decoration:none;margin-top:8px;}
.ibtn.solid{background:var(--orange);color:white;}
.ibtn.solid:hover{background:var(--orange-dark);}
.ibtn.outline{background:none;border:1.5px solid var(--border);color:var(--dark);}
.ibtn.outline:hover{border-color:var(--orange);color:var(--orange);}
.footer{background:var(--dark);color:#9CA3AF;text-align:center;padding:16px;font-size:12px;margin-top:32px;}
.footer strong{color:var(--orange);}
.toast{position:fixed;top:80px;right:20px;background:var(--dark);color:white;padding:12px 20px;border-radius:8px;font-size:13px;font-weight:500;border-left:4px solid var(--orange);box-shadow:0 4px 20px rgba(0,0,0,0.2);transform:translateX(120%);transition:transform 0.3s;z-index:999;}
.toast.show{transform:translateX(0);}
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.5);z-index:500;justify-content:center;align-items:center;padding:20px;}
.modal-overlay.show{display:flex;}
.modal-box{background:var(--white);border-radius:20px;width:100%;max-width:480px;overflow:hidden;box-shadow:0 20px 60px rgba(0,0,0,0.25);}
.modal-head{background:linear-gradient(135deg,var(--dark),#2d3561);padding:24px;display:flex;justify-content:space-between;align-items:center;}
.modal-head h3{color:white;font-size:17px;font-weight:700;display:flex;align-items:center;gap:8px;}
.modal-head h3 i{color:var(--orange);}
.modal-close-btn{background:rgba(255,255,255,0.1);border:none;color:white;width:32px;height:32px;border-radius:8px;cursor:pointer;font-size:16px;display:flex;align-items:center;justify-content:center;transition:background 0.2s;}
.modal-close-btn:hover{background:rgba(255,255,255,0.2);}
.profile-avatar-section{display:flex;align-items:center;gap:16px;padding:24px 24px 0;}
.profile-big-avatar{width:64px;height:64px;background:var(--orange);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:26px;font-weight:700;flex-shrink:0;}
.profile-info-text h4{font-size:16px;font-weight:700;color:var(--dark);margin-bottom:2px;}
.profile-info-text p{font-size:13px;color:var(--gray);}
.profile-info-text .cid{font-size:11px;background:var(--orange-light);color:var(--orange);padding:2px 10px;border-radius:12px;font-weight:600;display:inline-block;margin-top:4px;}
.profile-tabs{display:flex;border-bottom:1px solid var(--border);margin:20px 24px 0;gap:0;}
.profile-tab{flex:1;text-align:center;padding:10px;font-size:13px;font-weight:600;color:var(--gray);cursor:pointer;border-bottom:3px solid transparent;transition:all 0.2s;}
.profile-tab.active{color:var(--orange);border-bottom-color:var(--orange);}
.tab-content{display:none;padding:20px 24px;}
.tab-content.active{display:block;}
.form-group{margin-bottom:16px;}
.form-label{display:block;font-size:11px;font-weight:700;color:var(--gray);text-transform:uppercase;letter-spacing:0.5px;margin-bottom:6px;}
.form-input{width:100%;padding:10px 14px;border:1.5px solid var(--border);border-radius:8px;font-size:14px;font-family:inherit;color:var(--dark);transition:border-color 0.2s;}
.form-input:focus{outline:none;border-color:var(--orange);}
.form-input:disabled{background:#F9FAFB;color:var(--gray);}
.input-note{font-size:11px;color:var(--gray);margin-top:4px;}
.pass-wrap{position:relative;}
.pass-wrap .form-input{padding-right:40px;}
.pass-toggle{position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;color:var(--gray);font-size:14px;}
.save-btn{width:100%;background:var(--orange);color:white;border:none;padding:12px;border-radius:8px;font-size:14px;font-weight:700;cursor:pointer;font-family:inherit;transition:background 0.2s;margin-top:4px;}
.save-btn:hover{background:var(--orange-dark);}
.success-msg{background:#DCFCE7;color:#16A34A;border:1px solid #BBF7D0;border-radius:8px;padding:10px 14px;font-size:13px;font-weight:600;margin-bottom:16px;display:none;}
.error-msg{background:#FEE2E2;color:#DC2626;border:1px solid #FECACA;border-radius:8px;padding:10px 14px;font-size:13px;font-weight:600;margin-bottom:16px;display:none;}
@media(max-width:768px){.summary-cards,.nav-info-grid,.info-grid-3{grid-template-columns:1fr 1fr;}.header-nav{display:none;}}
</style>
</head>
<body>

<div class="top-bar">
  <span>&#128274; Secured Banking Portal &nbsp;|&nbsp; Customer ID: <%= customerId %></span>
  <div>
    <a onclick="goTo('helpSection')"><i class="fas fa-question-circle"></i> Help</a>
    <a onclick="goTo('locateSection')"><i class="fas fa-map-marker-alt"></i> Locate Us</a>
    <a onclick="goTo('downloadSection')"><i class="fas fa-download"></i> Download App</a>
  </div>
</div>

<header class="main-header">
  <div class="icici-logo">
    <div class="logo-icon">A</div>
    <div><div class="logo-text">Apex Saving Bank</div><span class="logo-sub">Internet Banking</span></div>
  </div>
  <nav class="header-nav">
    <button class="nav-link" onclick="goTo('accountsSection',this)"><i class="fas fa-wallet"></i> Accounts</button>
    <button class="nav-link" onclick="goTo('cardsSection',this)"><i class="fas fa-credit-card"></i> Cards</button>
    <button class="nav-link active" onclick="goTo('depositsSection',this)"><i class="fas fa-layer-group"></i> Deposits</button>
    <button class="nav-link" onclick="goTo('loansSection',this)"><i class="fas fa-hand-holding-usd"></i> Loans</button>
    <button class="nav-link" onclick="goTo('investmentsSection',this)"><i class="fas fa-chart-line"></i> Investments</button>
  </nav>
  <div class="header-right">
    <div class="user-chip" onclick="openProfileModal()" title="Click to edit profile">
      <div class="user-avatar"><%= customerName.charAt(0) %></div>
      <span class="user-name"><%= customerName %></span>
      <i class="fas fa-caret-down" style="font-size:11px;color:var(--orange);margin-left:2px;"></i>
    </div>
    <button class="logout-btn" onclick="window.location='LogoutServlet'"><i class="fas fa-sign-out-alt"></i> Logout</button>
  </div>
</header>

<nav class="sub-nav">
  <a href="dashboard.jsp" class="active"><i class="fas fa-home"></i> Overview</a>
  <a href="openAccount.jsp"><i class="fas fa-plus-circle"></i> Open RD</a>
  <a href="selectAccount.jsp"><i class="fas fa-credit-card"></i> Pay Installment</a>
  <a href="history.jsp"><i class="fas fa-history"></i> History</a>
</nav>
<div class="breadcrumb">Home &gt; <span>Recurring Deposit Dashboard</span></div>

<div class="main-content">
  <div id="depositsSection" style="scroll-margin-top:80px;">
    <div class="page-title-row">
      <div class="page-title">Recurring <span>Deposit</span> Accounts</div>
      <a href="openAccount.jsp" class="open-rd-btn"><i class="fas fa-plus-circle"></i> Open New RD</a>
    </div>
    <div class="summary-cards">
      <div class="summary-card"><div class="card-icon"><i class="fas fa-layer-group"></i></div><div class="card-label">Total RD Accounts</div><div class="card-value"><%= totalAccounts %></div><div class="card-sub"><%= activeCount %> Active &bull; <%= maturedCount %> Matured</div></div>
      <div class="summary-card"><div class="card-icon"><i class="fas fa-rupee-sign"></i></div><div class="card-label">Total Deposited</div><div class="card-value orange">₹<%= String.format("%,.0f", totalDeposited) %></div><div class="card-sub">Across all accounts</div></div>
      <div class="summary-card"><div class="card-icon"><i class="fas fa-coins"></i></div><div class="card-label">Total Maturity Value</div><div class="card-value green">₹<%= String.format("%,.0f", totalMaturity) %></div><div class="card-sub">At 7.5% p.a.</div></div>
      <div class="summary-card"><div class="card-icon"><i class="fas fa-calendar-check"></i></div><div class="card-label">Next Installment</div><div class="card-value" style="font-size:18px;"><%= nextDueDate %></div><div class="card-sub"><% if(nextDueAmt>0){%>₹<%= String.format("%,.0f",nextDueAmt) %> due<%}else{%>No active RD<%}%></div></div>
    </div>
    <div class="section-card">
      <div class="section-header">
        <div class="section-title"><i class="fas fa-sync-alt"></i> My RD Accounts</div>
        <div class="filter-row">
          <button class="filter-btn active" onclick="filterTable(this,'all')">All</button>
          <button class="filter-btn" onclick="filterTable(this,'active')">Active</button>
          <button class="filter-btn" onclick="filterTable(this,'matured')">Matured</button>
          <button class="filter-btn" onclick="filterTable(this,'closed')">Closed</button>
        </div>
      </div>
      <% if (!hasRows) { %><div class="empty-state"><i class="fas fa-inbox"></i>No RD accounts yet.<br><a href="openAccount.jsp" style="color:var(--orange);font-weight:600;">Open your first RD &#8594;</a></div>
      <% } else { %>
      <table class="rd-table"><thead><tr><th>Account No.</th><th>Monthly Amt</th><th>Tenure</th><th>Interest</th><th>Maturity Amt</th><th>Progress</th><th>Status</th><th>Actions</th></tr></thead><tbody id="rdTableBody"><%= tableRows %></tbody></table>
      <% } %>
    </div>
    <div class="section-card">
      <div class="section-header"><div class="section-title"><i class="fas fa-calculator"></i> RD Interest Calculator</div><span style="font-size:12px;color:var(--gray);">Plan your savings</span></div>
      <div class="calc-body">
        <div class="calc-grid">
          <div class="input-group"><label class="input-label">Monthly Investment (₹)</label><input type="number" id="calcAmount" class="icici-input" value="5000" oninput="calculate()"/></div>
          <div class="input-group"><label class="input-label">Duration (Months)</label><input type="number" id="calcMonths" class="icici-input" value="12" oninput="calculate()"/></div>
          <div class="input-group"><label class="input-label">Interest Rate (% p.a.)</label><input type="number" id="calcRate" class="icici-input" value="7.5" step="0.1" oninput="calculate()"/></div>
          <div class="input-group"><label class="input-label">Compounding</label><select class="icici-input"><option>Quarterly</option><option>Monthly</option></select></div>
        </div>
        <div class="calc-result">
          <div><div class="calc-res-label">Total Invested</div><div class="calc-res-value" id="totalInvested">₹60,000</div></div>
          <div><div class="calc-res-label">Interest Earned</div><div class="calc-res-value" style="color:var(--success)" id="interestEarned">₹2,471</div></div>
          <div><div class="calc-res-label">Maturity Amount</div><div class="calc-res-value highlight" id="maturityAmount">₹62,471</div></div>
        </div>
      </div>
    </div>
  </div>

  <div class="section-card" id="accountsSection" style="scroll-margin-top:80px;">
    <div class="section-header"><div class="section-title"><i class="fas fa-wallet"></i> Accounts</div></div>
    <div class="nav-info-grid">
      <div class="nic"><div class="nic-icon" style="background:#FFF3E6;color:var(--orange);"><i class="fas fa-piggy-bank"></i></div><h5>Savings Account</h5><p>Earn up to 4% p.a. interest. Free unlimited ATM transactions.</p><span class="tag" style="background:#FFF3E6;color:var(--orange);">4% p.a.</span></div>
      <div class="nic"><div class="nic-icon" style="background:#EFF6FF;color:var(--blue);"><i class="fas fa-briefcase"></i></div><h5>Current Account</h5><p>Built for businesses. No daily transaction limits.</p><span class="tag" style="background:#EFF6FF;color:var(--blue);">Business</span></div>
      <div class="nic"><div class="nic-icon" style="background:#F0FDF4;color:var(--success);"><i class="fas fa-exchange-alt"></i></div><h5>Fund Transfer</h5><p>Send money via NEFT, RTGS, IMPS 24x7. Zero charges.</p><span class="tag" style="background:#F0FDF4;color:var(--success);">Free</span></div>
    </div>
  </div>

  <div class="section-card" id="cardsSection" style="scroll-margin-top:80px;">
    <div class="section-header"><div class="section-title"><i class="fas fa-credit-card"></i> Cards &amp; Payments</div></div>
    <div class="nav-info-grid">
      <div class="nic"><div class="nic-icon" style="background:#FFF3E6;color:var(--orange);"><i class="fas fa-sim-card"></i></div><h5>Debit Card</h5><p>Apex Saving Bank Visa Debit Card accepted worldwide.</p><span class="tag" style="background:#FFF3E6;color:var(--orange);">Worldwide</span></div>
      <div class="nic"><div class="nic-icon" style="background:#EFF6FF;color:var(--blue);"><i class="fas fa-credit-card"></i></div><h5>Credit Card</h5><p>Up to 50 days interest-free credit.</p><span class="tag" style="background:#EFF6FF;color:var(--blue);">50 Days Free</span></div>
      <div class="nic"><div class="nic-icon" style="background:#F0FDF4;color:var(--success);"><i class="fas fa-mobile-alt"></i></div><h5>Virtual Card</h5><p>Generate a virtual card for safe online shopping.</p><span class="tag" style="background:#F0FDF4;color:var(--success);">Secure</span></div>
    </div>
  </div>

  <div class="section-card" id="loansSection" style="scroll-margin-top:80px;">
    <div class="section-header"><div class="section-title"><i class="fas fa-hand-holding-usd"></i> Loans &amp; Credit</div></div>
    <div class="nav-info-grid">
      <div class="nic"><div class="nic-icon" style="background:#FFF3E6;color:var(--orange);"><i class="fas fa-home"></i></div><h5>Home Loan</h5><p>Up to ₹5 Crore. Rates from 8.5% p.a.</p><span class="tag" style="background:#FFF3E6;color:var(--orange);">From 8.5%</span></div>
      <div class="nic"><div class="nic-icon" style="background:#EFF6FF;color:var(--blue);"><i class="fas fa-car"></i></div><h5>Car Loan</h5><p>Up to ₹50L. Quick approval in 24 hours.</p><span class="tag" style="background:#EFF6FF;color:var(--blue);">24hr Approval</span></div>
      <div class="nic"><div class="nic-icon" style="background:#F5F3FF;color:var(--purple);"><i class="fas fa-rupee-sign"></i></div><h5>Personal Loan</h5><p>Get up to ₹25L instantly.</p><span class="tag" style="background:#F5F3FF;color:var(--purple);">Instant</span></div>
    </div>
  </div>

  <div class="section-card" id="investmentsSection" style="scroll-margin-top:80px;">
    <div class="section-header"><div class="section-title"><i class="fas fa-chart-line"></i> Investments &amp; Wealth</div></div>
    <div class="nav-info-grid">
      <div class="nic"><div class="nic-icon" style="background:#FFF3E6;color:var(--orange);"><i class="fas fa-chart-pie"></i></div><h5>Mutual Funds</h5><p>Start SIP from just ₹500/month.</p><span class="tag" style="background:#FFF3E6;color:var(--orange);">SIP ₹500+</span></div>
      <div class="nic"><div class="nic-icon" style="background:#EFF6FF;color:var(--blue);"><i class="fas fa-chart-bar"></i></div><h5>Stocks &amp; Equity</h5><p>Trade in NSE &amp; BSE. Zero brokerage.</p><span class="tag" style="background:#EFF6FF;color:var(--blue);">Zero Brokerage</span></div>
      <div class="nic"><div class="nic-icon" style="background:#F5F3FF;color:var(--purple);"><i class="fas fa-coins"></i></div><h5>Digital Gold</h5><p>Buy 24K pure gold from just ₹1.</p><span class="tag" style="background:#F5F3FF;color:var(--purple);">From ₹1</span></div>
    </div>
  </div>

  <div class="section-card" id="helpSection" style="scroll-margin-top:80px;">
    <div class="section-header"><div class="section-title"><i class="fas fa-question-circle"></i> Help &amp; Support</div></div>
    <div class="info-grid-3">
      <div class="icard" style="background:#FFF3E6;border-color:#FDDBB4;"><div class="icard-icon" style="background:var(--orange);color:white;"><i class="fas fa-phone-alt"></i></div><h4>Call Us</h4><p>Talk to our banking experts anytime.</p><div class="row"><i class="fas fa-headset"></i><strong>1800-XXX-XXXX</strong></div><div class="row"><i class="fas fa-clock"></i> 24x7, 365 days</div><a href="tel:1800XXXXXXX" class="ibtn solid"><i class="fas fa-phone"></i> Call Now</a></div>
      <div class="icard" style="background:#EFF6FF;border-color:#BFDBFE;"><div class="icard-icon" style="background:var(--blue);color:white;"><i class="fas fa-comments"></i></div><h4>Live Chat &amp; Email</h4><p>Get instant answers from our team.</p><div class="row"><i class="fas fa-envelope"></i> support@apexsavingbank.in</div><div class="row"><i class="fas fa-reply"></i> Reply within 2 hours</div><a href="mailto:support@apexsavingbank.in" class="ibtn outline"><i class="fas fa-envelope"></i> Send Email</a></div>
      <div class="icard" style="background:#F0FDF4;border-color:#BBF7D0;"><div class="icard-icon" style="background:var(--success);color:white;"><i class="fas fa-book-open"></i></div><h4>FAQs &amp; Guides</h4><p>Find answers to common questions.</p><div class="row"><i class="fas fa-question"></i> How to open RD?</div><div class="row"><i class="fas fa-question"></i> How to pay installment?</div><a href="#" class="ibtn outline"><i class="fas fa-external-link-alt"></i> View FAQs</a></div>
    </div>
  </div>

  <div class="section-card" id="locateSection" style="scroll-margin-top:80px;">
    <div class="section-header"><div class="section-title"><i class="fas fa-map-marker-alt"></i> Locate Us</div></div>
    <div class="info-grid-3">
      <div class="icard" style="background:#FFF3E6;border-color:#FDDBB4;"><div class="icard-icon" style="background:var(--orange);color:white;"><i class="fas fa-university"></i></div><h4>Branch Locator</h4><p>Find the nearest Apex Saving Bank branch.</p><div class="row"><i class="fas fa-map-pin"></i> 500+ branches across India</div><div class="row"><i class="fas fa-clock"></i> Mon&ndash;Sat: 9:30 AM &ndash; 4:00 PM</div><a href="#" class="ibtn solid"><i class="fas fa-search-location"></i> Find Branch</a></div>
      <div class="icard" style="background:#EFF6FF;border-color:#BFDBFE;"><div class="icard-icon" style="background:var(--blue);color:white;"><i class="fas fa-money-bill-wave"></i></div><h4>ATM Locator</h4><p>Find 24x7 ATMs near you.</p><div class="row"><i class="fas fa-map-pin"></i> 2000+ ATMs nationwide</div><div class="row"><i class="fas fa-clock"></i> Open 24 hours</div><a href="#" class="ibtn outline"><i class="fas fa-search-location"></i> Find ATM</a></div>
      <div class="icard" style="background:#F0FDF4;border-color:#BBF7D0;"><div class="icard-icon" style="background:var(--success);color:white;"><i class="fas fa-video"></i></div><h4>Video Banking</h4><p>Talk to a banker from your home.</p><div class="row"><i class="fas fa-video"></i> HD video call</div><div class="row"><i class="fas fa-clock"></i> Mon&ndash;Sat: 9 AM &ndash; 6 PM</div><a href="#" class="ibtn outline"><i class="fas fa-video"></i> Start Video Call</a></div>
    </div>
  </div>

  <div class="section-card" id="downloadSection" style="scroll-margin-top:80px;">
    <div class="section-header"><div class="section-title"><i class="fas fa-download"></i> Download Apex Saving Bank App</div></div>
    <div class="info-grid-3">
      <div class="icard" style="background:#1a1a2e;border-color:#2d2d4e;"><div class="icard-icon" style="background:#2d2d4e;color:#3DDC84;font-size:24px;"><i class="fab fa-android"></i></div><h4 style="color:white;">Android App</h4><p style="color:#9CA3AF;">Available on Google Play Store.</p><div class="row" style="color:#9CA3AF;"><i class="fas fa-star" style="color:#FFD700;"></i> 4.8 Rating &middot; 2L+ reviews</div><a href="#" class="ibtn solid" style="margin-top:12px;"><i class="fab fa-google-play"></i> Google Play</a></div>
      <div class="icard" style="background:#1a1a2e;border-color:#2d2d4e;"><div class="icard-icon" style="background:#2d2d4e;color:#A2AAAD;font-size:24px;"><i class="fab fa-apple"></i></div><h4 style="color:white;">iOS App</h4><p style="color:#9CA3AF;">Available on Apple App Store.</p><div class="row" style="color:#9CA3AF;"><i class="fas fa-star" style="color:#FFD700;"></i> 4.7 Rating &middot; 80K+ reviews</div><a href="#" class="ibtn solid" style="margin-top:12px;"><i class="fab fa-app-store-ios"></i> App Store</a></div>
      <div class="icard" style="background:var(--orange-light);border-color:#FDDBB4;"><div class="icard-icon" style="background:var(--orange);color:white;"><i class="fas fa-mobile-alt"></i></div><h4>App Features</h4><p>Everything in one powerful app.</p><div class="row"><i class="fas fa-check" style="color:var(--success);"></i> Check balance &amp; statements</div><div class="row"><i class="fas fa-check" style="color:var(--success);"></i> Pay RD installments</div><div class="row"><i class="fas fa-check" style="color:var(--success);"></i> UPI &amp; fund transfers</div></div>
    </div>
  </div>
</div>

<div class="footer">&copy; 2026 <strong>Apex Saving Bank</strong> &nbsp;|&nbsp; Secure Digital Banking &nbsp;|&nbsp;
  <a href="#" style="color:var(--orange);text-decoration:none;">Privacy Policy</a> &nbsp;|&nbsp;
  <a href="#" style="color:var(--orange);text-decoration:none;">Terms &amp; Conditions</a>
</div>
<div class="toast" id="toast"></div>

<!-- PROFILE MODAL -->
<div class="modal-overlay" id="profileModal">
  <div class="modal-box">
    <div class="modal-head">
      <h3><i class="fas fa-user-circle"></i> My Profile</h3>
      <button class="modal-close-btn" onclick="closeProfileModal()"><i class="fas fa-times"></i></button>
    </div>
    <div class="profile-avatar-section">
      <div class="profile-big-avatar"><%= customerName.charAt(0) %></div>
      <div class="profile-info-text">
        <h4><%= userFullName.isEmpty() ? customerName : userFullName %></h4>
        <p>@<%= username %></p>
        <span class="cid">Customer ID: <%= customerId %></span>
      </div>
    </div>
    <div class="profile-tabs">
      <div class="profile-tab active" onclick="switchTab('infoTab', this)"><i class="fas fa-id-card"></i> Info &amp; Mobile</div>
      <div class="profile-tab" onclick="switchTab('passTab', this)"><i class="fas fa-lock"></i> Change Password</div>
    </div>
    <div class="tab-content active" id="infoTab">
      <div class="success-msg" id="infoSuccess">&#9989; Profile updated successfully!</div>
      <div class="error-msg" id="infoError"></div>
      <form method="post" action="UpdateProfileServlet" onsubmit="return validateInfo()">
        <input type="hidden" name="type" value="info"/>
        <div class="form-group">
          <label class="form-label">Username</label>
          <input class="form-input" type="text" value="@<%= username %>" disabled/>
          <div class="input-note">Username cannot be changed</div>
        </div>
        <div class="form-group">
          <label class="form-label">Full Name</label>
          <input class="form-input" type="text" name="full_name" value="<%= userFullName %>" placeholder="Enter your full name"/>
        </div>
        <div class="form-group">
          <label class="form-label">Mobile Number</label>
          <input class="form-input" type="tel" name="mobile" id="mobileInput" value="<%= userMobile %>" placeholder="10-digit mobile number" maxlength="10"/>
          <div class="input-note">Used for OTP and notifications</div>
        </div>
        <div class="form-group">
          <label class="form-label">Email Address</label>
          <input class="form-input" type="email" name="email" value="<%= userEmail %>" placeholder="your@email.com"/>
        </div>
        <button type="submit" class="save-btn"><i class="fas fa-save"></i> Save Changes</button>
      </form>
    </div>
    <div class="tab-content" id="passTab">
      <div class="success-msg" id="passSuccess">&#9989; Password changed successfully!</div>
      <div class="error-msg" id="passError"></div>
      <form method="post" action="UpdateProfileServlet" onsubmit="return validatePass()">
        <input type="hidden" name="type" value="password"/>
        <div class="form-group">
          <label class="form-label">Current Password</label>
          <div class="pass-wrap">
            <input class="form-input" type="password" name="old_password" id="oldPass" placeholder="Enter current password"/>
            <button type="button" class="pass-toggle" onclick="togglePass('oldPass', this)"><i class="fas fa-eye"></i></button>
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">New Password</label>
          <div class="pass-wrap">
            <input class="form-input" type="password" name="new_password" id="newPass" placeholder="Min 6 characters"/>
            <button type="button" class="pass-toggle" onclick="togglePass('newPass', this)"><i class="fas fa-eye"></i></button>
          </div>
        </div>
        <div class="form-group">
          <label class="form-label">Confirm New Password</label>
          <div class="pass-wrap">
            <input class="form-input" type="password" name="confirm_password" id="confirmPass" placeholder="Re-enter new password"/>
            <button type="button" class="pass-toggle" onclick="togglePass('confirmPass', this)"><i class="fas fa-eye"></i></button>
          </div>
        </div>
        <button type="submit" class="save-btn"><i class="fas fa-key"></i> Change Password</button>
      </form>
    </div>
  </div>
</div>

<script>
function openProfileModal(){document.getElementById('profileModal').classList.add('show');}
function closeProfileModal(){document.getElementById('profileModal').classList.remove('show');}
document.getElementById('profileModal').addEventListener('click',function(e){if(e.target===this)closeProfileModal();});
function switchTab(tabId,el){
  document.querySelectorAll('.tab-content').forEach(function(t){t.classList.remove('active');});
  document.querySelectorAll('.profile-tab').forEach(function(t){t.classList.remove('active');});
  document.getElementById(tabId).classList.add('active');el.classList.add('active');
}
function togglePass(inputId,btn){
  var input=document.getElementById(inputId);var icon=btn.querySelector('i');
  if(input.type==='password'){input.type='text';icon.className='fas fa-eye-slash';}
  else{input.type='password';icon.className='fas fa-eye';}
}
function validateInfo(){
  var mob=document.getElementById('mobileInput').value.trim();
  if(mob&&!/^\d{10}$/.test(mob)){
    document.getElementById('infoError').style.display='block';
    document.getElementById('infoError').textContent='Mobile number must be exactly 10 digits!';return false;
  }return true;
}
function validatePass(){
  var np=document.getElementById('newPass').value;var cp=document.getElementById('confirmPass').value;
  var errEl=document.getElementById('passError');
  if(np.length<6){errEl.style.display='block';errEl.textContent='New password must be at least 6 characters!';return false;}
  if(np!==cp){errEl.style.display='block';errEl.textContent='Passwords do not match!';return false;}
  errEl.style.display='none';return true;
}
<% if(profileMsg != null) { %>
  showToast('<%= profileMsg %>');openProfileModal();
<% } %>
function goTo(id,btn){
  var el=document.getElementById(id);if(el)el.scrollIntoView({behavior:'smooth',block:'start'});
  if(btn){document.querySelectorAll('.nav-link').forEach(function(b){b.classList.remove('active');});btn.classList.add('active');}
}
function filterTable(btn,status){
  document.querySelectorAll('.filter-btn').forEach(function(b){b.classList.remove('active');});btn.classList.add('active');
  document.querySelectorAll('#rdTableBody tr').forEach(function(row){
    row.style.display=(status==='all'||row.dataset.status===status)?'':'none';
  });
}
function calculate(){
  var P=parseFloat(document.getElementById('calcAmount').value)||0;
  var n=parseInt(document.getElementById('calcMonths').value)||0;
  var r=parseFloat(document.getElementById('calcRate').value)||0;
  var interest=P*n*(n+1)/2*r/1200;var total=P*n;var maturity=total+interest;
  var fmt=function(v){return '₹'+v.toLocaleString('en-IN',{maximumFractionDigits:0});};
  document.getElementById('totalInvested').textContent=fmt(total);
  document.getElementById('interestEarned').textContent=fmt(interest);
  document.getElementById('maturityAmount').textContent=fmt(maturity);
}
calculate();
function showToast(msg){var t=document.getElementById('toast');t.textContent='\u2713 '+msg;t.classList.add('show');setTimeout(function(){t.classList.remove('show');},3000);}
</script>
</body>
</html>
