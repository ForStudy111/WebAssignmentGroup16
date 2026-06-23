-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3307
-- Generation Time: Jun 21, 2026 at 09:57 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `counseling_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `availability`
--

CREATE TABLE `availability` (
  `id` int(11) NOT NULL,
  `counselor` varchar(50) DEFAULT NULL,
  `available_date` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `schedule_id` int(11) NOT NULL,
  `booking_date` date NOT NULL,
  `booking_status` varchar(20) NOT NULL DEFAULT 'PENDING',
  `cancelled_by` varchar(20) DEFAULT NULL,
  `google_event_id` varchar(255) DEFAULT NULL,
  `google_event_link` varchar(500) DEFAULT NULL,
  `calendar_sync_status` varchar(20) NOT NULL DEFAULT 'NOT_SYNCED'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `user_id`, `schedule_id`, `booking_date`, `booking_status`, `cancelled_by`, `google_event_id`, `google_event_link`, `calendar_sync_status`) VALUES
(1, 2, 1, '2026-06-21', 'COMPLETED', NULL, NULL, NULL, 'NOT_CONNECTED'),
(2, 3, 2, '2026-06-21', 'CANCELLED', 'COUNSELOR', NULL, NULL, 'NOT_SYNCED'),
(3, 2, 3, '2026-06-20', 'REJECTED', NULL, NULL, NULL, 'NOT_SYNCED'),
(4, 3, 4, '2026-06-20', 'CANCELLED', 'STUDENT', NULL, NULL, 'NOT_SYNCED'),
(5, 2, 5, '2026-06-20', 'CANCELLED', 'COUNSELOR', NULL, NULL, 'NOT_SYNCED'),
(6, 3, 6, '2026-06-20', 'COMPLETED', NULL, NULL, NULL, 'NOT_SYNCED'),
(7, 2, 9, '2026-06-20', 'CANCELLED', 'ADMIN', NULL, NULL, 'NOT_SYNCED'),
(8, 2, 10, '2026-06-21', 'REJECTED', NULL, NULL, NULL, 'NOT_SYNCED');

-- --------------------------------------------------------

--
-- Table structure for table `counsellors`
--

CREATE TABLE `counsellors` (
  `counsellor_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `counsellor_name` varchar(100) NOT NULL,
  `specialization` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `office_location` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `counsellors`
--

INSERT INTO `counsellors` (`counsellor_id`, `user_id`, `counsellor_name`, `specialization`, `email`, `phone_number`, `office_location`) VALUES
(1, 4, 'Dr. Sarah Smith', 'Academic Stress', 'sarah@counselling.com', '0123333333', 'Block C, Room 203'),
(2, 5, 'Dr. John Lee', 'Personal and Career Counselling', 'john@counselling.com', '0124444444', 'Block C, Room 205');

-- --------------------------------------------------------

--
-- Table structure for table `google_calendar_connections`
--

