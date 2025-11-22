-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th10 11, 2025 lúc 11:29 AM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `furnishop`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `categories`
--

CREATE TABLE `categories` (
  `CategoryID` int(11) NOT NULL,
  `CategoryName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `categories`
--

INSERT INTO `categories` (`CategoryID`, `CategoryName`) VALUES
(1, 'Sofa & Ghế bành'),
(2, 'Bàn các loại'),
(3, 'Giường & Phòng ngủ'),
(4, 'Tủ & Kệ lưu trữ'),
(5, 'Ghế'),
(6, 'Đồ trang trí'),
(7, 'Nội thất trẻ em'),
(8, 'Nội thất ngoài trời');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `contacts`
--

CREATE TABLE `contacts` (
  `ContactID` int(11) NOT NULL,
  `UserID` int(11) DEFAULT NULL COMMENT 'NULL nếu là khách vãng lai',
  `FullName` varchar(100) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Message` text NOT NULL,
  `CreatedAt` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `contacts`
--

INSERT INTO `contacts` (`ContactID`, `UserID`, `FullName`, `Email`, `Phone`, `Message`, `CreatedAt`) VALUES
(1, 2, 'Lý Ngọc Long', 'long.ly@example.com', '0922222222', 'Tôi muốn hỏi về chính sách bảo hành cho sản phẩm sofa da.', '2025-10-18 00:03:19'),
(2, NULL, 'Trần Anh Khoa', 'khoa.tran@guest.com', '0905111222', 'Vui lòng tư vấn cho tôi một bộ bàn ăn cho 8 người.', '2025-10-19 00:03:19'),
(3, 4, 'Đặng Đình Thế Hiếu', 'hieu.dang@example.com', '0944444444', 'Đơn hàng của tôi khi nào sẽ được giao?', '2025-10-20 00:03:19'),
(4, NULL, 'Lê Thị Thu Thảo', 'thao.le@guest.com', '0918222333', 'Cửa hàng có dịch vụ thiết kế nội thất trọn gói không?', '2025-10-21 00:03:19'),
(5, 3, 'Nguyễn Hữu Lương', 'luong.nguyen@example.com', '0933333333', 'Tôi muốn thay đổi địa chỉ giao hàng cho đơn hàng sắp tới.', '2025-10-22 00:03:19'),
(6, 5, 'Trần Văn An', 'an.tran@example.com', '0955555555', 'Sản phẩm ghế Eames có màu khác không?', '2025-10-23 10:00:00'),
(7, NULL, 'Nguyễn Thị Mai', 'mai.nguyen@guest.com', '0911223344', 'Tôi muốn đặt hàng số lượng lớn cho dự án căn hộ.', '2025-10-23 11:15:00'),
(8, 7, 'Phạm Minh Cường', 'cuong.pham@example.com', '0977777777', 'Thời gian giao hàng dự kiến cho đơn hàng #2 là bao lâu?', '2025-10-23 14:30:00'),
(9, NULL, 'Hoàng Tuấn Anh', 'tuananh.hoang@guest.com', '0987654321', 'Shop có nhận làm kệ tivi theo kích thước yêu cầu không?', '2025-10-24 09:45:00'),
(10, 9, 'Hoàng Văn Giang', 'giang.hoang@example.com', '0999999999', 'Tôi cần tư vấn về chất liệu gỗ óc chó và gỗ sồi.', '2025-10-24 13:20:00'),
(11, 11, 'Đinh Quang Huy', 'huy.dinh@example.com', '0913131313', 'Ghế ăn mã số 9 còn hàng không?', '2025-10-25 08:00:00'),
(12, NULL, 'Phan Thanh Bình', 'binh.phan@guest.com', '0909123456', 'Cho tôi xin báo giá giường tầng trẻ em.', '2025-10-25 14:50:00'),
(13, 13, 'Mai Thế Nhân', 'nhan.mai@example.com', '0915151515', 'Chính sách đổi trả hàng như thế nào?', '2025-10-26 10:15:00'),
(14, NULL, 'Vũ Thị Lan', 'lan.vu@guest.com', '0938776655', 'Tôi muốn xem hàng trực tiếp tại showroom.', '2025-10-26 15:05:00'),
(15, 15, 'Trịnh Thị Quỳnh', 'quynh.trinh@example.com', '0917171717', 'Sofa Chesterfield có màu nâu không?', '2025-10-27 09:30:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `orderitems`
--

CREATE TABLE `orderitems` (
  `OrderItemID` int(11) NOT NULL,
  `OrderID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  `Quantity` int(11) NOT NULL,
  `UnitPrice` decimal(18,0) NOT NULL COMMENT 'Giá tại thời điểm mua hàng'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `orderitems`
--

INSERT INTO `orderitems` (`OrderItemID`, `OrderID`, `ProductID`, `Quantity`, `UnitPrice`) VALUES
(1, 1, 1, 1, 28500000),
(2, 2, 3, 1, 25500000),
(3, 2, 9, 2, 950000),
(4, 3, 5, 1, 15500000),
(5, 4, 2, 1, 35000000),
(6, 5, 21, 1, 9800000),
(7, 5, 23, 1, 3500000),
(8, 6, 4, 1, 45000000),
(9, 6, 18, 1, 4500000),
(10, 7, 10, 1, 22000000),
(11, 8, 15, 1, 16000000),
(12, 9, 19, 1, 7800000),
(13, 10, 30, 1, 6500000),
(14, 11, 2, 1, 35000000),
(15, 12, 17, 1, 75000000),
(16, 13, 8, 1, 18900000),
(17, 13, 7, 1, 2800000),
(18, 13, 2, 1, 35000000);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `orders`
--

CREATE TABLE `orders` (
  `OrderID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `OrderDate` datetime DEFAULT current_timestamp(),
  `TotalAmount` decimal(18,0) NOT NULL,
  `Status` varchar(30) NOT NULL DEFAULT 'Pending' COMMENT 'Pending, Confirmed, Shipping, Done, Cancelled',
  `PaymentMethod` varchar(50) DEFAULT NULL COMMENT 'COD, BankTransfer',
  `ShippingAddress` varchar(255) NOT NULL,
  `Note` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `orders`
--

INSERT INTO `orders` (`OrderID`, `UserID`, `OrderDate`, `TotalAmount`, `Status`, `PaymentMethod`, `ShippingAddress`, `Note`) VALUES
(1, 2, '2025-10-10 10:00:00', 28500000, 'Done', 'COD', '20 Hai Bà Trưng, Quận 1, TP.HCM', 'Giao giờ hành chính'),
(2, 3, '2025-10-11 11:30:00', 27400000, 'Shipping', 'BankTransfer', '30 Trần Phú, Hải Châu, Đà Nẵng', ''),
(3, 4, '2025-10-12 14:00:00', 15500000, 'Done', 'COD', '40 Hùng Vương, Ninh Kiều, Cần Thơ', 'Vui lòng gọi trước khi giao'),
(4, 5, '2025-10-12 15:10:00', 35000000, 'Pending', 'COD', '50 Nguyễn Văn Cừ, Long Biên, Hà Nội', ''),
(5, 2, '2025-10-23 09:30:00', 13300000, 'Pending', 'COD', '20 Hai Bà Trưng, Quận 1, TP.HCM', 'Tôi đặt thêm 2 sản phẩm'),
(6, 6, '2025-10-15 08:45:00', 49500000, 'Confirmed', 'BankTransfer', '60 Võ Văn Tần, Quận 3, TP.HCM', 'Giao sau 5h chiều'),
(7, 7, '2025-10-16 13:00:00', 22000000, 'Pending', 'COD', '70 Lê Duẩn, Thanh Khê, Đà Nẵng', ''),
(8, 8, '2025-10-18 09:15:00', 16000000, 'Done', 'COD', '80 Hòa Bình, Ninh Kiều, Cần Thơ', 'Kiểm tra hàng trước khi nhận'),
(9, 10, '2025-10-20 10:00:00', 7800000, 'Shipping', 'BankTransfer', '100 Nam Kỳ Khởi Nghĩa, Quận 1, TP.HCM', ''),
(10, 12, '2025-10-22 16:30:00', 6500000, 'Pending', 'COD', '120 Nguyễn Chí Thanh, Quận 5, TP.HCM', 'Giao cuối tuần'),
(11, 1, '2025-10-25 12:45:15', 35000000, 'Pending', 'COD', 'Đỗ Công Minh - 0911111111, 10 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', 'rtgyhjik'),
(12, 1, '2025-10-25 12:46:01', 75000000, 'Pending', 'COD', 'Đỗ Công Minh - 0911111111, 10 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', ''),
(13, 16, '2025-11-04 09:43:52', 56700000, 'Processing', 'COD', 'Đỗ Công Minh - 0568658444, trương định HN', 'uniok');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `products`
--

CREATE TABLE `products` (
  `ProductID` int(11) NOT NULL,
  `CategoryID` int(11) NOT NULL,
  `ProductName` varchar(200) NOT NULL,
  `Description` text DEFAULT NULL,
  `OriginalPrice` decimal(18,0) DEFAULT 0 COMMENT 'Giá gốc (chưa giảm)',
  `Price` decimal(18,0) NOT NULL COMMENT 'Giá bán (có thể đã giảm)',
  `Material` varchar(255) DEFAULT NULL,
  `Dimensions` varchar(255) DEFAULT NULL,
  `Features` varchar(500) DEFAULT NULL,
  `ImageURL` varchar(255) DEFAULT NULL COMMENT 'Ảnh đại diện chính (thumbnail)',
  `Brand` varchar(100) DEFAULT NULL,
  `Stock` int(11) NOT NULL DEFAULT 0,
  `CreatedAt` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `products`
--

INSERT INTO `products` (`ProductID`, `CategoryID`, `ProductName`, `Description`, `OriginalPrice`, `Price`, `Material`, `Dimensions`, `Features`, `ImageURL`, `Brand`, `Stock`, `CreatedAt`) VALUES
(1, 1, 'Sofa Băng Vải Lông Cừu Andes', 'Thiết kế tối giản theo phong cách Bắc Âu, chất liệu vải lông cừu (bouclé) cao cấp mang lại cảm giác ấm cúng, sang trọng và mềm mại. Khung gỗ sồi tự nhiên đã qua xử lý, đảm bảo độ bền và chống mối mọt.', 32000000, 28500000, 'Vải lông cừu, Khung gỗ sồi, Nệm mút D40', '240cm x 95cm x 75cm', 'Nệm mút D40 đàn hồi; Chân gỗ tự nhiên; Vải nhập khẩu', 'assets/images/sofa-andes-1.jpg', 'Andes', 10, '2025-10-23 08:44:55'),
(2, 1, 'Ghế Bành Da Bò Thật Eames', 'Biểu tượng của sự thư giãn và đẳng cấp. Làm từ da bò thật 100% nhập khẩu từ Ý và gỗ óc chó tự nhiên. Bộ sản phẩm bao gồm ghế và đôn gác chân, chân hợp kim nhôm đúc nguyên khối siêu bền.', 40000000, 35000000, 'Da bò thật, Gỗ óc chó, Hợp kim nhôm', '84cm x 85cm x 89cm', 'Góc ngả lưng thư giãn; Kèm đôn gác chân; Chân hợp kim xoay 360 độ', 'assets/images/ghe-eames-1.jpg', 'Eames', 5, '2025-10-23 08:44:55'),
(3, 2, 'Bộ Bàn Ăn 6 Ghế Gỗ Sồi Oval', 'Thiết kế bàn hình oval độc đáo, tạo sự gần gũi cho không gian bếp. Toàn bộ làm từ gỗ sồi tự nhiên, mặt bàn được phủ lớp veneer sồi chống trầy. Ghế bọc da PU cao cấp, dễ dàng vệ sinh.', 28000000, 25500000, 'Gỗ sồi, Da PU', 'Bàn: 180cm x 90cm x 75cm', 'Mặt bàn chống trầy; Ghế công thái học; Chống mối mọt', 'assets/images/ban-an-oval-1.jpg', 'Oval', 12, '2025-10-23 08:44:55'),
(4, 3, 'Giường Ngủ Gỗ Óc Chó Hoàng Gia', 'Sản phẩm cao cấp làm từ gỗ óc chó tự nhiên, đầu giường bọc da microfiber cao cấp, mang lại vẻ đẹp quyền quý và sang trọng cho phòng ngủ master. Vân gỗ óc chó tuyệt đẹp.', 50000000, 45000000, 'Gỗ óc chó, Da microfiber', '180cm x 200cm', 'Thiết kế sang trọng; Độ bền cao; Vân gỗ tự nhiên', 'assets/images/giuong-hoang-gia-1.jpg', 'Royal', 8, '2025-10-23 08:44:55'),
(5, 4, 'Kệ Tivi Gỗ Óc Chó Hiện Đại', 'Đường nét thiết kế tinh xảo, màu gỗ óc chó tự nhiên sang trọng. Kệ có nhiều ngăn kéo sử dụng ray trượt giảm chấn của Hafele, bề mặt sơn lacker 7 lớp chống trầy.', 17000000, 15500000, 'Gỗ óc chó', '200cm x 40cm x 50cm', 'Nhiều ngăn chứa đồ; Bề mặt sơn lacker; Ray trượt giảm chấn', 'assets/images/ke-tivi-1.jpg', 'Modern', 20, '2025-10-23 08:44:55'),
(6, 4, 'Tủ Quần Áo Cánh Kính 4 Buồng', 'Thiết kế hiện đại với cánh kính cường lực khung nhôm và hệ thống đèn LED cảm ứng bên trong. Gỗ MDF lõi xanh chống ẩm E1 tiêu chuẩn Châu Âu. Tối ưu không gian lưu trữ.', 30000000, 26500000, 'Gỗ MDF lõi xanh, Kính cường lực', '220cm x 60cm x 240cm', 'Cánh kính sang trọng; Đèn LED cảm ứng; Chống ẩm', 'assets/images/tu-ao-kinh-1.jpg', 'Glassy', 15, '2025-10-23 08:44:55'),
(7, 1, 'Ghế Lười Hạt Xốp Canvas', 'Mang lại sự thoải mái và linh hoạt tối đa. Vỏ ghế bằng vải Canvas dày dặn, có thể tháo rời để giặt. Hạt xốp EPS đường kính 3-5mm, chống xẹp lún.', 3200000, 2800000, 'Vải Canvas, Hạt xốp EPS', '90cm x 110cm', 'Vỏ có thể tháo rời; Dễ dàng vệ sinh; Trọng lượng nhẹ', 'assets/images/ghe-luoi-1.jpg', 'Canvas', 30, '2025-10-23 08:44:55'),
(8, 2, 'Bàn Ăn Tròn Mặt Đá 4 Ghế', 'Mặt bàn bằng đá ceramic cao cấp chống xước, chống ố, chịu nhiệt. Chân bàn bằng thép sơn tĩnh điện cách điệu tạo điểm nhấn. Ghế bọc nỉ êm ái.', 21000000, 18900000, 'Đá ceramic, Chân thép', 'Bàn: D120cm x H75cm', 'Chống trầy xước; Chân bàn nghệ thuật; Ghế bọc nỉ', 'assets/images/ban-an-tron-1.jpg', 'Ceramic', 18, '2025-10-23 08:44:55'),
(9, 5, 'Ghế Ăn Gỗ Tần Bì Bọc Da', 'Ghế ăn đơn giản, thanh lịch, làm từ gỗ tần bì tự nhiên và mặt ngồi bọc da PU cao cấp. Thiết kế lưng ghế hơi ngả, tạo cảm giác thoải mái khi tựa.', 1200000, 950000, 'Gỗ tần bì, Da PU', '45cm x 50cm x 85cm', 'Thiết kế công thái học; Dễ dàng vệ sinh; Gỗ tự nhiên', 'assets/images/ghe-an-1.jpg', 'Scandinavian', 40, '2025-10-23 08:44:55'),
(10, 6, 'Đèn Chùm Pha Lê Nghệ Thuật', 'Đèn chùm với hàng trăm viên pha lê K9 lấp lánh, tán sắc cầu vồng. Khung hợp kim mạ vàng PVD cao cấp. Điểm nhấn đắt giá cho phòng khách hoặc sảnh lớn.', 25000000, 22000000, 'Pha lê K9, Hợp kim', 'D80cm x H60cm', 'Ánh sáng vàng ấm; Tiết kiệm điện; Thiết kế nghệ thuật', 'assets/images/den-chum-1.jpg', 'Classic', 10, '2025-10-23 08:44:55'),
(11, 2, 'Bàn Ăn Mở Rộng Thông Minh', 'Linh hoạt thay đổi kích thước từ 1.4m đến 1.8m, phù hợp cho tiệc tùng. Khung gỗ sồi, mặt bàn bằng đá ceramic. Hệ thống ray trượt thông minh, dễ dàng thao tác.', 25000000, 22500000, 'Gỗ sồi, Mặt đá ceramic', '140-180cm x 80cm x 75cm', 'Mở rộng dễ dàng; Mặt đá chống xước; Khung gỗ chắc chắn', 'assets/images/ban-an-mo-rong-1.jpg', 'SmartDesign', 14, '2025-10-23 08:44:55'),
(12, 4, 'Tủ Buffet Bếp Đa Năng', 'Không gian lưu trữ lớn cho đồ dùng nhà bếp. Gỗ MDF lõi xanh chống ẩm, sơn 2K cao cấp. Mặt tủ có thể dùng làm đảo bếp mini hoặc nơi chuẩn bị đồ ăn.', 13500000, 12000000, 'Gỗ MDF lõi xanh', '160cm x 45cm x 90cm', 'Nhiều ngăn chứa; Chống ẩm; Tay nắm kim loại', 'assets/images/tu-bep-1.jpg', 'KitchenPro', 16, '2025-10-23 08:44:55'),
(13, 7, 'Giường Tầng Gỗ Thông', 'Giường tầng trẻ em thông minh, làm từ gỗ thông New Zealand. Sơn gốc nước an toàn, không chì, không độc hại. Kết cấu chắc chắn, tiết kiệm diện tích tối đa.', 11000000, 9800000, 'Gỗ thông', '120cm x 200cm', 'Sơn gốc nước an toàn; Kết cấu chắc chắn; Tiết kiệm diện tích', 'assets/images/giuong-tang-1.jpg', 'KidHome', 22, '2025-10-23 08:44:55'),
(14, 2, 'Bàn Làm Việc Nâng Hạ Điện', 'Thay đổi chiều cao linh hoạt từ 70cm đến 120cm. Động cơ điện êm ái, ghi nhớ 4 vị trí. Bảo vệ sức khỏe cột sống, tăng hiệu quả làm việc.', 15000000, 13500000, 'Gỗ MDF, Khung thép', '140cm x 70cm', 'Động cơ điện êm ái; Ghi nhớ 4 vị trí; Mặt bàn chống trầy', 'assets/images/ban-nang-ha-1.jpg', 'ErgoDesk', 18, '2025-10-23 08:44:55'),
(15, 3, 'Giường Ngủ Tối Giản Kiểu Nhật', 'Thiết kế sát sàn (platform), chất liệu gỗ thông tự nhiên 100%. Mang lại cảm giác an yên, mộc mạc và gần gũi với thiên nhiên.', 18000000, 16000000, 'Gỗ thông', '160cm x 200cm', 'Phong cách tối giản; Gỗ tự nhiên; Dễ lắp ráp', 'assets/images/giuong-nhat-1.jpg', 'ZenStyle', 25, '2025-10-23 08:44:55'),
(16, 3, 'Bàn Trang Điểm Gỗ Sồi Có Gương LED', 'Gương cảm ứng với 3 chế độ ánh sáng (vàng, trắng, trung tính). Nhiều ngăn chứa đồ tiện lợi. Kèm ghế đôn bọc nỉ êm ái.', 11000000, 9800000, 'Gỗ sồi', '100cm x 40cm x 135cm', 'Đèn LED 3 màu; Kèm ghế đôn; Ngăn kéo tiện lợi', 'assets/images/ban-trang-diem-1.jpg', 'BeautySpace', 30, '2025-10-23 08:44:55'),
(17, 1, 'Sofa Da Bò Ý Chesterfield', 'Vẻ đẹp cổ điển bất tử. Các chi tiết nút bấm đặc trưng và chất liệu da bò Ý cao cấp (full grain). Làm thủ công 100%, khung gỗ sồi già.', 85000000, 75000000, 'Da bò thật', '280cm x 100cm x 80cm', 'Da bò Ý nhập khẩu; Làm thủ công; Khung gỗ sồi', 'assets/images/sofa-chesterfield-1.jpg', 'Chesterfield', 4, '2025-10-23 08:44:55'),
(18, 3, 'Tủ Đầu Giường Thông Minh', 'Tích hợp sạc không dây chuẩn Qi, loa bluetooth và đèn ngủ cảm ứng 3 chế độ. Mặt kính cường lực sang trọng. Giải pháp 3 trong 1 cho phòng ngủ hiện đại.', 5000000, 4500000, 'Gỗ MDF, Kính cường lực', '50cm x 40cm x 55cm', 'Sạc không dây Qi; Loa Bluetooth; Đèn LED cảm ứng', 'assets/images/tap-thong-minh-1.jpg', 'TechNap', 28, '2025-10-23 08:44:55'),
(19, 4, 'Kệ Sách Gỗ Tự Nhiên 5 Tầng', 'Kệ sách chắc chắn với 5 tầng lưu trữ rộng rãi. Gỗ sồi tự nhiên chống cong vênh, chịu lực tốt. Phù hợp cho sách, đồ trang trí, hồ sơ.', 8500000, 7800000, 'Gỗ sồi', '120cm x 30cm x 180cm', 'Chịu lực tốt; Chống cong vênh; Gỗ tự nhiên', 'assets/images/ke-sach-1.jpg', 'BookWorm', 24, '2025-10-23 08:44:55'),
(20, 4, 'Tủ Giày Thông Minh Cửa Lật', 'Thiết kế mỏng gọn (sâu 24cm), sức chứa lớn (24-30 đôi giày). Gỗ MDF lõi xanh chống ẩm, cửa lật 2 lớp tiện lợi. Giúp không gian lối vào ngăn nắp.', 6200000, 5600000, 'Gỗ MDF lõi xanh', '80cm x 24cm x 120cm', 'Cửa lật 2 lớp; Chứa được 24 đôi giày; Chống ẩm', 'assets/images/tu-giay-1.jpg', 'ShoeSmart', 35, '2025-10-23 08:44:55'),
(21, 5, 'Ghế Công Thái Học Ergonomic', 'Hỗ trợ toàn diện cho lưng, cổ và tay. Lưới Wintex nhập khẩu thoáng khí. Ngả lưng 135 độ, tựa đầu 3D, kê tay 4D. Khung hợp kim nhôm siêu bền.', 11000000, 9800000, 'Lưới, Hợp kim nhôm', '65cm x 65cm x 115-125cm', 'Ngả lưng 135 độ; Tựa đầu 3D; Kê tay 4D', 'assets/images/ghe-ergo-1.jpg', 'ErgoChair', 20, '2025-10-23 08:44:55'),
(22, 4, 'Tủ Buffet Bếp (Loại 2)', 'Tủ buffet đa năng, mặt đá ceramic chống xước. Nhiều ngăn kéo và cánh tủ giảm chấn. Thiết kế hiện đại, phù hợp cho phòng ăn hoặc phòng khách.', 14000000, 12300000, 'Gỗ MDF, Mặt đá', '150cm x 40cm x 85cm', 'Nhiều ngăn kéo; Cánh tủ giảm chấn; Chống ẩm', 'assets/images/tu-bep_loai2-1.jpg', 'KitchenPro', 17, '2025-10-23 08:44:55'),
(23, 5, 'Ghế Papasan Thư Giãn', 'Ghế thư giãn hình tròn (tổ chim) làm từ mây tự nhiên 100%. Kèm nệm dày 15cm êm ái. Mang lại cảm giác thư thái tuyệt đối.', 4000000, 3500000, 'Mây tự nhiên, Vải bố', 'D110cm', 'Thoáng mát; Thư giãn tối đa; Nệm dày êm ái', 'assets/images/ghe-papasan-1.jpg', 'ComfortZone', 26, '2025-10-23 08:44:55'),
(24, 6, 'Thảm Lông Cừu Thổ Nhĩ Kỳ', 'Thảm dệt thủ công từ len tự nhiên 100%. Họa tiết tinh xảo, độc đáo. Mang lại sự sang trọng và ấm áp cho không gian.', 13000000, 11500000, 'Len tự nhiên', '200cm x 300cm', 'Dệt thủ công; Mềm mại, êm ái; Họa tiết độc đáo', 'assets/images/tham-1.jpg', 'RugArt', 19, '2025-10-23 08:44:55'),
(25, 4, 'Tủ Hồ Sơ Gỗ 3 Ngăn', 'Lưu trữ tài liệu an toàn với khóa an toàn cho ngăn trên cùng. Ray trượt 3 lớp êm ái, chịu tải nặng. Gỗ MDF phủ melamine chống xước.', 7000000, 6200000, 'Gỗ MDF', '40cm x 50cm x 100cm', 'Khóa an toàn; Ray trượt êm; Chống ẩm', 'assets/images/tu-ho-so-1.jpg', 'OfficeSafe', 32, '2025-10-23 08:44:55'),
(26, 6, 'Gương Treo Tường Toàn Thân Viền Gỗ', 'Gương phôi Bỉ cao cấp cho hình ảnh trong và sắc nét, chống ố mốc. Viền gỗ sồi tự nhiên bo tròn mềm mại. Có thể treo tường hoặc tựa sàn.', 5500000, 4800000, 'Gỗ sồi, Phôi Bỉ', '70cm x 170cm', 'Chống ố mốc; Hình ảnh sắc nét; Viền gỗ tự nhiên', 'assets/images/guong-1.jpg', 'MirrorArt', 40, '2025-10-23 08:44:55'),
(27, 6, 'Đèn Sàn Cong Hiện Đại', 'Đèn sàn hình vòng cung (arc lamp) tạo điểm nhấn nghệ thuật cho góc đọc sách hoặc sofa. Thân thép sơn tĩnh điện, chao đèn vải lanh. Ánh sáng vàng ấm, có thể điều chỉnh độ sáng.', 6000000, 5200000, 'Thép sơn tĩnh điện, Vải lanh', 'H200cm', 'Ánh sáng vàng ấm; Điều chỉnh độ sáng; Thiết kế hiện đại', 'assets/images/den-san-1.jpg', 'LightArc', 23, '2025-10-23 08:44:55'),
(28, 6, 'Bộ Tranh Canvas Trừu Tượng', 'Bộ 3 tranh canvas với gam màu hiện đại (cam, xám, vàng). In trên vải canvas chống thấm, mực in UV bền màu. Khung composite nhẹ, dễ treo lắp.', 4000000, 3500000, 'Vải canvas, Khung composite', '50cm x 70cm (x3)', 'Màu sắc bền đẹp; Dễ treo lắp; Chống thấm nước', 'assets/images/tranh-1.jpg', 'ArtHome', 50, '2025-10-23 08:44:55'),
(29, 3, 'Giường Ngủ Có Ngăn Kéo', 'Tối ưu không gian lưu trữ với 4 ngăn kéo lớn bên dưới giường. Gỗ MDF lõi xanh chống ẩm, ray trượt giảm chấn. Đầu giường bọc nỉ êm ái.', 18000000, 16200000, 'Gỗ MDF lõi xanh, Vải nỉ', '180cm x 200cm', 'Tiết kiệm không gian; Chống ẩm; Ray trượt giảm chấn', 'assets/images/giuong-ngan-keo-1.jpg', 'StorageBed', 18, '2025-10-23 08:44:55'),
(30, 1, 'Sofa Đơn Vải Bố Bắc Âu', 'Thiết kế đơn giản, màu sắc trung tính (xám nhạt), phù hợp để đọc sách. Khung gỗ sồi, nệm D40, vải bố thoáng mát.', 7500000, 6500000, 'Vải bố, Gỗ sồi', '80cm x 85cm x 90cm', 'Thoáng mát; Nệm ngồi êm ái; Phong cách Scandinavian', 'assets/images/sofa-don-1.jpg', 'NordicStyle', 22, '2025-10-23 08:44:55'),
(31, 1, 'Sofa KIVIK 3 Chỗ', 'Sofa KIVIK rộng rãi với nệm mút hoạt tính êm ái, vỏ bọc có thể tháo rời và giặt máy. Thiết kế hiện đại, phù hợp nhiều phòng khách.', 0, 15990000, 'Vải, Mút hoạt tính, Gỗ', '228cm x 95cm x 83cm', 'Vỏ bọc tháo rời; Nệm mút hoạt tính', 'https://images.unsplash.com/photo-1512212678079-a4de110c0fae?q=80&w=800', 'IKEA', 15, '2025-11-11 17:23:07'),
(32, 5, 'Ghế Công Thái Học Aeron', 'Ghế Aeron của Herman Miller, biểu tượng của thiết kế công thái học. Hỗ trợ tư thế ngồi tối ưu với lưới Pellicle thoáng khí.', 0, 45500000, 'Lưới Pellicle, Hợp kim', '70cm x 70cm x 110cm', 'Hỗ trợ cột sống PostureFit SL; Lưới thoáng khí 8Z Pellicle', 'https://images.unsplash.com/photo-1561068471-3c4f7b6be8b6?q=80&w=800', 'Herman Miller', 10, '2025-11-11 17:23:07'),
(33, 2, 'Bàn Ăn Gỗ Sồi VEDDE', 'Bàn ăn VEDDE phong cách Scandinavian, gỗ công nghiệp phủ melamine sồi. Thiết kế chắc chắn, dễ dàng lau chùi.', 0, 7890000, 'Gỗ công nghiệp (MFC)', '160cm x 90cm x 75cm', 'Chống trầy xước; Phong cách Bắc Âu', 'https://images.unsplash.com/photo-1530018607932-25b2f050d09c?q=80&w=800', 'JYSK', 20, '2025-11-11 17:23:07'),
(34, 4, 'Tủ 3 Ngăn Kéo MALM', 'Tủ 3 ngăn kéo MALM với thiết kế đơn giản, tinh tế. Ngăn kéo chạy êm ái, có thể kết hợp với các nội thất khác trong series MALM.', 0, 3490000, 'Ván gỗ dăm', '80cm x 48cm x 78cm', 'Ngăn kéo chạy êm; Thiết kế tối giản', 'https://images.unsplash.com/photo-1594043242016-16017b5d8f6f?q=80&w=800', 'IKEA', 30, '2025-11-11 17:23:07'),
(35, 3, 'Giường Ngủ Bọc Nệm PAMA', 'Giường ngủ PAMA bọc nệm cao cấp, đầu giường thiết kế cao tạo cảm giác sang trọng. Khung gỗ sồi chắc chắn.', 0, 18500000, 'Vải nỉ, Khung gỗ sồi', '180cm x 200cm', 'Đầu giường bọc nệm êm ái; Khung gỗ tự nhiên', 'https://images.unsplash.com/photo-1595526114035-0d45ed16433d?q=80&w=800', 'Nhà Xinh', 12, '2025-11-11 17:23:07'),
(36, 1, 'Ghế Bành POÄNG', 'Ghế thư giãn POÄNG với khung gỗ bạch dương uốn cong, tạo độ đàn hồi thoải mái khi ngồi. Đệm vải êm, có thể tháo rời.', 0, 2290000, 'Gỗ bạch dương, Vải', '68cm x 82cm x 100cm', 'Khung gỗ uốn cong đàn hồi; Đệm êm ái', 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=800', 'IKEA', 25, '2025-11-11 17:23:07'),
(37, 2, 'Bàn Cà Phê LACK', 'Bàn cà phê LACK, thiết kế đơn giản, nhẹ và dễ di chuyển. Cấu trúc giấy tổ ong giúp giảm vật liệu mà vẫn chắc chắn.', 0, 499000, 'Ván gỗ dăm, Giấy tổ ong', '90cm x 55cm x 45cm', 'Nhẹ, dễ di chuyển; Giá cả phải chăng', 'https://images.unsplash.com/photo-1544228865-9f1b9319cdf8?q=80&w=800', 'IKEA', 50, '2025-11-11 17:23:07'),
(38, 4, 'Kệ Sách BILLY', 'Kệ sách BILLY kinh điển, linh hoạt và có thể điều chỉnh độ cao các ngăn. Phù hợp cho thư viện gia đình.', 0, 1790000, 'Ván gỗ dăm, Foil', '80cm x 28cm x 202cm', 'Điều chỉnh độ cao ngăn; Thiết kế vượt thời gian', 'https://images.unsplash.com/photo-1588693952173-5636c78673f3?q=80&w=800', 'IKEA', 40, '2025-11-11 17:23:07'),
(39, 5, 'Ghế Ăn Gỗ Sồi TOLIX', 'Ghế Tolix phiên bản gỗ sồi, kết hợp giữa kim loại sơn tĩnh điện và mặt ngồi gỗ sồi, mang lại vẻ đẹp công nghiệp và ấm cúng.', 0, 1250000, 'Thép sơn tĩnh điện, Gỗ sồi', '45cm x 46cm x 85cm', 'Phong cách công nghiệp (Industrial); Bền bỉ', 'https://images.unsplash.com/photo-1505843490065-c0a69c48b184?q=80&w=800', 'Tolix', 60, '2025-11-11 17:23:07'),
(40, 8, 'Bộ Sofa Ngoài Trời SOLLERÖN', 'Bộ sofa module ngoài trời SOLLERÖN, làm từ nhựa mây (nhựa giả mây) chống chịu thời tiết, nệm chống thấm nước.', 0, 24500000, 'Nhựa mây, Hợp kim', '223cm x 144cm x 88cm', 'Chống chịu thời tiết; Nệm chống thấm; Thiết kế module', 'https://images.unsplash.com/photo-1617103986222-074404f3b5c6?q=80&w=800', 'IKEA', 8, '2025-11-11 17:23:07'),
(41, 6, 'Đèn Sàn HECTAR', 'Đèn sàn HECTAR, thiết kế công nghiệp với đầu đèn lớn, có thể điều chỉnh độ cao và hướng sáng. Làm từ thép chắc chắn.', 0, 1990000, 'Thép sơn tĩnh điện', 'H181cm', 'Phong cách công nghiệp; Điều chỉnh hướng sáng', 'https://images.unsplash.com/photo-1507430455896-96b6d81e35d0?q=80&w=800', 'IKEA', 18, '2025-11-11 17:23:07'),
(42, 7, 'Giường Cũi Trẻ Em SUNDVIK', 'Giường cũi SUNDVIK có thể điều chỉnh 2 mức độ cao và tháo một bên thành cũi khi bé lớn, chuyển thành giường nhỏ.', 0, 4590000, 'Gỗ thông đặc', '70cm x 140cm', 'Điều chỉnh 2 độ cao; Chuyển thành giường nhỏ', 'https://images.unsplash.com/photo-1596524430615-b46475ddff6e?q=80&w=800', 'IKEA', 22, '2025-11-11 17:23:07'),
(43, 2, 'Bàn Làm Việc Đứng BEKANT', 'Bàn làm việc nâng hạ BEKANT, cho phép thay đổi tư thế làm việc từ ngồi sang đứng, bảo vệ sức khỏe. Động cơ điện êm ái.', 0, 11500000, 'Ván gỗ, Khung thép', '160cm x 80cm', 'Nâng hạ bằng điện; Bề mặt chống mài mòn', 'https://images.unsplash.com/photo-1611267860934-1f5d6f21c22f?q=80&w=800', 'IKEA', 15, '2025-11-11 17:23:07'),
(44, 4, 'Tủ Quần Áo PAX', 'Hệ tủ quần áo PAX module, cho phép tùy chỉnh kích thước, màu sắc và phụ kiện bên trong (thanh treo, ngăn kéo) theo ý muốn.', 0, 18000000, 'Ván gỗ dăm, Foil', '150cm x 60cm x 236cm', 'Thiết kế module tùy chỉnh; Bảo hành 10 năm', 'https://images.unsplash.com/photo-1600122425538-f86a5a4155a6?q=80&w=800', 'IKEA', 10, '2025-11-11 17:23:07'),
(45, 5, 'Ghế Eames DSW', 'Ghế Eames DSW với chân gỗ sồi và mặt ngồi nhựa PP, thiết kế biểu tượng của Charles và Ray Eames.', 0, 750000, 'Nhựa PP, Gỗ sồi, Thép', '46cm x 53cm x 81cm', 'Thiết kế Mid-century Modern; Bền bỉ, dễ vệ sinh', 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?q=80&w=800', 'Vitra', 50, '2025-11-11 17:23:07'),
(46, 1, 'Sofa Da Bò Florence', 'Sofa góc Florence bọc da bò thật 100% từ Ý. Thiết kế hiện đại, chân kim loại thanh mảnh, nệm mút cao cấp.', 0, 55000000, 'Da bò thật, Khung gỗ', '280cm x 170cm x 85cm', 'Da bò Ý cao cấp; Chân kim loại mạ chrome', 'https://images.unsplash.com/photo-1540574163024-58ea3f3b1b58?q=80&w=800', 'BoConcept', 7, '2025-11-11 17:23:07'),
(47, 3, 'Giường Ngủ Gỗ Óc Chó METRO', 'Giường ngủ Metro làm từ gỗ óc chó tự nhiên nhập khẩu, vân gỗ đẹp, thiết kế đầu giường cao và chắc chắn.', 0, 32000000, 'Gỗ óc chó', '180cm x 200cm', 'Gỗ óc chó tự nhiên; Vân gỗ sang trọng', 'https://images.unsplash.com/photo-1560184897-ae75f418420e?q=80&w=800', 'Nhà Xinh', 9, '2025-11-11 17:23:07'),
(48, 4, 'Kệ Tivi Gỗ Sồi AKSEL', 'Kệ tivi AKSEL phong cách Bắc Âu, gỗ sồi kết hợp MDF, chân gỗ sồi đặc, có 2 hộc kéo và 1 ngăn mở.', 0, 6990000, 'Gỗ sồi, MDF', '180cm x 40cm x 50cm', 'Phong cách Bắc Âu; Chân gỗ sồi đặc', 'https://images.unsplash.com/photo-1593339872344-f60a4693a778?q=80&w=800', 'JYSK', 14, '2025-11-11 17:23:07'),
(49, 5, 'Ghế Bar Gỗ Sồi STORNÄS', 'Ghế bar STORNÄS làm từ gỗ thông đặc, sơn màu đen, thiết kế chắc chắn, phù hợp cho đảo bếp hoặc quầy bar gia đình.', 0, 1890000, 'Gỗ thông đặc', '40cm x 45cm x H91cm', 'Gỗ thông đặc; Thiết kế chắc chắn', 'https://images.unsplash.com/photo-1503602642458-232111445657?q=80&w=800', 'IKEA', 20, '2025-11-11 17:23:07'),
(50, 6, 'Gương Đứng IKORNNES', 'Gương đứng IKORNNES toàn thân, khung gỗ tần bì, phía sau có thanh treo quần áo hoặc khăn.', 0, 2490000, 'Gỗ tần bì, Kính', '52cm x 167cm', 'Gương toàn thân; Tích hợp thanh treo đồ', 'https://images.unsplash.com/photo-1598420133483-34e86fea3e11?q=80&w=800', 'IKEA', 15, '2025-11-11 17:23:07'),
(51, 1, 'Ghế Đôn Bọc Vải OSKARSHAMN', 'Ghế đôn thư giãn OSKARSHAMN, có thể ngả lưng, thiết kế nhỏ gọn, bọc vải nỉ êm ái, chân kim loại.', 0, 3290000, 'Vải nỉ, Thép', '62cm x 96cm x 90cm', 'Chức năng ngả lưng; Thiết kế nhỏ gọn', 'https://images.unsplash.com/photo-1596101153531-3b32c694a9dd?q=80&w=800', 'IKEA', 18, '2025-11-11 17:23:07'),
(52, 2, 'Bàn Làm Việc MICKE', 'Bàn làm việc MICKE nhỏ gọn, có ngăn kéo và hộc tủ chứa dây điện gọn gàng. Phù hợp cho không gian làm việc nhỏ.', 0, 1990000, 'Ván gỗ dăm, Thép', '105cm x 50cm x 75cm', 'Quản lý dây điện gọn gàng; Ngăn kéo tiện lợi', 'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?q=80&w=800', 'IKEA', 35, '2025-11-11 17:23:07'),
(53, 5, 'Ghế Công Thái Học SAYL', 'Ghế SAYL của Herman Miller, thiết kế lưng 3D thông minh, lấy cảm hứng từ cầu Cổng Vàng, hỗ trợ linh hoạt theo chuyển động.', 0, 21500000, 'Nhựa dẻo, Vải', '62cm x 66cm x 98cm', 'Lưng 3D Intelligent; Thiết kế độc đáo', 'https://images.unsplash.com/photo-1519947486511-14f76265e1b5?q=80&w=800', 'Herman Miller', 12, '2025-11-11 17:23:07'),
(54, 8, 'Ghế Treo Ngoài Trời SVINGA', 'Ghế treo SVINGA, tạo không gian thư giãn ngoài ban công hoặc sân vườn. Làm từ nhựa và thép.', 0, 1790000, 'Nhựa, Thép', 'D74cm x H107cm', 'Thư giãn; Dễ dàng lắp đặt', 'https://images.unsplash.com/photo-1590483827221-f3c3ba294b1c?q=80&w=800', 'IKEA', 20, '2025-11-11 17:23:07'),
(55, 6, 'Tranh Treo Tường BJÖRKSTA', 'Tranh canvas BJÖRKSTA khổ lớn, hình ảnh (ví dụ: New York) sắc nét, khung nhôm nhẹ. Tạo điểm nhấn cho phòng khách.', 0, 1490000, 'Canvas, Khung nhôm', '140cm x 100cm', 'Tranh khổ lớn; Dễ dàng thay đổi hình ảnh', 'https://images.unsplash.com/photo-1549492423-400213a5d214?q=80&w=800', 'IKEA', 15, '2025-11-11 17:23:07'),
(56, 7, 'Tủ Đồ Chơi TROFAST', 'Hệ tủ TROFAST với nhiều thùng nhựa nhiều màu sắc, giúp bé dễ dàng sắp xếp và lấy đồ chơi. Khung gỗ thông.', 0, 2150000, 'Gỗ thông, Nhựa PP', '99cm x 44cm x 94cm', 'Giúp bé tự sắp xếp đồ; Thùng nhựa tháo rời', 'https://images.unsplash.com/photo-1599604563316-3393c834a413?q=80&w=800', 'IKEA', 25, '2025-11-11 17:23:07'),
(57, 1, 'Sofa Giường FRIHETEN', 'Sofa góc FRIHETEN có thể dễ dàng chuyển đổi thành giường ngủ, đồng thời có hộc chứa đồ lớn bên dưới.', 0, 14990000, 'Vải, Gỗ', '230cm x 151cm x 66cm', 'Sofa và giường 2 trong 1; Hộc chứa đồ lớn', 'https://images.unsplash.com/photo-1493663284031-b7e3aefca38f?q=80&w=800', 'IKEA', 13, '2025-11-11 17:23:07'),
(58, 4, 'Tủ Kệ KALLAX', 'Kệ ô vuông KALLAX, thiết kế đơn giản, có thể đặt đứng hoặc nằm, dùng làm kệ sách, kệ trang trí hoặc vách ngăn.', 0, 1990000, 'Ván gỗ dăm, Foil', '77cm x 39cm x 147cm', 'Linh hoạt (đứng/nằm); Có thể thêm hộp vải', 'https://images.unsplash.com/photo-1600122425538-f86a5a4155a6?q=80&w=800', 'IKEA', 45, '2025-11-11 17:23:07'),
(59, 8, 'Bộ Bàn Ăn Ngoài Trời ÄPPLARÖ', 'Bộ bàn ăn ÄPPLARÖ 4 ghế, làm từ gỗ keo, đã được xử lý chống chịu thời tiết, có thể gấp gọn khi không sử dụng.', 0, 9500000, 'Gỗ keo', 'Bàn: 140cm x 78cm', 'Gỗ keo tự nhiên; Chịu được thời tiết; Gấp gọn', 'https://images.unsplash.com/photo-1588821216503-e28d4a4f89b9?q=80&w=800', 'IKEA', 10, '2025-11-11 17:23:07'),
(60, 6, 'Đèn Bàn FADO', 'Đèn bàn FADO hình cầu, làm từ thủy tinh, cho ánh sáng dịu nhẹ, tạo không khí ấm cúng.', 0, 499000, 'Thủy tinh', 'D25cm x H24cm', 'Ánh sáng dịu nhẹ; Thiết kế hình cầu độc đáo', 'https://images.unsplash.com/photo-1543198131-750db1f89369?q=80&w=800', 'IKEA', 30, '2025-11-11 17:23:07');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `product_images`
--

CREATE TABLE `product_images` (
  `ImageID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  `ImageURL` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `product_images`
--

INSERT INTO `product_images` (`ImageID`, `ProductID`, `ImageURL`) VALUES
(1, 1, 'assets/images/sofa-andes-1.jpg'),
(2, 1, 'assets/images/sofa-andes-2.jpg'),
(3, 2, 'assets/images/ghe-eames-1.jpg'),
(4, 2, 'assets/images/ghe-eames-2.jpg'),
(5, 3, 'assets/images/ban-an-oval-1.jpg'),
(6, 3, 'assets/images/ban-an-oval-2.jpg'),
(7, 4, 'assets/images/giuong-hoang-gia-1.jpg'),
(8, 4, 'assets/images/giuong-hoang-gia-2.jpg'),
(9, 5, 'assets/images/ke-tivi-1.jpg'),
(10, 5, 'assets/images/ke-tivi-2.jpg'),
(11, 6, 'assets/images/tu-ao-kinh-1.jpg'),
(12, 6, 'assets/images/tu-ao-kinh-2.jpg'),
(13, 7, 'assets/images/ghe-luoi-1.jpg'),
(14, 7, 'assets/images/ghe-luoi-2.jpg'),
(15, 8, 'assets/images/ban-an-tron-1.jpg'),
(16, 8, 'assets/images/ban-an-tron-2.jpg'),
(17, 9, 'assets/images/ghe-an-1.jpg'),
(18, 9, 'assets/images/ghe-an-2.jpg'),
(19, 10, 'assets/images/den-chum-1.jpg'),
(20, 10, 'assets/images/den-chum-2.jpg'),
(21, 11, 'assets/images/ban-an-mo-rong-1.jpg'),
(22, 11, 'assets/images/ban-an-mo-rong-2.jpg'),
(23, 12, 'assets/images/tu-bep-1.jpg'),
(24, 12, 'assets/images/tu-bep-2.jpg'),
(25, 13, 'assets/images/giuong-tang-1.jpg'),
(26, 13, 'assets/images/giuong-tang-alt2.jpg'),
(27, 14, 'assets/images/ban-nang-ha-alt1.jpg'),
(28, 14, 'assets/images/ban-nang-ha-alt2.jpg'),
(29, 15, 'assets/images/giuong-nhat-alt1.jpg'),
(30, 15, 'assets/images/giuong-nhat-alt2.jpg'),
(31, 31, 'https://images.unsplash.com/photo-1512212678079-a4de110c0fae?q=80&w=800'),
(32, 31, 'https://images.unsplash.com/photo-1493663284031-b7e3aefca38f?q=80&w=800'),
(33, 31, 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=800'),
(34, 32, 'https://images.unsplash.com/photo-1561068471-3c4f7b6be8b6?q=80&w=800'),
(35, 32, 'https://images.unsplash.com/photo-1580489240954-5135aa32c589?q=80&w=800'),
(36, 32, 'https://images.unsplash.com/photo-1617704548623-0f6797b134ee?q=80&w=800'),
(37, 33, 'https://images.unsplash.com/photo-1530018607932-25b2f050d09c?q=80&w=800'),
(38, 33, 'https://images.unsplash.com/photo-1604578762246-41134e37f9cc?q=80&w=800'),
(39, 33, 'https://images.unsplash.com/photo-1519643381401-22c77e60520e?q=80&w=800'),
(40, 34, 'https://images.unsplash.com/photo-1594043242016-16017b5d8f6f?q=80&w=800'),
(41, 34, 'https://images.unsplash.com/photo-1618221617593-8439b1a03a74?q=80&w=800'),
(42, 34, 'https://images.unsplash.com/photo-1633519946483-336a99b45a0b?q=80&w=800'),
(43, 35, 'https://images.unsplash.com/photo-1595526114035-0d45ed16433d?q=80&w=800'),
(44, 35, 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?q=80&w=800'),
(45, 35, 'https://images.unsplash.com/photo-1615875605825-5eb9bb5fea38?q=80&w=800'),
(46, 36, 'https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=800'),
(47, 36, 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?q=80&w=800'),
(48, 36, 'https://images.unsplash.com/photo-1592078615290-033ee584e267?q=80&w=800'),
(49, 37, 'https://images.unsplash.com/photo-1544228865-9f1b9319cdf8?q=80&w=800'),
(50, 37, 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?q=80&w=800'),
(51, 37, 'https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc?q=80&w=800'),
(52, 38, 'https://images.unsplash.com/photo-1588693952173-5636c78673f3?q=80&w=800'),
(53, 38, 'https://images.unsplash.com/photo-1558153403-398588a91345?q=80&w=800'),
(54, 38, 'https://images.unsplash.com/photo-1634712282210-57a4f33d3423?q=80&w=800'),
(55, 39, 'https://images.unsplash.com/photo-1505843490065-c0a69c48b184?q=80&w=800'),
(56, 39, 'https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc?q=80&w=800'),
(57, 39, 'https://images.unsplash.com/photo-1519947486511-14f76265e1b5?q=80&w=800'),
(58, 40, 'https://images.unsplash.com/photo-1617103986222-074404f3b5c6?q=80&w=800'),
(59, 40, 'https://images.unsplash.com/photo-1588821216503-e28d4a4f89b9?q=80&w=800'),
(60, 40, 'https://images.unsplash.com/photo-1562088168-a42e7f01dfa2?q=80&w=800'),
(61, 41, 'https://images.unsplash.com/photo-1507430455896-96b6d81e35d0?q=80&w=800'),
(62, 41, 'https://images.unsplash.com/photo-1619432694356-f86a5a4155a6?q=80&w=800'),
(63, 41, 'https://images.unsplash.com/photo-1543198131-750db1f89369?q=80&w=800'),
(64, 42, 'https://images.unsplash.com/photo-1596524430615-b46475ddff6e?q=80&w=800'),
(65, 42, 'https://images.unsplash.com/photo-1615875605825-5eb9bb5fea38?q=80&w=800'),
(66, 42, 'https://images.unsplash.com/photo-1604578762246-41134e37f9cc?q=80&w=800'),
(67, 43, 'https://images.unsplash.com/photo-1611267860934-1f5d6f21c22f?q=80&w=800'),
(68, 43, 'https://images.unsplash.com/photo-1517400508447-f8a614948a25?q=80&w=800'),
(69, 43, 'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?q=80&w=800'),
(70, 44, 'https://images.unsplash.com/photo-1600122425538-f86a5a4155a6?q=80&w=800'),
(71, 44, 'https://images.unsplash.com/photo-1618220179428-22790b461013?q=80&w=800'),
(72, 44, 'https://images.unsplash.com/photo-1594043242016-16017b5d8f6f?q=80&w=800'),
(73, 45, 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?q=80&w=800'),
(74, 45, 'https://images.unsplash.com/photo-1519947486511-14f76265e1b5?q=80&w=800'),
(75, 45, 'https://images.unsplash.com/photo-1505843490065-c0a69c48b184?q=80&w=800'),
(76, 46, 'https://images.unsplash.com/photo-1540574163024-58ea3f3b1b58?q=80&w=800'),
(77, 46, 'https://images.unsplash.com/photo-1594026112274-b3522f16143b?q=80&w=800'),
(78, 46, 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?q=80&w=800'),
(79, 47, 'https://images.unsplash.com/photo-1560184897-ae75f418420e?q=80&w=800'),
(80, 47, 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?q=80&w=800'),
(81, 47, 'https://images.unsplash.com/photo-1595526114035-0d45ed16433d?q=80&w=800'),
(82, 48, 'https://images.unsplash.com/photo-1593339872344-f60a4693a778?q=80&w=800'),
(83, 48, 'https://images.unsplash.com/photo-1615965511434-3111302157d7?q=80&w=800'),
(84, 48, 'https://images.unsplash.com/photo-1633519946483-336a99b45a0b?q=80&w=800'),
(85, 49, 'https://images.unsplash.com/photo-1503602642458-232111445657?q=80&w=800'),
(86, 49, 'https://images.unsplash.com/photo-1562113530-57ba467c3b51?q=80&w=800'),
(87, 49, 'https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc?q=80&w=800'),
(88, 50, 'https://images.unsplash.com/photo-1598420133483-34e86fea3e11?q=80&w=800'),
(89, 50, 'https://images.unsplash.com/photo-1616627561958-856161ca1203?q=80&w=800'),
(90, 50, 'https://images.unsplash.com/photo-1618220179428-22790b461013?q=80&w=800'),
(91, 51, 'https://images.unsplash.com/photo-1596101153531-3b32c694a9dd?q=80&w=800'),
(92, 51, 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?q=80&w=800'),
(93, 51, 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?q=80&w=800'),
(94, 52, 'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?q=80&w=800'),
(95, 52, 'https://images.unsplash.com/photo-1517400508447-f8a614948a25?q=80&w=800'),
(96, 52, 'https://images.unsplash.com/photo-1611267860934-1f5d6f21c22f?q=80&w=800'),
(97, 53, 'https://images.unsplash.com/photo-1519947486511-14f76265e1b5?q=80&w=800'),
(98, 53, 'https://images.unsplash.com/photo-1561068471-3c4f7b6be8b6?q=80&w=800'),
(99, 53, 'https://images.unsplash.com/photo-1580489240954-5135aa32c589?q=80&w=800'),
(100, 54, 'https://images.unsplash.com/photo-1590483827221-f3c3ba294b1c?q=80&w=800'),
(101, 54, 'https://images.unsplash.com/photo-1631679701835-2698c4421633?q=80&w=800'),
(102, 54, 'https://images.unsplash.com/photo-1600122425538-f86a5a4155a6?q=80&w=800'),
(103, 55, 'https://images.unsplash.com/photo-1549492423-400213a5d214?q=80&w=800'),
(104, 55, 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?q=80&w=800'),
(105, 55, 'https://images.unsplash.com/photo-1575429199926-f78e02d90a61?q=80&w=800'),
(106, 56, 'https://images.unsplash.com/photo-1599604563316-3393c834a413?q=80&w=800'),
(107, 56, 'https://images.unsplash.com/photo-1615875605825-5eb9bb5fea38?q=80&w=800'),
(108, 56, 'https://images.unsplash.com/photo-1596524430615-b46475ddff6e?q=80&w=800'),
(109, 57, 'httpsS://images.unsplash.com/photo-1493663284031-b7e3aefca38f?q=80&w=800'),
(110, 57, 'https://images.unsplash.com/photo-1512212678079-a4de110c0fae?q=80&w=800'),
(111, 57, 'https://images.unsplash.com/photo-1595526114035-0d45ed16433d?q=80&w=800'),
(112, 58, 'https://images.unsplash.com/photo-1600122425538-f86a5a4155a6?q=80&w=800'),
(113, 58, 'https://images.unsplash.com/photo-1558153403-398588a91345?q=80&w=800'),
(114, 58, 'https://images.unsplash.com/photo-1588693952173-5636c78673f3?q=80&w=800'),
(115, 59, 'https://images.unsplash.com/photo-1588821216503-e28d4a4f89b9?q=80&w=800'),
(116, 59, 'https://images.unsplash.com/photo-1617103986222-074404f3b5c6?q=80&w=800'),
(117, 59, 'https://images.unsplash.com/photo-1562088168-a42e7f01dfa2?q=80&w=800'),
(118, 60, 'https://images.unsplash.com/photo-1543198131-750db1f89369?q=80&w=800'),
(119, 60, 'https://images.unsplash.com/photo-1517991101564-50e5033c3609?q=80&w=800'),
(120, 60, 'https://images.unsplash.com/photo-1619432694356-f86a5a4155a6?q=80&w=800');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `reviews`
--

CREATE TABLE `reviews` (
  `ReviewID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `Rating` int(11) NOT NULL COMMENT 'Từ 1 đến 5',
  `Comment` text DEFAULT NULL,
  `CreatedAt` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `reviews`
--

INSERT INTO `reviews` (`ReviewID`, `ProductID`, `UserID`, `Rating`, `Comment`, `CreatedAt`) VALUES
(1, 1, 2, 5, 'Sofa đẹp tuyệt vời, vải lông cừu ngồi êm ái và sang trọng. Giao hàng nhanh và lắp đặt cẩn thận. Rất đáng tiền!', '2025-10-18 10:00:00'),
(2, 3, 3, 5, 'Bộ bàn ăn chắc chắn, màu gỗ tự nhiên rất đẹp. Mặt bàn oval lạ mắt, giúp nhà bếp ấm cúng hơn. Sẽ ủng hộ shop lần nữa.', '2025-10-18 11:30:00'),
(3, 2, 4, 4, 'Ghế ngồi thư giãn rất sướng, da thật 100%. Tuy nhiên cái đôn gác chân hơi thấp so với tôi (tôi cao 1m8). Về tổng thể thì vẫn rất hài lòng.', '2025-10-18 14:00:00'),
(4, 4, 5, 5, 'Giường ngủ tuyệt vời, gỗ óc chó vân rất đẹp. Lắp đặt chuyên nghiệp, không một tiếng cọt kẹt. Cho shop 5 sao.', '2025-10-19 15:10:00'),
(5, 5, 6, 4, 'Kệ tivi đẹp, nhưng có một vết xước nhỏ ở góc. Shop đã hỗ trợ xử lý bằng cách gửi sáp và thợ qua dặm lại, rất chuyên nghiệp.', '2025-10-19 09:05:00'),
(6, 7, 7, 5, 'Ghế lười cực kỳ thoải mái, con tôi rất thích. Vải canvas dày, dễ tháo ra giặt.', '2025-10-20 16:45:00'),
(7, 8, 8, 4, 'Bàn ăn đẹp, mặt đá dễ lau chùi. Giao hàng hơi trễ 1 ngày so với lịch hẹn.', '2025-10-20 08:20:00'),
(8, 6, 9, 5, 'Tủ quần áo rộng rãi, thiết kế cánh kính và đèn LED rất sang. Rất đáng tiền.', '2025-10-21 11:00:00'),
(9, 10, 10, 5, 'Đèn chùm lộng lẫy, phòng khách trở nên sang trọng hẳn. Pha lê K9 tán sắc rất đẹp.', '2025-10-21 13:15:00'),
(10, 9, 11, 4, 'Ghế ăn ngồi chắc chắn, nhưng màu sắc da PU hơi đậm hơn so với ảnh web. Chấp nhận được.', '2025-10-22 17:00:00'),
(11, 1, 3, 4, 'Sofa êm, nhưng vải lông cừu hơi nóng vào mùa hè. Nên dùng phòng máy lạnh.', '2025-10-22 09:30:00'),
(12, 21, 12, 5, 'Ghế công thái học này là cứu cánh cho lưng của tôi. Ngồi làm việc 8 tiếng không còn đau mỏi. Đắt nhưng xắt ra miếng.', '2025-10-22 10:00:00'),
(13, 18, 13, 5, 'Tủ đầu giường siêu thông minh, sạc không dây nhạy, loa nghe nhạc cũng hay. Rất tiện lợi.', '2025-10-23 14:20:00'),
(14, 15, 14, 5, 'Giường kiểu Nhật đẹp, tối giản. Gỗ thông thơm mùi tự nhiên. Rất thích.', '2025-10-23 18:00:00'),
(15, 17, 15, 5, 'Sofa Chesterfield đúng là đẳng cấp, da thật sờ rất mát tay. Form ghế ngồi chuẩn, sang trọng.', '2025-10-23 11:11:00'),
(16, 11, 2, 4, 'Bàn ăn thông minh, rất tiện lợi khi nhà có khách. Mặt đá lau chùi dễ dàng.', '2025-10-24 08:15:00'),
(17, 12, 5, 5, 'Tủ bếp đẹp, nhiều ngăn chứa. Tuy nhiên cánh tủ hơi nặng.', '2025-10-24 09:00:00'),
(18, 13, 6, 3, 'Giường tầng chắc chắn, bé nhà mình rất thích. Sơn an toàn không mùi.', '2025-10-24 10:30:00'),
(19, 14, 7, 5, 'Bàn nâng hạ hoạt động êm, giúp tôi thay đổi tư thế làm việc hiệu quả.', '2025-10-24 11:45:00'),
(20, 16, 8, 4, 'Bàn trang điểm đẹp, gương LED sáng rõ. Hơi ít ngăn kéo nhỏ.', '2025-10-24 14:00:00'),
(21, 19, 9, 5, 'Kệ sách chắc chắn, đựng được nhiều sách. Gỗ sồi màu đẹp.', '2025-10-25 09:20:00'),
(22, 20, 10, 3, 'Tủ giày gọn gàng, tiết kiệm diện tích. Sức chứa tốt.', '2025-10-25 10:10:00'),
(23, 22, 11, 4, 'Tủ buffet loại 2 đẹp hơn loại 1, mặt đá sang trọng.', '2025-10-25 11:55:00'),
(24, 24, 12, 5, 'Thảm mềm mại, hoa văn đẹp. Hút bụi hơi khó.', '2025-10-25 15:00:00'),
(25, 25, 13, 4, 'Tủ hồ sơ có khóa an toàn, phù hợp cho văn phòng.', '2025-10-26 08:30:00'),
(26, 26, 14, 5, 'Gương soi rất nét, không bị méo hình. Viền gỗ đẹp.', '2025-10-26 10:40:00'),
(27, 27, 15, 4, 'Đèn sàn kiểu dáng độc đáo, ánh sáng dịu mắt.', '2025-10-26 13:00:00'),
(28, 28, 2, 5, 'Bộ tranh đẹp, màu sắc tươi sáng, làm bừng sáng cả căn phòng.', '2025-10-26 16:15:00'),
(29, 29, 3, 4, 'Giường có ngăn kéo tiện lợi, giúp phòng ngủ gọn gàng hơn nhiều.', '2025-10-27 09:00:00'),
(30, 30, 4, 5, 'Sofa đơn ngồi thoải mái, vải bố mát mẻ.', '2025-10-27 11:25:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `UserID` int(11) NOT NULL,
  `FullName` varchar(100) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `PasswordHash` varchar(255) NOT NULL COMMENT 'Nên được băm bằng bcrypt/SHA256',
  `Phone` varchar(20) DEFAULT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `Role` varchar(20) NOT NULL DEFAULT 'Customer' COMMENT 'Customer hoặc Admin',
  `CreatedAt` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`UserID`, `FullName`, `Email`, `PasswordHash`, `Phone`, `Address`, `Role`, `CreatedAt`) VALUES
(1, 'Đỗ Công Minh', 'admin@furnishop.vn', '$2a$10$n15qSvM2pwLXorC9rFhUde7rNS2iPakw24SoLxvjuaW9WhNc1.hYe', '0911111111', '10 Lý Thường Kiệt, Hoàn Kiếm, Hà Nội', 'Admin', '2025-10-23 04:06:33'),
(2, 'Lý Ngọc Long', 'long.ly@example.com', 'user123', '0922222222', '20 Hai Bà Trưng, Quận 1, TP.HCM', 'Customer', '2025-10-23 04:06:33'),
(3, 'Nguyễn Hữu Lương', 'luong.nguyen@example.com', 'user123', '0933333333', '30 Trần Phú, Hải Châu, Đà Nẵng', 'Customer', '2025-10-23 04:06:33'),
(4, 'Đặng Đình Thế Hiếu', 'hieu.dang@example.com', 'user123', '0944444444', '40 Hùng Vương, Ninh Kiều, Cần Thơ', 'Customer', '2025-10-23 04:06:33'),
(5, 'Trần Văn An', 'an.tran@example.com', 'user123', '0955555555', '50 Nguyễn Văn Cừ, Long Biên, Hà Nội', 'Customer', '2025-10-23 04:06:33'),
(6, 'Lê Thị Bình', 'binh.le@example.com', 'user123', '0966666666', '60 Võ Văn Tần, Quận 3, TP.HCM', 'Customer', '2025-10-23 04:06:33'),
(7, 'Phạm Minh Cường', 'cuong.pham@example.com', 'user123', '0977777777', '70 Lê Duẩn, Thanh Khê, Đà Nẵng', 'Customer', '2025-10-23 04:06:33'),
(8, 'Võ Ngọc Dung', 'dung.vo@example.com', 'user123', '0988888888', '80 Hòa Bình, Ninh Kiều, Cần Thơ', 'Customer', '2025-10-23 04:06:33'),
(9, 'Hoàng Văn Giang', 'giang.hoang@example.com', 'user123', '0999999999', '90 Láng Hạ, Đống Đa, Hà Nội', 'Customer', '2025-10-23 04:06:33'),
(10, 'Ngô Thị Hạnh', 'hanh.ngo@example.com', 'user123', '0912121212', '100 Nam Kỳ Khởi Nghĩa, Quận 1, TP.HCM', 'Customer', '2025-10-23 04:06:33'),
(11, 'Đinh Quang Huy', 'huy.dinh@example.com', 'user123', '0913131313', '110 Cầu Giấy, Cầu Giấy, Hà Nội', 'Customer', '2025-10-23 04:06:33'),
(12, 'Bùi Khánh Linh', 'linh.bui@example.com', 'user123', '0914141414', '120 Nguyễn Chí Thanh, Quận 5, TP.HCM', 'Customer', '2025-10-23 04:06:33'),
(13, 'Mai Thế Nhân', 'nhan.mai@example.com', 'user123', '0915151515', '130 Điện Biên Phủ, Bình Thạnh, TP.HCM', 'Customer', '2025-10-23 04:06:33'),
(14, 'Dương Quốc Oai', 'oai.duong@example.com', 'user123', '0916161616', '140 Xô Viết Nghệ Tĩnh, Bình Thạnh, TP.HCM', 'Customer', '2025-10-23 04:06:33'),
(15, 'Trịnh Thị Quỳnh', 'quynh.trinh@example.com', 'user123', '0917171717', '150 Phan Xích Long, Phú Nhuận, TP.HCM', 'Customer', '2025-10-23 04:06:33'),
(16, 'Đỗ Công Minh', 'mdang2186@gmail.com', '$2a$10$n15qSvM2pwLXorC9rFhUde7rNS2iPakw24SoLxvjuaW9WhNc1.hYe', '0568658444', 'trương định HN', 'Customer', '2025-11-04 00:00:00');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`CategoryID`);

--
-- Chỉ mục cho bảng `contacts`
--
ALTER TABLE `contacts`
  ADD PRIMARY KEY (`ContactID`),
  ADD KEY `FK_Contacts_Users` (`UserID`);

--
-- Chỉ mục cho bảng `orderitems`
--
ALTER TABLE `orderitems`
  ADD PRIMARY KEY (`OrderItemID`),
  ADD KEY `FK_OrderItems_Orders` (`OrderID`),
  ADD KEY `FK_OrderItems_Products` (`ProductID`);

--
-- Chỉ mục cho bảng `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`OrderID`),
  ADD KEY `FK_Orders_Users` (`UserID`);

--
-- Chỉ mục cho bảng `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`ProductID`),
  ADD KEY `FK_Products_Categories` (`CategoryID`);

--
-- Chỉ mục cho bảng `product_images`
--
ALTER TABLE `product_images`
  ADD PRIMARY KEY (`ImageID`),
  ADD KEY `FK_Images_Products` (`ProductID`);

--
-- Chỉ mục cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`ReviewID`),
  ADD UNIQUE KEY `UQ_Review_Product_User` (`ProductID`,`UserID`) COMMENT 'Mỗi user chỉ review 1 sản phẩm 1 lần',
  ADD KEY `FK_Reviews_Users` (`UserID`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`UserID`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `categories`
--
ALTER TABLE `categories`
  MODIFY `CategoryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `contacts`
--
ALTER TABLE `contacts`
  MODIFY `ContactID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT cho bảng `orderitems`
--
ALTER TABLE `orderitems`
  MODIFY `OrderItemID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT cho bảng `orders`
--
ALTER TABLE `orders`
  MODIFY `OrderID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT cho bảng `products`
--
ALTER TABLE `products`
  MODIFY `ProductID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT cho bảng `product_images`
--
ALTER TABLE `product_images`
  MODIFY `ImageID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=121;

--
-- AUTO_INCREMENT cho bảng `reviews`
--
ALTER TABLE `reviews`
  MODIFY `ReviewID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `contacts`
--
ALTER TABLE `contacts`
  ADD CONSTRAINT `FK_Contacts_Users` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `orderitems`
--
ALTER TABLE `orderitems`
  ADD CONSTRAINT `FK_OrderItems_Orders` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`) ON DELETE CASCADE,
  ADD CONSTRAINT `FK_OrderItems_Products` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ProductID`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `FK_Orders_Users` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `FK_Products_Categories` FOREIGN KEY (`CategoryID`) REFERENCES `categories` (`CategoryID`);

--
-- Các ràng buộc cho bảng `product_images`
--
ALTER TABLE `product_images`
  ADD CONSTRAINT `FK_Images_Products` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ProductID`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `FK_Reviews_Products` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ProductID`) ON DELETE CASCADE,
  ADD CONSTRAINT `FK_Reviews_Users` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
