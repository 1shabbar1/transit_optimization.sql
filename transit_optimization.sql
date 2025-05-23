/*
  Project: Public Transit Optimization & Delay Analysis System
  Author: Shabbar Poonawala
  Type: MySQL
  Description:
    A SQL project to track public transit routes, stops, schedules, GPS logs,
    delays, passenger activity, and weather conditions. Includes analytical queries
    for delay trends, ridership patterns, and operational efficiency.
*/

-- 🔧 1. Create Tables

-- Routes Table
CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    route_name VARCHAR(50),
    transit_type VARCHAR(20)
);

-- Stops Table
CREATE TABLE stops (
    stop_id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT,
    stop_name VARCHAR(100),
    lat DECIMAL(9,6),
    lon DECIMAL(9,6),
    FOREIGN KEY (route_id) REFERENCES routes(route_id)
);

-- Schedules Table
CREATE TABLE schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT,
    stop_id INT,
    arrival_time TIME,
    departure_time TIME,
    FOREIGN KEY (route_id) REFERENCES routes(route_id),
    FOREIGN KEY (stop_id) REFERENCES stops(stop_id)
);

-- Vehicle GPS Logs
CREATE TABLE vehicle_gps_logs (
    gps_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id VARCHAR(10),
    route_id INT,
    timestamp DATETIME,
    lat DECIMAL(9,6),
    lon DECIMAL(9,6),
    status VARCHAR(20),
    FOREIGN KEY (route_id) REFERENCES routes(route_id)
);

-- Passenger Counts
CREATE TABLE passenger_counts (
    count_id INT AUTO_INCREMENT PRIMARY KEY,
    stop_id INT,
    timestamp DATETIME,
    boarding_count INT,
    alighting_count INT,
    FOREIGN KEY (stop_id) REFERENCES stops(stop_id)
);

-- Delay Reports
CREATE TABLE delay_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id VARCHAR(10),
    route_id INT,
    timestamp DATETIME,
    delay_minutes INT,
    cause VARCHAR(100),
    FOREIGN KEY (route_id) REFERENCES routes(route_id)
);

-- Weather Logs
CREATE TABLE weather_logs (
    weather_id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp DATETIME,
    temperature DECIMAL(4,1),
    precipitation DECIMAL(4,2),
    `condition` VARCHAR(50)
);

-- 🧪 2. Insert Sample Data

-- Routes
INSERT INTO routes (route_name, transit_type) VALUES
('Red Line', 'Train'),
('Green Line', 'Bus');

-- Stops
INSERT INTO stops (route_id, stop_name, lat, lon) VALUES
(1, 'Central Station', 40.7128, -74.0060),
(1, 'Park Street', 40.7138, -74.0080),
(2, 'Main Avenue', 40.7500, -73.9900);

-- Schedules
INSERT INTO schedules (route_id, stop_id, arrival_time, departure_time) VALUES
(1, 1, '08:00:00', '08:05:00'),
(1, 2, '08:15:00', '08:20:00');

-- Delay Reports
INSERT INTO delay_reports (vehicle_id, route_id, timestamp, delay_minutes, cause) VALUES
('T101', 1, '2025-04-14 08:15:00', 10, 'Signal Failure'),
('T101', 1, '2025-04-14 18:30:00', 5, 'Weather');

-- Weather Logs
INSERT INTO weather_logs (timestamp, temperature, precipitation, `condition`) VALUES
('2025-04-14 08:00:00', 22.5, 0.0, 'Clear'),
('2025-04-14 18:00:00', 19.0, 2.3, 'Rain');

-- Passenger Counts
INSERT INTO passenger_counts (stop_id, timestamp, boarding_count, alighting_count) VALUES
(1, '2025-04-14 08:00:00', 30, 5),
(2, '2025-04-14 08:20:00', 20, 10),
(3, '2025-04-14 09:00:00', 50, 15);

-- Vehicle GPS Logs
INSERT INTO vehicle_gps_logs (vehicle_id, route_id, timestamp, lat, lon, status) VALUES
('T101', 1, '2025-04-14 08:10:00', 40.7130, -74.0070, 'Delayed'),
('T101', 1, '2025-04-14 08:20:00', 40.7138, -74.0080, 'Running');

-- 📊 3. SELECT Queries for Analysis

-- 1. Average Delay Per Route
SELECT r.route_name, AVG(d.delay_minutes) AS avg_delay
FROM delay_reports d
JOIN routes r ON d.route_id = r.route_id
GROUP BY r.route_name;

-- 2. Busiest Stops by Boarding
SELECT s.stop_name, SUM(p.boarding_count) AS total_boardings
FROM passenger_counts p
JOIN stops s ON p.stop_id = s.stop_id
GROUP BY s.stop_name
ORDER BY total_boardings DESC
LIMIT 5;

-- 3. Delays During Rainy Weather
SELECT r.route_name, d.timestamp, d.delay_minutes, w.`condition`
FROM delay_reports d
JOIN weather_logs w ON DATE(d.timestamp) = DATE(w.timestamp)
JOIN routes r ON d.route_id = r.route_id
WHERE w.`condition` = 'Rain';

-- 4. Peak Hour Ridership (7 AM – 10 AM)
SELECT HOUR(timestamp) AS hour, SUM(boarding_count) AS total_boardings
FROM passenger_counts
WHERE HOUR(timestamp) BETWEEN 7 AND 10
GROUP BY hour
ORDER BY total_boardings DESC;

-- 5. Current Vehicle Status per Route
SELECT r.route_name, v.vehicle_id, v.timestamp, v.status
FROM vehicle_gps_logs v
JOIN routes r ON v.route_id = r.route_id
ORDER BY v.timestamp DESC;
