-- RouteSafe Database Schema Setup for MySQL (XAMPP phpMyAdmin)
-- Host: localhost    Database: routesafe_db
-- ------------------------------------------------------

CREATE DATABASE IF NOT EXISTS `routesafe_db`;
USE `routesafe_db`;

-- Set foreign key checks to 0 during drop/recreation
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `trips`;
DROP TABLE IF EXISTS `bus_locations`;
DROP TABLE IF EXISTS `parent_bus`;
DROP TABLE IF EXISTS `bus_routes`;
DROP TABLE IF EXISTS `buses`;
DROP TABLE IF EXISTS `routes`;
DROP TABLE IF EXISTS `users`;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. users table: Stores login credentials and profile details for Admins, Drivers, and Parents.
CREATE TABLE `users` (
  `user_id` INT AUTO_INCREMENT PRIMARY KEY,
  `full_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) UNIQUE NOT NULL,
  `phone` VARCHAR(15) NOT NULL,
  `password` VARCHAR(255) NOT NULL, -- Stored as Bcrypt/SHA256 encrypted string
  `role` ENUM('Admin', 'Driver', 'Parent') NOT NULL DEFAULT 'Parent',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. routes table: Stores school bus navigation paths.
CREATE TABLE `routes` (
  `route_id` INT AUTO_INCREMENT PRIMARY KEY,
  `route_name` VARCHAR(100) NOT NULL,
  `start_location` VARCHAR(100) NOT NULL,
  `destination` VARCHAR(100) NOT NULL,
  `distance` DECIMAL(5,2) NOT NULL -- Distance in km
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. buses table: Stores vehicle data and links to the assigned driver.
CREATE TABLE `buses` (
  `bus_id` INT AUTO_INCREMENT PRIMARY KEY,
  `bus_number` VARCHAR(20) NOT NULL UNIQUE,
  `registration_no` VARCHAR(30) NOT NULL UNIQUE,
  `driver_id` INT DEFAULT NULL, -- Assigned driver ID from users
  `status` ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
  CONSTRAINT `fk_buses_driver` FOREIGN KEY (`driver_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. bus_routes table: Junction table associating buses with routes.
CREATE TABLE `bus_routes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `bus_id` INT NOT NULL,
  `route_id` INT NOT NULL,
  CONSTRAINT `fk_busroutes_bus` FOREIGN KEY (`bus_id`) REFERENCES `buses` (`bus_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_busroutes_route` FOREIGN KEY (`route_id`) REFERENCES `routes` (`route_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY `idx_bus_route` (`bus_id`, `route_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. parent_bus table: Junction table assigning parents to their child's bus.
CREATE TABLE `parent_bus` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `parent_id` INT NOT NULL, -- User ID of the parent (Role must be Parent)
  `bus_id` INT NOT NULL,
  CONSTRAINT `fk_parentbus_parent` FOREIGN KEY (`parent_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_parentbus_bus` FOREIGN KEY (`bus_id`) REFERENCES `buses` (`bus_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY `idx_parent_bus` (`parent_id`, `bus_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. bus_locations table: Real-time GPS coordinate stream.
CREATE TABLE `bus_locations` (
  `location_id` INT AUTO_INCREMENT PRIMARY KEY,
  `bus_id` INT NOT NULL,
  `latitude` DECIMAL(10,8) NOT NULL,
  `longitude` DECIMAL(11,8) NOT NULL,
  `speed` DECIMAL(5,2) DEFAULT '0.00', -- Speed in km/h
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `fk_locations_bus` FOREIGN KEY (`bus_id`) REFERENCES `buses` (`bus_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. trips table: Historical and active journeys.
CREATE TABLE `trips` (
  `trip_id` INT AUTO_INCREMENT PRIMARY KEY,
  `bus_id` INT NOT NULL,
  `driver_id` INT NOT NULL,
  `route_id` INT NOT NULL,
  `trip_date` DATE NOT NULL,
  `start_time` DATETIME DEFAULT NULL,
  `end_time` DATETIME DEFAULT NULL,
  `status` ENUM('Running', 'Completed') NOT NULL DEFAULT 'Running',
  CONSTRAINT `fk_trips_bus` FOREIGN KEY (`bus_id`) REFERENCES `buses` (`bus_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_trips_driver` FOREIGN KEY (`driver_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_trips_route` FOREIGN KEY (`route_id`) REFERENCES `routes` (`route_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. notifications table: Notification feed broadcasted to parents.
CREATE TABLE `notifications` (
  `notification_id` INT AUTO_INCREMENT PRIMARY KEY,
  `parent_id` INT NOT NULL, -- Target parent user ID
  `title` VARCHAR(100) NOT NULL,
  `message` TEXT NOT NULL,
  `sent_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('Read', 'Unread') NOT NULL DEFAULT 'Unread',
  CONSTRAINT `fk_notifications_parent` FOREIGN KEY (`parent_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert Mock Admin Account for offline testing reference
-- Password hash placeholder (bcrypt for 'password123')
INSERT INTO `users` (`full_name`, `email`, `phone`, `password`, `role`) 
VALUES ('System Admin', 'admin@routesafe.com', '+15550192834', '$2b$12$Ksf/S4uH6U8D7018n4y1nOlN3s43O7g7O.G7o5d5hK4.Y2V5y56wO', 'Admin')
ON DUPLICATE KEY UPDATE `email`=`email`;
