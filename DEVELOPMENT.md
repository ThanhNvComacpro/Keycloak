# 🚀 Keycloak Development Guide

## 📋 Yêu cầu hệ thống

- **macOS** (Intel hoặc Apple Silicon)
- **Java 17+** 
- **8GB RAM** (khuyến nghị)
- **Port 8080** available

## 🛠️ Cài đặt nhanh

### Bước 1: Setup môi trường
```bash
./setup.sh
```

### Bước 2: Khởi động Keycloak
```bash
./start-keycloak.sh
```

## 🌐 Truy cập

| Service | URL | Mô tả |
|---------|-----|-------|
| **Main** | http://localhost:8080 | Trang chủ Keycloak |
| **Admin Console** | http://localhost:8080/admin | Quản trị hệ thống |
| **Account Console** | http://localhost:8080/realms/master/account | Quản lý tài khoản |

## 🔐 First Time Setup

1. **Truy cập Admin Console**: http://localhost:8080/admin
2. **Tạo admin user** khi được yêu cầu:
   - Username: `admin`
   - Password: `admin123` (hoặc password bạn chọn)

## 📚 Cấu trúc Project

```
keycloak-26.2.5/
├── bin/                    # Scripts chạy server
│   ├── kc.sh              # Script chính
│   ├── kcadm.sh           # Admin CLI
│   └── kcreg.sh           # Registration CLI
├── conf/                   # Configuration files
│   ├── keycloak.conf      # Main config
│   ├── keycloak-dev.conf  # Dev config (custom)
│   └── cache-ispn.xml     # Cache configuration
├── lib/                    # JAR files và dependencies
├── providers/             # Custom providers
├── themes/                # Custom themes
├── setup.sh              # Setup script (custom)
└── start-keycloak.sh      # Start script (custom)
```

## 🔧 Development Commands

### Start Development Mode
```bash
./bin/kc.sh start-dev
```

### Stop Server
```
Ctrl + C
```

### Build Custom Configuration
```bash
./bin/kc.sh build
```

### Admin CLI Examples
```bash
# Login to admin CLI
./bin/kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin

# Create a new realm
./bin/kcadm.sh create realms -s realm=myrealm -s enabled=true

# Create a new user
./bin/kcadm.sh create users -r myrealm -s username=testuser -s enabled=true

# Create a new client
./bin/kcadm.sh create clients -r myrealm -s clientId=myclient -s enabled=true
```

## 🐳 Database Options

### Development (Default)
- **H2 In-Memory**: Dữ liệu bị mất khi restart
- **File Location**: Không cần cấu hình

### Production
Sửa file `conf/keycloak.conf`:

#### PostgreSQL
```properties
db=postgres
db-username=keycloak
db-password=password
db-url=jdbc:postgresql://localhost:5432/keycloak
```

#### MySQL
```properties
db=mysql
db-username=keycloak
db-password=password
db-url=jdbc:mysql://localhost:3306/keycloak
```

## 🎨 Customization

### Custom Themes
1. Tạo theme trong `themes/` directory
2. Restart server để load theme

### Custom Providers
1. Build JAR file chứa provider
2. Copy vào `providers/` directory  
3. Run `./bin/kc.sh build`
4. Restart server

## 🔍 Troubleshooting

### Port 8080 đã được sử dụng
```bash
# Tìm process đang dùng port 8080
lsof -i :8080

# Kill process
kill -9 <PID>
```

### Java not found
```bash
# Cài lại Java
brew install openjdk@17

# Set JAVA_HOME
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
```

### Memory issues
Tăng memory cho JVM trong file `bin/kc.sh`:
```bash
JAVA_OPTS="-Xms1g -Xmx2g $JAVA_OPTS"
```

## 📖 Useful Resources

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Server Administration Guide](https://www.keycloak.org/docs/latest/server_admin/)
- [REST API Documentation](https://www.keycloak.org/docs-api/26.2/rest-api/)

## 🎯 Next Steps

1. **Tạo Realm mới** cho ứng dụng của bạn
2. **Cấu hình Clients** cho các ứng dụng
3. **Setup Users và Roles**
4. **Tích hợp với ứng dụng** qua OAuth2/OIDC

Happy coding! 🚀
