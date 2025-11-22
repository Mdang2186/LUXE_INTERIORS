# Dự Án Website Bán Đồ Nội Thất - FurniShop (Nhóm 2)

Đây là kho chứa mã nguồn cho dự án website bán hàng trực tuyến **FurniShop**, được xây dựng trong khuôn khổ bài tập lớn môn **Thiết kế Web**. Dự án bao gồm đầy đủ các chức năng cơ bản của một trang thương mại điện tử, với giao diện dành cho người dùng và trang quản trị dành cho admin.

## 👥 Thành Viên & Vai Trò

| STT | Họ và Tên           | Ngày Sinh  | Vai Trò Chính                          |
|-----|---------------------|------------|----------------------------------------|
| 1   | Đỗ Công Minh        | 29/10/2004 | Team Leader, Frontend Dev, UI/UX Designer |
| 2   | Đặng Đình Thế Hiếu  | 17/10/2004 | Fullstack Dev (Frontend & Backend)     |
| 3   | Lý Ngọc Long        | 14/02/2003 | Backend Dev, Database Manager          |
| 4   | Nguyễn Hữu Lương    | 28/03/2004 | Backend Dev, Tester                    |

## 🚀 Công Nghệ Sử Dụng

- **Ngôn ngữ:** Java (Servlet)
- **Giao diện:** JSP (JavaServer Pages), JSTL
- **Frontend:** HTML5, CSS3, JavaScript (ES6), Bootstrap 5
- **Backend/Server:** Apache Tomcat 9.0
- **Cơ sở dữ liệu:** Microsoft SQL Server
- **Công cụ Build:** Apache Ant (quản lý thư viện thủ công)
- **IDE:** Apache NetBeans

## 🛠️ Hướng Dẫn Cài Đặt và Chạy Dự Án

> Phần này dành cho thành viên mới hoặc khi cần cài đặt lại môi trường.

### 1) Clone Repository
```bash
git clone https://github.com/Mdang2186/FurniShop.git
```

### 2) Mở Dự Án trong NetBeans
- Vào **File → Open Project...** và trỏ đến thư mục `FurniShop` bạn vừa clone về.

### 3) Cấu Hình Cơ Sở Dữ Liệu
- Mở **SQL Server Management Studio (SSMS)**.
- Thực thi file `database_schema.sql` để tạo database và dữ liệu mẫu.
- Mở file `src/main/java/com/furniture/util/DBContext.java` và cập nhật chuỗi kết nối cho đúng với cấu hình SQL Server của bạn.

### 4) Thêm Thư Viện (JAR Files)
- Chuột phải vào thư mục **Libraries → Add JAR/Folder...**
- Thêm các file JAR cần thiết (**JDBC Driver, JSTL API & IMPL**).

### 5) Build và Chạy
- Chuột phải vào dự án → **Clean and Build**, sau đó **Run**.

## 📖 Hướng Dẫn Làm Việc & Đóng Góp Của Nhóm

### 1) Cấu Trúc Nhánh (Branching Strategy)
- `main`: Nhánh ổn định, chỉ chứa code đã hoàn thiện.
- `develop`: Nhánh tích hợp chính. Mọi chức năng sẽ được gộp vào đây sau khi test.
- `dev-<tên>`: Nhánh làm việc cá nhân của mỗi thành viên (ví dụ: `dev-minh`, `dev-hieu`, `dev-long`, `dev-luong`).

### 2) Hướng Dẫn Thiết Lập Ban Đầu (dành cho Team Leader)
**Thực hiện một lần để tạo môi trường làm việc chung:**
```bash
# Tạo và đẩy nhánh develop
git checkout main
git pull origin main
git checkout -b develop
git push origin develop

# Tạo và đẩy các nhánh cá nhân từ develop (lặp lại cho mỗi thành viên)
git checkout -b dev-minh
git push origin dev-minh
# ...
# Quay trở lại nhánh develop
git checkout develop
```

### 3) Luồng Công Việc Hàng Ngày (cho tất cả thành viên)
```bash
# 1) Chuyển sang nhánh cá nhân của bạn
git checkout dev-minh

# 2) Cập nhật nhánh của bạn với code mới nhất từ develop
#    (BƯỚC CỰC KỲ QUAN TRỌNG để tránh xung đột code)
git pull origin develop

# 3) Sau khi code, commit thường xuyên
git add .
git commit -m "Style: Hoan thien phan header trang chu"

# 4) Đẩy code lên nhánh cá nhân (cuối ngày làm việc hoặc khi hoàn tất)
git push origin dev-minh
```
