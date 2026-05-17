<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*,controller.DBConnection" %>
<%
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) { response.sendRedirect("login.jsp"); return; }

    String action = request.getParameter("action");
    if (action != null) {
        Connection ac = DBConnection.getConnection();
        try {
            if ("deleteUser".equals(action)) {
                int uid = Integer.parseInt(request.getParameter("uid"));
                PreparedStatement p0 = ac.prepareStatement("DELETE FROM transactions WHERE account_id IN (SELECT account_id FROM rd_account WHERE user_id=?)");
                p0.setInt(1, uid); p0.executeUpdate();
                PreparedStatement p1 = ac.prepareStatement("DELETE FROM rd_account WHERE user_id=?");
                p1.setInt(1, uid); p1.executeUpdate();
                PreparedStatement p2 = ac.prepareStatement("DELETE FROM users WHERE id=?");
                p2.setInt(1, uid); p2.executeUpdate();

            } else if ("updateUser".equals(action)) {
                PreparedStatement ps = ac.prepareStatement(
                    "UPDATE users SET full_name=?,mobile=?,email=?,account_no=?,ifsc=?,bank_name=? WHERE id=?");
                ps.setString(1, request.getParameter("full_name"));
                ps.setString(2, request.getParameter("mobile"));
                ps.setString(3, request.getParameter("email"));
                ps.setString(4, request.getParameter("account_no"));
                ps.setString(5, request.getParameter("ifsc"));
                ps.setString(6, request.getParameter("bank_name"));
                ps.setInt(7, Integer.parseInt(request.getParameter("uid")));
                ps.executeUpdate();

            } else if ("deleteRD".equals(action)) {
                int aid = Integer.parseInt(request.getParameter("aid"));
                PreparedStatement p1 = ac.prepareStatement("DELETE FROM transactions WHERE account_id=?");
                p1.setInt(1, aid); p1.executeUpdate();
                PreparedStatement p2 = ac.prepareStatement("DELETE FROM rd_account WHERE account_id=?");
                p2.setInt(1, aid); p2.executeUpdate();

            } else if ("updateRD".equals(action)) {
                int aid = Integer.parseInt(request.getParameter("aid"));
                PreparedStatement ps = ac.prepareStatement(
                    "UPDATE rd_account SET amount=?,months=?,interest_rate=?,status=?,total_deposited=? WHERE account_id=?");
                ps.setDouble(1, Double.parseDouble(request.getParameter("amount")));
                ps.setInt(2, Integer.parseInt(request.getParameter("months")));
                ps.setDouble(3, Double.parseDouble(request.getParameter("interest_rate")));
                ps.setString(4, request.getParameter("status"));
                ps.setDouble(5, Double.parseDouble(request.getParameter("total_deposited")));
                ps.setInt(6, aid);
                ps.executeUpdate();
            }
        } catch(Exception e) { e.printStackTrace(); }
        finally { try { ac.close(); } catch(Exception ignored){} }
        response.sendRedirect("adminDashboard.jsp");
        return;
    }

    Connection con = DBConnection.getConnection();
    int totalUsers = 0, totalRD = 0, activeRD = 0;
    double totalDeposit = 0;
    ResultSet r1 = con.prepareStatement("SELECT COUNT(*) FROM users WHERE role='user'").executeQuery();
    if(r1.next()) totalUsers = r1.getInt(1);
    ResultSet r2 = con.prepareStatement("SELECT COUNT(*) FROM rd_account").executeQuery();
    if(r2.next()) totalRD = r2.getInt(1);
    ResultSet r3 = con.prepareStatement("SELECT COUNT(*) FROM rd_account WHERE status='Active'").executeQuery();
    if(r3.next()) activeRD = r3.getInt(1);
    ResultSet r4 = con.prepareStatement("SELECT COALESCE(SUM(amount),0) FROM transactions").executeQuery();
    if(r4.next()) totalDeposit = r4.getDouble(1);
    ResultSet rsU = con.prepareStatement("SELECT * FROM users WHERE role='user' ORDER BY id DESC").executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
