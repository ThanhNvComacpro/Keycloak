# 🔌 Keycloak REST APIs - Complete Guide

## 📋 **Tổng quan APIs**

Keycloak cung cấp 2 loại APIs chính:
1. **Admin REST API** - Quản lý realms, users, clients, roles
2. **Authentication APIs** - Login, logout, token management

## 🏗️ **Base URLs**

```
Admin API: http://localhost:8080/admin/realms/{realm}
Auth API: http://localhost:8080/realms/{realm}/protocol/openid-connect
```

## 🔐 **1. Authentication APIs (OpenID Connect)**

### **🚪 Login/Logout APIs**

#### **Token Endpoint (Login)**
```http
POST /realms/{realm}/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

# Password Grant (Direct Access)
grant_type=password
&client_id={client_id}
&client_secret={client_secret}
&username={email_or_username}
&password={password}
&scope=openid profile email

# Authorization Code Grant
grant_type=authorization_code
&client_id={client_id}
&client_secret={client_secret}
&code={authorization_code}
&redirect_uri={redirect_uri}

# Refresh Token
grant_type=refresh_token
&client_id={client_id}
&client_secret={client_secret}
&refresh_token={refresh_token}
```

#### **Logout**
```http
POST /realms/{realm}/protocol/openid-connect/logout
Content-Type: application/x-www-form-urlencoded

client_id={client_id}
&client_secret={client_secret}
&refresh_token={refresh_token}
```

#### **User Info**
```http
GET /realms/{realm}/protocol/openid-connect/userinfo
Authorization: Bearer {access_token}
```

#### **Introspect Token**
```http
POST /realms/{realm}/protocol/openid-connect/token/introspect
Content-Type: application/x-www-form-urlencoded
Authorization: Bearer {access_token}

token={token_to_inspect}
&client_id={client_id}
&client_secret={client_secret}
```

## 🛠️ **2. Admin REST APIs**

### **🏛️ Realm Management**

#### **Get Realms**
```http
GET /admin/realms
Authorization: Bearer {admin_token}
```

#### **Create Realm**
```http
POST /admin/realms
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "realm": "my-realm",
  "enabled": true,
  "displayName": "My Realm"
}
```

#### **Update Realm**
```http
PUT /admin/realms/{realm}
Authorization: Bearer {admin_token}
Content-Type: application/json
```

#### **Delete Realm**
```http
DELETE /admin/realms/{realm}
Authorization: Bearer {admin_token}
```

### **👤 User Management**

#### **Get Users**
```http
GET /admin/realms/{realm}/users
Authorization: Bearer {admin_token}

# Query parameters:
?email={email}
&username={username}
&firstName={firstName}
&lastName={lastName}
&search={search_term}
&first={offset}
&max={limit}
```

#### **Create User**
```http
POST /admin/realms/{realm}/users
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "username": "john.doe",
  "email": "john.doe@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "enabled": true,
  "emailVerified": true,
  "credentials": [{
    "type": "password",
    "value": "password123",
    "temporary": false
  }],
  "attributes": {
    "customField": ["value1", "value2"]
  }
}
```

#### **Update User**
```http
PUT /admin/realms/{realm}/users/{user_id}
Authorization: Bearer {admin_token}
Content-Type: application/json
```

#### **Delete User**
```http
DELETE /admin/realms/{realm}/users/{user_id}
Authorization: Bearer {admin_token}
```

#### **Reset Password**
```http
PUT /admin/realms/{realm}/users/{user_id}/reset-password
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "type": "password",
  "value": "new_password",
  "temporary": false
}
```

#### **Send Verification Email**
```http
PUT /admin/realms/{realm}/users/{user_id}/send-verify-email
Authorization: Bearer {admin_token}
```

#### **Get User by Email**
```http
GET /admin/realms/{realm}/users?email={email}&exact=true
Authorization: Bearer {admin_token}
```

### **🏢 Client Management**

#### **Get Clients**
```http
GET /admin/realms/{realm}/clients
Authorization: Bearer {admin_token}
```

#### **Create Client**
```http
POST /admin/realms/{realm}/clients
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "clientId": "my-app",
  "name": "My Application",
  "enabled": true,
  "publicClient": false,
  "secret": "my-client-secret",
  "redirectUris": ["http://localhost:3000/*"],
  "webOrigins": ["http://localhost:3000"],
  "standardFlowEnabled": true,
  "directAccessGrantsEnabled": true
}
```

### **🎭 Role Management**

#### **Get Realm Roles**
```http
GET /admin/realms/{realm}/roles
Authorization: Bearer {admin_token}
```

#### **Create Role**
```http
POST /admin/realms/{realm}/roles
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "name": "admin",
  "description": "Administrator role"
}
```