CREATE TABLE `google_calendar_connections` (
  `connection_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `google_calendar_id` varchar(255) NOT NULL DEFAULT 'primary',
  `refresh_token` text DEFAULT NULL,
  `sync_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `last_synced_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `patient_records`
--

CREATE TABLE `patient_records` (
  `student_username` varchar(50) NOT NULL,
  `medical_notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schedules`
--

CREATE TABLE `schedules` (
  `schedule_id` int(11) NOT NULL,
  `counsellor_id` int(11) NOT NULL,
  `available_date` date NOT NULL,
  `available_time` time NOT NULL,
  `availability_status` varchar(20) NOT NULL DEFAULT 'AVAILABLE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `schedules`
--

INSERT INTO `schedules` (`schedule_id`, `counsellor_id`, `available_date`, `available_time`, `availability_status`) VALUES
(1, 1, '2026-06-22', '09:00:00', 'BOOKED'),
(2, 1, '2026-06-22', '11:00:00', 'AVAILABLE'),
(3, 1, '2026-06-23', '10:00:00', 'AVAILABLE'),
(4, 2, '2026-06-23', '13:00:00', 'AVAILABLE'),
(5, 2, '2026-06-24', '15:00:00', 'AVAILABLE'),
(6, 1, '2026-06-20', '10:00:00', 'BOOKED'),
(7, 2, '2026-06-25', '09:00:00', 'AVAILABLE'),
(8, 1, '2026-06-25', '14:30:00', 'AVAILABLE'),
(9, 2, '2026-06-26', '16:00:00', 'AVAILABLE'),
(10, 1, '2026-06-22', '17:50:00', 'AVAILABLE');

-- --------------------------------------------------------

--
-- Table structure for table `session_records`
--

CREATE TABLE `session_records` (
  `record_id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `counsellor_id` int(11) NOT NULL,
  `session_notes` text NOT NULL,
  `feedback` text DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `session_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `session_records`
--

INSERT INTO `session_records` (`record_id`, `booking_id`, `counsellor_id`, `session_notes`, `feedback`, `rating`, `session_date`) VALUES
(1, 6, 1, 'Student discussed academic stress and agreed to follow a weekly study plan.', 'The session was helpful and clear.', 5, '2026-06-20'),
(2, 1, 1, 'good job', 'what the hell', 5, '2026-06-22');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'STUDENT'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `full_name`, `email`, `phone_number`, `role`) VALUES
(1, 'admin', 'admin123', 'System Administrator', 'admin@counselling.com', '0120000000', 'ADMIN'),
(2, 'student1', 'stud123', 'Alex Johnson', 'alex@student.com', '0121111111', 'STUDENT'),
(3, 'student2', 'stud456', 'Emma Wilson', 'emma@student.com', '0122222222', 'STUDENT'),
(4, 'counselor1', 'pass123', 'Dr. Sarah Smith', 'sarah@counselling.com', '0123333333', 'COUNSELOR'),
(5, 'counselor2', 'pass456', 'Dr. John Lee', 'john@counselling.com', '0124444444', 'COUNSELOR');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `availability`
--
ALTER TABLE `availability`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `fk_booking_user` (`user_id`),
  ADD KEY `idx_booking_schedule` (`schedule_id`);

--
-- Indexes for table `counsellors`
--
ALTER TABLE `counsellors`
  ADD PRIMARY KEY (`counsellor_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `google_calendar_connections`
--
ALTER TABLE `google_calendar_connections`
  ADD PRIMARY KEY (`connection_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `patient_records`
--
ALTER TABLE `patient_records`
  ADD PRIMARY KEY (`student_username`);

--
-- Indexes for table `schedules`
--
ALTER TABLE `schedules`
  ADD PRIMARY KEY (`schedule_id`),
  ADD UNIQUE KEY `uq_counsellor_slot` (`counsellor_id`,`available_date`,`available_time`);

--
-- Indexes for table `session_records`
--
ALTER TABLE `session_records`
  ADD PRIMARY KEY (`record_id`),
  ADD UNIQUE KEY `booking_id` (`booking_id`),
  ADD KEY `fk_record_counsellor` (`counsellor_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `availability`
--
ALTER TABLE `availability`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `counsellors`
--
ALTER TABLE `counsellors`
  MODIFY `counsellor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `google_calendar_connections`
--
ALTER TABLE `google_calendar_connections`
  MODIFY `connection_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `schedules`
--
ALTER TABLE `schedules`
  MODIFY `schedule_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `session_records`
--
ALTER TABLE `session_records`
  MODIFY `record_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `fk_booking_schedule` FOREIGN KEY (`schedule_id`) REFERENCES `schedules` (`schedule_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_booking_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `counsellors`
--
ALTER TABLE `counsellors`
  ADD CONSTRAINT `fk_counsellor_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `google_calendar_connections`
--
ALTER TABLE `google_calendar_connections`
  ADD CONSTRAINT `fk_google_connection_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `patient_records`
--
ALTER TABLE `patient_records`
  ADD CONSTRAINT `patient_records_ibfk_1` FOREIGN KEY (`student_username`) REFERENCES `users` (`username`) ON DELETE CASCADE;

--
-- Constraints for table `schedules`
--
ALTER TABLE `schedules`
  ADD CONSTRAINT `fk_schedule_counsellor` FOREIGN KEY (`counsellor_id`) REFERENCES `counsellors` (`counsellor_id`) ON DELETE CASCADE;

--
-- Constraints for table `session_records`
--
ALTER TABLE `session_records`
  ADD CONSTRAINT `fk_record_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_record_counsellor` FOREIGN KEY (`counsellor_id`) REFERENCES `counsellors` (`counsellor_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
