-- phpMyAdmin SQL Dump
-- version 3.5.8.1deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Nov 13, 2014 at 10:03 PM
-- Server version: 5.5.34-0ubuntu0.13.04.1
-- PHP Version: 5.4.9-4ubuntu2.4

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT=0;
START TRANSACTION;
SET time_zone = "+00:00";

--
-- Database: `bookmarks`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookmarks`
--
-- Creation: Nov 14, 2014 at 02:40 AM
--

DROP TABLE IF EXISTS `bookmarks`;
CREATE TABLE IF NOT EXISTS `bookmarks` (
		  `bookmark_id` bigint(14) unsigned NOT NULL AUTO_INCREMENT,
		  `href` longtext NOT NULL,
		  `bookmark` longtext NOT NULL,
		  `icon_id` bigint(14) unsigned DEFAULT NULL,
		  `add_date` bigint(14) unsigned NOT NULL,
		  `last_modified` datetime DEFAULT NULL,
		  PRIMARY KEY (`bookmark_id`),
		) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

		--
-- RELATIONS FOR TABLE `bookmarks`:
--   `icon_id`
--       `icons` -> `icon_id`
--

-- --------------------------------------------------------

--
-- Table structure for table `folders`
--
-- Creation: Nov 14, 2014 at 02:58 AM
--

DROP TABLE IF EXISTS `folders`;
CREATE TABLE IF NOT EXISTS `folders` (
		  `folder_id` bigint(14) unsigned NOT NULL AUTO_INCREMENT,
		  `folder_name` mediumtext NOT NULL,
		  `add_date` datetime NOT NULL,
		  `last_modified` datetime DEFAULT NULL,
		  `containing_folder_id` bigint(14) unsigned DEFAULT NULL,
		  `personal_toolbar` tinyint(1) NOT NULL DEFAULT '0',
		  PRIMARY KEY (`folder_id`),
		  KEY `containing_folder_id` (`containing_folder_id`),
		  KEY `containing_folder_id_2` (`containing_folder_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

		--
-- RELATIONS FOR TABLE `folders`:
--   `containing_folder_id`
--       `folders` -> `folder_id`
--

-- --------------------------------------------------------

--
-- Table structure for table `icons`
--
-- Creation: Nov 14, 2014 at 12:35 AM
--

DROP TABLE IF EXISTS `icons`;
CREATE TABLE IF NOT EXISTS `icons` (
		  `icon_id` bigint(14) unsigned NOT NULL AUTO_INCREMENT,
		  `icon` blob NOT NULL,
		  PRIMARY KEY (`icon_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

		--
-- MIME TYPES FOR TABLE `icons`:
--   `icon`
--       `image_png`
--

-- --------------------------------------------------------

--
-- Table structure for table `tagged`
--
-- Creation: Nov 14, 2014 at 02:36 AM
--

DROP TABLE IF EXISTS `tagged`;
CREATE TABLE IF NOT EXISTS `tagged` (
		  `tagged_id` bigint(14) unsigned NOT NULL AUTO_INCREMENT,
		  `bookmark_id` bigint(14) unsigned NOT NULL,
		  `tag_id` bigint(14) unsigned NOT NULL,
		  PRIMARY KEY (`tagged_id`),
		  KEY `bookmark_id` (`bookmark_id`),
		  KEY `tag_id` (`tag_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

		--
-- RELATIONS FOR TABLE `tagged`:
--   `tag_id`
--       `tags` -> `tag_id`
--   `bookmark_id`
--       `bookmarks` -> `bookmark_id`
--

-- --------------------------------------------------------

--
-- Table structure for table `tags`
--
-- Creation: Nov 14, 2014 at 02:12 AM
--

DROP TABLE IF EXISTS `tags`;
CREATE TABLE IF NOT EXISTS `tags` (
		  `tag_id` bigint(14) unsigned NOT NULL AUTO_INCREMENT,
		  `tag` tinytext NOT NULL,
		  PRIMARY KEY (`tag_id`)
		) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

		--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookmarks`
--
ALTER TABLE `bookmarks`
  ADD CONSTRAINT `bookmarks_ibfk_1` FOREIGN KEY (`icon_id`) REFERENCES `icons` (`icon_id`);

--
-- Constraints for table `folders`
--
ALTER TABLE `folders`
  ADD CONSTRAINT `folders_ibfk_1` FOREIGN KEY (`containing_folder_id`) REFERENCES `folders` (`folder_id`);

--
-- Constraints for table `tagged`
--
ALTER TABLE `tagged`
  ADD CONSTRAINT `tagged_ibfk_3` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`tag_id`),
  ADD CONSTRAINT `tagged_ibfk_1` FOREIGN KEY (`bookmark_id`) REFERENCES `bookmarks` (`bookmark_id`);
COMMIT;
