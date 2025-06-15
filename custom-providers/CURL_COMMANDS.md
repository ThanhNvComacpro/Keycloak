# 🧪 Manual cURL Commands for Creating Test Users

## 📋 Prerequisites
1. Keycloak running at http://localhost:8080
2. Admin user created with password
3. `jq` installed for JSON parsing: `brew install jq`

## 🔑 Step 1: Get Admin Token

```bash
# Get admin token
ADMIN_TOKEN=$(curl -s -X POST \
  'http://localhost:8080/realms/master/protocol/openid-connect/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d 'grant_type=password' \
  -d 'client_id=admin-cli' \
  -d 'username=admin' \
  -d 'password=admin123' \
  | jq -r '.access_token')

echo "Admin Token: $ADMIN_TOKEN"
```

## 📧 Step 2: Create Email Users

### User 1: test1@example.com
```bash
curl -X POST \
  'http://localhost:8080/admin/realms/master/users' \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "username": "test1_email",
    "email": "test1@example.com",
    "firstName": "Test",
    "lastName": "User1",
    "enabled": true,
    "emailVerified": true,
    "attributes": {
      "loginType": ["email"]
    }
  }'
```

### User 2: user@gmail.com
```bash
curl -X POST \
  'http://localhost:8080/admin/realms/master/users' \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "username": "user_gmail",
    "email": "user@gmail.com",
    "firstName": "Gmail",
    "lastName": "User",
    "enabled": true,
    "emailVerified": true,
    "attributes": {
      "loginType": ["email"]
    }
  }'
```

### User 3: demo@company.com
```bash
curl -X POST \
  'http://localhost:8080/admin/realms/master/users' \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "username": "demo_company",
    "email": "demo@company.com",
    "firstName": "Demo",
    "lastName": "Company",
    "enabled": true,
    "emailVerified": true,
    "attributes": {
      "loginType": ["email"]
    }
  }'
```

## 📱 Step 3: Create Phone Users

### User 1: +84901234567
```bash
curl -X POST \
  'http://localhost:8080/admin/realms/master/users' \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "username": "user_0901234567",
    "firstName": "Phone",
    "lastName": "User1",
    "enabled": true,
    "attributes": {
      "phoneNumber": ["+84901234567"],
      "phoneVerified": ["true"],
      "loginType": ["phone"]
    }
  }'
```

### User 2: +84987654321
```bash
curl -X POST \
  'http://localhost:8080/admin/realms/master/users' \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "username": "user_0987654321",
    "firstName": "Phone",
    "lastName": "User2",
    "enabled": true,
    "attributes": {
      "phoneNumber": ["+84987654321"],
      "phoneVerified": ["true"],
      "loginType": ["phone"]
    }
  }'
```

### User 3: 0123456789
```bash
curl -X POST \
  'http://localhost:8080/admin/realms/master/users' \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{
    "username": "user_0123456789",
    "firstName": "Phone",
    "lastName": "User3",
    "enabled": true,
    "attributes": {
      "phoneNumber": ["0123456789"],
      "phoneVerified": ["true"],
      "loginType": ["phone"]
    }
  }'
```

## 📊 Step 4: Verify Users Created

### List all users
```bash
curl -X GET \
  'http://localhost:8080/admin/realms/master/users?max=20' \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  | jq '.[] | {username: .username, email: .email, phone: .attributes.phoneNumber[0]}'
```

### Search user by email
```bash
curl -X GET \
  'http://localhost:8080/admin/realms/master/users?email=test1@example.com&exact=true' \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  | jq '.'
```

### Search user by phone (using search)
```bash
curl -X GET \
  'http://localhost:8080/admin/realms/master/users?search=0901234567' \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  | jq '.'
```

## 🧪 Step 5: Test Login (Without OTP Config)

### Test URLs:
- **Account Console**: http://localhost:8080/realms/master/account
- **Login directly**: http://localhost:8080/realms/master/protocol/openid-connect/auth?client_id=account-console&redirect_uri=http://localhost:8080/realms/master/account/&response_type=code

### Test Inputs:
- **Email**: `test1@example.com`
- **Email**: `user@gmail.com`
- **Phone**: `0901234567`
- **Phone**: `+84987654321`

## 🔍 Expected Behavior (Without OTP Config):
1. Enter email/phone → Click "Send OTP"
2. System will show error: "Failed to send email/SMS"
3. But you can see the authentication flow is working
4. UI will show the OTP verification form (even though OTP wasn't sent)

## ✅ One-liner Script:
```bash
# Run all commands at once
ADMIN_TOKEN=$(curl -s -X POST 'http://localhost:8080/realms/master/protocol/openid-connect/token' -H 'Content-Type: application/x-www-form-urlencoded' -d 'grant_type=password&client_id=admin-cli&username=admin&password=admin123' | jq -r '.access_token') && \
curl -X POST 'http://localhost:8080/admin/realms/master/users' -H "Authorization: Bearer $ADMIN_TOKEN" -H 'Content-Type: application/json' -d '{"username":"test1_email","email":"test1@example.com","firstName":"Test","lastName":"User1","enabled":true,"emailVerified":true}' && \
curl -X POST 'http://localhost:8080/admin/realms/master/users' -H "Authorization: Bearer $ADMIN_TOKEN" -H 'Content-Type: application/json' -d '{"username":"user_0901234567","firstName":"Phone","lastName":"User1","enabled":true,"attributes":{"phoneNumber":["+84901234567"],"phoneVerified":["true"]}}' && \
echo "✅ Test users created!"
```
