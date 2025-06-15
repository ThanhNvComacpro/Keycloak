# 🔐 Keycloak Server

Open Source Identity and Access Management solution.

## 🚀 Quick Start

### Setup và Start Server
```bash
./setup.sh              # Setup môi trường (Java, configs)
./start-keycloak.sh      # Start Keycloak server
```

### Test APIs 
```bash
./test-apis.sh           # Hướng dẫn test APIs với Postman
```

### Admin Access
- **URL**: http://localhost:8080/admin
- **Username**: `admin`
- **Password**: Set during first startup

## 📚 Documentation

| File | Mô tả |
|------|-------|
| `DEVELOPMENT.md` | Complete development guide |
| `KEYCLOAK_APIS.md` | API documentation |
| `Keycloak_APIs.postman_collection.json` | Postman collection |

## 🎯 API Testing với Postman

1. **Import collection**: `Keycloak_APIs.postman_collection.json`
2. **Set variables**:
   - `keycloak_url`: `http://localhost:8080`
   - `realm`: `master`
   - `client_id`: `admin-cli`
3. **Test flow**: Admin Token → Create User → Login → User Info

## 🛠️ Original Commands

To understand the contents of your Keycloak installation, see the [directory structure guide](https://www.keycloak.org/server/directory-structure).

To get help configuring Keycloak via the CLI, run:

on Linux/Unix:
```bash
./bin/kc.sh
```

on Windows:
```cmd
bin\kc.bat
```

To try Keycloak out in development mode, run: 

on Linux/Unix:
```bash
./bin/kc.sh start-dev
```

on Windows:
```cmd
bin\kc.bat start-dev
```

After the server boots, open http://localhost:8080 in your web browser. The welcome page will indicate that the server is running.

To get started, check out the [configuration guides](https://www.keycloak.org/guides#server).