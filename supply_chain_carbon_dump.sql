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
  KEY `parent_id` (`parent_id`),
  KEY `child_id` (`child_id`),
  CONSTRAINT `bom_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `component` (`component_id`),
  CONSTRAINT `bom_ibfk_2` FOREIGN KEY (`child_id`) REFERENCES `component` (`component_id`),
  CONSTRAINT `bom_chk_1` CHECK ((`quantity` > 0)),
  CONSTRAINT `bom_chk_2` CHECK ((`parent_id` <> `child_id`))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bom`
--

LOCK TABLES `bom` WRITE;
/*!40000 ALTER TABLE `bom` DISABLE KEYS */;
INSERT INTO `bom` VALUES (1,1,2,50.000),(2,1,4,1.000),(3,4,3,1.000);
/*!40000 ALTER TABLE `bom` ENABLE KEYS */;
UNLOCK TABLES;

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
  CONSTRAINT `carbon_credit_chk_1` CHECK ((`amount_kg_co2e` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carbon_credit`
--

LOCK TABLES `carbon_credit` WRITE;
/*!40000 ALTER TABLE `carbon_credit` DISABLE KEYS */;
INSERT INTO `carbon_credit` VALUES (1,500.0000,'AVAILABLE',NULL,'2025-02-01'),(2,250.0000,'CLAIMED','Electric Vehicle','2025-02-02');
/*!40000 ALTER TABLE `carbon_credit` ENABLE KEYS */;
UNLOCK TABLES;

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
  PRIMARY KEY (`factor_id`),
  CONSTRAINT `emission_factor_chk_1` CHECK ((`factor_value` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emission_factor`
--

LOCK TABLES `emission_factor` WRITE;
/*!40000 ALTER TABLE `emission_factor` DISABLE KEYS */;
INSERT INTO `emission_factor` VALUES (1,'Lithium',15.500000,'kg CO2e/kg','Kaggle Dataset',2024),(2,'Nickel',12.300000,'kg CO2e/kg','Kaggle Dataset',2024),(3,'Copper',4.100000,'kg CO2e/kg','Kaggle Dataset',2024),(4,'Truck Transport',0.120000,'kg CO2e/tonne-km','Kaggle Dataset',2024),(5,'Electricity',0.700000,'kg CO2e/kWh','Kaggle Dataset',2024);
/*!40000 ALTER TABLE `emission_factor` ENABLE KEYS */;
UNLOCK TABLES;

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
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-26 18:48:44
