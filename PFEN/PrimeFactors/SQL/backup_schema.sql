-- MySQL dump 10.13  Distrib 5.7.44, for osx10.15 (x86_64)
--
-- Host: localhost    Database: PFEN
-- ------------------------------------------------------
-- Server version	5.7.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Numbers`
--

DROP TABLE IF EXISTS `Numbers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Numbers` (
  `number_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `number` bigint(20) unsigned DEFAULT NULL,
  `total_factors` int(10) unsigned NOT NULL DEFAULT '0',
  `unique_factors` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`number_id`),
  UNIQUE KEY `number` (`number`)
) ENGINE=InnoDB AUTO_INCREMENT=18952319 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `PrimeFactors`
--

DROP TABLE IF EXISTS `PrimeFactors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PrimeFactors` (
  `primefactor_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `prime_id` bigint(20) unsigned DEFAULT NULL,
  `number_id` bigint(20) unsigned DEFAULT NULL,
  `exponent` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`primefactor_id`),
  UNIQUE KEY `unique_number_prime` (`number_id`,`prime_id`),
  KEY `prime_id` (`prime_id`),
  CONSTRAINT `primefactors_ibfk_1` FOREIGN KEY (`prime_id`) REFERENCES `Primes` (`prime_id`),
  CONSTRAINT `primefactors_ibfk_2` FOREIGN KEY (`number_id`) REFERENCES `Numbers` (`number_id`)
) ENGINE=InnoDB AUTO_INCREMENT=266399 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Primes`
--

DROP TABLE IF EXISTS `Primes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Primes` (
  `prime_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `sequence` int(10) unsigned DEFAULT NULL,
  `prime` bigint(255) unsigned DEFAULT NULL,
  `prime_gap` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`prime_id`),
  UNIQUE KEY `sequence` (`sequence`),
  UNIQUE KEY `prime` (`prime`)
) ENGINE=InnoDB AUTO_INCREMENT=664580 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_factorial`
--

DROP TABLE IF EXISTS `inv_factorial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inv_factorial` (
  `inv_factorial_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `number_id` bigint(20) unsigned NOT NULL,
  `inv_factorial_value` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`inv_factorial_id`),
  UNIQUE KEY `number_id` (`number_id`),
  CONSTRAINT `inv_factorial_ibfk_1` FOREIGN KEY (`number_id`) REFERENCES `numbers` (`number_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inv_primeorial`
--

DROP TABLE IF EXISTS `inv_primeorial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inv_primeorial` (
  `inv_primeorial_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `number_id` bigint(20) unsigned NOT NULL,
  `inv_primorial_value` int(10) unsigned NOT NULL,
  PRIMARY KEY (`inv_primeorial_id`),
  UNIQUE KEY `number_id` (`number_id`),
  CONSTRAINT `inv_primeorial_ibfk_1` FOREIGN KEY (`number_id`) REFERENCES `numbers` (`number_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log10`
--

DROP TABLE IF EXISTS `log10`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log10` (
  `log10_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `number_id` bigint(20) unsigned NOT NULL,
  `log10_value` int(10) unsigned NOT NULL,
  PRIMARY KEY (`log10_id`),
  UNIQUE KEY `number_id` (`number_id`),
  CONSTRAINT `log10_ibfk_1` FOREIGN KEY (`number_id`) REFERENCES `numbers` (`number_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log2`
--

DROP TABLE IF EXISTS `log2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log2` (
  `log2_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `number_id` bigint(20) unsigned NOT NULL,
  `log2_value` int(10) unsigned NOT NULL,
  PRIMARY KEY (`log2_id`),
  UNIQUE KEY `number_id` (`number_id`),
  CONSTRAINT `log2_ibfk_1` FOREIGN KEY (`number_id`) REFERENCES `numbers` (`number_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log3`
--

DROP TABLE IF EXISTS `log3`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log3` (
  `log3_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `number_id` bigint(20) unsigned NOT NULL,
  `log3_value` int(10) unsigned NOT NULL,
  PRIMARY KEY (`log3_id`),
  UNIQUE KEY `number_id` (`number_id`),
  CONSTRAINT `log3_ibfk_1` FOREIGN KEY (`number_id`) REFERENCES `numbers` (`number_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log5`
--

DROP TABLE IF EXISTS `log5`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log5` (
  `log5_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `number_id` bigint(20) unsigned NOT NULL,
  `log5_value` int(10) unsigned NOT NULL,
  PRIMARY KEY (`log5_id`),
  UNIQUE KEY `number_id` (`number_id`),
  CONSTRAINT `log5_ibfk_1` FOREIGN KEY (`number_id`) REFERENCES `numbers` (`number_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `log7`
--

DROP TABLE IF EXISTS `log7`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `log7` (
  `log7_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `number_id` bigint(20) unsigned NOT NULL,
  `log7_value` int(10) unsigned NOT NULL,
  PRIMARY KEY (`log7_id`),
  UNIQUE KEY `number_id` (`number_id`),
  CONSTRAINT `log7_ibfk_1` FOREIGN KEY (`number_id`) REFERENCES `numbers` (`number_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-02-15 15:42:18