<title>Apex Saving Bank - Admin Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
*{margin:0;padding:0;box-sizing:border-box;font-family:'Inter',sans-serif;}
body{background:#F0F2F5;min-height:100vh;}
.navbar{background:#0F172A;padding:0 28px;height:60px;display:flex;align-items:center;justify-content:space-between;}
.nav-logo{font-size:16px;font-weight:700;color:#fff;display:flex;align-items:center;gap:10px;}
.nav-logo-icon{background:linear-gradient(135deg,#1E40AF,#3B82F6);color:#fff;border-radius:8px;width:34px;height:34px;display:inline-flex;align-items:center;justify-content:center;font-size:16px;}
.nav-logo-text{color:#fff;font-size:16px;font-weight:700;}
.nav-logo-text span{color:#3B82F6;}
.admin-badge{background:rgba(59,130,246,0.15);color:#3B82F6;border:1px solid rgba(59,130,246,0.3);padding:4px 12px;border-radius:20px;font-size:12px;font-weight:600;}
.logout-btn{background:rgba(239,68,68,0.15);color:#EF4444;border:1px solid rgba(239,68,68,0.3);padding:6px 14px;border-radius:8px;font-size:13px;text-decoration:none;font-weight:600;}
.content{max-width:1200px;margin:28px auto;padding:0 20px;}
.page-title{font-size:21px;font-weight:700;color:#1a1a2e;margin-bottom:20px;}
.page-title em{color:#3B82F6;font-style:normal;}
.stats{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:28px;}
.stat-card{background:#fff;border-radius:14px;padding:20px;border:1px solid #E5E7EB;position:relative;overflow:hidden;transition:all 0.2s;}
.stat-card:hover{transform:translateY(-2px);box-shadow:0 4px 16px rgba(0,0,0,0.08);}
.stat-card::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;}
.stat-card.orange::before{background:#F07600;}.stat-card.blue::before{background:#3B82F6;}
.stat-card.green::before{background:#16A34A;}.stat-card.purple::before{background:#8B5CF6;}
.stat-icon{position:absolute;top:16px;right:16px;width:38px;height:38px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:16px;}
.stat-card.orange .stat-icon{background:#FFF3E6;color:#F07600;}.stat-card.blue .stat-icon{background:#EFF6FF;color:#3B82F6;}
.stat-card.green .stat-icon{background:#F0FDF4;color:#16A34A;}.stat-card.purple .stat-icon{background:#F5F3FF;color:#8B5CF6;}
.stat-label{font-size:12px;color:#9CA3AF;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:6px;}
.stat-value{font-size:26px;font-weight:700;color:#1a1a2e;}
.table-card{background:#fff;border-radius:14px;border:1px solid #E5E7EB;overflow:hidden;box-shadow:0 2px 10px rgba(0,0,0,0.04);margin-bottom:24px;}
.table-header{padding:18px 22px;border-bottom:1px solid #E5E7EB;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px;}
.table-title{font-size:15px;font-weight:700;color:#1a1a2e;display:flex;align-items:center;gap:8px;}
.table-title i{color:#3B82F6;}
.search-input{padding:8px 14px;border:1.5px solid #E5E7EB;border-radius:8px;font-size:13px;width:220px;}
.search-input:focus{outline:none;border-color:#3B82F6;}
table{width:100%;border-collapse:collapse;}
th{padding:10px 16px;font-size:11px;font-weight:600;color:#9CA3AF;text-transform:uppercase;background:#F9FAFB;text-align:left;border-bottom:1px solid #E5E7EB;}
td{padding:11px 16px;font-size:13px;color:#374151;border-bottom:1px solid #F3F4F6;vertical-align:middle;}
tr:last-child td{border-bottom:none;}
.user-row:hover td{background:#EFF6FF;cursor:pointer;}
.role-badge{padding:3px 10px;border-radius:12px;font-size:11px;font-weight:600;background:#EFF6FF;color:#3B82F6;}
.btn-edit{background:#EFF6FF;color:#2563EB;border:none;padding:5px 11px;border-radius:6px;font-size:12px;font-weight:600;cursor:pointer;transition:all 0.2s;}
.btn-edit:hover{background:#2563EB;color:white;}
.btn-del{background:#FEF2F2;color:#DC2626;border:none;padding:5px 11px;border-radius:6px;font-size:12px;font-weight:600;cursor:pointer;transition:all 0.2s;}
.btn-del:hover{background:#DC2626;color:white;}
.btn-view{background:#F0FDF4;color:#16A34A;border:none;padding:5px 11px;border-radius:6px;font-size:12px;font-weight:600;cursor:pointer;transition:all 0.2s;}
.btn-view:hover{background:#16A34A;color:white;}
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.55);z-index:200;justify-content:center;align-items:flex-start;padding:30px 20px;overflow-y:auto;}
.modal-overlay.show{display:flex;}
.modal-box{background:#fff;border-radius:18px;width:100%;max-width:780px;margin:auto;overflow:hidden;box-shadow:0 20px 60px rgba(0,0,0,0.3);}
.modal-head{background:linear-gradient(135deg,#0F172A,#1E40AF);padding:20px 24px;display:flex;justify-content:space-between;align-items:center;}
.modal-head h3{font-size:16px;font-weight:700;color:#fff;display:flex;align-items:center;gap:8px;}
.modal-head h3 i{color:#3B82F6;}
.modal-close{background:rgba(255,255,255,0.1);border:none;color:white;width:32px;height:32px;border-radius:8px;cursor:pointer;font-size:16px;}
.modal-close:hover{background:rgba(255,255,255,0.2);}
.modal-body{padding:24px;}
.info-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:20px;}
.info-item label{display:block;font-size:11px;font-weight:600;color:#9CA3AF;text-transform:uppercase;margin-bottom:4px;}
.info-item span{font-size:14px;font-weight:600;color:#1a1a2e;}
.edit-input{width:100%;padding:8px 12px;border:1.5px solid #E5E7EB;border-radius:8px;font-size:13px;color:#1a1a2e;}
.edit-input:focus{outline:none;border-color:#3B82F6;}
.modal-section{font-size:12px;font-weight:700;color:#3B82F6;text-transform:uppercase;letter-spacing:1px;padding:12px 0 8px;border-bottom:1px solid #F3F4F6;margin-bottom:14px;}
.rd-mini-table{width:100%;border-collapse:collapse;font-size:13px;}
.rd-mini-table th{padding:8px 12px;font-size:11px;font-weight:600;color:#9CA3AF;text-transform:uppercase;background:#F9FAFB;text-align:left;}
.rd-mini-table td{padding:10px 12px;border-bottom:1px solid #F3F4F6;vertical-align:middle;}
.rd-mini-table tr:last-child td{border-bottom:none;}
.modal-footer{padding:16px 24px;border-top:1px solid #E5E7EB;display:flex;justify-content:flex-end;gap:10px;background:#FAFAFA;}
.btn-save{background:linear-gradient(135deg,#1E40AF,#3B82F6);color:white;border:none;padding:9px 22px;border-radius:8px;font-size:13px;font-weight:700;cursor:pointer;}
.btn-save:hover{opacity:0.9;}
.btn-cancel{background:#E5E7EB;color:#374151;border:none;padding:9px 18px;border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;}
.no-rd{text-align:center;padding:28px;color:#9CA3AF;}
.no-rd i{font-size:28px;display:block;margin-bottom:8px;}
</style>
</head>
<body>

<nav class="navbar">
  <div class="nav-logo">
    <div class="nav-logo-icon"><i class="fas fa-university"></i></div>
    <div class="nav-logo-text">Apex <span>Saving</span> Bank</div>
  </div>
  <div style="display:flex;align-items:center;gap:12px;">
    <span class="admin-badge"><i class="fas fa-shield-alt"></i> Admin Panel</span>
    <a href="LogoutServlet" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
  </div>
</nav>

<div class="content">
  <div class="page-title">Admin <em>Dashboard</em></div>
  <div class="stats">
    <div class="stat-card orange"><div class="stat-icon"><i class="fas fa-users"></i></div><div class="stat-label">Total Users</div><div class="stat-value"><%= totalUsers %></div></div>
    <div class="stat-card blue"><div class="stat-icon"><i class="fas fa-layer-group"></i></div><div class="stat-label">Total RD Accounts</div><div class="stat-value"><%= totalRD %></div></div>
    <div class="stat-card green"><div class="stat-icon"><i class="fas fa-check-circle"></i></div><div class="stat-label">Active RD</div><div class="stat-value"><%= activeRD %></div></div>
    <div class="stat-card purple"><div class="stat-icon"><i class="fas fa-rupee-sign"></i></div><div class="stat-label">Total Collections</div><div class="stat-value" style="font-size:20px;">&#8377;<%= String.format("%.0f",totalDeposit) %></div></div>
  </div>

  <div class="table-card">
    <div class="table-header">
      <div class="table-title"><i class="fas fa-users"></i> All Customers
        <span style="background:#EFF6FF;color:#3B82F6;padding:2px 10px;border-radius:12px;font-size:12px;margin-left:8px;"><%= totalUsers %></span>
      </div>
      <input type="text" class="search-input" placeholder="Search users..." oninput="searchTable(this.value)"/>
    </div>
    <table id="userTable">
      <thead><tr>
        <th>#</th><th>Full Name</th><th>Username</th><th>Mobile</th><th>Email</th><th>Account No</th><th>Role</th><th>Actions</th>
      </tr></thead>
      <tbody>
<%
  int sno = 1;
  while(rsU.next()) {
    int    uid   = rsU.getInt("id");
    String uname = rsU.getString("username")   != null ? rsU.getString("username")   : "";
    String fname = rsU.getString("full_name")  != null ? rsU.getString("full_name")  : "";
    String mob   = rsU.getString("mobile")     != null ? rsU.getString("mobile")     : "";
    String eml   = rsU.getString("email")      != null ? rsU.getString("email")      : "";
    String acno  = rsU.getString("account_no") != null ? rsU.getString("account_no") : "";
    String ifsc  = rsU.getString("ifsc")       != null ? rsU.getString("ifsc")       : "";
    String bnm   = rsU.getString("bank_name")  != null ? rsU.getString("bank_name")  : "";
    String urole = rsU.getString("role")       != null ? rsU.getString("role")       : "";
    String fnameJ = fname.replace("\\","\\\\").replace("'","\\'");
    String mobJ   = mob.replace("\\","\\\\").replace("'","\\'");
    String emlJ   = eml.replace("\\","\\\\").replace("'","\\'");
    String acnoJ  = acno.replace("\\","\\\\").replace("'","\\'");
    String ifscJ  = ifsc.replace("\\","\\\\").replace("'","\\'");
    String bnmJ   = bnm.replace("\\","\\\\").replace("'","\\'");
    String unameJ = uname.replace("\\","\\\\").replace("'","\\'");
%>
      <tr class="user-row" onclick="openUserModal(<%= uid %>,'<%= unameJ %>','<%= fnameJ %>','<%= mobJ %>','<%= emlJ %>','<%= acnoJ %>','<%= ifscJ %>','<%= bnmJ %>')">
        <td style="color:#9CA3AF;"><%= sno++ %></td>
        <td><strong><i class="fas fa-user-circle" style="color:#3B82F6;margin-right:6px;"></i><%= fname.isEmpty() ? uname : fname %></strong></td>
        <td style="color:#3B82F6;font-weight:600;">@<%= uname %></td>
        <td><%= mob.isEmpty() ? "&#8212;" : mob %></td>
        <td><%= eml.isEmpty() ? "&#8212;" : eml %></td>
        <td style="font-family:monospace;font-size:12px;"><%= acno.isEmpty() ? "&#8212;" : acno %></td>
        <td><span class="role-badge"><%= urole %></span></td>
        <td onclick="event.stopPropagation()">
          <div style="display:flex;gap:6px;">
            <button class="btn-view" onclick="openUserModal(<%= uid %>,'<%= unameJ %>','<%= fnameJ %>','<%= mobJ %>','<%= emlJ %>','<%= acnoJ %>','<%= ifscJ %>','<%= bnmJ %>')"><i class="fas fa-eye"></i> View</button>
            <button class="btn-edit" onclick="openEditUser(<%= uid %>,'<%= fnameJ %>','<%= mobJ %>','<%= emlJ %>','<%= acnoJ %>','<%= ifscJ %>','<%= bnmJ %>')"><i class="fas fa-edit"></i></button>
            <button class="btn-del" onclick="confirmDeleteUser(<%= uid %>,'<%= unameJ %>','<%= fnameJ %>')"><i class="fas fa-trash"></i></button>
          </div>
        </td>
      </tr>
<% } con.close(); %>
      </tbody>
    </table>
  </div>
</div>

<!-- USER DETAIL MODAL -->
<div class="modal-overlay" id="userModal">
  <div class="modal-box">
    <div class="modal-head">
      <h3><i class="fas fa-user-circle"></i> <span id="modalUserTitle">User Details</span></h3>
      <button class="modal-close" onclick="closeModal('userModal')"><i class="fas fa-times"></i></button>
    </div>
    <div class="modal-body">
      <div class="modal-section"><i class="fas fa-id-card"></i> &nbsp;Personal Information</div>
      <div class="info-grid">
        <div class="info-item"><label>Full Name</label><span id="mu_name"></span></div>
        <div class="info-item"><label>Username</label><span id="mu_uname" style="color:#3B82F6;"></span></div>
        <div class="info-item"><label>Mobile</label><span id="mu_mobile"></span></div>
        <div class="info-item"><label>Email</label><span id="mu_email"></span></div>
        <div class="info-item"><label>Account No</label><span id="mu_accno"></span></div>
        <div class="info-item"><label>IFSC</label><span id="mu_ifsc"></span></div>
        <div class="info-item" style="grid-column:1/-1"><label>Bank Name</label><span id="mu_bank"></span></div>
      </div>
      <div class="modal-section"><i class="fas fa-sync-alt"></i> &nbsp;RD Accounts</div>
      <div id="rdAccountsArea"><div class="no-rd"><i class="fas fa-spinner fa-spin"></i> Loading...</div></div>
    </div>
  </div>
</div>

<!-- EDIT USER MODAL -->
<div class="modal-overlay" id="editUserModal">
  <div class="modal-box">
    <div class="modal-head">
      <h3><i class="fas fa-edit"></i> Edit User</h3>
      <button class="modal-close" onclick="closeModal('editUserModal')"><i class="fas fa-times"></i></button>
    </div>
    <form method="post" action="adminDashboard.jsp">
      <input type="hidden" name="action" value="updateUser"/>
      <input type="hidden" name="uid" id="eu_uid"/>
      <div class="modal-body">
        <div class="info-grid">
          <div class="info-item"><label>Full Name</label><input class="edit-input" name="full_name" id="eu_name"/></div>
          <div class="info-item"><label>Mobile</label><input class="edit-input" name="mobile" id="eu_mobile"/></div>
          <div class="info-item"><label>Email</label><input class="edit-input" name="email" id="eu_email"/></div>
          <div class="info-item"><label>Account No</label><input class="edit-input" name="account_no" id="eu_accno"/></div>
          <div class="info-item"><label>IFSC</label><input class="edit-input" name="ifsc" id="eu_ifsc"/></div>
          <div class="info-item"><label>Bank Name</label><input class="edit-input" name="bank_name" id="eu_bank"/></div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn-cancel" onclick="closeModal('editUserModal')">Cancel</button>
        <button type="submit" class="btn-save"><i class="fas fa-save"></i> Save Changes</button>
      </div>
    </form>
  </div>
</div>

<!-- EDIT RD MODAL -->
<div class="modal-overlay" id="editRDModal">
  <div class="modal-box">
    <div class="modal-head">
      <h3><i class="fas fa-sync-alt"></i> Edit RD Account</h3>
      <button class="modal-close" onclick="closeModal('editRDModal')"><i class="fas fa-times"></i></button>
    </div>
    <form method="post" action="adminDashboard.jsp">
      <input type="hidden" name="action" value="updateRD"/>
      <input type="hidden" name="aid" id="er_aid"/>
      <div class="modal-body">
        <div class="info-grid">
          <div class="info-item"><label>Monthly Amount (&#8377;)</label><input class="edit-input" name="amount" id="er_amount" type="number" step="0.01"/></div>
          <div class="info-item"><label>Duration (Months)</label><input class="edit-input" name="months" id="er_months" type="number"/></div>
          <div class="info-item"><label>Interest Rate (%)</label><input class="edit-input" name="interest_rate" id="er_rate" type="number" step="0.1"/></div>
          <div class="info-item"><label>Total Deposited (&#8377;)</label><input class="edit-input" name="total_deposited" id="er_dep" type="number" step="0.01"/></div>
          <div class="info-item" style="grid-column:1/-1"><label>Status</label>
            <select class="edit-input" name="status" id="er_status">
              <option value="Active">Active</option>
              <option value="Matured">Matured</option>
              <option value="Closed">Closed</option>
            </select>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn-cancel" onclick="closeModal('editRDModal')">Cancel</button>
        <button type="submit" class="btn-save"><i class="fas fa-save"></i> Update RD</button>
      </div>
    </form>
  </div>
</div>

<!-- HIDDEN DELETE FORMS -->
<form id="deleteUserForm" method="post" action="adminDashboard.jsp" style="display:none">
  <input type="hidden" name="action" value="deleteUser"/>
  <input type="hidden" name="uid" id="du_uid"/>
</form>
<form id="deleteRDForm" method="post" action="adminDashboard.jsp" style="display:none">
  <input type="hidden" name="action" value="deleteRD"/>
  <input type="hidden" name="aid" id="dr_aid"/>
</form>

<script>
var rdData = {};
<%
Connection rc2 = DBConnection.getConnection();
ResultSet rrs2 = rc2.prepareStatement(
  "SELECT account_id, user_id, account_no, amount, months, interest_rate, maturity_amount, total_deposited, status FROM rd_account ORDER BY account_id DESC"
).executeQuery();
while(rrs2.next()) {
  int    rdUid = rrs2.getInt("user_id");
  int    aid2  = rrs2.getInt("account_id");
  String acNo2 = rrs2.getString("account_no")     != null ? rrs2.getString("account_no").replace("\\","\\\\").replace("'","\\'") : "MYRD-"+aid2;
  double amt2  = rrs2.getDouble("amount");
  int    mon2  = rrs2.getInt("months");
  double rate2 = rrs2.getDouble("interest_rate");
  double mat2  = rrs2.getDouble("maturity_amount");
  double dep2  = rrs2.getDouble("total_deposited");
  String stat2 = rrs2.getString("status") != null ? rrs2.getString("status") : "Active";
%>
if(!rdData[<%= rdUid %>]) rdData[<%= rdUid %>] = [];
rdData[<%= rdUid %>].push({aid:<%= aid2 %>,accNo:'<%= acNo2 %>',amount:<%= amt2 %>,months:<%= mon2 %>,rate:<%= rate2 %>,matAmt:<%= mat2 %>,totDep:<%= dep2 %>,status:'<%= stat2 %>'});
<% } rc2.close(); %>

function openUserModal(uid, uname, fname, mobile, email, accno, ifsc, bname) {
  document.getElementById('modalUserTitle').textContent = fname || uname;
  document.getElementById('mu_name').textContent   = fname  || '\u2014';
  document.getElementById('mu_uname').textContent  = '@' + uname;
  document.getElementById('mu_mobile').textContent = mobile || '\u2014';
  document.getElementById('mu_email').textContent  = email  || '\u2014';
  document.getElementById('mu_accno').textContent  = accno  || '\u2014';
  document.getElementById('mu_ifsc').textContent   = ifsc   || '\u2014';
  document.getElementById('mu_bank').textContent   = bname  || '\u2014';

  var rdArea   = document.getElementById('rdAccountsArea');
  var accounts = rdData[uid] || [];

  if(accounts.length === 0) {
    rdArea.innerHTML = '<div class="no-rd"><i class="fas fa-inbox"></i>No RD accounts found</div>';
  } else {
    var html = '<table class="rd-mini-table"><thead><tr><th>Account No</th><th>Monthly</th><th>Months</th><th>Rate</th><th>Deposited</th><th>Maturity</th><th>Status</th><th>Actions</th></tr></thead><tbody>';
    for(var i = 0; i < accounts.length; i++) {
      var rd = accounts[i];
      var sc = (rd.status||'').toLowerCase();
      var scColor = sc==='active'?'#16A34A':sc==='matured'?'#1D4ED8':'#DC2626';
      var scBg    = sc==='active'?'#DCFCE7':sc==='matured'?'#DBEAFE':'#FEE2E2';
      html += '<tr>';
      html += '<td style="font-weight:600;font-size:12px;">'+(rd.accNo||'&mdash;')+'</td>';
      html += '<td>&#8377;'+Number(rd.amount).toLocaleString('en-IN')+'</td>';
      html += '<td>'+rd.months+'</td>';
      html += '<td style="color:#3B82F6;font-weight:700;">'+rd.rate+'%</td>';
      html += '<td>&#8377;'+Number(rd.totDep).toLocaleString('en-IN')+'</td>';
      html += '<td style="color:#16A34A;font-weight:700;">&#8377;'+Number(rd.matAmt).toLocaleString('en-IN')+'</td>';
      html += '<td><span style="background:'+scBg+';color:'+scColor+';padding:3px 8px;border-radius:12px;font-size:11px;font-weight:600;">'+rd.status+'</span></td>';
      html += '<td><div style="display:flex;gap:5px;">';
      html += '<button class="btn-edit" onclick="openEditRD('+rd.aid+','+rd.amount+','+rd.months+','+rd.rate+','+rd.totDep+',\''+rd.status+'\')"><i class="fas fa-edit"></i> Edit</button>';
      html += '<button class="btn-del" onclick="confirmDeleteRD('+rd.aid+',\''+(rd.accNo||'')+'\')"><i class="fas fa-trash"></i></button>';
      html += '</div></td></tr>';
    }
    html += '</tbody></table>';
    rdArea.innerHTML = html;
  }
  document.getElementById('userModal').classList.add('show');
}

function openEditUser(uid, fname, mobile, email, accno, ifsc, bname) {
  document.getElementById('eu_uid').value    = uid;
  document.getElementById('eu_name').value   = fname;
  document.getElementById('eu_mobile').value = mobile;
  document.getElementById('eu_email').value  = email;
  document.getElementById('eu_accno').value  = accno;
  document.getElementById('eu_ifsc').value   = ifsc;
  document.getElementById('eu_bank').value   = bname;
  closeModal('userModal');
  document.getElementById('editUserModal').classList.add('show');
}

function openEditRD(aid, amount, months, rate, totDep, status) {
  document.getElementById('er_aid').value    = aid;
  document.getElementById('er_amount').value = amount;
  document.getElementById('er_months').value = months;
  document.getElementById('er_rate').value   = rate;
  document.getElementById('er_dep').value    = totDep;
  document.getElementById('er_status').value = status;
  closeModal('userModal');
  document.getElementById('editRDModal').classList.add('show');
}

function confirmDeleteUser(uid, uname, fname) {
  if(confirm('Delete user "'+fname+'" (@'+uname+')?\n\nAll RD accounts and transactions will also be deleted.\nThis cannot be undone!')) {
    document.getElementById('du_uid').value = uid;
    document.getElementById('deleteUserForm').submit();
  }
}

function confirmDeleteRD(aid, accNo) {
  if(confirm('Delete RD Account "'+accNo+'"?\n\nAll transactions will also be deleted.\nThis cannot be undone!')) {
    document.getElementById('dr_aid').value = aid;
    document.getElementById('deleteRDForm').submit();
  }
}

function closeModal(id) {
  document.getElementById(id).classList.remove('show');
}

document.querySelectorAll('.modal-overlay').forEach(function(m) {
  m.addEventListener('click', function(e) {
    if(e.target === this) this.classList.remove('show');
  });
});

function searchTable(val) {
  document.querySelectorAll('#userTable tbody tr').forEach(function(r) {
    r.style.display = r.textContent.toLowerCase().includes(val.toLowerCase()) ? '' : 'none';
  });
}
</script>
</body>
</html>
