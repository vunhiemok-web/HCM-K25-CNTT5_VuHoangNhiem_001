CREATE DATABASE IF NOT EXISTS Logistics;
USE Logistics;

DROP TABLE IF EXISTS Delivery_Log;
DROP TABLE IF EXISTS Delivery_Orders;
DROP TABLE IF EXISTS Shipments;
DROP TABLE IF EXISTS Vehicle_Details;
DROP TABLE IF EXISTS Shippers;

CREATE TABLE Shippers(
	driver_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) UNIQUE,
    license_type VARCHAR(5),
    rating FLOAT DEFAULT 5.0,
    CONSTRAINT CHECK(rating BETWEEN 0.0 AND 5.0)
);

CREATE TABLE Vehicle_Details(
	vehicle_id INT PRIMARY KEY,
    driver_id INT,
    license_plate VARCHAR(25) UNIQUE,
    vehicle_type ENUM("Truck", "Motorbike", "Container"),
    max_payload INT,
    CONSTRAINT CHECK(max_payload > 0),
    FOREIGN KEY(driver_id) REFERENCES Shippers(driver_id)
);

CREATE TABLE Shipments(
	shipment_id INT PRIMARY KEY,
    product_name VARCHAR(50), 
    actual_weight DECIMAL(10,2),
    shipment_value INT,
    shipment_status ENUM("In Transit", "Delivered", "Returned"),
    CONSTRAINT CHECK(actual_weight > 0)
);

CREATE TABLE Delivery_Orders(
	order_id INT PRIMARY KEY,
    shipment_id INT,
    driver_id INT,
    vehicle_id INT,
    assigned_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipping_fee INT,
    order_status ENUM("Pending", "Processing", "Finished", "Cancelled"),
    FOREIGN KEY(shipment_id) REFERENCES Shipments(shipment_id),
    FOREIGN KEY(driver_id) REFERENCES Shippers(driver_id),
    FOREIGN KEY(vehicle_id) REFERENCES Vehicle_Details(vehicle_id)
);

CREATE TABLE Delivery_Log(
	log_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    current_location VARCHAR(50),
    log_time TIMESTAMP,
    note TEXT,
    FOREIGN KEY(order_id) REFERENCES Delivery_Orders(order_id)
);

INSERT INTO Shippers(full_name, phone_number, license_type, rating)
VALUES ("Nguyen Van A", "0901234567", "C", 4.8),
		("Tran Thi Binh", "0912345678", "A2", 5.0),
        ("Le Hoang Nam", "0983456789", "FC", 4.2),
        ("Pham Minh Duc", "0354567890", "B2", 4.9),
        ("Hoang Quoc Viet", "0775678901", "C", 4.7);
        
INSERT INTO Vehicle_Details
VALUES (101, 1, "29C-123.45", "Truck", 3500),
		(102, 2, "59A-888.88", "Motorbike", 500),
        (103, 3, "15R-999.99", "Container", 32000),
        (104, 4, "30F-111.22", "Truck", 1500),
        (105, 5, "43C-444.55", "Truck", 5000);
        
INSERT INTO Shipments
VALUES (5001, "Smart TV Samsung 55 inch", 25.5, 15000000, "In Transit"),
		(5002, "Laptop Dell XPS", 2.0, 35000000, "Delivered"),
        (5003, "Máy nén khí công nghiệp", 450.0, 120000000, "In Transit"),
        (5004, "Thùng trái cây nhập khẩu", 115.0, 2500000, "Returned"),
        (5005, "Máy giặt LG Inverter", 70.0, 9500000, "In Transit");
        
INSERT INTO Delivery_Orders
VALUES (9001, 5001, 1, 101,"2024-05-20 08:00:00", 2000000, "Processing"),
		(9002, 5002, 2, 102, "2024-05-20 09:30:00", 3500000, "Finished"),
        (9003, 5003, 3, 103, "2024-05-20 10:15:00", 2500000, "Processing"),
        (9004, 5004, 4, 104, "2024-05-21 07:00:00", 1500000, "Finished"),
        (9005, 5005, 5, 105, "2024-05-21 08:45:00", 2500000, "Pending");
        
INSERT INTO Delivery_Log(order_id, current_location, log_time, note)
VALUES (9001, "Kho tổng (Hà Nội)", "2024-05-20 08:15:00", "Rời kho"),
		(9002, "Trạm thu phí Phủ Lý", "2024-05-20 10:00:00", "Đang giao"),
        (9003,  "Quận 1, TP.HCM", "2024-05-20 10:30:00", "Đã đến điểm đích"),
        (9004, "Cảng Hải Phòng", " 2024-05-21 11:00:00", "Rời kho"),
        (9005, "Kho hoàn hàng (Đà Nẵng)", "2024-05-21 14:00:00", "Đã nhập kho trả hàng");
     
SET SQL_SAFE_UPDATES = 0;

UPDATE Delivery_Orders de_or
JOIN Shipments s
SET de_or.shipping_fee = de_or.shipping_fee * 1.1
WHERE order_status = "Finished" and s.actual_weight > 100;

-- DELETE FROM Delivery_Orders
-- WHERE log_time < (SELECT log_time FROM Delivery_Orders);

SET SQL_SAFE_UPDATES = 1;

SELECT license_plate, vehicle_type, max_payload FROM Vehicle_Details
WHERE max_payload > 5000 OR vehicle_type = "Container";

SELECT full_name, phone_number FROM Shippers
WHERE rating >= 4.5 AND phone_number LIKE "090%";

SELECT * FROM Shipments
ORDER BY shipment_value DESC
LIMIT 2 OFFSET 2;

SELECT sp.full_name, sm.shipment_id, sm.product_name, de_or.shipping_fee, de_or.assigned_time FROM Delivery_Orders de_or
JOIN Shippers sp
ON sp.driver_id = de_or.driver_id
JOIN Shipments sm
ON sm.shipment_id = de_or.shipment_id;

SELECT sp.full_name, de_or.shipping_fee AS Tong_phi_van_chuyen FROM Delivery_Orders de_or
JOIN Shippers sp
ON sp.driver_id = de_or.driver_id
WHERE de_or.shipping_fee > 3000000;

SELECT full_name, phone_number, license_type, rating FROM Shippers
WHERE rating = (SELECT MAX(rating) FROM Shippers);

CREATE INDEX idx_shipment_status_value
ON Shipments(shipment_status, shipment_value);

CREATE VIEW vw_driver_performance AS
SELECT sp.full_name, COUNT(de_or.order_id), SUM(de_or.shipping_fee)
FROM Shippers sp
JOIN Delivery_Orders de_or
GROUP BY sp.full_name
HAVING de_or.order_status != "Cancelled";

