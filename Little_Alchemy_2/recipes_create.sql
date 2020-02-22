-- phpMyAdmin SQL Dump
--

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `Little_Alchemy`
--

-- --------------------------------------------------------

--
-- Table structure for table `recipes`
--

DROP TABLE IF EXISTS `recipes`;
CREATE TABLE IF NOT EXISTS `recipes` (
  `id` bigint(12) unsigned NOT NULL AUTO_INCREMENT,
  `ingredient_1` bigint(12) unsigned NOT NULL,
  `ingredient_2` bigint(12) unsigned NOT NULL,
  `product` bigint(12) unsigned NOT NULL,
  `steps` tinyint unsigned DEFAULT NULL,
  `last_modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `date_added` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ingredient_1` (`ingredient_1`,`ingredient_2`,`product`),
  KEY `ingredient_1_2` (`ingredient_1`),
  KEY `ingredient_2` (`ingredient_2`),
  KEY `product_1` (`product`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `recipes`
--
ALTER TABLE `recipes`
  ADD CONSTRAINT `recipes_ibfk_3` FOREIGN KEY (`product`) REFERENCES `elements` (`id`),
  ADD CONSTRAINT `recipes_ibfk_1` FOREIGN KEY (`ingredient_1`) REFERENCES `elements` (`id`),
  ADD CONSTRAINT `recipes_ibfk_2` FOREIGN KEY (`ingredient_2`) REFERENCES `elements` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
