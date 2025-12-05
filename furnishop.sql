-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th10 29, 2025 lúc 04:52 AM
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
(8, 'Nội thất ngoài trời'),
(9, 'Bàn các loại 2');

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
-- Cấu trúc bảng cho bảng `feedbacks`
--

CREATE TABLE `feedbacks` (
  `FeedbackID` int(11) NOT NULL,
  `UserID` int(11) DEFAULT NULL,
  `FullName` varchar(100) DEFAULT NULL,
  `Email` varchar(100) DEFAULT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  `Subject` varchar(255) DEFAULT NULL,
  `Message` text NOT NULL,
  `CreatedAt` datetime DEFAULT current_timestamp(),
  `IsResolved` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(8, 6, 4, 1, 45000000),
(10, 7, 10, 1, 22000000),
(11, 8, 15, 1, 16000000),
(14, 11, 2, 1, 35000000),
(16, 13, 8, 1, 18900000),
(17, 13, 7, 1, 2800000),
(18, 13, 2, 1, 35000000),
(19, 14, 1, 1, 28500000),
(20, 14, 2, 1, 35000000),
(21, 14, 7, 1, 2800000),
(22, 15, 1, 1, 28500000),
(23, 16, 2, 1, 35000000),
(24, 17, 1, 2, 28500000),
(25, 18, 16, 1, 9800000),
(26, 19, 18, 1, 4500000),
(27, 19, 21, 1, 9800000),
(28, 19, 25, 1, 6200000);

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
(13, 16, '2025-11-04 09:43:52', 56700000, 'Processing', 'COD', 'Đỗ Công Minh - 0568658444, trương định HN', 'uniok'),
(14, 16, '2025-11-11 23:25:23', 66300000, 'Pending', 'COD', 'Đỗ Công Minh - 0568658444, trương định HN', ''),
(15, 16, '2025-11-14 07:37:29', 28500000, 'Pending', 'BANK', 'Đỗ Công Minh - 0568658444, trương định HN', ''),
(16, 16, '2025-11-25 07:54:01', 35000000, 'Pending', 'COD', 'Đỗ Công Minh - 0568658444, trương định HN', '[Thanh toán] Phương thức: COD | Đặt cọc: 17500000 VND | Còn lại: 17500000 VND'),
(17, 16, '2025-11-27 09:41:19', 57000000, 'Done', 'COD', 'Đỗ Công Minh - 0568658444, trương định HN', '[Thanh toán] Phương thức: COD | Đặt cọc: 28500000 VND | Còn lại: 28500000 VND'),
(18, 17, '2025-11-28 20:51:08', 9800000, 'Done', 'COD', 'Đặng Đình Thế Hiếu - 0964512620, VietNam', '[Thanh toán] Phương thức: COD | Đặt cọc: 4900000 VND | Còn lại: 4900000 VND'),
(19, 17, '2025-11-28 20:52:23', 20500000, 'Canceled', 'CARD', 'Đặng Đình Thế Hiếu - 0964512620, VietNam', '[Thanh toán] Phương thức: CARD | Thanh toán online 100%: 20500000 VND | Ngân hàng: MB Bank | Số thẻ: **** **** **** 4534');

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
  `CostPrice` decimal(18,0) DEFAULT 0 COMMENT 'Giá nhập kho để tính lợi nhuận',
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

INSERT INTO `products` (`ProductID`, `CategoryID`, `ProductName`, `Description`, `OriginalPrice`, `Price`, `CostPrice`, `Material`, `Dimensions`, `Features`, `ImageURL`, `Brand`, `Stock`, `CreatedAt`) VALUES
(1, 1, 'Sofa Băng Vải Lông Cừu Andes', 'Thiết kế tối giản theo phong cách Bắc Âu, chất liệu vải lông cừu (bouclé) cao cấp mang lại cảm giác ấm cúng, sang trọng và mềm mại. Khung gỗ sồi tự nhiên đã qua xử lý, đảm bảo độ bền và chống mối mọt.', 32000000, 28500000, 0, 'Vải lông cừu, Khung gỗ sồi, Nệm mút D40', '240cm x 95cm x 75cm', 'Nệm mút D40 đàn hồi; Chân gỗ tự nhiên; Vải nhập khẩu', 'assets/images/sofa-andes-1.jpg', 'Andes', 8, '2025-10-23 08:44:55'),
(2, 1, 'Ghế Bành Da Bò Thật Eames', 'Biểu tượng của sự thư giãn và đẳng cấp. Làm từ da bò thật 100% nhập khẩu từ Ý và gỗ óc chó tự nhiên. Bộ sản phẩm bao gồm ghế và đôn gác chân, chân hợp kim nhôm đúc nguyên khối siêu bền.', 40000000, 35000000, 0, 'Da bò thật, Gỗ óc chó, Hợp kim nhôm', '84cm x 85cm x 89cm', 'Góc ngả lưng thư giãn; Kèm đôn gác chân; Chân hợp kim xoay 360 độ', 'assets/images/ghe-eames-1.jpg', 'Eames', 4, '2025-10-23 08:44:55'),
(3, 2, 'Bộ Bàn Ăn 6 Ghế Gỗ Sồi Oval', 'Thiết kế bàn hình oval độc đáo, tạo sự gần gũi cho không gian bếp. Toàn bộ làm từ gỗ sồi tự nhiên, mặt bàn được phủ lớp veneer sồi chống trầy. Ghế bọc da PU cao cấp, dễ dàng vệ sinh.', 28000000, 25500000, 0, 'Gỗ sồi, Da PU', 'Bàn: 180cm x 90cm x 75cm', 'Mặt bàn chống trầy; Ghế công thái học; Chống mối mọt', 'assets/images/ban-an-oval-1.jpg', 'Oval', 12, '2025-10-23 08:44:55'),
(4, 3, 'Giường Ngủ Gỗ Óc Chó Hoàng Gia', 'Sản phẩm cao cấp làm từ gỗ óc chó tự nhiên, đầu giường bọc da microfiber cao cấp, mang lại vẻ đẹp quyền quý và sang trọng cho phòng ngủ master. Vân gỗ óc chó tuyệt đẹp.', 50000000, 45000000, 0, 'Gỗ óc chó, Da microfiber', '180cm x 200cm', 'Thiết kế sang trọng; Độ bền cao; Vân gỗ tự nhiên', 'assets/images/giuong-hoang-gia-1.jpg', 'Royal', 8, '2025-10-23 08:44:55'),
(5, 4, 'Kệ Tivi Gỗ Óc Chó Hiện Đại', 'Đường nét thiết kế tinh xảo, màu gỗ óc chó tự nhiên sang trọng. Kệ có nhiều ngăn kéo sử dụng ray trượt giảm chấn của Hafele, bề mặt sơn lacker 7 lớp chống trầy.', 17000000, 15500000, 0, 'Gỗ óc chó', '200cm x 40cm x 50cm', 'Nhiều ngăn chứa đồ; Bề mặt sơn lacker; Ray trượt giảm chấn', 'assets/images/ke-tivi-1.jpg', 'Modern', 20, '2025-10-23 08:44:55'),
(6, 4, 'Tủ Quần Áo Cánh Kính 4 Buồng', 'Thiết kế hiện đại với cánh kính cường lực khung nhôm và hệ thống đèn LED cảm ứng bên trong. Gỗ MDF lõi xanh chống ẩm E1 tiêu chuẩn Châu Âu. Tối ưu không gian lưu trữ.', 30000000, 26500000, 0, 'Gỗ MDF lõi xanh, Kính cường lực', '220cm x 60cm x 240cm', 'Cánh kính sang trọng; Đèn LED cảm ứng; Chống ẩm', 'assets/images/tu-ao-kinh-1.jpg', 'Glassy', 15, '2025-10-23 08:44:55'),
(7, 1, 'Ghế Lười Hạt Xốp Canvas', 'Mang lại sự thoải mái và linh hoạt tối đa. Vỏ ghế bằng vải Canvas dày dặn, có thể tháo rời để giặt. Hạt xốp EPS đường kính 3-5mm, chống xẹp lún.', 3200000, 2800000, 0, 'Vải Canvas, Hạt xốp EPS', '90cm x 110cm', 'Vỏ có thể tháo rời; Dễ dàng vệ sinh; Trọng lượng nhẹ', 'assets/images/ghe-luoi-1.jpg', 'Canvas', 30, '2025-10-23 08:44:55'),
(8, 2, 'Bàn Ăn Tròn Mặt Đá 4 Ghế', 'Mặt bàn bằng đá ceramic cao cấp chống xước, chống ố, chịu nhiệt. Chân bàn bằng thép sơn tĩnh điện cách điệu tạo điểm nhấn. Ghế bọc nỉ êm ái.', 21000000, 18900000, 0, 'Đá ceramic, Chân thép', 'Bàn: D120cm x H75cm', 'Chống trầy xước; Chân bàn nghệ thuật; Ghế bọc nỉ', 'assets/images/ban-an-tron-1.jpg', 'Ceramic', 18, '2025-10-23 08:44:55'),
(9, 5, 'Ghế Ăn Gỗ Tần Bì Bọc Da', 'Ghế ăn đơn giản, thanh lịch, làm từ gỗ tần bì tự nhiên và mặt ngồi bọc da PU cao cấp. Thiết kế lưng ghế hơi ngả, tạo cảm giác thoải mái khi tựa.', 1200000, 950000, 0, 'Gỗ tần bì, Da PU', '45cm x 50cm x 85cm', 'Thiết kế công thái học; Dễ dàng vệ sinh; Gỗ tự nhiên', 'assets/images/ghe-an-1.jpg', 'Scandinavian', 40, '2025-10-23 08:44:55'),
(10, 6, 'Đèn Chùm Pha Lê Nghệ Thuật', 'Đèn chùm với hàng trăm viên pha lê K9 lấp lánh, tán sắc cầu vồng. Khung hợp kim mạ vàng PVD cao cấp. Điểm nhấn đắt giá cho phòng khách hoặc sảnh lớn.', 25000000, 22000000, 0, 'Pha lê K9, Hợp kim', 'D80cm x H60cm', 'Ánh sáng vàng ấm; Tiết kiệm điện; Thiết kế nghệ thuật', 'assets/images/den-chum-1.jpg', 'Classic', 10, '2025-10-23 08:44:55'),
(11, 2, 'Bàn Ăn Mở Rộng Thông Minh', 'Linh hoạt thay đổi kích thước từ 1.4m đến 1.8m, phù hợp cho tiệc tùng. Khung gỗ sồi, mặt bàn bằng đá ceramic. Hệ thống ray trượt thông minh, dễ dàng thao tác.', 25000000, 22500000, 0, 'Gỗ sồi, Mặt đá ceramic', '140-180cm x 80cm x 75cm', 'Mở rộng dễ dàng; Mặt đá chống xước; Khung gỗ chắc chắn', 'assets/images/ban-an-mo-rong-1.jpg', 'SmartDesign', 14, '2025-10-23 08:44:55'),
(12, 4, 'Tủ Buffet Bếp Đa Năng', 'Không gian lưu trữ lớn cho đồ dùng nhà bếp. Gỗ MDF lõi xanh chống ẩm, sơn 2K cao cấp. Mặt tủ có thể dùng làm đảo bếp mini hoặc nơi chuẩn bị đồ ăn.', 13500000, 12000000, 0, 'Gỗ MDF lõi xanh', '160cm x 45cm x 90cm', 'Nhiều ngăn chứa; Chống ẩm; Tay nắm kim loại', 'assets/images/tu-bep-1.jpg', 'KitchenPro', 16, '2025-10-23 08:44:55'),
(13, 7, 'Giường Tầng Gỗ Thông', 'Giường tầng trẻ em thông minh, làm từ gỗ thông New Zealand. Sơn gốc nước an toàn, không chì, không độc hại. Kết cấu chắc chắn, tiết kiệm diện tích tối đa.', 11000000, 9800000, 0, 'Gỗ thông', '120cm x 200cm', 'Sơn gốc nước an toàn; Kết cấu chắc chắn; Tiết kiệm diện tích', 'assets/images/giuong-tang-1.jpg', 'KidHome', 22, '2025-10-23 08:44:55'),
(14, 2, 'Bàn Làm Việc Nâng Hạ Điện', 'Thay đổi chiều cao linh hoạt từ 70cm đến 120cm. Động cơ điện êm ái, ghi nhớ 4 vị trí. Bảo vệ sức khỏe cột sống, tăng hiệu quả làm việc.', 15000000, 13500000, 0, 'Gỗ MDF, Khung thép', '140cm x 70cm', 'Động cơ điện êm ái; Ghi nhớ 4 vị trí; Mặt bàn chống trầy', 'assets/images/ban-nang-ha-1.jpg', 'ErgoDesk', 18, '2025-10-23 08:44:55'),
(15, 3, 'Giường Ngủ Tối Giản Kiểu Nhật', 'Thiết kế sát sàn (platform), chất liệu gỗ thông tự nhiên 100%. Mang lại cảm giác an yên, mộc mạc và gần gũi với thiên nhiên.', 18000000, 16000000, 0, 'Gỗ thông', '160cm x 200cm', 'Phong cách tối giản; Gỗ tự nhiên; Dễ lắp ráp', 'assets/images/giuong-nhat-1.jpg', 'ZenStyle', 25, '2025-10-23 08:44:55'),
(16, 3, 'Bàn Trang Điểm Gỗ Sồi Có Gương LED', 'Gương cảm ứng với 3 chế độ ánh sáng (vàng, trắng, trung tính). Nhiều ngăn chứa đồ tiện lợi. Kèm ghế đôn bọc nỉ êm ái.', 11000000, 9800000, 0, 'Gỗ sồi', '100cm x 40cm x 135cm', 'Đèn LED 3 màu; Kèm ghế đôn; Ngăn kéo tiện lợi', 'assets/images/ban-trang-diem-1.jpg', 'BeautySpace', 2, '2025-11-28 10:36:56'),
(17, 1, 'Sofa Da Bò Ý Chesterfield', 'Vẻ đẹp cổ điển bất tử. Các chi tiết nút bấm đặc trưng và chất liệu da bò Ý cao cấp (full grain). Làm thủ công 100%, khung gỗ sồi già.', 85000000, 75000000, 0, 'Da bò thật', '280cm x 100cm x 80cm', 'Da bò Ý nhập khẩu; Làm thủ công; Khung gỗ sồi', 'assets/images/sofa-chesterfield-1.jpg', 'Chesterfield', 4, '2025-11-28 10:36:56'),
(18, 3, 'Tủ Đầu Giường Thông Minh', 'Tích hợp sạc không dây chuẩn Qi, loa bluetooth và đèn ngủ cảm ứng 3 chế độ. Mặt kính cường lực sang trọng. Giải pháp 3 trong 1 cho phòng ngủ hiện đại.', 5000000, 4600000, 0, 'Gỗ MDF, Kính cường lực', '50cm x 40cm x 55cm', 'Sạc không dây Qi; Loa Bluetooth; Đèn LED cảm ứng;Nút bấm hiện đại', 'assets/images/tu-dau-giuong-1.jpg', 'TechNap', 26, '2025-11-28 10:36:56'),
(19, 4, 'Kệ Sách Gỗ Tự Nhiên 5 Tầng', 'Kệ sách chắc chắn với 5 tầng lưu trữ rộng rãi. Gỗ sồi tự nhiên chống cong vênh, chịu lực tốt. Phù hợp cho sách, đồ trang trí, hồ sơ.', 8500000, 7800000, 0, 'Gỗ sồi', '120cm x 30cm x 180cm', 'Chịu lực tốt; Chống cong vênh; Gỗ tự nhiên', 'assets/images/ke-sach-go-1.jpg', 'BookWorm', 24, '2025-11-28 10:36:56'),
(20, 4, 'Tủ Giày Thông Minh Cửa Lật', 'Thiết kế mỏng gọn (sâu 24cm), sức chứa lớn (24-30 đôi giày). Gỗ MDF lõi xanh chống ẩm, cửa lật 2 lớp tiện lợi. Giúp không gian lối vào ngăn nắp.', 6200000, 5600000, 0, 'Gỗ MDF lõi xanh', '80cm x 24cm x 120cm', 'Cửa lật 2 lớp; Chứa được 24 đôi giày; Chống ẩm', 'assets/images/tu-giay-thong-minh-1.jpg', 'ShoeSmart', 35, '2025-11-28 10:36:56'),
(21, 5, 'Ghế Công Thái Học Ergonomic', 'Hỗ trợ toàn diện cho lưng, cổ và tay. Lưới Wintex nhập khẩu thoáng khí. Ngả lưng 135 độ, tựa đầu 3D, kê tay 4D. Khung hợp kim nhôm siêu bền.', 11000000, 9800000, 0, 'Lưới, Hợp kim nhôm', '65cm x 65cm x 115-125cm', 'Ngả lưng 135 độ; Tựa đầu 3D; Kê tay 4D', 'assets/images/ghe-ergonomic-1.jpg', 'ErgoChair', 19, '2025-11-28 10:36:56'),
(22, 4, 'Tủ Buffet Bếp (Loại 2)', 'Tủ buffet đa năng, mặt đá ceramic chống xước. Nhiều ngăn kéo và cánh tủ giảm chấn. Thiết kế hiện đại, phù hợp cho phòng ăn hoặc phòng khách.', 14000000, 12300000, 0, 'Gỗ MDF, Mặt đá', '150cm x 40cm x 85cm', 'Nhiều ngăn kéo; Cánh tủ giảm chấn; Chống ẩm', 'assets/images/tu-buffet-1.jpg', 'KitchenPro', 17, '2025-11-28 10:36:56'),
(23, 5, 'Ghế Papasan Thư Giãn', 'Ghế thư giãn hình tròn (tổ chim) làm từ mây tự nhiên 100%. Kèm nệm dày 15cm êm ái. Mang lại cảm giác thư thái tuyệt đối.', 4000000, 3500000, 0, 'Mây tự nhiên, Vải bố', 'D110cm', 'Thoáng mát; Thư giãn tối đa; Nệm dày êm ái', 'assets/images/ghe-papasan-1.jpg', 'ComfortZone', 26, '2025-11-28 10:36:56'),
(24, 6, 'Thảm Lông Cừu Thổ Nhĩ Kỳ', 'Thảm dệt thủ công từ len tự nhiên 100%. Họa tiết tinh xảo, độc đáo. Mang lại sự sang trọng và ấm áp cho không gian.', 13000000, 11500000, 0, 'Len tự nhiên', '200cm x 300cm', 'Dệt thủ công; Mềm mại, êm ái; Họa tiết độc đáo', 'assets/images/tham-long-cuu-1.jpg', 'RugArt', 19, '2025-11-28 10:36:56'),
(25, 4, 'Tủ Hồ Sơ Gỗ 3 Ngăn', 'Lưu trữ tài liệu an toàn với khóa an toàn cho ngăn trên cùng. Ray trượt 3 lớp êm ái, chịu tải nặng. Gỗ MDF phủ melamine chống xước.', 7000000, 6200000, 0, 'Gỗ MDF', '40cm x 50cm x 100cm', 'Khóa an toàn; Ray trượt êm; Chống ẩm', 'assets/images/tu-ho-so-1.jpg', 'OfficeSafe', 31, '2025-11-28 10:36:56'),
(26, 6, 'Gương Treo Tường Toàn Thân Viền Gỗ', 'Gương phôi Bỉ cao cấp cho hình ảnh trong và sắc nét, chống ố mốc. Viền gỗ sồi tự nhiên bo tròn mềm mại. Có thể treo tường hoặc tựa sàn.', 5500000, 4800000, 0, 'Gỗ sồi, Phôi Bỉ', '70cm x 170cm', 'Chống ố mốc; Hình ảnh sắc nét; Viền gỗ tự nhiên', 'assets/images/guong-toan-than-1.jpg', 'MirrorArt', 40, '2025-11-28 10:36:56'),
(27, 6, 'Đèn Sàn Cong Hiện Đại', 'Đèn sàn hình vòng cung (arc lamp) tạo điểm nhấn nghệ thuật cho góc đọc sách hoặc sofa. Thân thép sơn tĩnh điện, chao đèn vải lanh. Ánh sáng vàng ấm, có thể điều chỉnh độ sáng.', 6000000, 5200000, 0, 'Thép sơn tĩnh điện, Vải lanh', 'H200cm', 'Ánh sáng vàng ấm; Điều chỉnh độ sáng; Thiết kế hiện đại', 'assets/images/den-san-1.jpg', 'LightArc', 23, '2025-11-28 10:36:56'),
(28, 6, 'Bộ Tranh Canvas Trừu Tượng', 'Bộ 3 tranh canvas với gam màu hiện đại (cam, xám, vàng). In trên vải canvas chống thấm, mực in UV bền màu. Khung composite nhẹ, dễ treo lắp.', 4000000, 3500000, 0, 'Vải canvas, Khung composite', '50cm x 70cm (x3)', 'Màu sắc bền đẹp; Dễ treo lắp; Chống thấm nước', 'assets/images/tranh-canvas-1.jpg', 'ArtHome', 50, '2025-11-28 10:36:56'),
(29, 3, 'Giường Ngủ Có Ngăn Kéo', 'Tối ưu không gian lưu trữ với 4 ngăn kéo lớn bên dưới giường. Gỗ MDF lõi xanh chống ẩm, ray trượt giảm chấn. Đầu giường bọc nỉ êm ái.', 18000000, 16200000, 0, 'Gỗ MDF lõi xanh, Vải nỉ', '180cm x 200cm', 'Tiết kiệm không gian; Chống ẩm; Ray trượt giảm chấn', 'assets/images/giuong-ngan-keo-1.jpg', 'StorageBed', 18, '2025-11-28 10:36:56'),
(30, 1, 'Sofa Đơn Vải Bố Bắc Âu', 'Thiết kế đơn giản, màu sắc trung tính (xám nhạt), phù hợp để đọc sách. Khung gỗ sồi, nệm D40, vải bố thoáng mát.', 7500000, 6500000, 0, 'Vải bố, Gỗ sồi', '80cm x 85cm x 90cm', 'Thoáng mát; Nệm ngồi êm ái; Phong cách Scandinavian', 'assets/images/sofa-don-1.jpg', 'NordicStyle', 22, '2025-11-28 10:36:56'),
(31, 1, 'Sofa KIVIK 3 Chỗ', 'Sofa KIVIK rộng rãi với nệm mút hoạt tính êm ái, vỏ bọc có thể tháo rời và giặt máy. Thiết kế hiện đại, phù hợp nhiều phòng khách.', 18000000, 15990000, 0, 'Vải, Mút hoạt tính, Gỗ', '228cm x 95cm x 83cm', 'Vỏ bọc tháo rời; Nệm mút hoạt tính', 'assets/images/sofa-kivik-1.jpg', 'IKEA', 15, '2025-11-28 10:36:56'),
(32, 5, 'Ghế Công Thái Học Aeron', 'Ghế Aeron của Herman Miller, biểu tượng của thiết kế công thái học. Hỗ trợ tư thế ngồi tối ưu với lưới Pellicle thoáng khí.', 50000000, 45500000, 0, 'Lưới Pellicle, Hợp kim', '70cm x 70cm x 110cm', 'Hỗ trợ cột sống PostureFit SL; Lưới thoáng khí 8Z Pellicle', 'assets/images/ghe-aeron-1.jpg', 'Herman Miller', 10, '2025-11-28 10:36:56'),
(33, 2, 'Bàn Ăn Gỗ Sồi VEDDE', 'Bàn ăn VEDDE phong cách Scandinavian, gỗ công nghiệp phủ melamine sồi. Thiết kế chắc chắn, dễ dàng lau chùi.', 9000000, 7890000, 0, 'Gỗ công nghiệp (MFC)', '160cm x 90cm x 75cm', 'Chống trầy xước; Phong cách Bắc Âu', 'assets/images/ban-vedde-1.jpg', 'JYSK', 20, '2025-11-28 10:36:56'),
(34, 4, 'Tủ 3 Ngăn Kéo MALM', 'Tủ 3 ngăn kéo MALM với thiết kế đơn giản, tinh tế. Ngăn kéo chạy êm ái, có thể kết hợp với các nội thất khác trong series MALM.', 4000000, 3490000, 0, 'Ván gỗ dăm', '80cm x 48cm x 78cm', 'Ngăn kéo chạy êm; Thiết kế tối giản', 'assets/images/tu-malm-1.jpg', 'IKEA', 30, '2025-11-28 10:36:56'),
(35, 3, 'Giường Ngủ Bọc Nệm PAMA', 'Giường ngủ PAMA bọc nệm cao cấp, đầu giường thiết kế cao tạo cảm giác sang trọng. Khung gỗ sồi chắc chắn.', 22000000, 18500000, 0, 'Vải nỉ, Khung gỗ sồi', '180cm x 200cm', 'Đầu giường bọc nệm êm ái; Khung gỗ tự nhiên', 'assets/images/giuong-pama-1.jpg', 'Nhà Xinh', 12, '2025-11-28 10:36:56'),
(36, 1, 'Ghế Bành POÄNG', 'Ghế thư giãn POÄNG với khung gỗ bạch dương uốn cong, tạo độ đàn hồi thoải mái khi ngồi. Đệm vải êm, có thể tháo rời.', 2900000, 2290000, 0, 'Gỗ bạch dương, Vải', '68cm x 82cm x 100cm', 'Khung gỗ uốn cong đàn hồi; Đệm êm ái', 'assets/images/ghe-poang-1.jpg', 'IKEA', 25, '2025-11-28 10:36:56'),
(37, 2, 'Bàn Cà Phê LACK', 'Bàn cà phê LACK, thiết kế đơn giản, nhẹ và dễ di chuyển. Cấu trúc giấy tổ ong giúp giảm vật liệu mà vẫn chắc chắn.', 700000, 499000, 0, 'Ván gỗ dăm, Giấy tổ ong', '90cm x 55cm x 45cm', 'Nhẹ, dễ di chuyển; Giá cả phải chăng', 'assets/images/ban-lack-1.jpg', 'IKEA', 50, '2025-11-28 10:36:56'),
(38, 4, 'Kệ Sách BILLY', 'Kệ sách BILLY kinh điển, linh hoạt và có thể điều chỉnh độ cao các ngăn. Phù hợp cho thư viện gia đình.', 2500000, 1790000, 0, 'Ván gỗ dăm, Foil', '80cm x 28cm x 202cm', 'Điều chỉnh độ cao ngăn; Thiết kế vượt thời gian', 'assets/images/ke-billy-1.jpg', 'IKEA', 40, '2025-11-28 10:36:56'),
(39, 5, 'Ghế Ăn Gỗ Sồi TOLIX', 'Ghế Tolix phiên bản gỗ sồi, kết hợp giữa kim loại sơn tĩnh điện và mặt ngồi gỗ sồi, mang lại vẻ đẹp công nghiệp và ấm cúng.', 1800000, 1250000, 0, 'Thép sơn tĩnh điện, Gỗ sồi', '45cm x 46cm x 85cm', 'Phong cách công nghiệp (Industrial); Bền bỉ', 'assets/images/ghe-tolix-1.jpg', 'Tolix', 60, '2025-11-28 10:36:56'),
(40, 8, 'Bộ Sofa Ngoài Trời SOLLERÖN', 'Bộ sofa module ngoài trời SOLLERÖN, làm từ nhựa mây (nhựa giả mây) chống chịu thời tiết, nệm chống thấm nước.', 28000000, 24500000, 0, 'Nhựa mây, Hợp kim', '223cm x 144cm x 88cm', 'Chống chịu thời tiết; Nệm chống thấm; Thiết kế module', 'assets/images/sofa-solleron-1.jpg', 'IKEA', 8, '2025-11-28 10:36:56');

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
(25, 13, 'assets/images/giuong-tang-1.jpg'),
(26, 13, 'assets/images/giuong-tang-alt2.jpg'),
(27, 14, 'assets/images/ban-nang-ha-alt1.jpg'),
(28, 14, 'assets/images/ban-nang-ha-alt2.jpg'),
(29, 15, 'assets/images/giuong-nhat-alt1.jpg'),
(30, 15, 'assets/images/giuong-nhat-alt2.jpg'),
(33, 17, 'assets/images/sofa-chesterfield-1.jpg'),
(34, 17, 'assets/images/sofa-chesterfield-2.jpg'),
(35, 18, 'assets/images/tu-dau-giuong-1.jpg'),
(36, 18, 'assets/images/tu-dau-giuong-2.jpg'),
(37, 19, 'assets/images/ke-sach-go-1.jpg'),
(38, 19, 'assets/images/ke-sach-go-2.jpg'),
(39, 20, 'assets/images/tu-giay-thong-minh-1.jpg'),
(40, 20, 'assets/images/tu-giay-thong-minh-2.jpg'),
(41, 21, 'assets/images/ghe-ergonomic-1.jpg'),
(42, 21, 'assets/images/ghe-ergonomic-2.jpg'),
(43, 22, 'assets/images/tu-buffet-1.jpg'),
(44, 22, 'assets/images/tu-buffet-2.jpg'),
(45, 23, 'assets/images/ghe-papasan-1.jpg'),
(46, 23, 'assets/images/ghe-papasan-2.jpg'),
(47, 24, 'assets/images/tham-long-cuu-1.jpg'),
(48, 24, 'assets/images/tham-long-cuu-2.jpg'),
(49, 25, 'assets/images/tu-ho-so-1.jpg'),
(50, 25, 'assets/images/tu-ho-so-2.jpg'),
(51, 26, 'assets/images/guong-toan-than-1.jpg'),
(52, 26, 'assets/images/guong-toan-than-2.jpg'),
(53, 27, 'assets/images/den-san-1.jpg'),
(54, 27, 'assets/images/den-san-2.jpg'),
(55, 28, 'assets/images/tranh-canvas-1.jpg'),
(56, 28, 'assets/images/tranh-canvas-2.jpg'),
(57, 29, 'assets/images/giuong-ngan-keo-1.jpg'),
(58, 29, 'assets/images/giuong-ngan-keo-2.jpg'),
(59, 30, 'assets/images/sofa-don-1.jpg'),
(60, 30, 'assets/images/sofa-don-2.jpg'),
(61, 31, 'assets/images/sofa-kivik-1.jpg'),
(62, 31, 'assets/images/sofa-kivik-2.jpg'),
(63, 32, 'assets/images/ghe-aeron-1.jpg'),
(64, 32, 'assets/images/ghe-aeron-2.jpg'),
(65, 33, 'assets/images/ban-vedde-1.jpg'),
(66, 33, 'assets/images/ban-vedde-2.jpg'),
(67, 34, 'assets/images/tu-malm-1.jpg'),
(68, 34, 'assets/images/tu-malm-2.jpg'),
(69, 35, 'assets/images/giuong-pama-1.jpg'),
(70, 35, 'assets/images/giuong-pama-2.jpg'),
(71, 36, 'assets/images/ghe-poang-1.jpg'),
(72, 36, 'assets/images/ghe-poang-2.jpg'),
(73, 37, 'assets/images/ban-lack-1.jpg'),
(74, 37, 'assets/images/ban-lack-2.jpg'),
(75, 38, 'assets/images/ke-billy-1.jpg'),
(76, 38, 'assets/images/ke-billy-2.jpg'),
(77, 39, 'assets/images/ghe-tolix-1.jpg'),
(78, 39, 'assets/images/ghe-tolix-2.jpg'),
(79, 40, 'assets/images/sofa-solleron-1.jpg'),
(80, 40, 'assets/images/sofa-solleron-2.jpg'),
(121, 12, 'assets/images/tu-bep-1.jpg'),
(122, 12, 'assets/images/tu-bep-2.jpg'),
(123, 16, 'assets/images/ban-trang-diem-1.jpg'),
(124, 16, 'assets/images/ban-trang-diem-2.jpg');

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
(14, 15, 14, 5, 'Giường kiểu Nhật đẹp, tối giản. Gỗ thông thơm mùi tự nhiên. Rất thích.', '2025-10-23 18:00:00'),
(16, 11, 2, 4, 'Bàn ăn thông minh, rất tiện lợi khi nhà có khách. Mặt đá lau chùi dễ dàng.', '2025-10-24 08:15:00'),
(17, 12, 5, 5, 'Tủ bếp đẹp, nhiều ngăn chứa. Tuy nhiên cánh tủ hơi nặng.', '2025-10-24 09:00:00'),
(18, 13, 6, 3, 'Giường tầng chắc chắn, bé nhà mình rất thích. Sơn an toàn không mùi.', '2025-10-24 10:30:00'),
(19, 14, 7, 5, 'Bàn nâng hạ hoạt động êm, giúp tôi thay đổi tư thế làm việc hiệu quả.', '2025-10-24 11:45:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `subscribers`
--

CREATE TABLE `subscribers` (
  `email` varchar(150) NOT NULL,
  `createdAt` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(2, 'Lý Ngọc Long', 'long.ly@example.com', '$2a$12$6Nx5RXPT4dHrJ/vWZOA9FebpvKlLHWPyt1jA7JdxnBjebhAyoev6a', '0922222222', '20 Hai Bà Trưng, Quận 1, TP.HCM', 'Admin', '2025-10-23 04:06:33'),
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
(16, 'Đỗ Công Minh', 'mdang2186@gmail.com', '$2a$10$n15qSvM2pwLXorC9rFhUde7rNS2iPakw24SoLxvjuaW9WhNc1.hYe', '0568658444', 'trương định HN', 'Customer', '2025-11-04 00:00:00'),
(17, 'Đặng Đình Thế Hiếu', 'danghieu7bthcsnh@gmail.com', '$2a$10$2jwywGaeFWDSdknwzG/.h.uQg4I1vTkV4U8SMByLxdpLkmVR0RxwW', NULL, NULL, 'Customer', '2025-11-28 20:49:54');

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
-- Chỉ mục cho bảng `feedbacks`
--
ALTER TABLE `feedbacks`
  ADD PRIMARY KEY (`FeedbackID`);

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
-- Chỉ mục cho bảng `subscribers`
--
ALTER TABLE `subscribers`
  ADD PRIMARY KEY (`email`);

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
  MODIFY `CategoryID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `contacts`
--
ALTER TABLE `contacts`
  MODIFY `ContactID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT cho bảng `feedbacks`
--
ALTER TABLE `feedbacks`
  MODIFY `FeedbackID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `orderitems`
--
ALTER TABLE `orderitems`
  MODIFY `OrderItemID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT cho bảng `orders`
--
ALTER TABLE `orders`
  MODIFY `OrderID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT cho bảng `products`
--
ALTER TABLE `products`
  MODIFY `ProductID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT cho bảng `product_images`
--
ALTER TABLE `product_images`
  MODIFY `ImageID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT cho bảng `reviews`
--
ALTER TABLE `reviews`
  MODIFY `ReviewID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

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
