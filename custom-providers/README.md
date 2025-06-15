# Custom OTP Provider for Keycloak

Đây là custom provider cho Keycloak hỗ trợ đăng nhập bằng OTP qua email hoặc SMS (ESMS). Provider này hỗ trợ cả tiếng Anh và tiếng Việt.

## 🌟 Tính năng

- ✅ **Đăng nhập linh hoạt**: Hỗ trợ đăng nhập bằng email hoặc số điện thoại
- ✅ **OTP qua Email**: Gửi mã OTP qua email với template đẹp
- ✅ **OTP qua SMS**: Gửi mã OTP qua SMS sử dụng dịch vụ ESMS
- ✅ **Đa ngôn ngữ**: Hỗ trợ tiếng Anh và tiếng Việt
- ✅ **Bảo mật cao**: Mã OTP có thời hạn 5 phút, tối đa 3 lần thử
- ✅ **Tự động tạo user**: Tự động tạo user mới nếu chưa tồn tại
- ✅ **Giao diện đẹp**: Template UI hiện đại, responsive

## 🚀 Cài đặt

### 1. Build và Deploy Provider

```bash
cd custom-providers
./build-and-deploy.sh
```

### 2. Cấu hình Environment Variables

#### Email Configuration (SMTP)
```bash
export SMTP_HOST=smtp.gmail.com
export SMTP_PORT=587
export SMTP_USERNAME=your-email@gmail.com
export SMTP_PASSWORD=your-app-password
export SMTP_FROM_EMAIL=your-email@gmail.com
export SMTP_FROM_NAME="Your Service Name"
```

#### SMS Configuration (ESMS)
```bash
export ESMS_API_KEY=your-esms-api-key
export ESMS_SECRET_KEY=your-esms-secret-key
export ESMS_BRAND_NAME=YourBrand
```

### 3. Cấu hình Keycloak

1. **Khởi động Keycloak**:
   ```bash
   ./start-keycloak.sh
   ```

2. **Truy cập Admin Console**: http://localhost:8080/admin

3. **Tạo Authentication Flow**:
   - Vào `Authentication` → `Flows`
   - Click `Create flow`
   - Tên: `OTP Login Flow`
   - Type: `Client flow`

4. **Thêm Authenticator**:
   - Click `Add execution`
   - Chọn `Custom OTP Login (Email/Phone)`
   - Set Requirement: `REQUIRED`

5. **Cấu hình Client**:
   - Vào `Clients` → chọn client của bạn
   - Tab `Settings` → `Authentication flow overrides`
   - Browser Flow: chọn `OTP Login Flow`

## 📱 Cách sử dụng

### 1. Đăng nhập bằng Email
- Nhập email của bạn
- Click "Gửi mã OTP"
- Kiểm tra email và nhập mã 6 số
- Hoàn tất đăng nhập

### 2. Đăng nhập bằng Số điện thoại
- Nhập số điện thoại (VD: 0901234567 hoặc +84901234567)
- Click "Gửi mã OTP"
- Kiểm tra SMS và nhập mã 6 số
- Hoàn tất đăng nhập

## 🔧 Cấu hình nâng cao

### SMTP với Gmail

1. **Bật 2-Factor Authentication** cho Gmail account
2. **Tạo App Password**:
   - Vào Google Account Settings
   - Security → 2-Step Verification → App passwords
   - Tạo password cho "Mail"
3. **Sử dụng App Password** làm `SMTP_PASSWORD`

### ESMS Service

1. **Đăng ký tài khoản** tại [eSMS.vn](https://esms.vn)
2. **Lấy API credentials** từ dashboard
3. **Nạp tiền** để gửi SMS

## 🎨 Customization

### Email Templates

Template email được lưu tại:
- `src/main/resources/templates/email_otp_en.html` (Tiếng Anh)
- `src/main/resources/templates/email_otp_vi.html` (Tiếng Việt)

Bạn có thể chỉnh sửa template theo ý muốn và rebuild provider.

### UI Templates

Template giao diện được lưu tại:
- `src/main/resources/templates/otp-login.ftl` (Form nhập email/phone)
- `src/main/resources/templates/otp-verify.ftl` (Form xác thực OTP)

### SMS Templates

Template SMS được cấu hình trong code tại:
- `SMSOTPServiceImpl.getEnglishSMSTemplate()` (Tiếng Anh)
- `SMSOTPServiceImpl.getVietnameseSMSTemplate()` (Tiếng Việt)

## 🔍 Troubleshooting

### Provider không hiện

1. Kiểm tra JAR file đã được copy vào `providers/`
2. Chạy lại `./bin/kc.sh build`
3. Restart Keycloak

### Email không gửi được

1. Kiểm tra SMTP credentials
2. Kiểm tra network connection
3. Xem logs: `tail -f logs/keycloak.log`

### SMS không gửi được

1. Kiểm tra ESMS credentials
2. Kiểm tra số dư tài khoản ESMS
3. Kiểm tra định dạng số điện thoại

### Lỗi 500 Internal Server Error

1. Kiểm tra logs trong `data/log/`
2. Kiểm tra tất cả dependencies đã được include
3. Rebuild provider và restart Keycloak

## 📊 Validation Rules

### Email Format
- Phải có format đúng email: `user@domain.com`
- Ví dụ hợp lệ: `john@example.com`, `user.name@company.co.vn`

### Phone Number Format (Vietnamese)
- Hỗ trợ các định dạng:
  - `0901234567` (format Việt Nam)
  - `84901234567` (international không +)
  - `+84901234567` (international đầy đủ)
- Hỗ trợ các nhà mạng: Viettel, Vinaphone, MobiFone, Vietnamobile, Gmobile

### OTP Code
- 6 chữ số
- Có hiệu lực 5 phút
- Tối đa 3 lần thử sai

## 🛡️ Bảo mật

- **Mã hóa OTP**: OTP được lưu trữ tạm thời trong session
- **Thời gian hết hạn**: 5 phút
- **Giới hạn thử**: Tối đa 3 lần nhập sai
- **Masking**: Email và số điện thoại được ẩn bớt khi hiển thị
- **HTTPS**: Khuyến khích sử dụng HTTPS trong production

## 📝 Logs

Provider ghi log chi tiết để troubleshooting:

```bash
# Xem logs realtime
tail -f data/log/keycloak.log | grep OTP

# Xem logs email
grep "EmailOTPService" data/log/keycloak.log

# Xem logs SMS
grep "SMSOTPService" data/log/keycloak.log
```

## 🔄 Updates

Để update provider:

1. Sửa đổi source code
2. Chạy `./build-and-deploy.sh`
3. Restart Keycloak

## 🤝 Đóng góp

Nếu bạn muốn đóng góp hoặc báo lỗi, vui lòng tạo issue hoặc pull request.

## 📄 License

MIT License - Xem file LICENSE để biết thêm chi tiết.

---

**Happy Coding!** 🎉
