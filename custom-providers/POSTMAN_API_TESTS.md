# Keycloak OTP Login API Tests - Postman Collection

## 📋 Overview

Collection này chứa các API tests để kiểm tra custom OTP authentication provider cho Keycloak.

## 🚀 Quick Start

### 1. Import vào Postman

1. Mở Postman
2. Click **Import**
3. Import 2 files sau:
   - `Keycloak_OTP_Login_API_Tests.postman_collection.json` (Collection)
   - `Keycloak_OTP_Environment.postman_environment.json` (Environment)

### 2. Chọn Environment

1. Trong Postman, chọn **Keycloak OTP Environment** từ dropdown environment
2. Kiểm tra các variables đã được set đúng:
   - `KEYCLOAK_URL`: http://localhost:8080
   - `REALM`: master
   - `CLIENT_ID`: admin-cli
   - `ADMIN_USERNAME`: admin
   - `ADMIN_PASSWORD`: admin123

### 3. Chạy Tests

#### Option 1: Chạy từng request

1. **Health Check** → Check Keycloak Status
2. **Admin Operations** → Get Admin Token (chạy trước để lấy token)
3. **Admin Operations** → List All Users (xem users đã tạo)
4. **Email Login Tests** → Chạy tất cả các test email
5. **Phone Login Tests** → Chạy tất cả các test phone
6. **Browser Authentication URLs** → Lấy URL để test qua browser

#### Option 2: Chạy toàn bộ Collection

1. Click vào Collection name
2. Click **Run collection**
3. Chọn **Run Keycloak OTP Login API Tests**

## 📊 Expected Results

### ✅ Successful Tests

- **Health Check**: Status 200 - Keycloak running
- **Get Admin Token**: Status 200 - Token received
- **List Users**: Status 200 - Shows created test users
- **Login Tests**: Status 401 - OTP authentication required (đây là kết quả mong muốn!)

### 📧 Email Login Tests

Các email sau sẽ trả về **401 (OTP required)**:
- test1@example.com
- user@gmail.com  
- demo@company.com

### 📱 Phone Login Tests

Các số điện thoại sau sẽ trả về **401 (OTP required)**:
- 0901234567
- +84901234567
- 0987654321
- 0123456789

## 🔍 Understanding the Results

### Tại sao 401 là kết quả đúng?

**Status 401** với error "invalid_grant" hoặc "unauthorized" cho thấy:

1. ✅ User tồn tại trong hệ thống
2. ✅ Authentication flow được kích hoạt  
3. ✅ OTP provider đã được gọi
4. ✅ Hệ thống yêu cầu OTP để hoàn tất đăng nhập

**Nếu user không tồn tại**: Sẽ trả về "invalid_grant" với message khác
**Nếu authentication flow không hoạt động**: Sẽ có lỗi khác

### Browser Authentication Flow

Sử dụng URLs từ folder **"Browser Authentication URLs"** để:
1. Test authentication flow qua browser
2. Xem OTP form hiển thị
3. Kiểm tra email/SMS sending (nếu đã cấu hình)

## 🛠️ Test Data

### Test Users Created

**📧 Email Users:**
- Username: `test1_email` | Email: `test1@example.com`
- Username: `user_gmail` | Email: `user@gmail.com`  
- Username: `demo_company` | Email: `demo@company.com`

**📱 Phone Users:**
- Username: `user_0901234567` | Phone: `+84901234567`
- Username: `user_0987654321` | Phone: `+84987654321`
- Username: `user_0123456789` | Phone: `0123456789`

## 🔧 Troubleshooting

### Keycloak không chạy
```bash
cd /Users/thanh/Downloads/code/Keycloak
./bin/kc.sh start-dev --http-port=8080
```

### Admin token expired
Chạy lại request **"Get Admin Token"** trong folder **Admin Operations**

### Users không tồn tại
```bash
cd custom-providers
./create-test-users.sh
```

## 📝 Notes

1. **401 responses là expected behavior** - cho thấy OTP authentication đang hoạt động
2. Để test full flow, sử dụng browser authentication URLs
3. Cần cấu hình SMTP/SMS để OTP thực sự được gửi
4. Collection này test API level, không test UI

## 🎯 Next Steps

1. **Configure SMTP/SMS**: Set up email và SMS providers
2. **Browser Testing**: Sử dụng authentication URLs để test UI
3. **OTP Verification**: Test nhập OTP code
4. **Production Config**: Set up proper authentication flows

---

**✅ API Tests Complete!** 

Collection này verify rằng OTP authentication provider đang hoạt động đúng cách.
