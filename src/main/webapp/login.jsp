<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>MyBank – Login</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
*{margin:0;padding:0;box-sizing:border-box;font-family:'Inter',sans-serif;}
body{min-height:100vh;display:flex;justify-content:center;align-items:center;background:url('bg.jpg') no-repeat center center/cover;position:relative;}
body::before{content:"";position:fixed;inset:0;background:rgba(10,15,40,0.78);z-index:0;}

.wrap{position:relative;z-index:1;width:100%;max-width:420px;padding:20px;}

 
.back-home{display:flex;align-items:center;gap:8px;color:rgba(255,255,255,0.6);font-size:13px;text-decoration:none;margin-bottom:20px;transition:color 0.2s;}
.back-home:hover{color:#F07600;}

.logo-box{text-align:center;margin-bottom:28px;}
.logo-icon{width:58px;height:58px;background:linear-gradient(135deg,#F07600,#ff9a3c);border-radius:16px;display:inline-flex;align-items:center;justify-content:center;font-size:26px;font-weight:800;color:white;margin-bottom:10px;box-shadow:0 8px 24px rgba(240,118,0,0.4);}
.logo-name{font-size:26px;font-weight:700;color:#fff;letter-spacing:1px;}
.logo-sub{font-size:12px;color:#aaa;letter-spacing:3px;text-transform:uppercase;}

.card{background:rgba(255,255,255,0.06);backdrop-filter:blur(20px);border:1px solid rgba(255,255,255,0.12);border-radius:20px;padding:36px 32px;box-shadow:0 20px 60px rgba(0,0,0,0.5);}
.card h2{font-size:20px;font-weight:600;color:#fff;margin-bottom:6px;}
.card p{font-size:13px;color:#999;margin-bottom:24px;}

.alert{padding:10px 14px;border-radius:10px;font-size:13px;margin-bottom:16px;display:flex;align-items:center;gap:8px;}
.alert.error{background:rgba(220,38,38,0.15);border:1px solid rgba(220,38,38,0.3);color:#fca5a5;}
.alert.success{background:rgba(22,163,74,0.15);border:1px solid rgba(22,163,74,0.3);color:#86efac;}

.field{margin-bottom:18px;}
.field label{display:block;font-size:12px;font-weight:600;color:#ccc;text-transform:uppercase;letter-spacing:0.5px;margin-bottom:7px;}
.input-wrap{position:relative;}
.input-wrap i.icon{position:absolute;left:14px;top:50%;transform:translateY(-50%);color:#666;font-size:14px;}
.field input{width:100%;padding:12px 14px 12px 40px;background:rgba(255,255,255,0.08);border:1.5px solid rgba(255,255,255,0.1);border-radius:10px;color:#fff;font-size:14px;transition:border-color 0.2s,box-shadow 0.2s;}
.field input:focus{outline:none;border-color:#F07600;box-shadow:0 0 0 3px rgba(240,118,0,0.15);}
.field input::placeholder{color:#555;}
.toggle-pass{position:absolute;right:14px;top:50%;transform:translateY(-50%);color:#666;cursor:pointer;font-size:14px;background:none;border:none;}
.toggle-pass:hover{color:#F07600;}

.btn-login{width:100%;padding:13px;border:none;border-radius:10px;background:linear-gradient(135deg,#F07600,#ff9a3c);color:white;font-size:15px;font-weight:700;cursor:pointer;transition:all 0.2s;margin-top:4px;font-family:inherit;box-shadow:0 4px 16px rgba(240,118,0,0.3);}
.btn-login:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(240,118,0,0.4);}
.btn-login:disabled{opacity:0.7;cursor:not-allowed;transform:none;}

.forgot{text-align:center;font-size:13px;color:#aaa;cursor:pointer;margin-top:14px;}
.forgot:hover{color:#F07600;}
.register-link{display:block;text-align:center;margin-top:16px;font-size:13px;color:#aaa;text-decoration:none;}
.register-link span{color:#F07600;font-weight:600;}
.register-link:hover span{text-decoration:underline;}
.footer-txt{text-align:center;margin-top:20px;font-size:11px;color:#555;}
 
.step{display:none;}
.step.active{display:block;}

.otp-boxes{display:flex;gap:10px;justify-content:center;margin:20px 0;}
.otp-box{width:48px;height:56px;background:rgba(255,255,255,0.08);border:1.5px solid rgba(255,255,255,0.15);border-radius:10px;color:#fff;font-size:22px;font-weight:700;text-align:center;font-family:'Inter',sans-serif;transition:border-color 0.2s;}
.otp-box:focus{outline:none;border-color:#F07600;box-shadow:0 0 0 3px rgba(240,118,0,0.2);}

.otp-info{background:rgba(59,130,246,0.12);border:1px solid rgba(59,130,246,0.25);border-radius:10px;padding:12px 14px;font-size:13px;color:#93c5fd;margin-bottom:20px;text-align:center;line-height:1.6;}
.otp-info strong{color:#fff;}
#timerDisplay{font-weight:700;color:#F07600;}

.resend-row{text-align:center;margin-top:12px;font-size:13px;color:#777;}
.resend-btn{color:#F07600;cursor:pointer;font-weight:600;background:none;border:none;font-family:inherit;font-size:13px;}
.resend-btn:hover:not(:disabled){text-decoration:underline;}
.resend-btn:disabled{color:#555;cursor:not-allowed;}

.step-back-btn{display:flex;align-items:center;gap:6px;color:#aaa;font-size:13px;cursor:pointer;margin-bottom:20px;background:none;border:none;font-family:inherit;padding:0;}
.step-back-btn:hover{color:#F07600;}

 
.modal{display:none;position:fixed;inset:0;background:rgba(0,0,0,0.75);z-index:100;justify-content:center;align-items:center;}
.modal.show{display:flex;}
.modal-box{background:#1a1d2e;border:1px solid rgba(255,255,255,0.12);border-radius:16px;padding:32px;width:320px;text-align:center;}
.modal-box h3{color:#fff;margin-bottom:20px;font-size:17px;}
.modal-box input{width:100%;padding:11px 14px;margin-bottom:12px;background:rgba(255,255,255,0.07);border:1px solid rgba(255,255,255,0.1);border-radius:8px;color:#fff;font-size:14px;font-family:inherit;}
.modal-box input:focus{outline:none;border-color:#F07600;}
.modal-box button{width:100%;padding:11px;border:none;border-radius:8px;background:linear-gradient(135deg,#F07600,#ff9a3c);color:white;font-weight:600;cursor:pointer;font-family:inherit;font-size:14px;}
.modal-close{color:#F07600;font-size:13px;cursor:pointer;margin-top:12px;display:block;}
</style>
</head>
<body>

<div class="wrap">

 
  <a href="index.html" class="back-home"><i class="fas fa-arrow-left"></i> Back to Home</a>

  <div class="logo-box">
    <div class="logo-icon">A</div>
    <div class="logo-name">Apex Saving Bank</div>
    <div class="logo-sub">Digital Banking Portal</div>
  </div>

  <div class="card">

 
    <div class="step active" id="step1">
      <h2>Welcome Back 👋</h2>
      <p>Sign in to your Apex Saving Bank account</p>

      <%
        String error = request.getParameter("error");
        String msg   = request.getParameter("msg");
        if("badotp".equals(error)) {
      %><div class="alert error"><i class="fas fa-exclamation-circle"></i> Invalid or expired OTP! Please try again.</div><%
        } else if("nouser".equals(error)) {
      %><div class="alert error"><i class="fas fa-exclamation-circle"></i> Invalid username or password!</div><%
        } else if("noemail".equals(error)) {
      %><div class="alert error"><i class="fas fa-exclamation-circle"></i> No email linked to this account. Contact admin.</div><%
        }
        if("success".equals(msg)) {
      %><div class="alert success"><i class="fas fa-check-circle"></i> Registration successful! Please login.</div><%
        }
      %>

      <form id="loginForm" onsubmit="handleLogin(event)">
        <div class="field">
          <label>Username</label>
          <div class="input-wrap">
            <i class="fas fa-user icon"></i>
            <input type="text" id="usernameInput" placeholder="Enter your username" required/>
          </div>
        </div>
        <div class="field">
          <label>Password</label>
          <div class="input-wrap">
            <i class="fas fa-lock icon"></i>
            <input type="password" id="passInput" placeholder="Enter your password" required/>
            <button type="button" class="toggle-pass" onclick="togglePass()"><i class="fas fa-eye" id="eyeIcon"></i></button>
          </div>
        </div>
        <button type="submit" class="btn-login" id="loginBtn">
          <i class="fas fa-paper-plane"></i> &nbsp;Send OTP
        </button>
      </form>

      <div class="forgot" onclick="document.getElementById('forgotModal').classList.add('show')">
        <i class="fas fa-key"></i> Forgot Password?
      </div>
      <a href="register.jsp" class="register-link">New to Apex Saving Bank ? <span>Create Account</span></a>
    </div>

    
    <div class="step" id="step2">
      <button class="step-back-btn" onclick="goBack()"><i class="fas fa-arrow-left"></i> Back</button>
      <h2>OTP Verification 🔐</h2>
      <p style="margin-bottom:16px;">Enter the 6-digit OTP sent to your email</p>

      <div class="otp-info">
        📧 OTP sent to <strong id="maskedEmail">—</strong><br/>
        <span style="font-size:12px;color:rgba(255,255,255,0.5);">Valid for <span id="timerDisplay">5:00</span></span>
      </div>

      <form action="OTPVerifyServlet" method="post">
        <input type="hidden" name="username" id="hiddenUsername"/>
        <div class="otp-boxes">
          <input type="text" class="otp-box" maxlength="1" id="o1" oninput="otpNext(this,'o2')" onkeydown="otpBack(event,this,'')"/>
          <input type="text" class="otp-box" maxlength="1" id="o2" oninput="otpNext(this,'o3')" onkeydown="otpBack(event,this,'o1')"/>
          <input type="text" class="otp-box" maxlength="1" id="o3" oninput="otpNext(this,'o4')" onkeydown="otpBack(event,this,'o2')"/>
          <input type="text" class="otp-box" maxlength="1" id="o4" oninput="otpNext(this,'o5')" onkeydown="otpBack(event,this,'o3')"/>
          <input type="text" class="otp-box" maxlength="1" id="o5" oninput="otpNext(this,'o6')" onkeydown="otpBack(event,this,'o4')"/>
          <input type="text" class="otp-box" maxlength="1" id="o6" oninput="otpNext(this,'')"  onkeydown="otpBack(event,this,'o5')"/>
        </div>
        <input type="hidden" name="otp" id="otpHidden"/>
        <button type="submit" class="btn-login" onclick="collectOTP()">
          <i class="fas fa-check-circle"></i> &nbsp;Verify & Login
        </button>
      </form>

      <div class="resend-row">
        Didn't receive? &nbsp;
        <button class="resend-btn" id="resendBtn" onclick="resendOTP()" disabled>
          Resend OTP (<span id="resendTimer">60</span>s)
        </button>
      </div>
    </div>

  </div>
  <div class="footer-txt">🔒 256-bit SSL Encrypted | Apex Saving Bank © 2026</div>
</div>


<div class="modal" id="forgotModal">
  <div class="modal-box">
    <h3>🔑 Reset Password</h3>
    <input type="text" placeholder="Username" id="fpUser"/>
    <input type="password" placeholder="New Password" id="fpPass"/>
    <button onclick="resetPass()">Reset Password</button>
    <span class="modal-close" onclick="document.getElementById('forgotModal').classList.remove('show')">✕ Close</span>
  </div>
</div>

<script>
var countdownInterval = null;
var resendInterval    = null;

function handleLogin(e) {
  e.preventDefault();
  var username = document.getElementById('usernameInput').value.trim();
  var password = document.getElementById('passInput').value;
  var btn = document.getElementById('loginBtn');
  btn.disabled = true;
  btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Sending OTP...';

  fetch('SendOTPServlet', {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: 'username=' + encodeURIComponent(username) + '&password=' + encodeURIComponent(password)
  })
  .then(function(r){ return r.json(); })
  .then(function(data) {
    btn.disabled = false;
    btn.innerHTML = '<i class="fas fa-paper-plane"></i> &nbsp;Send OTP';
    if(data.success) {
      // ✅ Admin — OTP bypass, direct redirect
      if(data.isAdmin) {
        window.location.href = 'adminDashboard.jsp';
        return;
      }
      document.getElementById('maskedEmail').textContent = data.maskedEmail;
      document.getElementById('hiddenUsername').value = username;
      document.getElementById('step1').classList.remove('active');
      document.getElementById('step2').classList.add('active');
      startCountdown(5 * 60);
      startResendTimer(60);
      document.getElementById('o1').focus();
    } else {
      var existing = document.querySelector('#loginForm .alert');
      if(existing) existing.remove();
      var div = document.createElement('div');
      div.className = 'alert error';
      div.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + data.message;
      document.getElementById('loginForm').insertBefore(div, document.getElementById('loginForm').firstChild);
    }
  })
  .catch(function(){
    btn.disabled = false;
    btn.innerHTML = '<i class="fas fa-paper-plane"></i> &nbsp;Send OTP';
    alert('Network error. Please try again.');
  });
}

function otpNext(el, nextId) {
  el.value = el.value.replace(/[^0-9]/g, '');
  if(el.value && nextId) document.getElementById(nextId).focus();
}
function otpBack(e, el, prevId) {
  if(e.key === 'Backspace' && !el.value && prevId) document.getElementById(prevId).focus();
}
function collectOTP() {
  var otp = ['o1','o2','o3','o4','o5','o6'].map(function(id){ return document.getElementById(id).value; }).join('');
  document.getElementById('otpHidden').value = otp;
}

function startCountdown(seconds) {
  clearInterval(countdownInterval);
  countdownInterval = setInterval(function() {
    if(seconds <= 0) {
      clearInterval(countdownInterval);
      document.getElementById('timerDisplay').textContent = 'Expired';
      document.getElementById('timerDisplay').style.color = '#EF4444';
      return;
    }
    seconds--;
    var m = Math.floor(seconds / 60);
    var s = seconds % 60;
    document.getElementById('timerDisplay').textContent = m + ':' + (s < 10 ? '0' : '') + s;
  }, 1000);
}

function startResendTimer(secs) {
  clearInterval(resendInterval);
  var btn = document.getElementById('resendBtn');
  var timerEl = document.getElementById('resendTimer');
  btn.disabled = true;
  timerEl.textContent = secs;
  resendInterval = setInterval(function() {
    secs--;
    timerEl.textContent = secs;
    if(secs <= 0) {
      clearInterval(resendInterval);
      btn.disabled = false;
      btn.innerHTML = 'Resend OTP';
    }
  }, 1000);
}

function resendOTP() {
  var username = document.getElementById('hiddenUsername').value;
  var btn = document.getElementById('resendBtn');
  btn.disabled = true;
  btn.textContent = 'Sending...';
  fetch('SendOTPServlet', {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: 'username=' + encodeURIComponent(username) + '&resend=true'
  })
  .then(function(r){ return r.json(); })
  .then(function(data) {
    if(data.success) {
      startCountdown(5 * 60);
      startResendTimer(60);
      ['o1','o2','o3','o4','o5','o6'].forEach(function(id){ document.getElementById(id).value=''; });
      document.getElementById('o1').focus();
    }
  });
}

function goBack() {
  clearInterval(countdownInterval);
  clearInterval(resendInterval);
  document.getElementById('step2').classList.remove('active');
  document.getElementById('step1').classList.add('active');
  ['o1','o2','o3','o4','o5','o6'].forEach(function(id){ document.getElementById(id).value=''; });
}

function togglePass() {
  var p = document.getElementById('passInput');
  var i = document.getElementById('eyeIcon');
  p.type = p.type === 'password' ? 'text' : 'password';
  i.className = 'fas fa-' + (p.type === 'password' ? 'eye' : 'eye-slash');
}

function resetPass() {
  var u = document.getElementById('fpUser').value;
  var p = document.getElementById('fpPass').value;
  if(!u || !p){ alert('Please fill all fields'); return; }
  alert('Password reset! (Demo)');
  document.getElementById('forgotModal').classList.remove('show');
}
</script>
</body>
</html>