#### **Assign Role to User**
```http
POST /admin/realms/{realm}/users/{user_id}/role-mappings/realm
Authorization: Bearer {admin_token}
Content-Type: application/json

[{
  "id": "{role_id}",
  "name": "admin"
}]
```

#### **Get User Roles**
```http
GET /admin/realms/{realm}/users/{user_id}/role-mappings/realm
Authorization: Bearer {admin_token}
```

### **👥 Group Management**

#### **Get Groups**
```http
GET /admin/realms/{realm}/groups
Authorization: Bearer {admin_token}
```

#### **Create Group**
```http
POST /admin/realms/{realm}/groups
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "name": "developers",
  "attributes": {
    "department": ["IT"]
  }
}
```

#### **Add User to Group**
```http
PUT /admin/realms/{realm}/users/{user_id}/groups/{group_id}
Authorization: Bearer {admin_token}
```

### **🔑 Session Management**

#### **Get User Sessions**
```http
GET /admin/realms/{realm}/users/{user_id}/sessions
Authorization: Bearer {admin_token}
```

#### **Logout User**
```http
POST /admin/realms/{realm}/users/{user_id}/logout
Authorization: Bearer {admin_token}
```

#### **Get Realm Sessions**
```http
GET /admin/realms/{realm}/sessions/stats
Authorization: Bearer {admin_token}
```

## 🔍 **3. Useful Query APIs**

### **🔎 Search Users by Email**
```http
GET /admin/realms/{realm}/users?email={email}&exact=true
Authorization: Bearer {admin_token}
```

### **📊 Realm Statistics**
```http
GET /admin/realms/{realm}/users/count
Authorization: Bearer {admin_token}
```

### **🔍 Client Scopes**
```http
GET /admin/realms/{realm}/client-scopes
Authorization: Bearer {admin_token}
```

### **⚙️ Realm Settings**
```http
GET /admin/realms/{realm}
Authorization: Bearer {admin_token}
```

## 🏃‍♂️ **4. Quick Examples cho Backend Integration**

### **Example 1: Login bằng Email/Password**
```javascript
// Node.js example
const axios = require('axios');

async function loginWithEmail(email, password) {
  try {
    const response = await axios.post(
      'http://localhost:8080/realms/master/protocol/openid-connect/token',
      new URLSearchParams({
        grant_type: 'password',
        client_id: 'admin-cli',
        username: email,
        password: password,
        scope: 'openid profile email'
      }),
      {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      }
    );
    
    return {
      access_token: response.data.access_token,
      refresh_token: response.data.refresh_token,
      expires_in: response.data.expires_in
    };
  } catch (error) {
    throw new Error('Login failed: ' + error.response.data.error_description);
  }
}
```

### **Example 2: Tạo User qua Admin API**
```javascript
async function createUser(adminToken, userData) {
  try {
    const response = await axios.post(
      'http://localhost:8080/admin/realms/master/users',
      {
        username: userData.email,
        email: userData.email,
        firstName: userData.firstName,
        lastName: userData.lastName,
        enabled: true,
        emailVerified: true,
        credentials: [{
          type: 'password',
          value: userData.password,
          temporary: false
        }]
      },
      {
        headers: {
          'Authorization': `Bearer ${adminToken}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    return response.status === 201;
  } catch (error) {
    throw new Error('User creation failed: ' + error.response.data.errorMessage);
  }
}
```

### **Example 3: Get User Info**
```javascript
async function getUserByEmail(adminToken, email) {
  try {
    const response = await axios.get(
      `http://localhost:8080/admin/realms/master/users?email=${encodeURIComponent(email)}&exact=true`,
      {
        headers: {
          'Authorization': `Bearer ${adminToken}`
        }
      }
    );
    
    return response.data[0]; // Returns first matching user
  } catch (error) {
    throw new Error('User lookup failed: ' + error.message);
  }
}
```

## 🔧 **5. Authentication Flow cho Backend**

### **Step 1: Get Admin Token**
```http
POST /realms/master/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

grant_type=password
&client_id=admin-cli
&username=admin
&password={admin_password}
```

### **Step 2: Use Admin Token for Management**
```http
Authorization: Bearer {admin_token}
```

## 📚 **6. Postman Collection**

Tôi có thể tạo Postman collection với tất cả APIs này để bạn test dễ dàng!

## 🔒 **7. Security Best Practices**

1. **Luôn sử dụng HTTPS** trong production
2. **Validate tokens** trước khi trust
3. **Set proper CORS** cho web clients
4. **Use service accounts** cho backend-to-backend calls
5. **Implement rate limiting**
6. **Store secrets securely**

## 🎯 **8. Common Use Cases**

- ✅ Login/Register users
- ✅ Password reset
- ✅ User profile management  
- ✅ Role-based access control
- ✅ SSO integration
- ✅ Token validation
- ✅ Session management

Bạn cần tôi tạo examples cụ thể cho case nào không?
