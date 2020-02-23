-- phpMyAdmin SQL Dump
--

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `Little_Alchemy_2`
--

-- --------------------------------------------------------

--
-- Table structure for table `categorized`
--

DROP TABLE IF EXISTS `categorized`;
CREATE TABLE IF NOT EXISTS `categorized` (
  `id` bigint(12) unsigned NOT NULL AUTO_INCREMENT,
  `element` bigint(12) unsigned NOT NULL,
  `category` bigint(12) unsigned NOT NULL,
  `last_modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `date_added` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `element`  (`elements`),
  KEY `category` (`categories`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `categorized`
--
ALTER TABLE `categorized`
  ADD CONSTRAINT `recipes_ibfk_1` FOREIGN KEY (`element`)  REFERENCES `elements`   (`id`),
  ADD CONSTRAINT `recipes_ibfk_2` FOREIGN KEY (`category`) REFERENCES `categories` (`id`),

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
