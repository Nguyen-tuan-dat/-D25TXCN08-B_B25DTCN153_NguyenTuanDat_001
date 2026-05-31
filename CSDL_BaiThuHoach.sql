-- PHẦN 1:
CREATE DATABASE LiveStudioDB;
USE LiveStudioDB;

CREATE TABLE Creator(
    creator_id VARCHAR(5) PRIMARY KEY,
    creator_name VARCHAR(100) NOT NULL,
    creator_email VARCHAR(100) NOT NULL UNIQUE,
    creator_phone VARCHAR(15) NOT NULL UNIQUE,
    creator_platform VARCHAR(50) NOT NULL
);

CREATE TABLE Studio(
    studio_id VARCHAR(5) PRIMARY KEY,
    studio_name VARCHAR(100) NOT NULL,
    studio_location VARCHAR(100) NOT NULL,
    hourly_price DECIMAL(10,2) NOT NULL,
    studio_status VARCHAR(20) NOT NULL
);

CREATE TABLE LiveSession(
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    creator_id VARCHAR(5) NOT NULL,
    studio_id VARCHAR(5) NOT NULL,
    session_date DATE NOT NULL,
    duration_hours INT NOT NULL,
    CONSTRAINT fk_session_creator
        FOREIGN KEY (creator_id) REFERENCES Creator(creator_id),
    CONSTRAINT fk_session_studio
        FOREIGN KEY (studio_id) REFERENCES Studio(studio_id)
);

CREATE TABLE Payment(
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    CONSTRAINT fk_payment_session
        FOREIGN KEY (session_id) REFERENCES LiveSession(session_id)
);

-- Ý2. CHÈN DỮ LIỆU
INSERT INTO Creator(creator_id, creator_name, creator_email, creator_phone, creator_platform) VALUES
('CR01','Nguyen Van A','a@live.com','0901111111','TikTok'),
('CR02','Tran Thi B','b@live.com','0902222222','YouTube'),
('CR03','Le Minh C','c@live.com','0903333333','Facebook'),
('CR04','Pham Thi D','d@live.com','0904444444','TikTok'),
('CR05','Vu Hoang E','e@live.com','0905555555','Shopee Live');

INSERT INTO Studio(studio_id, studio_name, studio_location, hourly_price, studio_status) VALUES
('ST01','Studio A','Ha Noi',20.00,'Available'),
('ST02','Studio B','HCM',25.00,'Available'),
('ST03','Studio C','Da Nang',30.00,'Booked'),
('ST04','Studio D','Ha Noi',22.00,'Available'),
('ST05','Studio E','Can Tho',18.00,'Maintenance');

INSERT INTO LiveSession(session_id, creator_id, studio_id, session_date, duration_hours) VALUES
(1,'CR01','ST01','2025-05-01',3),
(2,'CR02','ST02','2025-05-02',4),
(3,'CR03','ST03','2025-05-03',2),
(4,'CR01','ST04','2025-05-04',5),
(5,'CR05','ST02','2025-05-05',1);

INSERT INTO Payment(payment_id, session_id, payment_method, payment_amount, payment_date) VALUES
(1,1,'Cash',60.00,'2025-05-01'),
(2,2,'Credit Card',100.00,'2025-05-02'),
(3,3,'Bank Transfer',60.00,'2025-05-03'),
(4,4,'Credit Card',110.00,'2025-05-04'),
(5,5,'Cash',25.00,'2025-05-05');

-- Ý3. CẬP NHẬT CREATOR
UPDATE Creator
SET creator_platform = 'YouTube'
WHERE creator_id = 'CR03';


-- Ý4. CẬP NHẬT STUDIO ST05
UPDATE Studio
SET studio_status = 'Available', hourly_price = hourly_price * 0.9
WHERE studio_id = 'ST05';


-- Ý5. XÓA PAYMENT
DELETE FROM Payment
WHERE payment_method = 'Cash'
AND payment_date < '2025-05-03';

-- PHẦN 2: TRUY VẤN CƠ BẢN
-- ý6.
SELECT studio_id, studio_name, hourly_price, studio_status
FROM Studio
WHERE studio_status = 'Available'
AND hourly_price > 20;

-- ý7.
SELECT creator_name, creator_phone
FROM Creator
WHERE creator_platform = 'TikTok';

-- ý8.
SELECT studio_id, studio_name, hourly_price
FROM Studio
ORDER BY hourly_price DESC;

-- ý9.
SELECT payment_id, session_id, payment_method, payment_amount, payment_date
FROM Payment
WHERE payment_method = 'Credit Card'
LIMIT 3;

-- ý10.
SELECT creator_id, creator_name
FROM Creator
LIMIT 2 OFFSET 2;

-- PHẦN 3: TRUY VẤN NÂNG CAO
-- ý1. Danh sách livestream
SELECT
    ls.session_id,
    c.creator_name,
    s.studio_name,
    ls.duration_hours,
    p.payment_amount
FROM LiveSession ls
INNER JOIN Creator c
    ON ls.creator_id = c.creator_id
INNER JOIN Studio s
    ON ls.studio_id = s.studio_id
INNER JOIN Payment p
    ON ls.session_id = p.session_id;

-- Ý2. Studio và số lần được thuê
SELECT
    s.studio_id,
    s.studio_name,
    COUNT(ls.session_id) AS usage_count
FROM Studio s
LEFT JOIN LiveSession ls
    ON s.studio_id = ls.studio_id
GROUP BY s.studio_id, s.studio_name;

-- ý3. Tổng doanh thu theo phương thức thanh toán
SELECT
    payment_method,
    SUM(payment_amount) AS total_revenue
FROM Payment
GROUP BY payment_method;

-- ý4. Creator có từ 2 session trở lên
SELECT
    c.creator_id,
    c.creator_name,
    COUNT(ls.session_id) AS total_sessions
FROM Creator c
INNER JOIN LiveSession ls
    ON c.creator_id = ls.creator_id
GROUP BY c.creator_id, c.creator_name
HAVING COUNT(ls.session_id) >= 2;

-- Ý5. Studio có giá cao hơn trung bình
SELECT studio_id, studio_name, hourly_price
FROM Studio
WHERE hourly_price > (
	SELECT AVG(hourly_price)
	FROM Studio);

-- Ý6. Creator từng livestream tại StudioB
SELECT DISTINCT c.creator_name, c.creator_email
FROM Creator c
INNER JOIN LiveSession ls
    ON c.creator_id = ls.creator_id
INNER JOIN Studio s
    ON ls.studio_id = s.studio_id
WHERE s.studio_name = 'Studio B';

-- Ý7. Báo cáo tổng hợp
SELECT
    ls.session_id,
    c.creator_name,
    s.studio_name,
    p.payment_method,
    p.payment_amount
FROM LiveSession ls
INNER JOIN Creator c
    ON ls.creator_id = c.creator_id
INNER JOIN Studio s
    ON ls.studio_id = s.studio_id
INNER JOIN Payment p
    ON ls.session_id = p.session_id
ORDER BY ls.session_id;
