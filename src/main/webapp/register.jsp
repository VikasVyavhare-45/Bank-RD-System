<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
<title>Apex Saving Bank - Register</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet"/>
<style>
*{margin:0;padding:0;box-sizing:border-box;font-family:'Inter',sans-serif;}
body{min-height:100vh;display:flex;justify-content:center;align-items:flex-start;padding:30px 20px;background:url('bg1.jpg') no-repeat center center/cover fixed;position:relative;}
body::before{content:"";position:fixed;inset:0;background:rgba(10,15,40,0.75);z-index:0;}
.wrap{position:relative;z-index:1;width:100%;max-width:620px;}
.logo-box{text-align:center;margin-bottom:24px;}
.logo-icon{width:52px;height:52px;background:linear-gradient(135deg,#F07600,#ff9a3c);border-radius:14px;display:inline-flex;align-items:center;justify-content:center;font-size:22px;font-weight:800;color:white;margin-bottom:8px;box-shadow:0 8px 24px rgba(240,118,0,0.35);}
.logo-name{font-size:22px;font-weight:700;color:#fff;}
.logo-sub{font-size:11px;color:#aaa;letter-spacing:3px;text-transform:uppercase;}
.card{background:rgba(255,255,255,0.06);backdrop-filter:blur(20px);border:1px solid rgba(255,255,255,0.12);border-radius:20px;padding:36px 32px;box-shadow:0 20px 60px rgba(0,0,0,0.5);}
.card-title{font-size:19px;font-weight:600;color:#fff;margin-bottom:4px;}
.card-sub{font-size:13px;color:#888;margin-bottom:24px;}
.alert{padding:10px 14px;border-radius:10px;font-size:13px;margin-bottom:16px;display:flex;align-items:center;gap:8px;}
.alert.error{background:rgba(220,38,38,0.15);border:1px solid rgba(220,38,38,0.3);color:#fca5a5;}
.section-label{font-size:11px;font-weight:700;color:#F07600;text-transform:uppercase;letter-spacing:1.5px;margin:20px 0 12px;border-bottom:1px solid rgba(240,118,0,0.2);padding-bottom:6px;}
.grid-2{display:grid;grid-template-columns:1fr 1fr;gap:14px;}
.grid-3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:14px;}
.field{margin-bottom:4px;}
.field label{display:block;font-size:12px;font-weight:500;color:#bbb;margin-bottom:6px;}
.input-wrap{position:relative;}
.input-wrap i.icon{position:absolute;left:12px;top:50%;transform:translateY(-50%);color:#555;font-size:13px;}
.field input,.field select,.field textarea{
  width:100%;padding:11px 12px 11px 36px;
  background:rgba(255,255,255,0.07);
  border:1.5px solid rgba(255,255,255,0.1);
  border-radius:10px;color:#fff;font-size:13.5px;
  transition:border-color 0.2s,box-shadow 0.2s;font-family:inherit;
}
.field select{padding:11px 12px 11px 36px;cursor:pointer;}
.field select option{background:#1a1a2e;color:#fff;}
.field textarea{padding:11px 12px 11px 36px;resize:vertical;min-height:70px;}
.field input:focus,.field select:focus,.field textarea:focus{outline:none;border-color:#F07600;box-shadow:0 0 0 3px rgba(240,118,0,0.12);}
.field input::placeholder,.field textarea::placeholder{color:#444;}

/* Rules Box */
.rules-box{
  background:rgba(255,255,255,0.04);
  border:1px solid rgba(255,255,255,0.1);
  border-radius:12px;padding:16px 18px;margin-bottom:6px;
  max-height:180px;overflow-y:auto;
}
.rules-box::-webkit-scrollbar{width:4px;}
.rules-box::-webkit-scrollbar-track{background:rgba(255,255,255,0.05);border-radius:4px;}
.rules-box::-webkit-scrollbar-thumb{background:#F07600;border-radius:4px;}
.rule-item{display:flex;align-items:flex-start;gap:10px;margin-bottom:10px;font-size:12.5px;color:#bbb;line-height:1.6;}
.rule-item:last-child{margin-bottom:0;}
.rule-num{min-width:20px;height:20px;background:rgba(240,118,0,0.2);color:#F07600;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:700;flex-shrink:0;margin-top:1px;}
.rule-item strong{color:#fff;}

/* Checkbox rows */
.check-row{display:flex;align-items:flex-start;gap:10px;margin:14px 0 4px;padding:12px 14px;background:rgba(240,118,0,0.07);border:1px solid rgba(240,118,0,0.2);border-radius:10px;}
.check-row input[type="checkbox"]{width:17px;height:17px;accent-color:#F07600;cursor:pointer;flex-shrink:0;margin-top:2px;}
.check-row label{font-size:13px;color:#ccc;cursor:pointer;line-height:1.55;}
.check-row label a{color:#F07600;text-decoration:none;}
.check-row label a:hover{text-decoration:underline;}

.btn-register{
  width:100%;padding:13px;border:none;border-radius:10px;
  background:linear-gradient(135deg,#F07600,#ff9a3c);
  color:white;font-size:15px;font-weight:700;cursor:pointer;
  margin-top:16px;font-family:inherit;
  box-shadow:0 4px 16px rgba(240,118,0,0.3);transition:all 0.2s;
}
.btn-register:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(240,118,0,0.4);}
.btn-register:disabled{opacity:0.5;cursor:not-allowed;transform:none;}
.login-link{display:block;text-align:center;margin-top:16px;font-size:13px;color:#888;text-decoration:none;}
.login-link span{color:#F07600;font-weight:600;}
.footer-txt{text-align:center;margin-top:20px;font-size:11px;color:#444;padding-bottom:10px;}
</style>
</head>
<body>
<div class="wrap">
  <div class="logo-box">
    <div class="logo-icon">A</div>
    <div class="logo-name">Apex Saving Bank</div>
    <div class="logo-sub">Account Opening</div>
  </div>

  <div class="card">
    <div class="card-title">Create Your Account &#127970;</div>
    <div class="card-sub">Fill in your details to open an Apex Saving Bank account</div>

    <%
    String error = request.getParameter("error");
    if ("exists".equals(error)) { %>
      <div class="alert error"><i class="fas fa-exclamation-circle"></i> Username already exists! Try another.</div>
    <% } else if ("empty".equals(error)) { %>
      <div class="alert error"><i class="fas fa-exclamation-circle"></i> Please fill all required fields.</div>
    <% } else if (error != null) { %>
      <div class="alert error"><i class="fas fa-exclamation-circle"></i> Registration failed! Please try again.</div>
    <% } %>

    <form action="RegisterServlet" method="post" onsubmit="return validateForm()">

      <!-- PERSONAL INFO -->
      <div class="section-label"><i class="fas fa-user"></i> &nbsp;Personal Information</div>
      <div class="grid-2">
        <div class="field">
          <label>Full Name *</label>
          <div class="input-wrap">
            <i class="fas fa-user icon"></i>
            <input type="text" name="fullname" placeholder="Vikas Vyavhare" required/>
          </div>
        </div>
        <div class="field">
          <label>Username *</label>
          <div class="input-wrap">
            <i class="fas fa-at icon"></i>
            <input type="text" name="username" placeholder="vikas29" required/>
          </div>
        </div>
        <div class="field">
          <label>Date of Birth *</label>
          <div class="input-wrap">
            <i class="fas fa-calendar-alt icon"></i>
            <input type="date" name="dob" id="dobInput" required/>
          </div>
        </div>
        <div class="field">
          <label>Gender *</label>
          <div class="input-wrap">
            <i class="fas fa-venus-mars icon"></i>
            <select name="gender" required>
              <option value="" disabled selected>Select Gender</option>
              <option value="Male">Male</option>
              <option value="Female">Female</option>
              <option value="Other">Other</option>
            </select>
          </div>
        </div>
        <div class="field">
          <label>Aadhar Number</label>
          <div class="input-wrap">
            <i class="fas fa-id-card icon"></i>
            <input type="text" name="aadhar" placeholder="XXXX XXXX XXXX" maxlength="14"/>
          </div>
        </div>
        <div class="field">
          <label>PAN Number</label>
          <div class="input-wrap">
            <i class="fas fa-file-alt icon"></i>
            <input type="text" name="pan" placeholder="ABCDE1234F" maxlength="10"/>
          </div>
        </div>
        <div class="field">
          <label>Mobile Number</label>
          <div class="input-wrap">
            <i class="fas fa-phone icon"></i>
            <input type="text" name="mobile" placeholder="9876543210" maxlength="10"/>
          </div>
        </div>
        <div class="field">
          <label>Email Address</label>
          <div class="input-wrap">
            <i class="fas fa-envelope icon"></i>
            <input type="email" name="email" placeholder="vikas@email.com"/>
          </div>
        </div>
      </div>

      <!-- ADDRESS -->
      <div class="section-label"><i class="fas fa-map-marker-alt"></i> &nbsp;Address Details</div>
      <div class="field" style="margin-bottom:14px;">
        <label>Full Address *</label>
        <div class="input-wrap">
          <i class="fas fa-home icon" style="top:18px;transform:none;"></i>
          <textarea name="address" placeholder="Flat No, Street, Area..." required></textarea>
        </div>
      </div>
      <div class="grid-3">
        <div class="field">
          <label>City *</label>
          <div class="input-wrap">
            <i class="fas fa-city icon"></i>
            <input type="text" name="city" placeholder="Pune" required/>
          </div>
        </div>
        <div class="field">
          <label>State *</label>
          <div class="input-wrap">
            <i class="fas fa-map icon"></i>
            <select name="state" required>
              <option value="" disabled selected>State</option>
              <option>Maharashtra</option><option>Gujarat</option><option>Rajasthan</option>
              <option>Uttar Pradesh</option><option>Madhya Pradesh</option><option>Karnataka</option>
              <option>Tamil Nadu</option><option>West Bengal</option><option>Bihar</option>
              <option>Andhra Pradesh</option><option>Telangana</option><option>Kerala</option>
              <option>Punjab</option><option>Haryana</option><option>Delhi</option>
              <option>Goa</option><option>Other</option>
            </select>
          </div>
        </div>
        <div class="field">
          <label>PIN Code *</label>
          <div class="input-wrap">
            <i class="fas fa-thumbtack icon"></i>
            <input type="text" name="pincode" placeholder="411001" maxlength="6" required/>
          </div>
        </div>
      </div>

      <!-- BANK INFO -->
      <div class="section-label"><i class="fas fa-university"></i> &nbsp;Bank Details</div>
      <div class="grid-2">
        <div class="field">
          <label>Account Number</label>
          <div class="input-wrap">
            <i class="fas fa-credit-card icon"></i>
            <input type="text" name="account" placeholder="XXXXXXXXXXXX"/>
          </div>
        </div>
        <div class="field">
          <label>IFSC Code</label>
          <div class="input-wrap">
            <i class="fas fa-code icon"></i>
            <input type="text" name="ifsc" placeholder="APXB0001234"/>
          </div>
        </div>
        <div class="field" style="grid-column:1/-1">
          <label>Bank Name</label>
          <div class="input-wrap">
            <i class="fas fa-building icon"></i>
            <input type="text" name="bank" placeholder="Apex Saving Bank" value="Apex Saving Bank"/>
          </div>
        </div>
      </div>

      <!-- SECURITY -->
      <div class="section-label"><i class="fas fa-shield-alt"></i> &nbsp;Security</div>
      <div class="field">
        <label>Password *</label>
        <div class="input-wrap">
          <i class="fas fa-lock icon"></i>
          <input type="password" name="password" id="passInput" placeholder="Minimum 6 characters" required/>
        </div>
      </div>

      <!-- IMPORTANT RULES -->
      <div class="section-label"><i class="fas fa-exclamation-triangle"></i> &nbsp;Important Rules &amp; Guidelines</div>
      <div class="rules-box">
        <div class="rule-item"><div class="rule-num">1</div><div>&#128274; <strong>OTP Login Required:</strong> Every login requires a valid email OTP. Keep your registered email accessible at all times.</div></div>
        <div class="rule-item"><div class="rule-num">2</div><div>&#128100; <strong>One Account Per Person:</strong> Creating multiple accounts with the same identity documents (Aadhar/PAN) is strictly prohibited and may lead to account suspension.</div></div>
        <div class="rule-item" style="background:rgba(240,118,0,0.08);border:1px solid rgba(240,118,0,0.25);border-radius:8px;padding:8px 10px;">
          <div class="rule-num" style="background:rgba(240,118,0,0.4);color:#fff;">3</div>
          <div>
            &#9888;&#65039; <strong style="color:#ff9a3c;">Late Payment Penalty — &#8377;10 Per Day:</strong>
            If the monthly RD installment is <strong>not paid by the selected due date</strong>, a late penalty of
            <strong style="color:#F07600;">&#8377;10 per day</strong> will be charged for every day past the due date.
            <br/><span style="font-size:11.5px;color:#aaa;margin-top:4px;display:block;">
              Example: Due date = 5th of month. Payment done on 8th = <strong style="color:#F07600;">&#8377;30 penalty</strong> (3 days late).
              Penalty amount will be deducted from your maturity amount.
            </span>
          </div>
        </div>
        <div class="rule-item"><div class="rule-num">4</div><div>&#128203; <strong>Accurate Information:</strong> All details provided during registration must be genuine. False information may result in permanent account termination.</div></div>
        <div class="rule-item"><div class="rule-num">5</div><div>&#128683; <strong>No Fraudulent Activity:</strong> Any attempt at fraudulent transactions will be reported to the authorities as per RBI guidelines.</div></div>
        <div class="rule-item"><div class="rule-num">6</div><div>&#128241; <strong>Profile Responsibility:</strong> You are solely responsible for keeping your login credentials secure. Do not share your password or OTP with anyone.</div></div>
        <div class="rule-item"><div class="rule-num">7</div><div>&#127959; <strong>Minimum Age:</strong> You must be at least 18 years old to open an account. Minor accounts require a guardian's co-signature.</div></div>
        <div class="rule-item"><div class="rule-num">8</div><div>&#128176; <strong>Minimum RD Amount:</strong> The minimum monthly RD deposit is &#8377;500. Accounts with zero activity for 6 months may be marked dormant.</div></div>
      </div>

      <!-- Checkboxes -->
      <div class="check-row">
        <input type="checkbox" name="rulesAccepted" id="rulesCheck" required/>
        <label for="rulesCheck">
          I have read and understood all the <strong style="color:#F07600;">Important Rules &amp; Guidelines</strong> listed above and agree to abide by them. I understand that violation of any rule may result in account suspension.
        </label>
      </div>

      <div class="check-row">
        <input type="checkbox" name="terms" id="termsCheck" required/>
        <label for="termsCheck">
          I agree to Apex Saving Bank's <a href="#">Terms &amp; Conditions</a> and <a href="#">Privacy Policy</a>. I confirm that all the information provided is accurate and complete.
        </label>
      </div>

      <div class="check-row">
        <input type="checkbox" name="ageConfirm" id="ageCheck" required/>
        <label for="ageCheck">
          I confirm that I am <strong style="color:#F07600;">18 years of age or older</strong> and legally eligible to open a bank account as per Indian banking regulations.
        </label>
      </div>

      <button type="submit" class="btn-register" id="registerBtn" disabled>
        <i class="fas fa-user-plus"></i> &nbsp;Create Account
      </button>
    </form>

    <a href="login.jsp" class="login-link">Already have an account? <span>Login here</span></a>
  </div>

  <div class="footer-txt">&#128274; Apex Saving Bank &copy; 2025 | Secure Registration Portal</div>
</div>

<script>
// Enable button only when all 3 checkboxes are checked
var checkboxes = ['rulesCheck','termsCheck','ageCheck'];
checkboxes.forEach(function(id){
  document.getElementById(id).addEventListener('change', toggleBtn);
});
function toggleBtn(){
  var allChecked = checkboxes.every(function(id){
    return document.getElementById(id).checked;
  });
  document.getElementById('registerBtn').disabled = !allChecked;
}

// Age validation (must be 18+)
function validateForm(){
  var dob = document.getElementById('dobInput').value;
  if(dob){
    var today = new Date();
    var birth = new Date(dob);
    var age = today.getFullYear() - birth.getFullYear();
    var m = today.getMonth() - birth.getMonth();
    if(m < 0 || (m === 0 && today.getDate() < birth.getDate())) age--;
    if(age < 18){
      alert('You must be at least 18 years old to register!');
      return false;
    }
  }
  return true;
}

// Set max date for DOB (today - 18 years)
window.onload = function(){
  var today = new Date();
  today.setFullYear(today.getFullYear() - 18);
  var maxDate = today.toISOString().split('T')[0];
  document.getElementById('dobInput').max = maxDate;
};
</script>
</body>
</html>
