# 🚀 Quick Start - Custom OTP Provider

## 🎯 Mục tiêu
Provider này cho phép đăng nhập Keycloak bằng **email** hoặc **số điện thoại** với xác thực OTP.

## ⚡ Quick Setup (5 phút)

### 1. Cấu hình Environment
```bash
cd custom-providers
./configure.sh
```

**Nhập thông tin:**
- **SMTP**: Gmail, Yahoo, hoặc SMTP server khác
- **ESMS**: API key từ [eSMS.vn](https://esms.vn)

### 2. Build & Deploy
```bash
./build-and-deploy.sh
```

### 3. Start Keycloak
```bash
cd ..
./start-keycloak.sh
```

### 4. Cấu hình Authentication Flow

1. **Vào Admin Console**: http://localhost:8080/admin
2. **Authentication** → **Flows**
3. **Create Flow**:
   - Name: `OTP Login Flow`
   - Top Level Flow Type: `Client flow`
4. **Add Execution**:
   - Provider: `Custom OTP Login (Email/Phone)`
   - Requirement: `REQUIRED`
5. **Bind Flow**:
   - **Clients** → chọn client → **Settings**
   - Browser Flow: `OTP Login Flow`

## ✅ Test Login

1. Logout khỏi admin console
2. Vào client URL hoặc http://localhost:8080/realms/master/account
3. Nhập **email** hoặc **số điện thoại Việt Nam**:
   - Email: `user@example.com`
   - Phone: `0901234567` hoặc `+84901234567`
4. Nhấn **"Gửi mã OTP"**
5. Kiểm tra email/SMS và nhập mã 6 số
6. Đăng nhập thành công!

## 📱 Supported Formats

### Email
```
✅ user@gmail.com
✅ user.name@company.co.vn
✅ test123@domain.org
```

### Phone (Vietnamese)
```
✅ 0901234567       (Viettel, Vinaphone)
✅ 84901234567      (International)
✅ +84901234567     (Full format)
```

## 🔧 Configuration Files

### SMTP (Gmail Example)
```bash
export SMTP_HOST=smtp.gmail.com
export SMTP_PORT=587
export SMTP_USERNAME=your-email@gmail.com
export SMTP_PASSWORD=your-app-password  # Not your login password!
export SMTP_FROM_EMAIL=your-email@gmail.com
export SMTP_FROM_NAME="My App"
```

### SMS (ESMS Example)
```bash
export ESMS_API_KEY=your-api-key
export ESMS_SECRET_KEY=your-secret-key
export ESMS_BRAND_NAME=MyApp
```

## 🛠️ Troubleshooting

### Email không gửi được
```bash
# Check SMTP config
curl -s telnet smtp.gmail.com 587

# Check logs
tail -f ../data/log/keycloak.log | grep Email
```

### SMS không gửi được
```bash
# Test ESMS API
curl -X POST https://rest.esms.vn/MainService.svc/json/GetBalance \
  -H "Content-Type: application/json" \
  -d '{"ApiKey":"YOUR_KEY","SecretKey":"YOUR_SECRET"}'

# Check logs  
tail -f ../data/log/keycloak.log | grep SMS
```

### Provider không hiện
```bash
# Rebuild Keycloak
cd ..
./bin/kc.sh build
```

### 500 Error
```bash
# Check full logs
tail -f ../data/log/keycloak.log

# Check JAR file
ls -la ../providers/custom-otp-provider-1.0.0.jar
```

## 🎨 Customization

### Change Email Template
```bash
# Edit templates
vi src/main/resources/templates/email_otp_en.html
vi src/main/resources/templates/email_otp_vi.html

# Rebuild
./build-and-deploy.sh
```

### Change SMS Template
```bash
# Edit SMSOTPServiceImpl.java
vi src/main/java/com/example/keycloak/otp/service/impl/SMSOTPServiceImpl.java

# Rebuild
./build-and-deploy.sh
```

### Change UI
```bash
# Edit Freemarker templates
vi src/main/resources/templates/otp-login.ftl
vi src/main/resources/templates/otp-verify.ftl

# Rebuild
./build-and-deploy.sh
```

## 📊 Features Overview

| Feature | Status | Description |
|---------|--------|-------------|
| Email Login | ✅ | SMTP integration |
| Phone Login | ✅ | ESMS integration |
| Multi-language | ✅ | EN/VI support |
| Auto User Creation | ✅ | Create users automatically |
| Security | ✅ | Time-limited OTP, max attempts |
| Templates | ✅ | Beautiful HTML emails |
| Responsive UI | ✅ | Mobile-friendly forms |

## 🌟 Pro Tips

1. **Gmail Setup**: Use App Passwords, not your regular password
2. **ESMS**: Check balance before going live
3. **Testing**: Use `./test.sh` to validate setup
4. **Logs**: Always check logs for debugging
5. **Backup**: Keep configuration in `.env.otp` file

## 📞 Support

- 📧 Email issues: Check SMTP settings and Gmail App Passwords
- 📱 SMS issues: Verify ESMS credentials and balance
- 🔧 Provider issues: Run `./test.sh` and check logs
- 🐛 Bugs: Check `IMPLEMENTATION.md` for details

---

**🎉 You're ready to go! Happy authenticating!**
