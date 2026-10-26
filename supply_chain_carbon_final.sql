-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: supply_chain_carbon
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `supply_chain_carbon`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `supply_chain_carbon` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `supply_chain_carbon`;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `audit_id` int NOT NULL AUTO_INCREMENT,
  `table_name` varchar(50) NOT NULL,
  `action` varchar(10) NOT NULL,
  `record_id` int NOT NULL,
  `old_value` varchar(255) DEFAULT NULL,
  `new_value` varchar(255) DEFAULT NULL,
  `changed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`audit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (1,'carbon_credit','UPDATE',1,'AVAILABLE / -','CLAIMED / Laptop','2026-10-26 15:58:01');
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bom`
--

DROP TABLE IF EXISTS `bom`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bom` (
  `bom_id` int NOT NULL AUTO_INCREMENT,
  `parent_id` int NOT NULL,
  `child_id` int NOT NULL,
  `quantity` decimal(12,3) NOT NULL,
  PRIMARY KEY (`bom_id`),
  UNIQUE KEY `uq_bom_edge` (`parent_id`,`child_id`),
  KEY `child_id` (`child_id`),
  CONSTRAINT `bom_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `component` (`component_id`),
  CONSTRAINT `bom_ibfk_2` FOREIGN KEY (`child_id`) REFERENCES `component` (`component_id`),
  CONSTRAINT `bom_chk_1` CHECK ((`quantity` > 0)),
  CONSTRAINT `bom_chk_2` CHECK ((`parent_id` <> `child_id`))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bom`
--

LOCK TABLES `bom` WRITE;
/*!40000 ALTER TABLE `bom` DISABLE KEYS */;
INSERT INTO `bom` VALUES (1,1,2,50.000),(2,1,4,1.000),(3,4,3,1.000);
/*!40000 ALTER TABLE `bom` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_bom_audit_ins` AFTER INSERT ON `bom` FOR EACH ROW BEGIN
  INSERT INTO audit_log(table_name, action, record_id, new_value)
  VALUES ('bom','INSERT',NEW.bom_id,CONCAT(NEW.parent_id,'->',NEW.child_id,' x',NEW.quantity));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_bom_audit_upd` AFTER UPDATE ON `bom` FOR EACH ROW BEGIN
  INSERT INTO audit_log(table_name, action, record_id, old_value, new_value)
  VALUES ('bom','UPDATE',OLD.bom_id,
          CONCAT(OLD.parent_id,'->',OLD.child_id,' x',OLD.quantity),
          CONCAT(NEW.parent_id,'->',NEW.child_id,' x',NEW.quantity));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_bom_audit_del` AFTER DELETE ON `bom` FOR EACH ROW BEGIN
  INSERT INTO audit_log(table_name, action, record_id, old_value)
  VALUES ('bom','DELETE',OLD.bom_id,CONCAT(OLD.parent_id,'->',OLD.child_id,' x',OLD.quantity));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `carbon_credit`
--

DROP TABLE IF EXISTS `carbon_credit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carbon_credit` (
  `credit_id` int NOT NULL AUTO_INCREMENT,
  `amount_kg_co2e` decimal(14,4) NOT NULL,
  `status` varchar(30) DEFAULT 'AVAILABLE',
  `claimed_by` varchar(100) DEFAULT NULL,
  `credit_date` date DEFAULT NULL,
  PRIMARY KEY (`credit_id`),
  CONSTRAINT `carbon_credit_chk_1` CHECK ((`amount_kg_co2e` > 0)),
  CONSTRAINT `chk_credit_status` CHECK ((`status` in (_cp850'AVAILABLE',_cp850'CLAIMED',_cp850'RETIRED')))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carbon_credit`
--

LOCK TABLES `carbon_credit` WRITE;
/*!40000 ALTER TABLE `carbon_credit` DISABLE KEYS */;
INSERT INTO `carbon_credit` VALUES (1,500.0000,'CLAIMED','Electric Vehicle','2025-02-01'),(2,250.0000,'CLAIMED','Electric Vehicle','2025-02-02');
/*!40000 ALTER TABLE `carbon_credit` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_credit_new_available` BEFORE INSERT ON `carbon_credit` FOR EACH ROW BEGIN
  IF NEW.status <> 'AVAILABLE' OR NEW.claimed_by IS NOT NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'New credits must be AVAILABLE and unclaimed';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_credit_audit` AFTER UPDATE ON `carbon_credit` FOR EACH ROW BEGIN
  IF OLD.status <> NEW.status THEN
    INSERT INTO audit_log(table_name, action, record_id, old_value, new_value)
    VALUES ('carbon_credit','UPDATE',OLD.credit_id,
            CONCAT(OLD.status,' / ',IFNULL(OLD.claimed_by,'-')),
            CONCAT(NEW.status,' / ',IFNULL(NEW.claimed_by,'-')));
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `component`
--

DROP TABLE IF EXISTS `component`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `component` (
  `component_id` int NOT NULL AUTO_INCREMENT,
  `component_name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `unit` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`component_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `component`
--

LOCK TABLES `component` WRITE;
/*!40000 ALTER TABLE `component` DISABLE KEYS */;
INSERT INTO `component` VALUES (1,'Battery Pack','Electrical','unit'),(2,'Battery Cell','Electrical','unit'),(3,'Electric Motor','Mechanical','unit'),(4,'Motor Assembly','Mechanical','unit');
/*!40000 ALTER TABLE `component` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `component_material`
--

DROP TABLE IF EXISTS `component_material`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `component_material` (
  `component_id` int NOT NULL,
  `material_id` int NOT NULL,
  `quantity_kg` decimal(12,4) NOT NULL,
  PRIMARY KEY (`component_id`,`material_id`),
  KEY `material_id` (`material_id`),
  CONSTRAINT `component_material_ibfk_1` FOREIGN KEY (`component_id`) REFERENCES `component` (`component_id`),
  CONSTRAINT `component_material_ibfk_2` FOREIGN KEY (`material_id`) REFERENCES `material` (`material_id`),
  CONSTRAINT `component_material_chk_1` CHECK ((`quantity_kg` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `component_material`
--

LOCK TABLES `component_material` WRITE;
/*!40000 ALTER TABLE `component_material` DISABLE KEYS */;
INSERT INTO `component_material` VALUES (2,1,0.5000),(2,2,0.8000),(3,3,12.0000);
/*!40000 ALTER TABLE `component_material` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `emission`
--

DROP TABLE IF EXISTS `emission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emission` (
  `emission_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `activity_type` varchar(50) NOT NULL,
  `co2e_kg` decimal(14,4) NOT NULL,
  `scope` varchar(20) DEFAULT NULL,
  `factor_id` int DEFAULT NULL,
  PRIMARY KEY (`emission_id`),
  KEY `product_id` (`product_id`),
  KEY `factor_id` (`factor_id`),
  CONSTRAINT `emission_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  CONSTRAINT `emission_ibfk_2` FOREIGN KEY (`factor_id`) REFERENCES `emission_factor` (`factor_id`),
  CONSTRAINT `chk_scope` CHECK (((`scope` is null) or (`scope` in (_cp850'Scope 1',_cp850'Scope 2',_cp850'Scope 3')))),
  CONSTRAINT `emission_chk_1` CHECK ((`co2e_kg` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emission`
--

LOCK TABLES `emission` WRITE;
/*!40000 ALTER TABLE `emission` DISABLE KEYS */;
INSERT INTO `emission` VALUES (1,1,'Raw Material',775.0000,'Scope 3',1),(2,1,'Manufacturing',450.0000,'Scope 3',5),(3,1,'Transportation',120.0000,'Scope 3',4),(4,2,'Raw Material',250.0000,'Scope 3',3);
/*!40000 ALTER TABLE `emission` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_emission_validate` BEFORE INSERT ON `emission` FOR EACH ROW BEGIN
  IF NEW.activity_type NOT IN ('Raw Material','Manufacturing','Transportation','Use','End of Life') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid activity_type';
  END IF;
  IF NEW.factor_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Emission must reference an emission factor (provenance required)';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_emission_audit_upd` AFTER UPDATE ON `emission` FOR EACH ROW BEGIN
  IF OLD.co2e_kg <> NEW.co2e_kg THEN
    INSERT INTO audit_log(table_name, action, record_id, old_value, new_value)
    VALUES ('emission','UPDATE',OLD.emission_id,
            CONCAT(OLD.co2e_kg,' kg CO2e'), CONCAT(NEW.co2e_kg,' kg CO2e'));
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_emission_audit_del` AFTER DELETE ON `emission` FOR EACH ROW BEGIN
  INSERT INTO audit_log(table_name, action, record_id, old_value)
  VALUES ('emission','DELETE',OLD.emission_id,CONCAT(OLD.activity_type,': ',OLD.co2e_kg,' kg CO2e'));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `emission_factor`
--

DROP TABLE IF EXISTS `emission_factor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `emission_factor` (
  `factor_id` int NOT NULL AUTO_INCREMENT,
  `activity_type` varchar(50) NOT NULL,
  `factor_value` decimal(12,6) NOT NULL,
  `unit` varchar(50) NOT NULL,
  `source` varchar(150) DEFAULT NULL,
  `year` int DEFAULT NULL,
  `material_id` int DEFAULT NULL,
  PRIMARY KEY (`factor_id`),
  KEY `fk_ef_material` (`material_id`),
  CONSTRAINT `fk_ef_material` FOREIGN KEY (`material_id`) REFERENCES `material` (`material_id`),
  CONSTRAINT `emission_factor_chk_1` CHECK ((`factor_value` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emission_factor`
--

LOCK TABLES `emission_factor` WRITE;
/*!40000 ALTER TABLE `emission_factor` DISABLE KEYS */;
INSERT INTO `emission_factor` VALUES (1,'Lithium',15.500000,'kg CO2e/kg','Kaggle Dataset',2024,1),(2,'Nickel',12.300000,'kg CO2e/kg','Kaggle Dataset',2024,2),(3,'Copper',4.100000,'kg CO2e/kg','Kaggle Dataset',2024,3),(4,'Truck Transport',0.120000,'kg CO2e/tonne-km','Kaggle Dataset',2024,NULL),(5,'Electricity',0.700000,'kg CO2e/kWh','Kaggle Dataset',2024,NULL);
/*!40000 ALTER TABLE `emission_factor` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_factor_validate` BEFORE INSERT ON `emission_factor` FOR EACH ROW BEGIN
  IF NEW.source IS NULL OR TRIM(NEW.source) = '' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Emission factor source is required';
  END IF;
  IF NEW.year IS NULL OR NEW.year < 1990 OR NEW.year > YEAR(CURDATE()) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Emission factor year invalid';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_factor_unit_lock` BEFORE UPDATE ON `emission_factor` FOR EACH ROW BEGIN
  IF NEW.unit <> OLD.unit
     AND EXISTS (SELECT 1 FROM emission WHERE factor_id = OLD.factor_id) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot change unit of a factor already used in emissions';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `factory`
--

DROP TABLE IF EXISTS `factory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `factory` (
  `factory_id` int NOT NULL AUTO_INCREMENT,
  `factory_name` varchar(100) NOT NULL,
  `location` varchar(100) DEFAULT NULL,
  `efficiency` decimal(5,2) DEFAULT NULL,
  `energy_source` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`factory_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `factory`
--

LOCK TABLES `factory` WRITE;
/*!40000 ALTER TABLE `factory` DISABLE KEYS */;
INSERT INTO `factory` VALUES (1,'Chennai Assembly Plant','Chennai',85.50,'Solar + Grid'),(2,'Bangalore Component Plant','Bangalore',78.00,'Grid');
/*!40000 ALTER TABLE `factory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material`
--

DROP TABLE IF EXISTS `material`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `material` (
  `material_id` int NOT NULL AUTO_INCREMENT,
  `material_name` varchar(100) NOT NULL,
  `unit` varchar(20) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`material_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material`
--

LOCK TABLES `material` WRITE;
/*!40000 ALTER TABLE `material` DISABLE KEYS */;
INSERT INTO `material` VALUES (1,'Lithium','kg','Battery raw material'),(2,'Nickel','kg','Battery raw material'),(3,'Copper','kg','Electrical conductor'),(4,'Steel','kg','Structural material');
/*!40000 ALTER TABLE `material` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `product_name` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (1,'Electric Vehicle','Automobile','Electric passenger vehicle'),(2,'Laptop','Electronics','Portable computer');
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_component`
--

DROP TABLE IF EXISTS `product_component`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_component` (
  `product_id` int NOT NULL,
  `component_id` int NOT NULL,
  `quantity` decimal(12,3) NOT NULL DEFAULT '1.000',
  PRIMARY KEY (`product_id`,`component_id`),
  KEY `component_id` (`component_id`),
  CONSTRAINT `product_component_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  CONSTRAINT `product_component_ibfk_2` FOREIGN KEY (`component_id`) REFERENCES `component` (`component_id`),
  CONSTRAINT `product_component_chk_1` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_component`
--

LOCK TABLES `product_component` WRITE;
/*!40000 ALTER TABLE `product_component` DISABLE KEYS */;
INSERT INTO `product_component` VALUES (1,1,1.000);
/*!40000 ALTER TABLE `product_component` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipment`
--

DROP TABLE IF EXISTS `shipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipment` (
  `shipment_id` int NOT NULL AUTO_INCREMENT,
  `supplier_id` int NOT NULL,
  `factory_id` int NOT NULL,
  `transport_mode` varchar(30) DEFAULT NULL,
  `distance_km` decimal(12,2) DEFAULT NULL,
  `weight_kg` decimal(12,2) DEFAULT NULL,
  `shipment_date` date DEFAULT NULL,
  PRIMARY KEY (`shipment_id`),
  KEY `supplier_id` (`supplier_id`),
  KEY `factory_id` (`factory_id`),
  CONSTRAINT `shipment_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `supplier` (`supplier_id`),
  CONSTRAINT `shipment_ibfk_2` FOREIGN KEY (`factory_id`) REFERENCES `factory` (`factory_id`),
  CONSTRAINT `shipment_chk_1` CHECK ((`distance_km` >= 0)),
  CONSTRAINT `shipment_chk_2` CHECK ((`weight_kg` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipment`
--

LOCK TABLES `shipment` WRITE;
/*!40000 ALTER TABLE `shipment` DISABLE KEYS */;
INSERT INTO `shipment` VALUES (1,1,1,'Truck',450.00,1000.00,'2025-01-15'),(2,2,2,'Ship',1200.00,5000.00,'2025-01-20');
/*!40000 ALTER TABLE `shipment` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_shipment_validate` BEFORE INSERT ON `shipment` FOR EACH ROW BEGIN
  IF NEW.transport_mode IS NULL OR NEW.transport_mode NOT IN ('Truck','Ship','Rail','Air') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'transport_mode must be Truck, Ship, Rail or Air';
  END IF;
  IF NEW.distance_km IS NULL OR NEW.weight_kg IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'distance_km and weight_kg are required (missing is not zero)';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `supplier`
--

DROP TABLE IF EXISTS `supplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supplier` (
  `supplier_id` int NOT NULL AUTO_INCREMENT,
  `supplier_name` varchar(100) NOT NULL,
  `country` varchar(50) DEFAULT NULL,
  `contact_info` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`supplier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supplier`
--

LOCK TABLES `supplier` WRITE;
/*!40000 ALTER TABLE `supplier` DISABLE KEYS */;
INSERT INTO `supplier` VALUES (1,'ABC Metals','India','abc@example.com'),(2,'Global Materials Ltd','India','global@example.com');
/*!40000 ALTER TABLE `supplier` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_bom_explosion`
--

DROP TABLE IF EXISTS `v_bom_explosion`;
/*!50001 DROP VIEW IF EXISTS `v_bom_explosion`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_bom_explosion` AS SELECT 
 1 AS `product_id`,
 1 AS `component_id`,
 1 AS `component_name`,
 1 AS `cum_qty`,
 1 AS `lvl`,
 1 AS `path`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_material_emissions`
--

DROP TABLE IF EXISTS `v_material_emissions`;
/*!50001 DROP VIEW IF EXISTS `v_material_emissions`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_material_emissions` AS SELECT 
 1 AS `product_id`,
 1 AS `material_name`,
 1 AS `total_kg`,
 1 AS `factor_value`,
 1 AS `unit`,
 1 AS `source`,
 1 AS `year`,
 1 AS `co2e_kg`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_material_requirements`
--

DROP TABLE IF EXISTS `v_material_requirements`;
/*!50001 DROP VIEW IF EXISTS `v_material_requirements`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_material_requirements` AS SELECT 
 1 AS `product_id`,
 1 AS `material_id`,
 1 AS `material_name`,
 1 AS `total_kg`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'supply_chain_carbon'
--

--
-- Dumping routines for database 'supply_chain_carbon'
--
/*!50003 DROP PROCEDURE IF EXISTS `GetProductTotalEmissions` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetProductTotalEmissions`(
    IN p_product_id INT
)
BEGIN
    SELECT
        p.product_id,
        p.product_name,
        COALESCE(SUM(e.co2e_kg), 0) AS total_emissions_kg_co2e
    FROM product p
    LEFT JOIN emission e
        ON p.product_id = e.product_id
    WHERE p.product_id = p_product_id
    GROUP BY p.product_id, p.product_name;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `supply_chain_carbon`
--

USE `supply_chain_carbon`;

--
-- Final view structure for view `v_bom_explosion`
--

/*!50001 DROP VIEW IF EXISTS `v_bom_explosion`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_bom_explosion` AS with recursive `t` as (select `pc`.`product_id` AS `product_id`,`pc`.`component_id` AS `component_id`,`c`.`component_name` AS `component_name`,cast(`pc`.`quantity` as decimal(24,6)) AS `cum_qty`,1 AS `lvl`,cast(`c`.`component_name` as char(500) charset cp850) AS `path` from (`product_component` `pc` join `component` `c` on((`c`.`component_id` = `pc`.`component_id`))) union all select `t`.`product_id` AS `product_id`,`b`.`child_id` AS `child_id`,`c`.`component_name` AS `component_name`,(`t`.`cum_qty` * `b`.`quantity`) AS `t.cum_qty * b.quantity`,(`t`.`lvl` + 1) AS `t.lvl + 1`,concat(convert(`t`.`path` using utf8mb4),' > ',`c`.`component_name`) AS `CONCAT(t.path,' > ',c.component_name)` from ((`t` join `bom` `b` on((`b`.`parent_id` = `t`.`component_id`))) join `component` `c` on((`c`.`component_id` = `b`.`child_id`))) where (`t`.`lvl` < 20)) select `t`.`product_id` AS `product_id`,`t`.`component_id` AS `component_id`,`t`.`component_name` AS `component_name`,`t`.`cum_qty` AS `cum_qty`,`t`.`lvl` AS `lvl`,`t`.`path` AS `path` from `t` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_material_emissions`
--

/*!50001 DROP VIEW IF EXISTS `v_material_emissions`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_material_emissions` AS select `mr`.`product_id` AS `product_id`,`mr`.`material_name` AS `material_name`,`mr`.`total_kg` AS `total_kg`,`ef`.`factor_value` AS `factor_value`,`ef`.`unit` AS `unit`,`ef`.`source` AS `source`,`ef`.`year` AS `year`,(`mr`.`total_kg` * `ef`.`factor_value`) AS `co2e_kg` from (`v_material_requirements` `mr` left join `emission_factor` `ef` on(((`ef`.`material_id` = `mr`.`material_id`) and (`ef`.`unit` = 'kg CO2e/kg')))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_material_requirements`
--

/*!50001 DROP VIEW IF EXISTS `v_material_requirements`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_material_requirements` AS select `x`.`product_id` AS `product_id`,`m`.`material_id` AS `material_id`,`m`.`material_name` AS `material_name`,sum((`x`.`cum_qty` * `cm`.`quantity_kg`)) AS `total_kg` from ((`v_bom_explosion` `x` join `component_material` `cm` on((`cm`.`component_id` = `x`.`component_id`))) join `material` `m` on((`m`.`material_id` = `cm`.`material_id`))) group by `x`.`product_id`,`m`.`material_id`,`m`.`material_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-26 22:33:46
